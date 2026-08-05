local Tab = {}
Tab.__index = Tab
Tab.__type = "Tab"

local Utility = require(script.Parent.Parent.utility)

function Tab.new(window, properties)
	properties = if typeof(properties) == "table" then properties else {}

	local self = setmetatable({
		window = window,
		name = properties.name or properties.Name or "Tab",
		icon = properties.icon or properties.Icon,
		elements = {},
		_order = properties._order or 0,
		_isSettings = properties._isSettings or false,
		forgetState = properties.forgetState or false,
	}, Tab)

	self:_build()

	return self
end

function Tab:_build()
	self.tabPage = self.window:Create("ScrollingFrame", {
		Name = self.name,
		Active = true,
		Size = UDim2.new(1, -20, 1, -8),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(60, 65, 90),
		ScrollBarImageTransparency = 0.5,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		LayoutOrder = self._order,
		Parent = self.window.elements,
	})

	self:Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = self.tabPage,
	})

	self:Create("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 12),
		Parent = self.tabPage,
	})

	if not self._isSettings then
		self:_buildTopbarItem()
	end
end

function Tab:_buildTopbarItem()
	self.topbarItem = self.window:Create("Frame", {
		Size = UDim2.fromOffset(0, 30),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Visible = false,
		LayoutOrder = self._order,
		Parent = self.window.tabList,
	}, { BackgroundColor3 = "TabBackground" })

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = self.topbarItem,
	})

	self.topbarStroke = self.window:Create("UIStroke", {
		Color = self.window.theme.TabStroke,
		Transparency = 0.7,
		Parent = self.topbarItem,
	})

	local container = self.window:Create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = self.topbarItem,
	})

	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = container,
	})

	self.window:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = container,
	})

	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon,
			Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1,
			ImageTransparency = 1,
			Parent = container,
		}, { ImageColor3 = "TabTextColor" })
	end

	self.topbarLabel = self.window:Create("TextLabel", {
		Text = self.name,
		FontFace = self.window.theme.Font,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = self.window.theme.TabTextColor,
		TextTransparency = 1,
		Parent = container,
	})

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		TextTransparency = 1,
		ZIndex = 10,
		Parent = self.topbarItem,
	})

	self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
		self:Select()
	end)
end

function Tab:Select(force)
	if self.window.selectedTab == self and not force then return end
	if self._isSettings then return end

	local prev = self.window.selectedTab
	self.window.selectedTab = self

	if prev and prev.topbarItem and not prev._isSettings then
		prev:_applyVisual("unselected")
	end

	if self.topbarItem then
		self:_applyVisual("selected")
	end

	self.window:_jumpTo(self.tabPage)

	if not self.window.hidden and not self.window.animating then
		if prev then
			for _, element in ipairs(prev.elements) do
				element:_setShown(false, false)
			end
		end

		for _, element in ipairs(self.elements) do
			element:_setShown(true, false)
		end

		self.window:_revealElements(0.03, 0.4)
	end
end

function Tab:_applyVisual(state, info)
	if not self.topbarItem then return end
	info = info or TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local ts = Utility.TweenService
	local theme = self.window.theme

	if state == "selected" then
		ts:Create(self.topbarItem, info, { BackgroundColor3 = theme.TabBackgroundSelected }):Play()
		ts:Create(self.topbarStroke, info, { Color = theme.TabStrokeSelected, Transparency = 0.3 }):Play()
		ts:Create(self.topbarLabel, info, { TextColor3 = theme.TabTextColorSelected }):Play()
		if self.iconLabel then
			ts:Create(self.iconLabel, info, { ImageColor3 = theme.TabTextColorSelected }):Play()
		end
	elseif state == "unselected" then
		ts:Create(self.topbarItem, info, { BackgroundColor3 = theme.TabBackground }):Play()
		ts:Create(self.topbarStroke, info, { Color = theme.TabStroke, Transparency = 0.7 }):Play()
		ts:Create(self.topbarLabel, info, { TextColor3 = theme.TabTextColor }):Play()
		if self.iconLabel then
			ts:Create(self.iconLabel, info, { ImageColor3 = theme.TabTextColor }):Play()
		end
	elseif state == "hidden" then
		ts:Create(self.topbarItem, info, { BackgroundTransparency = 1 }):Play()
		ts:Create(self.topbarLabel, info, { TextTransparency = 1 }):Play()
		if self.iconLabel then
			ts:Create(self.iconLabel, info, { ImageTransparency = 1 }):Play()
		end
	end
end

function Tab:CreateSection(properties)
	return require(script.Parent.Section).new(self, properties)
end

function Tab:CreateButton(properties)
	return require(script.Parent.Button).new(self, properties)
end

function Tab:CreateToggle(properties)
	return require(script.Parent.Toggle).new(self, properties)
end

function Tab:CreateSlider(properties)
	return require(script.Parent.Slider).new(self, properties)
end

function Tab:CreateDropdown(properties)
	return require(script.Parent.Dropdown).new(self, properties)
end

function Tab:CreateInput(properties)
	return require(script.Parent.Input).new(self, properties)
end

function Tab:CreateKeybind(properties)
	return require(script.Parent.Keybind).new(self, properties)
end

function Tab:CreateSection(properties)
	return require(script.Parent.Section).new(self, properties)
end

function Tab:Create(className, properties, themeBindings)
	return self.window:Create(className, properties, themeBindings)
end

return Tab
