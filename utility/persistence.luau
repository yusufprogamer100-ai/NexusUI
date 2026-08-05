local Persistence = {}

local HttpService = game:GetService("HttpService")

local function getFolder()
	return "NexusUI"
end

function Persistence.GetPath(windowName)
	return getFolder() .. "/" .. (windowName or "config") .. ".json"
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

	local success, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if success then
		writefile(path, encoded)
		return true
	end
	return false
end

function Persistence.Load(window)
	local path = Persistence.GetPath(window.name)

	if not isfile(path) then
		return false
	end

	local success, decoded = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)

	if not success or typeof(decoded) ~= "table" then
		return false
	end

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
	local folder = getFolder() .. "/"
	local configs = {}

	if not isfolder(getFolder()) then
		return configs
	end

	for _, file in listfiles(folder) do
		if string.match(file, "%.json$") then
			local name = string.match(file, "^(.+)%.json$")
			table.insert(configs, name)
		end
	end

	return configs
end

function Persistence.DeleteConfig(window, name)
	local path = getFolder() .. "/" .. name .. ".json"
	if isfile(path) then
		delfile(path)
		return true
	end
	return false
end

function Persistence.SaveSettings(settings)
	local path = getFolder() .. "/_settings.json"
	local data = {}
	for key, value in settings do
		if typeof(value) == "EnumItem" then
			data[key] = value.Name
		else
			data[key] = value
		end
	end

	local success, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if success then
		writefile(path, encoded)
		return true
	end
	return false
end

function Persistence.LoadSettings()
	local path = getFolder() .. "/_settings.json"

	if not isfile(path) then
		return nil
	end

	local success, decoded = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)

	if success and typeof(decoded) == "table" then
		return decoded
	end
	return nil
end

return Persistence
