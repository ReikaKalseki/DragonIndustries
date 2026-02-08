---@class (exact) Vector
---@field dx number
---@field dy number

---@param position MapPosition
---@param shift int8
---@return MapPosition
function roundToGridBitShift(position, shift)
	position.x = bit32.lshift(bit32.rshift(position.x, shift), shift)
	position.y = bit32.lshift(bit32.rshift(position.y, shift), shift)
	return position
end

---@param p1 MapPosition
---@param p2 MapPosition
---@return number
function getDistance(p1, p2)
	local dx = p1.x-p2.x
	local dy = p1.y-p2.y
	return math.sqrt(dx*dx+dy*dy)
end

---@param e1 LuaEntity
---@param e2 LuaEntity
---@return number
function getEntityDistance(e1, e2)
	return getDistance(e1.position, e2.position)
end

---@param dir defines.direction
---@return Vector
function directionToVector(dir)
	if dir == defines.direction.north then
		return {dx=0, dy=-1}
	elseif dir == defines.direction.south then
		return {dx=0, dy=1}
	elseif dir == defines.direction.east then
		return {dx=1, dy=0}
	elseif dir == defines.direction.west then
		return {dx=-1, dy=0}
	elseif dir == defines.direction.northwest then
		return {dx=-1, dy=-1}
	elseif dir == defines.direction.southwest then
		return {dx=-1, dy=1}
	elseif dir == defines.direction.northeast then
		return {dx=1, dy=-1}
	elseif dir == defines.direction.southeast then
		return {dx=1, dy=1}
	end
end

---@param i number
---@param n number
---@return number
function roundToNearest(i, n)
	local m = n/2
	return i+m-(i+m)%n
end

---@param num number
---@param places int8
---@return number
function roundToPlaces(num, places)
  local mult = 10^(places or 0)
  return math.floor(num * mult + 0.5) / mult
end

---@param dir defines.direction
---@return defines.direction
function getOppositeDirection(dir) --direction is a number from 0 to 15
	return (dir+8)%16
end

---@param dir defines.direction
---@return defines.direction
function getPerpendicularDirection(dir) --direction is a number from 0 to 15
	return (dir+4)%16
end

---@param num number
---@param figures int8
---@return number
function sigFig(num, figures)
    local x = figures - math.ceil(math.log(math.abs(num), 10))
    return (math.floor(num*10^x+0.5)/10^x)
end

---@param x number
---@param xmax number
---@param ymax number
---@return number
function getCosInterpolate(x, xmax, ymax)
	if x >= xmax then
		return ymax
	end
	local func = 0.5-0.5*math.cos(x*math.pi/xmax)
	return func*ymax
end

---@generic T
---@param values {[T]: number}
---@param randFunc function
---@return T
function getCustomWeightedRandom(values, randFunc)
	local sum = 0
	for idx,num in pairs(values) do
		sum = sum+num
	end
	local rand = randFunc and randFunc(0, sum) or math.random(0, sum)
	local val = 0
	for key,num in pairs(values) do
		val = val+num
		if val >= rand then
			return key
		end
	end
	return 0
end

---@generic T
---@param vals [T]
---@param randFunc function
---@return T
function getWeightedRandom(vals, randFunc)
	local sum = 0
	for _,entry in pairs(vals) do
		local weight = entry[1]
		sum = sum+weight
	end
	
	--Copied and Luafied from DragonAPI WeightedRandom
	local f = randFunc and randFunc(0, 100)/100 or math.random()
	local d = f*sum;
	local p = 0
	for _,entry in pairs(vals) do
		p = p + entry[1]
		if d <= p then
			return entry[2]
		end
	end
	return nil
end

---@param a number
---@param b number
---@return number
function cantorCombine(a, b)
	--a = (a+1024)%16384
	--b = b%16384
	local k1 = a*2
	local k2 = b*2
	if a < 0 then
		k1 = a*-2-1
	end
	if b < 0 then
		k2 = b*-2-1
	end
	return 0.5*(k1 + k2)*(k1 + k2 + 1) + k2
end