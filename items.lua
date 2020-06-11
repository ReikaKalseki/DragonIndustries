require "registration"

--"drop" follows standard https://wiki.factorio.com/Types/ProductPrototype / https://wiki.factorio.com/Types/ItemProductPrototype
function addMineableDropToEntity(proto, drop)
	if not proto.minable then proto.minable = {mining_time = 1, results = {}} end
	if not proto.minable.results then
		proto.minable.results = {}
		table.insert(proto.minable.results, {type = "item", name = proto.minable.result, amount = proto.minable.count})
		proto.minable.result = nil
	end
	table.insert(proto.minable.results, drop)
end

function getItemByName(name)
	local keys = {"item", "tool", "ammo", "repair-tool", "selection-tool", "item-with-entity-data", "capsule", "armor", "module", "gun"}
	for _,k in pairs(keys) do
		if data.raw[k][name] then
			return data.raw[k][name]
		end
	end
end

function getItemType(name)
	if data.raw.fluid[name] then
		return "fluid"
	elseif getItemByName(name) then
		return "item"
	else
		error("Item " .. name .. " does not exist in any form!")
	end
end

function tryLoadItem(name, amt)
	if getItemByName(name) then
		return {type = "item", name = name, amount = amt}
	elseif data.raw.fluid[name] then
		return {type = "fluid", name = name, amount = amt}
	else
		return nil
	end
end

function tryLoadItemWithFallback(name, amt, fallback, fallbackamt)
	local val = tryLoadItem(name, amt)
	if val == nil and fallback ~= nil then
		amt = fallbackamt and fallbackamt or amt
		log("Item " .. name .. " not found; switching to fallback " .. fallback .. " x" .. amt)
		val = tryLoadItem(fallback, amt)
	end
	return val
end

--This is an expensive function to call!
function getEntityCategory(item)
	if type(item) == "string" then item = data.raw.item[item] end
	if not item then error(serpent.block("No such item found!")) end
	local place = item.place_result
	if place then
		local proto = getPrototypeByName(place)
		return proto and proto.type or nil
	end
end

local function isEntryInCategory(item, cat, nest)
	--log("Seeking for " .. serpent.block(item) .. " @ " .. nest)
	if type(item) == "table" then
		if nest == 0 and not item.name then  --is a list of items
			--log("Parsing list tabled value " .. serpent.block(item))
			for k,e in pairs(item) do
				if isEntryInCategory(e, cat, 1) then
					return true
				end
			end
		elseif item.name then --actually a table value, likely {type, name, amount}
			--log("Parsing named tabled value " .. serpent.block(item))
			if item.type == "item" then
				if not data.raw.item[item.name] then error("Recipe produces nonexistent item '" .. item.name .. "'!") end
				if isEntryInCategory(item.name, cat, nest+1) then
					return true
				end
			else
				
			end
		else
			--log("ERROR Parsing tabled value " .. serpent.block(item))
		end
		return false
	elseif type(item) == "string" then
		local ref = getItemByName(item)
		if not ref then error("Recipe produces nonexistent item '" .. item .. "'!") end
		if not ref.place_result then return false end
		for name,proto in pairs(data.raw[cat]) do
			if ref.place_result == name then
				return true
			end
		end
	end
end

function isItemInCategory(item, cat)
	return isEntryInCategory(item, cat, 0)
end