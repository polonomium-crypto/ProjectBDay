-- THINGS TO NOTE ABOUT THIS DIALOG SYSTEM --
-- 1. You have to copy the "DialoguePoints" template and create a folder that has the name of the NPC and put that template into that folder.
-- 2. Now rename that into the characters name but have it be distinguishable from other baseparts within that folder. (e.g. DeadMan(folder) --> DeadMan1, DeadMan2, etc)
-- 3.


-- [Services]
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- [Modules]
local modulesFolder = script.Parent.Parent.Parent.Modules
local dialogFolder = modulesFolder.Dialog
local dialogMod = require(dialogFolder.Dialog)
local dialogBubbleAnim = require(dialogFolder.DialogBubbleAnim)
local interactLabelAnimMod = require(dialogFolder.DialogInteractLabelAnim)
local dialogSupportMod = require(dialogFolder.DialogSupportUI)
local playerStateManagerMod = require(modulesFolder.Player.PlayerStateManager)
local plrVarMod = require(modulesFolder.Player.PlayerVariables)
local plrCamMod = require(modulesFolder.Player.PlayerCamHandler)

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local shared = {}

-- Player
local plr = Players.LocalPlayer
local chara = plr.Character or plr.CharacterAdded
local humanoid = chara:FindFirstChild("Humanoid")
local HRP = chara:FindFirstChild("HumanoidRootPart")

-- Gui 
local playerGui = plr.PlayerGui
local dialog = playerGui.Dialogue
local bubble = dialog.Bubble
local dialogArea = bubble.DialogueArea

-- Dialog
local NPCFolder = Workspace.NPC
local dialogPointsFolder = NPCFolder.DialoguePoints
local dialogs

-- Sound
local DialogSFXFolder = SoundService.DialogSFX
local nextSound = DialogSFXFolder.Next
local bubbleAppearSound = DialogSFXFolder.BubbleAppear
local bubbleDisapperSound = DialogSFXFolder.BubbleDisappear

-- Cam
local cam = Workspace.CurrentCamera
local ogCamPosition:CFrame

-- Threads
local spawn:thread = nil

-- Misc
local targetNPC: Model
local inDialog = false
local counter = 1
local inProx = false
local controlDb = true -- Debounce for click
-------------------------------------------------------------------------------------------------
-- [Changable variables] ------------------------------------------------------------------------
-- Cam
local CAM_OFFSET = {X = 8, Y = 0, Z = -5} -- CFrame.new(-5,8,-5)
local CAM_FOV_ZOOM_DUR = 0.9
local CAM_DEFAULT_FOV = plrVarMod.FOV
local CAM_ZOOM_FOV = plrVarMod.FOV - 50
local CAM_POSITION_DURATION = 0.6

-- Player
local TRANSPARENCY_VAL = 0.8

-- Misc
local MIN_DIST = 10 -- The minimum distance between the player and the NPC in studs
local BUTTON_DEBOUNCE_TIME = 0.1

-- Sound affects
local BUBBLE_APPEAR_SFX = "rbxassetid://18202483174" -- 3034338716 325574531 18202483174
local NEXT_SOUND_SFX = "rbxassetid://5213483997" --8920918251 87437544236708 1259155076 325574531 5213483997
local BUBBLE_DISAPPEAR_SFX = "rbxassetid://8968249849"

local BUBBLE_APPEAR_VOL = 0.5
local NEXT_SOUND_VOL = 0.1
local BUBBLE_DISAPPEAR_VOL = 0.5
-------------------------------------------------------------------------------------------------
function shared:init()
    -- Initialize sound affects.
    nextSound.SoundId = NEXT_SOUND_SFX
    bubbleAppearSound.SoundId = BUBBLE_APPEAR_SFX
    bubbleDisapperSound.SoundId = BUBBLE_DISAPPEAR_SFX

    nextSound.Volume = NEXT_SOUND_VOL
    bubbleAppearSound.Volume = BUBBLE_APPEAR_VOL
    bubbleDisapperSound.Volume = BUBBLE_DISAPPEAR_VOL

    lcl:createInteractionZone()
end

