#!/usr/bin/env python
"""
Export all timeline markers to a text file with full data and metadata.
Uses DaVinci Resolve's external scripting API.
"""

import sys
import os
from datetime import datetime

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

project_name = project.GetName()
timeline_name = timeline.GetName()
fps = float(timeline.GetSetting("timelineFrameRate") or 24)
tl_start = timeline.GetStartFrame()

print(f"Project: {project_name}")
print(f"Timeline: {timeline_name}")
print(f"Frame Rate: {fps}")

# Get all markers
markers = timeline.GetMarkers()
if not markers:
    print("ERROR: No markers found.")
    sys.exit(1)

print(f"Found {len(markers)} marker(s)")

# Helper: convert frame number to timecode HH:MM:SS:FF
def frames_to_timecode(frame, fps):
    total_frames = int(frame)
    ff = total_frames % int(fps)
    total_seconds = total_frames // int(fps)
    ss = total_seconds % 60
    total_minutes = total_seconds // 60
    mm = total_minutes % 60
    hh = total_minutes // 60
    return f"{hh:02d}:{mm:02d}:{ss:02d}:{ff:02d}"

# Output file next to this script
script_dir = os.path.dirname(os.path.abspath(__file__))
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_file = os.path.join(script_dir, f"markers_export_{timestamp}.txt")

frames = sorted(markers.keys())

with open(output_file, "w", encoding="utf-8") as f:
    # Header
    f.write("=" * 80 + "\n")
    f.write(f"MARKER EXPORT\n")
    f.write(f"=" * 80 + "\n")
    f.write(f"Project:    {project_name}\n")
    f.write(f"Timeline:   {timeline_name}\n")
    f.write(f"Frame Rate: {fps} fps\n")
    f.write(f"TL Start:   {tl_start}\n")
    f.write(f"Exported:   {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    f.write(f"Total:      {len(markers)} markers\n")
    f.write("=" * 80 + "\n\n")

    # Column headers
    f.write(f"{'#':<5} {'Frame':<10} {'Abs Frame':<12} {'Timecode':<14} {'Color':<12} {'Duration':<10} {'Name'}\n")
    f.write(f"{'—'*4}  {'—'*9}  {'—'*11}  {'—'*13}  {'—'*11}  {'—'*9}  {'—'*40}\n")

    for i, frame_id in enumerate(frames, 1):
        m = markers[frame_id]
        abs_frame = tl_start + frame_id
        timecode = frames_to_timecode(abs_frame, fps)
        name = m.get("name", "")
        color = m.get("color", "")
        note = m.get("note", "")
        duration = m.get("duration", 1)
        custom = m.get("customData", "")

        f.write(f"{i:<5} {frame_id:<10} {abs_frame:<12} {timecode:<14} {color:<12} {duration:<10} {name}\n")

        # Write note and custom data if present
        if note:
            f.write(f"      {'Note:':<10} {note}\n")
        if custom:
            f.write(f"      {'Custom:':<10} {custom}\n")

    # Summary
    f.write(f"\n{'=' * 80}\n")

    # Color breakdown
    color_counts = {}
    for frame_id in frames:
        c = markers[frame_id].get("color", "Unknown")
        color_counts[c] = color_counts.get(c, 0) + 1

    f.write(f"\nColor Breakdown:\n")
    for color, count in sorted(color_counts.items(), key=lambda x: -x[1]):
        f.write(f"  {color:<15} {count}\n")

print(f"\nExported to: {output_file}")
