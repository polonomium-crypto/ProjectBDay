-- [Services]
local Workspace = game:GetService("Workspace")

-- [Modules]
local sharedModFolder = script.Parent.Parent.Parent.Parent.ServerShared.Modules
local itemTableMod = require(sharedModFolder.ItemDataBase)


-- [General Variables] --------------------------------------------------------------------------
local dungeonLootSpawn = {}
local lootCountControl = 3
-------------------------------------------------------------------------------------------------

function dungeonLootSpawn.calculateLootCount(maxLootCount:number, roomCount:number, maxNumOfRoom:number)
    return math.round(maxLootCount * (roomCount/(maxNumOfRoom*lootCountControl)))
end

function dungeonLootSpawn.pickSpawnArea(lootLocationArray)
    if #lootLocationArray == 0 then
        warn("No place for loot to spawn.")
        return
    end
    return lootLocationArray[math.random(1, #lootLocationArray)]
end

-- Rotates vector along the y axis by delta theta
function dungeonLootSpawn.vectorRotation2D(vector:Vector3, deltaTheta:number)
    local rotX, rotZ

    rotX = vector.X * math.cos(deltaTheta) - vector.Z * math.sin(deltaTheta)
    rotZ = vector.X * math.sin(deltaTheta) + vector.Z * math.cos(deltaTheta)

    return Vector3.new(rotX,0,rotZ)
end

-- Generating loot at a random place within the chosen spawn area
function dungeonLootSpawn.getRandLootPos(spawnArea:Part)
    local AreaPos = spawnArea.Position
    local AreaSize = spawnArea.Size
    local theta = -math.rad(spawnArea.Orientation.Y)
    local sizeX
    local sizeZ
    local rotationPos
    local spawnPos

    -- Picking random spawn position
    sizeX = math.abs(AreaSize.X) / 2
    sizeZ = math.abs(AreaSize.Z) / 2
    rotationPos = Vector3.new(math.random(-sizeX, sizeX), 0, math.random(-sizeZ, sizeZ))

    -- Rotating picked position
    rotationPos = dungeonLootSpawn.vectorRotation2D(rotationPos, theta)

    -- Spawn position
    spawnPos = rotationPos + AreaPos

    return spawnPos
end

-- Gets specified loot from the loot Folder in accord to the lootTable
function dungeonLootSpawn.getRefOfLootTable(lootFolder:Folder, lootTable:table)
    local newlootTable = {}

    for _, loot in lootTable do
        for _, item:Model in lootFolder:GetChildren() do
            if loot == item.Name then
                table.insert(newlootTable, item)
            end
        end
    end
    return newlootTable
end

-- Sorts loot from rarity attribute
function dungeonLootSpawn.sortLootFromRarity(lootTable: table)
    table.sort(lootTable, function(a:Model, b:Model)
        local A = a.Rarity
        local B = b.Rarity
        if A and B then
            return A < B
        end
    end)
    return lootTable
end

function dungeonLootSpawn.pickLoot(sortedLootTable: table) -- Sorted loot table consists of strings with the names of the loot
    local odds
    local lootRarity
    local randomlyChosenLootName: string
    for _ = 1, #sortedLootTable do
        odds = math.random(1,100)
        randomlyChosenLootName = sortedLootTable[math.random(1,#sortedLootTable)]
        
        if itemTableMod.itemData[randomlyChosenLootName] then
            lootRarity = itemTableMod.itemData[randomlyChosenLootName].Rarity
        else
            warn("Could not find loot in item table: ", randomlyChosenLootName)
            return
        end
        if lootRarity >= odds then
            return randomlyChosenLootName
        end
    end
end

return dungeonLootSpawn