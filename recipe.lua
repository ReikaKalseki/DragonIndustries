require "arrays"
require "items"
require "sprites"
require "mathhelper"
require "tech"

---@param recipe string|data.RecipePrototype
---@param skipError? boolean
---@return data.RecipePrototype
function lookupRecipe(recipe, skipError)
	local ret = nil
	if type(recipe) == "string" then
		ret = data.raw.recipe[recipe]
		if ret == nil and not skipError then fmterror("No such recipe found: '%s'", recipe) end
	else
		ret = recipe
	end
	return ret
end

---@param recipe string|data.RecipePrototype
---@param item string|data.ItemPrototype
function getRecipeCost(recipe, item)
	recipe = lookupRecipe(recipe)
	if type(item) == "table" then item = item.name end
		for _,ing in pairs(recipe.ingredients) do
			if ing.name == item then
				return ing.amount
			end
		end
end

---@param recipe string|data.RecipePrototype
---@return boolean
function recipeStartsEnabled(recipe)
	recipe = lookupRecipe(recipe)
	return recipe.enabled == nil or recipe.enabled == true
end

---@param recipe string|data.RecipePrototype
---@param item string|data.ItemPrototype
---@return boolean
function recipeProduces(recipe, item)
	recipe = lookupRecipe(recipe)
	if type(item) == "table" then item = item.name end
	for _,e in pairs(recipe.results) do
		if e.name == item then return true end
	end
	return false
end

---@param recipe string|data.RecipePrototype
---@param item data.ProductPrototype
---@param addIfPresent? boolean
function addRecipeProduct(recipe, item, addIfPresent)
	recipe = lookupRecipe(recipe)
	addIngredientToList(recipe.results, item, addIfPresent)
	if not recipe.icon and not recipe.icons then -- needs an icon when >1 output
		recipe.icons = makeIconArrayForItems(recipe.results)
		if #recipe.results > 1 then
			table.insert(recipe.icons, {icon = "__DragonIndustries__/graphics/multi-recipe.png", icon_size = 32})
		end
	end
end

---@param from string|data.RecipePrototype
---@param to string|data.RecipePrototype
function turnRecipeIntoConversion(from, to)
	local tgt = lookupRecipe(to)
	if not tgt then return end
	local rec = createConversionRecipe(from, to, false)
	tgt.ingredients = rec.ingredients
end

---@param list [data.IngredientPrototype|data.ProductPrototype]
---@param item data.IngredientPrototype|data.ProductPrototype
---@param addIfPresent? boolean
---@return boolean
function addIngredientToList(list, item, addIfPresent)
	local added = false
	local needsAdd = true
	fmtlog("Inserting recipe item %s/%s x %s", item.type, item.name, item.amount)
	for _,ing in pairs(list) do
		if ing.name == name then
			if addIfPresent then
				ing.amount = ing.amount+item.amount
				added = true
			end
			needsAdd = false
			break
		end
	end
	if needsAdd then
		table.insert(list, item)
		added = true
	end
	return added
end

---@param list [data.IngredientPrototype|data.ProductPrototype]
---@param type string
---@param item string
---@param amount int32
---@param addIfPresent? boolean
---@return boolean
function addIngredientToListSimple(list, type, item, amount, addIfPresent)
	return addIngredientToList(list, {type = type, name = item, amount = amount}, addIfPresent)
end

---@param item string
---@param amount int32
---@param catalyst? boolean
---@param fluid? boolean
---@return data.ItemIngredientPrototype
function buildIngredient(item, amount, catalyst, fluid)
	local put = item
	if fluid == nil then fluid = getItemOrFluidType(item) == "fluid" end
	--[[
	local type = "item"
	if item:find("^fluid::") ~= nil then
		type = "fluid"
		put = string.sub(item, 8)
	elseif item:find("^item::") ~= nil then
		type = "item"
		put = string.sub(item, 7)
	else
		type = data.raw.fluid[item] and "fluid" or "item"
	end
	--]]
	return {type = fluid and "fluid" or "item", name = put, amount = amount, catalyst = catalyst and true or false}
