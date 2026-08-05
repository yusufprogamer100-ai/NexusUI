local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yusufprogamer100-ai/NexusUI/main/main.luau"))()

local Window = NexusUI:CreateWindow({
	Name = "NexusUI v1.0",
	Subtitle = "5000+ lines of production-quality UI",
	theme = "Default", -- Default, Ocean, Light, Neon, Pastel, Midnight, Forest, Sunset, Cyberpunk
	configuration = {
		autoSave = true,
		autoLoad = true,
	},
})

-- ============================================================================
-- TABS
-- ============================================================================
local MainTab = Window:CreateTab({ name = "Main", icon = "rbxassetid://6023426926" })
local ElementsTab = Window:CreateTab({ name = "Elements", icon = "rbxassetid://6023426926" })
local ColorTab = Window:CreateTab({ name = "Colors", icon = "rbxassetid://6023426926" })
local ThemesTab = Window:CreateTab({ name = "Themes", icon = "rbxassetid://6023426926" })
local SettingsTab = Window:CreateTab({ name = "Settings", icon = "rbxassetid://6023426926" })

-- ============================================================================
-- MAIN TAB
-- ============================================================================
MainTab:CreateSection({ name = "General" })

MainTab:CreateParagraph({
	name = "Welcome to NexusUI",
	description = "This is a full-featured UI library with 12+ element types, 9 themes, and 5000+ lines of code. Everything is loadstring-ready.",
})

MainTab:CreateSeparator({ name = "Actions" })

MainTab:CreateButton({
	name = "Show Notification",
	description = "Push a notification to the queue",
	callback = function()
		Window:Notify({
			title = "Hello from NexusUI!",
			content = "This is a notification with auto-dismiss.",
			duration = 4,
			type = "info",
		})
	end,
})

MainTab:CreateButton({
	name = "Success Notification",
	description = "Show a success-type notification",
	callback = function()
		Window:Notify({
			title = "Operation Complete",
			content = "Your settings have been saved.",
			type = "success",
		})
	end,
})

MainTab:CreateButton({
	name = "Error Notification",
	description = "Show an error-type notification",
	callback = function()
		Window:Notify({
			title = "Something went wrong",
			content = "Check the console for details.",
			type = "error",
		})
	end,
})

MainTab:CreateButton({
	name = "Warning Notification",
	description = "Show a warning-type notification",
	callback = function()
		Window:Notify({
			title = "Low Health",
			content = "Consider healing before proceeding.",
			type = "warning",
		})
	end,
})

MainTab:CreateButton({
	name = "Shake Window",
	description = "Shake the window as a visual effect",
	callback = function()
		local uiLib = gethui and gethui() or game:GetService("CoreGui")
		for _, gui in uiLib:GetChildren() do
			if gui:IsA("ScreenGui") and gui.Name ~= "RobloxGui" then
				for _, frame in gui:GetDescendants() do
					if frame:IsA("Frame") and frame.Name == Window.name then
						-- simple shake via position offset
						local pos = frame.Position
						for i = 1, 6 do
							task.delay(i * 0.04, function()
								frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + (math.random(-4, 4)), pos.Y.Scale, pos.Y.Offset + (math.random(-4, 4)))
							end)
						end
						task.delay(0.3, function() frame.Position = pos end)
					end
				end
			end
		end
	end,
})

MainTab:CreateSeparator({ name = "Toggles & Sliders" })

MainTab:CreateToggle({
	name = "Auto-Farm",
	description = "Automatically farm resources",
	value = false,
	flag = "autofarm",
	callback = function(value)
		print("[NexusUI] Auto-Farm:", value)
	end,
})

MainTab:CreateToggle({
	name = "Auto-Attack",
	description = "Attack enemies automatically",
	value = true,
	flag = "autoattack",
	callback = function(value)
		print("[NexusUI] Auto-Attack:", value)
	end,
})

MainTab:CreateSlider({
	name = "Walk Speed",
	description = "Adjust your walk speed",
	range = { 16, 200 },
	increment = 1,
	value = 16,
	suffix = "studs",
	flag = "walkspeed",
	callback = function(value)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = value
		end
	end,
})

MainTab:CreateSlider({
	name = "Jump Power",
	description = "Adjust jump height",
	range = { 50, 300 },
	increment = 5,
	value = 50,
	suffix = "studs",
	flag = "jumppower",
	callback = function(value)
		local char = game.Players.LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.JumpPower = value
		end
	end,
})

MainTab:CreateSlider({
	name = "FOV Slider",
	description = "Field of view",
	range = { 30, 120 },
	increment = 1,
	value = 70,
	suffix = "deg",
	flag = "fov",
	callback = function(value)
		game.Workspace.Camera.FieldOfView = value
	end,
})

MainTab:CreateSlider({
	name = "Volume",
	description = "Master volume",
	range = { 0, 100 },
	increment = 5,
	value = 80,
	suffix = "%",
	flag = "volume",
	callback = function(value)
		print("[NexusUI] Volume:", value .. "%")
	end,
})

MainTab:CreateSeparator({ name = "Dropdowns & Inputs" })

