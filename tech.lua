require "arrays"
require "mathhelper"
require "strings"

---@param tech string|data.TechnologyPrototype
---@param skipError? boolean
---@return data.TechnologyPrototype
function lookupTech(tech, skipError)
	local ret = nil
	if type(tech) == "string" then
		ret = data.raw.technology[tech]
		if ret == nil and not skipError then fmterror("No such technology found: '%s'", tech) end
	else
		ret = tech
	end
	return ret
end

---@param tech string|data.TechnologyPrototype
---@param dep string|data.TechnologyPrototype
---@param depth? int
---@param path? [string]
---@param root? string
---@return boolean
function techHasDependencyRecursive(tech, dep, depth, path, root)
	tech = lookupTech(tech)
	if type(dep) == "table" then dep = dep.name end
	if not root then root = tech.name end
	if not depth then depth = 0 end
	if not path then path = {} end
	if listHasValue(path, tech.name) then
		fmtlog("Found a tech recursion loop while checking %s for %s, entering %s: %s", root, dep, tech.name, path)
		return true
	end
	table.insert(path, tech.name)
	--if not recurse then log("Checking recursive deps of " .. tech.name .. " for " .. dep .. "; has [" .. serpent.block(tech.prerequisites)) end
	--log("path is " .. serpent.block(path))
	if not tech.prerequisites then return false end
	for _,pre in pairs(tech.prerequisites) do
		--log(depth .. " calls deep; Checking dep " .. pre .. " for " .. tech.name)
		if pre == dep then
			return true
		end
		if techHasDependencyRecursive(data.raw.technology[pre], dep, depth+1, path, root) then
			return true
		end
	end
	table.remove(path)
	return false
end

---@param tech string|data.TechnologyPrototype
---@param pack string
---@return boolean
function techUsesPack(tech, pack)
	tech = lookupTech(tech)
	for _,ing in pairs(tech.unit.ingredients) do
		if ing[1] == pack then
			return true
		end
	end
	return false
end

---@param tech string|data.TechnologyPrototype
---@param recipe string|data.RecipePrototype
function addTechUnlock(tech, recipe)
	tech = lookupTech(tech)
	if type(recipe) == "table" then recipe = recipe.name end
	fmtlog("Adding unlock of recipe '%s' from tech '%s'", recipe, tech.name)
	if not tech.effects then tech.effects = {} end
	
	for _,eff in pairs(tech.effects) do
		if eff.type == "unlock-recipe" and eff.recipe == recipe then return end
	end
	table.insert(tech.effects, {type = "unlock-recipe", recipe = recipe})
end

---@param tech string|data.TechnologyPrototype
---@param recipe string|data.RecipePrototype
function removeTechUnlock(tech, recipe)
	tech = lookupTech(tech)
	if not tech.effects then return end
	for i,eff in ipairs(tech.effects) do
		if eff.type == "unlock-recipe" and eff.recipe == recipe then
			table.remove(tech.effects, i)
			return
		end
	end
end

---@param pack string|data.ToolPrototype
---@return string?
function getPrereqTechForPack(pack)
	if type(pack) == "table" then pack = pack.name end
	local tech = data.raw.technology[pack]
	return tech and tech.name or nil
end

---@param tech string|data.TechnologyPrototype
---@param prereq string|data.TechnologyPrototype
function addPrereqToTech(tech, prereq)
	tech = lookupTech(tech, true)
	if not tech then return end
	if type(prereq) == "table" then prereq = prereq.name end
	if not tech.prerequisites then tech.prerequisites = {} end
	for _,req in pairs(tech.prerequisites) do
		if req == prereq then return end
	end
	table.insert(tech.prerequisites, prereq)
end

---@param tech string|data.TechnologyPrototype
---@param prereqs [string]
---@param recipesToMove [string]
function splitTech(tech, prereqs, recipesToMove)
	local base = lookupTech(tech)
	local tech2 = table.deepcopy(base)
	local move = convertToSet(recipesToMove)
	local a, b = string.find(base.name, "-", 1, true)
	local number = b and tonumber(string.sub(base.name, b+1)) or nil
	--error("Number " .. number .. " from " .. tech)
	tech2.name = number and (base.name .. "-" .. (number+1)) or (base.name .. "-2")
	fmtlog("Split %s from %s", tech2.name, base.name)
	tech2.prerequisites = prereqs
	table.insert(prereqs, tech)
	tech2.effects = {}
	for _,recipe in pairs(recipesToMove) do
		addTechUnlock(tech2, recipe)
	end
	local keep = {}
	for _,effect in pairs(base.effects) do
		if effect.type == "unlock-recipe" and move[effect.recipe] then
			
		else
			table.insert(keep, effect)
		end
	end
	base.effects = keep
	data:extend({tech2})
end

---@param tech string|data.TechnologyPrototype
---@param pack string
function removeSciencePackFromTech(tech, pack)
	tech = lookupTech(tech, true)
	if not tech then return end
	removeEntryFromListIf(tech.unit.ingredients, function(entry) return entry[1] == pack end)
	local prereq = getPrereqTechForPack(pack)
	if prereq then
		removeEntryFromList(tech.prerequisites, prereq)
	end
	fmtlog("Removed science pack %s from tech %s", pack, tech.name)
end

---@param tech string|data.TechnologyPrototype
---@param pack string
---@param prereq? string|data.TechnologyPrototype
function addSciencePackToTech(tech, pack, prereq)
	tech = lookupTech(tech, true)
	if prereq and type(prereq) == "table" then prereq = prereq.name end
	if not tech then return end
	if techUsesPack(tech, pack) then return end
	if not prereq then prereq = getPrereqTechForPack(pack) end
	if prereq then addPrereqToTech(tech, prereq) end
	table.insert(tech.unit.ingredients, {pack, 1})
	fmtlog("Added science pack %s to tech %s", pack, tech.name)
end

---@param tech string|data.TechnologyPrototype
---@param old string
---@param new string
---@return boolean
function replaceTechPrereq(tech, old, new)
	tech = lookupTech(tech)
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
	fmtlog("Replaced prerequisite '%s' with '%s' in tech '%s'", old, new, tech.name)
	return flag
end

---@param tech string|data.TechnologyPrototype
---@param old string
---@param new string
---@param factor? number
---@return boolean
function replaceTechPack(tech, old, new, factor)
	tech = lookupTech(tech)
	if not factor then factor = 1 end
	local repl = {}
	local flag = false
	for _,pack in pairs (tech.unit.ingredients) do
		if pack[1] == old then
			table.insert(repl, {new, math.floor(pack[2]*factor)})
			flag = true
		else
			table.insert(repl, pack)
		end
	end
	tech.unit.ingredients = repl
	fmtlog("Replaced science pack '%s' with '%s' in tech '%s'", old, new, tech.name)
	return flag
end