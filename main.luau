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

-- Polyfill: table.clone (some executors don't have it)
if not table.clone then
	function table.clone(t)
		local clone = {}
		for k, v in t do
			if typeof(v) == "table" then
				clone[k] = table.clone(v)
			else
				clone[k] = v
			end
		end
		return clone
	end
end

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

function Utility.DeepClone(original)
	local clone = {}
	for key, value in original do
		if typeof(value) == "table" then
			clone[key] = Utility.DeepClone(value)
		else
			clone[key] = value
		end
	end
	return clone
end

function Utility.MergeTables(base, override)
	local result = Utility.DeepClone(base)
	for key, value in override do
		if typeof(value) == "table" and typeof(result[key]) == "table" then
			result[key] = Utility.MergeTables(result[key], value)
		else
			result[key] = value
		end
	end
	return result
end

function Utility.FormatNumber(n)
	if n >= 1e9 then return string.format("%.1fB", n / 1e9)
	elseif n >= 1e6 then return string.format("%.1fM", n / 1e6)
	elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
	else return tostring(n) end
end

function Utility.ClampVector2(v, min, max)
	return Vector2.new(
		math.clamp(v.X, min.X, max.X),
		math.clamp(v.Y, min.Y, max.Y)
	)
end

function Utility.Lerp(a, b, t)
	return a + (b - a) * math.clamp(t, 0, 1)
end

function Utility.InverseLerp(a, b, v)
	if b - a == 0 then return 0 end
	return math.clamp((v - a) / (b - a), 0, 1)
end

function Utility.Remap(value, fromMin, fromMax, toMin, toMax)
	local t = Utility.InverseLerp(fromMin, fromMax, value)
	return Utility.Lerp(toMin, toMax, t)
end

function Utility.RoundTo(value, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(value * mult + 0.5) / mult
end

function Utility.GenerateUID()
	return HttpService:GenerateGUID(false)
end

function Utility.Wait(seconds)
	task.wait(seconds or 0)
end

function Utility.SafeCall(fn, ...)
	local success, result = pcall(fn, ...)
	if success then return result end
	warn("[NexusUI] SafeCall error:", result)
	return nil
end

function Utility.FadeInstance(instance, duration, targetTransparency, properties)
	properties = properties or {}
	local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local goals = { BackgroundTransparency = targetTransparency }
	for prop, val in properties do goals[prop] = val end
	return Utility.Tween(instance, info, goals)
end

function Utility.SlideInstance(instance, duration, targetPosition)
	local info = TweenInfo.new(duration or 0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	return Utility.Tween(instance, info, { Position = targetPosition })
end

function Utility.ScaleInstance(instance, duration, targetSize)
	local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	return Utility.Tween(instance, info, { Size = targetSize })
end

function Utility.ColorLerp(colorA, colorB, t)
	t = math.clamp(t, 0, 1)
	return Color3.new(
		colorA.R + (colorB.R - colorA.R) * t,
		colorA.G + (colorB.G - colorA.G) * t,
		colorA.B + (colorB.B - colorA.B) * t
	)
end

function Utility.GetRelativePosition(instance, anchor)
	anchor = anchor or Vector2.new(0.5, 0.5)
	local absPos = instance.AbsolutePosition
	local absSize = instance.AbsoluteSize
	return absPos + absSize * anchor
end

function Utility.IsMouseOver(instance)
	local mouse = UserInputService:GetMouseLocation()
	local absPos = instance.AbsolutePosition
	local absSize = instance.AbsoluteSize
	return mouse.X >= absPos.X and mouse.X <= absPos.X + absSize.X
		and mouse.Y >= absPos.Y and mouse.Y <= absPos.Y + absSize.Y
end

function Utility.GetCorners(instance)
	local pos = instance.AbsolutePosition
	local size = instance.AbsoluteSize
	return {
		TopLeft = pos,
		TopRight = pos + Vector2.new(size.X, 0),
		BottomLeft = pos + Vector2.new(0, size.Y),
		BottomRight = pos + size,
		Center = pos + size * 0.5,
	}
end

function Utility.AnimateSequence(instances, delay, duration, fromProps, toProps)
	for i, instance in instances do
		task.delay(delay * (i - 1), function()
			local info = TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			Utility.Tween(instance, info, toProps)
		end)
	end
end

function Utility.StaggerReveal(instances, perElementDelay, duration, fromProps, toProps)
	for i, instance in instances do
		task.delay(perElementDelay * (i - 1), function()
			Utility.AnimateSequence({ instance }, 0, duration, fromProps, toProps)
		end)
	end
end

function Utility.BounceEffect(instance, scale, duration)
	scale = scale or 1.1
	duration = duration or 0.3
	local originalSize = instance.Size
	Utility.Tween(instance, TweenInfo.new(duration * 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * scale, originalSize.Y.Scale, originalSize.Y.Offset * scale),
	})
	task.delay(duration * 0.4, function()
		Utility.Tween(instance, TweenInfo.new(duration * 0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = originalSize,
		})
	end)
end

function Utility.PulseEffect(instance, property, from, to, duration)
	duration = duration or 0.5
	Utility.Tween(instance, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { [property] = to })
	task.delay(duration * 0.5, function()
		Utility.Tween(instance, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { [property] = from })
	end)
end

function Utility.ShakeEffect(instance, intensity, duration, callback)
	intensity = intensity or 4
	duration = duration or 0.3
	local originalPos = instance.Position
	local steps = math.floor(duration / 0.03)
	for i = 1, steps do
		task.delay(0.03 * (i - 1), function()
			local offsetX = (math.random() - 0.5) * intensity * 2
			local offsetY = (math.random() - 0.5) * intensity * 2
			instance.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + offsetX, originalPos.Y.Scale, originalPos.Y.Offset + offsetY)
		end)
	end
	task.delay(duration, function()
		instance.Position = originalPos
		if callback then callback() end
	end)
end

function Utility.FlashEffect(instance, color, duration)
	duration = duration or 0.3
	local originalColor = instance.BackgroundColor3
	Utility.Tween(instance, TweenInfo.new(duration * 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundColor3 = color })
	task.delay(duration * 0.3, function()
		Utility.Tween(instance, TweenInfo.new(duration * 0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundColor3 = originalColor })
	end)
end

function Utility.GradientShift(gradient, duration, newColor)
	duration = duration or 0.5
	Utility.Tween(gradient, TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Color = newColor })
end

function Utility.RotateEffect(instance, angle, duration, easingStyle)
	duration = duration or 0.5
	easingStyle = easingStyle or Enum.EasingStyle.Exponential
	Utility.Tween(instance, TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out), { Rotation = angle })
end

function Utility.Countdown(seconds, onTick, onComplete)
	task.spawn(function()
		for i = seconds, 0, -1 do
			if onTick then onTick(i) end
			task.wait(1)
		end
		if onComplete then onComplete() end
	end)
end

function Utility.BatchDestroy(instances, delay)
	delay = delay or 0.05
	for i, instance in instances do
		task.delay(delay * (i - 1), function()
			if instance and instance.Parent then instance:Destroy() end
		end)
	end
end

function Utility.CreateGradient(stops, rotation)
	local sequence = {}
	for i, stop in stops do
		table.insert(sequence, ColorSequenceKeypoint.new(stop[1], stop[2]))
	end
	return ColorSequence.new(sequence)
end

function Utility.CreateNumberGradient(stops, rotation)
	local sequence = {}
	for i, stop in stops do
		table.insert(sequence, NumberSequenceKeypoint.new(stop[1], stop[2]))
	end
	return NumberSequence.new(sequence)
end

function Utility.TableShallowCopy(t)
	local copy = {}
	for k, v in t do copy[k] = v end
	return copy
end

function Utility.TableFilter(t, predicate)
	local result = {}
	for _, v in t do
		if predicate(v) then table.insert(result, v) end
	end
	return result
end

function Utility.TableMap(t, fn)
	local result = {}
	for i, v in t do result[i] = fn(v, i) end
	return result
end

function Utility.TableFind(t, predicate)
	for i, v in t do
		if predicate(v, i) then return v, i end
	end
	return nil, nil
end

function Utility.TableEvery(t, predicate)
	for i, v in t do
		if not predicate(v, i) then return false end
	end
	return true
end

function Utility.TableSome(t, predicate)
	for i, v in t do
		if predicate(v, i) then return true end
	end
	return false
end

function Utility.TableFlatten(t)
	local result = {}
	for _, v in t do
		if typeof(v) == "table" then
			for _, item in Utility.TableFlatten(v) do table.insert(result, item) end
		else
			table.insert(result, v)
		end
	end
	return result
end

function Utility.TableUnique(t)
	local seen = {}
	local result = {}
	for _, v in t do
		if not seen[v] then
			seen[v] = true
			table.insert(result, v)
		end
	end
	return result
end

