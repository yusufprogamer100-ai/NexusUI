--[[
    NexusUI v1.0
    A production-quality Roblox UI library.
    Inspired by Rayfield Gen2, WindUI, and modern UI design.
    
    Usage:
        local NexusUI = loadstring(game:HttpGet("URL_TO_THIS_FILE"))()
        local Window = NexusUI:CreateWindow({Name = "My Script"})
        local Tab = Window:CreateTab({name = "Main"})
        Tab:CreateButton({name = "Click Me", callback = function() end})
        Window:Show()
--]]

-- ============================================================================
-- SERVICES
-- ============================================================================
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- UTILITY
-- ============================================================================
local Utility = {}

function Utility.Create(className, properties, themeBindings, themeRef)
	local instance = Instance.new(className)
	if themeBindings and themeRef then
		for property, value in themeBindings do
			if typeof(value) == "string" and themeRef[value] ~= nil then
				instance[property] = themeRef[value]
			end
		end
	end
	if properties then
		for property, value in properties do
			if property ~= "Parent" then
				pcall(function() instance[property] = value end)
			end
		end
	end
	if properties and properties.Parent then
		instance.Parent = properties.Parent
	end
	return instance
end

function Utility.Tween(instance, info, goals, play)
	local tween = TweenService:Create(instance, info, goals)
	if play ~= false then tween:Play() end
	return tween
end

function Utility.TweenInfo(duration, style, direction)
	return TweenInfo.new(
		duration or 0.35,
		style or Enum.EasingStyle.Exponential,
		direction or Enum.EasingDirection.Out
	)
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

-- ============================================================================
-- THEMES
-- ============================================================================
local Themes = {}

Themes.Default = {
	Name = "Default",
	WindowBackground = Color3.fromRGB(18, 18, 24),
	WindowStroke = Color3.fromRGB(40, 40, 55),
	WindowStrokeTransparency = 0.5,
	CornerRoundness = UDim.new(0, 12),
	TabBarBackground = Color3.fromRGB(14, 14, 20),
	TabBackground = Color3.fromRGB(25, 25, 35),
	TabBackgroundHover = Color3.fromRGB(32, 32, 45),
	TabBackgroundSelected = Color3.fromRGB(35, 35, 50),
	TabStroke = Color3.fromRGB(50, 50, 65),
	TabStrokeSelected = Color3.fromRGB(80, 90, 140),
	TabTextColor = Color3.fromRGB(140, 145, 170),
	TabTextColorSelected = Color3.fromRGB(220, 225, 255),
	ElementBackground = Color3.fromRGB(25, 25, 35),
	ElementStroke = Color3.fromRGB(40, 40, 55),
	ElementStrokeTransparency = 0.65,
	ElementStrokeHover = Color3.fromRGB(80, 90, 140),
	ElementStrokeHoverTransparency = 0.3,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(200, 205, 230),
	ElementTextHoverColor = Color3.fromRGB(255, 255, 255),
	ElementGradient = ColorSequence.new(Color3.fromRGB(28, 28, 38), Color3.fromRGB(22, 22, 32)),
	AccentColor = Color3.fromRGB(80, 100, 220),
	AccentStroke = Color3.fromRGB(100, 120, 240),
	AccentGlow = 0.7,
	ToggleTrack = Color3.fromRGB(40, 40, 55),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(120, 125, 150),
	ToggleKnobOffTransparency = 0.2,
	SliderBackground = Color3.fromRGB(35, 35, 48),
	SliderBackgroundHover = Color3.fromRGB(42, 42, 58),
	SliderProgress = ColorSequence.new(Color3.fromRGB(70, 90, 200), Color3.fromRGB(100, 120, 240)),
	SliderHandle = Color3.fromRGB(255, 255, 255),
	SliderStroke = Color3.fromRGB(80, 100, 220),
	DropdownHighlight = Color3.fromRGB(30, 30, 42),
	FieldBackground = Color3.fromRGB(20, 20, 28),
	FieldStroke = Color3.fromRGB(40, 40, 55),
	FieldStrokeFocus = Color3.fromRGB(80, 100, 220),
	TitlingColor = Color3.fromRGB(220, 225, 255),
	PlaceholderColor = Color3.fromRGB(100, 105, 130),
	ErrorColor = Color3.fromRGB(200, 60, 60),
	ErrorStrokeColor = Color3.fromRGB(240, 80, 80),
	SuccessColor = Color3.fromRGB(60, 180, 80),
	Font = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Medium),
	TitleFont = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Bold),
}

Themes.Ocean = {
	Name = "Ocean",
	WindowBackground = Color3.fromRGB(10, 18, 30),
	WindowStroke = Color3.fromRGB(30, 60, 100),
	WindowStrokeTransparency = 0.4,
	CornerRoundness = UDim.new(0, 14),
	TabBarBackground = Color3.fromRGB(8, 14, 24),
	TabBackground = Color3.fromRGB(18, 32, 52),
	TabBackgroundHover = Color3.fromRGB(24, 42, 68),
	TabBackgroundSelected = Color3.fromRGB(28, 50, 80),
	TabStroke = Color3.fromRGB(40, 70, 110),
	TabStrokeSelected = Color3.fromRGB(60, 130, 200),
	TabTextColor = Color3.fromRGB(120, 150, 190),
	TabTextColorSelected = Color3.fromRGB(200, 230, 255),
	ElementBackground = Color3.fromRGB(18, 32, 52),
	ElementStroke = Color3.fromRGB(35, 60, 95),
	ElementStrokeTransparency = 0.6,
	ElementStrokeHover = Color3.fromRGB(60, 120, 190),
	ElementStrokeHoverTransparency = 0.25,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(180, 210, 240),
	ElementTextHoverColor = Color3.fromRGB(240, 250, 255),
	ElementGradient = ColorSequence.new(Color3.fromRGB(20, 35, 58), Color3.fromRGB(15, 28, 48)),
	AccentColor = Color3.fromRGB(50, 130, 220),
	AccentStroke = Color3.fromRGB(70, 150, 240),
	AccentGlow = 0.65,
	ToggleTrack = Color3.fromRGB(30, 50, 78),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(100, 130, 170),
	ToggleKnobOffTransparency = 0.2,
	SliderBackground = Color3.fromRGB(22, 38, 62),
	SliderBackgroundHover = Color3.fromRGB(28, 48, 78),
	SliderProgress = ColorSequence.new(Color3.fromRGB(40, 110, 200), Color3.fromRGB(60, 140, 230)),
	SliderHandle = Color3.fromRGB(220, 240, 255),
	SliderStroke = Color3.fromRGB(50, 130, 220),
	DropdownHighlight = Color3.fromRGB(22, 38, 62),
	FieldBackground = Color3.fromRGB(12, 22, 38),
	FieldStroke = Color3.fromRGB(30, 55, 88),
	FieldStrokeFocus = Color3.fromRGB(50, 130, 220),
	TitlingColor = Color3.fromRGB(200, 230, 255),
	PlaceholderColor = Color3.fromRGB(90, 120, 160),
	ErrorColor = Color3.fromRGB(180, 50, 50),
	ErrorStrokeColor = Color3.fromRGB(220, 70, 70),
	SuccessColor = Color3.fromRGB(50, 160, 80),
	Font = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Medium),
	TitleFont = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Bold),
}

Themes.Light = {
	Name = "Light",
	WindowBackground = Color3.fromRGB(240, 240, 245),
	WindowStroke = Color3.fromRGB(200, 200, 210),
	WindowStrokeTransparency = 0.3,
	CornerRoundness = UDim.new(0, 12),
	TabBarBackground = Color3.fromRGB(230, 230, 238),
	TabBackground = Color3.fromRGB(220, 220, 230),
	TabBackgroundHover = Color3.fromRGB(210, 210, 222),
	TabBackgroundSelected = Color3.fromRGB(200, 200, 215),
	TabStroke = Color3.fromRGB(180, 180, 195),
	TabStrokeSelected = Color3.fromRGB(80, 100, 180),
	TabTextColor = Color3.fromRGB(100, 105, 130),
	TabTextColorSelected = Color3.fromRGB(50, 55, 90),
	ElementBackground = Color3.fromRGB(225, 225, 235),
	ElementStroke = Color3.fromRGB(190, 190, 205),
	ElementStrokeTransparency = 0.5,
	ElementStrokeHover = Color3.fromRGB(80, 100, 180),
	ElementStrokeHoverTransparency = 0.3,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(40, 42, 60),
	ElementTextHoverColor = Color3.fromRGB(20, 22, 40),
	ElementGradient = ColorSequence.new(Color3.fromRGB(228, 228, 238), Color3.fromRGB(218, 218, 230)),
	AccentColor = Color3.fromRGB(70, 90, 190),
	AccentStroke = Color3.fromRGB(90, 110, 210),
	AccentGlow = 0.85,
	ToggleTrack = Color3.fromRGB(190, 190, 205),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(160, 162, 178),
	ToggleKnobOffTransparency = 0,
	SliderBackground = Color3.fromRGB(200, 200, 215),
	SliderBackgroundHover = Color3.fromRGB(190, 190, 208),
	SliderProgress = ColorSequence.new(Color3.fromRGB(60, 80, 170), Color3.fromRGB(80, 100, 200)),
	SliderHandle = Color3.fromRGB(255, 255, 255),
	SliderStroke = Color3.fromRGB(70, 90, 190),
	DropdownHighlight = Color3.fromRGB(210, 210, 225),
	FieldBackground = Color3.fromRGB(250, 250, 255),
	FieldStroke = Color3.fromRGB(190, 190, 205),
	FieldStrokeFocus = Color3.fromRGB(70, 90, 190),
	TitlingColor = Color3.fromRGB(30, 32, 55),
	PlaceholderColor = Color3.fromRGB(140, 142, 165),
	ErrorColor = Color3.fromRGB(210, 55, 55),
	ErrorStrokeColor = Color3.fromRGB(230, 70, 70),
	SuccessColor = Color3.fromRGB(45, 160, 75),
	Font = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Medium),
	TitleFont = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Bold),
}

