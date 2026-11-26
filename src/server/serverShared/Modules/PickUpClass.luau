--[[
NOTE:
 - The "pickUp" is referring to the item/loot the player is able to pick up.
 - For now I am using Proximity Prompts, but in the future I would be adding custom proximity prompts.
 - Make sure the model has a primary part otherwise this would not work.
]]

-- [Services]
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- [Modules]

-- [Other scripts]
local plrInventoryServer = require(script.Parent.Parent.Handler.Player.PlayerInventoryServer)

-- [Changable variables] ------------------------------------------------------------------------
local pickUpClass = {}
pickUpClass.__index = pickUpClass

-- Folders
local activePickUpsFolder = Workspace.Dungeon.ActivePickUps

-- Templates
local pickUpsFolder =  ServerStorage.PickUps
local toolTemplate = pickUpsFolder.ToolTemplate

-- Changables
local HOLDDUR = 0.6
local PPYOFFSET = 100         -- Proximity prompt y offset
local DROPDIST = 0.1
-------------------------------------------------------------------------------------------------

-- Creates a new PickUp object
function pickUpClass.new(data:table)
    local self = setmetatable({}, pickUpClass)

    self.ID = HttpService:GenerateGUID()
    for i, v in data do
        self[i] = v
    end

    return self
end

-- Component that would run on the server side
function pickUpClass:addComponent(component:table)
    self.components = component
end

-- Component that would run on the client side
function pickUpClass:addLocalComponent(component:table)
    self.localComponent = component
end

function pickUpClass:changeParent(parent)
    if self.itemModel.Parent and parent then
        self.itemModel.Parent = parent
    end
end

function pickUpClass:positionTo(CF:CFrame)
    local item:Model = self.itemModel
    if item then
        item:PivotTo(CF)
    end
end

function pickUpClass:createModel()
    self.itemModel = self.ItemRef:Clone()
    self.itemModel.Parent = activePickUpsFolder

    -- Setting collision group
    for _, v:BasePart in self.itemModel:GetDescendants() do
        if v:IsA("BasePart") then
            v.CollisionGroup = "PickUps"
        end
    end

    self:giveProxPrompt()
end

-- This is temporary solution. Making sure the item is pick up able.
function pickUpClass:giveProxPrompt()
    local successful
    local proxPrompt = Instance.new("ProximityPrompt")
    proxPrompt.Parent = self.itemModel.PrimaryPart
    proxPrompt.HoldDuration = HOLDDUR
    proxPrompt.UIOffset = Vector2.new(0, PPYOFFSET)
    proxPrompt.ActionText = "Pick Up"

    proxPrompt.Triggered:Connect(function(playerWhoTriggered)
        local plrBackpack = playerWhoTriggered.Backpack

        -- Adding item data into the players inventory
        successful = plrInventoryServer.pickUp(self, playerWhoTriggered)
        proxPrompt.Enabled = not successful

        if successful and plrBackpack and self.itemModel then
            -- Destroys item model when item is picked up
            self.itemModel:Destroy()
        end
    end)
end



return pickUpClass