-- [Services]


-- [General Variables] ----------------------------------------------------------------------------------------
local lcl = {}
---------------------------------------------------------------------------------------------------------------

function lcl.initializeModules()
    for _, instance in script:GetDescendants() do
        if instance:IsA("ModuleScript") then
            local mod
            local success, errorMessage = pcall(function()
                mod = require(instance)
            end)
            if not success then -- Print a error message and continue the requiring the modules
                warn(errorMessage)
                continue
            end
            
            if mod.init then
                task.spawn(function()
                    mod.init()
                end)
            end
        end
    end
end

lcl.initializeModules()