function Utility.TableChunk(t, size)
	local chunks = {}
	for i = 1, #t, size do
		local chunk = {}
		for j = i, math.min(i + size - 1, #t) do
			table.insert(chunk, t[j])
		end
		table.insert(chunks, chunk)
	end
	return chunks
end

function Utility.TableRotate(t, direction)
	direction = direction or 1
	if direction > 0 then
		local first = table.remove(t, 1)
		table.insert(t, first)
	else
		local last = table.remove(t)
		table.insert(t, 1, last)
	end
	return t
end

function Utility.TableMin(t, selector)
	selector = selector or function(v) return v end
	local minVal, minItem = math.huge, nil
	for _, v in t do
		local val = selector(v)
		if val < minVal then minVal = val; minItem = v end
	end
	return minItem, minVal
end

function Utility.TableMax(t, selector)
	selector = selector or function(v) return v end
	local maxVal, maxItem = -math.huge, nil
	for _, v in t do
		local val = selector(v)
		if val > maxVal then maxVal = val; maxItem = v end
	end
	return maxItem, maxVal
end

function Utility.TableSum(t, selector)
	selector = selector or function(v) return v end
	local sum = 0
	for _, v in t do sum += selector(v) end
	return sum
end

function Utility.TableAverage(t, selector)
	selector = selector or function(v) return v end
	if #t == 0 then return 0 end
	return Utility.TableSum(t, selector) / #t
end

function Utility.TableGroupBy(t, keyFn)
	local groups = {}
	for _, v in t do
		local key = keyFn(v)
		if not groups[key] then groups[key] = {} end
		table.insert(groups[key], v)
	end
	return groups
end

function Utility.TableSortByKey(t, key, descending)
	table.sort(t, function(a, b)
		if descending then return a[key] > b[key]
		else return a[key] < b[key] end
	end)
	return t
end

function Utility.TableReverse(t)
	local reversed = {}
	for i = #t, 1, -1 do table.insert(reversed, t[i]) end
	return reversed
end

function Utility.TableZip(...)
	local tables = { ... }
	local length = math.max(Utility.TableMap(tables, function(t) return #t end))
	local result = {}
	for i = 1, length do
		local row = {}
		for _, t in tables do row[#row + 1] = t[i] end
		result[#result + 1] = row
	end
	return result
end

function Utility.TableUnzip(t)
	local cols = {}
	for _, row in t do
		for i, val in row do
			if not cols[i] then cols[i] = {} end
			cols[i][#cols[i] + 1] = val
		end
	end
	return cols
end

function Utility.TablePick(t, keys)
	local result = {}
	for _, key in keys do result[key] = t[key] end
	return result
end

function Utility.TableOmit(t, keys)
	local result = {}
	local omitSet = {}
	for _, key in keys do omitSet[key] = true end
	for k, v in t do
		if not omitSet[k] then result[k] = v end
	end
	return result
end

function Utility.TableIsEmpty(t)
	return next(t) == nil
end

function Utility.TableSize(t)
	local count = 0
	for _ in t do count += 1 end
	return count
end

function Utility.TableKeys(t)
	local keys = {}
	for k in t do keys[#keys + 1] = k end
	return keys
end

function Utility.TableValues(t)
	local values = {}
	for _, v in t do values[#values + 1] = v end
	return values
end

function Utility.TableContains(t, value)
	for _, v in t do
		if v == value then return true end
	end
	return false
end

function Utility.TableIndexOf(t, value)
	for i, v in t do
		if v == value then return i end
	end
	return nil
end

function Utility.TableRemoveValue(t, value)
	local idx = Utility.TableIndexOf(t, value)
	if idx then table.remove(t, idx) end
	return idx
end

function Utility.TableInsertUnique(t, value)
	if not Utility.TableContains(t, value) then
		table.insert(t, value)
		return true
	end
	return false
end

function Utility.TableShuffle(t)
	local shuffled = Utility.TableShallowCopy(t)
	for i = #shuffled, 2, -1 do
		local j = math.random(1, i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	return shuffled
end

function Utility.TableSample(t, n)
	n = n or 1
	local shuffled = Utility.TableShuffle(t)
	local sample = {}
	for i = 1, math.min(n, #shuffled) do sample[i] = shuffled[i] end
	return sample
end

function Utility.TableFlattenDeep(t)
	local result = {}
	local function recurse(arr)
		for _, v in arr do
			if typeof(v) == "table" then recurse(v)
			else result[#result + 1] = v end
		end
	end
	recurse(t)
	return result
end

function Utility.TableCompact(t)
	local result = {}
	for _, v in t do
		if v ~= nil and v ~= false and v ~= "" then
			result[#result + 1] = v
		end
	end
	return result
end

function Utility.TablePluck(t, key)
	return Utility.TableMap(t, function(item) return item[key] end)
end

function Utility.TableCount(t, predicate)
	if not predicate then return #t end
	local count = 0
	for _, v in t do
		if predicate(v) then count += 1 end
	end
	return count
end

function Utility.TableDistinct(t, selector)
	selector = selector or function(v) return v end
	local seen = {}
	local result = {}
	for _, v in t do
		local key = selector(v)
		if not seen[key] then
			seen[key] = true
			result[#result + 1] = v
		end
	end
	return result
end

function Utility.TableMapKeys(t, fn)
	local result = {}
	for k, v in t do result[fn(k, v)] = v end
	return result
end

function Utility.TableMapValues(t, fn)
	local result = {}
	for k, v in t do result[k] = fn(v, k) end
	return result
end

function Utility.TableFlatMap(t, fn)
	local result = {}
	for i, v in t do
		local mapped = fn(v, i)
		if typeof(mapped) == "table" then
			for _, item in mapped do result[#result + 1] = item end
		else
			result[#result + 1] = mapped
		end
	end
	return result
end

function Utility.TablePartition(t, predicate)
	local pass, fail = {}, {}
	for _, v in t do
		if predicate(v) then pass[#pass + 1] = v
		else fail[#fail + 1] = v end
	end
	return pass, fail
end

function Utility.TableWindow(t, start, finish)
	local result = {}
	for i = start, finish do result[#result + 1] = t[i] end
	return result
end

function Utility.TableSlidingWindow(t, size)
	local windows = {}
	for i = 1, math.max(1, #t - size + 1) do
		windows[#windows + 1] = Utility.TableWindow(t, i, math.min(i + size - 1, #t))
	end
	return windows
end

function Utility.TableScan(t, fn)
	for i, v in t do fn(v, i) end
	return t
end

function Utility.TableInject(t, initial, fn)
	local accumulator = initial
	for i, v in t do accumulator = fn(accumulator, v, i) end
	return accumulator
end

function Utility.TableJoin(...)
	local result = {}
	for _, t in { ... } do
		for k, v in t do result[k] = v end
	end
	return result
end

function Utility.TableMerge(...)
	local result = {}
	for _, t in { ... } do
		for i, v in t do result[#result + 1] = v end
	end
	return result
end

function Utility.TableFill(n, value)
	local result = {}
	for i = 1, n do result[i] = value end
	return result
end

function Utility.TableRange(start, finish, step)
	step = step or 1
	local result = {}
	for i = start, finish, step do result[#result + 1] = i end
	return result
end

function Utility.TableRepeatN(t, n)
	local result = {}
	for i = 1, n do
		for _, v in t do result[#result + 1] = v end
	end
	return result
end

function Utility.TableInterleave(...)
	local tables = { ... }
	local result = {}
	local maxLen = 0
	for _, t in tables do maxLen = math.max(maxLen, #t) end
	for i = 1, maxLen do
		for _, t in tables do
			if t[i] then result[#result + 1] = t[i] end
		end
	end
	return result
end

function Utility.TableWithoutIndex(t, index)
	local result = {}
	for i, v in t do
		if i ~= index then result[#result + 1] = v end
	end
	return result
end

function Utility.TableWithoutValue(t, value)
	local result = {}
	for _, v in t do
		if v ~= value then result[#result + 1] = v end
	end
	return result
end

function Utility.TableFirst(t, predicate)
	for _, v in t do
		if predicate(v) then return v end
	end
	return nil
end

function Utility.TableLast(t, predicate)
	local last = nil
	for _, v in t do
		if not predicate or predicate(v) then last = v end
	end
	return last
end

function Utility.TableNth(t, n)
	return t[n]
end

function Utility.TableHead(t, n)
	n = n or 1
	return Utility.TableWindow(t, 1, math.min(n, #t))
end

function Utility.TableTail(t, n)
	n = n or 1
	return Utility.TableWindow(t, math.max(1, #t - n + 1), #t)
end

function Utility.TableInit(t)
	return Utility.TableWithoutIndex(t, #t)
end

function Utility.TableLastN(t, n)
	return Utility.TableTail(t, n)
end

function Utility.TableTakeWhile(t, predicate)
	local result = {}
	for _, v in t do
		if predicate(v) then result[#result + 1] = v
		else break end
	end
	return result
end

function Utility.TableDropWhile(t, predicate)
	local result = {}
	local dropping = true
	for _, v in t do
		if dropping and predicate(v) then continue end
		dropping = false
		result[#result + 1] = v
	end
	return result
end

function Utility.TableSplitAt(t, index)
	return Utility.TableWindow(t, 1, index - 1), Utility.TableWindow(t, index, #t)
end

function Utility.TableSpan(t, predicate)
	local pass = {}
	local fail = {}
	local inPass = true
	for _, v in t do
		if inPass and predicate(v) then pass[#pass + 1] = v
		else inPass = false; fail[#fail + 1] = v end
	end
	return pass, fail
end

function Utility.TableBreak(t, predicate)
	for i, v in t do
		if predicate(v) then return Utility.TableSplitAt(t, i) end
	end
	return t, {}
end

function Utility.TableGroupConsecutive(t, keyFn)
	local groups = {}
	local currentKey = nil
	local currentGroup = {}
	for _, v in t do
		local key = keyFn(v)
		if key ~= currentKey then
			if currentGroup then groups[#groups + 1] = currentGroup end
			currentGroup = {}
			currentKey = key
		end
		currentGroup[#currentGroup + 1] = v
	end
	if currentGroup then groups[#groups + 1] = currentGroup end
	return groups
end

function Utility.TableSubsequence(t, indices)
	local result = {}
	for _, i in indices do result[#result + 1] = t[i] end
	return result
end

if not table.clone then table.clone = function(t) local c = {}; for k,v in t do c[k] = v end; return c end end

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

Themes.Neon = {
	Name = "Neon",
	WindowBackground = Color3.fromRGB(12, 12, 18),
	WindowStroke = Color3.fromRGB(0, 200, 255),
	WindowStrokeTransparency = 0.5,
	CornerRoundness = UDim.new(0, 14),
	TabBarBackground = Color3.fromRGB(8, 8, 14),
	TabBackground = Color3.fromRGB(18, 18, 28),
	TabBackgroundHover = Color3.fromRGB(25, 25, 40),
	TabBackgroundSelected = Color3.fromRGB(22, 22, 38),
	TabStroke = Color3.fromRGB(0, 150, 200),
	TabStrokeSelected = Color3.fromRGB(0, 220, 255),
	TabTextColor = Color3.fromRGB(100, 140, 170),
	TabTextColorSelected = Color3.fromRGB(0, 240, 255),
	ElementBackground = Color3.fromRGB(18, 18, 28),
	ElementStroke = Color3.fromRGB(0, 120, 160),
	ElementStrokeTransparency = 0.6,
	ElementStrokeHover = Color3.fromRGB(0, 200, 255),
	ElementStrokeHoverTransparency = 0.2,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(180, 220, 240),
	ElementTextHoverColor = Color3.fromRGB(0, 255, 255),
	ElementGradient = ColorSequence.new(Color3.fromRGB(20, 20, 32), Color3.fromRGB(15, 15, 25)),
	AccentColor = Color3.fromRGB(0, 180, 255),
	AccentStroke = Color3.fromRGB(0, 220, 255),
	AccentGlow = 0.8,
	ToggleTrack = Color3.fromRGB(30, 30, 48),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(80, 100, 120),
	ToggleKnobOffTransparency = 0.2,
	SliderBackground = Color3.fromRGB(25, 25, 40),
	SliderBackgroundHover = Color3.fromRGB(30, 30, 48),
	SliderProgress = ColorSequence.new(Color3.fromRGB(0, 150, 220), Color3.fromRGB(0, 200, 255)),
	SliderHandle = Color3.fromRGB(200, 240, 255),
	SliderStroke = Color3.fromRGB(0, 180, 255),
	DropdownHighlight = Color3.fromRGB(20, 20, 34),
	FieldBackground = Color3.fromRGB(12, 12, 20),
	FieldStroke = Color3.fromRGB(0, 100, 140),
	FieldStrokeFocus = Color3.fromRGB(0, 200, 255),
	TitlingColor = Color3.fromRGB(0, 240, 255),
	PlaceholderColor = Color3.fromRGB(70, 100, 130),
	ErrorColor = Color3.fromRGB(200, 40, 60),
	ErrorStrokeColor = Color3.fromRGB(255, 60, 80),
	SuccessColor = Color3.fromRGB(0, 200, 100),
	Font = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Medium),
	TitleFont = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Bold),
}

Themes.Pastel = {
	Name = "Pastel",
	WindowBackground = Color3.fromRGB(245, 240, 248),
	WindowStroke = Color3.fromRGB(210, 195, 215),
	WindowStrokeTransparency = 0.3,
	CornerRoundness = UDim.new(0, 16),
	TabBarBackground = Color3.fromRGB(235, 228, 240),
	TabBackground = Color3.fromRGB(225, 218, 232),
	TabBackgroundHover = Color3.fromRGB(215, 208, 225),
	TabBackgroundSelected = Color3.fromRGB(205, 195, 218),
	TabStroke = Color3.fromRGB(190, 175, 200),
	TabStrokeSelected = Color3.fromRGB(160, 120, 180),
	TabTextColor = Color3.fromRGB(120, 100, 130),
	TabTextColorSelected = Color3.fromRGB(80, 50, 100),
	ElementBackground = Color3.fromRGB(230, 222, 238),
	ElementStroke = Color3.fromRGB(200, 188, 210),
	ElementStrokeTransparency = 0.5,
	ElementStrokeHover = Color3.fromRGB(160, 120, 180),
	ElementStrokeHoverTransparency = 0.25,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(60, 45, 70),
	ElementTextHoverColor = Color3.fromRGB(40, 25, 55),
	ElementGradient = ColorSequence.new(Color3.fromRGB(232, 225, 242), Color3.fromRGB(222, 215, 235)),
	AccentColor = Color3.fromRGB(150, 100, 180),
	AccentStroke = Color3.fromRGB(170, 120, 200),
	AccentGlow = 0.75,
	ToggleTrack = Color3.fromRGB(200, 190, 215),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(170, 158, 185),
	ToggleKnobOffTransparency = 0,
	SliderBackground = Color3.fromRGB(210, 200, 222),
	SliderBackgroundHover = Color3.fromRGB(200, 190, 215),
	SliderProgress = ColorSequence.new(Color3.fromRGB(140, 90, 170), Color3.fromRGB(165, 115, 195)),
	SliderHandle = Color3.fromRGB(255, 255, 255),
	SliderStroke = Color3.fromRGB(150, 100, 180),
	DropdownHighlight = Color3.fromRGB(215, 205, 228),
	FieldBackground = Color3.fromRGB(248, 244, 252),
	FieldStroke = Color3.fromRGB(200, 188, 210),
	FieldStrokeFocus = Color3.fromRGB(150, 100, 180),
	TitlingColor = Color3.fromRGB(60, 40, 75),
	PlaceholderColor = Color3.fromRGB(145, 130, 155),
	ErrorColor = Color3.fromRGB(210, 80, 90),
	ErrorStrokeColor = Color3.fromRGB(230, 95, 105),
	SuccessColor = Color3.fromRGB(80, 180, 110),
	Font = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Medium),
	TitleFont = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Bold),
}

Themes.Midnight = {
	Name = "Midnight",
	WindowBackground = Color3.fromRGB(15, 15, 22),
	WindowStroke = Color3.fromRGB(50, 45, 70),
	WindowStrokeTransparency = 0.45,
	CornerRoundness = UDim.new(0, 10),
	TabBarBackground = Color3.fromRGB(10, 10, 16),
	TabBackground = Color3.fromRGB(22, 22, 32),
	TabBackgroundHover = Color3.fromRGB(30, 30, 42),
	TabBackgroundSelected = Color3.fromRGB(28, 28, 45),
	TabStroke = Color3.fromRGB(45, 40, 65),
	TabStrokeSelected = Color3.fromRGB(100, 80, 160),
	TabTextColor = Color3.fromRGB(110, 105, 140),
	TabTextColorSelected = Color3.fromRGB(200, 190, 255),
	ElementBackground = Color3.fromRGB(22, 22, 32),
	ElementStroke = Color3.fromRGB(40, 36, 58),
	ElementStrokeTransparency = 0.6,
	ElementStrokeHover = Color3.fromRGB(90, 75, 150),
	ElementStrokeHoverTransparency = 0.3,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(175, 170, 200),
	ElementTextHoverColor = Color3.fromRGB(220, 215, 255),
	ElementGradient = ColorSequence.new(Color3.fromRGB(25, 25, 36), Color3.fromRGB(18, 18, 28)),
	AccentColor = Color3.fromRGB(90, 70, 160),
	AccentStroke = Color3.fromRGB(110, 90, 180),
	AccentGlow = 0.7,
	ToggleTrack = Color3.fromRGB(35, 32, 52),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(95, 90, 120),
	ToggleKnobOffTransparency = 0.2,
	SliderBackground = Color3.fromRGB(28, 26, 42),
	SliderBackgroundHover = Color3.fromRGB(35, 32, 52),
	SliderProgress = ColorSequence.new(Color3.fromRGB(75, 60, 140), Color3.fromRGB(100, 85, 170)),
	SliderHandle = Color3.fromRGB(220, 215, 255),
	SliderStroke = Color3.fromRGB(90, 70, 160),
	DropdownHighlight = Color3.fromRGB(26, 24, 38),
	FieldBackground = Color3.fromRGB(12, 12, 18),
	FieldStroke = Color3.fromRGB(36, 32, 54),
	FieldStrokeFocus = Color3.fromRGB(90, 70, 160),
	TitlingColor = Color3.fromRGB(200, 190, 255),
	PlaceholderColor = Color3.fromRGB(85, 80, 110),
	ErrorColor = Color3.fromRGB(190, 50, 65),
	ErrorStrokeColor = Color3.fromRGB(220, 70, 85),
	SuccessColor = Color3.fromRGB(50, 170, 85),
	Font = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Medium),
	TitleFont = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Bold),
}

Themes.Forest = {
	Name = "Forest",
	WindowBackground = Color3.fromRGB(18, 24, 18),
	WindowStroke = Color3.fromRGB(40, 70, 40),
	WindowStrokeTransparency = 0.45,
	CornerRoundness = UDim.new(0, 12),
	TabBarBackground = Color3.fromRGB(14, 20, 14),
	TabBackground = Color3.fromRGB(24, 34, 24),
	TabBackgroundHover = Color3.fromRGB(30, 42, 30),
	TabBackgroundSelected = Color3.fromRGB(28, 40, 28),
	TabStroke = Color3.fromRGB(50, 80, 50),
	TabStrokeSelected = Color3.fromRGB(70, 140, 70),
	TabTextColor = Color3.fromRGB(100, 130, 100),
	TabTextColorSelected = Color3.fromRGB(150, 220, 150),
	ElementBackground = Color3.fromRGB(24, 34, 24),
	ElementStroke = Color3.fromRGB(45, 68, 45),
	ElementStrokeTransparency = 0.6,
	ElementStrokeHover = Color3.fromRGB(65, 130, 65),
	ElementStrokeHoverTransparency = 0.25,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(170, 200, 170),
	ElementTextHoverColor = Color3.fromRGB(180, 240, 180),
	ElementGradient = ColorSequence.new(Color3.fromRGB(26, 38, 26), Color3.fromRGB(20, 30, 20)),
	AccentColor = Color3.fromRGB(60, 130, 60),
	AccentStroke = Color3.fromRGB(80, 160, 80),
	AccentGlow = 0.7,
	ToggleTrack = Color3.fromRGB(35, 52, 35),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(90, 110, 90),
	ToggleKnobOffTransparency = 0.2,
	SliderBackground = Color3.fromRGB(28, 42, 28),
	SliderBackgroundHover = Color3.fromRGB(35, 52, 35),
	SliderProgress = ColorSequence.new(Color3.fromRGB(50, 120, 50), Color3.fromRGB(70, 150, 70)),
	SliderHandle = Color3.fromRGB(200, 230, 200),
	SliderStroke = Color3.fromRGB(60, 130, 60),
	DropdownHighlight = Color3.fromRGB(26, 38, 26),
	FieldBackground = Color3.fromRGB(16, 22, 16),
	FieldStroke = Color3.fromRGB(40, 60, 40),
	FieldStrokeFocus = Color3.fromRGB(60, 130, 60),
	TitlingColor = Color3.fromRGB(150, 220, 150),
	PlaceholderColor = Color3.fromRGB(80, 105, 80),
	ErrorColor = Color3.fromRGB(190, 55, 55),
	ErrorStrokeColor = Color3.fromRGB(220, 75, 75),
	SuccessColor = Color3.fromRGB(80, 190, 80),
	Font = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Medium),
	TitleFont = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Bold),
}

Themes.Sunset = {
	Name = "Sunset",
	WindowBackground = Color3.fromRGB(25, 18, 22),
	WindowStroke = Color3.fromRGB(80, 45, 55),
	WindowStrokeTransparency = 0.45,
	CornerRoundness = UDim.new(0, 14),
	TabBarBackground = Color3.fromRGB(18, 12, 16),
	TabBackground = Color3.fromRGB(32, 22, 28),
	TabBackgroundHover = Color3.fromRGB(42, 30, 38),
	TabBackgroundSelected = Color3.fromRGB(38, 26, 34),
	TabStroke = Color3.fromRGB(70, 40, 50),
	TabStrokeSelected = Color3.fromRGB(200, 100, 80),
	TabTextColor = Color3.fromRGB(140, 110, 120),
	TabTextColorSelected = Color3.fromRGB(255, 180, 140),
	ElementBackground = Color3.fromRGB(32, 22, 28),
	ElementStroke = Color3.fromRGB(60, 38, 48),
	ElementStrokeTransparency = 0.6,
	ElementStrokeHover = Color3.fromRGB(180, 90, 70),
	ElementStrokeHoverTransparency = 0.25,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(220, 190, 200),
	ElementTextHoverColor = Color3.fromRGB(255, 210, 180),
	ElementGradient = ColorSequence.new(Color3.fromRGB(35, 24, 30), Color3.fromRGB(26, 18, 24)),
	AccentColor = Color3.fromRGB(200, 100, 70),
	AccentStroke = Color3.fromRGB(230, 120, 90),
	AccentGlow = 0.75,
	ToggleTrack = Color3.fromRGB(48, 32, 40),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(120, 90, 100),
	ToggleKnobOffTransparency = 0.2,
	SliderBackground = Color3.fromRGB(38, 26, 34),
	SliderBackgroundHover = Color3.fromRGB(48, 34, 42),
	SliderProgress = ColorSequence.new(Color3.fromRGB(180, 85, 60), Color3.fromRGB(220, 110, 80)),
	SliderHandle = Color3.fromRGB(255, 230, 220),
	SliderStroke = Color3.fromRGB(200, 100, 70),
	DropdownHighlight = Color3.fromRGB(35, 24, 30),
	FieldBackground = Color3.fromRGB(22, 14, 18),
	FieldStroke = Color3.fromRGB(52, 34, 44),
	FieldStrokeFocus = Color3.fromRGB(200, 100, 70),
	TitlingColor = Color3.fromRGB(255, 180, 140),
	PlaceholderColor = Color3.fromRGB(110, 80, 90),
	ErrorColor = Color3.fromRGB(220, 55, 60),
	ErrorStrokeColor = Color3.fromRGB(245, 75, 80),
	SuccessColor = Color3.fromRGB(80, 190, 100),
	Font = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Medium),
	TitleFont = Font.new("rbxasset://fonts/families/GothamSSym.json", Enum.FontWeight.Bold),
}

Themes.Cyberpunk = {
	Name = "Cyberpunk",
	WindowBackground = Color3.fromRGB(10, 10, 15),
	WindowStroke = Color3.fromRGB(255, 0, 100),
	WindowStrokeTransparency = 0.6,
	CornerRoundness = UDim.new(0, 4),
	TabBarBackground = Color3.fromRGB(6, 6, 10),
	TabBackground = Color3.fromRGB(16, 16, 24),
	TabBackgroundHover = Color3.fromRGB(24, 24, 36),
	TabBackgroundSelected = Color3.fromRGB(20, 20, 32),
	TabStroke = Color3.fromRGB(200, 0, 80),
	TabStrokeSelected = Color3.fromRGB(255, 0, 120),
	TabTextColor = Color3.fromRGB(150, 80, 120),
	TabTextColorSelected = Color3.fromRGB(255, 50, 150),
	ElementBackground = Color3.fromRGB(16, 16, 24),
	ElementStroke = Color3.fromRGB(180, 0, 70),
	ElementStrokeTransparency = 0.65,
	ElementStrokeHover = Color3.fromRGB(255, 0, 120),
	ElementStrokeHoverTransparency = 0.2,
	ElementTransparency = 0,
	ContentColor = Color3.fromRGB(220, 180, 210),
	ElementTextHoverColor = Color3.fromRGB(255, 100, 200),
	ElementGradient = ColorSequence.new(Color3.fromRGB(18, 18, 28), Color3.fromRGB(12, 12, 20)),
	AccentColor = Color3.fromRGB(255, 0, 100),
	AccentStroke = Color3.fromRGB(255, 30, 130),
	AccentGlow = 0.85,
	ToggleTrack = Color3.fromRGB(30, 12, 22),
	ToggleTrackTransparency = 0,
	ToggleKnobOff = Color3.fromRGB(100, 50, 80),
	ToggleKnobOffTransparency = 0.2,
	SliderBackground = Color3.fromRGB(22, 12, 18),
	SliderBackgroundHover = Color3.fromRGB(30, 18, 24),
	SliderProgress = ColorSequence.new(Color3.fromRGB(220, 0, 90), Color3.fromRGB(255, 30, 120)),
	SliderHandle = Color3.fromRGB(255, 200, 230),
	SliderStroke = Color3.fromRGB(255, 0, 100),
	DropdownHighlight = Color3.fromRGB(18, 18, 28),
	FieldBackground = Color3.fromRGB(8, 8, 12),
	FieldStroke = Color3.fromRGB(160, 0, 60),
	FieldStrokeFocus = Color3.fromRGB(255, 0, 100),
	TitlingColor = Color3.fromRGB(255, 50, 150),
	PlaceholderColor = Color3.fromRGB(90, 40, 70),
	ErrorColor = Color3.fromRGB(255, 50, 50),
	ErrorStrokeColor = Color3.fromRGB(255, 80, 80),
	SuccessColor = Color3.fromRGB(0, 255, 120),
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
-- SEARCHABLE DROPDOWN COMPONENT
-- ============================================================================
local SearchableDropdown = {}
SearchableDropdown.__index = SearchableDropdown
SearchableDropdown.__type = "SearchableDropdown"

function SearchableDropdown.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab, window = tab.window,
		name = properties.name or properties.Name or "SearchDropdown",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag or properties.Flag or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "SearchDropdown") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		callback = properties.callback or properties.Callback or function() end,
		options = dedupStrings(properties.options or properties.Options or {}),
		placeholderText = properties.placeholder or properties.Placeholder or "Search...",
		value = properties.value or properties.Value or "",
		_isOpen = false, _filteredOptions = {}, connections = {},
	}, SearchableDropdown)
	self._desiredValue = self.value
	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)
	if self.description then self:_buildDescription() end
	return self
end

function SearchableDropdown:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 43), BorderSizePixel = 0,
		Name = self.name, ClipsDescendants = true,
		BackgroundTransparency = 1, Parent = self.tab.tabPage,
	})
	self.top = self.window:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 43), Position = UDim2.fromScale(0, 0),
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
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 43),
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

	self.searchField = self.window:Create("Frame", {
		Size = UDim2.new(1, -12, 0, 30), Position = UDim2.new(0, 6, 0, 4),
		BorderSizePixel = 0, BackgroundColor3 = self.window.theme.FieldBackground,
		ZIndex = 5, Parent = self.panel,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.searchField })
	self.window:Create("UIStroke", { Color = self.window.theme.FieldStroke, Transparency = 0.5, Parent = self.searchField })

	self.searchIcon = self.window:Create("ImageLabel", {
		Image = "rbxassetid://6031068420",
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(0, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		ImageColor3 = self.window.theme.PlaceholderColor,
		ZIndex = 6, Parent = self.searchField,
	})

	self.searchBox = self.window:Create("TextBox", {
		Text = "", PlaceholderText = "Type to search...",
		FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 26, 0, 0),
		BackgroundTransparency = 1, TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.ContentColor,
		PlaceholderColor3 = self.window.theme.PlaceholderColor,
		ClearTextOnFocus = false, TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 6, Parent = self.searchField,
	})

	self.list = self.window:Create("ScrollingFrame", {
		Active = true, Size = UDim2.new(1, 0, 1, -42),
		Position = UDim2.new(0, 0, 0, 38), BorderSizePixel = 0,
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

	self._filteredOptions = {}
	for _, opt in self.options do table.insert(self._filteredOptions, opt) end
	self:_buildAllOptions()
	self:_updateSelectedLabel()

	self.window:ConnectFor(self, self.interact.MouseButton1Click, function()
		if self._isOpen then self:_close() else self:_open() end
	end)
	self.window:ConnectFor(self, self.searchBox:GetPropertyChangedSignal("Text"), function()
		self:_filterOptions(self.searchBox.Text)
	end)
	self.window:ConnectFor(self, self.main.MouseEnter, function()
		if self._isOpen or not self.window:_interactive() then return end
		Utility.Tween(self.title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextColor3 = self.window.theme.ElementTextHoverColor })
	end)
	self.window:ConnectFor(self, self.main.MouseLeave, function()
		Utility.Tween(self.title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { TextColor3 = self.window.theme.ContentColor })
	end)
end

function SearchableDropdown:_buildAllOptions()
	for _, opt in self._filteredOptions do
		self:_buildOption(opt)
	end
end

function SearchableDropdown:_buildOption(optionName)
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
	local title = self.window:Create("TextLabel", {
		Text = optionName, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -24, 0, 16), Position = UDim2.new(0, 12, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, TextTransparency = 0.2, ZIndex = 5,
		TextColor3 = self.window.theme.ContentColor, Parent = frame,
	})

	local isOptionSelected = self.value == optionName
	frame.BackgroundTransparency = isOptionSelected and 0.88 or 1
	title.TextTransparency = isOptionSelected and 0 or 0.2
	if isOptionSelected then title.TextColor3 = self.window.theme.AccentColor end

	self.window:ConnectFor(self, interact.MouseButton1Click, function()
		if not self._isOpen then return end
		self.value = optionName
		self:_updateSelectedLabel()
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
		task.wait(0.1)
		self:_close()
	end)
	return { frame = frame, title = title, name = optionName }
end

function SearchableDropdown:_filterOptions(query)
	for _, child in self.list:GetChildren() do
		if child:IsA("Frame") then child:Destroy() end
	end
	self._filteredOptions = {}
	local lowerQuery = string.lower(query)
	for _, opt in self.options do
		if query == "" or string.find(string.lower(opt), lowerQuery, 1, true) then
			table.insert(self._filteredOptions, opt)
		end
	end
	self:_buildAllOptions()
end

function SearchableDropdown:_updateSelectedLabel()
	self.selectedLabel.Text = self.value or self.placeholderText
end

function SearchableDropdown:_openHeight()
	return math.min(250, 50 + #self._filteredOptions * 38 + 46)
end

function SearchableDropdown:_open()
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
	self.searchBox.Text = ""
	self.searchBox:CaptureFocus()
end

function SearchableDropdown:_close()
	if not self._isOpen then return end
	self._isOpen = false
	if self._outsideClickConn then self.window:Disconnect(self._outsideClickConn); self._outsideClickConn = nil end
	Utility.Tween(self.chevron, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Rotation = 180 })
	Utility.Tween(self.panel, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
	Utility.Tween(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.new(1, -20, 0, 43) })
end

function SearchableDropdown:_buildDescription()
	self.descriptor = self.window:Create("TextLabel", {
		Text = self.description, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 18, 1, 2),
		BackgroundTransparency = 1, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.PlaceholderColor,
		TextTransparency = 0.7, Parent = self.top,
	})
	self.main.Size = UDim2.new(1, -20, 0, 56)
end

function SearchableDropdown:_setShown(shown, animate)
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

function SearchableDropdown:Set(value, skipCallback)
	self.value = value
	self:_updateSelectedLabel()
	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

function SearchableDropdown:Refresh(newOptions)
	self.options = dedupStrings(newOptions or {})
	self._filteredOptions = {}
	for _, opt in self.options do table.insert(self._filteredOptions, opt) end
	for _, child in self.list:GetChildren() do
		if child:IsA("Frame") then child:Destroy() end
	end
	self:_buildAllOptions()
	self:_updateSelectedLabel()
end

function SearchableDropdown:Add(option)
	if typeof(option) ~= "string" or option == "" then return end
	if table.find(self.options, option) then return end
	table.insert(self.options, option)
	table.insert(self._filteredOptions, option)
	self:_buildOption(option)
end

function SearchableDropdown:Remove(option)
	local idx = table.find(self.options, option)
	if not idx then return end
	table.remove(self.options, idx)
	local fidx = table.find(self._filteredOptions, option)
	if fidx then table.remove(self._filteredOptions, fidx) end
	for _, child in self.list:GetChildren() do
		if child:IsA("Frame") and child.Name == option then child:Destroy(); break end
	end
	if self.value == option then
		self.value = ""
		self:_updateSelectedLabel()
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

-- ============================================================================
-- PROGRESS BAR COMPONENT
-- ============================================================================
local ProgressBar = {}
ProgressBar.__index = ProgressBar
ProgressBar.__type = "ProgressBar"

function ProgressBar.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab, window = tab.window,
		name = properties.name or properties.Name or "ProgressBar",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag or properties.Flag or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "ProgressBar") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		min = properties.min or properties.Min or 0,
		max = properties.max or properties.Max or 100,
		value = properties.value or properties.Value or 0,
		suffix = properties.suffix or properties.Suffix or "%",
		callback = properties.callback or properties.Callback or function() end,
		animated = properties.animated ~= false,
		connections = {},
	}, ProgressBar)
	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)
	if self.description then self:_buildDescription() end
	return self
end

function ProgressBar:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 65), BorderSizePixel = 0,
		Name = self.name, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1, Parent = self.tab.tabPage,
	})
	self.stroke = self.window:StyleElementBody(self.main)

	local container = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 18, 0.5, 0),
		Size = UDim2.new(0, 170, 0, 33), BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 5, Parent = self.main,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 2), VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = container,
	})

	local titleContainer = self.window:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
		BorderSizePixel = 0, ZIndex = 5, Parent = container,
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
		LayoutOrder = 1, Parent = container,
	})

	self.track = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.fromOffset(222, 10), BorderSizePixel = 0,
		BackgroundColor3 = self.window.theme.SliderBackground, Parent = self.main,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.track })

	self.progress = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(self:_ratio(), 1), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0, ZIndex = 2, Parent = self.track,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.progress })
	self.window:Create("UIGradient", {
		Offset = Vector2.new(0, 0.5), Rotation = 2,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.85), NumberSequenceKeypoint.new(1, 0),
		}), Parent = self.progress,
	}, { Color = "SliderProgress" })
end

function ProgressBar:_ratio()
	local span = self.max - self.min
	if span == 0 then return 0 end
	return math.clamp((self.value - self.min) / span, 0, 1)
end

function ProgressBar:_format(value)
	local text = string.format("%.0f", value)
	if self.suffix ~= "" then return text .. self.suffix end
	return text
end

function ProgressBar:Set(value, skipCallback)
	self.value = math.clamp(value, self.min, self.max)
	local ratio = self:_ratio()
	local info = self.animated and TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil
	if info then
		Utility.Tween(self.progress, info, { Size = UDim2.fromScale(ratio, 1) })
	else
		self.progress.Size = UDim2.fromScale(ratio, 1)
	end
	self.valueLabel.Text = self:_format(self.value)
	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

function ProgressBar:_buildDescription()
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

function ProgressBar:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil
	if shown then
		w:_reveal(self.main, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info) end
		w:_reveal(self.valueLabel, { TextTransparency = 0 }, animate, info)
		w:_reveal(self.track, { BackgroundTransparency = 0 }, animate, info)
		w:_reveal(self.progress, { BackgroundTransparency = 0 }, animate, info)
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info) end
		w:_reveal(self.valueLabel, { TextTransparency = 1 }, animate, info)
		w:_reveal(self.track, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.progress, { BackgroundTransparency = 1 }, animate, info)
	end
end

-- ============================================================================
-- COLOR PICKER COMPONENT
-- ============================================================================
local ColorPicker = {}
ColorPicker.__index = ColorPicker
ColorPicker.__type = "ColorPicker"

local function hsvToRgb(h, s, v)
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	i = i % 6
	if i == 0 then return v, t, p
	elseif i == 1 then return q, v, p
	elseif i == 2 then return p, v, t
	elseif i == 3 then return p, q, v
	elseif i == 4 then return t, p, v
	else return v, p, q end
end

local function rgbToHsv(r, g, b)
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local d = max - min
	local h, s, v = 0, 0, max
	v = max
	if max ~= 0 then s = d / max end
	if d ~= 0 then
		if max == r then h = (g - b) / d
		elseif max == g then h = 2 + (b - r) / d
		else h = 4 + (r - g) / d end
		h = h / 6
		if h < 0 then h = h + 1 end
	end
	return h, s, v
end

local function colorFromHSV(h, s, v)
	local r, g, b = hsvToRgb(h, s, v)
	return Color3.new(r, g, b)
end

function ColorPicker.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local initial = properties.color or properties.Color or properties.value or properties.Value or Color3.new(1, 1, 1)
	local h, s, v = rgbToHsv(initial.R, initial.G, initial.B)
	local self = setmetatable({
		tab = tab, window = tab.window,
		name = properties.name or properties.Name or "ColorPicker",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description,
		flag = properties.flag or properties.Flag or (not (properties.forgetState or tab.forgetState) and Utility.DeriveFlag(properties.name or "ColorPicker") or nil),
		forgetState = properties.forgetState or tab.forgetState,
		callback = properties.callback or properties.Callback or function() end,
		hue = h, saturation = s, brightness = v,
		alpha = properties.alpha or properties.Alpha or false,
		alphaValue = 1,
		_isOpen = false,
		_connections = {}, connections = {},
	}, ColorPicker)
	self.value = initial
	self.window:_registerControl(self)
	self:_build()
	table.insert(tab.elements, self)
	if self.description then self:_buildDescription() end
	return self
end

function ColorPicker:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 43), BorderSizePixel = 0,
		Name = self.name, ClipsDescendants = true,
		BackgroundTransparency = 1, Parent = self.tab.tabPage,
	})
	self.top = self.window:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 43), Position = UDim2.fromScale(0, 0),
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

	self.colorPreview = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -18, 0.5, 0),
		Size = UDim2.fromOffset(28, 18),
		BackgroundColor3 = self.value,
		BorderSizePixel = 0, ZIndex = 5, Parent = self.top,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.colorPreview })
	self.previewStroke = self.window:Create("UIStroke", {
		Color = self.window.theme.ElementStroke, Transparency = 0.4, Parent = self.colorPreview,
	})

	self.interact = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 43),
		Position = UDim2.fromScale(0, 0), BorderSizePixel = 0,
		Text = "", TextTransparency = 1, ZIndex = 10,
		AutoButtonColor = false, Parent = self.main,
	})

	self:_buildPanel()
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

