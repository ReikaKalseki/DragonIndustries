require "util"
require "di-utils"
require "arrays"

local maxQuality = nil

---@return data.QualityPrototype|LuaQualityPrototype
function getHighestQuality()
	if not maxQuality then
		local arr = prototypes and prototypes.quality or data.raw.quality
		for name,quality in pairs(arr) do
			if not maxQuality or maxQuality.level < quality.level then
				maxQuality = quality
			end
		end
	end
	return maxQuality
end

---@param objects table
function registerObjectArray(objects)
	for _,obj in pairs(objects) do
		if type(obj) == "table" then
			data:extend({obj})
		end
	end
end

---@param template table
---@param overrides table
---@return table
function addDerivativeFull(template, overrides)
	local derived = createDerivative(template, overrides)
	data:extend({derived})
	return derived
end

---@param type string
---@param name string
---@param overrides table
---@return table
function addDerivative(type, name, overrides)
	if not data.raw[type] then error(string.format("No such prototype type '%s' to add a derivative of '%s'!", type, name)) end
	if not data.raw[type][name] then error(string.format("No such prototype '%s/%s' to add a derivative of!", type, name)) end
	return addDerivativeFull(data.raw[type][name], overrides)
end
--[[
function createBasicCraftingItem(name, icon, ingredients, time, stacksize)
	local item = createDerivative(data.raw.item["iron-plate"], {
		name = name,
		icon = icon,
		order = "o[" .. name .. "]",
		stack_size = stacksize
	})
	local recipe = createDerivative(data.raw.recipe["iron-gear-wheel"], {
		name = name,
    	enabled = false,
    	ingredients = ingredients,
    	energy_required = time,
    	results = {{type = "item", name = name}}
	})
  return item, recipe
end
--]]

---@param layers table
---@return table
function apply_heat_pipe_glow_stack(layers)
	local ret = {}
	for _,layer in pairs(layers) do
		local substack = apply_heat_pipe_glow(layer)
		for _,img in pairs(substack.layers) do
			table.insert(ret, img)
		end
	end
	return ret
end