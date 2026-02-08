require "arrays"

---@param tile LuaTile|data.TilePrototype
---@return boolean
function isWaterTile(tile)
	return tile.valid and hasCollisionMask(tile, "water-tile")
end

---@param surface LuaSurface
---@param x int
---@param y int
---@param name string|[string]
---@return boolean
function isTileType(surface, x, y, name)
	if not surface then return false end
	if not surface.valid then return false end
	local tile = surface.get_tile(x, y)
	if not tile.valid then return false end
	if type(name) == "table" then
		for _,seek in pairs(name) do
			if string.find(tile.name, seek, 1, true) then
				return true
			end
		end
	else
		return string.find(tile.name, name, 1, true) ~= nil
	end
	return false
end