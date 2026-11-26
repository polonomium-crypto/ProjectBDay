-- [Services]
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- [Modules]

-- [General Variables] -----------------------------------------------------
local lcl = {}
local commandModClient = {}

-- Events
local commandEvent = ReplicatedStorage.Events.CommandEvent

-- Player related
local plr = Players.LocalPlayer

-- GUI related
local plrGUI = plr.PlayerGui
local adminGUI = plrGUI.AdminGUI
local messageTemplate = adminGUI.Template.MessageTemplate
local frame = adminGUI.Frame
local messages = frame.Messages
local inputBox:TextBox = frame.InputBox

-- Misc
local inCommandLine = false
----------------------------------------------------------------------------

function commandModClient.init()
    -- Detecting a enter(Although other buttons would be "Enter" aswell, soooo fix it in the future)
    inputBox.FocusLost:Connect(commandModClient.inputEnter)
end

-- Enter function. Function that is activated when the command line is active.
function commandModClient.openCommandLine()
    -- Making sure all the GUI elements are visible
    adminGUI.Enabled = true

    -- Making sure player is focused on the textbox
    inputBox:CaptureFocus()
end

function commandModClient.inputEnter()
    -- Get input string from the inputBox
    local inputString = inputBox.Text

    -- Parsing input
    commandModClient.processInput(inputString)
end

-- Input function that sends said command to the server.
--[[]
function commandModClient.inputEnter(actionName, inputState, _inputObject)
    if actionName == "Input" then
        if inputState == Enum.UserInputState.Begin and (_inputObject.KeyCode == Enum.KeyCode.KeypadEnter or _inputObject.KeyCode == Enum.KeyCode.Return) then
            print("enter is pressed.")
            -- Get input string from the inputBox
            local inputString = inputBox.Text

            -- Parsing input
            commandModClient.processInput(inputString)
        end
    end
end
]]

-- Close function. Function that closes the command line.
function commandModClient.closeCommandLine()
    -- Making sure all the GUI elements are visible
    adminGUI.Enabled = false

    -- Unbind enter key
    ContextActionService:UnbindAction("Input")
end

-- Handles massages
function commandModClient.handleMessage(message:string, color:Color3?)
    local text = messageTemplate:Clone()
    text.Visible = true
    text.Parent = messages
    text.Text = message
    text.TextColor3 = color or Color3.fromRGB(0,0,0)
end

function commandModClient.processInput(input:string)

    -- First getting what command it is. (e.g. tp, give, giveTo, etc)
    local command = string.match(input, "/(%a+)")

    if commandModClient[command] then
        commandModClient[command](input)
    else
        local message = "No command " .. '"' .. tostring(command) .. '"'
        commandModClient.handleMessage(message, Color3.fromRGB(255,0,0))
    end
end

-- Giving pickUp to player. item, quantity
function commandModClient.give(input:string)
    local pattern = "/%a+%s(%a+)%s(%d+)"
    local pattern2 = "/%a+%s(%a+)"
    local item, quantity

    -- Checking pattern1
    item, quantity = string.match(input, pattern)
    if item == nil and quantity == nil then
        item = string.match(input, pattern2)
    end

    local message
    quantity = tonumber(quantity)

    if item then
        -- Calling a event to see if the player is able to execute the command or not
        local data = {item, quantity}
        local success = commandEvent:InvokeServer("give", data)

        -- Handling the message sending
        if success and quantity then
            message = "Giving " .. quantity .. " " .. item .. " to " .. plr.Name
            commandModClient.handleMessage(message)
        elseif success then
            message = "Giving " .. " " .. item .. " to " .. plr.Name
            commandModClient.handleMessage(message)
        else
            message = "Not successful or player not permitted to use commands."
            commandModClient.handleMessage(message, Color3.fromRGB(255,0,0))
        end
    else
            message = "Item and or quantity was not specified."
            commandModClient.handleMessage(message, Color3.fromRGB(255,0,0))
    end
end

function commandModClient.changeData(input:string)
    local pattern = "/%a+%s(%d+)%s(%a+)%s(.+)"
    local pattern2 = "/%a+%s(-%d+)%s(%a+)%s(.+)"
    local userId, dataName, cData
    local message

    -- Checking patterns
    userId, dataName, cData = string.match(input, pattern)
    if userId == nil then
        userId, dataName, cData = string.match(input, pattern2)
    end

    if userId and dataName and cData then
        local data = {userId, dataName, cData}
        local success = commandEvent:InvokeServer("changeData", data)

        if success then
            message = "Successful at changing  " .. userId .. "'s " .. dataName .. " to " .. cData
            commandModClient.handleMessage(message)
        else
            message = "Was not able to change " .. userId .. "'s " .. dataName .. " to " .. cData
            commandModClient.handleMessage(message, Color3.fromRGB(255,0,0))
        end
    end
end

-- Gives info about commands
function commandModClient.help()
    commandModClient.handleMessage("'/give (Item) (quantity)'")
    commandModClient.handleMessage("'/tp (location)'")
    commandModClient.handleMessage("'/changeData (UserId) (dataName) (cData)'")
end

-- Leaving the command line
function commandModClient.exit()
    commandModClient.closeCommandLine()
end

-- Teleport player to position
function commandModClient.tp()
    print("Teleporting player.")
end

function commandModClient.test()
    commandEvent:InvokeServer("test")
end

return commandModClient