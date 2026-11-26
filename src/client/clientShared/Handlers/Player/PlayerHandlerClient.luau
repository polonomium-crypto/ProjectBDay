-- Client script

-- [Services]
local ContextActionService = game:GetService("ContextActionService")
local PhysicsService = game:GetService("PhysicsService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

-- [Modules]
local Modules = script.Parent.Parent.Parent.Modules
local plrCamMod = require(Modules.Player.PlayerCamHandler)

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local pH = {} -- pH = PlayerHandler

-- Player
local plr = Players.LocalPlayer
local chara = plr.Character or plr.CharacterAdded:Wait()
local primaryPart = chara.PrimaryPart
local humanoid = chara.Humanoid

-- Cam
local cam = workspace.CurrentCamera

-- Mouse
local mouse = plr:GetMouse()
-------------------------------------------------------------------------------------------------
-- [Changable variables] --------------------------------------------------------------------------
-- Player variables

-- Mouse Default
local DEFAULT_MOUSE_ICON = "rbxassetid://9947313248"
-------------------------------------------------------------------------------------------------

--[[
 - Create a class for the player.
 - Make sure some of the settings are easy to customize for the player. (e.g. Turning headbob off)
]]

-- [Initializing]
-- Making sure the player is in first person mode
function pH.init()
    -- Disabling default roblox Backpack
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

    -- Changing mouse decal
    mouse.Icon = DEFAULT_MOUSE_ICON

    -- Initialising and activating headbob
    plrCamMod:Initialize()
    plrCamMod:camStateManager()

end

return pH