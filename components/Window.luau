local Window = {}
Window.__index = Window
Window.__type = "Window"

local Utility = require(script.Parent.Parent.utility)
local Persistence = require(script.Parent.Parent.utility.persistence)
local Drag = require(script.Parent.Parent.utility.drag)

local defaultTheme = require(script.Parent.Parent.themes.default)

local revealInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local collapseSize = UDim2.fromOffset(185, 50)

local function resolveTheme(value)
	local theme = table.clone(defaultTheme)
	if typeof(value) == "table" then
		for key, override in value do
			theme[key] = override
		end
	elseif typeof(value) == "string" then
		local themes = script.Parent.Parent.themes
		local named = themes:FindFirstChild(string.lower(value))
		if named then
			local overrides = require(named)
			for key, override in overrides do
				theme[key] = override
			end
		end
	end
	return theme
end

function Window.new(properties)
	properties = if typeof(properties) == "table" then properties else {}

	local self = setmetatable({
		name = properties.name or properties.Name or "NexusUI",
		subtitle = properties.subtitle or properties.Subtitle,
		icon = properties.icon or properties.Icon,
		theme = resolveTheme(properties.theme or properties.Theme),

		instances = {},
		connections = {},
		tabs = {},
		controls = {},
		selectedTab = nil,

		configuration = (function()
			local cfg = properties.configuration or properties.Configuration
			if not cfg then return {} end
			return {
				autoSave = cfg.autoSave or cfg.AutoSave,
				autoLoad = cfg.autoLoad or cfg.AutoLoad,
				fileName = cfg.fileName or cfg.FileName,
			}
		end)(),

		hidden = true,
		animating = false,
		unloaded = false,
		minimised = false,
		hasShownOnce = false,
		_loading = false,

		settings = {
			toggleKeybind = Enum.KeyCode.RightShift,
			keepOnScreen = true,
		},
	}, Window)

	self.Flags = setmetatable({}, {
		__index = function(_, flag)
			local control = self.controls[flag]
			return control and control.value
		end,
		__newindex = function(_, flag, value)
			local control = self.controls[flag]
			if control then
				control:Set(value)
			end
		end,
	})

	self:_build()
	self:_loadSettings()
	self:_bindKeybind()

	return self
end

function Window:_build()
	local ts = Utility.TweenService

	self.screenGui = self:Create("ScreenGui", {
		Name = Utility.HttpService:GenerateGUID(false),
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		Enabled = true,
		DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		Parent = game:GetService("CoreGui"),
	})

	self.main = self:Create("Frame", {
		Name = self.name,
		Size = UDim2.fromOffset(520, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ClipsDescendants = true,
		Parent = self.screenGui,
	}, { BackgroundColor3 = "WindowBackground" })

	self:Create("UICorner", {
		CornerRadius = self.theme.CornerRoundness,
		Parent = self.main,
	})

	self.windowStroke = self:Create("UIStroke", {
		Transparency = 1,
		Parent = self.main,
	}, { Color = "WindowStroke", Transparency = "WindowStrokeTransparency" })

	self.windowShadow = self:Create("UIShadow", {
		BlurRadius = UDim.new(0, 24),
		Color = Color3.fromRGB(0, 0, 0),
		Transparency = 1,
		Parent = self.main,
	})

	self:_buildTopbar()
	self:_buildTabBar()
	self:_buildContentArea()
	self:_buildSettingsTab()

	self.drag = Drag.new(self)

	self.unloaded = false
	self.hidden = true

	-- Load saved settings
	local saved = Persistence.LoadSettings()
	if saved then
		for key, value in saved do
			if self.settings[key] ~= nil then
				self.settings[key] = value
			end
		end
	end
end

function Window:_buildTopbar()
	self.topbar = self:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		Active = true,
		Parent = self.main,
	})

	self.topContainer = self:Create("Frame", {
		Size = UDim2.new(0, 300, 0, 24),
		Position = UDim2.new(0, 22, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Parent = self.topbar,
	})

	self:Create("UIListLayout", {
		Padding = UDim.new(0, 3),
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.topContainer,
	})

	if self.name then
		self.title = self:Create("TextLabel", {
			Text = self.name,
			FontFace = self.theme.TitleFont,
			Size = UDim2.fromOffset(50, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			TextTransparency = 1,
			Parent = self.topContainer,
		}, { TextColor3 = "TitlingColor" })
	end

	if self.subtitle then
		self.subtitleLabel = self:Create("TextLabel", {
			Text = self.subtitle,
			FontFace = self.theme.Font,
			Size = UDim2.fromOffset(50, 12),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1,
			Parent = self.topContainer,
		}, { TextColor3 = "TitlingColor" })
	end

	self.actionContainer = self:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 24),
		Position = UDim2.new(1, -18, 0.5, 0),
		BackgroundTransparency = 1,
		Parent = self.topbar,
	})

	self:Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.actionContainer,
	})
