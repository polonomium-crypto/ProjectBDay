-- This script manages data and decides what happens in games
-- Depending on the floor the dungeon will change. Which means the game master should also manage the floor the players are in.


-- [Services]

-- [Modules]
local Modules = script.Parent.Parent.Parent.Modules
local FX = require(Modules.FX)

-- [Other Scripts]
local handlerFolder = script.Parent.Parent
local placeScriptFolder = handlerFolder.Place
local dungeonHandler = require(placeScriptFolder.DungeonHandler)
local enemyAI = require(handlerFolder.NPCs.Enemy.EnemyAI)
local enemyManager = require(handlerFolder.NPCs.Enemy.EnemyManager)

-- [General Variables] ----------------------------------------------------------------
local gameMaster = {
    floor = 1,
}
---------------------------------------------------------------------------------------

function gameMaster.init()
    gameMaster.main()
end

function gameMaster.main()
    --FX.scaryLighting()
    gameMaster.handleDungeon()
    gameMaster.handleEnemies() -- Needs the dungeon to generate first before the enemies can be initialized and managed
end

-- Handles dungeon generation using dungeon generation scripts
function gameMaster.handleDungeon()
    print("Making dungeon")
    local success = dungeonHandler.initializeDungeon(gameMaster.floor)
    if success then
        dungeonHandler.newDungeon()
        dungeonHandler.handleLootGen()
    end
end

-- Handles enemy spawning and management
function gameMaster.handleEnemies()
    --enemyManager.test()
end

return gameMaster