
local index = {
    components = {},  ---@type table<string, mwseMCMComponent>
    variables = {} ---@type table<string, mwseMCMVariable>
}

-- local debugPaths = {}
local prefixLength = 1 + #"Data Files\\MWSE\\core\\"

for filePath, dir, fileName in lfs.walkdir("data files\\mwse\\core\\mcm\\components\\") do
    local key = fileName:sub(1, #fileName - 4)
    local luaPath = filePath:sub(prefixLength, #filePath - 4):gsub("[\\/]", ".")
    local component = require(luaPath)
    if component and type(component) == "table" then
        component.class = key
        index.components[key] = component
    end
end

for filePath, dir, fileName in lfs.walkdir("data files\\mwse\\core\\mcm\\variables\\") do
    local key = fileName:sub(1, #fileName - 4)
    local luaPath = filePath:sub(prefixLength, #filePath - 4):gsub("[\\/]", ".")
    local variable = require(luaPath)
    if variable and type(variable) == "table" then
        variable.class = key
        index.variables[key] = variable
    end
end

local mcm = require("mcm.mcm")
setmetatable(mcm, {__index=index})
-- mcm = getmetatable(mcm) or mcm

local Category = index.components.Category
local Template = index.components.Template
for key, component in pairs(index.components) do
    local createKey = "create" .. key

    Category[createKey] = function(self, data)
        local obj = component.new(data)
        obj.parentComponent = self
        table.insert(self.components, obj)
        return obj
    end

    Template[createKey] = function(self, data)
        local obj = component.new(data)
        obj.parentComponent = self
        table.insert(self.pages, obj)
        return obj
    end
    
    mcm[createKey] = function(p1, p2)
        local parent, data = nil, p1
        if p2 ~= nil then
            parent, data = p1, p2
        end
        local object = component.new(data)
        -- Add check for mcm field to deal with using `:` instead of `.`
        if parent and parent ~= mcm then
            object:create(parent)
        end
        return object
    end
end
Category.createHyperLink = Category.createHyperlink
Template.createHyperLink = Template.createHyperlink
mcm.createHyperLink = mcm.createHyperlink

for key, variable in pairs(index.variables) do
    mcm["create" .. key] = function(p1, p2)
        -- local data = p2 or p1
        -- data.class = key
        -- return variable:new(data)
        return variable.new(p2 or p1)
    end
end

