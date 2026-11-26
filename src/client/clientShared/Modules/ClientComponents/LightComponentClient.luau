-- [Services]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- [General Variables] ------------------------------------------------------------------
local lcl = {}
local lightComponentClient = {}

-- Player related
local plr = Players.LocalPlayer
local chara = plr.Character or plr.CharacterAdded
local head = chara:FindFirstChild("Head")

-- GUI related
local hud = plr.PlayerGui.Hud
local batteryBar = hud["Battery Bar"]
local bar = batteryBar.Bar

-- Cam related
local cam = Workspace.CurrentCamera

-- Misc
local VM:Model
local light:SpotLight
local batteryDrain:RBXScriptConnection
-----------------------------------------------------------------------------------------
function lightComponentClient.init()
    -- Check whenever there is a light object on the head and delete it
    head.ChildAdded:Connect(function(child)
        if child:IsA("SpotLight") then
            child:Destroy()
        end
    end)
end

function lightComponentClient.OnEquip(obj:table)
    VM = cam:FindFirstChild("ViewModel")
    local attributes = obj.Attributes

    -- Showing UI
    lcl.batteryUI(obj, true)

    -- Check if spot light object is in cam or not
    if cam:FindFirstChild("LightBulb") then
        cam.LightBulb:Destroy()             -- Turning off the light
        if batteryDrain.Connected then      -- Stop battery from draining
            batteryDrain:Disconnect()
        end
    end

    -- Battery
    if VM and obj.Battery > 0 then
        light = VM.LightBulb:FindFirstChild("SpotLight")
        light.Brightness = attributes.Brightness
        light.Range = attributes.Range

        -- Start draining the battery
        if obj.Enabled then
            lcl.batteryDrain(obj)
        end

        -- If there is enough battery turn the item "ON"
        light.Enabled = obj.Enabled
    end
end

function lightComponentClient.OnActivate(obj:table)
    VM = cam:FindFirstChild("ViewModel")
    local attributes = obj.Attributes

    if VM then
        light = VM.LightBulb.SpotLight
        light.Brightness = attributes.Brightness
        light.Range = attributes.Range

        -- Check if the obj has enough battery or not
        if obj.Battery <= 0 then
            warn("No Battery")
            obj.Enabled = false
            light.Enabled = obj.Enabled
            return
        end

        -- If there is enough battery turn the item "ON"
        obj.Enabled = not obj.Enabled
        light.Enabled = obj.Enabled

        -- If the object is disbled there is no point checking using checker
        if obj.Enabled == false then
            return
        end

        -- Start draining the battery
        lcl.batteryDrain(obj)
    end
end

function lightComponentClient.OnUnequip(obj:table)
    if obj.Enabled then
        -- Showing UI
        lcl.batteryUI(obj, true)

        local lightBulb = Instance.new("Part")
        lightBulb.Name = "LightBulb"
        lightBulb.Size = Vector3.new(1,1,1)
        lightBulb.Transparency = 1
        lightBulb.CanCollide = false
        lightBulb.Anchored = true
        lightBulb.Parent = cam

        light = Instance.new("SpotLight")
        light.Parent = lightBulb

        local attributes = obj.Attributes

        light.Brightness = attributes.Brightness
        light.Range = attributes.Range
        light.Enabled = obj.Enabled

        -- Checking if the head light can still stay on or not
        local checker
        checker = RunService.RenderStepped:Connect(function()
            if not cam:FindFirstChild("LightBulb") then
                checker:Disconnect()
                return
            end
            if obj.Battery <= 0 then
                lightBulb:Destroy()
                checker:Disconnect()
                return
            end
            lightBulb.CFrame = cam.CFrame
        end)
    else
        lcl.batteryUI(obj, false)
    end
end

function lightComponentClient.OnDrop(obj:table)
    lcl.batteryUI(obj, false)
    if batteryDrain then
        batteryDrain:Disconnect()
    end
end

function lcl.batteryDrain(obj:table)
    batteryDrain = RunService.RenderStepped:Connect(function(deltaTime)
        if obj.Enabled == false then
            batteryDrain:Disconnect()
            return
        end

        if obj.Battery <= 0 then
            warn("Ran out of battery.")
            light.Enabled = false
            obj.Enabled = false
            batteryDrain:Disconnect()
            return
        else
            -- Changing UI
            local percentage = obj.Battery / obj.BatteryCap
            bar.Size = UDim2.fromScale(percentage, 1)

            -- Drain battery
            obj.Battery -= deltaTime
        end
    end)
end

function lcl.batteryUI(obj:table, visible:boolean)
    if visible then
        local percentage = obj.Battery / obj.BatteryCap
        bar.Size = UDim2.fromScale(percentage, 1)
        batteryBar.Visible = true
    else
        batteryBar.Visible = false
    end
end

return lightComponentClient