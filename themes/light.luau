return {
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
