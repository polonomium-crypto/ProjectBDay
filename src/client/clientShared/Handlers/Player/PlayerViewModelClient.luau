-- [Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- [General Vasriables] -------------------------------------------------------------
local lcl = {}
local plrVM = {}

-- Events
local VMEvent = ReplicatedStorage.Events.ViewModelEvent

-- Player related
local plr = Players.LocalPlayer
local chara = plr.Character or plr.CharacterAdded:Wait()
local HRP = chara:WaitForChild("HumanoidRootPart")

-- cam
local cam = Workspace.Camera

-- ViewModel
local VM:Model

-- Misc variables
local equipped = false
local swayCF = CFrame.new()
local lastCamCF = CFrame.new()
-------------------------------------------------------------------------------------
-- [General Vasriables] -------------------------------------------------------------
-- Sway changables
local SWAY_AMOUNT = 0.6

-- Bobbing changables
local PERIOD = 0.5
local RADIUS = 0.2
-------------------------------------------------------------------------------------

function plrVM.handleViewModel(viewModel:Model)
    -- Check if there is a view model active or not
    if VM then
        equipped = false
        VM:Destroy()
    end

    -- Creating a new view model appropriate to it
    if not viewModel then
        warn("Item does not have a viewmodel.")
        return
    end
    VM = viewModel:Clone()
    VM.Parent = cam
    VM.Name = "ViewModel"

    -- Copying players skin
    lcl.VMPlrSkin()

    -- Replicate in server
    equipped = true
    VMEvent:FireServer(viewModel, equipped)
end

function plrVM.removeVM()
    if VM then
        equipped = false
        VMEvent:FireServer(nil, equipped)
        VM:Destroy()
    end
end

function lcl.VMPlrSkin()
    local plrSkin = chara:FindFirstChild("Shirt")
    local plrHead = chara:FindFirstChild("Head")

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

-- Constantly update viewModel
local bobTime = 0
RunService.RenderStepped:Connect(function(deltaTime)
    if not equipped then return end

    if chara.Humanoid.Health <= 0 then
        equipped = false
        return
    end

    -- Viewmodel sway Cframe offset
    local rot = cam.CFrame:ToObjectSpace(lastCamCF)
    local X, Y = rot:ToOrientation()
    swayCF = swayCF:Lerp(CFrame.Angles(math.sin(X) * SWAY_AMOUNT, math.sin(Y) * SWAY_AMOUNT, 0), 0.1) -- Sway

    -- Viewmodel bobbing CFrame offset
    local bobCF = CFrame.new()
    print(HRP.AssemblyLinearVelocity.Magnitude)
    if HRP.AssemblyLinearVelocity.Magnitude >= 0.1 then
        local currentRad = 2*math.pi * bobTime/PERIOD
        local YBob = math.abs(math.sin(currentRad))
        local XBob = math.cos(currentRad)
        bobCF = CFrame.new(XBob, YBob, 0)
        if bobTime >= PERIOD then
            bobTime = 0
        else
            bobTime += deltaTime
        end
    end

    -- Positioning viewmodel
    lastCamCF = cam.CFrame
    VM:PivotTo(cam.CFrame * swayCF )

    -- Deleting the viewmodel that is replicated on the server side
    if chara:FindFirstChild("ViewModel") then
        chara:FindFirstChild("ViewModel"):Destroy()
    end
end)

return plrVM