require "strings"

local inventoryTypes = {
	["character"] = defines.inventory.character_main,
	["chest"] = defines.inventory.chest,
	["cargo-wagon"] = defines.inventory.cargo_wagon,
	["boiler"] = defines.inventory.fuel,
	["nuclear-reactor"] = defines.inventory.fuel,
	["locomotive"] = defines.inventory.fuel,
	["assembling-machine"] = defines.inventory.crafter_input,
	["furnace"] = defines.inventory.crafter_input,
	["roboport"] = defines.inventory.roboport_robot,
	["lab"] = defines.inventory.lab_input,
	["car"] = defines.inventory.car_trunk,
	["ammo-turret"] = defines.inventory.turret_ammo,
	["artillery-turret"] = defines.inventory.artillery_turret_ammo,
	["artillery-wagon"] = defines.inventory.artillery_wagon_ammo,
	["beacon"] = defines.inventory.beacon_modules,
}

---@param entity LuaEntity
---@param quality LuaQualityPrototype|string
function respawnWithQuality(entity, quality)
	entity.surface.create_entity{name=entity.name, position=entity.position, force=entity.force, quality=quality, direction = entity.direction}
	entity.destroy()
end

---@param proto data.PrototypeBase
---@return int32
function getObjectTier(proto)
	--return splitAfter(proto.name, "%-")
	local val = 1
	for num in string.gmatch(proto.name, "%d+") do
		--log(num)
		val = math.max(val, tonumber(num))
	end
	return val
end

---@param ghost LuaEntity
function convertGhostToRealEntity(ghost)
	local modules = ghost.item_requests
	local _,repl = ghost.revive()
	
	if repl and repl.valid then
		for module, amt in pairs(modules) do
			repl.insert({name=module, count = amt})
		end
	end
end

---@param entity LuaEntity
---@param player LuaPlayer
function upgradeEntity(entity, player, repl)
	local pos = entity.position
	local force = entity.force
	local dir = entity.direction
	local surf = entity.surface
	--game.print("Upgrading " .. entity.name .. " @ " .. serpent.block(entity.position) .. " to " .. repl)
	local conn = entity.type == "underground-belt" and entity.neighbours or nil
	local type = entity.type == "underground-belt" and entity.belt_to_ground_type or nil
	local placed = surf.create_entity{name = repl, position = pos, force = force, direction = dir, player = player, fast_replace = true, type = type}
	--game.print("placed " .. serpent.block(placed))
	if conn then
		upgradeEntity(conn, player, repl)
	end
end

---@param player LuaPlayer
---@param range number
function convertGhostsNear(player, range)
	convertGhostsIn(player.surface, getRadiusAABB(player.character, range))
end

---@param surface LuaSurface
---@param box BoundingBox
function convertGhostsIn(surface, box) --box may be null, and so it searches the whole surface
	local ghosts = surface.find_entities_filtered{type = {"entity-ghost", "tile-ghost"}, area = box}
	for _,entity in pairs(ghosts) do
		if entity.type == "entity-ghost" then
			convertGhostToRealEntity(entity)
		elseif entity.type == "tile-ghost" then
			entity.revive()
		end
	end
end

---@param category string
---@param name string
---@param type_ string|[string]
---@param reduce? number
---@param percent? number
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
		fmtlog("Adding resistance to '%s/%s' with damage type '%s', which does not exist!", category, name, type_)
	end
	local obj = data.raw[category][name]
	if obj.resistances == nil then
		obj.resistances = {}
	end
	local resistance = createResistance(type_, reduce, percent)
	for _,v in ipairs(obj.resistances) do
		if v.type == type_ then --if resistance to that type already present, overwrite-with-max rather than have two for same type
			v.decrease = math.max(v.decrease and v.decrease or 0, reduce)
			v.percent = math.max(v.percent and v.percent or 0, percent)
			return
		end
	end
	table.insert(data.raw[category][name].resistances, resistance)
end

---@param type_ string
---@param reduce number
---@param percent_ number
---@return data.Resistance
function createResistance(type_, reduce, percent_)
return
{
        type = type_,
		decrease = reduce,
        percent = percent_
}
end

---@param entity LuaEntity
---@return LuaInventory?
function getPrimaryInventory(entity)
	local type = inventoryTypes[entity.type]
	if type then
		return entity.get_inventory(type)
	else
		return nil
	end
end

---@param entity LuaEntity
---@param signals [Signal]|{string: int}
---@param sectionName? string
function setConstantCombinatorSignals(entity, signals, sectionName)
	for i,signal in ipairs(val) do
		local slot = {
			index = i+def.inputCount,
			signal = {type = "virtual", name = signal.SignalID},
			count = signal.count
		}
		table.insert(params, slot)
	end
	
	--game.print("Setting " .. entry.id .. " > " .. serpent.block(val))

	local control = entry.entity.get_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
	control. = params
end

---@param wc LuaWireConnector?
---@param call fun(LuaEntity)
local function forEachWireConnectionThrough(wc, call)
	if not (wc and wc.valid) then return end
	for _,conn in pairs(wc.real_connections) do
		local other = conn.target.owner
		if other and other.valid then
			call(other)
		end
	end
end

---@param entity LuaEntity
---@param call fun(LuaEntity)
---@param connection? defines.wire_connector_id
function forEachWireConnection(entity, call, connection)
	if connection then
		forEachWireConnectionThrough(entity.get_wire_connector(connection, false), call)
	else
		for id,wc in pairs(entity.get_wire_connectors(false)) do
			forEachWireConnectionThrough(wc, call)
		end
	end
end