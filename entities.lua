require "strings"

local inventoryTypes = {
	["character"] = defines.inventory.character_main,
	["chest"] = defines.inventory.chest,
	["cargo-wagon"] = defines.inventory.cargo_wagon,
	["boiler"] = defines.inventory.fuel,
	["nuclear-reactor"] = defines.inventory.fuel,
	["locomotive"] = defines.inventory.fuel,
	["assembling-machine"] = defines.inventory.assembling_machine_input,
	["furnace"] = defines.inventory.furnace_source,
	["roboport"] = defines.inventory.roboport_robot,
	["lab"] = defines.inventory.lab_input,
	["car"] = defines.inventory.car_trunk,
	["ammo-turret"] = defines.inventory.turret_ammo,
	["artillery-turret"] = defines.inventory.artillery_turret_ammo,
	["artillery-wagon"] = defines.inventory.artillery_wagon_ammo,
	["beacon"] = defines.inventory.beacon_modules,
}

function getObjectTier(proto)
	--return splitAfter(proto.name, "%-")
	local val = 1
	for num in string.gmatch(proto.name, "%d+") do
		--log(num)
		val = math.max(val, tonumber(num))
	end
	return val
end

function createTotalResistance()
	local ret = {}
	for name,damage in pairs(data.raw["damage-type"]) do
		table.insert(ret, {type = name, percent = 100})
	end
	return ret
end

function addCategoryResistance(category, type_, reduce, percent)
	if not data.raw[category] then error("No such category '" .. category .. "'!") end
	for k,v in pairs(data.raw[category]) do
		addResistance(category, k, type_, reduce, percent)
	end
end

function addResistance(category, name, type_, reduce, percent)
	if type(type_) == "table" then
		for _,tt in pairs(type_) do
			addResistance(category, name, tt, reduce, percent)
		end
		return
	end
	if not reduce then reduce = 0 end
	if not percent then percent = 0 end
	if data.raw["damage-type"][type_] == nil then
		log("Adding resistance to '" .. category .. "/" .. name .. "' with damage type '" .. type_ .. "', which does not exist!")
	end
	local obj = data.raw[category][name]
	if obj.resistances == nil then
		obj.resistances = {}
	end
	local resistance = createResistance(type_, reduce, percent)
	for k,v in pairs(obj.resistances) do
		if v.type == type_ then --if resistance to that type already present, overwrite-with-max rather than have two for same type
			v.decrease = math.max(v.decrease and v.decrease or 0, reduce)
			v.percent = math.max(v.percent and v.percent or 0, percent)
			return
		end
	end
	table.insert(data.raw[category][name].resistances, resistance)
end

function createResistance(type_, reduce, percent_)
return
{
        type = type_,
		decrease = reduce,
        percent = percent_
}
end

entityCategories = {
    "arrow",
    "artillery-flare",
    "artillery-projectile",
    "beam",
    "character-corpse",
    "cliff",
    "corpse",
    "rail-remnants",
    "deconstructible-tile-proxy",
    "entity-ghost",
    "accumulator",
    "artillery-turret",
    "beacon",
    "boiler",
    "burner-generator",
    "character",
    "arithmetic-combinator",
    "decider-combinator",
    "constant-combinator",
    "container",
    "logistic-container",
    "infinity-container",
    "assembling-machine",
    "rocket-silo",
    "furnace",
    "electric-energy-interface",
    "electric-pole",
    "unit-spawner",
    "fish",
    "combat-robot",
    "construction-robot",
    "logistic-robot",
    "gate",
    "generator",
    "heat-interface",
    "heat-pipe",
    "inserter",
    "lab",
    "lamp",
    "land-mine",
    "market",
    "mining-drill",
    "offshore-pump",
    "pipe",
    "infinity-pipe",
    "pipe-to-ground",
    "player-port",
    "power-switch",
    "programmable-speaker",
    "pump",
    "radar",
    "curved-rail",
    "straight-rail",
    "rail-chain-signal",
    "rail-signal",
    "reactor",
    "roboport",
    "simple-entity",
    "simple-entity-with-owner",
    "simple-entity-with-force",
    "solar-panel",
    "storage-tank",
    "train-stop",
    "loader-1x1",
    "loader",
    "splitter",
    "transport-belt",
    "underground-belt",
    "tree",
    "turret",
    "ammo-turret",
    "electric-turret",
    "fluid-turret",
    "unit",
    "car",
    "artillery-wagon",
    "cargo-wagon",
    "fluid-wagon",
    "locomotive",
    "wall",
    "explosion",
    "flame-thrower-explosion",
    "fire",
    "stream",
    "flying-text",
    "highlight-box",
    "item-entity",
    "item-request-proxy",
    "particle-source",
    "projectile",
    "resource",
    "rocket-silo-rocket",
    "rocket-silo-rocket-shadow",
    "smoke-with-trigger",
    "speech-bubble",
    "sticker",
    "tile-ghost",
}

function getPrimaryInventory(entity)
	local type = inventoryTypes[entity.type]
	if type then
		return entity.get_inventory(type)
	else
		return nil
	end
end