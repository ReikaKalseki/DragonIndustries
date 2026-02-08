--local MATCH_CACHE = {}

local tracker = {
	["add"] = {},
	["remove"] = {},
	--["globals"] = {}
}

local matchTracker = {
	["add"] = {},
	["remove"] = {},
	--["globals"] = {}
}

local tickGroups = {}

--call from all the entity creation/place/build events
function trackEntityAddition(entity, glbl)
	--local glbl = getGlobal(entity.name)
	local func = tracker["add"][entity.name]
	if func then
		func(glbl, entity, entity.force)
	else
		for k,func in pairs(matchTracker["add"]) do
			if string.find(entity.name, k, 1, true) then
				func(glbl, entity, entity.force)
			end
		end
	end
end

--call from all the entity removal/died/mined events
function trackEntityRemoval(entity, glbl)
	--local glbl = getGlobal(entity.name)
	local func = tracker["remove"][entity.name]
	if func then
		func(glbl, entity, entity.force)
	else
		for k,func in pairs(matchTracker["remove"]) do
			if string.find(entity.name, k, 1, true) then
				func(glbl, entity, entity.force)
			end
		end
	end
end

--call from onTick
function runTickHooks(glbl, tick)
	for _,func in pairs(tickGroups) do
		func(glbl, tick)
	end
end

function addTracker(name, add, _remove, tick--[[, globalID, glbl--]])
	log("Registering entity tracker for '" .. name .. "'")
	--local hook = getOrCreateTickGroup(globalID, glbl)
	--table.insert(hook.calls, tick)
	tracker["add"][name] = add
	tracker["remove"][name] = _remove
	table.insert(tickGroups, tick)
	--tracker["globals"][name] = glbl
end

function addMatcherTracker(name, add, _remove, tick--[[, globalID, glbl--]])
	log("Registering string-search entity tracker for '" .. name .. "'")
	--local hook = getOrCreateTickGroup(globalID, glbl)
	--table.insert(hook.calls, tick)
	matchTracker["add"][name] = add
	matchTracker["remove"][name] = _remove
	table.insert(tickGroups, tick)
	--matchTracker["globals"][name] = glbl
end


--remote.add_interface("entitytracker", {addTracker = addTracker, addMatcherTracker = addMatcherTracker})