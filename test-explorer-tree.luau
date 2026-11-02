local game = {Name = "game"}
local service = {Name = "Workspace", Parent = game}
local model = {Name = "Model", Parent = service}
local part = {Name = "Part", Parent = model}
local nodes = {[game] = {Obj = game}}
local ffa = function(obj) return obj.Parent end
local getDescendants = function() return {part, model, service} end
local warn = function(message) error(message) end
		local insts = getDescendants(game)
		local pending = {}
		-- GetDescendants does not promise parents before children.
		for i = 1,#insts do
			local obj = insts[i]
			if not nodes[obj] then
				local node = {Obj = obj}
				nodes[obj] = node
				pending[#pending+1] = node
			end
		end
		for i = 1,#pending do
			local node = pending[i]
			local ok, parent = pcall(ffa, node.Obj)
			local par = ok and nodes[parent]
			if par and par ~= node then
				node.Parent = par
				par[#par+1] = node
			else
				nodes[node.Obj] = nil
			end
		end
		if #nodes[game] == 0 then
			warn("Dex++: Explorer found no top-level objects; descendants returned: " .. tostring(#insts))
		end
assert(#nodes[game] == 1 and nodes[game][1] == nodes[service])
assert(nodes[service][1] == nodes[model] and nodes[model][1] == nodes[part])
assert(nodes[part].Parent == nodes[model] and nodes[service].Parent == nodes[game])
print("PASS reverse-order explorer tree links")
