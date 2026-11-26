-- [Services]
local dataStore = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- [Modules]
local dataTemplate = require(script.Parent.DataTemplate)

-- [General Variables] -----------------------------------------------------
local lcl = {}
local dataMan = {
    tempData = {}
}
local plrDataStore = dataStore:GetDataStore("PlayerData")
----------------------------------------------------------------------------

function dataMan.init()
    for _, plr in Players:GetChildren() do
        dataMan.plrJoined(plr.UserId)
    end

    -- Player joining the game
    Players.PlayerAdded:Connect(function(plr)
        dataMan.plrJoined(plr.UserId)
        print(dataMan.getPlrData(plr.UserId))   -- FOR TESTING
    end)

    -- Player leaving the game
    Players.PlayerRemoving:Connect(function(plr, reason)
        dataMan.plrLeaving(plr.UserId)
    end)
end

function dataMan.plrJoined(UserId)
    dataMan.initPlrData(UserId)
    table.insert(dataMan.tempData, dataMan.getPlrData(UserId))
end

function dataMan.plrLeaving(UserId:string)
    dataMan.tempData[UserId] = nil
end

-- Check if players data already exists or not
function dataMan.initPlrData(UserId)
    local data
    local success, results = pcall(function()
        data = plrDataStore:GetAsync(UserId)
        if not data then
            -- Setting players data to template
            warn("Could not find players data, falling back to default data.")
            local template = table.clone(dataTemplate)
            plrDataStore:SetAsync(UserId, template)
            dataMan.tempData[UserId] = template
            return
        end
    end)

    if not success then
        print(results)
        return
    end

    dataMan.tempData[UserId] = data
end

-- Changes data
function dataMan.changeData(UserId:IntValue, dataName:string, cData)
    local success, results = pcall(function()
        print(UserId, dataName, cData)
        local userData = plrDataStore:GetAsync(UserId)
        if userData and userData[dataName] then
            userData[dataName] = cData
            plrDataStore:SetAsync(UserId, userData)
        else
            warn("Could not find userData: ", userData[dataName])
            return false
        end
    end)
    if not success or results == false then
        warn("Was not able to change data")
    end

    -- If inserting was successful, insert it into the temp table
    dataMan.tempData[UserId] = cData
    return true
end

-- Prints players data
function dataMan.getPlrData(UserId:string)
    local data
    local success, results = pcall(function()
        data = plrDataStore:GetAsync(UserId)
    end)
    if not success then
        warn("Retrieving player data not successful")
        warn(results)
        return
    end
    return data
end

return dataMan