end

---@param name string
---@param amt int32
---@param fallback? string
---@param fallbackamt? int32
---@param catalyst? boolean
---@return data.ItemIngredientPrototype
function buildIngredientWithFallback(name, amt, fallback, fallbackamt, catalyst)
	local seek, fluid = getItemOrFluidByName(name)
	local use = name ---@type string
	if seek then

	elseif fallback then
		use = fallback
		amt = fallbackamt and fallbackamt or amt
		local type = getItemOrFluidType(fallback)
		fluid = type == "fluid"
		fmtlog("Item '%s' not found; switching to fallback '%s' [%s] x%s", name, fallback, type, amt)
	end
	--use = (fluid and "fluid::" or "item::") .. use
	return buildIngredient(use, amt, catalyst, fluid)
end

---@param items {[string]: int32}
---@param catalyst? boolean
---@return data.ItemIngredientPrototype
function buildIngredientWithFallbacks(items, catalyst)
	for item,amt in pairs(items) do
		local seek, fluid = getItemOrFluidByName(item)
		if seek then
			--local name = (fluid and "fluid::" or "item::") .. item
			--return buildIngredient(name, amt, catalyst)
			return buildIngredient(item, amt, catalyst, fluid)
		end
	end
	fmterror("No items were found for the fallback set %s", items)
	return {} --just to make the linter not complain about return
end

---@param list [data.IngredientPrototype|data.ProductPrototype]
---@param item string|data.ItemPrototype
---@param repl string|data.ItemPrototype
---@param ratio number
---@param skipError? boolean
---@return int32
function changeIngredientInList(list, item, repl, ratio, skipError)
	if type(item) == "table" then item = item.name end
	if type(repl) == "table" then repl = repl.name end
	repl = repl --[[@as string]]
	local put = buildIngredient(repl, 1)
	for i = 1,#list do
		local ing = list[i]
		if ing.name == item then
			put.amount = math.ceil(ing.amount*ratio)
			list[i] = put
			--fmtlog("Replaced %s with %s x%s in set %s", item, repl, ratio, list)
			return ing.amount
		end
	end
	if skipError then
		--log("No such item '" .. item .. "' in recipe!\n" .. debug.traceback())
	else
		fmterror("No such item '%s' in recipe!", item)
	end
	return 0
end

---@param list [data.IngredientPrototype|data.ProductPrototype]
---@param item string|data.ItemPrototype
---@param delta int32
---@param skipError? boolean
---@return int32
function changeCountInList(list, item, delta, skipError)
	if type(item) == "table" then item = item.name end
	for i = #list,1,-1 do
		local ing = list[i]
		if ing.name == item then
			ing.amount = ing.amount+delta
			list[i] = ing
			if ing.amount <= 0 then
				table.remove(list, i)
				return 0
			else
				return ing.amount
			end
		end
	end
	if skipError then
		--log("No such item '" .. item .. "' in recipe!\n" .. debug.traceback())
	else
		fmterror("No such item '%s' in recipe!", item)
	end
	return 0
end

---@param recipe string|data.RecipePrototype
---@param item string|data.ItemPrototype
---@param repl string|data.ItemPrototype
---@param ratio? number
---@param skipError? boolean
---@return int32
function replaceItemInRecipe(recipe, item, repl, ratio, skipError)
	if not ratio then ratio = 1 end
	recipe = lookupRecipe(recipe)
	local def = changeIngredientInList(recipe.ingredients, item, repl, ratio, skipError)
	fmtlog("Replaced item %s with %s in recipe %s with a ratio of %sx", item, repl, recipe.name, ratio)
	return def
end

