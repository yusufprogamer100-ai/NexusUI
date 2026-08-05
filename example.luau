local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/NexusUI/main/init.luau"))()

local Window = NexusUI:CreateWindow({
	Name = "NexusUI Demo",
	Subtitle = "Production-quality UI library",
	theme = "Default",
	configuration = {
		autoSave = true,
		autoLoad = true,
	},
})

local MainTab = Window:CreateTab({ name = "Main", icon = "rbxassetid://6023426926" })
local CombatTab = Window:CreateTab({ name = "Combat", icon = "rbxassetid://6023426926" })
local VisualsTab = Window:CreateTab({ name = "Visuals", icon = "rbxassetid://6023426926" })

MainTab:CreateSection({ name = "General" })

MainTab:CreateButton({
	name = "Click Me",
	description = "This is a demo button with a callback",
	callback = function()
		Window:Notify({
			title = "Button Clicked",
			content = "You pressed the demo button!",
			duration = 3,
		})
	end,
})

MainTab:CreateToggle({
	name = "Auto-Farm",
	description = "Automatically farm resources",
	value = false,
	flag = "autofarm",
	callback = function(value)
		print("Auto-Farm:", value)
	end,
})

MainTab:CreateSlider({
	name = "Walk Speed",
	description = "Adjust your walk speed",
	range = { 16, 100 },
	increment = 1,
	value = 16,
	suffix = "studs",
	flag = "walkspeed",
	callback = function(value)
		game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
	end,
})

MainTab:CreateDropdown({
	name = "Weapon Mode",
	description = "Select weapon mode",
	options = { "Auto", "Sword", "Gun", "Melee" },
	value = "Auto",
	flag = "weaponmode",
	callback = function(value)
		print("Weapon:", value)
	end,
})

MainTab:CreateInput({
	name = "Player Name",
	description = "Enter a player name",
	placeholder = "Username...",
	callback = function(value)
		print("Input:", value)
	end,
})

MainTab:CreateKeybind({
	name = "Panic Key",
	description = "Emergency toggle",
	value = Enum.KeyCode.P,
	callback = function(key)
		print("Keybind pressed:", key)
	end,
})

CombatTab:CreateSection({ name = "Combat Settings" })

CombatTab:CreateToggle({
	name = "Silent Aim",
	description = "Silently redirect projectiles",
	flag = "silentaim",
	callback = function(value)
		print("Silent Aim:", value)
	end,
})

CombatTab:CreateSlider({
	name = "FOV",
	description = "Aimbot field of view",
	range = { 30, 360 },
	increment = 5,
	value = 120,
	suffix = "deg",
	flag = "fov",
	callback = function(value)
		print("FOV:", value)
	end,
})

CombatTab:CreateDropdown({
	name = "Target Part",
	options = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" },
	value = "Head",
	callback = function(value)
		print("Target:", value)
	end,
})

VisualsTab:CreateSection({ name = "ESP" })

VisualsTab:CreateToggle({
	name = "Enable ESP",
	description = "Show player locations through walls",
	flag = "esp_enabled",
	callback = function(value)
		print("ESP:", value)
	end,
})

VisualsTab:CreateSlider({
	name = "ESP Distance",
	range = { 100, 5000 },
	increment = 100,
	value = 1000,
	suffix = "studs",
	flag = "esp_distance",
})

VisualsTab:CreateDropdown({
	name = "ESP Style",
	options = { "Box", "Skeleton", "Head Circle", "3D Box" },
	value = "Box",
})

Window:Show()
