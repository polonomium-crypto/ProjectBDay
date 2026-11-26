-- [Services]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [Modules]
local handlerFolder = script.Parent.Parent
local moduleClientFolder = script.Parent.Parent.Parent.Modules
local moduleSharedFolder = ReplicatedStorage.RSShared.Modules
local tweenMod = require(moduleSharedFolder.TweenModule)

-- [General Variables] ----------------------------------------------------------------------------------------
local lcl = {}
local shared = {}

-- player related
local player = Players.LocalPlayer
local playerGUI = player.PlayerGui

--UI
local StartMenu = playerGUI:WaitForChild("StartMenu")
local blackScreen = StartMenu.Parent.BlackScreen.BlackScreen
---------------------------------------------------------------------------------------------------------------

function shared:teleportingPlayer()
	--After blackscreen, teleport player to the starting area
	local starterRoomSpawn = workspace.StartingRoom.StarterRoomSpawn
	local plr: Player = Players.LocalPlayer
	local Character = plr.Character or plr.CharacterAdded:Wait()
	local HRP: BasePart = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")

	--HRP.Position = starterRoomSpawn.Position + Vector3.new(0,3,0)
	
	--Clean up
	local cam = workspace.CurrentCamera
	
	cam.CameraType = Enum.CameraType.Custom
	tweenMod.FadeFrame(blackScreen, 2, false)
	
	--Enabling player movement
	Humanoid.WalkSpeed = 16
	Humanoid.JumpHeight = 7.2
end

return shared