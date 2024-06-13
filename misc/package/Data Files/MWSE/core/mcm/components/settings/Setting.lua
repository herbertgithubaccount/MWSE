--[[
	A setting is a component that can be interacted with, such as a button or text input.
	It can have, but doesn't require, an associated variable.
]]--

--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local Parent = require("mcm.components.Component")

--- @class mwseMCMSetting
local Setting = Herbert_Class.new{parents={Parent},
	fields={
		{"variable"},
		{"componentType", default = "Setting"},
		{"restartRequired", default = false},
		{"restartRequiredMessage", default = mwse.mcm.i18n("The game must be restarted before this change will come into effect.")},


	},
	post_init=function (self)
		local v = self.variable
		if not v then return end
		v.defaultSetting = v.defaultSetting or self.defaultSetting
		self.variable = mwse.mcm.variables[v.class].new(v)
	end
}


function Setting:insertMouseovers(element)
	table.insert(self.mouseOvers, element)
	for _, child in ipairs(element.children or {}) do
		self:insertMouseovers(child)
	end
end

function Setting:update()
	if self.restartRequired then

		tes3.messageBox { message = self.restartRequiredMessage, buttons = { self.sOK } }
	end
	if self.callback then
		self:callback()
	end
end

function Setting:checkDisabled()
	-- override the variable
	if self.inGameOnly ~= nil then
		return not tes3.player and self.inGameOnly
	end
	-- Components with variable
	local disabled = (self.variable and self.variable.inGameOnly == true and not tes3.player)
	return disabled --[[@as boolean]]
end

--- @param parentBlock tes3uiElement
function Setting:createContentsContainer(parentBlock)
	self:createLabel(parentBlock)
	self:createInnerContainer(parentBlock)
	self:makeComponent(self.elements.innerContainer)
end


function Setting:convertToLabelValue(variableValue)
	return variableValue
end

return Setting
