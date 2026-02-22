#!/usr/bin/env python
"""
Name all unnamed markers from subtitle text at their position.
Finds every marker with an empty name or a default name (e.g. "Marker 42")
and fills it with the subtitle text.

WHY: When you trim clips, markers stay at their timeline position but subtitles
move with the clip. Having subtitle text in the marker name makes it easy to
identify and reposition markers after trimming — they're locked to the script
(subtitle), not to the timeline.

Uses DaVinci Resolve's external scripting API — no menu navigation needed.
"""

import sys
import os
import re

# Ensure the Resolve scripting module is discoverable
modules_path = os.path.join(
    os.getenv("PROGRAMDATA", ""),
    "Blackmagic Design", "DaVinci Resolve", "Support",
    "Developer", "Scripting", "Modules"
)
if modules_path not in sys.path:
    sys.path.insert(0, modules_path)

try:
    import DaVinciResolveScript as dvr
except ImportError as e:
    print(f"ERROR: Cannot import DaVinciResolveScript: {e}")
    print(f"Expected module at: {modules_path}")
    sys.exit(1)

resolve = dvr.scriptapp("Resolve")
if not resolve:
    print("ERROR: Could not connect to DaVinci Resolve. Is it running?")
    sys.exit(1)

project = resolve.GetProjectManager().GetCurrentProject()
if not project:
    print("ERROR: No project open.")
    sys.exit(1)

timeline = project.GetCurrentTimeline()
if not timeline:
    print("ERROR: No timeline open.")
    sys.exit(1)

print(f"Project: {project.GetName()}")
print(f"Timeline: {timeline.GetName()}")

# --- Get timeline start frame ---
tl_start = timeline.GetStartFrame()

# --- Get subtitle items ---
sub_count = timeline.GetTrackCount("subtitle")
if sub_count == 0:
    print("ERROR: No subtitle track found.")
    sys.exit(1)

subs = []
for i in range(1, sub_count + 1):
    items = timeline.GetItemListInTrack("subtitle", i)
    if items:
        for item in items:
            subs.append(item)

if len(subs) == 0:
    print("ERROR: No subtitles found.")
    sys.exit(1)

print(f"Found {len(subs)} subtitle(s)")

# --- Get all markers ---
markers = timeline.GetMarkers()
if not markers:
    print("ERROR: No markers found.")
    sys.exit(1)

print(f"Found {len(markers)} marker(s)")

# Sort frame IDs ascending (process in timeline order)
frames = sorted(markers.keys())

# Pattern to match Resolve's default marker names:
# "Marker 1", "Marker 42", "Yellow Marker", "Blue Marker", "Red Marker", etc.
DEFAULT_MARKER_NAME = re.compile(
    r"^(Marker\s+\d+|"                          # "Marker 1", "Marker 42"
    r"(Red|Blue|Green|Yellow|Cyan|Pink|Purple|Fuchsia|Rose|Lavender|Sky|Mint|Lemon|Sand|Cocoa|Cream)\s+Marker)$",  # "Yellow Marker", "Blue Marker"
    re.IGNORECASE
)


def is_unnamed(name):
    """Check if a marker name is empty or a default auto-generated name.
    Names wrapped in [...] are script-sourced and should NOT be replaced."""
    if not name or not name.strip():
        return True
    name = name.strip()
    # Names in brackets are from our script — already processed, skip
    if name.startswith("[") and "]" in name:
        return False
    # Resolve auto-names markers as "Marker 1", "Yellow Marker", etc.
    if DEFAULT_MARKER_NAME.match(name):
        return True
    return False


def get_subtitle_at(abs_frame):
    """Find subtitle text at a given absolute frame position."""
    for sub in subs:
        s = sub.GetStart()
        e = sub.GetEnd()
        if abs_frame >= s and abs_frame < e:
            text = sub.GetName()
            if text and text.strip():
                return text
    return None


# Walk through all markers and name the ones with empty names
updated = 0
skipped = 0
no_subtitle = 0

for frame_id in frames:
    m = markers[frame_id]
    name = m.get("name", "")

    # Skip markers that already have a meaningful name (not empty, not "Marker N")
    if not is_unnamed(name):
        skipped += 1
        continue

    # Convert marker frame to absolute position
    abs_frame = tl_start + frame_id

    # Find subtitle at this position
    sub_text = get_subtitle_at(abs_frame)

    if not sub_text:
        no_subtitle += 1
        print(f"  SKIP: Frame {frame_id} (abs: {abs_frame}) - No subtitle at this position")
        continue

    # Clean up subtitle text
    sub_text = " ".join(sub_text.split()).strip()
    if len(sub_text) > 80:
        sub_text = sub_text[:80] + "..."

    new_name = f"[{sub_text}]"

    # Delete and recreate marker with the new name
    color = m.get("color", "Blue")
    note = m.get("note", "")
    duration = m.get("duration", 1)
    custom = m.get("customData", "")

    timeline.DeleteMarkerAtFrame(frame_id)
    ok = timeline.AddMarker(frame_id, color, new_name, note, duration, custom)

    if ok:
        updated += 1
        print(f'  DONE: Frame {frame_id} [{color}] <- "{sub_text}"')
    else:
        # Restore original
        timeline.AddMarker(frame_id, color, name, note, duration, custom)
        print(f"  FAILED: Could not update marker at frame {frame_id}")

print(f"\nSummary: {updated} named, {skipped} already had names, {no_subtitle} had no subtitle")