end

function Window:_buildTabBar()
	self.tabList = self:Create("ScrollingFrame", {
		Name = "Tabs",
		Active = true,
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0.5, 0, 0, 55),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		ScrollingDirection = Enum.ScrollingDirection.X,
		Parent = self.main,
	})

	self:Create("UIListLayout", {
		Padding = UDim.new(0, 6),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.tabList,
	})

	self:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 20),
		PaddingRight = UDim.new(0, 10),
		Parent = self.tabList,
	})
end

function Window:_buildContentArea()
	self.elements = self:Create("Frame", {
		Size = UDim2.new(1, 0, 1, -101),
		Position = UDim2.new(0.5, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = self.main,
	})

	self.elementsLayout = self:Create("UIPageLayout", {
		Padding = UDim.new(0, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ScrollWheelInputEnabled = false,
		GamepadInputEnabled = false,
		TouchInputEnabled = false,
		EasingStyle = Enum.EasingStyle.Exponential,
		TweenTime = 0.4,
		Parent = self.elements,
	})
end

function Window:_buildSettingsTab()
	self._settingsTab = require(script.Parent.Tab).new(self, {
		name = "Settings",
		_order = 1000,
		_isSettings = true,
	})

	self._settingsTab:CreateSection({ name = "General" })

	self._settingsTab:CreateKeybind({
		name = "Toggle Keybind",
		value = self.settings.toggleKeybind,
		callback = function(key)
			self.settings.toggleKeybind = key
			Persistence.SaveSettings(self.settings)
		end,
	})

	self._settingsTab:CreateSection({ name = "Window" })

	self._settingsTab:CreateToggle({
		name = "Keep window on screen",
		description = "Prevents the window from being dragged off screen",
		value = self.settings.keepOnScreen,
		callback = function(state)
			self.settings.keepOnScreen = state
			Persistence.SaveSettings(self.settings)
		end,
	})

	self._settingsTab:CreateButton({
		name = "Reset Window Position",
		callback = function()
			Utility.Tween(self.main, Utility.TweenInfo(0.5), {
				Position = UDim2.new(0.5, 0, 0.5, 0),
			})
		end,
	})

	if next(self.configuration) ~= nil then
		self._settingsTab:CreateSection({ name = "Configurations" })

		local selected = Persistence.ListConfigs(self)[1]
		local configDropdown, nameInput

		local function refreshConfigs()
			local names = Persistence.ListConfigs(self)
			if configDropdown then
				configDropdown:Refresh(names)
			end
			if selected and not table.find(names, selected) then
				selected = names[1]
			end
			if selected and configDropdown then
				configDropdown:Set(selected, true)
			end
		end

		configDropdown = self._settingsTab:CreateDropdown({
			name = "Saved Configurations",
			options = Persistence.ListConfigs(self),
			value = selected,
			placeholder = "No saved configurations",
			callback = function(value)
				selected = value
			end,
		})

		nameInput = self._settingsTab:CreateInput({
			name = "Configuration Name",
			description = "Name a new configuration, or leave blank to overwrite the selected one.",
			placeholder = "e.g. PvP Setup",
		})

		local actions = self._settingsTab:CreateSection({ name = "Actions" })

		self._settingsTab:CreateButton({
			name = "Save Configuration",
			callback = function()
				local name = nameInput and nameInput.value or ""
				if name == "" then name = selected end
				if not name or name == "" then
					self:Notify({ title = "Name your configuration first" })
					return
				end
				if Persistence.Save(self) then
					if nameInput then nameInput:Set("") end
					selected = name
					refreshConfigs()
					self:Notify({ title = "Saved configuration", content = name })
				end
			end,
		})

		self._settingsTab:CreateButton({
			name = "Load Configuration",
			callback = function()
				if not selected or selected == "" then
					self:Notify({ title = "Pick a configuration to load" })
					return
				end
				if Persistence.Load(self) then
					self:Notify({ title = "Loaded configuration", content = selected })
				end
			end,
		})

		self._settingsTab:CreateButton({
			name = "Delete Configuration",
			callback = function()
				if not selected or selected == "" then return end
				if Persistence.DeleteConfig(self, selected) then
					refreshConfigs()
					self:Notify({ title = "Deleted configuration", content = selected })
				end
			end,
		})
	end
end

function Window:CreateTab(properties)
	local newTab = require(script.Parent.Tab).new(self, properties)
	table.insert(self.tabs, newTab)

	local isFirstVisible = true
	for _, tab in self.tabs do
		if tab ~= newTab and not tab._isSettings then
			isFirstVisible = false
			break
		end
	end
	if isFirstVisible then
		newTab:Select(true)
	end

	return newTab
end

function Window:Notify(properties)
	properties = properties or {}
	local duration = properties.duration or 3

	if not self._notifications then
		self._notifications = self:Create("Frame", {
			Name = "Notifications",
			Size = UDim2.new(0, 280, 0, 600),
			Position = UDim2.new(1, -16, 1, -16),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			Parent = self.screenGui,
		})

		self:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			Parent = self._notifications,
		})
	end

	local notif = self:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = self.theme.ElementBackground,
		BorderSizePixel = 0,
		BackgroundTransparency = 0.05,
		Parent = self._notifications,
	})

	self:Create("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = notif,
	})

	self:Create("UIStroke", {
		Color = self.theme.ElementStroke,
		Transparency = 0.6,
		Parent = notif,
	})

	self:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		Parent = notif,
	})

	if properties.title then
		self:Create("TextLabel", {
			Text = properties.title,
			FontFace = self.theme.TitleFont,
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = self.theme.TitlingColor,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = notif,
		})
	end

	if properties.content then
		self:Create("TextLabel", {
			Text = properties.content,
			FontFace = self.theme.Font,
			Size = UDim2.new(1, 0, 0, 12),
			Position = UDim2.new(0, 0, 0, 20),
			BackgroundTransparency = 1,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = self.theme.PlaceholderColor,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = notif,
		})
	end

	notif.BackgroundTransparency = 1
	Utility.Tween(notif, Utility.TweenInfo(0.3), { BackgroundTransparency = 0.05 })

	task.delay(duration, function()
		Utility.Tween(notif, Utility.TweenInfo(0.3), { BackgroundTransparency = 1 })
		task.wait(0.3)
		notif:Destroy()
	end)