MainTab:CreateDropdown({
	name = "Weapon Mode",
	description = "Select weapon mode",
	options = { "Auto", "Sword", "Gun", "Melee", "Magic" },
	value = "Auto",
	flag = "weaponmode",
	callback = function(value)
		print("[NexusUI] Weapon:", value)
	end,
})

MainTab:CreateDropdown({
	name = "Multi Target",
	description = "Select multiple targets",
	options = { "Head", "Torso", "Arms", "Legs" },
	value = { "Head" },
	multiSelect = true,
	flag = "multitarget",
	callback = function(value)
		print("[NexusUI] Targets:", table.concat(value, ", "))
	end,
})

MainTab:CreateInput({
	name = "Player Name",
	description = "Enter a player name to target",
	placeholder = "Username...",
	callback = function(value)
		print("[NexusUI] Input:", value)
	end,
})

MainTab:CreateInput({
	name = "Webhook URL",
	description = "Discord webhook for notifications",
	placeholder = "https://discord.com/api/webhooks/...",
	callback = function(value)
		print("[NexusUI] Webhook:", value)
	end,
})

MainTab:CreateKeybind({
	name = "Panic Key",
	description = "Emergency toggle - hides the UI",
	value = Enum.KeyCode.P,
	callback = function(key)
		print("[NexusUI] Panic key pressed:", key.Name)
	end,
})

MainTab:CreateKeybind({
	name = "Toggle ESP",
	description = "Toggle ESP on/off",
	value = Enum.KeyCode.E,
	callback = function(key)
		print("[NexusUI] ESP toggle:", key.Name)
	end,
})

-- ============================================================================
-- ELEMENTS TAB (all element types)
-- ============================================================================
ElementsTab:CreateSection({ name = "All Element Types" })

ElementsTab:CreateParagraph({
	name = "Component Showcase",
	description = "Every component type available in NexusUI. Each one supports icons, descriptions, flags, and callbacks.",
})

ElementsTab:CreateSeparator({ name = "Basic Elements" })

ElementsTab:CreateButton({
	name = "Button",
	description = "A clickable button element",
	callback = function()
		Window:Notify({ title = "Button clicked!" })
	end,
})

ElementsTab:CreateToggle({
	name = "Toggle",
	description = "A switch that toggles on/off",
	value = true,
	callback = function(v) print("Toggle:", v) end,
})

ElementsTab:CreateSlider({
	name = "Slider",
	description = "A draggable value slider",
	range = { 0, 100 },
	value = 50,
	suffix = "%",
	callback = function(v) print("Slider:", v) end,
})

ElementsTab:CreateDropdown({
	name = "Dropdown",
	description = "Select from a list of options",
	options = { "Option A", "Option B", "Option C" },
	value = "Option A",
	callback = function(v) print("Dropdown:", v) end,
})

ElementsTab:CreateInput({
	name = "Input",
	description = "Text input field",
	placeholder = "Type here...",
	callback = function(v) print("Input:", v) end,
})

ElementsTab:CreateKeybind({
	name = "Keybind",
	description = "Record a keybind",
	value = Enum.KeyCode.F,
	callback = function(v) print("Keybind:", v.Name) end,
})

ElementsTab:CreateColorPicker({
	name = "Color Picker",
	description = "Pick a color with full HSV control",
	color = Color3.fromRGB(100, 150, 255),
	callback = function(color)
		print("Color:", color)
	end,
})

ElementsTab:CreateProgressBar({
	name = "Progress Bar",
	description = "Animated progress indicator",
	value = 65,
	max = 100,
	suffix = "%",
	callback = function(v) print("Progress:", v) end,
})

ElementsTab:CreateSearchDropdown({
	name = "Search Dropdown",
	description = "Dropdown with search filtering",
	options = { "Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape", "Honeydew", "Kiwi", "Lemon" },
	placeholder = "Search fruits...",
	callback = function(v) print("Selected:", v) end,
})

ElementsTab:CreateParagraph({
	name = "Another Paragraph",
	description = "Paragraphs automatically resize based on content length. They support multi-line text and descriptions.",
})

ElementsTab:CreateSeparator({ name = "With Descriptions" })

ElementsTab:CreateButton({
	name = "Described Button",
	description = "This button has a description below it explaining what it does in more detail.",
	callback = function() end,
})

ElementsTab:CreateToggle({
	name = "Described Toggle",
	description = "This toggle also has a description. Descriptions appear below the element title.",
	value = false,
	callback = function(v) print("Described:", v) end,
})

-- ============================================================================
-- COLOR TAB
-- ============================================================================
ColorTab:CreateSection({ name = "Color Pickers" })

ColorTab:CreateParagraph({
	name = "Color System",
	description = "NexusUI includes a full HSV color picker with gradient panels, hue bar, hex display, and RGB readout.",
})

ColorTab:CreateSeparator({ name = "Pickers" })

ColorTab:CreateColorPicker({
	name = "ESP Color",
	description = "Main ESP box color",
	color = Color3.fromRGB(255, 0, 0),
	flag = "espcolor",
	callback = function(color)
		print("[Color] ESP:", color)
	end,
})

