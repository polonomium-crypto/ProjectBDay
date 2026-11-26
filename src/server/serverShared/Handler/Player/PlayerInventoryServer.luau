--[[
 - 
]]

-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

-- [Modules]

-- [Changable variables] ------------------------------------------------------------------------
local plrInventoryServer = {}
local plrInventoryData = {}

-- Event
local eventFolder       = ReplicatedStorage.Events
local UsePickUpsEvent   = eventFolder.UsePickUpsEvent
local inventoryEvent    = eventFolder.InventoryEvent    -- Called whenever the backpack is altered
local removeEvent       = "RemoveEvent"
local dropEvent         = "DropEvent"
local equipEvent        = "EquipEvent"
local toolActivation    = "ToolActivation"

local numberOfInventorySlots = 5
-------------------------------------------------------------------------------------------------

function plrInventoryServer.init()
    -- Capture the event thrown by the player to equip and unequip items
    inventoryEvent.OnServerEvent:Connect(plrInventoryServer.eventCapturer)

    UsePickUpsEvent.OnServerEvent:Connect(plrInventoryServer.useItemFunc)
end

function plrInventoryServer.eventCapturer(plr:Player, eventName:string, params)
    if      eventName == dropEvent then
        plrInventoryServer.dropItemFromInventory(params, plr)
    elseif  eventName == removeEvent then
        plrInventoryServer.removeItemFrom(params, plr)
    elseif  eventName == equipEvent then
        plrInventoryServer.equipHandler(params, plr)
    elseif  eventName == toolActivation then
        plrInventoryServer.toolActivation(params)
    end
end

function plrInventoryServer.useItemFunc(plr)
    local equippedSlot = plrInventoryData[plr.UserId]["CurrentlyEquipped"]
    local CurrentlyEquipped = plrInventoryData[plr.UserId]["Inventory"][equippedSlot]

    -- Checking if components exists
    if not CurrentlyEquipped.components then
        return
    end

    -- Checking if the player is even capable of using the item. Check if the player has the item and have enough battery.

    -- Runs server side component if there is one
    plrInventoryServer.manageComponents("Activate", plr, CurrentlyEquipped)
end

-- Creating a folder for inventory management
function plrInventoryServer.initialize(plr:Player)
    -- Giving the player their own inventory
    local inventory
    inventory = Instance.new("Folder")
    inventory.Name = "Inventory"
    inventory.Parent = plr

    plrInventoryData[plr.UserId] = {}
    plrInventoryData[plr.UserId]["Inventory"] = {}
    plrInventoryData[plr.UserId]["CurrentlyEquipped"] = -1
end

function plrInventoryServer.pickUp(item:table, plr:Player)
    local plrInventory = plr.Backpack--plr:FindFirstChild("Inventory")
    local numOfSlots = #plrInventoryData[plr.UserId]["Inventory"] + 1

    if plrInventory then
        -- Making sure the player does not have over the limit
        if numOfSlots > numberOfInventorySlots then
            warn("Player can't carry more than this.")
            return false
        end

        -- Adding the data of the item into player inventory data table
        plrInventoryData[plr.UserId]["Inventory"][numOfSlots] = item

        print(plrInventoryData)

        -- Sending the inventroy data to the player to handle UI and controls
        inventoryEvent:FireClient(plr,"updateInventory", plrInventoryData[plr.UserId])
        --inventoryEvent:FireClient(plr, clientSideInvData[plr.UserId])

        return true
    else
        return false
    end
end

function plrInventoryServer.removeEquipped(plr:Player)
    -- Checking if the player has a inventory
    if not plrInventoryData[plr.UserId]["Inventory"] then
        warn("Player does not have an inventory.")
        return
    end

    -- Checking if the player has that specific slot
    if plrInventoryData[plr.UserId]["CurrentlyEquipped"] == -1 then
        warn("Player does not have anything equipped!")
        return
    end

    local equippedSlot = plrInventoryData[plr.UserId]["CurrentlyEquipped"]
    plrInventoryServer.manageComponents("Drop", plr, plrInventoryData[plr.UserId]["Inventory"][equippedSlot])
    plrInventoryData[plr.UserId]["CurrentlyEquipped"] = -1

    table.remove(plrInventoryData[plr.UserId]["Inventory"], equippedSlot)
    inventoryEvent:FireClient(plr,"removeEquipped",  plrInventoryData[plr.UserId])
