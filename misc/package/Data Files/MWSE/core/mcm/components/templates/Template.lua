--- These types have annotations in the core\meta\ folder. Let's stop the warning spam here in the implementation.
--- The warnings arise because each field set here is also 'set' in the annotations in the core\meta\ folder.
--- @diagnostic disable: duplicate-set-field

local utils = require("mcm.utils")

local Parent = require("mcm.components.Component")
local Component = require("mcm.components.Component")

local currentSearchText = ""
local currentCaseSensitive = true

--- Class object
--- @class mwseMCMTemplate
local Template = Parent:new()


Template.componentType = "Template"

--- @param data mwseMCMTemplate.new.data
--- @return mwseMCMTemplate template
function Template:new(data)
	data.name = data.name or data.label
	local t = Parent:new(data)
	setmetatable(t, self)

	-- Create Pages
	local pages = {}
	t.pages = t.pages or {}
	for _, page in ipairs(t.pages) do
		-- Make sure it's actually a `Page`.
		if not page.componentType then
			local componentClass = utils.getComponentClass(page.class or "Page")
			if not componentClass then
				error(string.format("Could not intialize page %q", page.label))
			end
			page.parentComponent = self
			page = componentClass:new(page)
		end
		table.insert(pages, page)
	end
	t.pages = pages

	self.__index = Template.__index
	return t --[[@as mwseMCMTemplate]]
end

--- @param fileName string
--- @param config unknown
function Template:saveOnClose(fileName, config)
	self.onClose = function()
		mwse.saveConfig(fileName, config)
	end
end

function Template:searchTextMatches(searchText, caseSensitive)
	-- Do we have a custom search handler?
	if (self.onSearch and self.onSearch(searchText, caseSensitive)) then
		return true
	end

	-- Go through and search children.
	for _, page in ipairs(self.pages) do
		if page:searchTextMatches(searchText, caseSensitive) then
			return true
		end
	end
end
---@deprecated
Template.onSearchInternal = Template.searchTextMatches

---@param visibility boolean
function Template:setVisibility(visibility)
	self.elements.outerContainer.visible = visibility
	for _, page in ipairs(self.pages) do
		page:setVisibility(visibility)
	end
end

---@param searchText string The text to search for. Will be lowercased if `caseSensitive == false`.
---@param caseSensitive boolean Whether the search is case-sensitive or not.
function Template:filterCurrentPage(searchText, caseSensitive)
	if not self.currentPage then return end
	self.currentPage:filter(searchText, caseSensitive)
end

--- Filters components recursively as follows:
--- 1) If a category matches the search text: All subcomponents of that category are made visible.
--- 2) If a setting withing a category matches the search text: That setting and its parent category are made visible.
---    Other components within the same category are hidden, unless they also match the search text.
---@param searchText string The text to search for. Will be lowercased if `caseSensitive == false`.
---@param caseSensitive boolean Whether the search is case-sensitive or not.
---@return boolean atLeastOneComponentVisible True if at least one component in this category is visible, false otherwise.
function Template:filter(searchText, caseSensitive)
	local atLeastOnePageVisible = false
	if Component.searchTextMatches(self, searchText, caseSensitive) then
		self:setVisibility(true)
		return true
	end
	for _, page in ipairs(self.pages) do
		local pageFiltered = page:filter(searchText, caseSensitive)
		atLeastOnePageVisible = atLeastOnePageVisible or pageFiltered
	end
	Component.setVisibility(self, atLeastOnePageVisible)
	return atLeastOnePageVisible
end

--- @param callback nil|fun(searchText: string): boolean
function Template:setCustomSearchHandler(callback)
	self.onSearch = callback
end

--- @param parentBlock tes3uiElement
function Template:createOuterContainer(parentBlock)
	Parent.createOuterContainer(self, parentBlock)
	self.elements.outerContainer.heightProportional = 1.0
	self.elements.outerContainer.paddingBottom = 0
	self.elements.outerContainer.paddingLeft = 0
	self.elements.outerContainer.paddingRight = 0
end

