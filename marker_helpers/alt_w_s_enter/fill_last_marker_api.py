#!/usr/bin/env python
"""
Trigger fill_last_marker logic via DaVinci Resolve's external scripting API.
No menu navigation or keyboard shortcuts needed.
"""

import sys
import os

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

# Sort frame IDs descending (last first)
frames = sorted(markers.keys(), reverse=True)


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


# Walk from last marker backward, find first one without subtitle in note
for frame_id in frames:
    m = markers[frame_id]
    name = m.get("name", "")

    # Skip if name already has subtitle text (marked by brackets)
    if name.startswith("["):
        continue

    # Convert marker frame to absolute position
    abs_frame = tl_start + frame_id

    # Found the last unfilled marker
    sub_text = get_subtitle_at(abs_frame)

    if not sub_text:
        print(f"Frame {frame_id} (abs: {abs_frame}) - No subtitle at this position.")
        sys.exit(0)

    # Clean up
    sub_text = " ".join(sub_text.split()).strip()
    if len(sub_text) > 80:
        sub_text = sub_text[:80] + "..."

    # Build new name
    if name:
        new_name = f"[{sub_text}] {name}"
    else:
        new_name = f"[{sub_text}]"

    # Delete and recreate
    color = m.get("color", "Blue")
    note = m.get("note", "")
    duration = m.get("duration", 1)
    custom = m.get("customData", "")

    timeline.DeleteMarkerAtFrame(frame_id)
    ok = timeline.AddMarker(frame_id, color, new_name, note, duration, custom)

    if ok:
        print(f'DONE: Frame {frame_id} [{color}] <- "{sub_text}"')
    else:
        # Restore original
        timeline.AddMarker(frame_id, color, name, note, duration, custom)
        print(f"FAILED: Could not update marker at frame {frame_id}")

    sys.exit(0)

print("All markers already have subtitle text.")