local function resolveTheme(value)
	local theme = table.clone(Themes.Default)
	if typeof(value) == "table" then
		for key, override in value do
			theme[key] = override
		end
	elseif typeof(value) == "string" then
		local named = Themes[string.upper(string.sub(value, 1, 1)) .. string.sub(value, 2)]
		if not named then
			for name, t in Themes do
				if string.lower(name) == string.lower(value) then
					named = t
					break
				end
			end
		end
		if named then
			for key, override in named do
				theme[key] = override
			end
		end
	end
	return theme
end

-- ============================================================================
-- PERSISTENCE
-- ============================================================================
local Persistence = {}

local function getConfigFolder()
	return "NexusUI"
end

function Persistence.GetPath(windowName)
	return getConfigFolder() .. "/" .. (windowName or "config") .. ".json"
end

function Persistence.Save(window)
	local path = Persistence.GetPath(window.name)
	local data = {}
	for flag, control in window.controls do
		if control and control.value ~= nil then
			data[flag] = {
				value = if typeof(control.value) == "Color3" then
					{ control.value.R, control.value.G, control.value.B }
				elseif typeof(control.value) == "EnumItem" then
					control.value.Name
				else
					control.value
			}
		end
	end
	local success, encoded = pcall(function() return HttpService:JSONEncode(data) end)
	if success then
		writefile(path, encoded)
		return true
	end
	return false
end

function Persistence.Load(window)
	local path = Persistence.GetPath(window.name)
	if not isfile(path) then return false end
	local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not success or typeof(decoded) ~= "table" then return false end
	window._loading = true
	for flag, saved in decoded do
		local control = window.controls[flag]
		if control then
			local value = saved.value
			if typeof(value) == "table" and #value == 3 then
				value = Color3.new(value[1], value[2], value[3])
			end
			control:Set(value, true)
		end
	end
	window._loading = false
	return true
end

function Persistence.ListConfigs(window)
	local folder = getConfigFolder() .. "/"
	local configs = {}
	if not isfolder(getConfigFolder()) then return configs end
	for _, file in listfiles(folder) do
		if string.match(file, "%.json$") then
			local name = string.match(file, "^(.+)%.json$")
			if name and name ~= "_settings" then
				table.insert(configs, name)
			end
		end
	end
	return configs
end

function Persistence.DeleteConfig(window, name)
	local path = getConfigFolder() .. "/" .. name .. ".json"
	if isfile(path) then delfile(path); return true end
	return false
end

function Persistence.SaveSettings(settings)
	local path = getConfigFolder() .. "/_settings.json"
	local data = {}
	for key, value in settings do
		if typeof(value) == "EnumItem" then
			data[key] = value.Name
		else
			data[key] = value
		end
	end
	local success, encoded = pcall(function() return HttpService:JSONEncode(data) end)
	if success then writefile(path, encoded); return true end
	return false
end

function Persistence.LoadSettings()
	local path = getConfigFolder() .. "/_settings.json"
	if not isfile(path) then return nil end
	local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if success and typeof(decoded) == "table" then return decoded end
	return nil
end

-- ============================================================================
-- DRAG SYSTEM
-- ============================================================================
local Drag = {}
Drag.__index = Drag

function Drag.new(window)
	local self = setmetatable({}, Drag)
	self.window = window
	self.dragging = false
	self.relative = Vector2.new(0, 0)

	self.bar = Utility.Create("Frame", {
		Name = "DragBar",
		Size = UDim2.fromOffset(100, 4),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1, 8),
		BackgroundColor3 = Color3.fromRGB(80, 90, 120),
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Visible = false,
		Parent = window.main,
	})
	Utility.Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.bar })
	self:_bind()
	return self
end

function Drag:_bind()
	local uis = UserInputService
	Utility.Connect(self.window.topbar.InputBegan, function(input, processed)
		if processed then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if not self.window:_interactive() then return end
		self.dragging = true
		self.relative = self.window.main.AbsolutePosition + self.window.main.AbsoluteSize * self.window.main.AnchorPoint - uis:GetMouseLocation()
	end)
	Utility.Connect(uis.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.dragging = false
		end
	end)
	Utility.Connect(uis.WindowFocusReleased, function() self.dragging = false end)
	Utility.Connect(RunService.RenderStepped, function()
		if not self.dragging then return end
		if not self.window:_interactive() then self.dragging = false; return end
		local position = uis:GetMouseLocation() + self.relative
		local x, y = position.X, position.Y
		if self.window.settings.keepOnScreen then
			local size = self.window.main.AbsoluteSize
			local screen = self.window.screenGui.AbsoluteSize
			local margin = 8
			local halfX, halfY = size.X / 2, size.Y / 2
			x = math.clamp(x, halfX + margin, math.max(halfX + margin, screen.X - halfX - margin))
			y = math.clamp(y, halfY + margin, math.max(halfY + margin, screen.Y - halfY - margin))
		end
		self.window.main.Position = UDim2.fromOffset(x, y)
		self.bar.Position = UDim2.new(
			self.window.main.Position.X.Scale, self.window.main.Position.X.Offset,
			self.window.main.Position.Y.Scale,
			self.window.main.Position.Y.Offset + (self.window.main.Size.Y.Offset / 2 + 8)
		)
	end)
end

-- ============================================================================
-- SECTION COMPONENT
-- ============================================================================
local Section = {}
Section.__index = Section
Section.__type = "Section"

function Section.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or "Section",
	}, Section)
	self:_build()
	table.insert(tab.elements, self)
	return self
end

function Section:_build()
	self.main = self.tab:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 28),
		BackgroundTransparency = 1,
		Parent = self.tab.tabPage,
	})
	self.title = self.tab:Create("TextLabel", {
		Text = string.upper(self.name),
		FontFace = self.window.theme.TitleFont,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.PlaceholderColor,
		TextTransparency = 1,
		Parent = self.main,
	})
	self.tab:Create("UIPadding", { PaddingLeft = UDim.new(0, 6), Parent = self.main })
end

function Section:_setShown(shown, animate)
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil
	if shown then
		Utility.Tween(self.title, info or TweenInfo.new(0), { TextTransparency = 0.3 })
	else
		Utility.Tween(self.title, info or TweenInfo.new(0), { TextTransparency = 1 })
	end
end

-- ============================================================================
-- BUTTON COMPONENT
-- ============================================================================
local Button = {}
Button.__index = Button
Button.__type = "Button"

function Button.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or "Button",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		callback = properties.callback or properties.Callback or function() end,
		connections = {},
	}, Button)
	self:_build()
	table.insert(tab.elements, self)
	if self.description then self:_buildDescription() end
	return self
end

function Button:_build()
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
		BorderSizePixel = 0, Parent = self.main,
		Size = UDim2.new(0, 170, 0, 16),
		Position = UDim2.new(0, 18, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left, Parent = container,
	})

	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon, Size = UDim2.fromOffset(16, 16),
			BorderSizePixel = 0, BackgroundTransparency = 1, ImageTransparency = 1,
			Parent = container,
		}, { ImageColor3 = "ContentColor" })
	end

	self.title = self.window:Create("TextLabel", {
		Text = self.name, FontFace = self.window.theme.Font,
		Size = UDim2.fromOffset(250, 16), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, TextTransparency = 1,
		TextColor3 = self.window.theme.ContentColor, Parent = container,
	})

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0, Text = "", TextTransparency = 1, ZIndex = 10,
		Parent = self.main,
	})

	self.window:_wireElementHover(self)
	self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
		Utility.Tween(self.stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = 1 })
		Utility.Tween(self.main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.new(1, -26, 0, 43) })
		self.window:_runGuarded(self, self.callback)
		task.wait(0.1)
		Utility.Tween(self.main, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.new(1, -20, 0, 43) })
		Utility.Tween(self.stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Transparency = self.window.theme.ElementStrokeTransparency })
	end)