---@param recipe string|data.RecipePrototype
---@param item string|data.ItemPrototype
---@param delta int32
---@param skipError? boolean
---@return int32
function changeItemCountInRecipe(recipe, item, delta, skipError)
	recipe = lookupRecipe(recipe)
	local def = 0
	if recipe.ingredients then
		def = changeCountInList(recipe.ingredients, item, delta, skipError)
	end
	fmtlog("Changed count of item %s + %s in recipe %s", item, delta, recipe.name)
	--log(serpent.block(recipe))
	return def
end

---@param recipe string|data.RecipePrototype
---@param item string|data.ItemPrototype
function removeItemFromRecipe(recipe, item)
	recipe = lookupRecipe(recipe)
	if type(item) == "table" then item = item.name end
	for i = #recipe.ingredients,1,-1 do
		local ing = recipe.ingredients[i]
			if ing.name == item then
				table.remove(recipe.ingredients, i)
				break
			end
		end
end

---@param recipe string|data.RecipePrototype
---@param item string|data.ItemPrototype
---@param amount int32
---@param addIfPresent? boolean
---@param catalyst? boolean
function addItemToRecipe(recipe, item, amount, addIfPresent, catalyst)
	recipe = lookupRecipe(recipe)
	if type(item) == "table" then item = item.name end
	item = item --[[@as string]]
	local add = buildIngredient(item, amount, catalyst)
	fmtlog("Adding '%s' x%s to recipe '%s'", item, amount, recipe.name)
	if recipe.ingredients then
		addIngredientToList(recipe.ingredients, add, addIfPresent)
	end
end

---@param recipe string|data.RecipePrototype
---@param item string|data.ItemPrototype
---@param recipeRef string|data.RecipePrototype
---@param ratio? number
---@param addIfPresent? boolean
function addRecipeIngredientToRecipe(recipe, item, recipeRef, ratio, addIfPresent)
	if not ratio then ratio = 1 end
	local cost = getRecipeCost(recipeRef, item)
	if cost == nil then cost = 0 end
	if cost == 0 then cost = 1 end
	addItemToRecipe(recipe, item, cost*ratio, addIfPresent)
end

---@param recipe string|data.RecipePrototype
---@param from string|data.TechnologyPrototype
---@param to string|data.TechnologyPrototype
function moveRecipe(recipe, from, to)
	if type(recipe) == "table" then recipe = recipe.name end
	local tech = lookupTech(from)
	local tech2 = lookupTech(to)
	local effects = {}
	for _,effect in pairs(tech.effects) do
		if effect.type == "unlock-recipe" and effect.recipe == recipe then
		
		else
			table.insert(effects, effect)
		end
	end
	tech.effects = effects
	addTechUnlock(tech2, recipe)
end

---@param recipe string|data.RecipePrototype
---@param from string|data.TechnologyPrototype
function lockRecipe(recipe, from)
	recipe = lookupRecipe(recipe)
	if not recipe then return end
	recipe.enabled = false
	addTechUnlock(from, recipe)
end

---@param list {[string]: int32}
---@param ingredient data.IngredientPrototype|data.ProductPrototype
local function addToCostTable(list, ingredient)
	list[ingredient.name] = ingredient.amount+(list[ingredient.name] and list[ingredient.name] or 0)
end

---@param list [data.IngredientPrototype|data.ProductPrototype]
---@param recursionSet? {[string]: data.RecipePrototype|string}
---@return {[string]: int32}
local function buildRecipeCostTable(list, recursionSet)
	local ret = {}
	for i,ing in ipairs(list) do
		local recipeRecurse = recursionSet and recursionSet[ing.name] or nil
		if recipeRecurse then
			if recipeRecurse == "*" then recipeRecurse = data.raw.recipe[ing.name] end
			if type(recipeRecurse) == "string" then recipeRecurse = data.raw.recipe[recipeRecurse] end
			for i2,ing2 in ipairs(buildRecipeCostTable(recipeRecurse.ingredients, recursionSet)) do
				addToCostTable(ret, ing2)
			end
		else
			addToCostTable(ret, ing)
		end
	end
	return ret;
