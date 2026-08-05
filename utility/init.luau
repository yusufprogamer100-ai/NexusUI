local Utility = {}

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

Utility.HttpService = HttpService
Utility.TweenService = TweenService
Utility.RunService = RunService
Utility.UserInputService = UserInputService
Utility.Players = Players
Utility.LocalPlayer = Players.LocalPlayer

function Utility.Create(className, properties, parent)
	local instance = Instance.new(className)
	if properties then
		for property, value in properties do
			if property ~= "Parent" then
				instance[property] = value
			end
		end
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

function Utility.Tween(instance, info, goals, play)
	local tween = TweenService:Create(instance, info, goals)
	if play ~= false then
		tween:Play()
	end
	return tween
end

function Utility.TweenInfo(duration, style, direction)
	return TweenInfo.new(
		duration or 0.35,
		style or Enum.EasingStyle.Exponential,
		direction or Enum.EasingDirection.Out
	)
end

function Utility.After(duration, fn)
	task.delay(duration, fn)
end

function Utility.Connect(signal, callback)
	return signal:Connect(callback)
end

function Utility.DeriveFlag(name)
	return string.gsub(string.lower(name), "%s+", "")
end

function Utility.TextWidth(font, size, text)
	return TextService:GetTextSize(text, size, font, Vector2.new(9999, 9999)).X
end

local TextService = game:GetService("TextService")
Utility.TextService = TextService

return Utility
