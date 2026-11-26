-- [Services]
local ContextActionService = game:GetService("ContextActionService")
local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- [Other scripts]
local plrVM = require(script.Parent.PlayerViewModelClient)

-- [Moduels]
local moduleFolder = script.Parent.Parent.Parent.Modules
local localComponentsFolder = moduleFolder.ClientComponents

-- [General Variables] --------------------------------------------------
local lclPlrInventory   = {}

-- Player related
local plr               = players.LocalPlayer
local chara = plr.Character or plr.CharacterAdded:Wait()
local plrGui            = plr.PlayerGui
local inventory:Folder  = plr:WaitForChild("Inventory")

-- Event
local eventFolder       = ReplicatedStorage.Events
local inventoryEvent    = eventFolder.InventoryEvent
local UsePickUpsEvent   = eventFolder.UsePickUpsEvent

-- Inventory
local itemTable         = {}
local equippedSlotNum   = -1

-- GUI stuff
local hud               = plrGui.Hud
local inventoryGui      = hud.Inventory
local templateFolder    = hud.Template
local itemSlotTemp      = templateFolder.InventoryTemp.ItemFrame

-- Tween
local slotDefaultSize   = {Size = UDim2.fromScale(1,1)}
local equippedTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
local equippedTweenGoal = {Size = itemSlotTemp.Size + UDim2.fromScale(0.2,0.2)}
-------------------------------------------------------------------------
function lclPlrInventory.init()
    inventoryEvent.OnClientEvent:Connect(lclPlrInventory.eventHandler)
end

function lclPlrInventory.eventHandler(eventPurpose:string, data:table)
    if eventPurpose == "updateInventory" then
        lclPlrInventory.updateInventory(data)
    elseif eventPurpose == "removeEquipped" then
        lclPlrInventory.removeEquipped(data)
    end
end

-- Inventory UI is updated using this function
function lclPlrInventory.updateInventory(tableOfItems:table)
    lclPlrInventory.clearInventoryUI()         -- Clear all UI slots so that updates approprately

    -- Copying data to client
    itemTable = tableOfItems
    equippedSlotNum = itemTable["CurrentlyEquipped"]

    for i, itemInfo in tableOfItems.Inventory do
        local slot
        local slotImgLabel:ImageLabel

        -- Creating a clone for the updated inventory
        slot = itemSlotTemp:Clone()
        slot.Parent = inventoryGui
        slot.Name = i
        slotImgLabel = slot.img

        if equippedSlotNum ~= -1 then
            lclPlrInventory.equippedSlotEffect()
        end

        -- Changing the image of the inventory slot
        slotImgLabel.Image = itemInfo.ItemImage

        -- Retrieving local component
        lclPlrInventory.retrieveLocalComponent(i)

        slot.Visible = true
    end

    print(itemTable)
end

function lclPlrInventory.removeEquipped(data)
    if equippedSlotNum == -1 then
        return
    end

    -- Initating drop function if it has one
    print(equippedSlotNum, itemTable["Inventory"])
    lclPlrInventory.manageLclComponent("Drop", itemTable["Inventory"][equippedSlotNum])

    -- Updating inventory
    lclPlrInventory.updateInventory(data)

    -- Removing it from the item table
    table.remove(itemTable["Inventory"], equippedSlotNum)

    -- Removing the viewmodel from the player
    plrVM.removeVM()

    -- Unbind item input
    ContextActionService:UnbindAction("ItemInput")

    equippedSlotNum = -1    -- Changing this because the player would not be holding on to nothing.
end

-- Retrieving local component
function lclPlrInventory.retrieveLocalComponent(slotNum)
    -- First find if the component exists
    local componenList
    if itemTable["Inventory"][slotNum].localComponentName then
        componenList = itemTable["Inventory"][slotNum].localComponentName
    else
        return
    end

    local component
    itemTable["Inventory"][slotNum].localComponent = {}
    for _, componentName in componenList do
        component = localComponentsFolder:FindFirstChild(componentName)

        if component then
            itemTable["Inventory"][slotNum].localComponent[componentName] = require(component)
        end
    end
    print(itemTable["Inventory"])
end