end

---@param from string|data.RecipePrototype
---@param to string|data.RecipePrototype
---@param recursionSet? {[string]: data.RecipePrototype|string}
---@param scaleInput? boolean
---@return {[string]: int32}, {[string]: int32}, int32
 --returns {to-from, from-to}, ie the cost to go from 1 to 2, followed by anything costed by 1 but not 2; to-from = to_cost-from_cost+from_output (including the "new" output of from!)
local function buildDifferences(from, to, recursionSet, scaleInput)
	local rec1 = lookupRecipe(from)
	local rec2 = lookupRecipe(to)
	
	local cost1 = buildRecipeCostTable(rec1.ingredients, recursionSet)
	local cost2 = buildRecipeCostTable(rec2.ingredients)
	
	local out1 = buildRecipeCostTable(rec1.results)
	--local out2 = buildRecipeCostTable(rec2.results)

	local n = 1
	if scaleInput then
		n = 9999
		for item,cost in pairs(cost1) do
			n = math.min(n, math.floor(cost2[item]/cost))
			--fmtlog("%s: %s-%s -> %s", item, cost2[item], cost, n)
		end

		if n > 1 then
			for item,cost in pairs(cost1) do	
				cost1[item] = cost1[item]*n
			end
			for item,cost in pairs(out1) do
				out1[item] = out1[item]*n
			end
		end
	end

	for item,cost in pairs(out1) do
		addToCostTable(cost2, buildIngredient(item, cost))
	end

	local diff1 = {}
	local diff2 = {}
	for item,cost in pairs(cost2) do
		local sub = cost1[item]
		if not sub then sub = 0 end
		local net = cost-sub
		if net > 0 then
			diff1[item] = net
		end
	end
	for item,cost in pairs(cost1) do
		sub = cost2[item]
		if not sub then sub = 0 end
		local net = cost-sub
		if net > 0 then
			diff2[item] = net
		end
	end

	--fmterror("Computed %s for %s-%s*%s+%s -> %s", n, rec2.ingredients, n, rec1.ingredients, rec1.results, diff1)
	
	return diff1, diff2, n
end

---@param recipe string|data.RecipePrototype
local function swapRecipeIO(recipe)
	recipe = lookupRecipe(recipe)
	if not recipe then return end
	local temp = table.deepcopy(recipe.ingredients)
	recipe.ingredients = table.deepcopy(recipe.results)
	recipe.results = temp
end

---@param recipe string|data.RecipePrototype
---@param ref data.ItemPrototype
function createUncraftingRecipe(recipe, ref)
	recipe = lookupRecipe(recipe)
	local ret = table.deepcopy(recipe)
	swapRecipeIO(ret)
	ret.name = recipe.name .. "-uncraft"
	ret.icons = {{icon = ref.icon, icon_size = ref.icon_size}, {icon = "__DragonIndustries__/graphics/icons/uncrafting_overlay.png", icon_size = 32}}
	ret.subgroup = ref.subgroup
	ret.allow_decomposition = false
	ret.allow_as_intermediate = false
	ret.allow_intermediates = false
	ret.localised_name = {"uncraft-recipe.name", {"entity-name." .. ref.name}}
	return ret
end

---@param recipe string|data.RecipePrototype
---@return data.LocalisedString
function getRecipeLocale(recipe)
	return recipe.localised_name and recipe.localised_name or {"?", {"recipe-name." .. recipe.name}, {"item-name." .. recipe.results[1].name}, {"entity-name." .. recipe.results[1].name}}
end

