-- [Services]
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- [Modules]
local moduleFolder = script.Parent.Parent.Parent.Modules
local defaultDungeonData = require(moduleFolder.DungeonData)
local dungeonLootSpawn = require(script.Parent.DungeonLootSpawn)

-- [Other Scripts]
local handlerFolder = script.Parent.Parent
local pickUpHandler = require(handlerFolder.PickUps.PickUpHandlerServer)
local doors         = require(handlerFolder.Interactables.Doors)

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local dungeonHandler = {}

-- Dungeon rooms
local storageDungeonFolder      = ServerStorage.Dungeon
local workspaceDungeonFolder    = Workspace.Dungeon
local chosenDungeon:Folder
local generatedRoomFolder       = workspaceDungeonFolder.GeneratedRooms

-- Nodes
local nodesFolder = workspaceDungeonFolder.Nodes

-- SpawnLocation
local SpawnLocation = workspaceDungeonFolder.SpawnLocations

-- Dungeon data
local dungeonData   -- The data asociated with target dungeon
local specialRooms  -- The special rooms that should be generated
local tableOfRooms
local tableOfRoomsOG
local tableOfExitIndi = {}
local tableOfExitIndiOG
local lootSpawnArray = {}

-- Loot related
local activeLoot    = workspaceDungeonFolder.ActivePickUps
local lootCount     = 0
local multiplier    = 1.0

--  Interactables
local doorsFolder   = ServerStorage.Interactables.Doors
local activeDoorsFolder = workspace.Interactables.Doors

-- Misc
local finalLocked   = false
local roomCount     = 0
-------------------------------------------------------------------------------------------------

-- [Changable variables] ------------------------------------------------------------------------
local DEBUG_ON = false -- When testing make sure to comment out the checker in the init function.
local DEBUG_WAIT = 0.05
-------------------------------------------------------------------------------------------------

-- Modifies chosen aspects of the dungeon
function lcl.handleDungeonData(defaultTable:table, modifierTable:table?)
    dungeonData = table.clone(defaultTable)

    -- Checking if there is any modifiers
    if modifierTable == nil then
        return
    end

    -- Replacing modified items
    if DEBUG_ON then
        print("-----------------------------------------------------------------------")
        print("DUNGEON MODIFIED!")
        print("Following attributes were modified.")
    end
    for attribute, val in modifierTable do
        if dungeonData[attribute] then
            dungeonData[attribute] = val
        else
            warn("Could not find attribute: ", attribute)
        end
    end
end

-- Handling the dungeon data
function dungeonHandler.initializeDungeon(floor:IntValue, modifierTable:table?)
    local dungeonName

    -- Getting dungeon data depending on the floor
    for name, v in defaultDungeonData.DungeonLevels do
        if v[1] <= floor and floor <= v[2] then
            dungeonName = name
        end
    end

    -- Geting floor data
    local floorData = defaultDungeonData.floorData[tostring(floor)]
    if floorData == nil then
        warn("Floor data does not exit.")
        warn("Therefore could not initialize dungeon.")
        return false
    end
    local tableOfSpecifiedRooms = floorData.rooms
    roomCount = floorData.roomCount

    -- Seeing if the dungeon has any modifiers, if there is it will modify the data
    lcl.handleDungeonData(defaultDungeonData[dungeonName], modifierTable)

    -- Retrieving the dungeon map
    chosenDungeon = storageDungeonFolder:FindFirstChild(dungeonName)
    if not chosenDungeon then
        warn("Cannot find '", dungeonName, "'")
        return
    end

    -- Hand picking the rooms that would be generated in the dungeon.
    tableOfRooms = lcl.pickRooms(roomCount, chosenDungeon, tableOfSpecifiedRooms)
    tableOfRoomsOG = table.clone(tableOfRooms)

    -- Getting all exit indicators
    lcl.collectExitIndis(generatedRoomFolder)
    tableOfExitIndiOG = table.clone(tableOfExitIndi)

    if DEBUG_ON then
        print("-----------------------------------------------------------------------")
        print("INITIALIZATION COMPLATE!")
        print(" - Floor: ", floor)
        print(" - Room count: ", roomCount)
        print(" - Spawning in ",dungeonName)
        print(" - Rooms: ", tableOfRooms)
        print(" - Special rooms: ", specialRooms)
        print(" - Table Of exit inidicators: ", tableOfExitIndiOG)
    end
    return true
end

