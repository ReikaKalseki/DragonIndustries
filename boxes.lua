require "mathhelper"

---@param area BoundingBox
---@param dx number
---@param dy number
---@return BoundingBox
function moveBox(area, dx, dy)
	--printTable(area)
	area.left_top.x = area.left_top.x+dx
	area.left_top.y = area.left_top.y+dy
	area.right_bottom.x = area.right_bottom.x+dx
	area.right_bottom.y = area.right_bottom.y+dy
	return area
end

function moveBoxDirection(area, dir, dist)
	local vec = directionToVector(dir)
	return moveBox(area, dist*vec[1], dist*vec[2])
end

---@param area BoundingBox
---@param padX number
---@param padY number
---@return BoundingBox
function padBox(area, padX, padY)
	area.left_top.x = area.left_top.x-padX
	area.left_top.y = area.left_top.y-padY
	area.right_bottom.x = area.right_bottom.x+padX
	area.right_bottom.y = area.right_bottom.y+padY
	return area
end

---@param entity LuaEntity
---@param dx number
---@param dy number
---@return BoundingBox
function getMovedBox(entity, dx, dy)
	local base = entity.prototype.collision_box
	return moveBox(base, dx, dy)
end

---@param entity LuaEntity
---@param padX number
---@param padY number
---@return BoundingBox
function getPaddedBox(entity, padX, padY)
	local base = entity.prototype.collision_box
	return moveBox(padBox(base, padX, padY), entity.position.x, entity.position.y)
end

function getBox(entity)
	return getPaddedBox(entity.prototype.collision_box, 0, 0)	
end

---@param box1 BoundingBox
---@param box2 BoundingBox
---@return boolean
function intersects(box1, box2)
	if box1.right_bottom.x < box2.left_top.x then return false end -- box1 is left of box2
    if box1.left_top.x > box2.right_bottom.x then return false end -- box1 is right of box2
    if box1.right_bottom.y < box2.left_top.y then return false end -- box1 is above box2
    if box1.left_top.y > box2.right_bottom.y then return false end -- box1 is below box2
    return true -- boxes overlap
end

---@param entity LuaEntity
---@param r number
---@return BoundingBox
function getRadiusAABB(entity, r)
	return {{entity.position.x-r, entity.position.y-r}, {entity.position.x+r, entity.position.y+r}}
end

---@param box BoundingBox
---@return number
function getBoundingBoxAverageEdgeLength(box)
	local pos1 = box.left_top
	local pos2 = box.right_bottom
	local dx = pos2.x-pos1.x
	local dy = pos2.y-pos1.y
	return (dx+dy)/2
end