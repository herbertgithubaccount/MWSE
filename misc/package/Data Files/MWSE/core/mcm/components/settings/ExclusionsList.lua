--[[
	A very specialised, but still flexible page type that allows you
	to create filters on objects, plugins and more, and move them
	between allowed and blocked lists.
]]--

--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local utils = require("mcm.utils")
local Parent = require("mcm.components.settings.Setting")

---@enum mcm.listIndex
local LIST_INDEX = {
    left = 1,
    right = 2
}

---@class mwseMCMExclusionsListElements : mwseMCMComponentElements
---@field searchBars {[mcm.listIndex]: tes3uiElement}
---@field searchInputs {[mcm.listIndex]: tes3uiElement}
---@field lists {[mcm.listIndex]: tes3uiElement}
---@field filterList tes3uiElement
---@field sections tes3uiElement

--- @class mwseMCMExclusionsList : mwseMCMSetting
---@field elements mwseMCMExclusionsListElements
---@field showAllBlocked boolean
---@field filters mwseMCMExclusionsPageFilter[]
---@field currentItems string[]
---@field currentFilterIndex integer
local ExclusionsPage = Parent:new()
-- public fields
ExclusionsPage.label = mwse.mcm.i18n("Exclusions")

ExclusionsPage.listLabels = {
    [1] = mwse.mcm.i18n("Allowed"),
    [2] = mwse.mcm.i18n("Blocked"),
}
ExclusionsPage.toggleText = mwse.mcm.i18n("Toggle Filtered")

-- private fields
local itemID = tes3ui.registerID("ExclusionListItem")
local placeholderText = mwse.mcm.i18n("Search...")





function ExclusionsPage:resetSearchBars()
    for _, searchBar in ipairs(self.elements.searchBars) do  
        searchBar.text = ""
        searchBar:triggerEvent(tes3.uiEvent.keyPress)
    end
end


--- @param listIndex mcm.listIndex
function ExclusionsPage:updateSearch(listIndex)
    local searchString = self.elements.searchInputs[listIndex].text:lower()
    local list = self.elements.lists[listIndex]
    local listContent = list:getContentElement()
    for _, child in ipairs(list.children) do
        local itemIndex = child:getPropertyInt("MCM:ItemIndex")
        local item = self.currentItems[itemIndex]
        child.visible = item:lower():find(searchString, 1, true) ~= nil
    end

	list.widget:contentsChanged()
	self.elements.outerContainer:getTopLevelMenu():updateLayout()
end


---@param items string[]
function ExclusionsPage:distributeItems(items)
    local leftList = assert(self.elements.lists[LIST_INDEX.left])
    local rightList = assert(self.elements.lists[LIST_INDEX.right])
    leftList:getContentElement():destroyChildren()
    rightList:getContentElement():destroyChildren()

    -- if self.showAllBlocked then 
    --     for i, filter in ipairs(self.filters) do

    --     end
    -- end

    -- Happens each time an item gets clicked
    ---@param e tes3uiEventData
    local function clickItem(e)
        local set = self.variable.value
        local itemIndex = e.source:getPropertyInt("MCM:ItemIndex")
        local item = self.currentItems[itemIndex]

        local blocked = set[item]
        set[item] = not blocked or nil
        local newListIndex = blocked and LIST_INDEX.right or LIST_INDEX.left
        local newList = self.elements.lists[newListIndex]

        -- kill the old button
        e.source:destroy() 

        -- create a new button
        local newButton = newList:createTextSelect{ id = itemID, text = item}
        newButton:register(tes3.uiEvent.mouseClick, clickItem)

        -- update sorting
        local container = newList:getContentElement()

        -- inherit the sorting of the list
        container:sortChildren(function(a, b)
            local aIndex = a:getPropertyInt("MCM:ItemIndex")
            local bIndex = b:getPropertyInt("MCM:ItemIndex")
            return aIndex < bIndex
        end)

        -- update display
        self.elements.outerContainer:getTopLevelMenu():updateLayout()
    end

    local excluded = self.variable.value
    for i, name in ipairs(items) do
        local list = excluded[name] and leftList or rightList
        local textSelect = list:createTextSelect{id = itemID, text = name}
        textSelect:setPropertyInt("MCM:ItemIndex", i)
        textSelect:register(tes3.uiEvent.mouseClick, clickItem)
    end

    self.currentItems = items
end

