local Toggle = {}
Toggle.__index = Toggle
Toggle.__type = "Toggle"

local Utility = require(script.Parent.Parent.utility)

function Toggle.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}

	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or "Toggle",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag
			or properties.Flag
			or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Toggle") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		callback = properties.callback or properties.Callback or function() end,
		value = if (properties.value or properties.Value) ~= nil then (properties.value or properties.Value) else false,
		connections = {},
	}, Toggle)

	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)

	if self.description then
		self:_buildDescription()
	end

	return self
end

function Toggle:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 43),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Name = self.name,
		Parent = self.tab.tabPage,
	})

	self.stroke = self.window:StyleElementBody(self.main)
	self.hoverOverlay = self.window:CreateHoverOverlay(self.main)

	local container = self.window:Create("Frame", {
		BorderSizePixel = 0,
		Parent = self.main,
		Size = UDim2.new(0, 170, 0, 16),
		Position = UDim2.new(0, 18, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
	})

	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Parent = container,
	})

	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon,
			Size = UDim2.fromOffset(16, 16),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ImageTransparency = 1,
			Parent = container,
		}, { ImageColor3 = "ContentColor" })
	end

	self.title = self.window:Create("TextLabel", {
		Text = self.name,
		FontFace = self.window.theme.Font,
		Size = UDim2.fromOffset(250, 16),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		TextTransparency = 1,
		TextColor3 = self.window.theme.ContentColor,
		Parent = container,
	})

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		Text = "",
		TextTransparency = 1,
		ZIndex = 10,
		Parent = self.main,
	})

	self:_buildSwitch(self.main)
	self.functionContainer.Position = UDim2.new(1, -15, 0.5, 0)
	self.functionContainer.AnchorPoint = Vector2.new(1, 0.5)

	self.window:_wireElementHover(self)

	self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
		self:_performToggle()
	end)
end

function Toggle:_buildSwitch(parent)
	self.functionContainer = self.window:Create("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(46, 22),
		BackgroundColor3 = self.window.theme.ToggleTrack,
		BackgroundTransparency = self.window.theme.ToggleTrackTransparency,
		Parent = parent,
	})

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(0, 12),
		Parent = self.functionContainer,
	})

	self.indicator = self.window:Create("Frame", {
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(18, 18),
		Position = self.value and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = self.value and self.window.theme.AccentColor or self.window.theme.ToggleKnobOff,
		Parent = self.functionContainer,
	})

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.indicator,
	})

	self.indicatorGlow = self.window:Create("UIShadow", {
		BlurRadius = UDim.new(0, 12),
		Color = self.window.theme.AccentColor,
		Transparency = self.value and self.window.theme.AccentGlow or 1,
		Parent = self.indicator,
	})
end

function Toggle:_performToggle()
	self.value = not self.value
	self:_animateIndicator()
	self.window:_runGuarded(self, self.callback, self.value)
	self.window:_persist(self)
end

function Toggle:_animateIndicator()
	local info = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local ts = Utility.TweenService

	if self.value then
		ts:Create(self.indicator, info, {
			Position = UDim2.new(1, -24, 0.5, 0),
			BackgroundColor3 = self.window.theme.AccentColor,
		}):Play()
		ts:Create(self.indicatorGlow, info, {
			Transparency = self.window.theme.AccentGlow,
		}):Play()
	else
		ts:Create(self.indicator, info, {
			Position = UDim2.new(0, 4, 0.5, 0),
			BackgroundColor3 = self.window.theme.ToggleKnobOff,
		}):Play()
		ts:Create(self.indicatorGlow, info, {
			Transparency = 1,
		}):Play()
	end
end

function Toggle:_buildDescription()
	self.descriptor = self.window:Create("TextLabel", {
		Text = self.description,
		FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -20, 0, 12),
		Position = UDim2.new(0, 18, 1, 2),
		BackgroundTransparency = 1,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.PlaceholderColor,
		TextTransparency = 0.7,
		Parent = self.main,
	})

	self.main.Size = UDim2.new(1, -20, 0, 56)
end

function Toggle:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil

	if shown then
		w:_reveal(self.main, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info)
		end
		w:_reveal(self.functionContainer, { BackgroundTransparency = w.theme.ToggleTrackTransparency }, animate, info)
		w:_reveal(self.indicator, {
			BackgroundColor3 = self.value and w.theme.AccentColor or w.theme.ToggleKnobOff,
		}, animate, info)
		w:_reveal(self.indicatorGlow, {
			Transparency = self.value and w.theme.AccentGlow or 1,
		}, animate, info)
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info)
		end
		w:_reveal(self.functionContainer, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.indicator, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.indicatorGlow, { Transparency = 1 }, animate, info)
	end
end

function Toggle:Set(value, skipCallback)
	local changed = self.value ~= value
	self.value = value

	if changed then
		self:_animateIndicator()
	end

	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

return Toggle
