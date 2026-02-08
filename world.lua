require "tiles"

---@param surface LuaSurface
---@param x number
---@param y number
---@return boolean
function isWaterEdge(surface, x, y)
	return isWaterTile(surface.get_tile(x-1, y)) or isWaterTile(surface.get_tile(x+1, y)) or isWaterTile(surface.get_tile(x, y-1)) or isWaterTile(surface.get_tile(x, y+1))
end

---@param x number
---@param y number
---@param chunk BoundingBox
---@return boolean
function isInChunk(x, y, chunk)
	local minx = math.min(chunk.left_top.x, chunk.right_bottom.x)
	local miny = math.min(chunk.left_top.y, chunk.right_bottom.y)
	local maxx = math.max(chunk.left_top.x, chunk.right_bottom.x)
	local maxy = math.max(chunk.left_top.y, chunk.right_bottom.y)
	return x >= minx and x <= maxx and y >= miny and y <= maxy
end

---@param surface LuaSurface
---@param x int
---@param y int
---@return integer
function createSeed(surface, x, y) --Used by Minecraft MapGen
	local seed = surface.map_gen_settings.seed
	return bit32.band(cantorCombine(seed, cantorCombine(x, y)), 2147483647)
end