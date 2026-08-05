local Input = {}
Input.__index = Input
Input.__type = "Input"

local Utility = require(script.Parent.Parent.utility)

function Input.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}

	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or "Input",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag
			or properties.Flag
			or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Input") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		placeholder = properties.placeholder or properties.Placeholder or "",
		callback = properties.callback or properties.Callback or function() end,
		value = properties.value or properties.Value or "",
		connections = {},
	}, Input)

	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)

	if self.description then
		self:_buildDescription()
	end

	return self
end

function Input:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 43),
		BorderSizePixel = 0,
		Name = self.name,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Parent = self.tab.tabPage,
	})

	self.stroke = self.window:StyleElementBody(self.main)

	local container = self.window:Create("Frame", {
		BorderSizePixel = 0,
		Parent = self.main,
		Size = UDim2.new(0, 170, 0, 16),
		Position = UDim2.new(0, 18, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
	})

	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 5),
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

	self.field = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(160, 28),
		BackgroundColor3 = self.window.theme.FieldBackground,
		BorderSizePixel = 0,
		Parent = self.main,
	})

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = self.field,
	})

	self.fieldStroke = self.window:Create("UIStroke", {
		Color = self.window.theme.FieldStroke,
		Transparency = 0.6,
		Parent = self.field,
	})

	self.textBox = self.window:Create("TextBox", {
		Text = self.value,
		PlaceholderText = self.placeholder,
		FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.ContentColor,
		PlaceholderColor3 = self.window.theme.PlaceholderColor,
		ClearTextOnFocus = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = self.field,
	})

	self.window:ConnectFor(self, self.textBox.Focused, function()
		Utility.Tween(self.fieldStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Color = self.window.theme.FieldStrokeFocus,
			Transparency = 0.3,
		})
	end)

	self.window:ConnectFor(self, self.textBox.FocusLost, function()
		Utility.Tween(self.fieldStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Color = self.window.theme.FieldStroke,
			Transparency = 0.6,
		})

		self.value = self.textBox.Text
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end)
end

function Input:_buildDescription()
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

function Input:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil

	if shown then
		w:_reveal(self.main, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info)
		end
		w:_reveal(self.field, { BackgroundTransparency = 0 }, animate, info)
		w:_reveal(self.textBox, { TextTransparency = 0 }, animate, info)
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info)
		end
		w:_reveal(self.field, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.textBox, { TextTransparency = 1 }, animate, info)
	end
end

function Input:Set(value, skipCallback)
	self.value = value
	self.textBox.Text = value

	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

return Input