function ColorPicker:_buildPanel()
	self.panelHeight = 200
	self.panel = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 0, 49),
		Size = UDim2.new(1, 0, 0, self.panelHeight), BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 1, BackgroundTransparency = 1, Parent = self.main,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.panel })
	self.window:Create("UIStroke", { Transparency = 1, Parent = self.panel }, { Color = "ElementStroke", Transparency = "ElementStrokeTransparency" })
	self.window:Create("UIGradient", { Rotation = 270, Parent = self.panel }, { Color = "ElementGradient" })
	self.window:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = self.panel,
	})

	selfsatPanel = self.window:Create("Frame", {
		Size = UDim2.new(1, -120, 1, -30), BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 5, Parent = self.panel,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.satPanel })

	self.satGradient = self.window:Create("UIGradient", {
		Color = ColorSequence.new(Color3.new(1, 1, 1), colorFromHSV(self.hue, 1, 1)),
		Rotation = 0, Parent = self.satPanel,
	})

	self.valOverlay = self.window:Create("Frame", {
		Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(0, 0, 0), ZIndex = 6, Parent = self.satPanel,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.valOverlay })
	self.window:Create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1),
		}), Rotation = 90, Parent = self.valOverlay,
	})

	self.satCursor = self.window:Create("Frame", {
		Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(self.saturation, 0, 1 - self.brightness, 0),
		BorderSizePixel = 0, ZIndex = 10, BackgroundColor3 = Color3.new(1, 1, 1), Parent = self.satPanel,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.satCursor })
	self.window:Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 2, Parent = self.satCursor })

	self.hueBar = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -4, 0, 0),
		Size = UDim2.new(0, 14, 1, -30), BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 5, Parent = self.panel,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.hueBar })
	self.window:Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.new(1, 1, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
			ColorSequenceKeypoint.new(0.67, Color3.new(0, 0, 1)),
			ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0)),
		}), Rotation = 90, Parent = self.hueBar,
	})

	self.hueCursor = self.window:Create("Frame", {
		Size = UDim2.new(1, 4, 0, 4), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, self.hue, 0),
		BorderSizePixel = 0, ZIndex = 10, BackgroundColor3 = Color3.new(1, 1, 1), Parent = self.hueBar,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.hueCursor })
	self.window:Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = self.hueCursor })

	local infoArea = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, -120, 0, 18), BorderSizePixel = 0,
		BackgroundTransparency = 1, ZIndex = 5, Parent = self.panel,
	})
	self.window:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6), Parent = infoArea,
	})

	self.hexLabel = self.window:Create("TextLabel", {
		Text = string.format("#%02X%02X%02X", math.floor(self.value.R * 255), math.floor(self.value.G * 255), math.floor(self.value.B * 255)),
		FontFace = self.window.theme.Font, Size = UDim2.new(0, 80, 1, 0),
		BackgroundTransparency = 1, TextSize = 12, ZIndex = 5,
		TextColor3 = self.window.theme.PlaceholderColor, Parent = infoArea,
	})

	self.rgbLabel = self.window:Create("TextLabel", {
		Text = string.format("%d, %d, %d", math.floor(self.value.R * 255), math.floor(self.value.G * 255), math.floor(self.value.B * 255)),
		FontFace = self.window.theme.Font, Size = UDim2.new(0, 100, 1, 0),
		BackgroundTransparency = 1, TextSize = 12, ZIndex = 5,
		TextColor3 = self.window.theme.PlaceholderColor, Parent = infoArea,
	})

	self.satInteract = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Text = "", TextTransparency = 1, ZIndex = 15, Parent = self.satPanel,
	})
	self.hueInteract = self.window:Create("TextButton", {
		BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
		Text = "", TextTransparency = 1, ZIndex = 15, Parent = self.hueBar,
	})

	self.window:ConnectFor(self, self.satInteract.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self._draggingSV = true
			self:_updateSV(input)
			if self._svConn then self._svConn:Disconnect() end
			self._svConn = RunService.RenderStepped:Connect(function()
				if not self._draggingSV then self._svConn:Disconnect(); return end
				self:_updateSVFromMouse()
			end)
		end
	end)
	self.window:ConnectFor(self, UserInputService.InputEnded, function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and self._draggingSV then
			self._draggingSV = false
			if self._svConn then self._svConn:Disconnect(); self._svConn = nil end
			self.window:_persist(self)
		end
	end)

	self.window:ConnectFor(self, self.hueInteract.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self._draggingHue = true
			self:_updateHue(input)
			if self._hueConn then self._hueConn:Disconnect() end
			self._hueConn = RunService.RenderStepped:Connect(function()
				if not self._draggingHue then self._hueConn:Disconnect(); return end
				self:_updateHueFromMouse()
			end)
		end
	end)
	self.window:ConnectFor(self, UserInputService.InputEnded, function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and self._draggingHue then
			self._draggingHue = false
			if self._hueConn then self._hueConn:Disconnect(); self._hueConn = nil end
			self.window:_persist(self)
		end
	end)
