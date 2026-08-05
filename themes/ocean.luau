return {
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
