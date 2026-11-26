-- [Services]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- [Modules]
local dialogMod = require(script.Parent.Dialog)

-- [General variables] --------------------------------------------------------------------------
-- Player
local plr = Players.LocalPlayer

-- UI
local playerGui = plr.PlayerGui
local dialogFolder = playerGui.Dialogue
local blackscreens = dialogFolder.BlackScreens
local nameFrame = dialogFolder.NameFrame
local top = blackscreens.Top
local topRight = blackscreens.TopRight
local topLeft = blackscreens.TopLeft
local bottomLeft = blackscreens.BottomLeft
local bottomRight = blackscreens.BottomRight

-- Original positions
local ogPos = nameFrame.Position
local topOgPos = top.Position
local topRightOgPos = topRight.Position
local topLeftOgPos = topLeft.Position
local bottomLeftOgPos = bottomLeft.Position
local bottomRightOgPos = bottomRight.Position
-------------------------------------------------------------------------------------------------
-- [Changable variables] ------------------------------------------------------------------------
local lcl = {}
local shared = {}

-- Blackscreen var
local BS_MOVE_DUR = 0.2
local BS_PAUSE_DUR = 0.07
local BOTTOM_LEFT_OFFSCREEN_POS = UDim2.fromScale(-1.6, 0)
local BOTTOM_RIGHT_OFFSCREEN_POS = UDim2.fromScale(2, 1)
local TOP_RIGHT_OFFSCREEN_POS = UDim2.fromScale(1.3, -0.3)
local TOP_OFFSCREEN_POS = UDim2.fromScale(0.5, -1)
local TOP_LEFT_OFFSCREEN_POS = UDim2.fromScale(-0.042, -0.3)

-- Name tween var
local NAME_MOVE_DUR = 0.8
local NAME_FRAME_MOVE_DIST = -1
-------------------------------------------------------------------------------------------------

function shared.moveBlackScreens()
    -- Init
    bottomLeft.Position = BOTTOM_LEFT_OFFSCREEN_POS
    bottomRight.Position = BOTTOM_RIGHT_OFFSCREEN_POS
    topRight.Position = TOP_RIGHT_OFFSCREEN_POS
    top.Position = TOP_OFFSCREEN_POS
    topLeft.Position = TOP_LEFT_OFFSCREEN_POS

    bottomLeft.Visible = true
    bottomRight.Visible = true
    topRight.Visible = true
    top.Visible = true
    topLeft.Visible = true

    task.spawn(function()
        TweenService:Create(bottomRight, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = bottomRightOgPos}):Play()
        task.wait(BS_PAUSE_DUR)
        TweenService:Create(bottomLeft, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = bottomLeftOgPos}):Play()
        task.wait(BS_PAUSE_DUR)
        TweenService:Create(topRight, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = topRightOgPos}):Play()
        task.wait(BS_PAUSE_DUR)
        TweenService:Create(topLeft, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = topLeftOgPos}):Play()
        task.wait(BS_PAUSE_DUR)
        TweenService:Create(top, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = topOgPos}):Play()
    end)
end

function shared.removeBlackScreens()
    task.spawn(function()
        TweenService:Create(bottomRight, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = BOTTOM_RIGHT_OFFSCREEN_POS}):Play()
        task.wait(BS_PAUSE_DUR)
        TweenService:Create(bottomLeft, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = BOTTOM_LEFT_OFFSCREEN_POS}):Play()
        task.wait(BS_PAUSE_DUR)
        TweenService:Create(topRight, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = TOP_RIGHT_OFFSCREEN_POS}):Play()
        task.wait(BS_PAUSE_DUR)
        TweenService:Create(topLeft, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = TOP_LEFT_OFFSCREEN_POS}):Play()
        task.wait(BS_PAUSE_DUR)
        TweenService:Create(top, TweenInfo.new(BS_MOVE_DUR,Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Position = TOP_OFFSCREEN_POS}):Play()
        task.wait(BS_PAUSE_DUR)

        bottomLeft.Visible = false
        bottomRight.Visible = false
        topRight.Visible = false
        top.Visible = false
        topLeft.Visible = false
    end)
end

function shared.printName(nameInfo:string, targetNPCName:string)
    -- Tween 
    local moveTweenInfo = TweenInfo.new(NAME_MOVE_DUR, Enum.EasingStyle.Cubic)
    local moveGoal = {Position = ogPos}

    -- Init
    nameFrame.Position = UDim2.fromScale(NAME_FRAME_MOVE_DIST, ogPos.Y.Scale)

    -- Start
    TweenService:Create(nameFrame, moveTweenInfo, moveGoal):Play()
    local parsedName = dialogMod:parseDialog(nameInfo)
    dialogMod:main(parsedName, targetNPCName, nameFrame, true)
end

function shared.removeName()
    -- Tween 
    local moveTweenInfo = TweenInfo.new(NAME_MOVE_DUR, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
    local moveGoal = {Position = UDim2.fromScale(NAME_FRAME_MOVE_DIST, ogPos.Y.Scale)}

    -- Init
    nameFrame.Position = ogPos

    -- Start
    local tween = TweenService:Create(nameFrame, moveTweenInfo, moveGoal)
    tween:Play()
    tween.Completed:Wait()

    nameFrame:ClearAllChildren()
end

return shared