require "recipe"
require "color"
require "arrays"

local function addRecipe(name, amt, ingredients, byproducts, time)
	local input = {}
	local output = {{type = "fluid", name = name, amount = amt}}
	
	for _,item in pairs(ingredients) do
		local add = tryLoadItem(item[1], item[2])
		if add then
			table.insert(input, add)
		end
	end
	
	log("Adding fluid " .. name .. " with recipe " .. serpent.block(input))
	
	if byproducts ~= nil and time == nil and type(byproducts) == "number" then
		time = byproducts
		byproducts = nil
	end
	
	if byproducts then
		for _,by in pairs(byproducts) do
			local add = tryLoadItem(by[1], by[2])
			if add then
				table.insert(output, add)
			end
		end
	end
	
	local color = data.raw.fluid[name].base_color
	
	local recipe = {
		type = "recipe",
		name = name .. "-" .. getTableSize(data.raw.recipe),
		energy_required = time,
		category = "chemistry",
		icon = data.raw.fluid[name].icon,
		icon_size = data.raw.fluid[name].icon_size,
		subgroup = "fluid-recipes",
		ingredients = input,
		results = output,
		localised_name = {"fluid-name." .. name},
		crafting_machine_tint =
		{
		  primary = color,
		  secondary = color,
		  tertiary = color,
		  quaternary = color,
		}
	}
	data:extend({recipe})
end

local function addFluid(name, color, amt, ingredients, byproducts, time)
	if data.raw.fluid[name] and type(data.raw.fluid[name]) == "table" then
		return
	end
	color = convertColor(color, true)
	local proto = {
		type = "fluid",
		name = name,
		icon = "__DragonIndustries__/graphics/icons/chemicals/" .. name .. ".png",
		icon_size = 32,
		default_temperature = 25,
		max_temperature = 25,
		order = "a[fluid]-a[water]",
		pressure_to_speed_ratio = 0.3,
		flow_to_energy_ratio = 0.59,
		heat_capacity = "500J",
		base_color = color,
		auto_barrel = true,
		flow_color = {r=math.sqrt(color.r), g = math.sqrt(color.g), b=math.sqrt(color.b)}
	}
	data:extend({proto})
	if ingredients then
		addRecipe(name, amt, ingredients, byproducts, time)
	end
end

if data.raw.fluid["hydrogen"] and data.raw.fluid["oxygen"] and data.raw.item["carbon"] then
	addFluid("carbon-dioxide", 0xD8ADAD)
	addFluid("isopropanol", 0xB5E5FF, 20, {{"sulfuric-acid", 2}, {"water", 20}, {"petroleum-gas", 30}}, {{"sulfuric-acid", 2}}, 1)
	addRecipe("isopropanol", 50, {{"sulfuric-acid", 5}, {"water-barrel", 1}, {"petroleum-gas", 75}}, {{"sulfuric-acid", 5}}, 2.5)
	addFluid("acetone", 0xFFB5B5, 20, {{"isopropanol", 20}, {"oxygen", 10}}, {{"water", 20}}, 2)
	addFluid("benzene", 0xB6AFDB9)
	if data.raw.fluid["hydrogen-peroxide"] then
		addRecipe("benzene", 60, {{"petroleum-gas", 20}, {"crude-oil", 30}, {"hydrogen-peroxide", 10}, {"carbon", 1}}, {{"ethanol", 50}}, 4)
		addRecipe("benzene", 300, {{"petroleum-gas", 100}, {"crude-oil-barrel", 3}, {"hydrogen-peroxide", 50}, {"carbon", 5}}, {{"ethanol", 250}}, 20)
	end
	addRecipe("benzene", 60, {{"petroleum-gas", 20}, {"crude-oil", 40}, {"water", 10}, {"carbon", 2}}, {{"ethanol", 80}}, 4)
	addRecipe("benzene", 75, {{"petroleum-gas", 25}, {"crude-oil-barrel", 1}, {"water", 15}, {"carbon", 2}}, {{"ethanol", 90}}, 5)
	data.raw.fluid["acetic-acid"] = "temp"
	addFluid("ethanol", 0x93FF93, 10, {{"acetic-acid", 1}, {"petroleum-gas", 10}, {"water", 10}}, 1)
	addRecipe("ethanol", 50, {{"acetic-acid", 5}, {"petroleum-gas", 50}, {"water-barrel", 1}}, 5)
	addRecipe("ethanol", 20, {{"wood", 4}, {"water", 10}}, {{"carbon-dioxide", 20}}, 60)
	addFluid("acetic-acid", 0xF6FF93, 10, {{"ethanol", 10}, {"oxygen", 10}}, {{"water", 10}}, 1)
end