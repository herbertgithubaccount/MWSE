--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

-- Parent class
local Parent = require("mcm.variables.Variable")

--- Class object
--- @class mwseMCMGlobal
local GlobalVar = Herbert_Class.new{parents={Parent}}
GlobalVar.inGameOnly = true

--- @return number value
function GlobalVar:get()
	return tes3.findGlobal(self.id).value
end

--- @param newValue unknown
function GlobalVar:set(newValue)
	tes3.findGlobal(self.id).value = self:handleConverter(newValue)
end

return GlobalVar
