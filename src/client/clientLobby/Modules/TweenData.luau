-- [General Variables] ----------------------------------------------------------------------------------------
local castle = game.Workspace:WaitForChild("Castle")
local gate = castle.Wall.door

local EndPos = castle.CutscenePositions:WaitForChild("EndPos")
local pos1 = castle.CutscenePositions:WaitForChild("pos1")
local pos2 = castle.CutscenePositions:WaitForChild("pos2")
---------------------------------------------------------------------------------------------------------------
local tweenData = {

    tweenInfo = {
        startCredit = TweenInfo.new(
            2,
            Enum.EasingStyle.Linear
        ),

        CamStartToFinish = TweenInfo.new(
            20,
            Enum.EasingStyle.Exponential,
            Enum.EasingDirection.Out
        ),

        BlackScreen = TweenInfo.new(
            30,
            Enum.EasingStyle.Exponential,
            Enum.EasingDirection.Out,
            0,
            false,
            0
        ),

        gateCam = TweenInfo.new(
            2,
            Enum.EasingStyle.Exponential,
            Enum.EasingDirection.In
        ),

        gate = TweenInfo.new(
            4,
            Enum.EasingStyle.Exponential,
            Enum.EasingDirection.InOut
        )
    },

    goal = {
        CamStartToFinish = {CFrame = EndPos.CFrame}, --Name to keys equal to the property u want to change
        BlackScreen = {BackgroundTransparency = 1},
        camGateGoal1 = {CFrame = pos1.CFrame},
        camGateGoal2 = {CFrame = pos2.CFrame},
        gateGoal1 = {CFrame = gate.Union.CFrame * CFrame.new(0,20,0)}
    }
}

return tweenData