function addRecipeProduct(recipe, item, amountnormal, amountexpensive, addIfPresent)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found!")) end
	if recipe.result and not recipe.results then
		recipe.results = {{type = "item", name = recipe.result, amount = recipe.result_count}}
	end
	if recipe.normal and recipe.normal.result and not recipe.normal.results then
		recipe.normal.results = {{type = "item", name = recipe.normal.result, amount = recipe.normal.result_count}}
	end
	if recipe.expensive and recipe.expensive.result and not recipe.expensive.results then
		recipe.expensive.results = {{type = "item", name = recipe.expensive.result, amount = recipe.expensive.result_count}}
	end
	if recipe.results then
		addIngredientToList(recipe.results, item, amountnormal, addIfPresent)
	end
	if recipe.normal and recipe.normal.results then
		addIngredientToList(recipe.normal.results, item, amountnormal, addIfPresent)
	end
	if recipe.expensive and recipe.expensive.results then
		local amt = amountexpensive and amountexpensive or amountnormal
		addIngredientToList(recipe.expensive.results, item, amt, addIfPresent)
	end
	if not recipe.icon and not recipe.icons then -- needs an icon when >1 output
		recipe.icons = {}
		
		local seek = data.raw.item[recipe.name]
		if not seek then seek = data.raw.fluid[recipe.name] end
		if seek then
			table.insert(recipe.icons, {icon = seek.icon, icon_size = seek.icon_size})
		else
			local li = recipe.results
			if not li and recipe.normal then li = recipe.normal.results end
			for _,ing in pairs(li) do
				if not ing.name then error("Found nil-named from: " .. serpent.block(li)) end
				local val = data.raw.item[ing.name]
				if not val then val = data.raw.fluid[ing.name] end
				if not val then error("Product " .. ing.name .. " not indexable?!") end
				table.insert(recipe.icons, {icon = val.icon, icon_size = val.icon_size})
			end
		end
		table.insert(recipe.icons, {icon = "__DragonIndustries__/graphics/multi-recipe.png", icon_size = 32})
	end
end

function turnRecipeIntoConversion(from, to)
	local tgt = data.raw.recipe[to]
	if not tgt then return end
	local rec = createConversionRecipe(from, to, false)
	tgt.ingredients = rec.ingredients
	if tgt.normal then tgt.normal.ingredients = rec.normal.ingredients end
	if tgt.expensive then tgt.expensive.ingredients = rec.expensive.ingredients end
end

function parseIngredient(entry)
	local type = entry.name and entry.name or entry[1]
	local amt = entry.amount and entry.amount or entry[2]
	return {type, amt}
end

function addIngredientToList(list, item, amount, addIfPresent)
	local added = false
	for _,ing in pairs(list) do
		local parse = parseIngredient(ing)
		--log(serpent.block(parse))
		if parse[1] == item then
			if addIfPresent then
				parse[2] = parse[2]+amount
			end
			added = true
			break
		end
	end
	if not added then
		table.insert(list, {type = "item", name = item, amount = amount})
	end
end

function changeIngredientInList(list, item, repl, ratio, skipError)
	for i = 1,#list do
		local ing = parseIngredient(list[i])
		--[[
		if ing[1] then
			log("Pos " .. i .. ": " .. ing[1] .. " x" .. ing[2] .. " for " .. item .. "->" .. repl)
		else
			log("Pos " .. i .. " is invalid!")
		end--]]
		--log("Comparing '" .. ing[1] .. "' and '" .. item .. "': " .. (ing[1] == item and "true" or "false"))
		if ing[1] == item then
			ing[1] = repl
			ing[2] = math.ceil(ing[2]*ratio)
			ing.name = repl
			ing.amount = ing[2]
			list[i] = ing
			return ing.amount
		end
	end
	if skipError then
		--log("No such item '" .. item .. "' in recipe!\n" .. debug.traceback())
		return 0
	else
		error("No such item '" .. item .. "' in recipe!\n" .. debug.traceback())
	end
end

function replaceItemInRecipe(recipe, item, repl, ratio, skipError)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found! " .. debug.traceback())) end
	local def, norm, exp = 0, 0, 0
	if recipe.ingredients then
		def = changeIngredientInList(recipe.ingredients, item, repl, ratio, skipError)
	end
	if recipe.normal and recipe.normal.ingredients then
		norm = changeIngredientInList(recipe.normal.ingredients, item, repl, ratio, skipError)
	end
	if recipe.expensive and recipe.expensive.ingredients then
		exp = changeIngredientInList(recipe.expensive.ingredients, item, repl, ratio, skipError)
	end
	log("Replaced item " .. item .. " with " .. repl .. " in recipe " .. recipe.name .. " with a ratio of " .. ratio .. "x")
	return {def, norm, exp}