end

function ColorPicker:_updateSV(input)
	local absPos = self.satPanel.AbsolutePosition
	local absSize = self.satPanel.AbsoluteSize
	local x = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
	local y = math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
	self.saturation = x
	self.brightness = 1 - y
	self:_applyColor()
end

function ColorPicker:_updateSVFromMouse()
	local mouse = UserInputService:GetMouseLocation()
	local absPos = self.satPanel.AbsolutePosition
	local absSize = self.satPanel.AbsoluteSize
	local x = math.clamp((mouse.X - absPos.X) / absSize.X, 0, 1)
	local y = math.clamp((mouse.Y - absPos.Y) / absSize.Y, 0, 1)
	self.saturation = x
	self.brightness = 1 - y
	self:_applyColor()
end

function ColorPicker:_updateHue(input)
	local absPos = self.hueBar.AbsolutePosition
	local absSize = self.hueBar.AbsoluteSize
	local y = math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
	self.hue = y
	self:_applyColor()
end

function ColorPicker:_updateHueFromMouse()
	local mouse = UserInputService:GetMouseLocation()
	local absPos = self.hueBar.AbsolutePosition
	local absSize = self.hueBar.AbsoluteSize
	local y = math.clamp((mouse.Y - absPos.Y) / absSize.Y, 0, 1)
	self.hue = y
	self:_applyColor()