end

function Button:_buildDescription()
	self.descriptor = self.window:Create("TextLabel", {
		Text = self.description, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 18, 1, 2),
		BackgroundTransparency = 1, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.PlaceholderColor,
		TextTransparency = 0.7, Parent = self.main,
	})
	self.main.Size = UDim2.new(1, -20, 0, 56)
end

function Button:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil
	if shown then
		w:_reveal(self.main, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info) end
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info) end
	end
end

-- ============================================================================
-- TOGGLE COMPONENT
-- ============================================================================
local Toggle = {}
Toggle.__index = Toggle
Toggle.__type = "Toggle"

function Toggle.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or "Toggle",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag or properties.Flag or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Toggle") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		callback = properties.callback or properties.Callback or function() end,
		value = if (properties.value or properties.Value) ~= nil then (properties.value or properties.Value) else false,
		connections = {},
	}, Toggle)
	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)
	if self.description then self:_buildDescription() end
	return self
end

function Toggle:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 43),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0, BackgroundTransparency = 1,
		Name = self.name, Parent = self.tab.tabPage,
	})
	self.stroke = self.window:StyleElementBody(self.main)
	self.hoverOverlay = self.window:CreateHoverOverlay(self.main)

	local container = self.window:Create("Frame", {
		BorderSizePixel = 0, Parent = self.main,
		Size = UDim2.new(0, 170, 0, 16),
		Position = UDim2.new(0, 18, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left, Parent = container,
	})

	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon, Size = UDim2.fromOffset(16, 16),
			BorderSizePixel = 0, BackgroundTransparency = 1, ImageTransparency = 1,
			Parent = container,
		}, { ImageColor3 = "ContentColor" })
	end

	self.title = self.window:Create("TextLabel", {
		Text = self.name, FontFace = self.window.theme.Font,
		Size = UDim2.fromOffset(250, 16), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, TextTransparency = 1,
		TextColor3 = self.window.theme.ContentColor, Parent = container,
	})

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0, Text = "", TextTransparency = 1, ZIndex = 10,
		Parent = self.main,
	})

	self:_buildSwitch(self.main)
	self.functionContainer.Position = UDim2.new(1, -15, 0.5, 0)
	self.functionContainer.AnchorPoint = Vector2.new(1, 0.5)
	self.window:_wireElementHover(self)
	self.window:ConnectFor(self, self.interact.MouseButton1Click, function() self:_performToggle() end)
end

function Toggle:_buildSwitch(parent)
	self.functionContainer = self.window:Create("Frame", {
		BorderSizePixel = 0, Size = UDim2.fromOffset(46, 22),
		BackgroundColor3 = self.window.theme.ToggleTrack,
		BackgroundTransparency = self.window.theme.ToggleTrackTransparency,
		Parent = parent,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.functionContainer })

	self.indicator = self.window:Create("Frame", {
		BorderSizePixel = 0, Size = UDim2.fromOffset(18, 18),
		Position = self.value and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = self.value and self.window.theme.AccentColor or self.window.theme.ToggleKnobOff,
		Parent = self.functionContainer,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.indicator })

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
	if self.value then
		Utility.Tween(self.indicator, info, { Position = UDim2.new(1, -24, 0.5, 0), BackgroundColor3 = self.window.theme.AccentColor })
		Utility.Tween(self.indicatorGlow, info, { Transparency = self.window.theme.AccentGlow })
	else
		Utility.Tween(self.indicator, info, { Position = UDim2.new(0, 4, 0.5, 0), BackgroundColor3 = self.window.theme.ToggleKnobOff })
		Utility.Tween(self.indicatorGlow, info, { Transparency = 1 })
	end
end

function Toggle:_buildDescription()
	self.descriptor = self.window:Create("TextLabel", {
		Text = self.description, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 18, 1, 2),
		BackgroundTransparency = 1, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.PlaceholderColor,
		TextTransparency = 0.7, Parent = self.main,
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
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info) end
		w:_reveal(self.functionContainer, { BackgroundTransparency = w.theme.ToggleTrackTransparency }, animate, info)
		w:_reveal(self.indicator, { BackgroundColor3 = self.value and w.theme.AccentColor or w.theme.ToggleKnobOff }, animate, info)
		w:_reveal(self.indicatorGlow, { Transparency = self.value and w.theme.AccentGlow or 1 }, animate, info)
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info) end
		w:_reveal(self.functionContainer, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.indicator, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.indicatorGlow, { Transparency = 1 }, animate, info)
	end
end

function Toggle:Set(value, skipCallback)
	local changed = self.value ~= value
	self.value = value
	if changed then self:_animateIndicator() end
	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

-- ============================================================================
-- SLIDER COMPONENT
-- ============================================================================
local Slider = {}
Slider.__index = Slider
Slider.__type = "Slider"

local function decimalsOf(step)
	local decimals = 0
	while step % 1 ~= 0 and decimals < 6 do step = step * 10; decimals += 1 end
	return decimals
end

local function snapTo(range, increment, value)
	local snapped = range[1] + math.round((value - range[1]) / increment) * increment
	return math.clamp(snapped, range[1], range[2])
end

local sliderTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local followInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function Slider.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab, window = tab.window,
		name = properties.name or properties.Name or "Slider",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag or properties.Flag or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Slider") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		range = properties.range or properties.Range or { 0, 100 },
		increment = properties.increment or properties.Increment or 1,
		suffix = properties.suffix or properties.Suffix or "",
		callback = properties.callback or properties.Callback or function() end,
		dragging = false, connections = {},
	}, Slider)
	if self.range[1] > self.range[2] then self.range = { self.range[2], self.range[1] } end
	if self.increment <= 0 then self.increment = 1 end
	self.value = if (properties.value or properties.Value) ~= nil then (properties.value or properties.Value) else self.range[1]
	self.value = snapTo(self.range, self.increment, self.value)
	self._decimals = decimalsOf(self.increment)
	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)
	if self.description then self:_buildDescription() end
	return self
end

function Slider:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 65), BorderSizePixel = 0,
		Name = self.name, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1, Parent = self.tab.tabPage,
	})
	self.stroke = self.window:StyleElementBody(self.main)
	self:_buildLabel()

	self.track = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.fromOffset(222, 14), BorderSizePixel = 0,
		BackgroundColor3 = self.window.theme.SliderBackground, Parent = self.main,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 13), Parent = self.track })

	self.progress = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0, ZIndex = 2, Parent = self.track,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 13), Parent = self.progress })
	self.window:Create("UIGradient", {
		Offset = Vector2.new(0, 0.5), Rotation = 2,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(1, 0),
		}), Parent = self.progress,
	}, { Color = "SliderProgress" })

	self.progressGlow = self.window:Create("UIShadow", {
		BlurRadius = UDim.new(0, 14), Color = self.window.theme.AccentColor,
		Transparency = 1, Parent = self.progress,
	})

	self.handle = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 20, 0.5, 0),
		Size = UDim2.fromOffset(32, 18), BorderSizePixel = 0,
		ZIndex = 50, BackgroundColor3 = self.window.theme.SliderHandle, Parent = self.progress,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.handle })
	self.handleStroke = self.window:Create("UIStroke", {
		Color = self.window.theme.SliderStroke, Transparency = 0.7, Parent = self.handle,
	})

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Text = "", TextTransparency = 1, ZIndex = 10, Parent = self.track,
	})

	self.window:ConnectFor(self, self.interact.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.dragging = true
			self:_setHeld(true)
			self:_updateFromMouse()
			if self._dragConnection then self._dragConnection:Disconnect(); self._dragConnection = nil end
			self._dragConnection = RunService.RenderStepped:Connect(function()
				if self.window.unloaded or not self.dragging then
					if self._dragConnection then self._dragConnection:Disconnect(); self._dragConnection = nil end
					return
				end
				self:_updateFromMouse()
			end)
		end
	end)

	self.window:ConnectFor(self, UserInputService.InputEnded, function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and self.dragging then
			self.dragging = false
			self:_setHeld(false)
			if self._dragConnection then self._dragConnection:Disconnect(); self._dragConnection = nil end
			self.window:_persist(self)
		end
	end)

	self:_renderProgress()
