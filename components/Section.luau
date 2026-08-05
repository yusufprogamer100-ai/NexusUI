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

	self.tab:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 6),
		Parent = self.main,
	})
end

function Section:_setShown(shown, animate)
	local ts = self.window and game:GetService("TweenService")
	if not ts then return end

	if shown then
		ts:Create(self.title, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			TextTransparency = 0.3,
		}):Play()
	else
		ts:Create(self.title, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			TextTransparency = 1,
		}):Play()
	end
end

return Section
