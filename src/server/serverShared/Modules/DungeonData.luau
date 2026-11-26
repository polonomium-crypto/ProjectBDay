-- [Services]
local ServerStorage = game:GetService("ServerStorage")

-- [Changable variables] ------------------------------------------------------------------------
local SRF = ServerStorage.Dungeon.SpecialRooms
-------------------------------------------------------------------------------------------------

local dungeonData = {
    floorData  = {
        ["1"] = {
            roomCount       = 50,
            rooms           = {SRF["Room2-1"],SRF["Room2-3"],SRF["Room2-4"],SRF["Room2-6"],SRF["Room2-7"]}
        },
    },
    DungeonLevels = {
        Dungeon1    = {1,12},
        Dungeon2    = {13,14},
        Dungeon3    = {15,99}
    },
    Dungeon1 = {
        DIFFICULTY_MULTIPLIER   = 1,                  -- 1 is base difficulty, 1.1 is 10% more difficult.
        BRIGHTNESS              = 1,                  -- 0 is nothing, 1 is default 100%.
        MAX_NUM_OF_MONSTERS     = 6,                  -- Maximum number of monster that spawn
        MONSTER_TABLE           = {"Dingle"},
        LOOT_DENSITY            = 3,
        LOOT_TABLE              = {"Bear", "Battery", "BeachBall", "Duck"},
        DOOR_TYPE               = "BasicDoor",
        MAX_LOOT_COUNT          = 20,
        MIN_NUM_ROOM            = 20,
        MAX_NUM_ROOM            = 25
    },
    Dungeon2 = {
        DIFFICULTY_MULTIPLIER   = 1,                  -- 1 is base difficulty, 1.1 is 10% more difficult.
        BRIGHTNESS              = 1,                  -- 0 is nothing, 1 is default 100%.
        MAX_NUM_OF_MONSTERS     = 6,                  -- Maximum number of monster that spawn
        MONSTER_TABLE           = {"Dingle"},
        LOOT_DENSITY            = 3,
        LOOT_TABLE              = {"Bear", "Battery", "BeachBall", "Duck"},
        DOOR_TYPE               = "BasicDoor",
        MAX_LOOT_COUNT          = 20,
        MIN_NUM_ROOM            = 20,
        MAX_NUM_ROOM            = 25
    },
    Dungeon3 = {
        DIFFICULTY_MULTIPLIER = 1.5,                -- 1 is base difficulty, 1.1 is 10% more difficult.
        BRIGHTNESS = 0.6,                           -- 0 is nothing, 1 is default 100%.
        MAX_NUM_OF_MONSTERS = 9,                    -- Maximum number of monster that spawn
        MIN_NUM_ROOM = 4,
        MAX_NUM_ROOM = 20
    },
}

return dungeonData