end

function Window:_registerControl(control)
	if not control.flag or control.flag == "" or control.forgetState then
		return
	end

	local flag = control.flag
	if self.controls[flag] then
		local n = 2
		while self.controls[flag .. n] do
			n += 1
		end
		flag = flag .. n
	end

	control.flag = flag
	self.controls[flag] = control
	return flag
end

function Window:_persist(control)
	if control.flag and not control.forgetState and self.configuration.autoSave and not self._loading then
		task.spawn(function()
			Persistence.Save(self)
		end)
	end
end

function Window:_interactive()
	return not self.animating and not self.hidden
end

function Window:Show()
	if self.animating or not self.hidden then return end
	self.animating = true
	self.hidden = false

	if self.configuration.autoLoad and not self._autoLoaded then
		self._autoLoaded = true
		Persistence.Load(self)
	end

	if self.hasShownOnce then
		self:_quickRestore()
	else
		self.hasShownOnce = true
		self:_firstShow()
	end
end

function Window:_firstShow()
	local ts = Utility.TweenService
	self.elements.Visible = true
	self.tabList.Visible = true
	self.drag.bar.Visible = false
	self.main.Visible = true

	ts:Create(self.main, Utility.TweenInfo(0.6), {
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(520, 460),
	}):Play()
	task.wait(0.4)

	ts:Create(self.windowShadow, Utility.TweenInfo(0.5), { Transparency = 0.6 }):Play()
	ts:Create(self.windowStroke, Utility.TweenInfo(0.5), { Transparency = self.theme.WindowStrokeTransparency }):Play()
	task.wait(0.2)

	if self.title then
		ts:Create(self.title, Utility.TweenInfo(0.4), { TextTransparency = 0 }):Play()
	end
	if self.subtitleLabel then
		ts:Create(self.subtitleLabel, Utility.TweenInfo(0.4), { TextTransparency = 0.7 }):Play()
	end

	for _, action in self.actionContainer:GetChildren() do
		if action:IsA("Frame") then
			ts:Create(action.ImageLabel, Utility.TweenInfo(0.4), { ImageTransparency = 0.6 }):Play()
		end
	end

	task.wait(0.15)

	for _, tab in self.tabs do
		if not tab._isSettings and tab.topbarItem then
			tab.topbarItem.Visible = true
			tab:_applyVisual(
				if self.selectedTab == tab then "selected" else "unselected",
				Utility.TweenInfo(0.4)
			)
			task.wait(0.1)
		end
	end

	self:_revealElements(0.03, 0.6)

	task.wait(0.6)
	self.drag.bar.Visible = true
	Utility.Tween(self.drag.bar, Utility.TweenInfo(0.5), {
		BackgroundTransparency = 0.7,
		Size = UDim2.fromOffset(100, 4),
	})

	self.animating = false
