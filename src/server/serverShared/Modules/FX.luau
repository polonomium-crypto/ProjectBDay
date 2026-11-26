-- [Service]
local ServerStorage = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")

-- [General Variables] -------------------------------------------------------------------------
local FX = {}

local FXFolder = ServerStorage.FX
local lightingFolder = FXFolder.Lighting
------------------------------------------------------------------------------------------------
-- [Changable Variables] -------------------------------------------------------------------------
local DEFAULT_EXPOSURE = 3
------------------------------------------------------------------------------------------------

function FX.scaryLighting()
    --[[
    -- Putting lighting FX into lighting service
    for _, fx in lightingFolder:GetChildren() do
        fx.Parent = Lighting
    end

    -- Setting up lighting properties
    Lighting.Brightness = 0
    Lighting.ExposureCompensation = DEFAULT_EXPOSURE
    Lighting.Ambient = Color3.fromRGB(0,0,0)
    Lighting.ClockTime = 0]]
end

return FX