--[[
	Button Setting for binding a key/mouse combination. Variable returned in the form:
		{
			keyCode = tes3.scanCode|nil,
			mouseButton = integer|nil,
			mouseWheel = integer|nil,
			isAltDown = boolean|nil,
			isShiftDown = boolean|nil,
			isControlDown = boolean|nil,
		}
]]--

--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local Parent = require("mcm.components.settings.Binder")

--- @class mwseMCMKeyBinder
local KeyBinder = Herbert_Class.new{parents={Parent},
	fields={
		{"allowMouse", default=false},
		{"observeEvents", factory=function (self)
			local observeEvents = { [tes3.event.keyDown] = true }
			if self.allowMouse then
				observeEvents[tes3.event.mouseButtonDown] = true
				observeEvents[tes3.event.mouseWheel] = true
			end
			return observeEvents
		end}
	}
}

-- TODO: Implement flags for enabling the binding of mouse wheel or mouse buttons separately

return KeyBinder