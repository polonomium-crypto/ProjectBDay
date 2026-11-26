-- [Services]


-- [General Variables] ----------------------------------------------------------------------------------------
local lcl = {}
---------------------------------------------------------------------------------------------------------------

function lcl.initializeModules()
    for _, instance in script:GetDescendants() do
        if instance:IsA("ModuleScript") then
            local mod:ModuleScript
            local success, errorMessage = pcall(function()
                mod = require(instance)
            end)
            if not success then -- Print a error message and continue the requiring the modules
                warn(errorMessage,": ", instance)
                continue
            end

            -- Checking if mod is a array or not.
            if typeof(mod) ~= "table" then
                warn(instance, " is not the type 'table'.")
            end

            -- Init mod if it has a "init" method/function element
            if mod.init then
                task.spawn(function()
                    mod.init()
                end)
            end
        end
    end
end

lcl.initializeModules()