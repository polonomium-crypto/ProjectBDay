-- [Services]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- [General Variables] ------------------------------------------------------------
local CDS = {}
CDS.__index = CDS

-- Events
local CDEvent = ReplicatedStorage.Events.ChargingDockEvent

-- Folders
local interactableFolder = Workspace.Interactables
local chargeDocksFolder = interactableFolder.ChargeDocks
local storedInteractableFolder = ServerStorage.Interactables

-- Player related
local playerScriptFolder = script.Parent.Parent.Player
local PIS = require(playerScriptFolder.PlayerInventoryServer)

-- Misc
local CDCache = {}

-- [Changable variables]
local OVERTIME_LIMIT        = 5
local PP_OFFSET             = 100
local PP_HOLD_DUR           = 1
local PLR_DOCK_MAX_DIST     = 5
local EXPLOSION_FORCE       = 500000
local BLAST_RADIUS          = 20
-----------------------------------------------------------------------------------

function CDS.init()
    -- Revicing events from the client
    CDEvent.OnServerEvent:Connect(CDS.eventHandler)

    for _, chargeDock:Folder in chargeDocksFolder:GetChildren() do
        CDS.new(chargeDock[chargeDock.Name])
    end
end

function CDS.eventHandler(plr:Player, eventName:string, CDName:string)
    local CD:table = CDCache[CDName]
    if not CD then
        warn("Can't find Charging Dock: ", CDName)
        return
    end

    -- Check if player is close to the charger or not
    if not CDS.checkPlrDistance(plr, CD, eventName) then return end

    if eventName == "MainButton" then
        CDS.mainbutton(CD)                                      -- Main button functions
        CDS.notifyOutcastPlr(CD, "ChargingFX", plr)             -- Telling the outcast player to show the VFX of charging
        CDS.notifyFX(CD, "CDState", plr)                        -- Telling everyone except the one who sent the call to start FX.
    elseif eventName == "SelfDestructButton" then
        CDS.explosion(CD)
        CDS.notifyOutcastPlr(CD, "ExplosionFX", plr)             -- Telling the outcast player to show the VFX of charging
    end
end

function CDS.notifyOutcastPlr(CD:table, eventName:string, plr:Player)
    CDEvent:FireClient(plr,  CD.Name, eventName, CD.RechargeEnabled)
end

-- Helper: replaces all direct FX calls
function CDS.notifyFX(CD:table, FXName: string, outcastPlr:Player?)
    if outcastPlr == nil then
        CDEvent:FireAllClients(CD.Name, FXName, CD.RechargeEnabled)
        return
    end
    -- FXName is: ButtonFX, ChargingFX, ExplosionFX
    for _, plr:Player in Players:GetChildren() do
        if plr.Name ~= outcastPlr.Name then
            CDEvent:FireClient(plr, CD.Name, FXName, CD.RechargeEnabled)
        end
    end
end

function CDS.new(model:Model)
    local self = setmetatable({}, CDS)

    self.Model              = model
    self.Name               =self.Model.Name
    self.RechargeEnabled    = false
    self.chargeObj          = nil
    self.chargePos          = self.Model:FindFirstChild("ChargePos")
    self.Display            = self.Model.Display.Display.SurfaceGui.TextLabel
    self.button             = self.Model.Button.Button
    self.SDButton           = self.Model.SelfDestructButton.Button
    self.overtime           = 0
    if not self.chargePos and not self.Model then return end

    -- Adding self into CDList to be able to access it easily
    CDCache[self.Name] = self

    -- Creating proximity prompt
    local pp:ProximityPrompt    = self.chargePos.ProximityPrompt
    pp.UIOffset                 = Vector2.new(0,PP_OFFSET)
    pp.HoldDuration             = PP_HOLD_DUR
    pp.MaxActivationDistance    = PLR_DOCK_MAX_DIST

    -- Initializing main button click detector
    local clickDetector:ClickDetector   = self.button.ClickDetector
    clickDetector.MaxActivationDistance = PLR_DOCK_MAX_DIST

    -- Initializing self destruct button click detector
    local SDclickDetector:ClickDetector   = self.SDButton.ClickDetector
    SDclickDetector.MaxActivationDistance = PLR_DOCK_MAX_DIST

    -- Proximity prompt triggered when placing item down
    pp.Triggered:Connect(function(plr:Player)
        local obj = self.checker(plr)
        if not obj then return end
        self.chargeObj = obj

        -- Remove item from players inventory
        PIS.removeEquipped(plr)
        -- Place the obj model onto the charger
        obj:createModel()
        obj:positionTo(self.chargePos.CFrame)

        if self.chargeObj and self.RechargeEnabled then
            -- Obj on the charging dock
            self:recharge(self.chargeObj)
        end

        -- Handle when player picks up item again
        self.chargeObj.itemModel.Destroying:Connect(function()
            self:reset()
        end)
    end)

    return self
