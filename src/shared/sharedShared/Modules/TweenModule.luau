--Services
local TweenService = game:GetService("TweenService")

local TM = {}

--Function that deals with when the  mouse enters the button
function TM.EnterButton(Button: GuiButton)
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Exponential)
	local goal = {Size = Button.Size + UDim2.new(0.01,0,0.01,0)}
	
	TweenService:Create(Button, tweenInfo, goal):Play()
end

--Function that deals with when the mouse leaves the button
function TM.LeaveButton(Button: GuiButton)
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Exponential)
	local goal = {Size = Button.Size - UDim2.new(0.01,0,0.01,0)}

	TweenService:Create(Button, tweenInfo, goal):Play()
end

function TM.FadeFrame(Frame: Frame, duration: number, visible: boolean)
	local transparency: IntValue
	if visible then
		transparency = 0
		Frame.Visible = true
	else
		transparency = 1
	end

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local goal = {BackgroundTransparency = transparency}

	local tween = TweenService:Create(Frame, tweenInfo, goal)
	tween:Play()

	if visible == false then
		tween.Completed:Wait()
		Frame.Visible = false
	end
end

function TM.FadeText(Text: TextLabel, duration: number, visible: boolean)
	local transparency: IntValue
	if visible then
		transparency = 0
		Text.Visible = true
	else
		transparency = 1
	end
	
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local goal = {TextTransparency = transparency}
	
	local tween = TweenService:Create(Text, tweenInfo, goal)
	tween:Play()
	
	if visible == false then
		coroutine.wrap(function()
			tween.Completed:Wait()
			Text.Visible = false
			coroutine.yield()
		end)
	end
end

return TM
