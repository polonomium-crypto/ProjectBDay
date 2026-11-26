
-- [Services]
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- [Moduels]
local enemyAIMod = require(script.Parent.EnemyAI)

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local enemyManager = {
    Enemies = {}
}

-- Dungeon
local workspaceDungeonFolder = Workspace.Dungeon
local generatedRoomFolder = workspaceDungeonFolder.GeneratedRooms
local spawnLocationFolder = workspaceDungeonFolder.SpawnLocations

local enemyModFolder = script.Parent.Enemies

-- Server storage enemy folder
local enemyStorFolder = ServerStorage.NPC.Enemies
local shyGuyModel = enemyStorFolder.ShyGuy
-------------------------------------------------------------------------------------------------
-- [Changable variables] ------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

function enemyManager.init()
end

function enemyManager.test()
    enemyManager.requireEnemyMods()

    local enemiesTable = enemyManager.Enemies
    local DingleMod = enemiesTable.Dingle
    local spawnPos
    spawnPos = enemyManager.pickRandSpawnPos()  -- Getting a random spawn position
    DingleMod.createNewDingle(spawnPos)
end

-- Requires all the enemy modules
function enemyManager.requireEnemyMods()
    for _, mod in enemyModFolder:GetChildren() do
        local requiredMod = require(mod)
        enemyManager.Enemies[mod.Name] = requiredMod
    end
end

-- Picking a random place to spawn in enemy
function enemyManager.pickRandSpawnPos()
    -- Picking a random spawn location
    local spawnLocation
    if #spawnLocationFolder:GetChildren() ~= 0 then
        spawnLocation = spawnLocationFolder:GetChildren()[math.random(1,#spawnLocationFolder:GetChildren())]
    else
        warn("There was no spawn location for the enemy to spawn")
        return
    end
    
    return spawnLocation.CFrame
end

return enemyManager