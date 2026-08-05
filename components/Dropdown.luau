local Dropdown = {}
Dropdown.__index = Dropdown
Dropdown.__type = "Dropdown"

local Utility = require(script.Parent.Parent.utility)

local function dedupStrings(arr)
	local seen = {}
	local out = {}
	for _, v in arr do
		if typeof(v) == "string" and not seen[v] then
			seen[v] = true
			table.insert(out, v)
		end
	end
	return out
end

local function normalizeValue(value, multi)
	if value == nil then return {} end
	if typeof(value) == "string" then return { value } end
	if typeof(value) == "table" then
		local out = dedupStrings(value)
		if not multi and #out > 1 then return { out[1] } end
		return out
	end
	return {}
end

function Dropdown.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}

	local multiSelect = properties.multiSelect or properties.MultiSelect or false

	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or "Dropdown",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag
			or properties.Flag
			or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Dropdown") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		callback = properties.callback or properties.Callback or function() end,
		options = dedupStrings(properties.options or properties.Options or {}),
		multiSelect = multiSelect,
		placeholderText = properties.placeholder or properties.Placeholder or "None",
		value = normalizeValue(
			properties.value or properties.Value or properties.currentOption,
			multiSelect
		),
		_isOpen = false,
		_optionFrames = {},
		connections = {},
	}, Dropdown)

	self._desiredValue = self.value

	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)

	if self.description then
		self:_buildDescription()
	end

	return self
end

function Dropdown:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 41),
		BorderSizePixel = 0,
		Name = self.name,
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		Parent = self.tab.tabPage,
	})

	self.top = self.window:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 41),
		Position = UDim2.fromScale(0, 0),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		ZIndex = 1,
		Parent = self.main,
	})

	self.stroke = self.window:Create("UIStroke", {
		Transparency = 1,
		Parent = self.top,
	}, { Color = "ElementStroke", Transparency = "ElementStrokeTransparency" })

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = self.top,
	})

	self.window:Create("UIGradient", {
		Rotation = 270,
		Parent = self.top,
	}, { Color = "ElementGradient" })

	self.hoverOverlay = self.window:CreateHoverOverlay(self.top)
	self.flashTarget = self.top

	local container = self.window:Create("Frame", {
		BorderSizePixel = 0,
		Parent = self.top,
		Size = UDim2.new(0, 170, 0, 16),
		Position = UDim2.new(0, 18, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 5,
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
			ZIndex = 5,
			Parent = container,
		}, { ImageColor3 = "ContentColor" })
	end

	self.title = self.window:Create("TextLabel", {
		Text = self.name,
		FontFace = self.window.theme.Font,
		Size = UDim2.fromOffset(150, 16),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		TextTransparency = 1,
		ZIndex = 5,
		TextColor3 = self.window.theme.ContentColor,
		Parent = container,
	})

	self.selectedLabel = self.window:Create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -40, 0.5, 0),
		Size = UDim2.fromOffset(160, 15),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextSize = 13,
		FontFace = self.window.theme.Font,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextWrapped = true,
		TextTransparency = 1,
		ZIndex = 5,
		TextColor3 = self.window.theme.PlaceholderColor,
		Parent = self.top,
	})

	self.chevron = self.window:Create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Image = "rbxassetid://6031068420",
		Rotation = 180,
		ImageTransparency = 1,
		ZIndex = 5,
		Parent = self.top,
	}, { ImageColor3 = "ContentColor" })

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 41),
		Position = UDim2.fromScale(0, 0),
		BorderSizePixel = 0,
		Text = "",
		TextTransparency = 1,
		ZIndex = 10,
		AutoButtonColor = false,
		Parent = self.main,
	})

	self.panel = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.new(1, 0, 1, -47),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 1,
		BackgroundTransparency = 1,
		Parent = self.main,
	})

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = self.panel,
	})

	self.window:Create("UIStroke", {
		Transparency = 1,
		Parent = self.panel,
	}, { Color = "ElementStroke", Transparency = "ElementStrokeTransparency" })

	self.window:Create("UIGradient", {
		Rotation = 270,
		Parent = self.panel,
	}, { Color = "ElementGradient" })

	self.list = self.window:Create("ScrollingFrame", {
		Active = true,
		Size = UDim2.new(1, 0, 1, -8),
		Position = UDim2.new(0, 0, 0, 4),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(60, 65, 90),
		ScrollBarImageTransparency = 0.5,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = 1,
		Parent = self.panel,
	})

	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = self.list,
	})

	self.window:Create("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		Parent = self.list,
	})

	for _, opt in self.options do
		local data = self:_buildOption(opt)
		table.insert(self._optionFrames, data)
	end

	self:_updateSelectedLabel()

	self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
		if self._isOpen then
			self:_close()
		else
			self:_open()
		end
	end)

	self.window:ConnectFor(self, self.main.MouseEnter, function()
		if self._isOpen or not self.window:_interactive() then return end
		Utility.Tween(self.title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			TextColor3 = self.window.theme.ElementTextHoverColor,
		})
	end)

	self.window:ConnectFor(self, self.main.MouseLeave, function()
		Utility.Tween(self.title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			TextColor3 = self.window.theme.ContentColor,
		})
	end)