--- @param parentBlock tes3uiElement
function Template:createLabel(parentBlock)
	-- header image
	local headerBlock = parentBlock:createBlock()
	headerBlock.autoHeight = true
	headerBlock.widthProportional = 1.0
	local imagePath = self.headerImagePath
	if imagePath then
		local headerImage = headerBlock:createImage({ path = imagePath })
		headerImage.absolutePosAlignX = 0.5
		headerImage.autoHeight = true
		headerImage.widthProportional = 1.0
		headerImage.imageScaleX = 0.5
		headerImage.imageScaleY = 0.5
	elseif self.label then
		headerBlock.borderAllSides = 10
		local title = headerBlock:createLabel({ text = self.label })
		title.color = tes3ui.getPalette(tes3.palette.headerColor)
	end

end

--- @param page mwseMCMExclusionsPage|mwseMCMFilterPage|mwseMCMMouseOverPage|mwseMCMPage|mwseMCMSideBarPage
function Template:clickTab(page)
	local pageBlock = self.elements.pageBlock

	-- Clear previous page
	pageBlock:destroyChildren()
	-- Create new page
	page:create(pageBlock)
	-- Set new page to current
	self.currentPage = page
	self:filterCurrentPage(currentSearchText, currentCaseSensitive)

	local tabsBlock = self.elements.tabsBlock

	-- Update the tabs (if there are any)
	if tabsBlock then
		-- Disable tabs and tally width
		local totalWidth = 0
		for _id, page in pairs(self.pages) do
			local tab = tabsBlock:findChild(page.tabUID)
			tab.widget.state =  tes3.uiState.normal
			totalWidth = totalWidth + tab.width
		end
		-- Enable tab for this page
		local tab = tabsBlock:findChild(page.tabUID)
		tab.widget.state = tes3.uiState.active

		-- Ensure tabs are visible.
		tabsBlock.childOffsetX = 0
		tabsBlock:updateLayout()
		tabsBlock.childOffsetX = math.clamp(-tab.positionX, -totalWidth + tabsBlock.width, 0)

		self:padTabBlock()
	end

	-- update view
	pageBlock:getTopLevelMenu():updateLayout()
end

--- @param button tes3uiElement
local function formatTabButton(button)
	button.borderAllSides = 0
	button.paddingTop = 4
	button.paddingLeft = 8
	button.paddingRight = 8
	button.paddingBottom = 6
end

local arrowPrevious = {
	id = "MCM_PreviousButton",
	idle = "textures/mwse/menu_arrow_prev.tga",
	over = "textures/mwse/menu_arrow_prev.tga",
	pressed = "textures/mwse/menu_arrow_prev_pressed.tga",
}

local arrowNext = {
	id = "MCM_NextButton",
	idle = "textures/mwse/menu_arrow_next.tga",
	over = "textures/mwse/menu_arrow_next.tga",
	pressed = "textures/mwse/menu_arrow_next_pressed.tga",
}

--- @param element tes3uiElement
local function createArrow(element, imageParams)
	local arrow = element:createImageButton(imageParams)
	arrow.height = 32
	arrow.childOffsetY = 2
	return arrow
end

--- @param page mwseMCMExclusionsPage|mwseMCMFilterPage|mwseMCMMouseOverPage|mwseMCMPage|mwseMCMSideBarPage
function Template:createTab(page)
	local button = self.elements.tabsBlock:createButton({ id = page.tabUID, text = page.label })
	formatTabButton(button)
	button:register(tes3.uiEvent.mouseClick, function()
		self:clickTab(page)
	end)
end

function Template:padTabBlock()
	local totalWidth = 0
	for _, page in pairs(self.pages) do
		local tab = self.elements.tabsBlock:findChild(page.tabUID)
		totalWidth = totalWidth + tab.width
	end

	self.elements.tabsBlock.borderRight = self.elements.tabsBlock.parent.width - totalWidth
	self.elements.tabsBlock.parent:updateLayout()
end

