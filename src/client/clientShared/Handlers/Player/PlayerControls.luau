-- [Services]
local ContextActionService = game:GetService("ContextActionService")
local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- [Modules]

-- [Other scripts]
local plrInventoryClient = require(script.Parent.PlayerInventoryClient)
local plrStamina = require(script.Parent.PlayerStamina)
local commandMod = require(script.Parent.Parent.Commands.CommandHandlerClient)

-- [General Variables] --------------------------------------------------
local plrControls   = {}

local plr = players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid = char.Humanoid

-- State names
local stateTable         = {
    deadState          = "dead",
    inGameState        = "inGame"
}

-- Misc
local inputType
-------------------------------------------------------------------------

function plrControls.init()
    inputType = UserInputService.PreferredInput
    plrControls.updateState("inGame")       -- For testing purposes
end

function plrControls.keyBoardInput(actionName, inputState, _inputObject)
    -- General function
    if actionName == "General" then
        if inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.Slash then
            commandMod.openCommandLine()
        end
    end
    -- State specfic function
    if      actionName == stateTable.inGameState then
        if      inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.One then
            plrInventoryClient.equipFlipFlop(1)
        elseif  inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.Two then
            plrInventoryClient.equipFlipFlop(2)
        elseif  inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.Three then
            plrInventoryClient.equipFlipFlop(3)
        elseif  inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.Four then
            plrInventoryClient.equipFlipFlop(4)
        elseif  inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.Five then
            plrInventoryClient.equipFlipFlop(5)
        elseif  inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.Six then
            plrInventoryClient.equipFlipFlop(6)
        elseif  inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.Seven then
            plrInventoryClient.equipFlipFlop(7)
        elseif  inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.Eight then
            plrInventoryClient.equipFlipFlop(8)
        elseif  inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.Nine then
            plrInventoryClient.equipFlipFlop(9)
        elseif  inputState == Enum.UserInputState.End and _inputObject.KeyCode == Enum.KeyCode.Q then
            plrInventoryClient.dropItem()
        elseif inputState == Enum.UserInputState.Begin and _inputObject.KeyCode == Enum.KeyCode.LeftShift and plrStamina.canRun then
            plrStamina.runActive = true
        elseif inputState == Enum.UserInputState.End and _inputObject.KeyCode == Enum.KeyCode.LeftShift then
            plrStamina.runActive = false
        end
    elseif  actionName == stateTable.deadState then
    end
end

function plrControls.touchInput()
    
end

function plrControls.gamepadInput()
    
end

function plrControls.updateState(state:string)
    if      inputType == Enum.PreferredInput.Touch then
        print("Input type is touch.")
        plrControls.unbindAll()
        ContextActionService:BindAction(state, plrControls.touchInput, false)
    elseif  inputType == Enum.PreferredInput.KeyboardAndMouse then
        print("Input type is keyboard.")
        plrControls.unbindAll()
        ContextActionService:BindAction("General", plrControls.keyBoardInput, false, Enum.KeyCode.Slash)
        ContextActionService:BindAction(state, plrControls.keyBoardInput, false, Enum.KeyCode.LeftShift,Enum.KeyCode.Q ,Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,Enum.KeyCode.Five,Enum.KeyCode.Six,Enum.KeyCode.Seven,Enum.KeyCode.Eight,Enum.KeyCode.Nine)
    elseif  inputType == Enum.PreferredInput.Gamepad then
        print("Input type is gamepad.")
    end

    print("In game state", state)
end

-- This is to unbind game specific controls. Built in function of Unbind all will also remove the functionality of walking and such
function plrControls.unbindAll()
    for _, stateName in stateTable do
        ContextActionService:UnbindAction(stateName)
    end
end

return plrControls