end

function Slider:_buildLabel()
	self.container = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 18, 0.5, 0),
		Size = UDim2.fromOffset(170, 33), BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 5, Parent = self.main,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 2), VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.container,
	})

	local titleContainer = self.window:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 5, Parent = self.container,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 5), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = titleContainer,
	})

	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon, Size = UDim2.fromOffset(16, 16),
			BorderSizePixel = 0, BackgroundTransparency = 1,
			ImageTransparency = 1, ZIndex = 5, Parent = titleContainer,
		}, { ImageColor3 = "ContentColor" })
	end

	self.title = self.window:Create("TextLabel", {
		Text = self.name, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, 0, 0, 16), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextTransparency = 1, ZIndex = 5,
		TextColor3 = self.window.theme.ContentColor, Parent = titleContainer,
	})

	self.valueLabel = self.window:Create("TextLabel", {
		Text = self:_format(self.value), FontFace = self.window.theme.Font,
		Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
		TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1, ZIndex = 6,
		TextColor3 = self.window.theme.AccentColor,
		LayoutOrder = 1, Parent = self.container,
	})
end

function Slider:_format(value)
	local text = string.format("%." .. self._decimals .. "f", value)
	if self.suffix ~= "" then return text .. " " .. self.suffix end
	return text
end

function Slider:_renderProgress(info)
	local span = self.range[2] - self.range[1]
	local ratio = if span ~= 0 then math.clamp((self.value - self.range[1]) / span, 0, 1) else 0
	if info then Utility.Tween(self.progress, info, { Size = UDim2.fromScale(ratio, 1) })
	else self.progress.Size = UDim2.fromScale(ratio, 1) end
end

function Slider:_updateFromMouse()
	local width = self.track.AbsoluteSize.X
	if width <= 0 then return end
	local ratio = math.clamp((UserInputService:GetMouseLocation().X - self.track.AbsolutePosition.X) / width, 0, 1)
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
		Utility.Tween(self.handle, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(38, 20) })
		Utility.Tween(self.handleStroke, TweenInfo.new(0.3), { Transparency = 0.4 })
	else
		Utility.Tween(self.handle, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(32, 18) })
		Utility.Tween(self.handleStroke, TweenInfo.new(0.3), { Transparency = 0.7 })
	end
end

function Slider:_buildDescription()
	self.descriptor = self.window:Create("TextLabel", {
		Text = self.description, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 18, 1, 2),
		BackgroundTransparency = 1, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.PlaceholderColor,
		TextTransparency = 0.7, Parent = self.main,
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
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info) end
		w:_reveal(self.valueLabel, { TextTransparency = 0.3 }, animate, info)
		w:_reveal(self.track, { BackgroundTransparency = 0 }, animate, info)
		w:_reveal(self.progress, { BackgroundTransparency = 0 }, animate, info)
		w:_reveal(self.handle, { BackgroundTransparency = 0 }, animate, info)
		w:_reveal(self.progressGlow, { Transparency = 0.6 }, animate, info)
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info) end
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
	self:_renderProgress(sliderTweenInfo)
	if not skipCallback then
		self.window:_runGuarded(self, self.callback, value)
		self.window:_persist(self)
	end
end

-- ============================================================================
-- DROPDOWN COMPONENT
-- ============================================================================
local Dropdown = {}
Dropdown.__index = Dropdown
Dropdown.__type = "Dropdown"

local function dedupStrings(arr)
	local seen, out = {}, {}
	for _, v in arr do
		if typeof(v) == "string" and not seen[v] then seen[v] = true; table.insert(out, v) end
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
		tab = tab, window = tab.window,
		name = properties.name or properties.Name or "Dropdown",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag or properties.Flag or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Dropdown") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		callback = properties.callback or properties.Callback or function() end,
		options = dedupStrings(properties.options or properties.Options or {}),
		multiSelect = multiSelect,
		placeholderText = properties.placeholder or properties.Placeholder or "None",
		value = normalizeValue(properties.value or properties.Value or properties.currentOption, multiSelect),
		_isOpen = false, _optionFrames = {}, connections = {},
	}, Dropdown)
	self._desiredValue = self.value
	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)
	if self.description then self:_buildDescription() end
	return self
end

function Dropdown:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 41), BorderSizePixel = 0,
		Name = self.name, ClipsDescendants = true,
		BackgroundTransparency = 1, Parent = self.tab.tabPage,
	})
	self.top = self.window:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 41), Position = UDim2.fromScale(0, 0),
		BorderSizePixel = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1, ZIndex = 1, Parent = self.main,
	})
	self.stroke = self.window:Create("UIStroke", {
		Transparency = 1, Parent = self.top,
	}, { Color = "ElementStroke", Transparency = "ElementStrokeTransparency" })
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.top })
	self.window:Create("UIGradient", { Rotation = 270, Parent = self.top }, { Color = "ElementGradient" })
	self.hoverOverlay = self.window:CreateHoverOverlay(self.top)
	self.flashTarget = self.top

	local container = self.window:Create("Frame", {
		BorderSizePixel = 0, Parent = self.top,
		Size = UDim2.new(0, 170, 0, 16),
		Position = UDim2.new(0, 18, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, ZIndex = 5,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 5), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left, Parent = container,
	})

	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon, Size = UDim2.fromOffset(16, 16),
			BorderSizePixel = 0, BackgroundTransparency = 1,
			ImageTransparency = 1, ZIndex = 5, Parent = container,
		}, { ImageColor3 = "ContentColor" })
	end

	self.title = self.window:Create("TextLabel", {
		Text = self.name, FontFace = self.window.theme.Font,
		Size = UDim2.fromOffset(150, 16), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, TextTransparency = 1, ZIndex = 5,
		TextColor3 = self.window.theme.ContentColor, Parent = container,
	})

	self.selectedLabel = self.window:Create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -40, 0.5, 0),
		Size = UDim2.fromOffset(160, 15), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 13,
		FontFace = self.window.theme.Font,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextWrapped = true, TextTransparency = 1, ZIndex = 5,
		TextColor3 = self.window.theme.PlaceholderColor, Parent = self.top,
	})

	self.chevron = self.window:Create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.fromOffset(14, 14), BorderSizePixel = 0,
		BackgroundTransparency = 1, Image = "rbxassetid://6031068420",
		Rotation = 180, ImageTransparency = 1, ZIndex = 5, Parent = self.top,
	}, { ImageColor3 = "ContentColor" })

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 41),
		Position = UDim2.fromScale(0, 0), BorderSizePixel = 0,
		Text = "", TextTransparency = 1, ZIndex = 10,
		AutoButtonColor = false, Parent = self.main,
	})

	self.panel = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.new(1, 0, 1, -47), BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 1, BackgroundTransparency = 1, Parent = self.main,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.panel })
	self.window:Create("UIStroke", { Transparency = 1, Parent = self.panel }, { Color = "ElementStroke", Transparency = "ElementStrokeTransparency" })
	self.window:Create("UIGradient", { Rotation = 270, Parent = self.panel }, { Color = "ElementGradient" })

	self.list = self.window:Create("ScrollingFrame", {
		Active = true, Size = UDim2.new(1, 0, 1, -8),
		Position = UDim2.new(0, 0, 0, 4), BorderSizePixel = 0,
		BackgroundTransparency = 1, ClipsDescendants = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
		ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(60, 65, 90),
		ScrollBarImageTransparency = 0.5,
		ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 1, Parent = self.panel,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = self.list,
	})
	self.window:Create("UIPadding", {
		PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = self.list,
	})

	for _, opt in self.options do
		local data = self:_buildOption(opt)
		table.insert(self._optionFrames, data)
	end
	self:_updateSelectedLabel()

	self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
		if self._isOpen then self:_close() else self:_open() end
	end)
	self.window:ConnectFor(self, self.main.MouseEnter, function()
		if self._isOpen or not self.window:_interactive() then return end
		Utility.Tween(self.title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextColor3 = self.window.theme.ElementTextHoverColor })
	end)
	self.window:ConnectFor(self, self.main.MouseLeave, function()
		Utility.Tween(self.title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextColor3 = self.window.theme.ContentColor })
	end)
end

