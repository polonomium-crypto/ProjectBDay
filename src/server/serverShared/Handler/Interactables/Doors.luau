-- [Services]
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- [General Variables] -----------------------------------------------------------------
local doorMod = {}
doorMod.__index = doorMod

local doorsFolder = Workspace.Interactables.Doors
----------------------------------------------------------------------------------------
-- [Changable Variables] -----------------------------------------------------------------
local HOLD_DURATION                 = 0.3
local MAX_ACTIVATION_DISTANCE       = 5
local TWEEN_INFO                    = TweenInfo.new(0.6)
----------------------------------------------------------------------------------------

function doorMod.new(model:Model, parent, position:CFrame)
    local self = setmetatable({}, doorMod)

    self.Name               = model.Name
    self.Model              = model:Clone()
    self.Model.Parent       = parent or doorsFolder
    self.open               = false
    
    -- Preparing the proximity prompt
    self.ProximityPrompt    =self.Model.Board.DoorNob.PrimaryPart:FindFirstChild("ProximityPrompt")

    -- Checking if proximity prompt exists inside the door
    if self.ProximityPrompt == nil then
        warn("Could not find proximity prompt for door.")
        return
    end

    -- Initializing the proximity prompt
    self.ProximityPrompt.HoldDuration = HOLD_DURATION
    self.ProximityPrompt.MaxActivationDistance = MAX_ACTIVATION_DISTANCE
    self.ProximityPrompt.RequiresLineOfSight = false

    -- Position door
    self.Model:PivotTo(position)

    -- Initializing door animation
    local hinge:BasePart    = self.Model.Hinge
    local openState         = {}
    local closeState        = {}
    openState.CFrame        = hinge.CFrame * CFrame.Angles(0,math.rad(-90),0)
    closeState.CFrame       = hinge.CFrame * CFrame.Angles(0,0,0)
    self.openAnim           = TweenService:Create(hinge, TWEEN_INFO, openState)
    self.closeAnim          = TweenService:Create(hinge, TWEEN_INFO, closeState)

    -- Proximity prompt activation function
    self.ProximityPrompt.Triggered:Connect(function()
        self:openClose()
    end)

    return self
end

function doorMod:openClose()
    if self.open then
        -- Closing door
        self.open = false
        -- Maing sure every basepart can't be collided with
        for _, part:BasePart in self.Model.Board:GetDescendants() do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        self.closeAnim:Play()
    else
        -- Opening door
        self.open = true
        -- Maing sure every basepart can be collided with
        for _, part:BasePart in self.Model.Board:GetDescendants() do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        self.openAnim:Play()
    end
end

return doorMod