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

---@return {[string]: {[string]: [number]}}
local function createCircuitConnections()
	local ret = {
        shadow = {
          red = {0.375, 0.5625},
          green = {-0.125, 0.5625}
        },
        wire = {
          red = {0.375, 0.15625},
          green = {-0.125, 0.15625}
        }
    }
	return ret
end

---@param name string
---@return data.ConstantCombinatorPrototype
function createFixedSignalAnchor(name)
	local obj = createDerivative(data.raw["constant-combinator"]["constant-combinator"], {
		name = name,
		destructible = false,
		minable = "nil",
		order = "z",
		max_health = 100,
		collision_mask = {layers = {}},
		flags = {"placeable-neutral", "player-creation", "not-on-map", "placeable-off-grid", "not-blueprintable", "not-deconstructable"},
		selection_priority = 254,
		sprites = {
			north = createCircuitSprite(),
			west = createCircuitSprite(),
			east = createCircuitSprite(),
			south = createCircuitSprite(),
		},
		activity_led_sprites = {
			north = createEmptySprite(),
			west = createEmptySprite(),
			east = createEmptySprite(),
			south = createEmptySprite(),
		},	
		circuit_wire_connection_points = {
			createCircuitConnections(),
			createCircuitConnections(),
			createCircuitConnections(),
			createCircuitConnections(),
		}
	})
	
	return obj
end