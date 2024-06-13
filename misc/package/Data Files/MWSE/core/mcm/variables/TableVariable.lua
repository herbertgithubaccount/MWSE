--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local Parent = require("mcm.variables.Variable")

--- @class mwseMCMTableVariable
local TableVariable = Herbert_Class.new{parents={Parent}}

--- @return unknown value
function TableVariable:get()
	table.getset(self.table, self.id, self.defaultSetting)
	return self.table[self.id]
end

--- @param newVal unknown
function TableVariable:set(newVal)
	self.table[self.id] = self:handleConverter(newVal)
end

return TableVariable
