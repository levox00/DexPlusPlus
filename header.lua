--[[
	Dex++
	Version 3.0
	
	Developed by Chillz
	
	Dex++ is a revival of Moon's Dex, made to fulfill Moon's Dex prophecy.
]]

local selection
local nodes = {}

-- Keep the DataModel and its descendants in the same reference space.
-- Some executor cloneref implementations produce uncached or nil references;
-- using them for the root can leave the Explorer unable to link services.
local oldgame = game
local game = workspace.Parent or oldgame
