---@param entry data.Animation|data.AnimationVariations|data.Sprite
function clearTexture(entry)
	if entry.sheet then clearTexture(entry.sheet) return end
	entry.filename = "__core__/graphics/empty.png"
	entry.width = 1
	entry.height = 1
	entry.shift = nil
end

---@return data.Animation
function createCircuitSprite()
	local ret = {
        filename = "__DragonIndustries__/graphics/signal-connection.png",
        x = 0,
        y = 0,
        width = 61,
        height = 50,
        frame_count = 1,
        shift = {0.140625, 0.140625},
    }
	return ret
end

---@return data.Sprite
function createEmptySprite()
	local ret = {
        filename = "__core__/graphics/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
    }
	return ret
end
--[[
---@param filename string
---@param suffix string
---@return string
local function suffixFilename(filename, suffix)
	local parts = splitString(filename, ".")
	local newname = parts[1] .. suffix
	return newname .. "." .. parts[2]
end

---@param from string
---@param to string
---@param filename string
---@return string
local function genReparentedFilename(from, to, filename)
	local val = literalReplace(filename, "__" .. from .. "__", "__" .. to .. "__")
	return val
end

---@param modname string
---@param itemname string
---@param oldname string
---@param filename string
---@return string
local function genNewFilename(modname, itemname, oldname, filename)
	if string.find(filename, "__base__/graphics/terrain/masks", 1, true) then return filename end
	local val = literalReplace(filename, "__base__", "__" .. modname .. "__")
	return literalReplace(val, oldname, itemname)
end

---@param from string
---@param to string
---@param entry data.Sprite|data.Animation|data.SimpleEntityPrototype|data.Sprite4Way
local function reparentSpritesDynamic(from, to, entry)
	if entry.filename then
		entry.filename = genReparentedFilename(from, to, entry.filename)
	elseif entry.picture and entry.picture.filename then
		entry.picture = 
		{
			filename = genReparentedFilename(from, to, entry.picture.filename)
		}
	end
end

---@param modname string
---@param itemname string
---@param oldname string
---@param entry data.Sprite|data.Animation|data.SimpleEntityPrototype|data.Sprite4Way
local function replaceSpritesInTableDynamic(modname, itemname, oldname, entry)
	if entry.filename then
		entry.filename = genNewFilename(modname, itemname, oldname, entry.filename)
	elseif entry.picture and entry.picture.filename then
		entry.picture = {filename = genNewFilename(modname, itemname, oldname, entry.picture.filename)}
	end
end

---@param entry data.Sprite|data.Animation|data.Sprite4Way
---@param suffix string
local function suffixSpritesInTableDynamic(entry, suffix)
	if not entry.filename then return end
	entry.filename = suffixFilename(entry.filename, suffix)
end

---@param tab data.SpriteSource
---@param new string
local function replaceSpritesInTable(tab, new)
	if tab and tab.filename then tab.filename = new end
end

---@param obj table
---@param new string
function replaceSprites(obj, new)
	if obj.picture then
		replaceSpritesInTable(obj.picture, new)
	end
	if obj.pictures then
		for _,pic in pairs(obj.pictures) do
			replaceSpritesInTable(pic, new)
		end
	end
	if obj.sprites then
		for _,pic in pairs(obj.sprites) do
			replaceSpritesInTable(pic, new)
		end
	end
	if obj.animation then
		if obj.animation.layers then
			for _,lyr in pairs(obj.animation.layers) do
				replaceSpritesInTable(lyr, new)
			end
		else
			replaceSpritesInTable(obj.animation, new)
		end
	end
end

---@param from string
---@param to string
---@param obj {[any]: data.Animation}
---@param key any
local function handleAnimationTable(from, to, obj, key)
	local anim = obj[key]
	--log(from .. " > " .. to .. " in " .. obj.name .. "[" .. key .. "]" .. (anim and "yes" or "no"))
	if not anim then return end
	if anim.layers then
		for _,lyr in pairs(anim.layers) do
			reparentSpritesDynamic(from, to, lyr)
		end
	else
		reparentSpritesDynamic(from, to, anim)
	end
end

---@param from string
---@param to string
---@param obj data.Sprite|data.Animation|data.SimpleEntityPrototype|data.CombinatorPrototype|data.TilePrototype
function reparentSprites(from, to, obj)
	log("Reparenting sprites in " .. obj.name)
	if obj.icon then
		obj.icon = genReparentedFilename(from, to, obj.icon)
	end
	if obj.icons then
		--log(serpent.block(obj.icons))
		for _,ico in pairs(obj.icons) do
			ico.icon = genReparentedFilename(from, to, ico.icon)
		end
	end
	if obj.picture then
		reparentSpritesDynamic(from, to, obj.picture)
	end
	if obj.pictures then
		for _,pic in pairs(obj.pictures) do
			reparentSpritesDynamic(from, to, pic)
		end
	end
	if obj.sprites then
		for _,pic in pairs(obj.sprites) do
			reparentSpritesDynamic(from, to, pic)
		end
	end
	handleAnimationTable(from, to, obj, "animation")
	handleAnimationTable(from, to, obj, "on_animation")
	handleAnimationTable(from, to, obj, "off_animation")
	handleAnimationTable(from, to, obj, "folded_animation")
	handleAnimationTable(from, to, obj, "folding_animation")
	handleAnimationTable(from, to, obj, "preparing_animation")
	handleAnimationTable(from, to, obj, "prepared_animation")
	handleAnimationTable(from, to, obj, "energy_glow_animation")
	if obj.variants then
		for __,cat in pairs(obj.variants) do
			for _,pic in pairs(cat) do
				reparentSpritesDynamic(from, to, pic)
			end
		end
	end
end

---@param modname string
---@param oldname string
---@param obj data.Sprite|data.Animation|data.SimpleEntityPrototype|data.CombinatorPrototype|data.TilePrototype
function replaceSpritesDynamic(modname, oldname, obj)
	if type(obj) ~= "table" then error("Tried to resprite a primitive object!") end
	if not obj.name then error("Cannot resprite a nameless object: " .. serpent.block(obj)) end
	log("Replacing sprites from '" .. oldname .. "' in __" .. modname .. "__/" .. obj.type .. "/" .. obj.name)
	if obj.icon then
		obj.icon = genNewFilename(modname, obj.name, oldname, obj.icon)
	end
	if obj.icons then
		for _,ico in pairs(obj.icons) do
			ico.icon = genNewFilename(modname, obj.name, oldname, ico.icon)
		end
	end
	if obj.picture then
		replaceSpritesInTableDynamic(modname, obj.name, oldname, obj.picture)
	end
	if obj.pictures then
		for _,pic in pairs(obj.pictures) do
			replaceSpritesInTableDynamic(modname, obj.name, oldname, pic)
		end
	end
	if obj.sprites then
		for _,pic in pairs(obj.sprites) do
			replaceSpritesInTableDynamic(modname, obj.name, oldname, pic)
		end
	end
	if obj.animation then
		if obj.animation.layers then
			for _,lyr in pairs(obj.animation.layers) do
				replaceSpritesInTableDynamic(modname, obj.name, oldname, lyr)
			end
		else
			replaceSpritesInTableDynamic(modname, obj.name, oldname, obj.animation)
		end
	end
	if obj.variants then
		for catname,cat in pairs(obj.variants) do
			replaceSpritesInTableDynamic(modname, obj.name, oldname, cat)
		end
	end
end

---@param obj data.Sprite|data.Animation|data.SimpleEntityPrototype|data.CombinatorPrototype|data.TilePrototype
---@param suffix string
function suffixSpritesDynamic(obj, suffix)
	if obj.icon then
		obj.icon = suffixFilename(obj.icon, suffix)
	end
	if obj.icons then
		for _,ico in pairs(obj.icons) do
			ico.icon = suffixFilename(ico.icon, suffix)
		end
	end
	if obj.picture then
		suffixSpritesInTableDynamic(obj.picture, suffix)
	end
	if obj.pictures then
		for _,pic in pairs(obj.pictures) do
			suffixSpritesInTableDynamic(pic, suffix)
		end
	end
	if obj.sprites then
		for _,pic in pairs(obj.sprites) do
			suffixSpritesInTableDynamic(pic, suffix)
		end
	end
	if obj.animation then
		if obj.animation.layers then
			for _,lyr in pairs(obj.animation.layers) do
				suffixSpritesInTableDynamic(lyr, suffix)
			end
		else
			suffixSpritesInTableDynamic(obj.animation, suffix)
		end
	end
end

local function swapObjSpriteField(obj1, obj2, field)
	if obj1[field] then
		local temp = table.deepcopy(obj1[field])
		obj1[field] = table.deepcopy(obj2[field])
		obj2[field] = temp
	end
end

function swapSprites(obj1, obj2)
	swapObjSpriteField(obj1, obj2, "icon")
	swapObjSpriteField(obj1, obj2, "icons")
	swapObjSpriteField(obj1, obj2, "picture")
	swapObjSpriteField(obj1, obj2, "pictures")
	swapObjSpriteField(obj1, obj2, "sprites")
	swapObjSpriteField(obj1, obj2, "animation")
	swapObjSpriteField(obj1, obj2, "on_animation")
	swapObjSpriteField(obj1, obj2, "off_animation")
	swapObjSpriteField(obj1, obj2, "variants")
end
--]]

