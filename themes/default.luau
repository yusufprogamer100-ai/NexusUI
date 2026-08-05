return {
	Name = "Default",

	-- Window
	WindowBackground = Color3.fromRGB(18, 18, 24),
	WindowStroke = Color3.fromRGB(40, 40, 55),
	WindowStrokeTransparency = 0.5,
	CornerRoundness = UDim.new(0, 12),

	-- Tab Bar
	TabBarBackground = Color3.fromRGB(14, 14, 20),
	TabBackground = Color3.fromRGB(25, 25, 35),
	TabBackgroundHover = Color3.fromRGB(32, 32, 45),
	TabBackgroundSelected = Color3.fromRGB(35, 35, 50),
	TabStroke = Color3.fromRGB(50, 50, 65),
	TabStrokeSelected = Color3.fromRGB(80, 90, 140),
	TabTextColor = Color3.fromRGB(140, 145, 170),
	TabTextColorSelected = Color3.fromRGB(220, 225, 255),

	-- Elements
	ElementBackground = Color3.fromRGB(25, 25, 35),
	ElementStroke = Color3.fromRGB(40, 40, 55),
	ElementStrokeTransparency = 0.65,
	ElementStrokeHover = Color3.fromRGB(80, 90, 140),
	ElementStrokeHoverTransparency = 0.3,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(200, 205, 230),
	ElementTextHoverColor = Color3.fromRGB(255, 255, 255),
	ElementGradient = ColorSequence.new(Color3.fromRGB(28, 28, 38), Color3.fromRGB(22, 22, 32)),

	-- Accent
	AccentColor = Color3.fromRGB(80, 100, 220),
	AccentStroke = Color3.fromRGB(100, 120, 240),
	AccentGlow = 0.7,

	-- Toggle
	ToggleTrack = Color3.fromRGB(40, 40, 55),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(120, 125, 150),
	ToggleKnobOffTransparency = 0.2,

	-- Slider
	SliderBackground = Color3.fromRGB(35, 35, 48),
	SliderBackgroundHover = Color3.fromRGB(42, 42, 58),
	SliderProgress = ColorSequence.new(Color3.fromRGB(70, 90, 200), Color3.fromRGB(100, 120, 240)),
	SliderHandle = Color3.fromRGB(255, 255, 255),
	SliderStroke = Color3.fromRGB(80, 100, 220),

	-- Dropdown
	DropdownHighlight = Color3.fromRGB(30, 30, 42),

	-- Input
	FieldBackground = Color3.fromRGB(20, 20, 28),
	FieldStroke = Color3.fromRGB(40, 40, 55),
	FieldStrokeFocus = Color3.fromRGB(80, 100, 220),

	-- Text
	TitlingColor = Color3.fromRGB(220, 225, 255),
	PlaceholderColor = Color3.fromRGB(100, 105, 130),

	-- Status
	ErrorColor = Color3.fromRGB(200, 60, 60),
	ErrorStrokeColor = Color3.fromRGB(240, 80, 80),
	SuccessColor = Color3.fromRGB(60, 180, 80),

	-- Fonts
	Font = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Medium),
	TitleFont = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Bold),
}
