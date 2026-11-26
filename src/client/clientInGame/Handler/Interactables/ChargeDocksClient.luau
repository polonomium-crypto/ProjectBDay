-- This script just handles the animations for the button
-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- [General Variables] ------------------------------------------------------------
local CDC = {}

-- Event
local CDEvent = ReplicatedStorage.Events.ChargingDockEvent

-- Charging dock related
local CDCache = {}
local CDFolder = Workspace.Interactables.ChargeDocks

-- Tween
local buttonTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out,0,true)
-----------------------------------------------------------------------------------
-- [General Variables] ------------------------------------------------------------
-- Button
local ACTIVE_BUTTON_COLOR           = Color3.fromRGB(255,0,0)
local DEACTIVE_BUTTON_COLOR         = Color3.fromRGB(0,255,0)

-- Charge FX
local CHARGE_LIGHT_COLOR            = Color3.fromRGB(34, 194, 252)
local CHARGE_LIGHT_RANGE            = 8

-- Explosion
local EXPLOSION_LIGHT_COLOR         = Color3.fromRGB(255, 255, 255)
local EXPLOSION_LIGHT_RANGE         = 25
local EXPLOSION_LIGHT_BRIGHTNESS    = 20
local EXPLOSION_LIGHT_DUR           = 1
local EXPLOSION_TWEENINFO           = TweenInfo.new(EXPLOSION_LIGHT_DUR/2,Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true)
-----------------------------------------------------------------------------------

function CDC.init()
    -- Getting event reciving ready
    CDEvent.OnClientEvent:Connect(CDC.eventHandler)

    -- Caching Charging docks to have easier access and to not not have to find the object all the time
    for _, folder:Folder in CDFolder:GetChildren() do
        local dockName = folder.Name
        local model = folder[dockName]
        CDCache[dockName] = {}
        CDCache[dockName]["Model"] = model
        CDCache[dockName]["MainButton"] = model:WaitForChild("Button"):WaitForChild("Button")
        CDCache[dockName]["SelfDestructButton"] = model:WaitForChild("SelfDestructButton"):WaitForChild("Button")
        CDCache[dockName]["FXPart"] = folder:WaitForChild("DockExplodeFX")
    end

    -- Getting button input ready
    for _, v:Folder in CDFolder:GetChildren() do
        local CD:Model      = v[v.Name]
        local FXPart        = v.DockExplodeFX
        local button        = CD.Button:WaitForChild("Button")
        local SDButton      = CD.SelfDestructButton:WaitForChild("Button")
        if not button then return end

        -- Main button
        local DB = true -- Debounce
        button.ClickDetector.MouseClick:Connect(function()
            if DB then
                DB = false
                button.Switch:Play()
                CDEvent:FireServer("MainButton", CD.Name)
                CDC.buttonFX(CD)
                DB = true
            end
        end)

        -- Self destruct button
        local DB2 = true
        SDButton.ClickDetector.MouseClick:Connect(function()
            if DB2 then
                DB2 = false
                CDEvent:FireServer("SelfDestructButton", CD.Name)
                --CDC.explosionFX(FXPart)
                DB2 = true
            end
        end)
    end
end

function CDC.eventHandler(CDName:string, eventName:string, data:any?)
    -- Getting CDName model
    local CDModel = CDCache[CDName]["Model"]
    local dockFX  = CDCache[CDName]["FXPart"]
    if not CDModel and not dockFX then 
        warn("Could not find: ", CDName)
    end

    if eventName == "CDState" then
        CDC.buttonFX(CDModel)
        CDC.chargingFX(CDModel, dockFX, data)
    elseif eventName == "ChargingFX" then
        CDC.chargingFX(CDModel, dockFX, data)
    elseif eventName == "ExplosionFX" then
        CDC.explosionFX(dockFX)
    end
end

-- Button animation
function CDC.buttonFX(CD:Model)
    local button:BasePart = CD.Button.Button
    local goal = {CFrame = button.CFrame:ToWorldSpace(CFrame.new(0,0,0.1))}
    local tween = TweenService:Create(button,buttonTweenInfo,goal)

    tween:Play()
    tween.Completed:Wait()
end

function CDC.chargingFX(CD:Model, FXPart:BasePart, enabled:boolean)
    local chargeEffects = CD:FindFirstChild("ChargePos")
    local button = CD.Button:FindFirstChild("Button")
    if not chargeEffects and not button then return end

    -- Initializing charging light and turning it on
    local lightObj:PointLight = FXPart.PointLight
    lightObj.Color = CHARGE_LIGHT_COLOR
    lightObj.Range = CHARGE_LIGHT_RANGE
    lightObj.Enabled = enabled

    -- Changing the button color and light affect
    if enabled then
        button.Color = ACTIVE_BUTTON_COLOR
    else
        button.Color = DEACTIVE_BUTTON_COLOR
    end

    -- Emitting the particles
    for _, v:ParticleEmitter in chargeEffects:GetChildren() do
        if v:IsA("ParticleEmitter") then
            v.Enabled = enabled
        end
    end
end

function CDC.explosionFX(explopart:BasePart)
    local effects = explopart.Attachment
    local smoke = explopart.Smoke
    local SFX:Sound = explopart.ExplosionSFX

    -- Handle the SFX and VFX
    SFX:Play()
    for _, effect:ParticleEmitter in effects:GetChildren() do
        effect:Emit(1)
    end
    --smoke:Emit(30)

    -- Initializing charging light and turning it on
    local lightObj:PointLight = explopart.PointLight
    lightObj.Color = EXPLOSION_LIGHT_COLOR
    lightObj.Range = 0
    lightObj.Brightness = EXPLOSION_LIGHT_BRIGHTNESS
    lightObj.Enabled = true

    local tween = TweenService:Create(lightObj, EXPLOSION_TWEENINFO, {Range = EXPLOSION_LIGHT_RANGE})
    tween:Play()
    task.wait(EXPLOSION_LIGHT_DUR)
    lightObj.Enabled = false
end

return CDC