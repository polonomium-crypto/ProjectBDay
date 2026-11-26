-- [Services]
local PathFindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local enemyAI = {}
enemyAI.__index = enemyAI

-- Dungeon
local workspaceDungeonFolder = Workspace.Dungeon
local generatedRoomFolder = workspaceDungeonFolder.GeneratedRooms
local spawnLocationFolder = workspaceDungeonFolder.SpawnLocations

-- NPC
local NPCFolder = Workspace.NPC
local enemiesWorkspaceFolder = NPCFolder.Enemies

-- Raycast
local raycastParamPathFind = RaycastParams.new()
local raycastParamVision = RaycastParams.new()
-------------------------------------------------------------------------------------------------
-- [Changable variables] ------------------------------------------------------------------------
-- Debug var
local RAYCAST_DEBUG_ON = false
local DEBUG_MARKING_NODES = true

local NODE_RETRY_MAX = 4
local NODE_RADIUS = 15
local PATH_PARAMS = {AgentRadius = 1.5, AgenHeight = 3, AgentCanJump = true, Costs = {PathfindingNode = 0.9}}
local WAYPOINT_LEGROOM = 3
local PATHING_TIME_LIMIT = 2

-- Time limits
local PATROL_TIME_LIMIT = 2
local TRACKING_TIME_LOOP_DUR = 0.2

-- Enemy default values
local DEFAULT_WALKSPEED = 5
local DEFAULT_DIST_VISION = 100
local DEFAULT_HUNT_RADIUS = 5
local STATE_PATROL = "Patrol"
local STATE_HUNT = "Hunt"
local STATE_TRACK = "Track"
local STATE_IDLE = "Idle"
local STATE_ATTACK = "Attack"
-------------------------------------------------------------------------------------------------
-- Defining "State" data structure
export type state = {
    Name: string,
    EnterFunction: () -> (),
    MainFunction: () -> (),
    ExitFunction: () -> (),
}

function enemyAI.new()
    local self = setmetatable({}, enemyAI) -- Makes a table independant from table EnemyAI but will look for var when it doesn't exit in the new table.

    -- Setting up list of states and current state
    self.States = {}
    self.currentState = nil

    return self
end

function enemyAI:getData(enemyAttributes: table)
     -- Setting values to new enemy
    self.Data = table.clone(enemyAttributes)

    -- Cloning the model and getting a refrence
    local cloneModel:Model = self.Data.MODEL
    self.Data.MODEL = cloneModel:Clone()
    self.Data.MODEL.Parent = Workspace
    self.Data.HUMANOID = self.Data.MODEL.Humanoid
    self.Data.PRIMARY_PART = self.Data.MODEL.PrimaryPart

    -- Preparing necessary variables
    self.activeData = {}
    self.activeData.currentWaypointIndex = 1
    self.activeData.inMotion = false
    self.activeData.pathLock = false -- It acts as a debounce of sorts in the patrol method, so that it only creates 1 new path.
    self.activeData.eTime = PATHING_TIME_LIMIT
    self.activeData.checkedOff = {}
    self.activeData.instancesToFilterPathFind = {}

    -- Making sure the folder "Nodes" has nodes inside it
    self.activeData.nodes = workspaceDungeonFolder.Nodes:GetChildren()

    -- Seeing if nodes are loaded in, if not return a error message and stop the function
    if #self.activeData.nodes == 0 then
        error("Nodes didn't load in yet or doesn't exit in the folder Dungeon/Nodes.")
        return
    end

     -- Init raycast params. (Getting all the instances that gets hit by the ray)
    for _, v in generatedRoomFolder:GetDescendants() do
        if v.Name == "floor" or v.Name == "Floor" or v.Name == "wall" or v.Name == "Wall" or v.Name == "Stair" then
            table.insert(self.activeData.instancesToFilterPathFind, v)
        end
    end
    raycastParamPathFind.FilterDescendantsInstances = self.activeData.instancesToFilterPathFind
    raycastParamPathFind.FilterType = Enum.RaycastFilterType.Include

    -- Setting network ownership of the enemy to the server and not auto(It will cause the enemy to lag if not server)
    self.Data.MODEL.PrimaryPart:SetNetworkOwner(nil)
