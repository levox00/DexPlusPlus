local function check(candidate, expected)
 local cloneref = candidate
local executorCloneref = cloneref
local function cloneref(ref)
	if type(executorCloneref) == "function" then
		local ok, result = pcall(executorCloneref, ref)
		if ok and result ~= nil then return result end
	end
	return ref
end

 local ref = {}
 local result = cloneref(ref)
 assert(result == (expected or ref))
end
check(nil)
check(function() return nil end)
check(function() error("broken") end)
local clone = {}
check(function() return clone end, clone)
print("PASS cloneref absent, nil, error, and valid")
