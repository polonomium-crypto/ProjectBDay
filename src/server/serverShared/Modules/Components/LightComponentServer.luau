-- [Services]
local RunService = game:GetService("RunService")

-- [General Variabels] ---------------------------------------------------------------
local lcl = {}
local lightCompServer = {}

-- Misc
local VM:Model
local light:SpotLight
local batteryDrain:RBXScriptConnection
--------------------------------------------------------------------------------------
function lightCompServer.OnEquip(plr:Player, obj:table)
    local chara = plr.Character or plr.CharacterAdded:Wait()
    local head = chara:FindFirstChild("Head")
    VM = chara:FindFirstChild("ViewModel")
    local attributes = obj.Attributes

    -- Checking if the spotlight object is in head, if there is destroy and turn battery drain off.
    if head:FindFirstChild("SpotLight") then
        head.SpotLight:Destroy()
        if batteryDrain.Connected then
            batteryDrain:Disconnect()
        end
    end

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


function lightCompServer.OnActivate(plr:Player, obj:table)
    local chara = plr.Character or plr.CharacterAdded:Wait()
    VM = chara:FindFirstChild("ViewModel")
    local attributes = obj.Attributes

    if VM then
        light = VM.LightBulb:FindFirstChild("SpotLight")
        light.Brightness = attributes.Brightness
        light.Range = attributes.Range

        -- Check if the obj has enough battery or not
        if obj.Battery <= 0 then
            light.Enabled = false
            obj.Enabled = false
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

function lightCompServer.OnUnequip(plr:Player, obj:table)
    if obj.Enabled then
        local chara = plr.Character or plr.CharacterAdded:Wait()
        local head = chara:FindFirstChild("Head")

        if not head then return end

        light = Instance.new("SpotLight")
        light.Parent = head

        local attributes = obj.Attributes

        light.Brightness = attributes.Brightness
        light.Range = attributes.Range
        light.Enabled = obj.Enabled
    end
end

function lightCompServer.OnDrop(plr:Player, obj:table)
    if batteryDrain then
        batteryDrain:Disconnect()
    end
end

function lcl.batteryDrain(obj:table)
    -- Start draining the battery
    batteryDrain = RunService.Heartbeat:Connect(function(deltaTime)
        if obj.Enabled == false then
            batteryDrain:Disconnect()
        end
        if obj.Battery <= 0 then    -- Check if battery is out
            obj.Enabled = false
            light.Enabled = obj.Enabled
            batteryDrain:Disconnect()
            return
        else
            obj.Battery -= deltaTime
        end
    end)
end

return lightCompServer