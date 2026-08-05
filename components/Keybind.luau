local Keybind = {}
Keybind.__index = Keybind
Keybind.__type = "Keybind"

local Utility = require(script.Parent.Parent.utility)

function Keybind.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}

	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or "Keybind",
		flag = properties.flag
			or properties.Flag
			or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Keybind") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		callback = properties.callback or properties.Callback or function() end,
		value = properties.value or properties.Value or Enum.KeyCode.RightShift,
		Recording = false,
		connections = {},
	}, Keybind)

	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)

	return self
end

function Keybind:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 43),
		BorderSizePixel = 0,
		Name = self.name,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Parent = self.tab.tabPage,
	})

	self.stroke = self.window:StyleElementBody(self.main)
	self.hoverOverlay = self.window:CreateHoverOverlay(self.main)

	self.title = self.window:Create("TextLabel", {
		Text = self.name,
		FontFace = self.window.theme.Font,
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(0, 18, 0, 0),
		BackgroundTransparency = 1,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		TextTransparency = 1,
		TextColor3 = self.window.theme.ContentColor,
		Parent = self.main,
	})

	self.keyDisplay = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(80, 28),
		BackgroundColor3 = self.window.theme.FieldBackground,
		BorderSizePixel = 0,
		Parent = self.main,
	})

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = self.keyDisplay,
	})

	self.keyStroke = self.window:Create("UIStroke", {
		Color = self.window.theme.FieldStroke,
		Transparency = 0.6,
		Parent = self.keyDisplay,
	})

	self.keyLabel = self.window:Create("TextLabel", {
		Text = self.value.Name or "RightShift",
		FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.new(0, 4, 0, 0),
		BackgroundTransparency = 1,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = self.window.theme.ContentColor,
		TextTransparency = 0.3,
		Parent = self.keyDisplay,
	})

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		TextTransparency = 1,
		ZIndex = 10,
		Parent = self.main,
	})

	self.window:_wireElementHover(self)

	self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
		if self.Recording then return end
		self.Recording = true
		self.keyLabel.Text = "..."
		Utility.Tween(self.keyStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Color = self.window.theme.FieldStrokeFocus,
			Transparency = 0.3,
		})
	end)

	self.window:ConnectFor(self, Utility.UserInputService.InputBegan, function(input, processed)
		if processed then return end

		if self.Recording then
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				self.value = input.KeyCode
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				self.value = input.UserInputType
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				self.value = input.UserInputType
			end

			self.Recording = false
			self.keyLabel.Text = self.value.Name or self.value.Name
			Utility.Tween(self.keyStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Color = self.window.theme.FieldStroke,
				Transparency = 0.6,
			})

			self.window:_runGuarded(self, self.callback, self.value)
			self.window:_persist(self)
			return
		end

		if input.KeyCode == self.value or input.UserInputType == self.value then
			self.window:_runGuarded(self, self.callback, self.value)
		end
	end)
end

function Keybind:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil

	if shown then
		w:_reveal(self.main, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		w:_reveal(self.keyLabel, { TextTransparency = 0.3 }, animate, info)
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		w:_reveal(self.keyLabel, { TextTransparency = 1 }, animate, info)
	end
end

function Keybind:Set(value, skipCallback)
	if typeof(value) == "EnumItem" then
		self.value = value
	elseif typeof(value) == "string" then
		self.value = Enum.KeyCode[value] or Enum.UserInputType[value]
	end

	if self.value then
		self.keyLabel.Text = self.value.Name or ""
	end

	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

return Keybind