function Dropdown:_buildOption(optionName)
	local frame = self.window:Create("Frame", {
		Size = UDim2.new(1, -12, 0, 34), BorderSizePixel = 0,
		BackgroundTransparency = 1, BackgroundColor3 = self.window.theme.DropdownHighlight,
		Parent = self.list,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = frame })
	local interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Text = "", TextTransparency = 1, ZIndex = 50, Parent = frame,
	})
	local container = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(170, 16), BorderSizePixel = 0,
		BackgroundTransparency = 1, ZIndex = 5, Parent = frame,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 5), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = container,
	})
	local checkMark = self.window:Create("TextLabel", {
		Text = if table.find(self.value, optionName) then "✓" else "",
		FontFace = self.window.theme.Font, Size = UDim2.fromOffset(16, 16),
		BorderSizePixel = 0, BackgroundTransparency = 1, TextSize = 14,
		TextTransparency = 1, ZIndex = 5,
		TextColor3 = self.window.theme.AccentColor, Parent = container,
	})
	local title = self.window:Create("TextLabel", {
		Text = optionName, FontFace = self.window.theme.Font,
		Size = UDim2.fromOffset(170, 16), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, TextTransparency = 1, ZIndex = 5,
		TextColor3 = self.window.theme.ContentColor, Parent = container,
	})
	local isOptionSelected = table.find(self.value, optionName) ~= nil
	self:_renderOption(frame, title, checkMark, isOptionSelected, false)

	local data = { name = optionName, frame = frame, interact = interact, title = title, checkMark = checkMark, selected = isOptionSelected }
	self.window:ConnectFor(self, interact.MouseButton1Click, function()
		if not self._isOpen then return end
		if not self.multiSelect then
			if data.selected then self:_close(); return end
			table.clear(self.value); table.insert(self.value, optionName)
		else
			if data.selected then
				local idx = table.find(self.value, optionName)
				if idx then table.remove(self.value, idx) end
			else table.insert(self.value, optionName) end
		end
		self._desiredValue = table.clone(self.value)
		for _, d in self._optionFrames do
			d.selected = table.find(self.value, d.name) ~= nil
			self:_renderOption(d.frame, d.title, d.checkMark, d.selected, true)
		end
		self:_updateSelectedLabel()
		self.window:_runGuarded(self, self.callback, self:_callbackValue())
		self.window:_persist(self)
		if not self.multiSelect then task.wait(0.1); self:_close() end
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
		frame.BackgroundTransparency = bgT; title.TextTransparency = textT; checkMark.TextTransparency = checkT
	end
end

function Dropdown:_callbackValue()
	if self.multiSelect then return table.clone(self.value) end
	return self.value[1]
end

function Dropdown:_updateSelectedLabel()
	if self.multiSelect then
		local n = #self.value
		if n == 0 then self.selectedLabel.Text = self.placeholderText
		elseif n == 1 then self.selectedLabel.Text = self.value[1]
		else self.selectedLabel.Text = "Various" end
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
	if self._outsideClickConn then self.window:Disconnect(self._outsideClickConn) end
	self._outsideClickConn = self.window:Connect(UserInputService.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local pos = input.Position
		local mainPos = self.main.AbsolutePosition
		local mainSize = self.main.AbsoluteSize
		if pos.X < mainPos.X or pos.X > mainPos.X + mainSize.X or pos.Y < mainPos.Y or pos.Y > mainPos.Y + mainSize.Y then
			self:_close()
		end
	end)
	Utility.Tween(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.new(1, -20, 0, self:_openHeight()) })
	Utility.Tween(self.chevron, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Rotation = 0 })
	Utility.Tween(self.panel, TweenInfo.new(0.3), { BackgroundTransparency = self.window.theme.ElementTransparency or 0 })
	for _, data in self._optionFrames do self:_renderOption(data.frame, data.title, data.checkMark, data.selected, true) end
end

function Dropdown:_close()
	if not self._isOpen then return end
	self._isOpen = false
	if self._outsideClickConn then self.window:Disconnect(self._outsideClickConn); self._outsideClickConn = nil end
	Utility.Tween(self.chevron, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Rotation = 180 })
	Utility.Tween(self.panel, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
	Utility.Tween(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.new(1, -20, 0, 41) })
	for _, data in self._optionFrames do self:_renderOption(data.frame, data.title, data.checkMark, data.selected, true) end
end

function Dropdown:_buildDescription()
	self.descriptor = self.window:Create("TextLabel", {
		Text = self.description, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 18, 1, 2),
		BackgroundTransparency = 1, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.PlaceholderColor,
		TextTransparency = 0.7, Parent = self.top,
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
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info) end
		w:_reveal(self.selectedLabel, { TextTransparency = 0.5 }, animate, info)
		w:_reveal(self.chevron, { ImageTransparency = 0.5 }, animate, info)
	else
		w:_reveal(self.top, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info) end
		w:_reveal(self.selectedLabel, { TextTransparency = 1 }, animate, info)
		w:_reveal(self.chevron, { ImageTransparency = 1 }, animate, info)
		if self._isOpen then self:_close() end
	end
end

function Dropdown:Set(value, skipCallback)
	local newValue = normalizeValue(value, self.multiSelect)
	self._desiredValue = newValue; self.value = newValue
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
	for _, data in self._optionFrames do data.frame:Destroy() end
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
		if data.name == option then data.frame:Destroy(); table.remove(self._optionFrames, i); break end
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

-- ============================================================================
-- INPUT COMPONENT
-- ============================================================================
local Input = {}
Input.__index = Input
Input.__type = "Input"

function Input.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab, window = tab.window,
		name = properties.name or properties.Name or "Input",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag or properties.Flag or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Input") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		placeholder = properties.placeholder or properties.Placeholder or "",
		callback = properties.callback or properties.Callback or function() end,
		value = properties.value or properties.Value or "",
		connections = {},
	}, Input)
	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)
	if self.description then self:_buildDescription() end
	return self
end

function Input:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 43), BorderSizePixel = 0,
		Name = self.name, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1, Parent = self.tab.tabPage,
	})
	self.stroke = self.window:StyleElementBody(self.main)

	local container = self.window:Create("Frame", {
		BorderSizePixel = 0, Parent = self.main,
		Size = UDim2.new(0, 170, 0, 16),
		Position = UDim2.new(0, 18, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 5), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left, Parent = container,
	})

	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon, Size = UDim2.fromOffset(16, 16),
			BorderSizePixel = 0, BackgroundTransparency = 1,
			ImageTransparency = 1, Parent = container,
		}, { ImageColor3 = "ContentColor" })
	end

	self.title = self.window:Create("TextLabel", {
		Text = self.name, FontFace = self.window.theme.Font,
		Size = UDim2.fromOffset(250, 16), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.X,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, TextTransparency = 1,
		TextColor3 = self.window.theme.ContentColor, Parent = container,
	})

	self.field = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(160, 28),
		BackgroundColor3 = self.window.theme.FieldBackground,
		BorderSizePixel = 0, Parent = self.main,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.field })
	self.fieldStroke = self.window:Create("UIStroke", {
		Color = self.window.theme.FieldStroke, Transparency = 0.6, Parent = self.field,
	})

	self.textBox = self.window:Create("TextBox", {
		Text = self.value, PlaceholderText = self.placeholder,
		FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.ContentColor,
		PlaceholderColor3 = self.window.theme.PlaceholderColor,
		ClearTextOnFocus = false, TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = self.field,
	})

	self.window:ConnectFor(self, self.textBox.Focused, function()
		Utility.Tween(self.fieldStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Color = self.window.theme.FieldStrokeFocus, Transparency = 0.3,
		})
	end)
	self.window:ConnectFor(self, self.textBox.FocusLost, function()
		Utility.Tween(self.fieldStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Color = self.window.theme.FieldStroke, Transparency = 0.6,
		})
		self.value = self.textBox.Text
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end)
end

function Input:_buildDescription()
	self.descriptor = self.window:Create("TextLabel", {
		Text = self.description, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 18, 1, 2),
		BackgroundTransparency = 1, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.PlaceholderColor,
		TextTransparency = 0.7, Parent = self.main,
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
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info) end
		w:_reveal(self.field, { BackgroundTransparency = 0 }, animate, info)
		w:_reveal(self.textBox, { TextTransparency = 0 }, animate, info)
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info) end
		w:_reveal(self.field, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.textBox, { TextTransparency = 1 }, animate, info)
	end
end

function Input:Set(value, skipCallback)
	self.value = value; self.textBox.Text = value
	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

-- ============================================================================
-- KEYBIND COMPONENT
-- ============================================================================
local Keybind = {}
Keybind.__index = Keybind
Keybind.__type = "Keybind"

function Keybind.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab, window = tab.window,
		name = properties.name or properties.Name or "Keybind",
		flag = properties.flag or properties.Flag or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "Keybind") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		callback = properties.callback or properties.Callback or function() end,
		value = properties.value or properties.Value or Enum.KeyCode.RightShift,
		Recording = false, connections = {},
	}, Keybind)
	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)
	return self
end

