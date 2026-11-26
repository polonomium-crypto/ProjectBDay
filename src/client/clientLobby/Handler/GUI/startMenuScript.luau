-- [Services]
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

-- [Modules]
local modulesFolder = ReplicatedStorage.RSShared.Modules
local moduleClientFolder = script.Parent.Parent.Parent.Modules
local handlerFolder = script.Parent.Parent
local introCutscene = require(handlerFolder.CutScenes.introCutscene)
local tweenDataMod = require(moduleClientFolder.TweenData)
local tweenMod = require(modulesFolder.TweenModule)
local teleportMod = require(handlerFolder.Player.TeleportHandler)

-- [General Variables] ----------------------------------------------------------------------------------------
local lcl = {}
local shared = {}

-- player related
local player = Players.LocalPlayer
local playerGUI = player.PlayerGui

--UI
local StartMenu = playerGUI:WaitForChild("StartMenu")
local Title = StartMenu.Title
local StartButton = StartMenu.StartButton
local credit = StartMenu.Credit
local blackScreen = StartMenu.Parent.BlackScreen.BlackScreen
local SkipButton = StartMenu.SkipButton

-- Debounce
local startDb = true

-- Tween
local tweenInfo = tweenDataMod.tweenInfo
local tweenGoal = tweenDataMod.goal
 ---------------------------------------------------------------------------------------------------------------
-- [Changable Variables] ---------------------------------------------------------------------------------------
local DoMenu = false -- for ease of debugging
---------------------------------------------------------------------------------------------------------------

function lcl:main()
	if DoMenu then
		Lighting.ClockTime = 3.2 -- Set the mood (Making it nighttime)

		introCutscene:SetUp()
		lcl:startingCredit()
		introCutscene:StartScene()
		introCutscene:EndScene()
		lcl:startMenuGui()
	end
end

-- starts the starting credits
function lcl:startingCredit()
	--SkipButton visible
	SkipButton.Visible = true

	--Start music (While also having lights load in)
	if not SoundService["01 Prelude"].Playing then
		SoundService["01 Prelude"]:Play()
	end
	
	--Credit
	credit.Visible = true
	task.wait(2)
	TweenService:Create(credit, tweenInfo.startCredit, {TextTransparency = 0}):Play()
	task.wait(3)
	TweenService:Create(credit, tweenInfo.startCredit, {TextTransparency = 1}):Play()

	task.wait(3.3)
end

StartButton.MouseEnter:Connect(function()
	tweenMod.EnterButton(StartButton)
end)

StartButton.MouseLeave:Connect(function()
	tweenMod.LeaveButton(StartButton)
end)

--StartButton clicked
StartButton.MouseButton1Click:Connect(function()
	if startDb then
		startDb = false

		task.spawn(function()
			introCutscene:cutsceneOpenGates()
		end)
		
		StartMenu.start:Play()
		SoundService["01 Prelude"]:Stop()
		
		tweenMod.FadeText(Title, 2, false)
		--task.wait(0.6)
		tweenMod.FadeText(StartButton, 2, false)
		task.wait(2.1)
		tweenMod.FadeFrame(blackScreen, 2, true)
		
		task.wait(2.1)
		
		--Preparing the game
		teleportMod:teleportingPlayer()
		startDb = true
	end
end)

--SkipButton
SkipButton.MouseButton1Click:Connect(function()
	SkipButton.Visible = false
	credit.Visible = false
	introCutscene:skipCutscene()
	lcl:startMenuGui()
end)

--After Cutscene is over
function lcl:startMenuGui()
	SkipButton.Visible = false

	tweenMod.FadeText(Title, 2, true)
	task.wait(0.6)
	tweenMod.FadeText(StartButton, 2, true)
end

-- player joined
for _,_ in Players:GetChildren() do lcl:main() end -- for ealy birds
Players.PlayerAdded:Connect(function()
	lcl:main()
end)

return shared