end

function ColorPicker:_applyColor()
	self.value = colorFromHSV(self.hue, self.saturation, self.brightness)
	self.colorPreview.BackgroundColor3 = self.value
	self.satGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), colorFromHSV(self.hue, 1, 1))
	self.satCursor.Position = UDim2.new(self.saturation, 0, 1 - self.brightness, 0)
	self.hueCursor.Position = UDim2.new(0.5, 0, self.hue, 0)
	self.hexLabel.Text = string.format("#%02X%02X%02X", math.floor(self.value.R * 255), math.floor(self.value.G * 255), math.floor(self.value.B * 255))
	self.rgbLabel.Text = string.format("%d, %d, %d", math.floor(self.value.R * 255), math.floor(self.value.G * 255), math.floor(self.value.B * 255))
	self.window:_runGuarded(self, self.callback, self.value)
end

function ColorPicker:_open()
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
	Utility.Tween(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.new(1, -20, 0, 43 + self.panelHeight + 16) })
	Utility.Tween(self.panel, TweenInfo.new(0.3), { BackgroundTransparency = self.window.theme.ElementTransparency or 0 })
end

function ColorPicker:_close()
	if not self._isOpen then return end
	self._isOpen = false
	if self._outsideClickConn then self.window:Disconnect(self._outsideClickConn); self._outsideClickConn = nil end
	Utility.Tween(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Size = UDim2.new(1, -20, 0, 43) })
	Utility.Tween(self.panel, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
end

function ColorPicker:_buildDescription()
	self.descriptor = self.window:Create("TextLabel", {
		Text = self.description, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 18, 1, 2),
		BackgroundTransparency = 1, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = self.window.theme.PlaceholderColor,
		TextTransparency = 0.7, Parent = self.top,
	})
	self.main.Size = UDim2.new(1, -20, 0, 56)