--- @param listIndex mcm.listIndex
function ExclusionsPage:toggleFiltered(listIndex)
	-- Move all items currently filtered to opposite list

	local list = self.elements.lists[listIndex]
    local content = list:getContentElement()
    
    local var = self.variable.value
    for _, child in ipairs(content.children) do 
        if child.visible then
            local index = child:getPropertyInt("MCM:ItemIndex")
            local item = self.currentItems[index]
            var[item] = not var[item] or nil
        end
    end
	--destroy and recreate page
	self.elements.outerContainer.parent:destroyChildren()
	self:create(self.elements.outerContainer.parent)
end

--- @param filter tes3uiElement
function ExclusionsPage:clickFilter(filter)

	-- Turn all filters off
	for id, button in pairs(self.elements.filterList.children) do
		button.widget.state = tes3.uiState.normal
	end
	-- turn this filter back on
	filter.widget.state = tes3.uiState.active
end

-- UI creation functions

--- @param parentBlock tes3uiElement
--- @param listIndex mcm.listIndex
function ExclusionsPage:createSearchBar(parentBlock, listIndex)

	local searchBlock = parentBlock:createBlock()
	searchBlock.flowDirection = tes3.flowDirection.leftToRight
	searchBlock.autoHeight = true
	searchBlock.widthProportional = 1.0
	searchBlock.borderBottom = self.indent

	local searchBar = searchBlock:createThinBorder({ id = tes3ui.registerID("ExclusionsSearchBar") })
	searchBar.autoHeight = true
	searchBar.widthProportional = 1.0

    

    self.elements.searchBars[listIndex] = searchBar


	-- Create the search input itself.
	local input = searchBar:createTextInput({ id = tes3ui.registerID("ExclusionsSearchInput") })
	input.color = tes3ui.getPalette(tes3.palette.disabledColor)
	input.text = placeholderText
	input.borderLeft = 5
	input.borderRight = 5
	input.borderTop = 2
	input.borderBottom = 4
	input.widget.eraseOnFirstKey = true
	input.consumeMouseEvents = false

	-- Set up the events to control text input control.
	input:register(tes3.uiEvent.keyPress, function(e)
		local inputController = tes3.worldController.inputController

		local pressedTab = (inputController:isKeyDown(tes3.scanCode.tab))
        if pressedTab then return end

		local pressedDelete = (inputController:isKeyDown(tes3.scanCode.delete)) or (inputController:isKeyDown(tes3.scanCode.backspace))

        if pressedDelete and input.text == placeholderText then return end

		input:forwardEvent(e)

		input.color = tes3ui.getPalette(tes3.palette.normalColor)
		self:updateSearch(listIndex)
		input:updateLayout()
		if input.text == "" then
			input.text = placeholderText
			input.color = tes3ui.getPalette(tes3.palette.disabledColor)
		end
	end)

	-- Pressing enter applies toggle to all items currenty filtered
	input:register(tes3.uiEvent.keyEnter, function()
		self:toggleFiltered(listIndex)
	end)

    searchBar:register(tes3.uiEvent.mouseClick, function()
		tes3ui.acquireTextInput(input)
	end)

    self.elements.searchInputs[listIndex] = input


	

	-- Add button to exclude all currently filtered items
	local toggleButton = searchBlock:createButton({ text = self.toggleText })
	toggleButton.heightProportional = 1.0
	-- toggleButton.alignY = 0.0
	toggleButton.borderAllSides = 0
	toggleButton.paddingAllSides = 2
	toggleButton:register(tes3.uiEvent.mouseClick, function()
		self:toggleFiltered(listIndex)
	end)


end

---@param filter mwseMCMExclusionsPageFilter
---@param obj tes3object|tes3activator
---@return boolean
local function filterObject(filter, obj)
    if filter.noScripted and obj.script ~= nil then
       return false
    end
    for field, value in pairs(filter.objectFilters or {}) do
        if obj[field] ~= value then
            return false
        end
    end
    return true
end

---@param filter mwseMCMExclusionsPageFilter
---@return string[] items
function ExclusionsPage:getItems(filter)
    if filter.callback then 
        return filter.callback()
    end

    if filter.type == "Plugin" then
        local names = table.map(tes3.getModList(), function(_, m) 
            return m:lower() 
        end)
        table.sort(names)
        return names

    elseif filter.type == "Object" then
        local set = {}
        for obj in tes3.iterateObjects(filter.objectType) do
            local id = obj.id:lower()
            if not set[id] and filterObject(filter, obj) then
                set[id] = true
            end
        end
        return table.keys(set, true)
    end
    error("Invalid filter provided!")
end