end

-- Checking if the player is cheating or not. Activation will be valid if player is close to the Charging dock.
function CDS.checkPlrDistance(plr:Player, CD:table, eventName:string)
    local chara = plr.Character or plr.CharacterAdded:Wait()
    local HRP = chara:FindFirstChild("HumanoidRootPart")
    local targetButton
    print(CD)
    if eventName == "MainButton" then
        targetButton = CD.button
    elseif eventName == "SelfDestructButton" then
        targetButton = CD.SDButton
    end

    if HRP and targetButton then
        local dist = (HRP.Position - targetButton.Position).Magnitude
        print(dist)
        if dist > PLR_DOCK_MAX_DIST then
            warn("Player is most likely cheating.")
            return false
        else
            return true
        end
    else
        warn("Could not find Humanoid Root Part or primary part of charging dock.")
        return
    end
end

-- Gets player equipped and see if the PickUp is chargable
function CDS.checker(plr:Player)
    local obj = PIS.getPlrEquipped(plr)

    if not obj then return end

    -- Check if obj has battery
    if obj.Battery then
        warn("Object has battery!")
        return obj
    else
        warn("Object does not have a Battery!")
        return false
    end
end

function CDS.mainbutton(CD:table)
    CD.RechargeEnabled = not CD.RechargeEnabled
    if CD.charge and not CD.RechargeEnabled then
        CD.charge:Disconnect()
        CDS.reset(CD)
    end
    if CD.chargeObj and CD.RechargeEnabled then
        -- Obj on the charging dock
        CD:recharge(CD.chargeObj)
    end
end

-- Resets the machine
function CDS.reset(CD:table)
    CD.Display.Text = "00:00"
    CD.overtime = 0
    if CD.charge then
        CD.charge:Disconnect()
    end
end

function CDS:recharge(obj:table)
    self.charge = RunService.Heartbeat:Connect(function(deltaTime)
        -- Check if battery of obj is over max
        if obj.Battery >= obj.BatteryCap then
            self.Display.Text = "--:--"
            obj.Battery = obj.BatteryCap
            self.overtime += deltaTime
            if self.overtime >= OVERTIME_LIMIT then
                -- Explosion function
                CDS.notifyFX(self, "ExplosionFX")
                CDS.explosion(self)
                self.charge:Disconnect()
            end
            return
        end
        -- Check if obj model is still on the charging dock

        -- Check if charging is enabled
        if not self.RechargeEnabled then
            self.charge:Disconnect()
        end

        -- Handling display of charging dock
        self:timerDisplay(obj)
        
        -- If all checked and cleared, recharge battery
        obj.Battery += deltaTime
    end)
end

function CDS.explosion(CD:table)
    local explopart = CD.Model.PrimaryPart
    -- Handle the destroyed model of charging dock
    local brokenDock:Model = storedInteractableFolder.ChargeDocks.BrokenChargeDock:Clone()
    brokenDock.Parent = chargeDocksFolder
    brokenDock:PivotTo(CD.Model.PrimaryPart.CFrame)
    CD.Model:Destroy()
    CD.Model = brokenDock

    -- Handle damaging the players
    local explosion = Instance.new("Explosion")
    explosion.Parent = Workspace
    explosion.BlastRadius = BLAST_RADIUS
    explosion.Position = explopart.Position
    explosion.ExplosionType = Enum.ExplosionType.NoCraters
    explosion.DestroyJointRadiusPercent = 0
    explosion.BlastPressure = EXPLOSION_FORCE
    explosion.Visible = false
    explosion.Hit:Connect(function(part)
        local humanoid = part.Parent:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end)

    -- Handle destroying the item thats on the charging dock
    if CD.chargeObj then
        CD.chargeObj.itemModel:Destroy()
        CD.chargeObj = nil
    end
end

function CDS:timerDisplay(obj:table)
    -- Calculate remaining time for obj
    local remainingTime = obj.BatteryCap - obj.Battery

    -- Then calculate mins and secs
    local mins = math.floor(remainingTime/60)
    local secs = math.floor(remainingTime - mins*60)
    if mins < 10 then
        mins = "0"..tostring(mins)
    end
    if secs < 10 then
        secs = "0"..tostring(secs)
    end

    -- Display
    self.Display.Text = mins .. ":" .. secs
end

return CDS