end

function ColorPicker:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil
	if shown then
		w:_reveal(self.top, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info) end
		w:_reveal(self.colorPreview, { BackgroundTransparency = 0 }, animate, info)
	else
		w:_reveal(self.top, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info) end
		w:_reveal(self.colorPreview, { BackgroundTransparency = 1 }, animate, info)
		if self._isOpen then self:_close() end
	end
end

function ColorPicker:Set(color, skipCallback)
	if typeof(color) == "Color3" then
		local h, s, v = rgbToHsv(color.R, color.G, color.B)
		self.hue = h; self.saturation = s; self.brightness = v
		self.value = color
		self:_applyColor()
	end
	if not skipCallback then
		self.window:_runGuarded(self, self.callback, self.value)
		self.window:_persist(self)
	end
end

-- ============================================================================
-- PARAGRAPH COMPONENT
-- ============================================================================
local Paragraph = {}
Paragraph.__index = Paragraph
Paragraph.__type = "Paragraph"

function Paragraph.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or "Paragraph",
		icon = properties.icon or properties.Icon,
		description = properties.description or properties.Description or properties.content or properties.Content or "",
		links = properties.links or properties.Links,
		connections = {},
	}, Paragraph)
	self:_build()
	table.insert(tab.elements, self)
	return self
end

function Paragraph:_build()
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 52), BorderSizePixel = 0,
		Name = self.name, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1, Parent = self.tab.tabPage,
	})
	self.stroke = self.window:StyleElementBody(self.main)

	local container = self.window:Create("Frame", {
		BorderSizePixel = 0, Parent = self.main,
		Size = UDim2.new(1, -36, 1, -12),
		Position = UDim2.new(0, 18, 0, 6),
		BackgroundTransparency = 1,
	})
	self.window:Create("UIListLayout", {
		Padding = UDim.new(0, 2), FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder, Parent = container,
	})

	if self.icon then
		self.iconLabel = self.window:Create("ImageLabel", {
			Image = self.icon, Size = UDim2.fromOffset(16, 16),
			BorderSizePixel = 0, BackgroundTransparency = 1, ImageTransparency = 1,
			LayoutOrder = 0, Parent = container,
		}, { ImageColor3 = "ContentColor" })
	end

	self.title = self.window:Create("TextLabel", {
		Text = self.name, FontFace = self.window.theme.TitleFont,
		Size = UDim2.new(1, 0, 0, 16), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, TextTransparency = 1, LayoutOrder = 1,
		TextColor3 = self.window.theme.TitlingColor, Parent = container,
	})

	self.contentLabel = self.window:Create("TextLabel", {
		Text = self.description, FontFace = self.window.theme.Font,
		Size = UDim2.new(1, 0, 0, 12), BorderSizePixel = 0,
		BackgroundTransparency = 1, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true, TextTransparency = 0.6, LayoutOrder = 2,
		TextColor3 = self.window.theme.PlaceholderColor, Parent = container,
	})

	local textHeight = TextService:GetTextSize(
		self.description, 12, self.window.theme.Font,
		Vector2.new(container.AbsoluteSize.X > 0 and container.AbsoluteSize.X or 300, 9999)
	).Y
	self.main.Size = UDim2.new(1, -20, 0, math.max(52, 16 + textHeight + 14))
