require "registration"

if not DIItemTypeCache then DIItemTypeCache = {} end

---@param item string|data.ItemPrototype
---@param name string
function mapItemType(item, name)
	if type(item) == "table" then item = item.type end
	--fmtlog("Mapping item '%s' to type '%s'", item, name)
	DIItemTypeCache[item] = name
end

--"drop" follows standard https://wiki.factorio.com/Types/ProductPrototype / https://wiki.factorio.com/Types/ItemProductPrototype
---@param proto data.EntityPrototype
---@param drop data.ProductPrototype
function addMineableDropToEntity(proto, drop)
	if not proto.minable then proto.minable = {mining_time = 1, results = {}} end
	if proto.minable.result and not proto.minable.results then
		proto.minable.results = {}
		table.insert(proto.minable.results, {type = "item", name = proto.minable.result, amount = proto.minable.count})
		proto.minable.result = nil
	end
	table.insert(proto.minable.results, drop)
end

---@param name string
---@return data.ItemPrototype|LuaItemPrototype|nil
function getItemByName(name)
	if prototypes then return prototypes.item[name] end
	local type = getItemOrFluidType(name)
	if not type then
		return nil
	end
	local item = data.raw[type][name] --[[@as data.ItemPrototype]]
	if not item then
		fmtlog("Could not find item '%s'", name)
		return nil
	end
	return item
end

---@param name string
---@return data.FluidPrototype|LuaFluidPrototype|nil
function getFluidByName(name)
	if prototypes then return prototypes.fluid[name] end
	return data.raw.fluid[name]
end

---@param name string
---@return data.ItemPrototype|LuaItemPrototype|data.FluidPrototype|LuaFluidPrototype|nil,boolean
function getItemOrFluidByName(name)
	local ret = getItemByName(name) ---@type data.ItemPrototype|LuaItemPrototype|data.FluidPrototype|LuaFluidPrototype|nil
	local fluid = false
	if not ret then
		ret = getFluidByName(name)
		fluid = ret ~= nil
	end
	return ret,fluid
end

---@param name string
---@return string|nil
function getItemOrFluidType(name) --returns either the item type ("item", "ammo", "tool", etc, or "fluid")
	if DIItemTypeCache["iron-plate"] == nil then fmterror("Tried to access item lookup before table was populated!") end
	local type = DIItemTypeCache[name]
	if type then
		return type
	elseif data.raw.fluid[name] then
		return "fluid"
	else
		fmtlog("No category was mapped for item or fluid name '%s'", name)
		return nil
	end
end

---@param item string|data.ItemPrototype|LuaItemPrototype
---@return data.ItemSubGroup|LuaGroup
function getItemCategory(item)
	if type(item) == "string" then
		item = getItemByName(item) --[[@as data.ItemPrototype|LuaItemPrototype]]
	end
	if not item then fmterror("No such item!") end
	if prototypes then
		return item.group
	else
		local sub = item.subgroup
		return data.raw["item-subgroup"][sub]
	end
end

---@param item string|data.ItemPrototype|LuaItemPrototype
---@param cat string
---@return boolean
function isItemInCategory(item, cat)
	return getItemCategory(item).name == cat
end