end

function enemyAI:defineStates(states:{state})
    for _, state in states do
        self.States[state.Name] = state
    end
end

function enemyAI:spawnEnemy()   -- DELETE THIS FUNCTION
    -- Preparing necessary variables
    self.currentWaypointIndex = 1
    self.inMotion = false
    self.pathLock = false -- It acts as a debounce of sorts in the patrol method, so that it only creates 1 new path.
    self.eTime = PATHING_TIME_LIMIT
    self.humanoid = self.model.Humanoid
    self.primaryPart = self.model.PrimaryPart
    self.checkedOff = {}

    -- Setting the character to the workspace
    self.model.Parent = enemiesWorkspaceFolder

    -- Setting network ownership of the enemy to the server and not auto(It will cause the enemy to lag if not server)
    self.model.PrimaryPart:SetNetworkOwner(nil)
    
    -- Picking a random spawn location
    local spawnLocation
    if #spawnLocationFolder:GetChildren() ~= 0 then
        spawnLocation = spawnLocationFolder:GetChildren()[math.random(1,#spawnLocationFolder:GetChildren())]
    else
        warn("There was no spawn location for the enemy to spawn")
        return
    end
    self.model:PivotTo(spawnLocation.CFrame)

    -- An event for when the enemy reaches a waypoint
    self.humanoid.MoveToFinished:Connect(function()
        warn("MoveToFinsihed has been called!")
        self.currentWaypointIndex += 1
        self.inMotion = false
    end)
end

function lcl.visualiseWaypoints(waypoints)
    for _, waypoint in waypoints do
        local obj = Instance.new("Part")
        obj.Parent = enemiesWorkspaceFolder.TestingWaypoint
        obj.Size = Vector3.new(0.5,0.5,0.5)
        obj.Anchored = true
        obj.CanCollide = false
        obj.Position = waypoint.Position
        obj.Material = Enum.Material.Neon
        obj.Color = Color3.fromRGB(0, 179, 131)
    end
end

-- This function is iterated thorugh runService
function enemyAI:update(d_time:number)
    local activeState = self.activeData

    -- Check if the state has changed
    if activeState.currentState ~= activeState.stateTmp then
        -- If the enemy changes state, transition over to that state
        activeState.stateTmp = activeState.currentState
        activeState:transitionState(activeState.currentState)
    end

    -- If state is the same, continue state function
    self.States[activeState.currentState].MainFunction(d_time)
end

-- Setting up the enemies initial state
function enemyAI:setInitialState(state:string)
    self.activeData.currentState = state
    self.activeData.stateTmp = state
end

-- Transition from one state to another
function enemyAI:transitionState()
    
end

-- Constantly checks the current state of the enemy.
function enemyAI:stateManager()
    RunService.Heartbeat:Connect(function(deltaTime)
        if self.stateMemory ~= self.currentState then
            self:transitionState()
            self.stateMemory = self.currentState
        end

        if self.currentState == STATE_PATROL then
            self:patrol(deltaTime)
        elseif self.currentState == STATE_HUNT then
            self:hunt(deltaTime)
        elseif self.currentState == STATE_TRACK then
            self:tracking(deltaTime)
        elseif self.currentState == STATE_ATTACK then
            self:attack()
        elseif self.currentState == STATE_IDLE then
            self:idle()
        end
    end)
end

-- The behavior where the NPC walks around trying to find the player
function enemyAI:patrol(deltaTime:number)
    local activeData = self.activeData

    -- Creating a path when there is no path. This is creating a new path from the enemies primary part.
    if activeData.currentPath == nil then
        warn("Creating new path")
        activeData.currentNode = self:findClosestNode(self.Data.PRIMARY_PART)
        self:markSurroundingNode(activeData.currentNode)
        activeData.queuedNode = self:findClosestNode(activeData.currentNode)
        self:markSurroundingNode(activeData.queuedNode)
        activeData.currentPath = PathFindingService:CreatePath(PATH_PARAMS)
        local success, errorMessage = pcall(function()
            activeData.currentPath:ComputeAsync(self.Data.PRIMARY_PART.Position, activeData.currentNode.Position)
        end)
        if not success then
            error(errorMessage)
        end
    end

    activeData.eTime += deltaTime
    -- Checks if the enemy got stuck on something
    if activeData.eTime >= PATROL_TIME_LIMIT then
        self:resetNodes()
        activeData.eTime = 0
        activeData.currentPath = nil
        return
    end

    -- Checks if the humanoid reached the waypoint within a certain distance or not
    if activeData.currentWaypointIndex < #activeData.currentPath:GetWaypoints() then
        local targetNode = activeData.currentPath:GetWaypoints()[activeData.currentWaypointIndex]
        local humanoidNodeDistance = (self.Data.PRIMARY_PART.Position - targetNode.Position).Magnitude

         -- Checks if the humanoid is already in range of the node or not.
        if humanoidNodeDistance <= WAYPOINT_LEGROOM and activeData.inMotion then
            activeData.currentWaypointIndex += 1
            activeData.inMotion = false
            return
        end

        -- Checking if the character is still moving or not
        if not activeData.inMotion then
            activeData.inMotion = true
            --print(self.currentWaypointIndex, #self.currentPath:GetWaypoints())
            activeData.eTime = 0
            self.Data.HUMANOID:MoveTo(activeData.currentPath:GetWaypoints()[activeData.currentWaypointIndex].Position)
            --lcl.visualiseWaypoints(self.currentPath:GetWaypoints()) -- Remove this after debugging
        end
    elseif not activeData.pathLock then
        activeData.pathLock = true
        -- Creates a new path because the there either isnt a path or the path was already finished.
        enemiesWorkspaceFolder.TestingWaypoint:ClearAllChildren() -- This is to get rid of objects to visualize the path

        local oldNode = activeData.currentNode
        activeData.currentNode = activeData.queuedNode
        activeData.currentWaypointIndex = 1 -- Reseting index

        local success, errorMessage = pcall(function()
            activeData.currentPath:ComputeAsync(self.Data.PRIMARY_PART.Position, activeData.currentNode.Position)
        end)
        if success then
            activeData.queuedNode = self:findClosestNode(oldNode)
            self:markSurroundingNode(activeData.queuedNode)
        else
            error(errorMessage)
        end
        activeData.pathLock = false
    end
end

-- The behavior when the NPC spots a player and goes after them to kill them
function enemyAI:hunt(deltaTime:number)
    if self.targetPlr == nil then
        warn("Did not specify target player.")
        self.currentState = STATE_PATROL
        return
    end

    local plrChara = self.targetPlr.Character or self.targetPlr.CharacterAdded:Wait()
    local HRP = plrChara.HumanoidRootPart -- player HRP

    -- If the enemy is outdside the range of hunting.
    if (HRP.Position - self.primaryPart.Position).Magnitude > self.huntRadius then
        self.currentState = STATE_TRACK
        return
    end

    if self.targetPlr and HRP then
        self.inMotion = true
        self.humanoid:MoveTo(HRP.Position)
    end
end

function enemyAI:attack()

end

-- Even though the enemy can't see the player, it will create a path to the player every few seconds, if the enemy couldn't find the player under a time limit it will go back to patrolling.
function enemyAI:tracking(deltaTime:number)
    self.eTime += deltaTime
    if self.targetPlr then
        local plrChara = self.targetPlr.Character or self.targetPlr.CharacterAdded:Wait()
        local HRP = plrChara.HumanoidRootPart -- Player HRP

        if not HRP then -- When there is no player. (Usually when they leave)
            warn("No humanoid root part specified.")
            return
        end

        -- Go to hunting status once the enemy is close enough to the player.
        if (HRP.Position - self.primaryPart.Position).Magnitude <= self.huntRadius then
            self.currentState = STATE_HUNT
            return
        end

        -- The time limit for how often a path should be made.
        if self.eTime >= TRACKING_TIME_LOOP_DUR then
            self.eTime = 0
            self.pathLock = false
        end

        -- Creating a new path to the last location the enemy saw the player
        if not self.pathLock then
            self.pathLock = true
            self.currentWaypointIndex = 1
            if self.currentPath == nil then
                self.currentPath = PathFindingService:CreatePath(PATH_PARAMS)
            end
            local success, errorMessage = pcall(function()
                --print(self.currentPath, HRP.Position, self.currentWaypointIndex)
                self.currentPath:ComputeAsync(self.primaryPart.Position, self.currentTargetPos)
            end)
            if not success then
                error(errorMessage)
            end
        end
    end

    if self.currentPath == nil then -- Return if there is no path to follow
        return
    end

    if #self.currentPath:GetWaypoints() ~= 0 then
        -- If the enemy reaches the target location without going into hunt mode. (Went to the last location the enemy saw the player)
        if self.currentWaypointIndex >= #self.currentPath:GetWaypoints() and self.targetPlr == nil then
            self.currentState = STATE_PATROL
            return
        end

        if self.currentWaypointIndex >= #self.currentPath:GetWaypoints() then
            return
        end

        local targetNode = self.currentPath:GetWaypoints()[self.currentWaypointIndex]
        local humanoidNodeDistance = (self.primaryPart.Position - targetNode.Position).Magnitude

         -- Checks if the humanoid is already in range of the node or not. (Kind of a ducktape solution for the weird pause it does whenever MoveToFinished is called.) Same code on line 208 ~ 217
        if humanoidNodeDistance <= WAYPOINT_LEGROOM and self.inMotion then
             self.currentWaypointIndex += 1
             self.inMotion = false
            return
        end

        if not self.inMotion then -- Checking if the character is still moving or not
            self.inMotion = true
            --print(self.currentWaypointIndex, #self.currentPath:GetWaypoints())
            self.humanoid:MoveTo(self.currentPath:GetWaypoints()[self.currentWaypointIndex].Position)
            --lcl.visualiseWaypoints(self.currentPath:GetWaypoints()) -- Remove this after debugging
        end
    end
end

function enemyAI:idle()
    
end

-- The vision of the enemy
function enemyAI:vision()
    local model = self.Data.MODEL
    local enemyHead = model:FindFirstChild("Head")
    local enemyFOV = math.cos(math.rad(self.Data.FOV))
    local enemyDistVis = self.activeData.distVis
    local partsToFilter = {}

    -- Init raycastParams
    for _, plr:Player in Players:GetChildren() do
        local chara = plr.Character or plr.CharacterAdded:Wait()
        for _, part in chara:GetDescendants() do
            if part.Name ~= "HumanoidRootPart" then
                table.insert(partsToFilter, part)
            end
        end
    end
    table.insert(partsToFilter, enemyHead)
    raycastParamVision.FilterDescendantsInstances = partsToFilter
    raycastParamVision.FilterType = Enum.RaycastFilterType.Exclude

    task.spawn(function()
        if enemyHead then
            RunService.Heartbeat:Connect(function()
                -- Getting the dot product of the enemies look vector and the players location relative to the enemy
                
                for _, plr:Player in Players:GetChildren() do
                    local chara = plr.Character
                    local HRP:BasePart = chara:FindFirstChild("HumanoidRootPart")

                    -- If player is too far for the enemy to see
                    if (enemyHead.Position - HRP.Position).Magnitude >= enemyDistVis then
                        self.activeData.targetPlr = nil
                        continue
                    end

                    -- Checking if the player is in the field of view of the enemy
                    local plrVectorRelativeToEnemy = HRP.Position - enemyHead.Position
                    local dotProduct = enemyHead.CFrame.LookVector:Dot(plrVectorRelativeToEnemy/plrVectorRelativeToEnemy.Magnitude)
                    if dotProduct <= enemyFOV then
                        self.activeData.targetPlr = nil
                        continue
                    end

                    -- Checking if there is anything that is blocking the way of the enemies view.
                    local raycastResult = Workspace:Raycast(enemyHead.Position, HRP.Position - enemyHead.Position, raycastParamVision)
                    if raycastResult then
                        if raycastResult.Instance.Name == "HumanoidRootPart" then -- In hunting state but can't find player, changes to Tracking state
                            self.activeData.targetPlr = plr
                            self.activeData.currentTargetPos = HRP.Position
                            if self.activeData.currentState ~= STATE_HUNT then
                                self.activeData.currentState = STATE_TRACK
                            end
                        else
                            self.activeData.targetPlr = nil
                        end
                    end
                end
            end)
            else
                warn("Was not able to find enemies head.")
            end
    end)
end

-- Finding the closest node that is not included in the table checkedOff.
function enemyAI:findClosestNode(origin:BasePart)
    local activeData = self.activeData
    local checkOff = activeData.checkedOff
    local nodes = self.activeData.nodes

    -- Sort for the closest node
    table.sort(nodes, function(a,b)
        local distA = (origin.Position - a.Position).Magnitude
        local distB = (origin.Position - b.Position).Magnitude
        return distA < distB
    end)

    -- Checking if this node is included in the table checkedOff, is in view from the origin and returning it, if it is not in checkedOff and is in view from the origin.
    for _, node in nodes do
        local raycastResult:RaycastResult = Workspace:Raycast(origin.Position, node.Position - origin.Position, raycastParamPathFind) -- Create a ray from origin to node

        -- For debugging
        if RAYCAST_DEBUG_ON then
            local originHighlight = Instance.new("Highlight", origin)
            local nodeHighLight = Instance.new("Highlight", node)
            local hitHighlight

            if raycastResult ~= nil then
                hitHighlight = Instance.new("Highlight", raycastResult.Instance)
            end

            local ray = Instance.new("Part", Workspace)
            ray.Anchored = true
            ray.CanCollide = false
            ray.Material = Enum.Material.Neon
            ray.Size = Vector3.new(0.1, 0.1, (origin.Position - node.Position).Magnitude)
            ray.CFrame = CFrame.new((origin.Position + node.Position)*0.5, node.Position)
            ray.Color = Color3.fromRGB(255, 0, 0)

            task.wait(0.2)
            if hitHighlight then
                hitHighlight:Destroy()
            end
            ray:Destroy()
            originHighlight:Destroy()
            nodeHighLight:Destroy()
        end

        if table.find(checkOff, node) then
            continue
        elseif raycastResult == nil then
            return node
        end
    end

    --warn("There was no ray in view.")
    for _, node in nodes do
        if table.find(checkOff, node) then
            continue
        else
            return node
        end
    end
end

function enemyAI:resetNodes()
    local nodes = self.activeData.nodes
    warn("Clearing all nodes", #self.activeData.checkedOff, #nodes)
    table.clear(self.activeData.checkedOff)

    if DEBUG_MARKING_NODES then
        for _, v in nodes do
            v.Color = Color3.fromRGB(0, 0, 0)
        end
    end
end

function enemyAI:markSurroundingNode(targetNode:BasePart)
    local nodes = self.activeData.nodes
    print(self)
    for _, node in nodes do
        local raycastResult = Workspace:Raycast(targetNode.Position, node.Position - targetNode.Position)
        if (targetNode.Position - node.Position).Magnitude <= NODE_RADIUS and table.find(self.activeData.checkedOff, node) == nil and raycastResult == nil then
            node.Color = Color3.fromRGB(241, 245, 0)    -- This is to better visualise what is going on.
            table.insert(self.activeData.checkedOff, node)

            -- Check if the NPC went through all the nodes or not, if so, reset.
            if #self.activeData.checkedOff >= #nodes then
                self:resetNodes()
            end
        end
    end
end

return enemyAI