end

function Paragraph:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil
	if shown then
		w:_reveal(self.main, { BackgroundTransparency = w.theme.ElementTransparency or 0 }, animate, info)
		w:_reveal(self.stroke, { Transparency = w.theme.ElementStrokeTransparency }, animate, info)
		w:_reveal(self.title, { TextTransparency = 0 }, animate, info)
		w:_reveal(self.contentLabel, { TextTransparency = 0.6 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 0 }, animate, info) end
	else
		w:_reveal(self.main, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.stroke, { Transparency = 1 }, animate, info)
		w:_reveal(self.title, { TextTransparency = 1 }, animate, info)
		w:_reveal(self.contentLabel, { TextTransparency = 1 }, animate, info)
		if self.iconLabel then w:_reveal(self.iconLabel, { ImageTransparency = 1 }, animate, info) end
	end
end

-- ============================================================================
-- SEPARATOR COMPONENT
-- ============================================================================
local Separator = {}
Separator.__index = Separator
Separator.__type = "Separator"

function Separator.new(tab, properties)
	properties = if typeof(properties) == "table" then properties else {}
	local self = setmetatable({
		tab = tab,
		window = tab.window,
		name = properties.name or properties.Name or nil,
		connections = {},
	}, Separator)
	self:_build()
	table.insert(tab.elements, self)
	return self
end

function Separator:_build()
	local height = self.name and 28 or 16
	self.main = self.window:Create("Frame", {
		Size = UDim2.new(1, -20, 0, height), BorderSizePixel = 0,
		BackgroundTransparency = 1, Parent = self.tab.tabPage,
	})
	if self.name then
		self.label = self.window:Create("TextLabel", {
			Text = self.name, FontFace = self.window.theme.Font,
			Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1, TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = self.window.theme.PlaceholderColor,
			TextTransparency = 0.5, Parent = self.main,
		})
	end
	self.lineLeft = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0.5, if self.name then -40 else -10, 0, 1),
		BackgroundColor3 = self.window.theme.ElementStroke,
		BorderSizePixel = 0, BackgroundTransparency = 0.5, Parent = self.main,
	})
	self.lineRight = self.window:Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0.5, if self.name then -40 else -10, 0, 1),
		BackgroundColor3 = self.window.theme.ElementStroke,
		BorderSizePixel = 0, BackgroundTransparency = 0.5, Parent = self.main,
	})
end

function Separator:_setShown(shown, animate)
	local w = self.window
	local info = animate and TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out) or nil
	if shown then
		w:_reveal(self.lineLeft, { BackgroundTransparency = 0.5 }, animate, info)
		w:_reveal(self.lineRight, { BackgroundTransparency = 0.5 }, animate, info)
		if self.label then w:_reveal(self.label, { TextTransparency = 0.5 }, animate, info) end
	else
		w:_reveal(self.lineLeft, { BackgroundTransparency = 1 }, animate, info)
		w:_reveal(self.lineRight, { BackgroundTransparency = 1 }, animate, info)
		if self.label then w:_reveal(self.label, { TextTransparency = 1 }, animate, info) end
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
function Tab:CreateColorPicker(properties) return ColorPicker.new(self, properties) end
function Tab:CreateParagraph(properties) return Paragraph.new(self, properties) end
function Tab:CreateSeparator(properties) return Separator.new(self, properties) end
function Tab:CreateSearchDropdown(properties) return SearchableDropdown.new(self, properties) end
function Tab:CreateProgressBar(properties) return ProgressBar.new(self, properties) end

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

	-- Close button
	self.closeButton = self:Create("Frame", {
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = Color3.fromRGB(200, 60, 60),
		BorderSizePixel = 0,
		Parent = self.actionContainer,
	})
	self:Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.closeButton })
	local closeIcon = self:Create("Frame", {
		Size = UDim2.fromOffset(8, 2),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(80, 20, 20),
		BorderSizePixel = 0,
		Parent = self.closeButton,
	})
	self:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = closeIcon })
	local closeIcon2 = self:Create("Frame", {
		Size = UDim2.fromOffset(2, 8),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(80, 20, 20),
		BorderSizePixel = 0,
		Parent = self.closeButton,
	})
	self:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = closeIcon2 })
	local closeBtn = self:Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 15,
		Parent = self.closeButton,
	})
	self:Connect(closeBtn.MouseButton1Click, function()
		self:Unload()
	end)
	self:Connect(self.closeButton.MouseEnter, function()
		Utility.Tween(self.closeButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(220, 70, 70) })
		Utility.Tween(closeIcon, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
		Utility.Tween(closeIcon2, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
	end)
	self:Connect(self.closeButton.MouseLeave, function()
		Utility.Tween(self.closeButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(200, 60, 60) })
		Utility.Tween(closeIcon, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(80, 20, 20) })
		Utility.Tween(closeIcon2, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(80, 20, 20) })
	end)

	-- Minimize button
	self.minimizeButton = self:Create("Frame", {
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = Color3.fromRGB(220, 180, 50),
		BorderSizePixel = 0,
		LayoutOrder = -1,
		Parent = self.actionContainer,
	})
	self:Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.minimizeButton })
	local minBar = self:Create("Frame", {
		Size = UDim2.fromOffset(8, 2),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(100, 80, 20),
		BorderSizePixel = 0,
		Parent = self.minimizeButton,
	})
	self:Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = minBar })
	local minBtn = self:Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 15,
		Parent = self.minimizeButton,
	})
	self:Connect(minBtn.MouseButton1Click, function()
		self:Hide()
	end)
	self:Connect(self.minimizeButton.MouseEnter, function()
		Utility.Tween(self.minimizeButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(240, 200, 60) })
		Utility.Tween(minBar, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
	end)
	self:Connect(self.minimizeButton.MouseLeave, function()
		Utility.Tween(self.minimizeButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(220, 180, 50) })
		Utility.Tween(minBar, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(100, 80, 20) })
	end)

	-- Maximize button
	self.maximizeButton = self:Create("Frame", {
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = Color3.fromRGB(60, 180, 80),
		BorderSizePixel = 0,
		LayoutOrder = -2,
		Parent = self.actionContainer,
	})
	self:Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.maximizeButton })
	local maxIcon = self:Create("Frame", {
		Size = UDim2.fromOffset(8, 8),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(20, 80, 30),
		BorderSizePixel = 0,
		Parent = self.maximizeButton,
	})
	self:Create("UICorner", { CornerRadius = UDim.new(0, 2), Parent = maxIcon })
	self:Create("UIStroke", { Color = Color3.fromRGB(20, 80, 30), Thickness = 1, Parent = maxIcon })
	local maxBtn = self:Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ZIndex = 15,
		Parent = self.maximizeButton,
	})
	self._maximized = false
	self._preMaxSize = nil
	self:Connect(maxBtn.MouseButton1Click, function()
		self._maximized = not self._maximized
		if self._maximized then
			self._preMaxSize = self.main.Size
			Utility.Tween(self.main, Utility.TweenInfo(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = UDim2.new(0.8, 0, 0.85, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
			})
		else
			Utility.Tween(self.main, Utility.TweenInfo(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = self._preMaxSize or UDim2.fromOffset(520, 460),
				Position = UDim2.new(0.5, 0, 0.5, 0),
			})
		end
	end)
	self:Connect(self.maximizeButton.MouseEnter, function()
		Utility.Tween(self.maximizeButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(70, 200, 90) })
		Utility.Tween(maxIcon, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
	end)
	self:Connect(self.maximizeButton.MouseLeave, function()
		Utility.Tween(self.maximizeButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(60, 180, 80) })
		Utility.Tween(maxIcon, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(20, 80, 30) })
	end)
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
	if not self._notifQueue then
		self._notifQueue = NotificationQueue.new(self)
	end
	return self._notifQueue:Push(properties)
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
-- TOOLTIP SYSTEM
-- ============================================================================
local Tooltip = {}
Tooltip.__index = Tooltip
Tooltip._activeTooltip = nil

function Tooltip.new(window)
	local self = setmetatable({}, Tooltip)
	self.window = window
	self.instance = nil
	self.visible = false
	self:_build()
	return self
end

function Tooltip:_build()
	self.instance = self.window:Create("Frame", {
		Name = "Tooltip",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = self.window.theme.WindowBackground,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 1000,
		Parent = self.window.screenGui,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.instance })
	self.window:Create("UIStroke", {
		Color = self.window.theme.ElementStroke,
		Transparency = 0.4,
		Parent = self.instance,
	})
	self.window:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		Parent = self.instance,
	})
	self.window:Create("UIShadow", {
		BlurRadius = UDim.new(0, 16),
		Color = Color3.fromRGB(0, 0, 0),
		Transparency = 0.7,
		Parent = self.instance,
	})
	self.label = self.window:Create("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		FontFace = self.window.theme.Font,
		TextSize = 12,
		TextColor3 = self.window.theme.ContentColor,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.instance,
	})
end

