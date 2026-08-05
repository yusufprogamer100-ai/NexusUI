local Slider = {}
Slider.__index = Slider
Slider.__type = "Slider"

local Utility = require(script.Parent.Parent.utility)

local function decimalsOf(step)
	local decimals = 0
	while step % 1 ~= 0 and decimals < 6 do
		step = step * 10
		decimals += 1
	end
	return decimals
end

local function snapTo(range, increment, value)
	local snapped = range[1] + math.round((value - range[1]) / increment) * increment
	return math.clamp(snapped, range[1], range[2])
end

local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local followInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function Slider.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}

	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or "Slider",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag
			or properties.Flag
			or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Slider") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		range = properties.range or properties.Range or { 0, 100 },
		increment = properties.increment or properties.Increment or 1,
		suffix = properties.suffix or properties.Suffix or "",
		callback = properties.callback or properties.Callback or function() end,
		dragging = false,
		connections = {},
	}, Slider)

	if self.range[1] > self.range[2] then
		self.range = { self.range[2], self.range[1] }
	end
	if self.increment <= 0 then
		self.increment = 1
	end

	self.value = if (properties.value or properties.Value) ~= nil
		then (properties.value or properties.Value)
		else self.range[1]
	self.value = snapTo(self.range, self.increment, self.value)

	self._decimals = decimalsOf(self.increment)

	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)

	if self.description then
		self:_buildDescription()
	end

	return self
end

function Slider:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 65),
		BorderSizePixel = 0,
		Name = self.name,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Parent = self.tab.tabPage,
	})

	self.stroke = self.window:StyleElementBody(self.main)

	self:_buildLabel()

	self.track = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.fromOffset(222, 14),
		BorderSizePixel = 0,
		BackgroundColor3 = self.window.theme.SliderBackground,
		Parent = self.main,
	})

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(0, 13),
		Parent = self.track,
	})

	self.progress = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = self.track,
	})

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(0, 13),
		Parent = self.progress,
	})

	self.window:Create("UIGradient", {
		Offset = Vector2.new(0, 0.5),
		Rotation = 2,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.85),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = self.progress,
	}, { Color = "SliderProgress" })

	self.progressGlow = self.window:Create("UIShadow", {
		BlurRadius = UDim.new(0, 14),
		Color = self.window.theme.AccentColor,
		Transparency = 1,
		Parent = self.progress,
	})

	self.handle = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 20, 0.5, 0),
		Size = UDim2.fromOffset(32, 18),
		BorderSizePixel = 0,
		ZIndex = 50,
		BackgroundColor3 = self.window.theme.SliderHandle,
		Parent = self.progress,
	})

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.handle,
	})

	self.handleStroke = self.window:Create("UIStroke", {
		Color = self.window.theme.SliderStroke,
		Transparency = 0.7,
		Parent = self.handle,
	})

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		TextTransparency = 1,
		ZIndex = 10,
		Parent = self.track,
	})

	self.window:ConnectFor(self, self.interact.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.dragging = true
			self:_setHeld(true)
			self:_updateFromMouse()

			if self._dragConnection then
				self._dragConnection:Disconnect()
				self._dragConnection = nil
			end

			self._dragConnection = Utility.RunService.RenderStepped:Connect(function()
				if self.window.unloaded or not self.dragging then
					if self._dragConnection then
						self._dragConnection:Disconnect()
						self._dragConnection = nil
					end
					return
				end
				self:_updateFromMouse()
			end)
		end
	end)

	self.window:ConnectFor(self, Utility.UserInputService.InputEnded, function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and self.dragging then
			self.dragging = false
			self:_setHeld(false)

			if self._dragConnection then
				self._dragConnection:Disconnect()
				self._dragConnection = nil
			end

			self.window:_persist(self)
		end
	end)

	self:_renderProgress()
end

