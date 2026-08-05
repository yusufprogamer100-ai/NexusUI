local NexusUI = {}
NexusUI.__index = NexusUI

local Window = require(script.components.Window)

function NexusUI:CreateWindow(properties)
	return Window.new(properties)
end

return NexusUI
