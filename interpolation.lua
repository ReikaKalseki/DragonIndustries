---@class CurvePoint: {[integer]: number}

---@class (exact) Interpolation
---@field values {[string]: number} The curve points
---@field granularity number
---@field minX number
---@field maxX number

---@param curve [CurvePoint]
---@param val number
---@return number
function calcInterpolatedValue(curve, val)
	local idx = 1
	while idx <= #curve and curve[idx][1] < val do
		idx = idx+1
	end
	idx = idx-1
	if val <= curve[1][1] then idx = 1 end
	if not curve[idx] then fmterror("Queried out-of-bounds index %s on curve! \n%s\n", idx, curve) end
	local x1 = curve[idx][1]
	local x2 = curve[idx+1][1]
	local y1 = curve[idx][2]
	local y2 = curve[idx+1][2]
	return y1+(y2-y1)*((val-x1)/(x2-x1))
end

---@param curve [CurvePoint]
---@param step number
---@return Interpolation
function buildLinearInterpolation(curve, step)
	local values = {}
	local minx = curve[1][1]
	local maxx = curve[#curve][1]
	for x = minx,maxx,step do
		local key = string.format('%.04f', x)
		local y = calcInterpolatedValue(curve, x)
		values[key] = y
	end
	
	--respecify limit
	local key = string.format('%.04f', maxx)
	local y = calcInterpolatedValue(curve, maxx)
	values[key] = y
	
	return {values = values, granularity = step, minX = minx, maxX = maxx}
end

---@param curve Interpolation
---@param val number
---@return number
function getInterpolatedValue(curve, val)
	local rnd = math.floor(val/curve.granularity+0.5)*curve.granularity
	if rnd < curve.minX then
		rnd = curve.minX
	end
	if rnd > curve.maxX then
		rnd = curve.maxX
	end
	local key = string.format('%.04f', rnd)
	return curve.values[key]
end