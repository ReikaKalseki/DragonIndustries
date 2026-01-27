require "strings"
require "sprites"
require "di-utils"

---@param category string
---@param name string
---@param newname string
---@return data.EntityPrototype|data.ItemPrototype
function copyObject(category, name, newname)
	fmtlog("Cloning object '%s/%s' into '%s'...", category, name, newname)
	local base = data.raw[category][name]
	if not base then error("Object data.raw[" .. category .. "][" .. name .. "] does not exist!") end
    local obj = createDerivative(base, {
		name = newname
	}) --[[@as data.EntityPrototype|data.ItemPrototype]]
    if obj.minable then
		obj.minable.results = nil
		obj.minable.result = newname
    end
	if obj.place_result then
		obj.place_result = newname
	end
	if obj.order then
		obj.order = literalReplace(obj.order, "[" .. obj.name .. "]", "[" .. newname .. "]")
	end
	return obj
end
