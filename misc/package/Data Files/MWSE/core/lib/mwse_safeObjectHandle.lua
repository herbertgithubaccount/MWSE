local SafeHandle = {}

-- used by instances of the SafeHandle class
local handleMetatable = {}

-- A map of tes3objects to their unsafe handle.
local handles = {} ---@type table<tes3object, table> stores one safe handle per object

--- Remove handles on object invalidated.
--- @param e objectInvalidatedEventData
event.register("objectInvalidated", function(e)
	local handle = handles[e.object]
	if handle ~= nil then
		rawset(handle, "_object", nil)
		handles[e.object] = nil
	end
end)

-- Create a new unsafe reference.
function SafeHandle.new(object)
	if (object == nil) then return end

	if handles[object] == nil then 
		handles[object] = setmetatable({ _object = object }, handleMetatable)
	end

	return handles[object]
end

function SafeHandle:valid()
	local object = rawget(self, "_object")
	return object ~= nil and not object.deleted
end

function SafeHandle:getObject()
	return rawget(self, "_object")
end

do -- fill out the metatable

	function handleMetatable.__index(handle, key)
		-- try to look things up in the `SafeHandle` class
		local val = rawget(SafeHandle, key)
		if val ~= nil then return val end

		-- try to look things up in the stored object, if it still exists

		local storedObject = SafeHandle.getObject(handle)
		assert(storedObject, "unsafe_object: This object has been invalidated.")

		val = storedObject[key]
		if type(val) == "function" then
			return function(_, ...) val(storedObject, ...) end
		end
		return val
	end

	-- Allow this handle to set values of the reference, with some checking.
	function handleMetatable.__newindex(handle, key, value)
		local object = assert(SafeHandle.getObject(handle), "unsafe_object: This object has been invalidated.")
		object[key] = value
	end

	-- Don't compare against this table. Compare against the reference instead.
	-- there is no guarantee as to whether the handle will be the left parameter, the right paraemeter, or both
	function handleMetatable.__eq(left, right)
		local leftMeta, rightMeta = getmetatable(left), getmetatable(right)
		if leftMeta == handleMetatable then
			if rightMeta == handleMetatable then
				return SafeHandle.getObject(left) == SafeHandle.getObject(right)
			else
				return SafeHandle.getObject(left) == right
			end
		elseif rightMeta == handleMetatable then
			return left == rawget(right, "_object")
		else 
			-- this will never be reached
		end
	end

	-- Add tostring() support.
	function handleMetatable.__tostring(handle)
		return tostring(SafeHandle.getObject(handle))
	end

	-- Add json support.
	function handleMetatable.__tojson(handle)
		local object = SafeHandle.getObject(handle)
		-- try to call the `__tojson` metamethod, if it exists
		if object ~= nil then
			local objectMetatable = getmetatable(object)
			if objectMetatable and objectMetatable.__tojson then
				return objectMetatable.__tojson(object)
			end
		end
		return "null"
	end
end

return SafeHandle