ColorTab:CreateColorPicker({
	name = "Team Color",
	description = "Color for teammates",
	color = Color3.fromRGB(0, 150, 255),
	flag = "teamcolor",
	callback = function(color)
		print("[Color] Team:", color)
	end,
})

ColorTab:CreateColorPicker({
	name = "Enemy Color",
	description = "Color for enemies",
	color = Color3.fromRGB(255, 50, 50),
	flag = "enemycolor",
	callback = function(color)
		print("[Color] Enemy:", color)
	end,
})

ColorTab:CreateColorPicker({
	name = "Custom Theme",
	description = "Pick any color for custom theming",
	color = Color3.fromRGB(120, 80, 200),
	callback = function(color)
		print("[Color] Custom:", color)
	end,
})

ColorTab:CreateSeparator({ name = "Presets" })

ColorTab:CreateButton({
	name = "Set Red",
	callback = function()
		-- Access flags to programmatically set colors
		print("Set all colors to red")
	end,
})

ColorTab:CreateButton({
	name = "Set Blue",
	callback = function()
		print("Set all colors to blue")
	end,
})

ColorTab:CreateButton({
	name = "Set Green",
	callback = function()
		print("Set all colors to green")
	end,
})

-- ============================================================================
-- THEMES TAB
-- ============================================================================
ThemesTab:CreateSection({ name = "Available Themes" })

ThemesTab:CreateParagraph({
	name = "9 Built-in Themes",
	description = "Default, Ocean, Light, Neon, Pastel, Midnight, Forest, Sunset, Cyberpunk. Change theme by passing theme = \"ThemeName\" to CreateWindow.",
})

ThemesTab:CreateSeparator({ name = "Theme Preview" })

ThemesTab:CreateParagraph({
	name = "Default",
	description = "Dark theme with blue accents. The original NexusUI look.",
})

ThemesTab:CreateParagraph({
	name = "Ocean",
	description = "Deep blue theme with ocean-inspired gradients and calm tones.",
})

ThemesTab:CreateParagraph({
	name = "Light",
	description = "Clean white theme for bright environments and daytime use.",
})

ThemesTab:CreateParagraph({
	name = "Neon",
	description = "Electric cyan accents on dark background. Cyberpunk-inspired.",
})

ThemesTab:CreateParagraph({
	name = "Pastel",
	description = "Soft purple and lavender tones. Gentle on the eyes.",
})

ThemesTab:CreateParagraph({
	name = "Midnight",
"description = "Deep purple-blue tones. Darker and more subdued.",
})

ThemesTab:CreateParagraph({
	name = "Forest",
	description = "Natural green tones. Earthy and organic feel.",
})

ThemesTab:CreateParagraph({
	name = "Sunset",
	description = "Warm orange and red tones. Inspired by golden hour.",
})

ThemesTab:CreateParagraph({
	name = "Cyberpunk",
	description = "Hot pink accents on black. Bold and aggressive.",
})

ThemesTab:CreateSeparator({ name = "Theme Switcher Demo" })

ThemesTab:CreateDropdown({
	name = "Preview Theme",
	description = "This dropdown shows theme names",
	options = { "Default", "Ocean", "Light", "Neon", "Pastel", "Midnight", "Forest", "Sunset", "Cyberpunk" },
	value = "Default",
	callback = function(value)
		print("[NexusUI] Theme preview:", value)
	end,
})

-- ============================================================================
-- SETTINGS TAB (built-in)
-- ============================================================================
SettingsTab:CreateSection({ name = "About" })

SettingsTab:CreateParagraph({
	name = "NexusUI v1.0",
	description = "A production-quality Roblox UI library inspired by Rayfield Gen2 and WindUI. 5000+ lines, 12+ element types, 9 themes, loadstring-ready.",
})

SettingsTab:CreateParagraph({
	name = "Credits",
	description = "Created by yusufprogamer100. Inspired by Rayfield Gen2, WindUI, and modern UI design patterns.",
})

SettingsTab:CreateSeparator({ name = "Links" })

SettingsTab:CreateButton({
	name = "View on GitHub",
	description = "Open the GitHub repository",
	callback = function()
		print("GitHub: https://github.com/yusufprogamer100-ai/NexusUI")
	end,
})

SettingsTab:CreateButton({
	name = "Copy Loadstring",
	description = "Copy the loadstring to your clipboard",
	callback = function()
		if setclipboard then
			setclipboard('local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yusufprogamer100-ai/NexusUI/main/main.luau"))()')
			Window:Notify({ title = "Copied to clipboard!", type = "success" })
		else
			Window:Notify({ title = "setclipboard not available", type = "error" })
		end
	end,
})

SettingsTab:CreateSeparator({ name = "Statistics" })

SettingsTab:CreateParagraph({
	name = "File Stats",
	description = "main.luau: 5000+ lines | 12 component types | 9 themes | 60+ utility functions | Single file, zero dependencies",
})

-- ============================================================================
-- SHOW WINDOW
-- ============================================================================
Window:Show()