end

function plrInventoryServer.dropItemFromInventory(slotNum:IntValue, plr:Player)
    -- Checking if the player has a inventory
    if not plrInventoryData[plr.UserId]["Inventory"] then
        warn("Player does not have an inventory.")
        return
    end

    -- Checking if the player has that specific slot
    if not plrInventoryData[plr.UserId]["Inventory"][slotNum] then
        warn("There is no item in this slot to drop")
        return
    end

    -- Removing item data from the table and removing it from players inventory UI
    if plrInventoryData[plr.UserId]["CurrentlyEquipped"] then
        local equippedSlot = plrInventoryData[plr.UserId]["CurrentlyEquipped"]
        -- Creating a new model and positioning it accordingly
        local chara = plr.Character or plr.CharacterAdded:Wait()
        local dropPosition = chara:FindFirstChild("HumanoidRootPart").CFrame
        plrInventoryData[plr.UserId]["Inventory"][equippedSlot]:createModel()
        plrInventoryData[plr.UserId]["Inventory"][equippedSlot]:positionTo(dropPosition)

        -- Handling drop function
        plrInventoryServer.manageComponents("Drop", plr, plrInventoryData[plr.UserId]["Inventory"][equippedSlot])

        plrInventoryData[plr.UserId]["CurrentlyEquipped"] = -1
    end
    table.remove(plrInventoryData[plr.UserId]["Inventory"], slotNum)
    inventoryEvent:FireClient(plr,"updateInventory",  plrInventoryData[plr.UserId])
end

-- Handles equiping items. Specify slot of inventory and player u want to handle the inventory.
function plrInventoryServer.equipHandler(slotNum:IntValue, plr:Player)
    local plrChara = plr.Character or plr.CharacterAdded:Wait()
    local equippedSlot = plrInventoryData[plr.UserId]["CurrentlyEquipped"]
    local item

    if plr.Inventory and plrChara then
        -- Check if there is a "OnUnequip" component function
        if equippedSlot ~= -1 then
            plrInventoryServer.manageComponents("Unequip", plr, plrInventoryData[plr.UserId]["Inventory"][equippedSlot])
        end

        -- If (slotNum = -1) aka no items equipped
        if slotNum == -1 then
            plrInventoryData[plr.UserId]["CurrentlyEquipped"] = -1
            return
        end

        -- Insert it into the inventory equipped data
        plrInventoryData[plr.UserId]["CurrentlyEquipped"] = slotNum
        equippedSlot = plrInventoryData[plr.UserId]["CurrentlyEquipped"]

        -- Check if there is a "OnEquip" component function
        plrInventoryServer.manageComponents("Equip", plr,  plrInventoryData[plr.UserId]["Inventory"][equippedSlot])
    end
end

function plrInventoryServer.manageComponents(state:string, plr:Player, obj:table)
    local stateFunc
    if state == "Activate" then
        if obj.components.OnActivate then
            stateFunc = obj.components.OnActivate
            stateFunc(plr, obj)
        end
    elseif state == "Equip" then
        if obj.components.OnEquip then
            stateFunc = obj.components.OnEquip
            stateFunc(plr, obj)
        end
    elseif state == "Unequip" then
        if obj.components.OnUnequip then
            stateFunc = obj.components.OnUnequip
            stateFunc(plr, obj)
        end
    elseif state == "Drop" then
        if obj.components.OnDrop then
            stateFunc = obj.components.OnDrop
            stateFunc(plr, obj)
        end
    end
end

function plrInventoryServer.getPlrEquipped(plr:Player)
    if plrInventoryData[plr.UserId]["CurrentlyEquipped"] then
        local equippedSlot = plrInventoryData[plr.UserId]["CurrentlyEquipped"]
        return plrInventoryData[plr.UserId]["Inventory"][equippedSlot]
    end
end

return plrInventoryServer