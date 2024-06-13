--[[
	Button Setting for binding a mouse button + modifier key combination. Variable returned in the form:
		{
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

--- @class mwseMCMMouseBinder
local MouseBinder = Herbert_Class.new{parents={Parent},
    fields={
        {"allowButtons", default=true},
        {"observeEvents", factory=function (self)
            local observeEvents = {}
            observeEvents = {}
            if self.allowButtons then
                observeEvents[tes3.event.mouseButtonDown] = true
            end
            if self.allowWheel then
                observeEvents[tes3.event.mouseWheel] = true
            end
            return observeEvents
        end}
    },
    post_init=function (self)
        Parent.__secrets.post_init(self)
        assert(self.allowButtons or self.allowWheel, 
            "[MouseBinder]: Both allowButtons and allowWheel options are false. \z
            At least one needs to be enabled to use MouseBinder."
        )
    end
}

return MouseBinder