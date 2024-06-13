local mcm = {}
mcm.version = 1.5


--- @param template mwseMCMTemplate
function mcm.register(template)
	local modConfig = {}

	--- @param container tes3uiElement
	modConfig.onCreate = function(container)
		template:create(container)
		modConfig.onClose = template.onClose
	end
	mwse.log("%s mod config registered", template.name)
	mwse.registerModConfig(template.name, modConfig)
end

--- @param keybind mwseKeyCombo
--- @return boolean pressed
function mcm.testKeyBind(keybind)
	local inputController = tes3.worldController.inputController
	return inputController:isKeyDown(keybind.keyCode) and keybind.isShiftDown == inputController:isShiftDown() and
	       keybind.isAltDown == inputController:isAltDown() and keybind.isControlDown == inputController:isControlDown()
end

local mouseWheelDirectionName = {
	[1] = "Mouse wheel up",
	[-1] = "Mouse wheel down",
}

--- @param mouseWheel integer|nil
--- @return string|nil result
function mcm.getMouseWheelName(mouseWheel)
	if not mouseWheel then
		return
	end
	-- Support directly passing mouseWheelEventData.delta
	mouseWheel = math.clamp(mouseWheel, -1, 1)
	local name = mouseWheelDirectionName[mouseWheel]
	if name then
		return mwse.mcm.i18n(name)
	end
end

local mouseButtonName = {
	[0] = "Left mouse button",
	[1] = "Right mouse button",
	[2] = "Middle mouse button",
}

--- @param buttonIndex number|nil
--- @return string|nil result
function mcm.getMouseButtonName(buttonIndex)
	-- Only work with button indices supported by the inputController
	if not buttonIndex or buttonIndex > 7 or buttonIndex < 0 then
		return
	end
	local name = mouseButtonName[buttonIndex]
	if name then
		return mwse.mcm.i18n(name)
	end

	return string.format(mwse.mcm.i18n("Mouse %s"), buttonIndex)
end

--- @param keyCombo mwseKeyCombo|mwseKeyMouseCombo
--- @return string|nil result
function mcm.getKeyComboName(keyCombo)
	local keyCode = keyCombo.keyCode
	local comboText = tes3.getKeyName(keyCode) or
	                  mcm.getMouseWheelName(keyCombo.mouseWheel) or
	                  mcm.getMouseButtonName(keyCombo.mouseButton)

	-- No base name, nothing to do.
	if not comboText then
		return
	end

	local hasAlt = (keyCombo.isAltDown and keyCode ~= tes3.scanCode.lAlt
	                                   and keyCode ~= tes3.scanCode.rAlt)
	local hasShift = (keyCombo.isShiftDown and keyCode ~= tes3.scanCode.lShift
	                                       and keyCode ~= tes3.scanCode.rShift)
	local hasCtrl = (keyCombo.isControlDown and keyCode ~= tes3.scanCode.lCtrl
	                                        and keyCode ~= tes3.scanCode.rCtrl)
	local prefixes = {}
	if hasShift then table.insert(prefixes, "Shift") end
	if hasAlt then table.insert(prefixes, "Alt") end
	if hasCtrl then table.insert(prefixes, "Ctrl") end
	table.insert(prefixes, comboText)
	return table.concat(prefixes, " - ")
end

-- Depreciated
function mcm.registerModData(mcmData)
	-- object returned to be used in modConfigMenu
	local modConfig = {}

	---CREATE MCM---
	--- @param container tes3uiElement
	function modConfig.onCreate(container)
		local templateClass = mcmData.template or "Template"
		local templatePath = ("mcm.components.templates." .. templateClass)
		local template = require(templatePath).new(mcmData) --[[@as mwseMCMTemplate]]
		template:create(container)
		modConfig.onClose = template.onClose
	end

	mwse.log("%s mod config registered", mcmData.name)

	return modConfig
end

-- Depreciated
function mcm.registerMCM(mcmData)
	local newMCM = mcm.registerModData(mcmData)
	mwse.registerModConfig(mcmData.name, newMCM)
end

--[[
	Check if key being accessed is in the form "create{class}" where
	{class} is a component or variable class.

	If only component data was sent as a parameter, create the new
	component instance. If a parentBlock was also passed, then also
	create the element on the parent.

]]--


return mcm