---@param icon data.IconData
---@param scale number
---@param expectedSize? int32
function rescaleIcon(icon, scale, expectedSize)
	if not expectedSize then expectedSize = 64 end
	if icon.scale then
		icon.scale = icon.scale*scale
	else
		icon.scale = scale*(expectedSize / 2) / (icon.icon_size and icon.icon_size or expectedSize)
	end
end


---@param ret [data.IconData]
---@param object data.RecipePrototype|data.ItemPrototype|data.FluidPrototype|data.PlanetPrototype|data.IconData
function appendIcons(ret, object)
		if type(object) == "IconData" then
			table.insert(ret, object)
		elseif object.icon then
			table.insert(ret, {icon = object.icon, icon_size = object.icon_size and object.icon_size or 64})
		elseif object.icons then
			for _,i in pairs(object.icons) do
				table.insert(ret, i)
			end
		else
			fmterror("%s '%s' has no icons specified!", object.type, object.name)
		end
	end

---@param obj1 data.RecipePrototype|data.ItemPrototype|data.FluidPrototype|data.PlanetPrototype|data.IconData
---@param obj2 data.RecipePrototype|data.ItemPrototype|data.FluidPrototype|data.PlanetPrototype|data.IconData
---@param float? boolean
---@return table
function createABIcon(obj1, obj2, float)
	local ret = {}
	
	appendIcons(ret, obj1)
	
	for idx,ico in ipairs(ret) do
		rescaleIcon(ico, 0.75)
		if float then
			ico.shift={ico.icon_size and -ico.icon_size/8 or -8, ico.icon_size and -ico.icon_size/8 or -8}
			ico.floating = true
		end
		ico.draw_background = true
	end
	local start = #ret

	appendIcons(ret, obj2)

	for idx,ico in ipairs(ret) do
		if idx > start then
			rescaleIcon(ico, 0.75)
			if float then
				ico.shift={ico.icon_size and ico.icon_size/16 or 4, ico.icon_size and ico.icon_size/16 or 4}
				ico.floating = true
			else
				ico.shift={ico.icon_size and ico.icon_size/8 or 8, ico.icon_size and ico.icon_size/8 or 8}
			end
			ico.draw_background = true
		end
	end
	
	return ret
end

---@param object data.RecipePrototype|data.ItemPrototype|data.FluidPrototype|data.PlanetPrototype|data.IconData
---@param backgrounds? [data.IconData]
---@param overlays? [data.IconData]
---@return [data.IconData]
function makeIconArray(object, backgrounds, overlays)
		local ret = {}
		if backgrounds then
			for _,i in pairs(backgrounds) do
				table.insert(ret, i)
			end
		end

		appendIcons(ret, object)
		
		if overlays then
			for _,i in pairs(overlays) do
				table.insert(ret, i)
			end
		end
		return ret
end

---@param items [data.RecipePrototype|data.ItemPrototype|data.FluidPrototype|data.PlanetPrototype|data.IconData]
---@return [data.IconData]
function makeIconArrayForItems(items)
		local ret = {}
		
			for _,o in pairs(items) do
				appendIcons(ret, o)
			end
		return ret
end