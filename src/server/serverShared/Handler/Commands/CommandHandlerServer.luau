-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

-- [Modules]
local dataMan = require(script.Parent.Parent.Data.DataManagement)
local pickUpHandler = require(script.Parent.Parent.PickUps.PickUpHandlerServer)
local ItemDataBase = require(script.Parent.Parent.Parent.Modules.ItemDataBase)

-- [General Variables] -----------------------------------------------------
local lcl = {}
local commandModServer = {}

-- Folders
local dungeonFolder = Workspace.Dungeon
local activeLootFolder = dungeonFolder.ActivePickUps

-- Events
local commandEvent = ReplicatedStorage.Events.CommandEvent
----------------------------------------------------------------------------
function commandModServer.init()
    -- To capture the event for commands
    commandEvent.OnServerInvoke = function(plr, commandName, data)
        -- First check if player is allowed to execute commands or not
        local plrRank
        if dataMan.tempData[plr.UserId] then
            plrRank = dataMan.tempData[plr.UserId].Rank
        else
            warn("Could not find player Rank data.")
            return false
        end

        if not (plrRank == "Creator" or plrRank == "Admin") then
            return false
        end

        -- Executing the command
        local successful
        successful = commandModServer[commandName](plr, data)
        return successful
    end
end

function commandModServer.give(plr:Player, data:table)
    local chara = plr.Character or plr.CharacterAdded:Wait()
    local HRP = chara.HumanoidRootPart
    local givePos = HRP.CFrame

    -- Check if the item actually exits
    if not ItemDataBase[data[1]] then
        return false
    end

    if not data[2] then
        SoundService.SFX["Spawn Sound Effect (Garry's mod)"]:Play()
        pickUpHandler.createNew(data[1], activeLootFolder, givePos)
        return true
    end

    SoundService.SFX["Spawn Sound Effect (Garry's mod)"]:Play()
    for _ = 1, data[2], 1 do
        pickUpHandler.createNew(data[1], activeLootFolder, givePos)
    end
    return true
end

function commandModServer.changeData(plr:Player, data:table)
    local success = dataMan.changeData(tonumber(data[1]), data[2], data[3])
    return success
end

function commandModServer.test()
    local itemDataBase = require(script.Parent.Parent.Parent.Modules.ItemDataBase)
    itemDataBase.Duck()
end

return commandModServer