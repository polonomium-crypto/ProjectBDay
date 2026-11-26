-- [Services]

-- [General Variables] ------------------------------------------------
local actSound = {}
-----------------------------------------------------------------------

function actSound.OnActivate(plr:Player, obj:table)
    local chara = plr.Character or plr.CharacterAdded:Wait()
    local VM = chara:FindFirstChild("ViewModel")
    local sound:Sound

    if VM then
        sound = VM.Item.Sound
        sound.SoundId = obj.SFX
        sound:Play()
    end
end



return actSound