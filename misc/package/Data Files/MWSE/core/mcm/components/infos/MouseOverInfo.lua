--[[
	Info field that shows mouseover information for settings
]]--

--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local Parent = require("mcm.components.infos.Info")

--- @class mwseMCMMouseOverInfo
local MouseOverInfo = Parent:new()
MouseOverInfo.triggerOn = "MCM:MouseOver"
MouseOverInfo.triggerOff = "MCM:MouseLeave"


---@param comp mwseMCMComponent|mwseMCMSetting|nil
---@return string?
local function getComponentDescription(comp)
	if not comp then return end

	-- We should try to add defaults if `comp` is a `Setting`, and it has a `variable`
	-- and that `variable` has a `defaultSetting`
	---@type boolean|nil
	local shouldAddDefaults = (
		(comp.componentType == "Setting")
		and comp.showDefaultSetting 
		and comp.variable 
		and comp.variable.defaultSetting
	)
							  
	if not shouldAddDefaults then
		return comp.description -- This has type `string|nil`
	end
	---@cast comp mwseMCMSetting

	-- Now we add defaults to the description.
	local defaultStr = comp:convertToLabelValue(comp.variable.defaultSetting)

	-- No description exists yet? Then we'll only write the default value.
	if not comp.description then
		return string.format("%s: %s", mwse.mcm.i18n("Default"), defaultStr)
	end

	return string.format(
		"%s\n\n\z
		 %s: %s", 
		comp.description,
		mwse.mcm.i18n("Default"), defaultStr
	)
end

-- This function updates the `text` in this `Info` to be either the
-- `description` of the `Component`, or the `self.text` parameter of the `Info`.
--- @param component mwseMCMComponent|nil
function MouseOverInfo:updateInfo(component)

	-- If component has a description, update mouseOver
	-- Or return to original text on mouseLeave
	local newText = getComponentDescription(component) or self.text or "" 
	self.elements.info.text = newText
	self:update()
end

--- @param parentBlock tes3uiElement
function MouseOverInfo:makeComponent(parentBlock)
	Parent.makeComponent(self, parentBlock)

	--- @param component mwseMCMMouseOverInfo
	local function updateInfo(component)
		self:updateInfo(component)
	end

	-- Register events
	event.register(self.triggerOn, updateInfo)
	event.register(self.triggerOff, updateInfo)
	parentBlock:register("destroy", function()
		event.unregister(self.triggerOn, updateInfo)
		event.unregister(self.triggerOff, updateInfo)
	end)
	self:updateInfo()
end

return MouseOverInfo
