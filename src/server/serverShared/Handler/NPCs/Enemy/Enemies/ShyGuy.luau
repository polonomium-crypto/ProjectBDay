-- Handles anything Dingle related

-- [Services]
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- [Moduels]
local moduleFolder = script.Parent.Parent.Parent.Parent.Parent.Modules
local enemyData = require(moduleFolder.EnemyData)

-- [Other Scripts]
local enemyAIMod = require(script.Parent.Parent.EnemyAI)

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local enemyShyGuy = {}
enemyShyGuy["data"] = enemyData.ShyGuy
-------------------------------------------------------------------------------------------------
-- [Changable variables] --------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------

function enemyShyGuy.init()
    --shared.spawnDingle()
end

function enemyShyGuy.spawnDingle()
    local shyGuy = enemyAIMod.new(enemyShyGuy.data)
    shyGuy:spawnEnemy()

    task.wait(1)
    shyGuy:stateManager()
    print("ffhfh")
    shyGuy:vision()
    shyGuy:patrol()
end

return enemyShyGuy