-- Getting camera to its position and disabling players movements
function lcl:setup(targetNPC:BasePart)
    -- Disabling players movemnets
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0

    -- Changing players transparency value
    playerStateManagerMod.invisPlayer(TRANSPARENCY_VAL)

    -- Diabling interactable label
    targetNPC.InteractLabel.Enabled = false

    -- Disabling players camera and getting last position of cam
    ogCamPosition = cam.CFrame
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CameraSubject = targetNPC

    -- Making camera face the NPC that is talking and zooming in
    plrCamMod:camStateChanger(plrVarMod.camStates.IN_DIALOGUE)
    lcl:positionCam()
    lcl:camFOV(CAM_ZOOM_FOV)

    -- Display dialog supports (name, blackboarder)
    local name = dialogMod["dialogData"][targetNPC.Name]["name"]
    dialogSupportMod.moveBlackScreens()
    dialogSupportMod.printName(name, targetNPC.Name)

    -- Making UI appear
    dialog.Enabled = true
    bubble.Visible = true
    dialogBubbleAnim.startingAnimation(bubble)
end

function lcl:positionCam()
    -- Init
    local positionCamTweenInfo = TweenInfo.new(CAM_POSITION_DURATION, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
    local pos = targetNPC.CFrame.LookVector * CAM_OFFSET.X + targetNPC.CFrame.RightVector * CAM_OFFSET.Z + targetNPC.CFrame.UpVector * CAM_OFFSET.Y + targetNPC.Position
    local positionCamGoal = {CFrame = CFrame.lookAt(pos, targetNPC.Position)}

    TweenService:Create(cam, positionCamTweenInfo, positionCamGoal):Play()
end

function lcl:camFOV(FOV:IntValue)
    -- Init
    local camFOVTweenInfo = TweenInfo.new(CAM_FOV_ZOOM_DUR, Enum.EasingStyle.Cubic)
    local camFOVGoal = {FieldOfView = FOV}

    TweenService:Create(cam, camFOVTweenInfo, camFOVGoal):Play()
end

local function dialogInput(actionName, inputState, _inputObject)
    if inputState == Enum.UserInputState.Begin  and controlDb then
        controlDb = false -- To prevent multiple clicks happening at the same time
        if actionName == "Next" then -- Input for progressing dialog

            -- Function that creates a coroutine for typing and managing affects of the texts so the input function would not get interrupted.
            local function coroutineFunc()
                counter += 1                              -- Keeps track of the current letter in the dialog to not go over the limit. Also so it points to the right letter within the dialog.

                -- Play sound affect for going to the next dialog
                nextSound:Play()

                 -- Check if the dialog is over or not
                if counter > #dialogs then
                    lcl:dialogFinished()                  -- If it is over, restore default settings
                    task.wait(0.3)
                    controlDb = true
                    return
                end

                local parsedDialog = dialogMod:parseDialog(dialogs[counter]) -- Parsing dialog so the program can know what to do

                spawn = coroutine.create(function()
                    dialogArea:ClearAllChildren()
                    dialogMod:main(parsedDialog, targetNPC.Name, dialogArea)
                end)
                coroutine.resume(spawn)
            end
            
            if spawn == nil then                          -- Seeing if the dialog exists or not
                coroutineFunc()
            elseif coroutine.status(spawn) == "dead" then -- Seeing if the dialog is finished doing its thing
                coroutineFunc()
            else                                          -- If dialog exists and is still playing then skip the dialog
                dialogMod.skipDialog()
                controlDb = true
                return
            end

            
        elseif actionName == "interact" and not inDialog and inProx then -- Input for Interaction
            inDialog = true

            -- Plays sound
            bubbleAppearSound:Play()

            -- Remove controls for interacting with NPCs
            ContextActionService:UnbindAction("interact")

            -- Start dialog
            lcl:setup(targetNPC)
            lcl:startDialog(targetNPC)  
        end

        task.wait(BUTTON_DEBOUNCE_TIME)
        controlDb = true
    end
end

function lcl:startDialog(targetNPC:BasePart)
    -- Settig up the input for the player
    ContextActionService:BindAction("Next", dialogInput, false, Enum.KeyCode.E, Enum.UserInputType.MouseButton1)
    
    -- Getting the dialog texts specfic to that character.
    dialogs = dialogMod["dialogData"][targetNPC.Name]["dialogs"]
    
    -- Rest dialog area and print new dialog
    dialogArea:ClearAllChildren()
    local parsedDialog = dialogMod:parseDialog(dialogs[counter])
    dialogMod:main(parsedDialog, targetNPC.Name, dialogArea)
end

-- Going through all instances in dialogPointsFolder creating a interactable area
function lcl:createInteractionZone()
    -- Initialize
    for _, DP:BasePart in dialogPointsFolder:GetDescendants() do
        -- Making sure it is a basepart
        if not DP:IsA("Part") then
            continue
        end

        DP.InteractLabel.Enabled = false
    end

    -- Setting the controls to interact so the player can interact with the NPCs
    ContextActionService:BindAction("interact", dialogInput, false, Enum.KeyCode.E) -- Button to open dialog

    local mostClosestNPC = nil -- Note that this is not refering to the model of the NPC, but the dialog point
    local mostClosestNPCDist = MIN_DIST -- This is because the max distance in range is MIN_DIST
    local tableOfInRangeNPCs = {}
    
    RunService.Heartbeat:Connect(function(deltaTime)
        table.clear(tableOfInRangeNPCs) -- Clear table to get most up to date data

        -- Gets the list of NPCs around the player in range
        for _, DP:BasePart in dialogPointsFolder:GetDescendants() do
            -- Making sure it is a basepart
            if not DP:IsA("Part") then
                continue
            end
            
            local distFromNPC = (HRP.Position - DP.Position).Magnitude -- The distance from HRP to NPC

            if distFromNPC < MIN_DIST then
                tableOfInRangeNPCs[DP] = distFromNPC -- If the NPC is close to the player it would be added to a list to be compared to other NPCs distance to find the closest NPC.
            end
        end

        local counter = 0
        for _, v in tableOfInRangeNPCs do
            counter += 1
        end

        -- If the disctionary is empty,
        if counter ~= 0 then
            -- Compare which NPC is closest in the list
            for Npc, dist in tableOfInRangeNPCs do
                if dist < mostClosestNPCDist then
                    -- Gets NPC and distance from the most closest NPC
                    mostClosestNPC = Npc
                    mostClosestNPCDist = (HRP.Position - Npc.Position).Magnitude
                end
            end
        end

        -- Display interact label, and activate button capabilities, and manages if the NPCs are in proximity or not
        if mostClosestNPC and targetNPC then
            if mostClosestNPC ~= targetNPC then -- This is for when the most closest NPC changes to another NPC
                inProx = true

                --mostClosestNPC.InteractLabel.Enabled = true
                interactLabelAnimMod.InteractLabelAnim(mostClosestNPC)
                targetNPC.InteractLabel.Enabled = false
                targetNPC = mostClosestNPC
            end
        elseif mostClosestNPC then -- This is for when there is no target saved and that there would be a new target
            inProx = true
            targetNPC = mostClosestNPC

            --mostClosestNPC.InteractLabel.Enabled = true
            interactLabelAnimMod.InteractLabelAnim(mostClosestNPC)
        elseif targetNPC then -- This is for when there isn't any NPCs near by.
            inProx = false
            targetNPC.InteractLabel.Enabled = false
            targetNPC = nil
        end
        
        mostClosestNPC = nil
        mostClosestNPCDist = MIN_DIST
        counter = 0
    end)
end

-- Called when player finishes dialog.
function lcl:dialogFinished()
    -- No longer in dialog
    inDialog = false

     -- Making player back to visible transparency
    playerStateManagerMod.invisPlayer(0)

    -- Making the UI disapear
    dialogBubbleAnim.endingAnimation(bubble)
    targetNPC.InteractLabel.TextLabel.Visible = true

    -- Playing Bubble disappearing SFX
    --bubbleDisapperSound:Play()

    -- Making name frame disapear.
    dialogSupportMod.removeBlackScreens()
    dialogSupportMod.removeName()

    -- Reposition cam
    plrCamMod:camStateChanger(plrVarMod.camStates.HEAD_BOB)
    lcl:camFOV(CAM_DEFAULT_FOV)
    local repositionCamTweenInfo = TweenInfo.new(CAM_POSITION_DURATION, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
    local repositionCamGoal = {CFrame = ogCamPosition}
    TweenService:Create(cam, repositionCamTweenInfo, repositionCamGoal):Play()
    task.wait(CAM_POSITION_DURATION)

    -- Disabling players movemnets
    humanoid.WalkSpeed = plrVarMod.WALKSPEED
    humanoid.JumpPower = plrVarMod.JUMP_POWER
    humanoid.JumpHeight = plrVarMod.JUMP_HEIGHT

    -- Disabling players camera and setting 
    cam.CameraType = Enum.CameraType.Custom
    cam.CameraSubject = humanoid

    -- Manging controls
    ContextActionService:UnbindAction("Next")
    ContextActionService:BindAction("interact", dialogInput, false, Enum.KeyCode.E)

    -- Making the interat label appear again
    targetNPC.InteractLabel.Enabled = true

    -- Managing variables
    counter = 1
end

return shared