--[[
	A basic Page. Components are displayed in a vertical scroll pane.
]]--

--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local Parent = require("mcm.components.categories.Category")

--- @class mwseMCMPage : mwseMCMCategory
---@field indent integer
local Page = Herbert_Class.new{parents={Parent},
	fields={
		{"componentType", default="Page"},
		{"indent", default=6},
		{"label", factory=function (self)
			local parentPages = self.parentComponent and self.parentComponent.pages
			return parentPages and ("Page " .. (1 + #parentPages))
				or "Page"
		end},
		{"tabUID", factory=function (self)
			return tes3ui.registerID("Page_" .. self.label)
		end}
	}}


--- @param parentBlock tes3uiElement
function Page:createLabel(parentBlock)
	if self.showHeader then
		Parent.createLabel(self, parentBlock)
	end
end

function Page:disable()
	-- Update and grey out page label
	if self.elements.label then
		self.elements.label.text = string.format("%s (%s)", self.elements.label.text, mwse.mcm.i18n("In-Game Only"))
		self.elements.label.color = tes3ui.getPalette("disabled_color")
	end
	-- Grey out all child elements
	for _, element in ipairs(self.elements.subcomponentsContainer.children) do
		if element.color then
			element.color = tes3ui.getPalette("disabled_color")
		end
	end
end

--- @param parentBlock tes3uiElement
function Page:createOuterContainer(parentBlock)
	local border

	if self.noScroll then
		border = parentBlock:createThinBorder({ id = tes3ui.registerID("Page_thinBorder") })
		border.heightProportional = 1.0
		border.widthProportional = 1.0
		border.autoHeight = true
		border.flowDirection = "top_to_bottom"
		border.paddingTop = 4
		border.paddingLeft = 4
	else
		border = parentBlock:createVerticalScrollPane({ id = tes3ui.registerID("Page_ScrollPane") })
		border.heightProportional = 1.0
		border.widthProportional = 1.0
	end

	local outerContainer = border:createBlock({ id = tes3ui.registerID("Page_OuterContainer") })
	outerContainer.flowDirection = "top_to_bottom"
	outerContainer.autoHeight = true
	outerContainer.heightProportional = 1.0
	outerContainer.widthProportional = 1.0
	outerContainer.paddingLeft = self.indent
	outerContainer.paddingTop = self.indent

	self.elements.outerContainer = outerContainer
end

return Page
