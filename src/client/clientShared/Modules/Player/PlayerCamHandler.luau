-- [Services]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- [Modules]
local plrVarMod = require(script.Parent.PlayerVariables)

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local camMod = {} -- pH = PlayerHandler

-- Player
local plr = Players.LocalPlayer
local chara = plr.Character or plr.CharacterAdded:Wait()
local primaryPart = chara.PrimaryPart
local humanoid = chara.Humanoid

-- Cam
local cam = workspace.CurrentCamera
local camState = plrVarMod.camStates.HEAD_BOB -- default val
local tiltX = 0
local decayXOffset = 0
local decayYOffset = 0

-- Time variables
local eTime = 0

-- Player changable variables (Might not be changable)
local headBobIsActive = true

-- State
local stateCache = nil

-- Math Variables
local pi = math.pi
-------------------------------------------------------------------------------------------------
-- [Changable variables] --------------------------------------------------------------------------
-- Default cam variables
local DEFAULT_CAM_FOV = plrVarMod.FOV

-- Camera state names
local HEAD_BOB = plrVarMod.camStates.HEAD_BOB
local IN_DIALOGUE = plrVarMod.camStates.IN_DIALOGUE
local STATE_TRANSITION = plrVarMod.camStates.STATE_TRANSITION

-- Player variables
local PLAYER_WALKSPEED = plrVarMod.WALKSPEED
local PLAYER_JUMP_POWER = plrVarMod.JUMP_POWER

-- Cam shake variables
local CAM_SHAKE_AMPLITUDE_Y = 0.15
local CAM_SHAKE_AMPLITUDE_X = 0.15
local CAM_SHAKE_FREQUENCY = 0.7 -- The larger the number the slower it is
local CAM_SHAKE_DECAY = 25
local CAM_ROTATE_ANGLE = math.rad(70) -- The max amount the cam can tilt
local TILT_DECAY = 170 -- Default 170
local TILT_AMOUNT = 100 -- The higher the number the less it would tilt.
local CAM_ZOOM_AMOUNT = 5 -- The higher the number the more it will zoom
local ZOOM_DECAY = 90
-------------------------------------------------------------------------------------------------

function camMod:Initialize()
    cam.FieldOfView = DEFAULT_CAM_FOV
end

local function decayLerp(a, b, rate, dt)
    return a + (b - a) * math.exp(-rate*dt)
end

function camMod:camStateManager()
    task.spawn(function()
        RunService.RenderStepped:Connect(function(deltaTime)
            if camState == STATE_TRANSITION then
                camMod:transitionState(deltaTime)
            elseif camState == HEAD_BOB then
                camMod:headBob(deltaTime)
            elseif camState == IN_DIALOGUE then

            end
        end)
    end)
end

function camMod:camStateChanger(state:string)
    camState = STATE_TRANSITION
    stateCache = state -- This exists because we need to smoothly reset our camera back its orignal properties

    -- Reseting specific variables
    eTime = 0
end

function camMod:transitionState(deltaTime)
    -- Resetting the cameras state
    if not (decayXOffset <= 0.01 or decayYOffset <= 0.01 or tiltX <= 0.01) then -- used 0.01 because exponential does not reach 0
        -- Changing the cam positions back to its original state
        decayXOffset = decayLerp(decayXOffset, 0, CAM_SHAKE_DECAY, deltaTime)
        decayYOffset = decayLerp(decayYOffset, 0, CAM_SHAKE_DECAY, deltaTime)
        tiltX = decayLerp(tiltX, 0, TILT_DECAY, deltaTime)
        cam.CFrame = cam.CFrame
            * CFrame.new(decayXOffset,decayYOffset,0)
            * CFrame.Angles(0,0,tiltX)
    else
        -- Changing the state once the resetting is over
        if stateCache ~= nil then
            camState = stateCache
            stateCache = nil
            decayXOffset = 0
            decayYOffset = 0
            tiltX = 0
        else
            warn("StateCache was not specified.")
        end
    end
end

function camMod:headBob(deltaTime)
    if headBobIsActive then
        local plrLookVector = cam.CFrame.LookVector
        local plrVelocity = primaryPart.AssemblyLinearVelocity -- Gets plrs velocity: Vector3
        local plrSpeed = plrVelocity.Magnitude
        local mouseDelta = UserInputService:GetMouseDelta()
        
        -- Changing FOV when player is moving
        local cosFOV = plrVelocity:Dot(plrLookVector)/plrSpeed
        local forwardVelocity = plrVelocity * cosFOV
        local forwardSpeed = forwardVelocity.Magnitude
        local zoomGoal

        if math.deg(cosFOV) > 0 then -- Only changes the FOV if the player is moving in the direction they are looking at. If the player is moving diogonally forawrd it will scale accordingly.
            zoomGoal = DEFAULT_CAM_FOV - (CAM_ZOOM_AMOUNT * (forwardSpeed/PLAYER_WALKSPEED))
        else
            zoomGoal = DEFAULT_CAM_FOV
        end
        cam.FieldOfView = decayLerp(cam.FieldOfView, zoomGoal, ZOOM_DECAY, deltaTime)

        -- Getting the rotation values
        local x = mouseDelta.X / TILT_AMOUNT
        tiltX = decayLerp(tiltX, x, TILT_DECAY, deltaTime)

        -- Camera offsets
        local xOffset
        local yOffset
        local zRot = math.clamp(tiltX, -CAM_ROTATE_ANGLE, CAM_ROTATE_ANGLE)

        -- Walk bobbing. Check if player is on the ground or not otherwise the walking does not make any sense
        --local jumpCos = plrVelocity:Dot(Vector3.yAxis)/plrSpeed
        --local jumpAngle = math.deg(math.acos(jumpCos))
        --if isJumping or (jumpAngle <= 30 or jumpAngle >= 150) then
        if humanoid:GetState() == Enum.HumanoidStateType.Running then
            -- Player is on the ground
            xOffset = CAM_SHAKE_AMPLITUDE_X * math.cos(2*pi * (eTime/CAM_SHAKE_FREQUENCY)) * (plrSpeed/PLAYER_WALKSPEED)
            yOffset = CAM_SHAKE_AMPLITUDE_Y * math.abs(math.sin(2*pi * (eTime/CAM_SHAKE_FREQUENCY))) * (plrSpeed/PLAYER_WALKSPEED)
        else
            -- Player is off the ground (JUMPING)
            xOffset = 0
            yOffset = 0
        end

        -- Positioning the camera
        decayXOffset = decayLerp(decayXOffset, xOffset, CAM_SHAKE_DECAY, deltaTime)
        decayYOffset = decayLerp(decayYOffset, yOffset, CAM_SHAKE_DECAY, deltaTime)
        cam.CFrame = cam.CFrame
            * CFrame.new(decayXOffset,decayYOffset,0)
            --* CFrame.Angles(0,0,zRot)
        
        eTime += deltaTime
        if eTime >= CAM_SHAKE_FREQUENCY then
            eTime -= CAM_SHAKE_FREQUENCY
        end
    end
end

function camMod:inDialog()
    -- Does not do anything lol (For now)    
end

return camMod