---@param from string|data.RecipePrototype
---@param to string|data.RecipePrototype
---@param register? boolean
---@param tech? string|data.TechnologyPrototype
---@param recursionSet? {[string]: data.RecipePrototype|string}
function createConversionRecipe(from, to, register, tech, recursionSet)
	if tech and type(tech) == "table" then tech = tech.name end

	local rec1 = lookupRecipe(from)
	local rec2 = lookupRecipe(to)

	local name = rec1.name .. "-conversion-to-" .. rec2.name
	
	if data.raw.recipe[name] then
		fmterror("Conversion recipe already exists: %s", name)
	else
		fmtlog("Creating conversion recipe '%s'", name)
		if recursionSet then
			fmtlog("(Recursing ingredients: %s)", recursionSet)
		end
	end
	
	local cost, extra, n = buildDifferences(rec1, rec2, recursionSet, true)

	if getTableSize(cost) == 0 then fmterror("Could not compute cost of conversion recipe %s - delta from '%s' to '%s' yielded nothing (%s - %s*%s)", name, rec1.name, rec2.name, rec2.ingredients, n, rec1.ingredients) end
	
	local ret = table.deepcopy(rec2)
	ret.name = name
	ret.ingredients = {}
	for item,amt in pairs(cost) do
		table.insert(ret.ingredients, buildIngredient(item, amt))
	end
	
	if data.raw.item["basic-circuit-board"] then
		replaceItemInRecipe(ret, "electronic-circuit", "basic-circuit-board", 1, true)
	end

	local fromItem = rec1.results[1].name
	local result = ret.results[1].name
	local mainProduct = getItemByName(result)
	local mainFrom = getItemByName(fromItem)
	if not mainFrom then fmterror("Could not determine main input of conversion recipe %s - no item exists by its output name '%s'", name, fromItem) end
	if not mainProduct then fmterror("Could not determine main product of conversion recipe %s - no item exists by its output name '%s'", name, result) end
	mainFrom = mainFrom --[[@as data.ItemPrototype]]
	mainProduct = mainProduct --[[@as data.ItemPrototype]]
	local itemType = mainProduct.type

	if extra then
		for item,amt in pairs(extra) do
			table.insert(ret.results, buildIngredient(item, amt))
		end
	end

	ret.main_product = result
	
	ret.subgroup = data.raw[itemType][result].subgroup --[[@as string]]
	
	--ret.localised_name = {"conversion-recipe.name", {"?", {"recipe-name." .. rec1.name}, {"item-name." .. fromItem}, {"entity-name." .. fromItem}}, {"?", {"recipe-name." .. rec2.name}, {"item-name." .. result}, {"entity-name." .. result}}}
	
	ret.localised_name = {"conversion-recipe.name", getRecipeLocale(rec1), getRecipeLocale(rec2)}
	ret.energy_required = math.max(1, rec2.energy_required-rec1.energy_required*n)

	ret.icons = createABIcon(mainFrom, mainProduct)
	table.insert(ret.icons, {icon = "__DragonIndustries__/graphics/icons/conversion_overlay.png", icon_size = 32, shift = {-2, -2}})
	
	ret.allow_decomposition = false
	ret.allow_as_intermediate = false
	ret.allow_intermediates = false

	fmtlog("Conversion recipe %s created with cost %s (%s - %s*%s)", name, ret.ingredients, rec2.ingredients, n, rec1.ingredients)
	
	if register then
		data:extend({ret})
		
		if tech then
			addTechUnlock(tech, name)
		end
	end
	
	--log(serpent.block(ret))
	
	return ret
end

---@param recipe string|data.RecipePrototype
---@param with string|data.RecipePrototype
---@param main string|data.ItemPrototype
---@param skipError? boolean
function streamlineRecipeOutputWithRecipe(recipe, with, main, skipError)
	recipe = lookupRecipe(recipe)
	local stream = lookupRecipe(with)
	if type(main) == "table" then main = main.name end

	fmtlog("Streamlining '%s' with recipe '%s' for main item '%s'", recipe.name, stream.name, main)

	--NO-OP
end