-- [Services]
local StarterGui = game:GetService("StarterGui")

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local shared = {}
-------------------------------------------------------------------------------------------------

function shared:init()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
end

return shared