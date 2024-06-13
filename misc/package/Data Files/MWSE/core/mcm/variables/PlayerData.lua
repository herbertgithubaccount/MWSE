--[[
	MCMData structure:
	variable = {
		id
		path			--OPTIONAL: path from tes3.player.data if it's nested in tables,
		class
		defaultSetting
	}
]]--

--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local Parent = require("mcm.variables.Variable")

--- Class object
--- @class mwseMCMPlayerData
local PlayerDataVar = Herbert_Class.new{parents={Parent}}
PlayerDataVar.inGameOnly = true

--- @return unknown value
function PlayerDataVar:get()
	if not tes3.player then 
		return self.defaultSetting
	end
	local current = tes3.player.data
	for key in self.path:gmatch("[^%.]+") do
		current = table.getset(current, key, {})
	end
	return table.getset(current, self.id, self.defaultSetting)
end

--- @param newValue unknown
function PlayerDataVar:set(newValue)
	if not tes3.player then return end

	local table = tes3.player.data
	for v in string.gmatch(self.path, "[^%.]+") do
		table = table[v]
	end

	table[self.id] = self:handleConverter(newValue)
end

return PlayerDataVar