--- @param parentBlock tes3uiElement
function Template:createTabsBlock(parentBlock)
	local outerTabsBlock = parentBlock:createBlock()
	self.elements.outerTabsBlock = outerTabsBlock
	outerTabsBlock.autoHeight = true
	outerTabsBlock.widthProportional = 1.0

	-- Create a tab for each page (no need if only one page)
	if #self.pages <= 1 then
		return
	end

	-- Previous Button
	self.elements.previousTabButton = createArrow(outerTabsBlock, arrowPrevious)

	local subBlock = outerTabsBlock:createBlock()
	subBlock.autoHeight = true
	subBlock.widthProportional = 1
	-- Create page tab buttons
	local tabsBlock = subBlock:createThinBorder()
	self.elements.tabsBlock = tabsBlock
	tabsBlock.autoHeight = true
	tabsBlock.widthProportional = 1
	tabsBlock.childOffsetX = 0
	for _, page in ipairs(self.pages) do
		self:createTab(page)
	end
	local firstTab = parentBlock:findChild(self.pages[1].tabUID)
	firstTab.widget.state = tes3.uiState.active

	-- Next Button
	self.elements.nextTabButton = createArrow(outerTabsBlock, arrowNext)

	-- Pagination
	self.elements.nextTabButton:register(tes3.uiEvent.mouseClick, function()
		-- Move active tab forward 1
		for i, page in ipairs(self.pages) do
			local tab = tabsBlock:findChild(page.tabUID)
			if tab.widget.state == tes3.uiState.active then
				self:clickTab(self.pages[table.wrapindex(self.pages, i + 1)])
				break
			end
		end
	end)

	self.elements.previousTabButton:register(tes3.uiEvent.mouseClick, function()
		-- Move active tab back 1
		for i, page in ipairs(self.pages) do
			local tab = tabsBlock:findChild(page.tabUID)
			if tab.widget.state == tes3.uiState.active then
				self:clickTab(self.pages[table.wrapindex(self.pages, i - 1)])
				break
			end
		end
	end)

	parentBlock:registerAfter(tes3.uiEvent.update, function() self:padTabBlock() end)
	outerTabsBlock:updateLayout()
	self:padTabBlock()
end

--- @param parentBlock tes3uiElement
function Template:createSubcomponentsContainer(parentBlock)
	local pageBlock = parentBlock:createBlock()
	pageBlock.heightProportional = 1.0
	pageBlock.widthProportional = 1.0
	pageBlock.flowDirection = tes3.flowDirection.leftToRight
	self.elements.pageBlock = pageBlock
	self:clickTab(self.currentPage or self.pages[1])
end

--- @param parentBlock tes3uiElement
function Template:createContentsContainer(parentBlock)
	self:createLabel(parentBlock)
	self:createTabsBlock(parentBlock)
	self:createSubcomponentsContainer(parentBlock)
end

function Template:register()
	---@type mwse.registerModConfig.package
	local mcm = { template = self }

	--- @param container tes3uiElement
	mcm.onCreate = function(container)
		self:create(container)
		mcm.onClose = self.onClose
	end

	--- @param searchText string
	--- @param caseSensitive boolean
	--- @return boolean
	mcm.onSearch = function(searchText, caseSensitive)
		currentSearchText = searchText
		currentCaseSensitive = caseSensitive
		return self:searchTextMatches(searchText, caseSensitive)
	end

	mwse.registerModConfig(self.name, mcm)
	mwse.log("%s mod config registered", self.name)
end

function Template.__index(tbl, key)
	-- If the `key` starts with `"create"`, and if there's an `mwse.mcm.create<Component>` method,
	-- Make a new `Template.create<Component>` method.
	-- Otherwise, look the value up in the `metatable`.

	if not key:startswith("create") or mwse.mcm[key] == nil then
		return getmetatable(tbl)[key]
	end

	Template[key] = function(self, data)
		if not data then
			data = {}
		elseif type(data) == "string" then
			data = { label = data }
		end
		data.parentComponent = self
		local component = mwse.mcm[key](data)
		table.insert(self.pages, component)
		return component
	end

	return Template[key]
end

return Template
