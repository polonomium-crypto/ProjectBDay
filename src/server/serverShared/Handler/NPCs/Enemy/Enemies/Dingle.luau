-- Handles anything Dingle related

-- [Services]
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- [Moduels]
local moduleFolder = script.Parent.Parent.Parent.Parent.Parent.Modules
local enemyData = require(moduleFolder.EnemyData)

-- [Other Scripts]
local enemyAIMod = require(script.Parent.Parent.EnemyAI)

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local enemyDingle = {}

-------------------------------------------------------------------------------------------------
-- [Changable variables] ------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------

-- States
local states: enemyDingle.state = {
    {
        Name            = "Patrol",
        EnterFunction   = nil,
        MainFunction    = function(d_time:number)
            enemyDingle:patrol(d_time)
        end,
        ExitFunction    = nil,
    },
    {
        Name            = "Hunt",
        EnterFunction   = nil,
        MainFunction    = function()
            enemyDingle:hunt()
        end,
        ExitFunction    = nil,
    },
    {
        Name            = "Track",
        EnterFunction   = nil,
        MainFunction    = function()
            enemyDingle:tracking()
        end,
        ExitFunction    = nil,
    },
    {
        Name            = "Idle",
        EnterFunction   = nil,
        MainFunction    = function()
            enemyDingle:idle()
        end,
        ExitFunction    = nil,
    },
    {
        Name            = "Attack",
        EnterFunction   = nil,
        MainFunction    = function()
            enemyDingle:attack()
        end,
        ExitFunction    = nil,
    },
    {
        Name            = "Dance",
        EnterFunction   = nil,
        MainFunction    = function()
            enemyDingle:dance()
        end,
        ExitFunction    = nil,
    },
}

function enemyDingle.init()
end

function enemyDingle.createNewDingle(SpawnPos: CFrame)
    enemyDingle = enemyAIMod.new()                      -- Creating a new enemy
    enemyDingle:getData(enemyData.Dingle)  -- Putting in enemy data
    enemyDingle:defineStates(states)

    -- Initializing current state
    enemyDingle:setInitialState("Patrol")
    print(enemyDingle)

    -- Positioning where the model would spawn
    if SpawnPos then
        enemyDingle.Data.MODEL:PivotTo(SpawnPos)
    end

    -- Making sure the enemy can see
    enemyDingle:vision()

    -- Updating with runservice
    local thread = coroutine.create(function()
        RunService.Heartbeat:Connect(function(d_time)
            enemyDingle:update(d_time)
        end)
    end)
    coroutine.resume(thread)

    return enemyDingle
end

function enemyDingle.dance()
    warn("DINGLE IS DANCING!!!")
end

return enemyDingle