function Tooltip:Show(text, position)
	if Tooltip._activeTooltip and Tooltip._activeTooltip ~= self then
		Tooltip._activeTooltip:Hide()
	end
	Tooltip._activeTooltip = self
	self.label.Text = text
	self.instance.Visible = true
	self.visible = true
	local textSize = TextService:GetTextSize(text, 12, self.window.theme.Font, Vector2.new(300, 9999))
	self.instance.Size = UDim2.fromOffset(textSize.X + 20, textSize.Y + 12)
	local screenGuiSize = self.window.screenGui.AbsoluteSize
	local x = math.clamp(position.X + 12, 0, screenGuiSize.X - self.instance.AbsoluteSize.X - 4)
	local y = math.clamp(position.Y - self.instance.AbsoluteSize.Y - 8, 0, screenGuiSize.Y - self.instance.AbsoluteSize.Y - 4)
	self.instance.Position = UDim2.fromOffset(x, y)
	self.instance.BackgroundTransparency = 0.02
	self.label.TextTransparency = 0
end

function Tooltip:Hide()
	if not self.visible then return end
	self.visible = false
	self.instance.Visible = false
	if Tooltip._activeTooltip == self then Tooltip._activeTooltip = nil end
end

function Tooltip:BindTo(element, text)
	local conn1, conn2
	conn1 = self.window:Connect(element.MouseEnter, function()
		if not self.window:_interactive() then return end
		task.delay(0.4, function()
			if not self.visible then
				local pos = element.AbsolutePosition + element.AbsoluteSize * 0.5
				self:Show(text, pos)
			end
		end)
	end)
	conn2 = self.window:Connect(element.MouseLeave, function()
		self:Hide()
	end)
	return { conn1, conn2 }
end

-- ============================================================================
-- NOTIFICATION QUEUE SYSTEM
-- ============================================================================
local NotificationQueue = {}
NotificationQueue.__index = NotificationQueue

function NotificationQueue.new(window)
	local self = setmetatable({}, NotificationQueue)
	self.window = window
	self.queue = {}
	self.container = nil
	self.maxVisible = 5
	self.spacing = 8
	self:_build()
	return self
end

function NotificationQueue:_build()
	self.container = self.window:Create("Frame", {
		Name = "NotificationQueue",
		Size = UDim2.new(0, 300, 0, 600),
		Position = UDim2.new(1, -20, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Parent = self.window.screenGui,
	})
	self.window:Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, self.spacing),
		Parent = self.container,
	})
end

function NotificationQueue:Push(properties)
	properties = properties or {}
	local duration = properties.duration or 3
	local notifType = properties.type or "info"
	local title = properties.title or "Notification"
	local content = properties.content or ""
	local icon = properties.icon

	local bgColor, accentColor, defaultIcon
	if notifType == "success" then
		bgColor = Color3.fromRGB(20, 40, 25)
		accentColor = self.window.theme.SuccessColor or Color3.fromRGB(60, 180, 80)
		defaultIcon = "rbxassetid://6031068420"
	elseif notifType == "error" then
		bgColor = Color3.fromRGB(40, 20, 20)
		accentColor = self.window.theme.ErrorColor or Color3.fromRGB(200, 60, 60)
		defaultIcon = "rbxassetid://6031068420"
	elseif notifType == "warning" then
		bgColor = Color3.fromRGB(40, 35, 15)
		accentColor = Color3.fromRGB(220, 180, 50)
		defaultIcon = "rbxassetid://6031068420"
	else
		bgColor = self.window.theme.ElementBackground
		accentColor = self.window.theme.AccentColor
		defaultIcon = "rbxassetid://6031068420"
	end

	local notifFrame = self.window:Create("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = bgColor,
		BorderSizePixel = 0,
		BackgroundTransparency = 0.05,
		LayoutOrder = #self.queue + 1,
		Parent = self.container,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = notifFrame })
	self.window:Create("UIStroke", {
		Color = accentColor,
		Transparency = 0.6,
		Thickness = 1,
		Parent = notifFrame,
	})
	self.window:Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		Parent = notifFrame,
	})

	local iconFrame = self.window:Create("Frame", {
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = accentColor,
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Parent = notifFrame,
	})
	self.window:Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = iconFrame })
	self.window:Create("ImageLabel", {
		Image = icon or defaultIcon,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ImageColor3 = accentColor,
		Parent = iconFrame,
	})

	self.window:Create("TextLabel", {
		Text = title,
		FontFace = self.window.theme.TitleFont,
		Size = UDim2.new(1, -44, 0, 16),
		Position = UDim2.new(0, 40, 0, 6),
		BackgroundTransparency = 1,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = self.window.theme.TitlingColor,
		Parent = notifFrame,
	})

	if content ~= "" then
		self.window:Create("TextLabel", {
			Text = content,
			FontFace = self.window.theme.Font,
			Size = UDim2.new(1, -44, 0, 12),
			Position = UDim2.new(0, 40, 0, 24),
			BackgroundTransparency = 1,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextColor3 = self.window.theme.PlaceholderColor,
			Parent = notifFrame,
		})
	end

	notifFrame.BackgroundTransparency = 1
	Utility.Tween(notifFrame, Utility.TweenInfo(0.3), { BackgroundTransparency = 0.05 })

	table.insert(self.queue, { frame = notifFrame, duration = duration })

	task.delay(duration, function()
		Utility.Tween(notifFrame, Utility.TweenInfo(0.3), { BackgroundTransparency = 1 })
		task.delay(0.3, function()
			notifFrame:Destroy()
			for i, entry in self.queue do
				if entry.frame == notifFrame then
					table.remove(self.queue, i)
					break
				end
			end
		end)
	end)

	return notifFrame
end

function NotificationQueue:Clear()
	for _, entry in self.queue do
		Utility.Tween(entry.frame, Utility.TweenInfo(0.2), { BackgroundTransparency = 1 })
		task.delay(0.2, function() entry.frame:Destroy() end)
	end
	table.clear(self.queue)
end

-- ============================================================================
-- RIPPLE EFFECT UTILITY
-- ============================================================================
local Ripple = {}

function Ripple.new(parent, position, color, radius)
	radius = radius or 60
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.BackgroundColor3 = color or Color3.new(1, 1, 1)
	ripple.BackgroundTransparency = 0.7
	ripple.BorderSizePixel = 0
	ripple.Size = UDim2.fromOffset(0, 0)
	ripple.Position = UDim2.new(
		(position.X - parent.AbsolutePosition.X) / parent.AbsoluteSize.X,
		0,
		(position.Y - parent.AbsolutePosition.Y) / parent.AbsoluteSize.Y,
		0
	)
	ripple.ZIndex = 50
	ripple.Parent = parent

	Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)

	local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
	TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(maxSize, maxSize),
		BackgroundTransparency = 1,
	}):Play()

	task.delay(0.5, function() ripple:Destroy() end)
	return ripple
end

-- ============================================================================
-- DEBOUNCE / THROTTLE UTILITIES
-- ============================================================================
local function debounce(fn, delay)
	local lastCall = 0
	local pendingThread = nil
	return function(...)
		local now = tick()
		if pendingThread then task.cancel(pendingThread) end
		pendingThread = task.delay(delay, function()
			fn(...)
			lastCall = tick()
		end)
	end
end

local function throttle(fn, interval)
	local lastCall = 0
	return function(...)
		local now = tick()
		if now - lastCall >= interval then
			lastCall = now
			return fn(...)
		end
	end
end

local function afterLastTween(instance, callback)
	local connection
	connection = instance:GetPropertyChangedSignal("Position"):Connect(function()
		-- simple post-tween hook
	end)
	task.delay(0.5, function()
		if connection then connection:Disconnect() end
		callback()
	end)
end

-- ============================================================================
-- ANIMATION PRESETS
-- ============================================================================
local AnimationPresets = {}

AnimationPresets.SlideInFromLeft = {
	start = function(instance)
		local originalPos = instance.Position
		instance.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset - 60, originalPos.Y.Scale, originalPos.Y.Offset)
		instance.BackgroundTransparency = 1
	end,
	finish = function(instance, info)
		return { Position = instance.Position, BackgroundTransparency = 0 }
	end,
}

AnimationPresets.SlideInFromRight = {
	start = function(instance)
		local originalPos = instance.Position
		instance.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset + 60, originalPos.Y.Scale, originalPos.Y.Offset)
		instance.BackgroundTransparency = 1
	end,
	finish = function(instance, info)
		return { Position = instance.Position, BackgroundTransparency = 0 }
	end,
}

AnimationPresets.ScaleIn = {
	start = function(instance)
		instance.Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset, instance.Size.Y.Scale * 0.8, instance.Size.Y.Offset * 0.8)
		instance.BackgroundTransparency = 1
	end,
	finish = function(instance, info)
		return { BackgroundTransparency = 0 }
	end,
}

AnimationPresets.FadeInUp = {
	start = function(instance)
		local originalPos = instance.Position
		instance.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset, originalPos.Y.Scale, originalPos.Y.Offset + 20)
		instance.BackgroundTransparency = 1
	end,
	finish = function(instance, info)
		return { Position = instance.Position, BackgroundTransparency = 0 }
	end,
}

AnimationPresets.PopBounce = {
	start = function(instance)
		instance.Size = UDim2.new(instance.Size.X.Scale, instance.Size.X.Offset * 0.85, instance.Size.Y.Scale, instance.Size.Y.Offset * 0.85)
	end,
	finish = function(instance, info)
		return {}
	end,
	info = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

AnimationPresets.GlowPulse = {
	start = function(instance) end,
	finish = function(instance, info)
		return {}
	end,
}

-- ============================================================================
-- ENHANCED WINDOW FEATURES
-- ============================================================================

-- ============================================================================
-- ENHANCED WINDOW FEATURES
-- ============================================================================

-- ============================================================================
-- TAB ENHANCED: CREATE LABEL (alias for paragraph short form)
-- ============================================================================
function Tab:CreateLabel(properties)
	properties = properties or {}
	properties.description = properties.description or properties.text or properties.Text or properties.content or ""
	return Paragraph.new(self, properties)
end

-- ============================================================================
-- WINDOW: TOOLTIP FACTORY
-- ============================================================================
function Window:CreateTooltip()
	return Tooltip.new(self)
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
