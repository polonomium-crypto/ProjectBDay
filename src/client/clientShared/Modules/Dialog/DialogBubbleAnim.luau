-- [Services]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

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

-- Dialog
local NPCFolder = Workspace.NPC
local dialogPointsFolder = NPCFolder.DialoguePoints
local dialogs

-- Misc varibales
local bubbleOgPos = dialog.Bubble.Position
-------------------------------------------------------------------------------------------------
-- [Changable variables] ------------------------------------------------------------------------
-- Tween
local ANIM_TWEEN_DUR = 0.5
local FADE_ANIM_TWEEN_DUR = 0.2
local ANIM_SCALE_DELTA = 0.1 -- How below the bubble would be in the start of the animation
-------------------------------------------------------------------------------------------------

function shared.setup()

end

function shared.startingAnimation(bubble:ImageLabel)
    -- Tween varibles
    local startAnimTweenInfo = TweenInfo.new(ANIM_TWEEN_DUR, Enum.EasingStyle.Cubic)
    local startAnimGoal = {Position = bubbleOgPos}
    local startFadeAnimTweenInfo = TweenInfo.new(FADE_ANIM_TWEEN_DUR, Enum.EasingStyle.Cubic)
    local startFadeAnimGoal = {ImageTransparency = 0}

    -- Start movement animation
    bubble.Position += UDim2.fromScale(0,ANIM_SCALE_DELTA)
    TweenService:Create(bubble, startAnimTweenInfo, startAnimGoal):Play()

    -- Fading every image
    for _, gui:ImageLabel in bubble:GetChildren() do
        if gui:IsA("ImageLabel") then
            -- Init
            gui.ImageTransparency = 1

            -- Tweening
            TweenService:Create(gui, startFadeAnimTweenInfo, startFadeAnimGoal):Play()
        end
    end

    task.wait(ANIM_TWEEN_DUR)
end

function shared.endingAnimation(bubble:ImageLabel)
    -- Initiale properties
    local bubbleOgPos = bubble.Position

    -- Tween varibles
    local endAnimTweenInfo = TweenInfo.new(ANIM_TWEEN_DUR, Enum.EasingStyle.Cubic)
    local endAnimGoal = {Position = bubble.Position + UDim2.fromScale(0,ANIM_SCALE_DELTA)}
    local endFadeAnimTweenInfo = TweenInfo.new(FADE_ANIM_TWEEN_DUR, Enum.EasingStyle.Cubic)
    local endFadeAnimImageGoal = {ImageTransparency = 1}
    local endFadeAnimTextGoal = {TextTransparency = 1}

    -- Start movement animation
    TweenService:Create(bubble, endAnimTweenInfo, endAnimGoal):Play()

    -- Fading every image
    for _, gui:ImageLabel in bubble:GetChildren() do
        if gui:IsA("ImageLabel") then
            TweenService:Create(gui, endFadeAnimTweenInfo, endFadeAnimImageGoal):Play()
        elseif gui:IsA("Frame") then
            for _, letter in gui:GetChildren() do
                TweenService:Create(letter, endFadeAnimTweenInfo, endFadeAnimTextGoal):Play()
            end
        end
    end

    task.wait(ANIM_TWEEN_DUR) -- Wait till the animation is done

    -- Making sure the bubble isn't visible and moving it back to its original position
    bubble.Visible = false
    bubble.Position = bubbleOgPos
end
return shared