end

function removeItemFromRecipe(recipe, item)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found!")) end
	if recipe.ingredients then
		for i,ing in pairs(recipe.ingredients) do
			if ing[1] == item then
				table.remove(recipe.ingredients, i)
				break
			end
		end
	end
	if recipe.normal and recipe.normal.ingredients then
		for i,ing in pairs(recipe.normal.ingredients) do
			if ing[1] == item then
				table.remove(recipe.normal.ingredients, i)
				break
			end
		end
	end
	if recipe.expensive and recipe.expensive.ingredients then
		for i,ing in pairs(recipe.expensive.ingredients) do
			if ing[1] == item then
				table.remove(recipe.expensive.ingredients, i)
				break
			end
		end
	end
end

function addItemToRecipe(recipe, item, amountnormal, amountexpensive, addIfPresent)
	if type(recipe) == "string" then recipe = data.raw.recipe[recipe] end
	if not recipe then error(serpent.block("No such recipe found!")) end
	if recipe.ingredients then
		addIngredientToList(recipe.ingredients, item, amountnormal, addIfPresent)
	end
	if recipe.normal and recipe.normal.ingredients then
		addIngredientToList(recipe.normal.ingredients, item, amountnormal, addIfPresent)
	end
	if recipe.expensive and recipe.expensive.ingredients then
		local amt = amountexpensive and amountexpensive or amountnormal
		addIngredientToList(recipe.expensive.ingredients, item, amt, addIfPresent)
	end
end

function moveRecipe(recipe, from, to)
	local tech = data.raw.technology[from]
	local effects = {}
	for _,effect in pairs(tech.effects) do
		if effect.type == "unlock-recipe" and effect.recipe == recipe then
		
		else
			table.insert(effects, effect)
		end
	end
	tech.effects = effects
	table.insert(data.raw.technology[to].effects, {type = "unlock-recipe", recipe = recipe})
end