end

function Dropdown:_buildOption(optionName)
	local frame = self.window:Create("Frame", {
		Size = UDim2.new(1, -12, 0, 34),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		BackgroundColor3 = self.window.theme.DropdownHighlight,
		Parent = self.list,
	})

	self.window:Create("UICorner", {
		CornerRadius = UDim.new(0, 8),
		Parent = frame,
	})

	local interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		TextTransparency = 1,
		ZIndex = 50,
		Parent = frame,
	})

	local container = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(170, 16),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = frame,
	})

	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 5),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = container,
	})

	local checkMark = self.window:Create("TextLabel", {
		Text = if table.find(self.value, optionName) then "✓" else "",
		FontFace = self.window.theme.Font,
		Size = UDim2.fromOffset(16, 16),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextSize = 14,
		TextTransparency = 1,
		ZIndex = 5,
		TextColor3 = self.window.theme.AccentColor,
		Parent = container,
	})

	local title = self.window:Create("TextLabel", {
		Text = optionName,
		FontFace = self.window.theme.Font,
		Size = UDim2.fromOffset(170, 16),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		TextTransparency = 1,
		ZIndex = 5,
		TextColor3 = self.window.theme.ContentColor,
		Parent = container,
	})

	local isOptionSelected = table.find(self.value, optionName) ~= nil
	self:_renderOption(frame, title, checkMark, isOptionSelected, false)

	local data = {
		name = optionName,
		frame = frame,
		interact = interact,
		title = title,
		checkMark = checkMark,
		selected = isOptionSelected,
	}

	self.window:ConnectFor(self, interact.MouseButton1Click, function()
		if not self._isOpen then return end

		if not self.multiSelect then
			if data.selected then
				self:_close()
				return
			end
			table.clear(self.value)
			table.insert(self.value, optionName)
		else
			if data.selected then
				local idx = table.find(self.value, optionName)
				if idx then table.remove(self.value, idx) end
			else
				table.insert(self.value, optionName)
			end
		end

		self._desiredValue = table.clone(self.value)

		for _, d in self._optionFrames do
			d.selected = table.find(self.value, d.name) ~= nil
			self:_renderOption(d.frame, d.title, d.checkMark, d.selected, true)
		end

		self:_updateSelectedLabel()
		self.window:_runGuarded(self, self.callback, self:_callbackValue())
		self.window:_persist(self)

		if not self.multiSelect then
			task.wait(0.1)
			self:_close()
		end
	end)

	return data
end

function Dropdown:_renderOption(frame, title, checkMark, selected, animate)
	local open = self._isOpen
	local info = animate and TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil

	local bgT = if open then (selected and 0.88 or 0.94) else 1
	local textT = if open then (selected and 0 or 0.2) else 1
	local checkT = if open then (selected and 0 or 0.8) else 1

	if animate then
		Utility.Tween(frame, info, { BackgroundTransparency = bgT })
		Utility.Tween(title, info, { TextTransparency = textT })
		Utility.Tween(checkMark, info, { TextTransparency = checkT })
	else
		frame.BackgroundTransparency = bgT
		title.TextTransparency = textT
		checkMark.TextTransparency = checkT
	end
end

function Dropdown:_callbackValue()
	if self.multiSelect then
		return table.clone(self.value)
	end
	return self.value[1]
end

function Dropdown:_updateSelectedLabel()
	if self.multiSelect then
		local n = #self.value
		if n == 0 then
			self.selectedLabel.Text = self.placeholderText
		elseif n == 1 then
			self.selectedLabel.Text = self.value[1]
		else
			self.selectedLabel.Text = "Various"
		end
	else
		self.selectedLabel.Text = self.value[1] or self.placeholderText
	end
