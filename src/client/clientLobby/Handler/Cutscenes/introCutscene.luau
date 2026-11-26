--Default walkspeed = 16, JumpHeight = 7.2

-- [Services]
local Players = game:GetService("Players")
local TweenSevice = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- [Modules]
local handlerFolder = script.Parent.Parent
local modulesFolder = script.Parent.Parent.Parent.Modules
local tweenDataMod = require(modulesFolder.TweenData)

-- [General Variables] ----------------------------------------------------------------------------------------
local lcl = {}
local shared = {}

--Player related
local plr = Players.LocalPlayer
local chara = plr.Character or plr.CharacterAdded:Wait()
local Humanoid = chara:FindFirstChild("Humanoid")

--Parts and models
local castle = game.Workspace:WaitForChild("Castle")
local gate = castle.Wall.door

--Camera
local cam = game.Workspace.CurrentCamera
local StartPos = castle.CutscenePositions:WaitForChild("StartPos")
local EndPos = castle.CutscenePositions:WaitForChild("EndPos")
local playerPos = castle.CutscenePositions:WaitForChild("PlayerPos")
local pos1 = castle.CutscenePositions:WaitForChild("pos1")
local pos2 = castle.CutscenePositions:WaitForChild("pos2")

-- GUI
local playerGui = plr.PlayerGui
local blackscreen = playerGui.BlackScreen.BlackScreen

-- tween
local tweenInfo = tweenDataMod.tweenInfo
local tweenGoal = tweenDataMod.goal
local firstCutsceneCamTween = TweenSevice:Create(cam, tweenInfo.CamStartToFinish, tweenGoal.CamStartToFinish)
local firstCutsceneBlackscreenTween = TweenSevice:Create(blackscreen, tweenInfo.BlackScreen, tweenGoal.BlackScreen)
----------------------------------------------------------------------------------------------------------------

-- [Changable Variables] ---------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------

function shared:SetUp()
	if Humanoid and cam and StartPos and EndPos then
		--Diabling player movement
		Humanoid.WalkSpeed = 0
		Humanoid.JumpHeight = 0
		
		--Teleport Player character onto playerPos
		chara.HumanoidRootPart.CFrame = playerPos.CFrame
		
		--Camera setup
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = StartPos.CFrame

		--Blackscreen setup
		blackscreen.BackgroundTransparency = 0
		blackscreen.Visible = true
	end
end

function shared:StartScene()
	firstCutsceneBlackscreenTween:Play() -- Fades the black screen into view
	firstCutsceneCamTween:Play() -- Moves the game to the end position
	task.wait(10)
end

function shared:EndScene()
	blackscreen.Visible = false
	blackscreen.BackgroundTransparency = 1
end

--Cutscene after player presses the start button
function shared:cutsceneOpenGates()
	--Create a tween that moves the gate up
	gate.Union.Gate:Play()
	task.wait(0.2)
	TweenSevice:Create(gate.Union, tweenInfo.gate, tweenGoal.gateGoal1):Play()
	
	TweenSevice:Create(cam, tweenInfo.gateCam, tweenGoal.camGateGoal1):Play()
	task.wait(1.9)
	TweenSevice:Create(cam, tweenInfo.gateCam, tweenGoal.camGateGoal2):Play()
end

function shared:skipCutscene()
	firstCutsceneCamTween:Cancel()
	firstCutsceneBlackscreenTween:Cancel()

	blackscreen.BackgroundTransparency = 1
	cam.CFrame = EndPos.CFrame
	SoundService["01 Prelude"].TimePosition = 19
end

return shared