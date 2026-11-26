-- [Services]
local StarterGui = game:GetService("StarterGui")

-- [General Variables] -------------------------------------------------------------------
local lcl = {}
------------------------------------------------------------------------------------------

function  lcl:loadInFirst()
    while game:IsLoaded() do
        task.wait()
    end

    local blackscreen = StarterGui:WaitForChild("BlackScreen"):WaitForChild("BlackScreen")

    blackscreen.Visible = true
    blackscreen.BackgroundTransparency = 0
end