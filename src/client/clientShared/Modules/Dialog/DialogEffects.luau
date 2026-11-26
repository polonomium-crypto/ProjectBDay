-- [Services]
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local shared = {}

-- Screeen
local screenSize = Workspace.Camera.ViewportSize

-- Models
local NPCFolder = Workspace.NPC
local NPCModels = NPCFolder["NPC models"]

-- Math variables
local pi = math.pi

-- Misc
local targetNPCModel
local ogModelPosition

-- Wave related
local rotationMemory = 0                                -- rotational difference for each letter for the wave function. (So that its not reliant on time)
-------------------------------------------------------------------------------------------------
-- [Changabel variables] --------------------------------------------------------------------------
local COLORS = {
    red   = Color3.fromRGB(255, 0, 0),
    blue  = Color3.fromRGB(0,0,255),
    green = Color3.fromRGB(0,255,0),
    white = Color3.fromRGB(255,255,255),
    black = Color3.fromRGB(0,0,0),
    grey  = Color3.fromRGB(133, 133, 133)
}

-- Function/Method priority list
shared.priorities = {                                   -- Lower the number the more higher the priority is
    size = 1,
    scaleSize = 2,
    typewriterFadeFall = 1000
}

-- Default parameters
local DEFAULT_TEXT_SCALE = 0.4                          -- Make sure to change this in "Dialog" aswell.
local TEXT_HORIZONTAL_OFFSET = 4                        -- Pixels

-- Shake variables
local SHAKE_AGGRESSIVENESS = 1.3

-- Wave variables
local WAVE_FREQUENCY = 0.7                              -- How long it will take to do 1 rotation
local WAVE_AMPLITUDE = 3
local WAVE_ROTATION_DELTA = pi/8                        -- The amount of rotation each letter offsets by

-- Tween variables
local FALL_DURATION = 0.1
local FALL_SCALE_DIST = 0.15
local FADE_DURATION = 0.4

local ENLARGE_DURATION = 0.5
local ENLARGE_SCALE = 0.2

-- Model variables
local UP_DIST = 0.15                                    -- The distance the model go up when they are in dialog
-------------------------------------------------------------------------------------------------

function shared.shake(letter:TextLabel)
    if letter == " " then -- There is no point int animating space.
        return
    end

    local timePassed = 0
    local ogPosition = letter.Position
    local shakeThread:thread

    local function shake()
        local waveStep = RunService.RenderStepped:Connect(function(deltaTime:number)
            letter.Position = ogPosition + UDim2.fromOffset(math.random(-SHAKE_AGGRESSIVENESS, SHAKE_AGGRESSIVENESS), math.random(-SHAKE_AGGRESSIVENESS, SHAKE_AGGRESSIVENESS))
            timePassed += deltaTime
        end)
        
        letter.Destroying:Connect(function()
            waveStep:Disconnect()
            coroutine.close(shakeThread)
        end)
    end
    
    shakeThread = coroutine.create(shake)
    coroutine.resume(shakeThread)
end

function shared.wave(letter:TextLabel)
    if letter == " " then -- There is no point int animating space.
        return
    end

    local timePassed = 0
    local ogPosition = letter.Position
    local waveThread:thread

    local function wave()
        local rotDelta = rotationMemory
        local waveStep = RunService.RenderStepped:Connect(function(deltaTime:number)
            local rad = 2*pi*(timePassed/WAVE_FREQUENCY) - rotDelta
            letter.Position = ogPosition + UDim2.fromOffset(WAVE_AMPLITUDE * math.cos(rad), WAVE_AMPLITUDE * math.sin(rad))
            timePassed += deltaTime

            if timePassed >= WAVE_FREQUENCY then
                timePassed -= WAVE_FREQUENCY
            end
        end)

        letter.Destroying:Connect(function()
            waveStep:Disconnect()
            coroutine.close(waveThread)
        end)
    end

    waveThread = coroutine.create(wave)
    coroutine.resume(waveThread)

    -- Handling rotational delta
    rotationMemory += WAVE_ROTATION_DELTA
    if rotationMemory >= 2*pi then
        rotationMemory -= 2*pi
    end
end

-- Changes the color of the letter
function shared.color(letter:TextLabel, color)
    letter.TextColor3 = COLORS[color]
end

function shared.font(letter:TextLabel, attribute)
    letter.Font = Enum.Font[attribute]
end