-- Equips and unequips the items
function lclPlrInventory.equipFlipFlop(slotNum:IntValue)
    -- Making sure the player has the inventory data
    if not itemTable["Inventory"] then
        return
    end

    -- Making sure the player has item in the slot num
    if not itemTable["Inventory"][slotNum] then
        warn("There is no item in this item slot")
        return
    end

    -- Executing unequip function
    if equippedSlotNum ~= -1 then
        lclPlrInventory.manageLclComponent("Unequip", itemTable["Inventory"][equippedSlotNum])
    end

    -- Unselecting the item if input is the same as currently equipped slot number.
    if equippedSlotNum == slotNum then  -- When the equipping same slot Unequip
        equippedSlotNum = -1
    else                                -- When the equipping different slot
        equippedSlotNum = slotNum
    end

    -- UI reacting to equipping
    lclPlrInventory.equippedSlotEffect()

    -- Handle viewmodel, input function, and component function
    if equippedSlotNum == -1 then
        plrVM.removeVM()                                                                -- Removing ViewModel
        ContextActionService:UnbindAction("ItemInput")                                  -- Unbinde controls
    else
        plrVM.handleViewModel(itemTable["Inventory"][slotNum].ViewModel)                                                    -- Adding view model
        ContextActionService:BindAction("ItemInput", lclPlrInventory.managePUInput, false, Enum.UserInputType.MouseButton1) -- Bind controls
        lclPlrInventory.manageLclComponent("Equip", itemTable["Inventory"][equippedSlotNum])                                -- Executing equip function
    end

    -- Handle things on the server side
    inventoryEvent:FireServer("EquipEvent",equippedSlotNum)
end

-- Adds an animation to the slot the player equips
function lclPlrInventory.equippedSlotEffect()
    for _, slot:GuiObject in inventoryGui:GetChildren() do
        if slot:IsA("Frame") then
            if slot.Name == tostring(equippedSlotNum) then
                TweenService:Create(slot, equippedTweenInfo, equippedTweenGoal):Play()
            else
                TweenService:Create(slot, equippedTweenInfo, slotDefaultSize):Play()
            end
        end
    end
end

-- Drop equipped item
function lclPlrInventory.dropItem()
    if equippedSlotNum == -1 then
        return
    end

    -- Initating drop function if it has one
    lclPlrInventory.manageLclComponent("Drop", itemTable["Inventory"][equippedSlotNum])

    -- Removing it from the item table
    table.remove(itemTable["Inventory"], equippedSlotNum)

    -- Removing the viewmodel from the player
    plrVM.removeVM()

    -- Unbind item input
    ContextActionService:UnbindAction("ItemInput")

    inventoryEvent:FireServer("DropEvent", equippedSlotNum)     -- Asking the server to drop the item
    equippedSlotNum = -1    -- Changing this because the player would not be holding on to nothing.
end

function lclPlrInventory.clearInventoryUI()
    for _, v:GuiObject in inventoryGui:GetChildren() do
        if not v:IsA("UIListLayout") then
            v:Destroy()
        end
    end
end

function lclPlrInventory.managePUInput(actionName, inputState, _inputObject)
    if actionName == "ItemInput" then
        if inputState == Enum.UserInputState.Begin and _inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Calling function that has to be dealt locally
            if itemTable["Inventory"][equippedSlotNum].localComponent then
                lclPlrInventory.manageLclComponent("Activate", itemTable["Inventory"][equippedSlotNum])
            end

            -- Sending an event to the server to handle server side
            UsePickUpsEvent:FireServer()
        end
    end
end

function lclPlrInventory.manageLclComponent(state:string, obj:table)
    local stateFunc
    if state == "Activate" then
        for _, component in obj.localComponent do
            if component.OnActivate then
                stateFunc = component.OnActivate
                stateFunc(obj)
            end
        end
    elseif state == "Equip" then
        for _, component in obj.localComponent do
            if component.OnEquip then
                stateFunc = component.OnEquip
                stateFunc(obj)
            end
        end
    elseif state == "Unequip" then
        for _, component in obj.localComponent do
            if component.OnUnequip then
                stateFunc = component.OnUnequip
                stateFunc(obj)
            end
        end
    elseif state == "Drop" then
        for _, component in obj.localComponent do
            if component.OnDrop then
                stateFunc = component.OnDrop
                stateFunc(obj)
            end
        end
    end
end

return lclPlrInventory