--- @param parentBlock tes3uiElement
function ExclusionsPage:createFiltersSection(parentBlock)

	local block = parentBlock:createBlock{}
	block.flowDirection = tes3.flowDirection.topToBottom
	block.autoWidth = true
	block.heightProportional = 1.0
	block.borderTop = 13
	block.borderLeft = self.indent
	block.borderRight = self.indent

	local filterList = block:createBlock{ id = tes3ui.registerID("FilterList") }
	filterList.flowDirection = tes3.flowDirection.topToBottom
	filterList.autoWidth = true
	filterList.heightProportional = 1.0

	filterList.borderTop = 3

	-- Add buttons for each filter
	for _, filter in ipairs(self.filters) do
		local button = filterList:createButton{ text = filter.label }
		button.widthProportional = 1.0
		button.borderBottom = 5

		-- Register clicking filter button
		button:register(tes3.uiEvent.mouseClick, function(e)
			local items = self:getItems(filter)
			self:clickFilter(button)
            self:distributeItems(items)
			self:resetSearchBars()
		end)

	end

	if #self.filters <= 1 then
		filterList.visible = false
	end

	self.elements.filterList = filterList
end
---@alias mwseMCMExclusionsListSide
---|1 left
---|2 right

--- @param parentBlock tes3uiElement
--- @param listIndex mcm.listIndex
function ExclusionsPage:createList(parentBlock, listIndex)
    assert(listIndex == 1 or listIndex == 2, "ERROR: param 2 of createList must be 1 or 2.")

	local block = parentBlock:createBlock{}
	block.flowDirection = tes3.flowDirection.topToBottom
	block.widthProportional = 1.0
	block.heightProportional = 1.0

	local labelText = self.listLabels[listIndex] .. ":"
	local label = block:createLabel{ text = labelText }
	label.borderBottom = 2
	label.color = tes3ui.getPalette(tes3.palette.headerColor)

	self:createSearchBar(block, listIndex)

	-- Create actual list
	local list = block:createVerticalScrollPane{}
	list.widthProportional = 1.0
	list.heightProportional = 1.0
	list.paddingLeft = 8
	self.elements.lists[listIndex] = list

end

--- @param parentBlock tes3uiElement
function ExclusionsPage:createOuterContainer(parentBlock)
	local outerContainer = parentBlock:createThinBorder({ id = tes3ui.registerID("Category_OuterContainer") })
	outerContainer.flowDirection = tes3.flowDirection.topToBottom
	outerContainer.widthProportional = 1.0
	outerContainer.heightProportional = 1.0

	-- VerticalScrollPanes add 4 padding
	-- Because we are using a thinBorder, we match it here
	outerContainer.paddingLeft = 4 + self.indent
	outerContainer.paddingRight = 4 + self.indent
	outerContainer.paddingBottom = 4
	outerContainer.paddingTop = self.indent + 4
	self.elements.outerContainer = outerContainer
end

--- @param parentBlock tes3uiElement
function ExclusionsPage:createLabel(parentBlock)
	Parent.createLabel(self, parentBlock)
	if self.elements.label then
		self.elements.label.color = tes3ui.getPalette(tes3.palette.headerColor)
	end
end

-- --- @param parentBlock tes3uiElement
-- function ExclusionsPage:createDescription(parentBlock)
-- 	if not self.description then
-- 		return
-- 	end

-- 	local description = parentBlock:createLabel{ text = self.description }
-- 	-- description.heightProportional = -1
-- 	description.autoHeight = true
-- 	description.widthProportional = 1.0
-- 	description.wrapText = true
-- 	description.borderLeft = self.indent
-- 	description.borderRight = self.indent
-- 	self.elements.description = description
-- end

--- @param parentBlock tes3uiElement
function ExclusionsPage:createSections(parentBlock)
	local sections = parentBlock:createBlock{}
	sections.flowDirection = tes3.flowDirection.leftToRight
	sections.widthProportional = 1.0
	sections.heightProportional = 1.0
	sections.paddingAllSides = self.indent
	self.elements.sections = sections
end

--- @param parentBlock tes3uiElement
function ExclusionsPage:create(parentBlock)
    ---@diagnostic disable-next-line: missing-fields
	self.elements = {
        searchBars = {},
        searchInputs = {},
        lists = {},

    }

	self.mouseOvers = {}

	self:createOuterContainer(parentBlock)
	self:createLabel(self.elements.outerContainer)
	-- self:createDescription(self.elements.outerContainer)
	self:createSections(self.elements.outerContainer)
	self:createList(self.elements.sections, LIST_INDEX.left)
	self:createFiltersSection(self.elements.sections)
	self:createList(self.elements.sections, LIST_INDEX.right)

	-- default to first filter
	self.elements.filterList.children[1]:triggerEvent(tes3.uiEvent.mouseClick)
end

return ExclusionsPage
