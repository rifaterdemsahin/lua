# –[[
Chapter Title Cards from Markers

For each marker with a name starting with [chapter],
creates a 3-second black solid with big white text
showing the marker name as a chapter title.

The titles are inserted as Fusion Text+ clips.

IMPORTANT:

Place your playhead at the start of the timeline before running
Chapter markers should have names like: [chapter] Introduction
The script reads the marker name (after [chapter]) as the title text
If no [chapter] prefix, ALL markers will be used
Install (Windows): %APPDATA%\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Edit  
Install (Mac):     ~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Edit/
Run:               Workspace > Scripts > Chapter Title Cards
–]]

– ============================================
– EDIT YOUR CHAPTER TITLES HERE
– ============================================
local chapter_titles = {
“Chapter 1”,
“Chapter 2”,
“Chapter 3”,
“Chapter 4”,
“Chapter 5”,
“Chapter 6”,
“Chapter 7”,
“Chapter 8”,
“Chapter 9”,
“Chapter 10”,
}
– ============================================

local resolve = Resolve()
local project = resolve:GetProjectManager():GetCurrentProject()
local timeline = project:GetCurrentTimeline()

if not timeline then
print(“ERROR: No timeline open.”)
return
end

– ============================================
– FADE SETTINGS (in frames)
– ============================================
local fade_in_frames  = 15   – fade in duration
local fade_out_frames = 15   – fade out duration
– ============================================

local fps = tonumber(timeline:GetSetting(“timelineFrameRate”)) or 24
local duration_seconds = 3
local duration_frames = math.floor(duration_seconds * fps)

– Build chapters from the list
local chapters = {}
for i, title in ipairs(chapter_titles) do
table.insert(chapters, {
text = title
})
end

print(“Found “ .. #chapters .. “ chapter markers.”)
print(“FPS: “ .. fps .. “ | Duration: “ .. duration_seconds .. “s (” .. duration_frames .. “ frames)”)
print(””)

– Process each chapter marker
for i, ch in ipairs(chapters) do
print(“Creating chapter “ .. i .. “/” .. #chapters .. “: "” .. ch.text .. “"”)

-- Insert a Fusion Title (inserts at current playhead position)
local ok = timeline:InsertFusionTitleIntoTimeline("Text+")
if not ok then
    print("  FAILED to insert title. Skipping.")
else
    -- Switch to Fusion page to edit the title
    resolve:OpenPage("fusion")
    
    local fu = resolve:Fusion()
    local comp = fu:GetCurrentComp()
    
    if comp then
        local tools = comp:GetToolList()
        local template = nil
        local bg = nil
        
        -- Find the Template (Text+) tool
        for _, tool in pairs(tools) do
            local attrs = tool:GetAttrs()
            if attrs.TOOLS_Name == "Template" then
                template = tool
            end
        end
        
        if template then
            -- Set the chapter text
            template:SetInput("StyledText", ch.text)
            -- Big font size (0.1 = large, relative to frame height)
            template:SetInput("Size", 0.08)
            -- Center alignment
            template:SetInput("Center", {0.5, 0.5})
            -- White text
            template:SetInput("Red1", 1.0)
            template:SetInput("Green1", 1.0)
            template:SetInput("Blue1", 1.0)
            
            print("  Set text: \"" .. ch.text .. "\"")
        else
            print("  WARNING: Could not find Template tool.")
        end
        
        -- Find or create Background (black solid)
        -- Check if there's already a Background node
        local has_bg = false
        for _, tool in pairs(tools) do
            local attrs = tool:GetAttrs()
            if attrs.TOOLS_RegID == "Background" then
                has_bg = true
                bg = tool
                -- Make sure it's black
                bg:SetInput("TopLeftRed", 0)
                bg:SetInput("TopLeftGreen", 0)
                bg:SetInput("TopLeftBlue", 0)
                bg:SetInput("TopLeftAlpha", 1)
                break
            end
        end
        
        if not has_bg then
            -- Add a black background and merge
            bg = comp:AddTool("Background")
            bg:SetInput("TopLeftRed", 0)
            bg:SetInput("TopLeftGreen", 0)
            bg:SetInput("TopLeftBlue", 0)
            bg:SetInput("TopLeftAlpha", 1)
            
            local merge = comp:AddTool("Merge")
            local media_out = comp:FindToolByID("MediaOut")
            
            if merge and media_out and template then
                -- Wire: Background -> Merge (bg input)
                merge:FindMainInput(1):ConnectTo(bg:FindMainOutput(1))
                -- Wire: Text+ -> Merge (fg input)  
                merge:FindMainInput(2):ConnectTo(template:FindMainOutput(1))
                -- Wire: Merge -> MediaOut
                media_out:FindMainInput(1):ConnectTo(merge:FindMainOutput(1))
                
                -- Get comp render range for fade timing
                local comp_start = comp:GetAttrs().COMPN_RenderStart
                local comp_end = comp:GetAttrs().COMPN_RenderEnd
                
                -- Fade in: Blend 0 -> 1 over fade_in_frames
                merge:SetInput("Blend", 0.0, comp_start)
                merge:SetInput("Blend", 1.0, comp_start + fade_in_frames)
                
                -- Fade out: Blend 1 -> 0 over fade_out_frames
                merge:SetInput("Blend", 1.0, comp_end - fade_out_frames)
                merge:SetInput("Blend", 0.0, comp_end)
                
                print("  Created black background with text overlay.")
                print("  Fade in: " .. fade_in_frames .. " frames | Fade out: " .. fade_out_frames .. " frames")
            end
        end
    else
        print("  WARNING: Could not get Fusion composition.")
    end
    
    -- Switch back to Edit page
    resolve:OpenPage("edit")
    
    print("  Done.")
end

print("")
end

print(”========================================”)
print(“DONE! Created “ .. #chapters .. “ chapter title cards.”)
print(”========================================”)
print(””)
print(“NOTE: You may need to manually adjust:”)
print(”  - Duration of each title to 3 seconds (drag edges)”)
print(”  - Position on the timeline if they overlap”)
print(”  - Font choice in Fusion page if needed”)
