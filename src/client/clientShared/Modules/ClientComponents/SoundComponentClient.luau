-- [Services]
local Workspace = game:GetService("Workspace")

-- [General Variables] ------------------------------------------------
local actSound = {}

-- Cam related
local cam = Workspace.CurrentCamera
-----------------------------------------------------------------------

function actSound.OnActivate(obj:table)
    local VM = cam:FindFirstChild("ViewModel")
    local sound:Sound

    if VM then
        sound = VM.Item.Sound
        sound.SoundId = obj.SFX
        sound:Play()
    end
end



return actSound