function Keybind:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 43), BorderSizePixel = 0,
		Name = self.name, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1, Parent = self.tab.tabPage,
	})
	self.stroke = self.window:StyleElementBody(self.main)
	self.hoverOverlay = self.window:CreateHoverOverlay(self.main)

	self.title = self.window:Create("TextLabel", {
		Text = self.name, FontFace = self.window.theme.Font,
		Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 18, 0, 0),
		BackgroundTransparency = 1, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, TextTransparency = 1,
		TextColor3 = self.window.theme.ContentColor, Parent = self.main,
	})

	self.keyDisplay = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(80, 28),
		BackgroundColor3 = self.window.theme.FieldBackground,
		BorderSizePixel = 0, Parent = self.main,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.keyDisplay })
	self.keyStroke = self.window:Create("UIStroke", {
		Color = self.window.theme.FieldStroke, Transparency = 0.6, Parent = self.keyDisplay,
	})
	self.keyLabel = self.window:Create("TextLabel", {
		Text = self.value.Name or "RightShift", FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0),
		BackgroundTransparency = 1, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = self.window.theme.ContentColor,
		TextTransparency = 0.3, Parent = self.keyDisplay,
	})

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Text = "", TextTransparency = 1, ZIndex = 10, Parent = self.main,
	})
	self.window:_wireElementHover(self)

	self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
		if self.Recording then return end
		self.Recording = true
		self.keyLabel.Text = "..."
		Utility.Tween(self.keyStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Color = self.window.theme.FieldStrokeFocus, Transparency = 0.3,
		})
	end)

	self.window:ConnectFor(self, UserInputService.InputBegan, function(input, processed)
		if processed then return end
		if self.Recording then
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				self.value = input.KeyCode
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
				self.value = input.UserInputType
			end
			self.Recording = false
			self.keyLabel.Text = self.value.Name or ""
			Utility.Tween(self.keyStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Color = self.window.theme.FieldStroke, Transparency = 0.6,
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
	if self.value then self.keyLabel.Text = self.value.Name or "" end
	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

-- ============================================================================
-- TAB COMPONENT
-- ============================================================================
local Tab = {}
Tab.__index = Tab
Tab.__type = "Tab"

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
		Name = self.name, Active = true,
		Size = UDim2.new(1, -20, 1, -8),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(60, 65, 90),
		ScrollBarImageTransparency = 0.5,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		LayoutOrder = self._order, Parent = self.window.elements,
	})
	self:Create("UIListLayout", {
		Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = self.tabPage,
	})
	self:Create("UIPadding", {
		PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 12), Parent = self.tabPage,
	})
	if not self._isSettings then self:_buildTopbarItem() end
end

function Tab:_buildTopbarItem()
	self.topbarItem = self.window:Create("Frame", {
		Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0, Visible = false,
		LayoutOrder = self._order, Parent = self.window.tabList,
	}, { BackgroundColor3 = "TabBackground" })
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.topbarItem })
	self.topbarStroke = self.window:Create("UIStroke", {
		Color = self.window.theme.TabStroke, Transparency = 0.7, Parent = self.topbarItem,
	})
	local container = self.window:Create("Frame", {
		Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1, Parent = self.topbarItem,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = container,
	})
	self.window:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = container,
	})
	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon, Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1, ImageTransparency = 1, Parent = container,
		}, { ImageColor3 = "TabTextColor" })
	end
	self.topbarLabel = self.window:Create("TextLabel", {
		Text = self.name, FontFace = self.window.theme.Font,
		Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextColor3 = self.window.theme.TabTextColor,
		TextTransparency = 1, Parent = container,
	})
	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Text = "", TextTransparency = 1, ZIndex = 10, Parent = self.topbarItem,
	})
	self.window:ConnectFor(self, self.interact.MouseButton1Click, function() self:Select() end)
end

function Tab:Select(force)
	if self.window.selectedTab == self and not force then return end
	if self._isSettings then return end
	local prev = self.window.selectedTab
	self.window.selectedTab = self
	if prev and prev.topbarItem and not prev._isSettings then prev:_applyVisual("unselected") end
	if self.topbarItem then self:_applyVisual("selected") end
	self.window:_jumpTo(self.tabPage)
	if not self.window.hidden and not self.window.animating then
		if prev then for _, element in ipairs(prev.elements) do element:_setShown(false, false) end end
		for _, element in ipairs(self.elements) do element:_setShown(true, false) end
		self.window:_revealElements(0.03, 0.4)
	end
end

function Tab:_applyVisual(state, info)
	if not self.topbarItem then return end
	info = info or TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local theme = self.window.theme
	if state == "selected" then
		Utility.Tween(self.topbarItem, info, { BackgroundColor3 = theme.TabBackgroundSelected })
		Utility.Tween(self.topbarStroke, info, { Color = theme.TabStrokeSelected, Transparency = 0.3 })
		Utility.Tween(self.topbarLabel, info, { TextColor3 = theme.TabTextColorSelected })
		if self.iconLabel then Utility.Tween(self.iconLabel, info, { ImageColor3 = theme.TabTextColorSelected }) end
	elseif state == "unselected" then
		Utility.Tween(self.topbarItem, info, { BackgroundColor3 = theme.TabBackground })
		Utility.Tween(self.topbarStroke, info, { Color = theme.TabStroke, Transparency = 0.7 })
		Utility.Tween(self.topbarLabel, info, { TextColor3 = theme.TabTextColor })
		if self.iconLabel then Utility.Tween(self.iconLabel, info, { ImageColor3 = theme.TabTextColor }) end
	elseif state == "hidden" then
		Utility.Tween(self.topbarItem, info, { BackgroundTransparency = 1 })
		Utility.Tween(self.topbarLabel, info, { TextTransparency = 1 })
		if self.iconLabel then Utility.Tween(self.iconLabel, info, { ImageTransparency = 1 }) end
	end
end

function Tab:CreateSection(properties) return Section.new(self, properties) end
function Tab:CreateButton(properties) return Button.new(self, properties) end
function Tab:CreateToggle(properties) return Toggle.new(self, properties) end
function Tab:CreateSlider(properties) return Slider.new(self, properties) end
function Tab:CreateDropdown(properties) return Dropdown.new(self, properties) end
function Tab:CreateInput(properties) return Input.new(self, properties) end
function Tab:CreateKeybind(properties) return Keybind.new(self, properties) end

function Tab:Create(className, properties, themeBindings)
	return self.window:Create(className, properties, themeBindings)
end

-- ============================================================================
-- WINDOW COMPONENT
-- ============================================================================
local Window = {}
Window.__index = Window
Window.__type = "Window"

function Window.new(properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		name = properties.name or properties.Name or "NexusUI",
		subtitle = properties.subtitle or properties.Subtitle,
		icon = properties.icon or properties.Icon,
		theme = resolveTheme(properties.theme or properties.Theme),
		instances = {}, connections = {}, tabs = {}, controls = {},
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
		hidden = true, animating = false, unloaded = false,
		minimised = false, hasShownOnce = false, _loading = false,
		settings = { toggleKeybind = Enum.KeyCode.RightShift, keepOnScreen = true },
	}, Window)

	self.Flags = setmetatable({}, {
		__index = function(_, flag) local control = self.controls[flag]; return control and control.value end,
		__newindex = function(_, flag, value) local control = self.controls[flag]; if control then control:Set(value) end end,
	})

	self:_build()
	self:_loadSettings()
	self:_bindKeybind()
	return self
end

function Window:_build()
	self.screenGui = self:Create("ScreenGui", {
		Name = HttpService:GenerateGUID(false),
		IgnoreGuiInset = true, ResetOnSpawn = false, Enabled = true,
		DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Global,
		Parent = CoreGui,
	})
	self.main = self:Create("Frame", {
		Name = self.name, Size = UDim2.fromOffset(520, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1, BorderSizePixel = 0,
		Visible = false, ClipsDescendants = true, Parent = self.screenGui,
	}, { BackgroundColor3 = "WindowBackground" })
	self:Create("UICorner", { CornerRadius = self.theme.CornerRoundness, Parent = self.main })
	self.windowStroke = self:Create("UIStroke", { Transparency = 1, Parent = self.main }, { Color = "WindowStroke", Transparency = "WindowStrokeTransparency" })
	self.windowShadow = self:Create("UIShadow", {
		BlurRadius = UDim.new(0, 24), Color = Color3.fromRGB(0, 0, 0),
		Transparency = 1, Parent = self.main,
	})
	self:_buildTopbar()
	self:_buildTabBar()
	self:_buildContentArea()
	self:_buildSettingsTab()
	self.drag = Drag.new(self)
	self.unloaded = false; self.hidden = true
	local saved = Persistence.LoadSettings()
	if saved then for key, value in saved do if self.settings[key] ~= nil then self.settings[key] = value end end end
end

function Window:_buildTopbar()
	self.topbar = self:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1,
		Active = true, Parent = self.main,
	})
	self.topContainer = self:Create("Frame", {
		Size = UDim2.new(0, 300, 0, 24), Position = UDim2.new(0, 22, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Parent = self.topbar,
	})
	self:Create("UIListLayout", {
		Padding = UDim.new(0, 3), FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.topContainer,
	})
	if self.name then
		self.title = self:Create("TextLabel", {
			Text = self.name, FontFace = self.theme.TitleFont,
			Size = UDim2.fromOffset(50, 20), AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1, TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true, TextTransparency = 1, Parent = self.topContainer,
		}, { TextColor3 = "TitlingColor" })
	end
	if self.subtitle then
		self.subtitleLabel = self:Create("TextLabel", {
			Text = self.subtitle, FontFace = self.theme.Font,
			Size = UDim2.fromOffset(50, 12), AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1, TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1, Parent = self.topContainer,
		}, { TextColor3 = "TitlingColor" })
	end
	self.actionContainer = self:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 24), Position = UDim2.new(1, -18, 0.5, 0),
		BackgroundTransparency = 1, Parent = self.topbar,
	})
	self:Create("UIListLayout", {
		Padding = UDim.new(0, 4), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.actionContainer,
	})
