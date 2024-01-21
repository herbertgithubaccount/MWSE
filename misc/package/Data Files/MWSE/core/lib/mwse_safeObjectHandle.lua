local this = {}

-- A map of tes3objects to their unsafe handle.
local handles = {}

--- Remove handles on object invalidated.
--- @param e objectInvalidatedEventData
local function onObjectInvalidated(e)
	local handle = handles[e.object]
	if handle then
		handle.object = nil
		handles[e.object] = nil
	end
end

event.register("objectInvalidated", onObjectInvalidated)

local mwseSafeObjectHandleMetatable = {
	-- safe handles look up missing values in the `this` table
	__index = this,
	
	-- Don't compare against this table. Compare against the reference instead.
	__eq = function(self, value) return self.object == value end,

	__tostring = function(self) return tostring(self.object) end,

	-- calls the object's `tojson` method, if appropriate
	__tojson = function(self)
		-- see if the object has a metatable
		local metatbl = self.object and getmetatable(self.object)
		-- see if the metatable has a `__tojson` method
		if metatbl and metatbl.__tojson then
			return metatbl.__tojson(self.object)
		else
			return "null"
		end
	end
}

-- Create a new unsafe reference.
function this.new(object)
	if object == nil then return end

	-- Return a previous handle if applicable.
	if handles[object] then return handles[object] end

	
	local instance = {object = object}

	setmetatable(instance, mwseSafeObjectHandleMetatable)

	handles[object] = instance

	return instance
end


function this:valid()
	local obj = rawget(self, "object")
	return obj and not obj.deleted
end

function this:getObject() return self.object end

return this
