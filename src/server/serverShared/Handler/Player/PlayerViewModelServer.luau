-- [Services]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- [General Vasriables] -------------------------------------------------------------
local lcl = {}
local plrVMServer = {}

-- Events
local VMEvent = ReplicatedStorage.Events.ViewModelEvent

-- Misc
local connection
-------------------------------------------------------------------------------------

function lcl.VMPlrSkin(plr, VM)
    local chara = plr.Character or plr.CharacterAdded:Wait()
    local plrSkin = chara:FindFirstChild("Shirt")
    local plrHead = chara:FindFirstChild("Head")

    lcl.changeArmTransp(plr, 1)

    if plrHead and VM:FindFirstChild("Left Arm") then
        VM["Left Arm"].Color = plrHead.Color
    end

    if plrHead and VM:FindFirstChild("Right Arm") then
        VM["Right Arm"].Color = plrHead.Color
    end

    if plrSkin then
        VM.Shirt.ShirtTemplate = plrSkin.ShirtTemplate
    end
end

function lcl.changeArmTransp(plr:Player, Transparency:IntValue)
    local chara = plr.Character or plr.CharacterAdded:Wait()
    local LArm = chara:FindFirstChild("Left Arm")
    local RArm = chara:FindFirstChild("Right Arm")

    if LArm then
        LArm.Transparency = Transparency
    end

    if RArm then
        RArm.Transparency = Transparency
    end
end

VMEvent.OnServerEvent:Connect(function(plr:Player, viewModel:Model, equipped:boolean)
    local chara = plr.Character or plr.CharacterAdded:Wait()
    if equipped then

        -- Disconnecting heartbeat when there is one running
        if connection then
            connection:Disconnect()
        end

        -- Deleting viewmodel if there are any
        if chara:FindFirstChild("ViewModel") then
            chara:FindFirstChild("ViewModel"):Destroy()
        end

        local VM = viewModel:Clone()
        local head = chara:FindFirstChild("Head")
        VM.Name = "ViewModel"
        VM.Parent = chara
        lcl.VMPlrSkin(plr, VM)

        if head and VM then
            connection = RunService.Heartbeat:Connect(function()
                VM:PivotTo(head.CFrame)
            end)
        end
    else
        if chara:FindFirstChild("ViewModel") then
            chara:FindFirstChild("ViewModel"):Destroy()
        end

        lcl.changeArmTransp(plr, 0)
    end
end)


return plrVMServer