end

function Window:_buildTabBar()
	self.tabList = self:Create("ScrollingFrame", {
		Name = "Tabs", Active = true,
		Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0.5, 0, 0, 55),
		AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0, ScrollBarImageTransparency = 1,
		ScrollingDirection = Enum.ScrollingDirection.X, Parent = self.main,
	})
	self:Create("UIListLayout", {
		Padding = UDim.new(0, 6), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.tabList,
	})
	self:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 10), Parent = self.tabList,
	})
end

function Window:_buildContentArea()
	self.elements = self:Create("Frame", {
		Size = UDim2.new(1, 0, 1, -101), Position = UDim2.new(0.5, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1,
		ClipsDescendants = true, Parent = self.main,
	})
	self.elementsLayout = self:Create("UIPageLayout", {
		Padding = UDim.new(0, 0), FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		ScrollWheelInputEnabled = false, GamepadInputEnabled = false,
		TouchInputEnabled = false,
		EasingStyle = Enum.EasingStyle.Exponential, TweenTime = 0.4,
		Parent = self.elements,
	})
end

function Window:_buildSettingsTab()
	self._settingsTab = Tab.new(self, { name = "Settings", _order = 1000, _isSettings = true })
	self._settingsTab:CreateSection({ name = "General" })
	self._settingsTab:CreateKeybind({
		name = "Toggle Keybind", value = self.settings.toggleKeybind,
		callback = function(key) self.settings.toggleKeybind = key; Persistence.SaveSettings(self.settings) end,
	})
	self._settingsTab:CreateSection({ name = "Window" })
	self._settingsTab:CreateToggle({
		name = "Keep window on screen",
		description = "Prevents the window from being dragged off screen",
		value = self.settings.keepOnScreen,
		callback = function(state) self.settings.keepOnScreen = state; Persistence.SaveSettings(self.settings) end,
	})
	self._settingsTab:CreateButton({
		name = "Reset Window Position",
		callback = function()
			Utility.Tween(self.main, Utility.TweenInfo(0.5), { Position = UDim2.new(0.5, 0, 0.5, 0) })
		end,
	})
	if next(self.configuration) ~= nil then
		self._settingsTab:CreateSection({ name = "Configurations" })
		local selected = Persistence.ListConfigs(self)[1]
		local configDropdown, nameInput
		local function refreshConfigs()
			local names = Persistence.ListConfigs(self)
			if configDropdown then configDropdown:Refresh(names) end
			if selected and not table.find(names, selected) then selected = names[1] end
			if selected and configDropdown then configDropdown:Set(selected, true) end
		end
		configDropdown = self._settingsTab:CreateDropdown({
			name = "Saved Configurations", options = Persistence.ListConfigs(self),
			value = selected, placeholder = "No saved configurations",
			callback = function(value) selected = value end,
		})
		nameInput = self._settingsTab:CreateInput({
			name = "Configuration Name",
			description = "Name a new configuration, or leave blank to overwrite the selected one.",
			placeholder = "e.g. PvP Setup",
		})
		self._settingsTab:CreateSection({ name = "Actions" })
		self._settingsTab:CreateButton({
			name = "Save Configuration",
			callback = function()
				local name = nameInput and nameInput.value or ""
				if name == "" then name = selected end
				if not name or name == "" then self:Notify({ title = "Name your configuration first" }); return end
				if Persistence.Save(self) then
					if nameInput then nameInput:Set("") end
					selected = name; refreshConfigs()
					self:Notify({ title = "Saved configuration", content = name })
				end
			end,
		})
		self._settingsTab:CreateButton({
			name = "Load Configuration",
			callback = function()
				if not selected or selected == "" then self:Notify({ title = "Pick a configuration to load" }); return end
				if Persistence.Load(self) then self:Notify({ title = "Loaded configuration", content = selected }) end
			end,
		})
		self._settingsTab:CreateButton({
			name = "Delete Configuration",
			callback = function()
				if not selected or selected == "" then return end
				if Persistence.DeleteConfig(self, selected) then refreshConfigs(); self:Notify({ title = "Deleted configuration", content = selected }) end
			end,
		})
	end
end

function Window:CreateTab(properties)
	local newTab = Tab.new(self, properties)
	table.insert(self.tabs, newTab)
	local isFirstVisible = true
	for _, tab in self.tabs do
		if tab ~= newTab and not tab._isSettings then isFirstVisible = false; break end
	end
	if isFirstVisible then newTab:Select(true) end
	return newTab
end

function Window:Notify(properties)
	properties = properties or {}
	local duration = properties.duration or 3
	if not self._notifications then
		self._notifications = self:Create("Frame", {
			Name = "Notifications", Size = UDim2.new(0, 280, 0, 600),
			Position = UDim2.new(1, -16, 1, -16), AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1, Parent = self.screenGui,
		})
		self:Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6), Parent = self._notifications,
		})
	end
	local notif = self:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = self.theme.ElementBackground,
		BorderSizePixel = 0, BackgroundTransparency = 0.05, Parent = self._notifications,
	})
	self:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = notif })
	self:Create("UIStroke", { Color = self.theme.ElementStroke, Transparency = 0.6, Parent = notif })
	self:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14),
		PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = notif,
	})
	if properties.title then
		self:Create("TextLabel", {
			Text = properties.title, FontFace = self.theme.TitleFont,
			Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
			TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = self.theme.TitlingColor,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = notif,
		})
	end
	if properties.content then
		self:Create("TextLabel", {
			Text = properties.content, FontFace = self.theme.Font,
			Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 0, 20),
			BackgroundTransparency = 1, TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = self.theme.PlaceholderColor,
			TextTruncate = Enum.TextTruncate.AtEnd, Parent = notif,
		})
	end
	notif.BackgroundTransparency = 1
	Utility.Tween(notif, Utility.TweenInfo(0.3), { BackgroundTransparency = 0.05 })
	task.delay(duration, function()
		Utility.Tween(notif, Utility.TweenInfo(0.3), { BackgroundTransparency = 1 })
		task.wait(0.3); notif:Destroy()
	end)
end

function Window:_registerControl(control)
	if not control.flag or control.flag == "" or control.forgetState then return end
	local flag = control.flag
	if self.controls[flag] then
		local n = 2
		while self.controls[flag .. n] do n += 1 end
		flag = flag .. n
	end
	control.flag = flag; self.controls[flag] = control
	return flag
end

function Window:_persist(control)
	if control.flag and not control.forgetState and self.configuration.autoSave and not self._loading then
		task.spawn(function() Persistence.Save(self) end)
	end
end

function Window:_interactive() return not self.animating and not self.hidden end

function Window:Show()
	if self.animating or not self.hidden then return end
	self.animating = true; self.hidden = false
	if self.configuration.autoLoad and not self._autoLoaded then
		self._autoLoaded = true; Persistence.Load(self)
	end
	if self.hasShownOnce then self:_quickRestore()
	else self.hasShownOnce = true; self:_firstShow() end
end

