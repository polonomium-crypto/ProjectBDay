-- [Services]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- [Modules]
local moduleFolder = script.Parent.Parent.Parent.Modules
local plrVarMod = require(moduleFolder.Player.PlayerVariables)

-- [General variables] --------------------------------------------------------------------------
local lcl = {}
local plrStamina = {
    runActive = false,
    canRun = true,
    value = plrVarMod.RUN_DUR
}

-- Player
local plr = Players.LocalPlayer
local chara = plr.Character or plr.CharacterAdded:Wait()
local humanoid = chara.Humanoid
local HRP = chara.HumanoidRootPart

-- UI
local playerGui = plr.PlayerGui
local hud = playerGui.Hud
local bar = hud["Stamina Bar"].Bar

-- Math
local xVel
local zVel
local XZMagnitude

-------------------------------------------------------------------------------------------------
function plrStamina.init()
    plrStamina:checker()
end

function plrStamina:checker()
    task.spawn(function()
        RunService.Heartbeat:Connect(function(deltaTime)
            if plrStamina.runActive and lcl.isMoving() then
                lcl.run()

                -- Depleting the stamina bar
                plrStamina.value -= deltaTime
                plrStamina.value = math.clamp(plrStamina.value, 0, plrVarMod.RUN_DUR)
                
                -- Checking if plr is able to run or not
                if plrStamina.value <= 0 then
                    lcl.walk()
                end

                -- Dealing with stamina bar
                lcl.handleBar()
            else
                lcl.walk()

                -- Replenishing stamina
                plrStamina.value += deltaTime
                plrStamina.value = math.clamp(plrStamina.value, 0, plrVarMod.RUN_DUR)
                -- Dealing with stamina bar
                lcl.handleBar()
            end
        end)
    end)
end

function lcl.run()
    humanoid.WalkSpeed = plrVarMod.RUN_SPEED
end

function lcl.walk()
    humanoid.WalkSpeed = plrVarMod.WALKSPEED
end

function lcl.isMoving()
    xVel = HRP.AssemblyLinearVelocity.X
    zVel = HRP.AssemblyLinearVelocity.Z
    XZMagnitude = math.sqrt(xVel^2 + zVel^2)

    if XZMagnitude <= 0.5 then
        return false
    else
        return true
    end
end

function lcl.handleBar()
    local staminaRatio

    -- Getting the ratio of player stamina
    staminaRatio = plrStamina.value / plrVarMod.RUN_DUR
    bar.Size = UDim2.fromScale(staminaRatio, 1)
end

return plrStamina