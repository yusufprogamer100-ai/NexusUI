local Button = {}
Button.__index = Button
Button.__type = "Button"

local Utility = require(script.Parent.Parent.utility)

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

	if self.description then
		self:_buildDescription()
	end

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

	self.window:_wireElementHover(self)

	self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
		Utility.Tween(self.stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Transparency = 1,
		})
		Utility.Tween(self.main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, -26, 0, 43),
		})

		self.window:_runGuarded(self, self.callback)

		task.wait(0.1)

		Utility.Tween(self.main, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, -20, 0, 43),
		})
		Utility.Tween(self.stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Transparency = self.window.theme.ElementStrokeTransparency,
		})
	end)
end

function Button:_buildDescription()
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

function Button:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil

	if shown then
		w:_reveal(self.main, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info)
		end
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then
			w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info)
		end
	end
end

return Button