function Window:_firstShow()
	self.elements.Visible = true; self.tabList.Visible = true
	self.drag.bar.Visible = false; self.main.Visible = true
	Utility.Tween(self.main, Utility.TweenInfo(0.6), { BackgroundTransparency = 0, Size = UDim2.fromOffset(520, 460) })
	task.wait(0.4)
	Utility.Tween(self.windowShadow, Utility.TweenInfo(0.5), { Transparency = 0.6 })
	Utility.Tween(self.windowStroke, Utility.TweenInfo(0.5), { Transparency = self.theme.WindowStrokeTransparency })
	task.wait(0.2)
	if self.title then Utility.Tween(self.title, Utility.TweenInfo(0.4), { TextTransparency = 0 }) end
	if self.subtitleLabel then Utility.Tween(self.subtitleLabel, Utility.TweenInfo(0.4), { TextTransparency = 0.7 }) end
	for _, action in self.actionContainer:GetChildren() do
		if action:IsA("Frame") and action:FindFirstChild("ImageLabel") then
			Utility.Tween(action.ImageLabel, Utility.TweenInfo(0.4), { ImageTransparency = 0.6 })
		end
	end
	task.wait(0.15)
	for _, tab in self.tabs do
		if not tab._isSettings and tab.topbarItem then
			tab.topbarItem.Visible = true
			tab:_applyVisual(if self.selectedTab == tab then "selected" else "unselected", Utility.TweenInfo(0.4))
			task.wait(0.1)
		end
	end
	self:_revealElements(0.03, 0.6)
	task.wait(0.6)
	self.drag.bar.Visible = true
	Utility.Tween(self.drag.bar, Utility.TweenInfo(0.5), { BackgroundTransparency = 0.7, Size = UDim2.fromOffset(100, 4) })
	self.animating = false
end

function Window:_quickRestore()
	Utility.Tween(self.main, Utility.TweenInfo(0.4), { Size = UDim2.fromOffset(520, 460), Position = UDim2.new(0.5, 0, 0.5, 0) })
	task.delay(0.2, function()
		self.topbar.Visible = true; self.tabList.Visible = true; self.elements.Visible = true
		Utility.Tween(self.windowShadow, Utility.TweenInfo(0.3), { Transparency = 0.6 })
		Utility.Tween(self.windowStroke, Utility.TweenInfo(0.3), { Transparency = self.theme.WindowStrokeTransparency })
		if self.title then Utility.Tween(self.title, Utility.TweenInfo(0.3), { TextTransparency = 0 }) end
		if self.subtitleLabel then Utility.Tween(self.subtitleLabel, Utility.TweenInfo(0.3), { TextTransparency = 0.7 }) end
		for _, action in self.actionContainer:GetChildren() do
			if action:IsA("Frame") and action:FindFirstChild("ImageLabel") then
				Utility.Tween(action.ImageLabel, Utility.TweenInfo(0.3), { ImageTransparency = 0.6 })
			end
		end
		for _, tab in self.tabs do
			if not tab._isSettings and tab.topbarItem then
				tab.topbarItem.Visible = true
				tab:_applyVisual(if self.selectedTab == tab then "selected" else "unselected", Utility.TweenInfo(0.3))
			end
		end
		self:_revealElements(0.03, 0.4)
	end)
	self.drag.bar.Position = UDim2.new(0.5, 0, 0.5, 238)
	self.drag.bar.Size = UDim2.fromOffset(0, 4); self.drag.bar.Visible = true
	Utility.Tween(self.drag.bar, Utility.TweenInfo(0.4), { Size = UDim2.fromOffset(100, 4), BackgroundTransparency = 0.7 })
	task.delay(0.5, function() self.animating = false end)
end

function Window:Hide()
	if self.animating or self.hidden then return end
	self.animating = true; self.hidden = true
	Utility.Tween(self.main, Utility.TweenInfo(0.4), { Size = UDim2.fromOffset(520, 0) })
	Utility.Tween(self.windowShadow, Utility.TweenInfo(0.3), { Transparency = 1 })
	Utility.Tween(self.windowStroke, Utility.TweenInfo(0.3), { Transparency = 1 })
	if self.title then Utility.Tween(self.title, Utility.TweenInfo(0.2), { TextTransparency = 1 }) end
	if self.subtitleLabel then Utility.Tween(self.subtitleLabel, Utility.TweenInfo(0.2), { TextTransparency = 1 }) end
	Utility.Tween(self.drag.bar, Utility.TweenInfo(0.3), { Size = UDim2.fromOffset(0, 4), BackgroundTransparency = 1 })
	task.delay(0.35, function()
		self.topbar.Visible = false; self.elements.Visible = false
		self.tabList.Visible = false; self.drag.bar.Visible = false
		self.animating = false
	end)
end

function Window:ToggleHide()
	if self.animating then return end
	if self.hidden then self:Show() else self:Hide() end
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
			element:_setShown(true, true); staggered += 1
			if staggered <= maxStaggered then task.wait(perElementDelay) end
		else element:_setShown(true, false) end
	end
end

function Window:_fadeSelectedElementsOut()
	if self.selectedTab then
		for _, element in ipairs(self.selectedTab.elements) do element:_setShown(false, true) end
	end
end

function Window:_bindKeybind()
	Utility.Connect(UserInputService.InputBegan, function(input, processed)
		if processed then return end
		if input.KeyCode == self.settings.toggleKeybind then self:ToggleHide() end
	end)
end

function Window:_loadSettings()
	local saved = Persistence.LoadSettings()
	if saved then for key, value in saved do if self.settings[key] ~= nil then self.settings[key] = value end end end
end

function Window:_jumpTo(page) if page then self.elementsLayout:JumpTo(page) end end

function Window:Navigate(tab)
	if tab == nil then return end
	for _, candidate in self.tabs do
		if candidate == tab or candidate.name == tab then candidate:Select(); break end
	end
end

function Window:Create(className, properties, themeBindings)
	local instance = Instance.new(className)
	if themeBindings and self.theme then
		for property, value in themeBindings do
			if typeof(value) == "string" and self.theme[value] ~= nil then
				pcall(function() instance[property] = self.theme[value] end)
			end
		end
	end
	if properties then
		for property, value in properties do
			if property ~= "Parent" then pcall(function() instance[property] = value end) end
		end
	end
	if properties and properties.Parent then instance.Parent = properties.Parent end
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
	if index then table.remove(self.connections, index) end
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
		local ok, err = pcall(function() return fn(table.unpack(args, 1, args.n)) end)
		if ok then return end
		Utility.Tween(element.main, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { BackgroundColor3 = self.theme.ErrorColor })
		if element.title then element.title.Text = "Error, check console" end
		warn("[NexusUI] Error in " .. (element.__type or "element") .. " '" .. (element.name or "") .. "': " .. tostring(err))
		task.wait(1.5)
		if element.title then element.title.Text = element.name or "" end
		Utility.Tween(element.main, TweenInfo.new(0.4), { BackgroundColor3 = self.theme.ElementBackground })
	end)
end

function Window:StyleElementBody(main)
	self:Create("UIGradient", { Rotation = 270, Parent = main }, { Color = "ElementGradient" })
	self:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = main })
	return self:Create("UIStroke", { Transparency = 1, Parent = main }, { Color = "ElementStroke", Transparency = "ElementStrokeTransparency" })
end

function Window:_wireElementHover(element)
	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local theme = self.theme
	self:Connect(element.main.MouseEnter, function()
		if not self:_interactive() then return end
		Utility.Tween(element.stroke, info, { Transparency = theme.ElementStrokeHoverTransparency, Color = theme.ElementStrokeHover })
		if element.title then Utility.Tween(element.title, info, { TextColor3 = theme.ElementTextHoverColor }) end
		if element.hoverOverlay then Utility.Tween(element.hoverOverlay, info, { BackgroundTransparency = 0.96 }) end
	end)
	self:Connect(element.main.MouseLeave, function()
		Utility.Tween(element.stroke, info, { Transparency = theme.ElementStrokeTransparency, Color = theme.ElementStroke })
		if element.title then Utility.Tween(element.title, info, { TextColor3 = theme.ContentColor }) end
		if element.hoverOverlay then Utility.Tween(element.hoverOverlay, info, { BackgroundTransparency = 1 }) end
	end)
end

function Window:CreateHoverOverlay(parent)
	local overlay = self:Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, ZIndex = 1, Parent = parent,
	})
	self:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = overlay })
	return overlay
end

function Window:_reveal(instance, props, animate, info)
	if not instance then return end
	if animate then Utility.Tween(instance, info or TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), props)
	else for property, value in props do pcall(function() instance[property] = value end) end end
end

function Window:Unload()
	self.unloaded = true
	for i = #self.connections, 1, -1 do self.connections[i]:Disconnect() end
	for i = #self.instances, 1, -1 do self.instances[i]:Destroy() end
	table.clear(self.connections); table.clear(self.instances)
	table.clear(self.controls); table.clear(self.tabs)
end

-- ============================================================================
-- ENTRY POINT
-- ============================================================================
local NexusUI = {}
NexusUI.__index = NexusUI

function NexusUI:CreateWindow(properties)
	return Window.new(properties)
end

return NexusUI
