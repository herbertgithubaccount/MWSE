--[[
	Base class for variables used by mcm
	To create a subclass, simply create it using Variable:new()
	and override the get/set functions.
	Within get/set functions, use self.id to get the variable id.

	e.g
		local Subclass = require("mcm.variables.Variable"):new()
		function Subclass:get()
			--DO STUFF
		end
		function Subvlass:set(newValue)
			--DO STUFF
		end
		return Subclass
]]--

--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local base = {}

--- @class mwseMCMVariable : herbert.Class
local Variable = Herbert_Class.new({
	fields={
		{"componentType", default="Variable"},
		{"inGameOnly", default=false},
		{"restartRequiredMessage", default=mwse.mcm.i18n("The game must be restarted before this change will come into effect.")},
	},
	obj_index=function (self, key)
		if key == "value" then
			return self:get()
		end
	end,
	obj_metatable={
		__newindex=function (obj, key, value)
			if key ~= "value" then
				rawset(obj, key, value)
				return
			end
			if obj.restartRequired then
				local sOk = tes3.findGMST(tes3.gmst.sOK).value --[[@as string]]
				tes3.messageBox { message = obj.restartRequiredMessage, buttons = { sOk } }
			end
			obj:set(value)
		end
	},
	new_obj_func=function(p1, p2)
		if p1 == base then
			return p2
		else
			return p1
		end
	end
}, base)



--- @return unknown value
function Variable:get()
	return rawget(self, "value")
end

--- @param newValue unknown
function Variable:set(newValue)
	rawset(self, "value", self:handleConverter(newValue))
end

---@protected
function Variable:handleConverter(val)
	local converter = self.converter
	if converter then
		return converter(val)
	else
		return val
	end
end

return Variable
