local function test(native, scenario)
local env = {}
local saveinstance = native
local calls, lastOptions, fetches = 0, nil, 0
local game = {GetService = function() return {IsStudio = function() return false end} end}
local oldgame = {HttpGet = function(_, url) fetches += 1; assert(string.find(url, "UniversalSynSaveInstance", 1, true)); return "source" end}
local loadstring = function() return function() return function(options) calls += 1; lastOptions = options; return "saved" end end end
local warn = function() end
		local nativeSaveInstance = saveinstance
		local universalSaveInstance
		local function saveWithUniversal(obj, filepath, options, wholePlace)
			if game:GetService("RunService"):IsStudio() then error("Cannot run in Roblox Studio!") end
			if not universalSaveInstance then
				local url = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.luau"
				local source = oldgame:HttpGet(url, true)
				local chunk, compileError = loadstring(source, "saveinstance")
				if not chunk then error("Could not compile USSI: " .. tostring(compileError)) end
				universalSaveInstance = chunk()
				if type(universalSaveInstance) ~= "function" then error("USSI did not return a save function") end
			end
			local saveOptions = {}
			for key, value in pairs(options or {}) do saveOptions[key] = value end
			saveOptions.FilePath = filepath
			if wholePlace then
				-- Do not rely on instance identity across executor-cloned game references.
				saveOptions.Object = nil
				saveOptions.IsModel = false
				saveOptions.mode = "full"
			else
				saveOptions.Object = obj
			end
			return universalSaveInstance(saveOptions)
		end
		env.saveinstance = function(obj, filepath, options, wholePlace)
			if type(nativeSaveInstance) == "function" then
				local ok, result = pcall(nativeSaveInstance, obj, filepath, options)
				if ok then return result end
				-- Some executors expose a different saveinstance signature and treat
				-- the filename as a configuration table. Only retry this known mismatch.
				local message = tostring(result)
				if not (message:find("RepoURL", 1, true) and message:find("string", 1, true)) then
					error(result, 0)
				end
				warn("Dex++: incompatible executor saveinstance signature; using USSI instead")
			end
			return saveWithUniversal(obj, filepath, options, wholePlace)
		end
		
local original = {Decompile = true}
local success, result = pcall(env.saveinstance, "object", "file.rbxl", original, scenario == "place")
if scenario == "place" then
 assert(success and lastOptions.Object == nil and lastOptions.IsModel == false and lastOptions.mode == "full" and lastOptions.FilePath == "file.rbxl")
elseif scenario == "mismatch" or scenario == "missing" then
 assert(success and result == "saved" and calls == 1 and fetches == 1)
 assert(lastOptions.Object == "object" and lastOptions.FilePath == "file.rbxl" and lastOptions.Decompile == true)
 assert(original.Object == nil and original.FilePath == nil)
 assert(env.saveinstance("object2", "file2.rbxl", original) == "saved" and fetches == 1)
elseif scenario == "native" then
 assert(success and result == "native" and calls == 0 and fetches == 0)
else
 assert(not success and string.find(result, "disk failure", 1, true) and fetches == 0)
end
end
test(function() error("attempt to index string with 'RepoURL'") end, "mismatch")
test(nil, "missing")
test(nil, "place")
test(function(obj, file, options) assert(obj == "object" and file == "file.rbxl" and options.Decompile); return "native" end, "native")
test(function() error("disk failure") end, "other")
print("PASS native compatibility, mismatch fallback, missing native, unrelated errors, options and cached loader")