end

function Window:_quickRestore()
	local ts = Utility.TweenService

	ts:Create(self.main, Utility.TweenInfo(0.4), {
		Size = UDim2.fromOffset(520, 460),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	}):Play()

	task.delay(0.2, function()
		self.topbar.Visible = true
		self.tabList.Visible = true
		self.elements.Visible = true

		ts:Create(self.windowShadow, Utility.TweenInfo(0.3), { Transparency = 0.6 }):Play()
		ts:Create(self.windowStroke, Utility.TweenInfo(0.3), { Transparency = self.theme.WindowStrokeTransparency }):Play()

		if self.title then
			ts:Create(self.title, Utility.TweenInfo(0.3), { TextTransparency = 0 }):Play()
		end
		if self.subtitleLabel then
			ts:Create(self.subtitleLabel, Utility.TweenInfo(0.3), { TextTransparency = 0.7 }):Play()
		end

		for _, action in self.actionContainer:GetChildren() do
			if action:IsA("Frame") and action:FindFirstChild("ImageLabel") then
				ts:Create(action.ImageLabel, Utility.TweenInfo(0.3), { ImageTransparency = 0.6 }):Play()
			end
		end

		for _, tab in self.tabs do
			if not tab._isSettings and tab.topbarItem then
				tab.topbarItem.Visible = true
				tab:_applyVisual(
					if self.selectedTab == tab then "selected" else "unselected",
					Utility.TweenInfo(0.3)
				)
			end
		end

		self:_revealElements(0.03, 0.4)
	end)

	self.drag.bar.Position = UDim2.new(0.5, 0, 0.5, 238)
	self.drag.bar.Size = UDim2.fromOffset(0, 4)
	self.drag.bar.Visible = true
	Utility.Tween(self.drag.bar, Utility.TweenInfo(0.4), {
		Size = UDim2.fromOffset(100, 4),
		BackgroundTransparency = 0.7,
	})

	task.delay(0.5, function()
		self.animating = false
	end)
end

function Window:Hide()
	if self.animating or self.hidden then return end
	self.animating = true
	self.hidden = true

	local ts = Utility.TweenService
	ts:Create(self.main, Utility.TweenInfo(0.4), {
		Size = UDim2.fromOffset(520, 0),
	}):Play()
	ts:Create(self.windowShadow, Utility.TweenInfo(0.3), { Transparency = 1 }):Play()
	ts:Create(self.windowStroke, Utility.TweenInfo(0.3), { Transparency = 1 }):Play()

	if self.title then
		ts:Create(self.title, Utility.TweenInfo(0.2), { TextTransparency = 1 }):Play()
	end
	if self.subtitleLabel then
		ts:Create(self.subtitleLabel, Utility.TweenInfo(0.2), { TextTransparency = 1 }):Play()
	end

	Utility.Tween(self.drag.bar, Utility.TweenInfo(0.3), {
		Size = UDim2.fromOffset(0, 4),
		BackgroundTransparency = 1,
	})

	task.delay(0.35, function()
		self.topbar.Visible = false
		self.elements.Visible = false
		self.tabList.Visible = false
		self.drag.bar.Visible = false
		self.animating = false
	end)
end

function Window:ToggleHide()
	if self.animating then return end
	if self.hidden then
		self:Show()
	else
		self:Hide()
	end
end

function Window:_revealElements(perElementDelay, budget)
	local tab = self.selectedTab
	if not tab then return end

	local page = tab.tabPage
	local viewTop = page.AbsolutePosition.Y
	local viewBottom = viewTop + page.AbsoluteWindowSize.Y

	local maxStaggered = math.floor(budget / perElementDelay)
	local staggered = 0

	for _, element in ipairs(tab.elements) do
		local top = element.main.AbsolutePosition.Y
		local onScreen = (top + element.main.AbsoluteSize.Y) > viewTop and top < viewBottom

		if onScreen then
			element:_setShown(true, true)
			staggered += 1
			if staggered <= maxStaggered then
				task.wait(perElementDelay)
			end
		else
			element:_setShown(true, false)
		end
	end
end