function shared.stroke(letter:TextLabel, color:string?) -- color in Hex
    local stroke:UIStroke = letter.UIStroke
    local finalColor = "#000000"

    if color ~= "nil" then
        finalColor = color
    end

    if stroke then
        stroke.Enabled = true
        stroke.Color = Color3.fromHex(finalColor)
    else
        error("This letter does not have a UIStroke.")
    end
end

-- Pauses printing text for a specified amount of time
function shared.pause(letter:TextLabel, duration:string)
    return tonumber(duration)
end

-- enlarge appearance animation for when typewriting
function shared.typewriterEnlarge(letter:TextLabel)
    -- Initial variables
    local ogTextSize = letter.TextSize
    
    -- Init
    letter.TextTransparency = 1
    letter.TextSize = letter.TextSize * ENLARGE_SCALE
    print(ogTextSize, letter.TextSize)
    -- Preparing fall tween
    local enlargeTweenInfo = TweenInfo.new(ENLARGE_DURATION, Enum.EasingStyle.Exponential)
    local enlargeGoal = {TextSize = ogTextSize}

    -- Preparing fade tween
    local fadeTweenInfo = TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Exponential)
    local fadeGoal = {TextTransparency = 0}

    task.spawn(function()
        TweenService:Create(letter, enlargeTweenInfo, enlargeGoal):Play()
        TweenService:Create(letter, fadeTweenInfo, fadeGoal):Play()
    end)
end

-- fade and fall animation for typewriting
function shared.typewriterFadeFall(letter:TextLabel)
    -- Initial variables
    local ogPosition = letter.Position

    -- Init
    letter.TextTransparency = 1
    letter.Position = letter.Position - UDim2.fromScale(0, FALL_SCALE_DIST)

    -- Preparing fall tween
    local fallTweenInfo = TweenInfo.new(FALL_DURATION, Enum.EasingStyle.Exponential)
    local fallGoal = {Position = ogPosition}

    -- Preparing fade tween
    local fadeTweenInfo = TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Exponential)
    local fadeGoal = {TextTransparency = 0}

    task.spawn(function()
        TweenService:Create(letter, fallTweenInfo, fallGoal):Play()
        TweenService:Create(letter, fadeTweenInfo, fadeGoal):Play()
    end)
end

-- Changes text size but it has a limit on how much it can change.
function shared.size(letter:TextLabel, TextScale:IntValue?, mediumSize)
    if mediumSize == nil then
        error("No medium was specified.")
    end
    if TextScale then
        letter.TextSize = mediumSize.Y * TextScale
    else
        letter.TextSize = mediumSize.Y * DEFAULT_TEXT_SCALE
    end
    letter.Size = UDim2.fromOffset(letter.TextBounds.X + TEXT_HORIZONTAL_OFFSET, letter.TextBounds.Y)
    --print(letter, letter.TextBounds.Y, letter.Size)
end

function shared.scaleSize(letter:TextLabel, TextScale:IntValue?, mediumSize:Vector2)
    -- Note that TextScale is the scale for the Y
    -- Getting ratio of X relative to Y
    letter.TextSize = 100
    letter.Size = UDim2.new(0,0,TextScale,0)
    local xOffset = (letter.TextBounds.X/letter.TextBounds.Y) * letter.AbsoluteSize.Y           -- Gets the pixel length of the X for the letter
    local xScale = xOffset/mediumSize.X                                                         -- Gets the x scale for the letter

    -- Scaling letters relative to the frame that the letter is in
    letter.Size = UDim2.fromScale(xScale, TextScale)
    letter.TextScaled = true
end

function shared:moveModelInit(nameOfNPC:string)
    -- Getting the model
    for _, model:Model in NPCModels:GetChildren() do
        if model.Name == nameOfNPC then
            targetNPCModel = model
            if model:IsA("Model") then
                ogModelPosition = model.PrimaryPart.CFrame
            else
                ogModelPosition = model.Position
            end
            return
        end
    end
end

function shared:moveModel(up:boolean)
    if targetNPCModel == nil then
        return
    end

    if up then
        if targetNPCModel:IsA("Model") then
            targetNPCModel:PivotTo(ogModelPosition * CFrame.new(Vector3.yAxis * UP_DIST))
        else
            targetNPCModel.Position += Vector3.yAxis * UP_DIST
        end
    else
        if targetNPCModel:IsA("Model") then
            targetNPCModel:PivotTo(ogModelPosition)
        else
            targetNPCModel.Position = ogModelPosition
        end
    end
end

function shared:cleanUpMoveModel()
    targetNPCModel = nil
    ogModelPosition = nil
end

return shared