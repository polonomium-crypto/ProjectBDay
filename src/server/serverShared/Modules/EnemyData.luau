-- [Services]
local ServerStorage = game:GetService("ServerStorage")

-- [General variables] --------------------------------------------------------------------------
-- Server storage enemy folder
local enemyStorFolder = ServerStorage.NPC.Enemies
-------------------------------------------------------------------------------------------------

local enemyData

enemyData = {
    Dingle = {
        NAME                = "Dingle",
        MODEL               = enemyStorFolder.Dingle,
        WALKSPEED           = 20,
        FOV                 = 60, -- In degrees.
        DISTANCE_VISION     = 150, -- In studs
        HUNT_RADIUS         = 9,
    },
    ShyGuy = {
        NAME                = "ShyGuy",
        MODEL               = enemyStorFolder.ShyGuy,
        WALKSPEED           = 10,
        FOV                 = 60, -- In degrees.
        DISTANCE_VISION     = 150, -- In studs
        HUNT_RADIUS         = 9
    }
}

return enemyData