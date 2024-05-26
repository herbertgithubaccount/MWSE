--[[
	Button Setting for binding a key/mouse combination. Variable returned in the form:
		{
			keyCode = tes3.scanCode/nil,
			isAltDown = true/false,
			isShiftDown = true/false,
			isControlDown = true/false,
			mouseWheel = integer/nil,
			mouseButton = integer/nil,
		}
]]--

--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local Parent = require("mcm.components.settings.Binder")

--- @class mwseMCMKeyBinder
local KeyBinder = Parent:new()

function KeyBinder.new(cls, obj)
	obj = Parent.new(cls, obj) -- also creates object if not provided, and sets metatables

	if obj.allowCombinations and obj.variable then
		table.copymissing(obj.variable.value, {
			isAltDown = false,
			isControlDown = false,
			isShiftDown = false,
			isSuperDown = false,
		})
	end

	return obj
end
KeyBinder.allowMouse = false
KeyBinder.popupId = tes3ui.registerID("KeyBinderPopup")

-- TODO: Implement flags for enabling the binding of mouse wheel or mouse buttons separately

--- @param e keyDownEventData|keyUpEventData|mouseButtonDownEventData|mouseWheelEventData
function KeyBinder:getKeyComboFromEventData(e)
	local result = {
		keyCode = e.keyCode or nil
	}

	if self.allowMouse then
		local wheel = e.delta and math.clamp(e.delta, -1, 1)
		result.mouseWheel = wheel or nil
		result.mouseButton = e.button or nil
	end

	if self.allowCombinations then
		result.isAltDown = e.isAltDown
		result.isShiftDown = e.isShiftDown
		result.isControlDown = e.isControlDown
	end

	return result
end

function KeyBinder:press()
	self:createPopupMenu()

	--- @param e keyUpEventData|mouseButtonDownEventData|mouseWheelEventData
	local function waitInput(e)
		-- Unregister this function once we got some input
		event.unregister(tes3.event.keyUp, waitInput)
		if self.allowMouse then
			event.unregister(tes3.event.mouseButtonDown, waitInput)
			event.unregister(tes3.event.mouseWheel, waitInput)
		end

		local popup = tes3ui.findMenu(self.popupId)
		if popup then
			popup:destroy()
		end

		-- Allow closing the menu using escape, wihout binding anything
		if e.keyCode == tes3.scanCode.esc then
			return
		end

		self:keySelected(self:getKeyComboFromEventData(e))
	end

	event.register(tes3.event.keyUp, waitInput)
	if self.allowMouse then
		event.register(tes3.event.mouseButtonDown, waitInput)
		event.register(tes3.event.mouseWheel, waitInput)
	end
end

return KeyBinder
