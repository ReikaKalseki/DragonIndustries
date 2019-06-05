require "arrays"
require "mathhelper"
require "strings"

function getPrereqTechForPack(pack) --this is going to change in 0.17 to a dedicated tech for each
	if pack == "automation-science-pack" then
		return nil
	end
	return data.raw.technology[pack].name
end

function splitTech(tech, prereqs, recipesToMove)
	local base = data.raw.technology[tech]
	local tech2 = table.deepcopy(base)
	local a, b = string.find(tech, "-", 1, true)
	local number = b and tonumber(string.sub(tech, b+1)) or nil
	--error("Number " .. number .. " from " .. tech)
	tech2.name = number and (tech .. "-" .. (number+1)) or (tech .. "-2")
	log("Split " .. tech2.name .. " from " .. tech)
	tech2.prerequisites = prereqs
	table.insert(prereqs, tech)
	tech2.effects = {}
	for _,recipe in pairs(recipesToMove) do
		table.insert(tech2.effects, {type = "unlock-recipe", recipe = recipe})
	end
	--for k,v in pairs(recipesToMove) do log(v) end
	local keep = {}
	for _,effect in pairs(base.effects) do
		--log("Checking if list has " .. effect.recipe)
		if effect.type == "unlock-recipe" and listHasValue(recipesToMove, effect.recipe) then
			
		else
			table.insert(keep, effect)
		end
	end
	base.effects = keep
	data:extend({tech2})
end

function addSciencePackToTech(techname, pack)
	local tech = data.raw.technology[techname]
	if not tech then return end
	local prereq = getPrereqTechForPack(pack)
	if prereq and data.raw.technology[prereq] and not listHasValue(tech.prerequisites, prereq) then
		table.insert(tech.prerequisites, prereq)
	end
	table.insert(tech.unit.ingredients, {pack, 1})
	log("Added science pack " .. pack .. " to tech " .. tech.name)
end

function replaceTechPrereq(tech, old, new)
	if type(tech) == "string" then tech = data.raw.technology[tech] end
	if not tech then error(serpent.block("No such technology found! " .. debug.traceback())) end
	local repl = {}
	local flag = false
	for _,prereq in pairs (tech.prerequisites) do
		if prereq == old then
			table.insert(repl, new)
			flag = true
		else
			table.insert(repl, prereq)
		end
	end
	tech.prerequisites = repl
	log("Replaced prerequisite " .. old .. " with " .. new .. " in tech " .. tech.name)
	return flag
end

function replaceTechPack(tech, old, new, factor)
	local f = factor and factor or 1
	if type(tech) == "string" then tech = data.raw.technology[tech] end
	if not tech then error(serpent.block("No such technology found! " .. debug.traceback())) end
	local repl = {}
	local flag = false
	for _,pack in pairs (tech.unit.ingredients) do
		if pack[1] == old then
			table.insert(repl, {new, math.floor(pack[2]*f)})
			flag = true
		else
			table.insert(repl, pack)
		end
	end
	tech.unit.ingredients = repl
	log("Replaced science pack " .. old .. " with " .. new .. " in tech " .. tech.name)
	return flag
end