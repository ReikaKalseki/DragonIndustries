
---@param curve [data.UnitSpawnDefinition]
---@param evo number
---@return {[string]: number},number
function getPossibleBiters(curve, evo)
	local ret = {}
	local totalWeight = 0
	for _,entry in pairs(curve) do
		local biter = entry.unit
		local vals = entry.spawn_points -- eg "{0.5, 0.0}, {1.0, 0.4}"
		for idx = 1,#vals do
			local point = vals[idx]
			local ref = point.evolution_factor
			local chance = point.spawn_weight
			if evo >= ref then
				local interp = 0
				if idx == #vals then
					interp = chance
				else
					interp = chance+(vals[idx+1].spawn_weight-chance)*(vals[idx+1].evolution_factor-ref)
				end
				if interp > 0 then
					ret[biter] = interp+totalWeight
					totalWeight = totalWeight+interp
				end
				break
			end
		end
	end
	return ret, totalWeight
end

---@param biters {[string]: number},number
---@param total number
---@return string|nil
function selectWeightedBiter(biters, total)
	local f = math.random()*total
	local ret = nil
	local smallest = 99999999
	for biter,weight in pairs(biters) do
		if f <= weight and smallest > weight then
			smallest = weight
			ret = biter
		end
	end
	--game.print("Selected " .. ret .. " with " .. f .. " / " .. total)
	return ret
end

---@param curve [data.UnitSpawnDefinition]
---@param evo number
---@return string|nil
function getSpawnedBiter(curve, evo)
	--game.print("Real Evo " .. evo)
	if math.random() < 0.5 then
		evo = evo-0.1
	end
	if math.random() < 0.25 then
		evo = evo-0.1
	end
	evo = math.max(evo, 0)
	local biters, total = getPossibleBiters(curve, evo)
	return selectWeightedBiter(biters, total)
end