--returns nil if none, not {}
local function buildRecipeSurplus(name1, name2, list1, list2)
	local counts = {}
	local ret = nil
	for i = 1,#list1 do
		local ing = parseIngredient(list1[i])
		--log("Parsing input ingredient: " .. (ing[1] and ing[1] or "nil") .. " x " .. (ing[2] and ing[2] or "nil"))
		if #ing > 0 then
			--log(#ing .. " > " .. tostring(ing))
			counts[ing[1]] = (counts[ing[1]] and counts[ing[1]] or 0)+(ing[2] and ing[2] or 1) -- += in case recipe specifies an ingredient multiple times
		else
			log("Found empty entry in recipe " .. name1 .. "!")
		end
	end
	for i = 1,#list2 do
		local ing = parseIngredient(list2[i])
		--log("Parsing output ingredient: " .. (ing[1] and ing[1] or "nil") .. " x " .. (ing[2] and ing[2] or "nil"))
		if #ing > 0 then
			if counts[ing[1]] then
				counts[ing[1]] = counts[ing[1]]-ing[2]
			end
		else
			log("Found empty entry in recipe " .. name2 .. "!")
		end
	end
	for item,amt in pairs(counts) do
		if counts[item] > 0 and data.raw.item[item] then
			if not ret then ret = {} end
			ret[item] = amt
		end
	end
	return ret
end

--Supply nil for list1 to get a plain ingredient list for list2
local function buildRecipeDifference(name1, name2, list1, list2, form, recursion)

	if recursion then
		for i,ing in ipairs(list1) do
			--log(serpent.block(ing))
			if listHasValue(recursion, ing[1]) and data.raw.recipe[ing[1]] then
				log("Recursing " .. ing[1])
				table.remove(list1, i)
				local list = form == "expensive" and data.raw.recipe[ing[1]].expensive.ingredients or ("normal" and data.raw.recipe[ing[1]].normal.ingredients or data.raw.recipe[ing[1]].ingredients)
				for _,e in pairs(buildRecipeDifference("", ing[1], nil, list)) do
					table.insert(list1, e)
					log("Adding " .. e[1])
				end
			end
		end
	end
	
	if not list2 then error(debug.traceback()) end
	
	local counts = {}
	local ret = {}
	if list1 then
		for i = 1,#list1 do
			local ing = parseIngredient(list1[i])
			--log("Parsing input ingredient: " .. (ing[1] and ing[1] or "nil") .. " x " .. (ing[2] and ing[2] or "nil"))
			if #ing > 0 then
				--log(#ing .. " > " .. tostring(ing))
				counts[ing[1]] = (counts[ing[1]] and counts[ing[1]] or 0)+(ing[2] and ing[2] or 1) -- += in case recipe specifies an ingredient multiple times
			else
				log("Found empty entry in recipe " .. name1 .. "!")
			end
		end
	end
	for i = 1,#list2 do
		local ing = parseIngredient(list2[i])
		--log("Parsing output ingredient: " .. (ing[1] and ing[1] or "nil") .. " x " .. (ing[2] and ing[2] or "nil"))
		if #ing > 0 then
			local amt = ing[2]-(counts[ing[1]] and counts[ing[1]] or 0)
			if amt > 0 then
				ret[#ret+1] = {ing[1], amt}
			end
		else
			log("Found empty entry in recipe " .. name2 .. "!")
		end
	end
	return ret
end

local function createRecipeProfile(recipe)
    return
    {
      enabled = recipe.enabled,
      ingredients = table.deepcopy(recipe.ingredients),
      result = recipe.result,
      results = recipe.results and table.deepcopy(recipe.results) or nil,
    }
end

function createConversionRecipe(from, to, register, tech, recursion)
	local rec1 = data.raw.recipe[from]
	local rec2 = data.raw.recipe[to]
	
	if not rec1 then
		error("No such recipe '" .. from .. "'!")
	end
	if not rec2 then
		error("No such recipe '" .. to .. "'!")
	end
	
	rec1 = table.deepcopy(rec1)
	rec2 = table.deepcopy(rec2)
	
	local name = rec1.name .. "-conversion-to-" .. rec2.name
	
	if data.raw.recipe.name then
		error("Conversion recipe already exists: " .. name)
	else
		log("Creating conversion recipe " .. name)
		if recursion then
			log("Recursing ingredients " .. serpent.block(recursion))
		end
	end
	
	local list = nil
	local exp = nil
	local norm = nil
	
	local e_list = nil
	local e_exp = nil
	local e_norm = nil
	
	if rec1.normal and not rec2.normal then --harmonize the recipe styles
		rec2.normal = createRecipeProfile(rec2)
		rec2.expensive = createRecipeProfile(rec2)
	elseif rec2.normal and not rec1.normal then
		rec1.normal = createRecipeProfile(rec1)
		rec1.expensive = createRecipeProfile(rec1)
	end
	
	local prev = rec1.expensive and rec1.expensive.result or rec1.result
	
	if rec1.ingredients and rec2.ingredients then
		list = buildRecipeDifference(from, to, rec1.ingredients, rec2.ingredients, "basic", recursion)
		e_list = buildRecipeSurplus(from, to, rec1.ingredients, rec2.ingredients, "basic", recursion)
	end
	
	if rec1.expensive or rec2.expensive then
		local exp1 = rec1.expensive and rec1.expensive.ingredients or rec1.ingredients
		local exp2 = rec2.expensive and rec2.expensive.ingredients or rec2.ingredients
		exp = buildRecipeDifference(from, to, exp1, exp2, "expensive", recursion)
		e_exp = buildRecipeSurplus(from, to, exp1, exp2, "expensive", recursion)
	end
	
	if rec1.normal or rec2.normal then
		local norm1 = rec1.normal and rec1.normal.ingredients or rec1.ingredients
		local norm2 = rec2.normal and rec2.normal.ingredients or rec2.ingredients
		norm = buildRecipeDifference(from, to, norm1, norm2, "normal", recursion)
		e_norm = buildRecipeSurplus(from, to, norm1, norm2, "normal", recursion)
	end
	
	if list then
		table.insert(list, {prev, rec1.result_count and rec1.result_count or 1})
	end
	if exp then
		table.insert(exp, {prev, rec1.expensive.result_count and rec1.expensive.result_count or 1})
	end
	if norm then
		table.insert(norm, {prev, rec1.normal.result_count and rec1.normal.result_count or 1})
	end
	
	local ret = table.deepcopy(rec2)
	ret.name = name
	ret.ingredients = list
	local main = rec1.result and rec1.result or rec1.normal.result
	local result = rec2.result and rec2.result or rec2.normal.result
	
	if main == nil then
		for _,ing in pairs(rec1.results) do
			if ing.type == "item" then
				main = ing.name
				break
			end
		end
		for _,ing in pairs(rec2.results) do
			if ing.type == "item" then
				result = ing.name
				break
			end
		end
	end
	
	if not main then
		error("Cannot create a conversion recipe from a recipe that has no output!" .. serpent.block(rec1))
	end	
	if not result then
		error("Cannot create a conversion recipe to a recipe that has no output!" .. serpent.block(rec2))
	end
	
	ret.localised_name = {"conversion-recipe.name", {"entity-name." .. main}, {"entity-name." .. result}}
	local orig_icon_src = rec2
	if not (orig_icon_src.icon or orig_icon_src.icons) then
		orig_icon_src = data.raw.item[result]
	end
	if not (orig_icon_src.icon or orig_icon_src.icons) then
		error("Could not find an icon for " .. rec2.name .. ", in either the recipe or its produced item! This item is invalid and would have crashed the game anyways!")
	end
	local ico = orig_icon_src.icon and orig_icon_src.icon or orig_icon_src.icons[1].icon
	local icosz = orig_icon_src.icon_size and orig_icon_src.icon_size or orig_icon_src.icons[1].icon_size
	ret.icons = {{icon = ico, icon_size = icosz}, {icon = "__FTweaks__/graphics/icons/conversion_overlay.png", icon_size = 32}}
	if not ret.icon then
		if data.raw.item[result] then
			ret.icon = data.raw.item[result].icon
		else
			log("Could not create icon for conversion recipe '" .. name .. "'! No such item '" .. result .. "'")
		end
	end
	if e_list then
		ret.results = {{type = "item", name = ret.result, amount = ret.result_count and ret.result_count or 1}}
		for type,count in pairs(e_list) do
			table.insert(ret.results, {type = "item", name = type, amount = count})
		end
		ret.result = nil
		ret.subgroup = data.raw.item[result].subgroup
	end
	if ret.normal then
		ret.normal.ingredients = norm
		if e_norm then
			ret.normal.results = {{type = "item", name = ret.normal.result, amount = ret.normal.result_count and ret.normal.result_count or 1}}
			for type,count in pairs(e_norm) do
				table.insert(ret.normal.results, {type = "item", name = type, amount = count})
			end
			ret.normal.result = nil
			ret.subgroup = data.raw.item[result].subgroup
		end
	end
	if ret.expensive then
		ret.expensive.ingredients = exp
		if e_exp then
			ret.expensive.results = {{type = "item", name = ret.expensive.result, amount = ret.expensive.result_count and ret.expensive.result_count or 1}}
			for type,count in pairs(e_exp) do
				table.insert(ret.expensive.results, {type = "item", name = type, amount = count})
			end
			ret.expensive.result = nil
			ret.subgroup = data.raw.item[result].subgroup
		end
	end
	
	if data.raw.item["basic-circuit-board"] then
		replaceItemInRecipe(ret, "electronic-circuit", "basic-circuit-board", 1, true)
	end
	
	ret.allow_decomposition = false
	ret.allow_as_intermediate = false
	if ret.normal then
		ret.normal.allow_decomposition = false
		ret.normal.allow_as_intermediate = false
	end
	if ret.expensive then
		ret.expensive.allow_decomposition = false
		ret.expensive.allow_as_intermediate = false
	end
	
	if ret.ingredients == nil and (ret.normal == nil or ret.normal.ingredients == nil) then error("Conversion recipe " .. ret.name .. " has no specified ingredients! Source recipes: " .. serpent.block(rec1) .. " , " .. serpent.block(rec2)) end
	if ret.ingredients then
		for _,ing in pairs(ret.ingredients) do
			if ing[2] == 0 then
				error("Conversion recipe " .. ret.name .. " has no 0-count ingredients! Source recipes: " .. serpent.block(rec1) .. " , " .. serpent.block(rec2))
			end
		end
	end
	if ret.normal and ret.normal.ingredients then
		for _,ing in pairs(ret.normal.ingredients) do
			if ing[2] == 0 then
				error("Conversion recipe " .. ret.name .. " has no 0-count ingredients! Source recipes: " .. serpent.block(rec1) .. " , " .. serpent.block(rec2))
			end
		end
	end
	
	if register then
		data:extend({ret})
		
		if tech then
			table.insert(data.raw.technology[tech].effects, {type = "unlock-recipe", recipe = name})
		end
	end
	
	return ret
end