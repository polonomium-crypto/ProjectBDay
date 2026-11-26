-- [Services]
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- [Modules]
local playerFolder = script.Parent
local playerInventory = require(playerFolder.PlayerInventoryServer)

-- [Changable variables] ------------------------------------------------------------------------
local playerHandler = {}
-------------------------------------------------------------------------------------------------

function playerHandler.init()
    -- Initializing player and pick up collisions
    playerHandler.collisionInit()

    for _, player in Players:GetChildren() do
        playerHandler.main(player)
    end

    Players.PlayerAdded:Connect(function(player)
        playerHandler.main(player)
    end)
end

function playerHandler.main(plr:Player)
    -- initialize player Inventory
    playerInventory.initialize(plr)

    -- Setting player collision group
    playerHandler.groupingPlayerParts(plr)
end

function playerHandler.collisionInit()
    PhysicsService:RegisterCollisionGroup("PickUps")
    PhysicsService:RegisterCollisionGroup("Players")

    PhysicsService:CollisionGroupSetCollidable("PickUps", "Players", false)
end

function playerHandler.groupingPlayerParts(plr:Player)
    local chara = plr.Character or plr.CharacterAdded:Wait()

    for _, v:BasePart in chara:GetChildren() do
        if v:IsA("BasePart") then
            v.CollisionGroup = "Players"
        end
    end
end

return playerHandler