function Slider:_buildLabel()
	self.container = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 18, 0.5, 0),
		Size = UDim2.fromOffset(170, 33),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = self.main,
	})

	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.container,
	})

	local titleContainer = self.window:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = self.container,
	})

	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 5),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = titleContainer,
	})

	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon,
			Size = UDim2.fromOffset(16, 16),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ImageTransparency = 1,
			ZIndex = 5,
			Parent = titleContainer,
		}, { ImageColor3 = "ContentColor" })
	end

	self.title = self.window:Create("TextLabel", {
		Text = self.name,
		FontFace = self.window.theme.Font,
		Size = UDim2.new(1, 0, 0, 16),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextTransparency = 1,
		ZIndex = 5,
		TextColor3 = self.window.theme.ContentColor,
		Parent = titleContainer,
	})

	self.valueLabel = self.window:Create("TextLabel", {
		Text = self:_format(self.value),
		FontFace = self.window.theme.Font,
		Size = UDim2.new(1, 0, 0, 14),
		BackgroundTransparency = 1,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1,
		ZIndex = 6,
		TextColor3 = self.window.theme.AccentColor,
		LayoutOrder = 1,
		Parent = self.container,
	})
end

function Slider:_format(value)
	local text = string.format("%." .. self._decimals .. "f", value)
	if self.suffix ~= "" then
		return text .. " " .. self.suffix
	end
	return text
end

function Slider:_renderProgress(info)
	local span = self.range[2] - self.range[1]
	local ratio = if span ~= 0 then math.clamp((self.value - self.range[1]) / span, 0, 1) else 0
	local size = UDim2.fromScale(ratio, 1)
	if info then
		Utility.Tween(self.progress, info, { Size = size })
	else
		self.progress.Size = size
	end
end

function Slider:_updateFromMouse()
	local width = self.track.AbsoluteSize.X
	if width <= 0 then return end

	local ratio = math.clamp(
		(Utility.UserInputService:GetMouseLocation().X - self.track.AbsolutePosition.X) / width, 0, 1
	)
	local value = snapTo(self.range, self.increment, self.range[1] + ratio * (self.range[2] - self.range[1]))

	if value ~= self.value then
		self.value = value
		self.valueLabel.Text = self:_format(value)
		self:_renderProgress(followInfo)
		self.window:_runGuarded(self, self.callback, value)
	end
end

function Slider:_setHeld(held)
	if held then
		Utility.Tween(self.handle, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(38, 20),
		})
		Utility.Tween(self.handleStroke, TweenInfo.new(0.3), { Transparency = 0.4 })
	else
		Utility.Tween(self.handle, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(32, 18),
		})
		Utility.Tween(self.handleStroke, TweenInfo.new(0.3), { Transparency = 0.7 })
	end
end

function Slider:_buildDescription()
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

	self.main.Size = UDim2.new(1, -20, 0, 78)
end

function Slider:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil

	if shown then
		w:_reveal(self.main, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info)
		end
		w:_reveal(self.valueLabel, { TextTransparency = 0.3 }, animate, info)
		w:_reveal(self.track, { BackgroundTransparency = 0 }, animate, info)
		w:_reveal(self.progress, { BackgroundTransparency = 0 }, animate, info)
		w:_reveal(self.handle, { BackgroundTransparency = 0 }, animate, info)
		w:_reveal(self.progressGlow, { Transparency = 0.6 }, animate, info)
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info)
		end
		w:_reveal(self.valueLabel, { TextTransparency = 1 }, animate, info)
		w:_reveal(self.track, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.progress, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.handle, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.progressGlow, { Transparency = 1 }, animate, info)
	end
end

function Slider:Set(value, skipCallback)
	value = snapTo(self.range, self.increment, value)
	self.value = value
	self.valueLabel.Text = self:_format(value)
	self:_renderProgress(tweenInfo)

	if not skipCallback then
		self.window:_runGuarded(self, self.callback, value)
		self.window:_persist(self)
	end
end

return Slider
