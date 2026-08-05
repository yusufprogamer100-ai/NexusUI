local Drag = {}
Drag.__index = Drag

local Utility = require(script.Parent.Parent.utility)

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

	Utility.Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.bar,
	})

	self:_bind()

	return self
end

function Drag:_bind()
	local uis = Utility.UserInputService

	Utility.Connect(self.window.topbar.InputBegan, function(input, processed)
		if processed then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not self.window:_interactive() then return end

		self.dragging = true
		self.relative = self.window.main.AbsolutePosition + self.window.main.AbsoluteSize * self.window.main.AnchorPoint - uis:GetMouseLocation()
	end)

	Utility.Connect(uis.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.dragging = false
		end
	end)

	Utility.Connect(uis.WindowFocusReleased, function()
		self.dragging = false
	end)

	Utility.Connect(Utility.RunService.RenderStepped, function()
		if not self.dragging then return end
		if not self.window:_interactive() then
			self.dragging = false
			return
		end

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
			self.window.main.Position.X.Scale,
			self.window.main.Position.X.Offset,
			self.window.main.Position.Y.Scale,
			self.window.main.Position.Y.Offset + (self.window.main.Size.Y.Offset / 2 + 8)
		)
	end)
end

return Drag