function Window:_fadeSelectedElementsOut()
	if self.selectedTab then
		for _, element in ipairs(self.selectedTab.elements) do
			element:_setShown(false, true)
		end
	end
end

function Window:_bindKeybind()
	Utility.Connect(Utility.UserInputService.InputBegan, function(input, processed)
		if processed then return end
		if input.KeyCode == self.settings.toggleKeybind then
			self:ToggleHide()
		end
	end)
end

function Window:_loadSettings()
	local saved = Persistence.LoadSettings()
	if saved then
		for key, value in saved do
			if self.settings[key] ~= nil then
				self.settings[key] = value
			end
		end
	end
end

function Window:_jumpTo(page)
	if page then
		self.elementsLayout:JumpTo(page)
	end
end

function Window:Navigate(tab)
	if tab == nil then return end
	for _, candidate in self.tabs do
		if candidate == tab or candidate.name == tab then
			candidate:Select()
			break
		end
	end
end

function Window:Create(className, properties, themeBindings)
	local instance = Instance.new(className)

	if themeBindings and self.theme then
		for property, value in themeBindings do
			if typeof(value) == "string" then
				instance[property] = self.theme[value]
			end
		end
	end

	if properties then
		for property, value in properties do
			if property ~= "Parent" then
				instance[property] = value
			end
		end
	end

	if properties and properties.Parent then
		instance.Parent = properties.Parent
	end

	table.insert(self.instances, instance)
	return instance
end

function Window:Connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self.connections, connection)
	return connection
end

function Window:Disconnect(connection)
	if not connection then return end
	local index = table.find(self.connections, connection)
	if index then
		table.remove(self.connections, index)
	end
	connection:Disconnect()
end

function Window:ConnectFor(owner, signal, callback)
	local connection = self:Connect(signal, callback)
	owner.connections = owner.connections or {}
	table.insert(owner.connections, connection)
	return connection
end

function Window:_runGuarded(element, fn, ...)
	local args = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(function()
			return fn(table.unpack(args, 1, args.n))
		end)
		if ok then return end

		local quickOut = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Utility.Tween(element.main, quickOut, { BackgroundColor3 = self.theme.ErrorColor })

		if element.title then
			element.title.Text = "Error, check console"
		end

		warn("[NexusUI] Error in " .. (element.__type or "element") .. " '" .. (element.name or "") .. "': " .. tostring(err))

		task.wait(1.5)

		if element.title then
			element.title.Text = element.name or ""
		end
		Utility.Tween(element.main, TweenInfo.new(0.4), { BackgroundColor3 = self.theme.ElementBackground })
	end)
end

function Window:StyleElementBody(main)
	self:Create("UIGradient", {
		Rotation = 270,
		Parent = main,
	}, { Color = "ElementGradient" })

	self:Create("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = main,
	})

	return self:Create("UIStroke", {
		Transparency = 1,
		Parent = main,
	}, { Color = "ElementStroke", Transparency = "ElementStrokeTransparency" })
end

function Window:_wireElementHover(element)
	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local theme = self.theme

	self:Connect(element.main.MouseEnter, function()
		if not self:_interactive() then return end
		Utility.Tween(element.stroke, info, {
			Transparency = theme.ElementStrokeHoverTransparency,
			Color = theme.ElementStrokeHover,
		})
		if element.title then
			Utility.Tween(element.title, info, { TextColor3 = theme.ElementTextHoverColor })
		end
		if element.hoverOverlay then
			Utility.Tween(element.hoverOverlay, info, { BackgroundTransparency = 0.96 })
		end
	end)

	self:Connect(element.main.MouseLeave, function()
		Utility.Tween(element.stroke, info, {
			Transparency = theme.ElementStrokeTransparency,
			Color = theme.ElementStroke,
		})
		if element.title then
			Utility.Tween(element.title, info, { TextColor3 = theme.ContentColor })
		end
		if element.hoverOverlay then
			Utility.Tween(element.hoverOverlay, info, { BackgroundTransparency = 1 })
		end
	end)
end

function Window:CreateHoverOverlay(parent)
	local overlay = self:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = parent,
	})

	self:Create("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = overlay,
	})

	return overlay
end

function Window:Unload()
	self.unloaded = true
	for i = #self.connections, 1, -1 do
		self.connections[i]:Disconnect()
	end
	for i = #self.instances, 1, -1 do
		self.instances[i]:Destroy()
	end
	table.clear(self.connections)
	table.clear(self.instances)
	table.clear(self.controls)
	table.clear(self.tabs)
end

return Window
