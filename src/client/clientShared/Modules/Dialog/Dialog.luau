--[[
Scripters note.
- This script is in charge of parsing and managing affects and such.
- dialogHandler on the other hand is in charge of overseeing everything, also handling player input.

- Absolutely not proud of this script, I wish I could script this better.
- I am sorry if this is hard to understand.
]]

-- [Services]
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

-- [Module]
local dialogFolder = script.Parent.DialogData
local dialogEffectsMod = require(script.Parent.DialogEffects)

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local shared = {}

-- Player
local plr = Players.LocalPlayer

-- Gui 
local playerGui = plr.PlayerGui
local dialog = playerGui:WaitForChild("Dialogue")
local template = dialog.Templates.DialogTemplate
local bubble = dialog.Bubble
local dialogArea = bubble.DialogueArea

-- Dialogs
local dialogFolder = script.Parent.DialogData
local textInitialHorizontalPos = 0-- pixels
local textInitialVerticleScale = 0.1665

-- Sound
local voiceFolder = SoundService["NPC Voice"]
local voiceOutputTemplate = voiceFolder.Voice

-- misc
local hasChangedLine = false
local textPauseDur:number
local skipDialog = false
-------------------------------------------------------------------------------------------------

-- [Changable variables] ------------------------------------------------------------------------
local DEBUG_ON = false
local DEFAULT_TEXT_SCALE = 0.4          -- Make sure to change this in "DialogEffects" aswell.
local DEFAULT_TEXT_SPEED = 0.03         -- The delta time for how fast text is typed. In reality the total delta is this added by MODEL_UP_DUR.
local SPACE_SCALE = 26                  -- Higher the number the smaller the distance of "space" is.
local MODEL_UP_DUR = 0.02               -- This is the time to wait for the NPC to bop up
-------------------------------------------------------------------------------------------------
function shared:init()

    -- Creating the necessary table
    shared["dialogData"] = {}

    -- Getting the entire data of dialog from several files and puts it into one table.
    for _, mod in dialogFolder:GetChildren() do
        local dialogData = require(mod)

        for name, texts in dialogData["dialogs"] do
            -- Creating a new table for the specific model.
            shared["dialogData"][name] = {} -- e.g. name = Gwagwa1

            -- Inserting the model specfic dialog into the table
            shared["dialogData"][name]["dialogs"] = texts

            -- Inserting the remaining parent properties into the table
            for dataName, data in dialogData do
                if dataName == "dialogs"  then
                    continue
                end
                shared["dialogData"][name][dataName] = data
            end
        end
    end
    if DEBUG_ON then
        print(shared)
    end
end

