-- [Services]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local shared = {}

-- Player
local plr = Players.LocalPlayer
local chara = plr.Character or plr.CharacterAdded:Wait()
-------------------------------------------------------------------------------------------------

function shared.invisPlayer(invisVal:number)
    local transparency = 0

    if invisVal then
        transparency = invisVal
    else
        transparency = 0
    end

    for _, instance in chara:GetDescendants() do
        if instance:IsA("BasePart") then
            if instance.Name == "HumanoidRootPart" then
                continue
            end

            TweenService:Create(instance, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Transparency = transparency}):Play()
        end
    end
end

return shared