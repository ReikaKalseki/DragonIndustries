function createTotalResistance()
	local ret = {}
	for name,damage in pairs(data.raw["damage-type"]) do
		table.insert(ret, {type = name, percent = 100})
	end
	return ret
end

function addCategoryResistance(category, type_, reduce, percent)
	if not data.raw[category] then error("No such category '" .. category .. "'!") end
	for k,v in pairs(data.raw[category]) do
		addResistance(category, k, type_, reduce, percent)
	end
end

function addResistance(category, name, type_, reduce, percent)
	if data.raw["damage-type"][type_] == nil then
		log("Adding resistance to '" .. category .. "/" .. name .. "' with damage type '" .. type_ .. "', which does not exist!")
	end
	local obj = data.raw[category][name]
	if obj.resistances == nil then
		obj.resistances = {}
	end
	local resistance = createResistance(type_, reduce, percent)
	for k,v in pairs(obj.resistances) do
		if v.type == type_ then --if resistance to that type already present, overwrite-with-max rather than have two for same type
			v.decrease = math.max(v.decrease and v.decrease or 0, reduce)
			v.percent = math.max(v.percent and v.percent or 0, percent)
			return
		end
	end
	table.insert(data.raw[category][name].resistances, resistance)
end

function createResistance(type_, reduce, percent_)
return
{
        type = type_,
		decrease = reduce,
        percent = percent_
}
end