end

function Dropdown:_openHeight()
	local n = 0
	for _, _ in self._optionFrames do n += 1 end
	local rows = n * 34 + math.max(0, n - 1) * 4 + 8
	return math.min(200, 50 + rows)
end

function Dropdown:_open()
	if self._isOpen then return end
	self._isOpen = true

	if self._outsideClickConn then
		self.window:Disconnect(self._outsideClickConn)
	end
	self._outsideClickConn = self.window:Connect(Utility.UserInputService.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local pos = input.Position
		local mainPos = self.main.AbsolutePosition
		local mainSize = self.main.AbsoluteSize
		if pos.X < mainPos.X or pos.X > mainPos.X + mainSize.X or pos.Y < mainPos.Y or pos.Y > mainPos.Y + mainSize.Y then
			self:_close()
		end
	end)

	Utility.Tween(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, -20, 0, self:_openHeight()),
	})
	Utility.Tween(self.chevron, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Rotation = 0,
	})
	Utility.Tween(self.panel, TweenInfo.new(0.3), {
		BackgroundTransparency = self.window.theme.ElementTransparency or 0,
	})

	for _, data in self._optionFrames do
		self:_renderOption(data.frame, data.title, data.checkMark, data.selected, true)
	end
end

function Dropdown:_close()
	if not self._isOpen then return end
	self._isOpen = false

	if self._outsideClickConn then
		self.window:Disconnect(self._outsideClickConn)
		self._outsideClickConn = nil
	end

	Utility.Tween(self.chevron, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Rotation = 180,
	})
	Utility.Tween(self.panel, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
	Utility.Tween(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, -20, 0, 41),
	})

	for _, data in self._optionFrames do
		self:_renderOption(data.frame, data.title, data.checkMark, data.selected, true)
	end
end

function Dropdown:_buildDescription()
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
		Parent = self.top,
	})

	self.main.Size = UDim2.new(1, -20, 0, 54)
end

function Dropdown:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil

	if shown then
		w:_reveal(self.top, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info)
		end
		w:_reveal(self.selectedLabel, { TextTransparency = 0.5 }, animate, info)
		w:_reveal(self.chevron, { ImageTransparency = 0.5 }, animate, info)
	else
		w:_reveal(self.top, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info)
		end
		w:_reveal(self.selectedLabel, { TextTransparency = 1 }, animate, info)
		w:_reveal(self.chevron, { ImageTransparency = 1 }, animate, info)

		if self._isOpen then
			self:_close()
		end
	end
end

function Dropdown:Set(value, skipCallback)
	local newValue = normalizeValue(value, self.multiSelect)
	self._desiredValue = newValue
	self.value = newValue

	for _, data in self._optionFrames do
		data.selected = table.find(self.value, data.name) ~= nil
		self:_renderOption(data.frame, data.title, data.checkMark, data.selected, true)
	end

	self:_updateSelectedLabel()

	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self:_callbackValue())
		self.window:_persist(self)
	end
end

function Dropdown:Refresh(newOptions)
	self.options = dedupStrings(newOptions or {})
	self.value = normalizeValue(self._desiredValue or self.value, self.multiSelect)

	for _, data in self._optionFrames do
		data.frame:Destroy()
	end
	table.clear(self._optionFrames)

	for _, opt in self.options do
		local data = self:_buildOption(opt)
		table.insert(self._optionFrames, data)
	end

	self:_updateSelectedLabel()
end

function Dropdown:Add(option)
	if typeof(option) ~= "string" or option == "" then return end
	if table.find(self.options, option) then return end

	table.insert(self.options, option)
	local data = self:_buildOption(option)
	table.insert(self._optionFrames, data)
end

function Dropdown:Remove(option)
	local idx = table.find(self.options, option)
	if not idx then return end

	table.remove(self.options, idx)

	for i, data in self._optionFrames do
		if data.name == option then
			data.frame:Destroy()
			table.remove(self._optionFrames, i)
			break
		end
	end

	local valueIdx = table.find(self.value, option)
	if valueIdx then
		table.remove(self.value, valueIdx)
		self._desiredValue = table.clone(self.value)
		self:_updateSelectedLabel()
		self.window:_runGuarded(self, self.callback, self:_callbackValue())
		self.window:_persist(self)
	end
end

return Dropdown
