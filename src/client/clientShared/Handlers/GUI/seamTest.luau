-- [Services]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- [Packages]
local seam = require(ReplicatedStorage.Packages.Seam)

-- [General Variables] -------------------------------------------------------------------------
local seamTest = {}

-- Player related
local plr       = Players.LocalPlayer
local plrGUI    = plr.PlayerGui

-- Seam related
local Rendered  = seam.Rendered
local Spring    = seam.Spring
local New       = seam.New
------------------------------------------------------------------------------------------------
--[[
-- Creating GUI
local Gui = New("ScreenGui",{
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    Parent = plrGUI
})

-- Let's make the rendered instance
local MousePositionRender = Rendered(function()
	local MouseLocation = UserInputService:GetMouseLocation() -- Get mouse position as Vector2
	local TargetPosition = UDim2.fromOffset(MouseLocation.X, MouseLocation.Y) -- Convert it to UI position

	return TargetPosition -- Return the UI position
end)

local MousePositionSpring = Spring(MousePositionRender, 5, 0.5) -- Making our spring

local ChasingSquare = New("Frame", {
    Size = UDim2.fromOffset(50, 50),
    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = Gui,

    Position = MousePositionSpring
})
]]
return seamTest