-- Pareses texts from dialog in dialogData into something the machine can understand. Returns segments
function shared:parseDialog(dialog:string)
    local segments = {}
    local activeTags = {}
    local currentIndex = 1

    while currentIndex < #dialog do
        local tagStart, tagEnd = dialog:find("<[^>]+>",currentIndex) -- Getting index of where the tag begins
        
        if tagStart then
            local subLine = dialog:sub(currentIndex, tagStart-1) -- Doing this so we can get the text before the next tag

            if #subLine > 0 then
                table.insert(segments, {["text"] = subLine, ["format"] = table.clone(activeTags)}) -- Inserting lines before tag into segments
            end

            -- Handling with what to do with text inbetween tags. 
            if dialog:match("^</", tagStart) then
                -- Ending tag
                local tagName = dialog:match("</(%a+)>", tagStart)
                for i = #activeTags, 1, -1 do
                    if activeTags[i]["tagname"] == tagName then
                        table.remove(activeTags, i)
                    end
                end
            else
                -- Starting tag
                local tagName, attribute = dialog:match("<(%a+)=?(.-)>", tagStart) 
                table.insert(activeTags, {["tagname"] = tagName, ["attribute"] = attribute})
            end

            currentIndex = tagEnd + 1
        else
            local subLine = dialog:sub(currentIndex, #dialog)
            table.insert(segments, {["text"] = subLine, ["format"] = {}})
            currentIndex = #dialog
        end
    end
    return segments
end

function shared:main(parseDialog:table, targetNPCName:string?, medium:Frame, noModel:boolean?)
    local format:table -- format: [tagName], [attribute]
    local text:string -- text
    local currentVerticlePos = 0
    local currentHorizontalPos = 0
    local mediumSize = medium.AbsoluteSize

    -- Initializing move method
    if not noModel then
        dialogEffectsMod:moveModelInit(targetNPCName)
    end
    
    -- retrieving format and text applying affects and positioning texts
    for _, v in parseDialog do
        if v["format"] then
            format = v["format"]

            -- Sorting the priority of the format
            table.sort(format, function(a, b)
                local priorityA = dialogEffectsMod.priorities[a.tagname] or 999
                local priorityB = dialogEffectsMod.priorities[b.tagname] or 999
                return priorityA < priorityB
            end)

             -- For debugging
            if DEBUG_ON then
                print(parseDialog)
            end
        end

        text = v["text"]

        for _,letter:string in text:split("") do

            -- Create text
            local uiLetter = shared.createText(letter, medium)

            ----------------------------------------------------------------------------------------------------------------
            -- This section has to be done in this order, otherwise the code will not work. (There is definately a better way of doing this)
            -- Change text font
            local hasDoneFont = false
            if format[2] then
                if format[2].tagname == "font" then
                    dialogEffectsMod.font(uiLetter, format[2].attribute)
                    hasDoneFont = true
                end
            end
            if not hasDoneFont then
                uiLetter.Font = shared["dialogData"][targetNPCName].font
            end

             -- Positioning texts
            uiLetter.Position = UDim2.fromOffset(currentHorizontalPos + textInitialHorizontalPos, 0)
            uiLetter.Position = uiLetter.Position + UDim2.fromScale(0, currentVerticlePos + textInitialVerticleScale)

            -- Setting the size and position first
            local sizeScale = nil
            for i = 1,2 do
                if not format[i] then
                    break
                end
                if format[i].tagname == "size" then
                    sizeScale = format[1].attribute
                elseif format[i].tagname == "scaleSize" then
                    sizeScale = format[1].attribute
                    dialogEffectsMod.scaleSize(uiLetter, sizeScale, mediumSize)
                end
            end
            dialogEffectsMod.size(uiLetter, sizeScale, mediumSize) -- This cannot be inside the loop above because otherwise the default value would not be set.

            -- If it is a space then make sure there is space inbetween
            if uiLetter.Text == " " then
                currentHorizontalPos += mediumSize.X * (sizeScale or DEFAULT_TEXT_SCALE) / SPACE_SCALE
            else
                currentHorizontalPos += uiLetter.TextBounds.X -- Making sure the spacing between texts are appropriate
            end
            ----------------------------------------------------------------------------------------------------------------

            -- Creating newline
            if not hasChangedLine then
                for _, v in format do
                    local tagName = v["tagname"]
                    local attribute = v["attribute"]

                    if tagName == "newline" then
                        hasChangedLine = true
                        currentHorizontalPos = 0
                        currentVerticlePos = 0.333 * (attribute - 1) -- Attribute is the line its on. 0.333 is the scale its separated in.
                        break
                    end
                end
            end

            -- Getting affect data and applying them.
            for _, v in format do
                local tagName = v["tagname"]
                local attribute = v["attribute"]

                if tagName == "newline" then
                    hasChangedLine = true
                    currentHorizontalPos = 0
                    currentVerticlePos = 0.333 * (attribute - 1) -- Attribute is the line its on. 0.333 is the scale its separated in.
                    continue
                end

                -- Skipping newline so because it is handled in positionManager
                if tagName == "size" or tagName == "font" or tagName == "scaleSize" then
                    continue
                end

                local success, output
                if dialogEffectsMod[tagName] then
                    success, output = pcall(dialogEffectsMod[tagName], uiLetter, attribute)
                    if not success then
                        warn("Error applying effect '" .. tagName .. "': " .. output)
                    end
                end

                if output then
                    textPauseDur = output -- Gets the pause duration and applies it.
                end
            end

            if not(letter == " " or letter == ".") and not skipDialog and not noModel then
                -- Moving the model up
                dialogEffectsMod:moveModel(true)

                -- Retrieve sound and plays sound
                task.spawn(function()
                    shared.playSound(targetNPCName)
                    task.wait(MODEL_UP_DUR)
                    dialogEffectsMod:moveModel(false)
                end)
            end
            if skipDialog and not noModel then
            elseif textPauseDur then
                task.wait(textPauseDur)
            else
                task.wait(DEFAULT_TEXT_SPEED)
            end 

            -- Resting variables
            textPauseDur = nil
        end
        hasChangedLine = false -- newline is now able to move to a newline
    end

    -- Reseting text to its original position because input has been recieved
    currentHorizontalPos = 0
    currentVerticlePos = 0
    hasChangedLine = false
    skipDialog = false
    dialogEffectsMod:cleanUpMoveModel()
end

function shared.createText(letter:string, medium)
     -- Creating letter
    local uiLetter:TextLabel = template:Clone()
    uiLetter.Parent = medium
    uiLetter.Name = letter
    uiLetter.Text = letter
    uiLetter.Visible = true
    return uiLetter
end

function shared.skipDialog()
    skipDialog = true
end

function shared.playSound(nameOfNPC:string)
    local voiceSound = shared["dialogData"][nameOfNPC]["voice"]
    local pickedSound = voiceSound[math.random(1, #voiceSound)]

    if pickedSound then
        voiceOutputTemplate.SoundId = pickedSound
        voiceOutputTemplate:Play()
    else
        warn("There are no specified sounds to play.")
    end
end

return shared