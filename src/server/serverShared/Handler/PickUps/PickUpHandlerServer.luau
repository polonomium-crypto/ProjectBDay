local Workspace = game:GetService("Workspace")
--[[
NOTE:
 - The "pickUp" is referring to the item/loot the player is able to pick up.
 - For now I am using Proximity Prompts, but in the future I would be adding custom proximity prompts.
 - Make sure the model has a primary part otherwise this would not work.
]]

-- [Services]

-- [Modules]
local modFolder = script.Parent.Parent.Parent.Modules
local ItemDataBase = require(modFolder.ItemDataBase)

-- [Other scripts]

-- [Changable variables] ------------------------------------------------------------------------
local pickUpHandler = {}
local lcl = {}
-------------------------------------------------------------------------------------------------

-- Creates a new PickUp object
function pickUpHandler.createNew(name:string, parent:Instance?, position:CFrame?)
    local pickUp
    local defaultPos = CFrame.new(0,0,0)

    if not ItemDataBase[name] then
        warn("Could not find pickUp: ", name)
        return false
    end

    pickUp = ItemDataBase[name]()
    pickUp:positionTo(position or defaultPos)

    return pickUp
end

return pickUpHandler