-- [Services]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

-- Misc
local targetNPC

-- Math
local pi = math.pi
-------------------------------------------------------------------------------------------------
-- [Changable variables] ------------------------------------------------------------------------
-- UI Tween
local INTERATLABEL_FADE_DUR = 0.8
local MOVE_DUR = 0.6
local BOBBING_FREQUENCY = 2 -- The higher the number the slower, unit in seconds
local BOBBING_AMPLITUDE = 0.01 -- Measured in studs
-------------------------------------------------------------------------------------------------

function shared.InteractLabelAnim(mostClosestNPC:BasePart)
    local interactLabel = mostClosestNPC.InteractLabel
    local textLabel = interactLabel.TextLabel
    local interactLabelStroke = textLabel.UIStroke
    local ogPos = interactLabel.StudsOffset

    -- Fade tween var
    local labelFadeTweenInfo = TweenInfo.new(INTERATLABEL_FADE_DUR, Enum.EasingStyle.Cubic)
    local labelFadeGoal = {BackgroundTransparency = 0, TextTransparency = 0}
    local strokeFadeGoal = {Transparency = 0}

    -- Move up tween var
    local labelMoveTweenInfo = TweenInfo.new(MOVE_DUR, Enum.EasingStyle.Elastic)
    local labelMoveGoal = {StudsOffset = ogPos}

    -- Enlarge tween var
    local labelEnlargeTweenInfo = TweenInfo.new(MOVE_DUR, Enum.EasingStyle.Elastic)
    local labelEnlargeGoal = {Size = UDim2.fromScale(1.2,1.2)}

    -- Init
    textLabel.BackgroundTransparency = 1
    textLabel.TextTransparency = 1
    interactLabelStroke.Transparency = 1
    interactLabel.Enabled = true
    textLabel.Visible = true

    interactLabel.StudsOffset = Vector3.new(0,1,0)
    interactLabel.Size = UDim2.fromScale(0,0)

    TweenService:Create(interactLabel, labelMoveTweenInfo, labelMoveGoal):Play() -- Move entire label
    TweenService:Create(textLabel, labelFadeTweenInfo, labelFadeGoal):Play() -- Fadeing text and background
    TweenService:Create(interactLabelStroke, labelFadeTweenInfo, strokeFadeGoal):Play() -- Fading stroke
    TweenService:Create(interactLabel, labelEnlargeTweenInfo, labelEnlargeGoal):Play() -- Enlarging the textlabel

    coroutine.wrap(function()
        task.wait(MOVE_DUR) -- Wait until the animation is over

        local counter = 0
        local run:RBXScriptConnection
        run = RunService.PreRender:Connect(function(deltaTime)
            if interactLabel.Enabled == false then
                counter = 0
                interactLabel.StudsOffset = ogPos
                run:Disconnect()
                coroutine.yield()
            end

            if counter >= BOBBING_FREQUENCY then
                counter -= BOBBING_FREQUENCY
            end

            interactLabel.StudsOffset += Vector3.new(0, BOBBING_AMPLITUDE * math.sin(2*pi * (counter/BOBBING_FREQUENCY)), 0)
            counter += deltaTime
        end)
    end)()
end

return shared