--[[
	Stores variable as a Global short, but treats it as a Boolean, returning true/false
]]--

--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

-- Parent class
local Parent = require("mcm.variables.Variable")

--- Class object
--- @class mwseMCMGlobalBoolean
local GlobalVar = Herbert_Class.new{parents={Parent}}
GlobalVar.inGameOnly = true

--- @return boolean|nil value
function GlobalVar:get()
	local global = tes3.findGlobal(self.id)
	if not global then
		mwse.log("ERROR: global %s does not exist", self.id)
		return
	end
	if global.value ~= nil then
		return global.value ~= 0
	end
end

--- @param newValue boolean
function GlobalVar:set(newValue)
	local global = tes3.findGlobal(self.id)
	if not global then
		mwse.log("ERROR: global %s does not exist", self.id)
		return
	end
	global.value = newValue and 1 or 0
end

return GlobalVar
