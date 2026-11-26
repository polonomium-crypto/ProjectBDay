-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- [Modules]
local pickUpClass = require(script.Parent.PickUpClass)
local componentFolder = script.Parent.Components

-- [General Variabels] ---------------------------------------------------
local itemDataBase     = {}

-- Necessary Folders
local pickUpsFolder     = ServerStorage.PickUps
local itemsFolder       = pickUpsFolder.ItemModels
local lootFolder        = pickUpsFolder.LootModels
local viewModelFolder   = ReplicatedStorage.Viewmodels

--------------------------------------------------------------------------

itemDataBase.itemData = {
    ["Torch"] = {
        Name = "Torch",
        Rarity = nil,
        ItemRef = itemsFolder.Torch,
        ItemImage = "rbxassetid://105961633630873",
        ViewModel = viewModelFolder.TorchViewmodel,
        SFX = "rbxassetid://9120093158",
        localComponentName = {"LightComponentClient", "SoundComponentClient"},
        Battery = 100,
        BatteryCap = 100,
        Enabled = false,
        Attributes = {
            Brightness = 3,
            Range = 100
        }
    },
    ["Bear"] = {
        Name = "Bear",
        Rarity = 5,
        ItemRef = lootFolder.Bear,
        ItemImage = "rbxassetid://7396627787",
        ViewModel = viewModelFolder.BearViewmodel,
        SFX = "rbxassetid://134627487275898",
        localComponentName = {"SoundComponentClient"},
        Battery = nil
    },
    ["BeachBall"] = {
        Name = "BeachBall",
        Rarity = 70,
        ItemRef = lootFolder["BeachBall"],
        ItemImage = "rbxassetid://11288914742",
        ViewModel = viewModelFolder.BallViewmodel,
        SFX = "rbxassetid://8254243427",
        localComponentName = {"SoundComponentClient"},
        Battery = nil
    },
    ["Battery"] = {
        Name = "Battery",
        Rarity = 80,
        ItemRef = lootFolder.Battery,
        ItemImage = "rbxassetid://23077377",
        ViewModel = viewModelFolder.BatteryViewmodel,
        SFX = "rbxassetid://3473294581",
        localComponentName = {"SoundComponentClient"}
    },
    ["Duck"] = {
        Name = "Duck",
        Rarity = 85,
        ItemRef = lootFolder.Duck,
        ItemImage = "rbxassetid://5360342520",
        ViewModel = viewModelFolder.DuckViewmodel,
        Inputs = Enum.KeyCode.MouseLeftButton,
        SFX = "rbxassetid://96675207035727",
        localComponentName = {"SoundComponentClient"}
    },
    ["Rocket"] = {
        Name = "Rocket",
        Rarity = 3,
        ItemRef = lootFolder.Rocket,
        ItemImage = "rbxassetid://7237720170",
        ViewModel = viewModelFolder.RocketViewmodel,
        SFX = "rbxassetid://121276137899079",
        localComponentName = {"SoundComponentClient"}
    },
    ["Nokia"] = {
        Name = "Nokia",
        Rarity = 3,
        ItemRef = lootFolder.Nokia,
        ItemImage = "rbxassetid://9067800996",
        ViewModel = nil,
        SFX = "rbxassetid://137696953403792",
        localComponentName = {"SoundComponentClient"}
    }
}

--[[
!!!!!!!!!!!!!!!!!!!!!!!!NOTE!!!!!!!!!!!!!!!!!!!!!!!!
 - Local component are in the data section above.
]]
function itemDataBase.Duck()
    -- Creation function
    local item = pickUpClass.new(itemDataBase.itemData.Duck)
    item:addComponent(require(componentFolder.SoundComponentServer))
    item:createModel()
    return item
end

function itemDataBase.Torch()
    -- Creation function
    local item = pickUpClass.new(itemDataBase.itemData.Torch)
    item:addComponent(require(componentFolder.SoundComponentServer))
    item:addComponent(require(componentFolder.LightComponentServer))
    item:createModel()
    return item
end

function itemDataBase.BeachBall()
    -- Creation function
    local item = pickUpClass.new(itemDataBase.itemData.BeachBall)
    item:addComponent(require(componentFolder.SoundComponentServer))
    item:createModel()
    return item
end

function itemDataBase.Bear()
    -- Creation function
    local item = pickUpClass.new(itemDataBase.itemData.Bear)
    item:addComponent(require(componentFolder.SoundComponentServer))
    item:createModel()
    return item
end

function itemDataBase.Rocket()
    -- Creation function
    local item = pickUpClass.new(itemDataBase.itemData.Rocket)
    item:addComponent(require(componentFolder.SoundComponentServer))
    item:createModel()
    return item
end

function itemDataBase.Nokia()
    -- Creation function
    local item = pickUpClass.new(itemDataBase.itemData.Nokia)
    item:addComponent(require(componentFolder.SoundComponentServer))
    item:createModel()
    return item
end

function itemDataBase.Battery()
    -- Creation function
    local item = pickUpClass.new(itemDataBase.itemData.Battery)
    item:addComponent(require(componentFolder.SoundComponentServer))
    item:createModel()
    return item
end

table.freeze(itemDataBase)

return itemDataBase