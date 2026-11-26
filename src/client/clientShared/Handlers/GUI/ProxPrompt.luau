-- [Services]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [Modules]
local Packages = ReplicatedStorage.Packages
local ExpressivePrompts = require(Packages.ExpressivePrompts)

-- [General Variables] ------------------------------------------------------
local pp = {}

-- Player related
local plr = Players.LocalPlayer
local PlayerGui = plr.PlayerGui

-- UI related
local ppUI
-----------------------------------------------------------------------------

function pp.init()
    --ExpressivePrompts.Config.PromptHeight = 100 -- In pixels
    --ExpressivePrompts.Config.PromptWidth = 200
    ExpressivePrompts.Init()
end

return pp