--[[
Auto-Fill Last Marker with Subtitle Text (FIXED)
=================================================
Finds the LAST timeline marker that doesn't have subtitle text
in its note yet, and fills it in.

Run this every time you drop a new marker.

Install: %APPDATA%\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Edit\
Run:     Workspace > Scripts > Fill Last Marker Subtitle
--]]

local resolve = Resolve()
local project = resolve:GetProjectManager():GetCurrentProject()
local timeline = project:GetCurrentTimeline()

if not timeline then
    print("ERROR: No timeline open.")
    return
end

-- Get timeline start frame (needed to convert marker positions to absolute)
local tl_start = timeline:GetStartFrame()

-- Get subtitle items
local sub_count = timeline:GetTrackCount("subtitle")
if sub_count == 0 then
    print("ERROR: No subtitle track found.")
    return
end

local subs = {}
for i = 1, sub_count do
    local items = timeline:GetItemListInTrack("subtitle", i)
    if items then
        for _, item in ipairs(items) do
            table.insert(subs, item)
        end
    end
end

if #subs == 0 then
    print("ERROR: No subtitles found.")
    return
end

-- Get all markers
local markers = timeline:GetMarkers()
if not markers then
    print("ERROR: No markers found.")
    return
end

-- Collect frame IDs and sort descending (last first)
local frames = {}
for frame_id, _ in pairs(markers) do
    table.insert(frames, frame_id)
end
table.sort(frames, function(a, b) return a > b end)

-- Find subtitle at a given ABSOLUTE frame
local function get_subtitle_at(abs_frame)
    for _, sub in ipairs(subs) do
        local s = sub:GetStart()
        local e = sub:GetEnd()
        if abs_frame >= s and abs_frame < e then
            local text = sub:GetName()
            if text and text ~= "" then
                return text
            end
        end
    end
    return nil
end

-- Walk from last marker backward, find first one without subtitle in note
for _, frame_id in ipairs(frames) do
    local m = markers[frame_id]
    local name = m["name"] or ""

    -- Skip if name already has subtitle text (marked by brackets)
    if name:match("^%[") then
        -- Already processed, skip
    else
        -- Convert marker frame to absolute position
        local abs_frame = tl_start + frame_id

        -- Found the last unfilled marker
        local sub_text = get_subtitle_at(abs_frame)

        if not sub_text then
            print("Frame " .. frame_id .. " (abs: " .. abs_frame .. ") - No subtitle at this position.")
            return
        end

        -- Clean up
        sub_text = sub_text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        if #sub_text > 80 then
            sub_text = sub_text:sub(1, 80) .. "..."
        end

        -- Build new name
        local new_name
        if name ~= "" then
            new_name = "[" .. sub_text .. "] " .. name
        else
            new_name = "[" .. sub_text .. "]"
        end

        -- Delete and recreate
        local color = m["color"]
        local note = m["note"] or ""
        local duration = m["duration"]
        local custom = m["customData"] or ""

        timeline:DeleteMarkerAtFrame(frame_id)
        local ok = timeline:AddMarker(frame_id, color, new_name, note, duration, custom)

        if ok then
            print("DONE: Frame " .. frame_id .. " [" .. color .. "] <- \"" .. sub_text .. "\"")
        else
            -- Restore original
            timeline:AddMarker(frame_id, color, name, note, duration, custom)
            print("FAILED: Could not update marker at frame " .. frame_id)
        end

        return
    end
end

print("All markers already have subtitle text.")