function lcl.pickRooms(numOfRooms:IntValue, mapFolder:Folder, specifiedRooms:table?)
    local chosenRooms = {}
    local roomFolder = mapFolder:GetChildren()

    -- Inserting the specified rooms (or "special rooms") into chosenRooms table, if they exist
    if specifiedRooms then
        chosenRooms = table.clone(specifiedRooms)
    end

    -- Inserting the exit into the room gen
    table.insert(chosenRooms, ServerStorage.Dungeon.SpecialRooms.Exit)

    -- Inserting a random room into the chosen rooms folder
    for _ = 1, (numOfRooms - #specifiedRooms - 1), 1 do
        table.insert(chosenRooms, roomFolder[math.random(1,#roomFolder)])
    end

    return chosenRooms
end

function lcl.collectExitIndis(file)
    for _, v:Instance in file:GetDescendants() do
        if v.Name == "Exit Indicator" then
            table.insert(tableOfExitIndi, v)
        end
    end
end

-- Create new dungeon
function dungeonHandler.newDungeon()
    local resetDungeonGen = false

    repeat
        -- Generating the dungeon
        resetDungeonGen = lcl.generateRoom()

        if resetDungeonGen then
            warn("Resetting dungeon generation.")
            lcl.clearRooms()
            tableOfRooms = table.clone(tableOfRoomsOG)
            tableOfExitIndi = table.clone(tableOfExitIndiOG)
            resetDungeonGen = false
        end
    until #tableOfRooms == 0

    -- Finish off dungeon generation
    lcl.finishDungeon()

    -- Giving each node a pathfinder modifier
    for _, node in nodesFolder:GetChildren() do
        local modifier = Instance.new("PathfindingModifier", node)
        modifier.Label = "PathfindingNode"
        modifier.PassThrough = true
    end

    if DEBUG_ON then
        print("-----------------------------------------------------------------------")
        print("ROOM GEN COMPLATE!")
        print(" - RoomCount = ", roomCount)
    end
end

-- Preparing loot generation etc
function dungeonHandler.handleLootGen()
    local spawnArea
    local spawnPosition
    local spawnCFrame
    local chosenLoot:Model = nil
    local lootFolder = nil
    local sortedLootTable = {}

    local roomCounter = 0 -- Test

    -- Getting all the loot spawn location within the generated rooms folder
    for _, area in generatedRoomFolder:GetDescendants() do
        if area.Name == "LootSpawnArea" then
            table.insert(lootSpawnArray, area)
        end
    end

    -- Getting the number of loot that will spawn
    lootCount = dungeonLootSpawn.calculateLootCount(dungeonData.MAX_NUM_ROOM, roomCount, dungeonData.MAX_NUM_ROOM)

    lootFolder = ServerStorage.PickUps.LootModels

    if lootFolder == nil  then
        warn("Could not find loot folder.")
    end

    -- Sorting loot based on rarity
    sortedLootTable = dungeonData.LOOT_TABLE
    sortedLootTable = dungeonLootSpawn.sortLootFromRarity(sortedLootTable)

    for _ = 1, lootCount, 1 do
        -- Choosing what loot would be spawned ------------------------
        -- Picking what loot would spawn by chance
        local chosenLootName = dungeonLootSpawn.pickLoot(sortedLootTable)

        if chosenLootName == nil then
            multiplier += 0.05
            continue
        end

        -- Creating said item
        chosenLoot = pickUpHandler.createNew(chosenLootName, activeLoot)
        ---------------------------------------------------------------

        -- Picking the location of where the loot would spawn and look
        spawnArea = dungeonLootSpawn.pickSpawnArea(lootSpawnArray)   -- Picking a area where the loot can spawn
        spawnPosition = dungeonLootSpawn.getRandLootPos(spawnArea)
        spawnCFrame = CFrame.new(spawnPosition) * CFrame.Angles(0,math.random(0,360),0)

        -- Positioning chosen loot
        chosenLoot:positionTo(spawnCFrame)
        
        -- Resetting variables
        chosenLoot = nil

        roomCounter += 1
    end

    if DEBUG_ON then
        print("-----------------------------------------------------------------------")
        print("LOOT GEN COMPLATE!")
        print(" - Loot table: ", sortedLootTable)
        print(" - Multiplier: ", multiplier)
        print(" - Amonut of loot spawned. ",roomCounter)
        print("-----------------------------------------------------------------------")
    end
end

function lcl.generateRoom()
    local chosenRoom
    local checker
    local chosenExitIndi
    local CEIIndex
    local exitIndiTmp = tableOfExitIndi

    for _ = 1, #tableOfExitIndi, 1 do
        -- Picking a random exit indicator to place a room
        CEIIndex = math.random(1,#exitIndiTmp)
        chosenExitIndi = exitIndiTmp[CEIIndex]
        table.remove(exitIndiTmp, CEIIndex) -- Removing exit nodes to not choose it again

        -- Looping through the room file to see which room is valid
        for i=1, #tableOfRooms do
            local chosenRoomIndex = math.random(1, #tableOfRooms)

            -- Picking random room/hallway
            chosenRoom = tableOfRooms[chosenRoomIndex]:Clone()
            checker = chosenRoom.Checker

            -- Checking if the next room area is free
            local free = lcl:checkIfFree(checker, chosenExitIndi)
            checker:Destroy()
            if free then
                -- Create the room
                lcl.createRoom(chosenRoom, chosenExitIndi)
                table.remove(tableOfRooms, chosenRoomIndex)

                -- Collect new and old exit indicators
                lcl.collectExitIndis(chosenRoom)

                return false -- Returning false when successful at creating a room, to deny reset of dungeon gen
            else
                -- There was something blocking the way, Block off that entrance
                chosenRoom:Destroy()
                if i == #tableOfRooms then --  barricading if there isnt any more rooms/hallways to check with.
                    local success, errorMessage = pcall(function()  -- IDK why I used pcall here.
                        lcl.barricadeFunc(chosenExitIndi)
                    end)

                    if not success then
                        print(chosenRoom, chosenExitIndi)
                        warn(errorMessage)
                        return
                    end
                end
            end
        end
    end
    -- If there is no place for rooms then return true, to allow reset of dungeon gen
    return true
end

function lcl.clearRooms()
    for _, rooms:Model in generatedRoomFolder:GetChildren() do
        if rooms.Name ~= "StartingRoom" then
            rooms:Destroy()
        end
    end
end

-- function that is called when the dungeon is finished gneerating.
function lcl.finishDungeon()
    if finalLocked then
        return
    end
    finalLocked = true -- To prevent this function from running multiple times

    -- Creating a barricade when finish creating the dungeon
    for _, room in generatedRoomFolder:GetChildren() do
        for _, v in room:GetDescendants() do
            if v.Name == "Exit Indicator" then
                -- Seeing if the exit indicator is murged with the entrance indicator to see if its necessary to barricade or not.
                local overlapTable = Workspace:GetPartBoundsInBox(v.CFrame, v.Size)
                local free = true

                for _, parts in overlapTable do
                    if parts.Name == "Entrance Indicator" then
                        free = false
                        lcl.createDoor(v)
                        break
                    end
                end

                if free then
                    lcl.barricadeFunc(v)
                end
            end
        end
    end

    -- Putting all the waypoints from the rooms and hallways into the nodes folder
    for _, v in generatedRoomFolder:GetDescendants() do
        if v.Name == "Waypoint" then
            v.Parent = nodesFolder
        end
    end

    -- Putting all the spawn points into spawnlocation folder
    for _, v in generatedRoomFolder:GetDescendants() do
        if v.Name == "SpawnLocation" then
            v.Parent = SpawnLocation
        end
    end
end

function lcl.createDoor(exitIndicator:BasePart)
    if doorsFolder[dungeonData.DOOR_TYPE] == nil then
        warn("Could not find data for door.")
        return
    end
    local door = doors.new(doorsFolder[dungeonData.DOOR_TYPE], activeDoorsFolder, exitIndicator.CFrame)
end

function lcl.barricadeFunc(exitNode:BasePart)
    local exitFolder = exitNode.Parent
    if exitFolder == nil then
        return
    end
    local barricade:BasePart = exitFolder.Barricade or nil
    if barricade then
        barricade.Transparency = 0
        barricade.CanCollide = true
        barricade.CanQuery = true
        barricade.CanTouch = true
    end
end

function lcl.createRoom(room:Model, exitNode:BasePart)
    room.Parent = generatedRoomFolder
    room:PivotTo(exitNode.CFrame)
end

function lcl:checkIfFree(checker:Model, exitNode:BasePart)
    checker.Parent = generatedRoomFolder -- Moving it to the workspace so that it can check the space

    -- Move the checker to the exitNode
    checker:PivotTo(exitNode.CFrame)
    for _, checkBox in checker:GetChildren() do
        if checkBox.Name ~= "CheckBox" then continue end
        if DEBUG_ON then
            checkBox.Transparency = 0.6
            task.wait(DEBUG_WAIT)
        end

        -- Check if there is any object inside the checkbox
        local overlapTable = Workspace:GetPartBoundsInBox(checkBox.CFrame, checkBox.Size)
        if #overlapTable ~= 0 then
            return false
        end
    end
    -- After the loop has passed, it means that there is nothing in obstructing that area.
    return true
end

function dungeonHandler.destroyDungeon()
    finalLocked = false
    generatedRoomFolder:ClearAllChildren()
    nodesFolder:ClearAllChildren()
    SpawnLocation:ClearAllChildren()
    activeLoot:ClearAllChildren()
end

return dungeonHandler