require "strings"

local function suffixFilename(filename, suffix)
	local parts = splitString(filename, ".")
	local newname = parts[1] .. suffix
	return newname .. "." .. parts[2]
end

local function genReparentedFilename(from, to, filename)
	local val = literalReplace(filename, "__" .. from .. "__", "__" .. to .. "__")
	return val
end

local function genNewFilename(modname, itemname, oldname, filename)
	if string.find(filename, "__base__/graphics/terrain/masks", 1, true) then return filename end
	local val = literalReplace(filename, "__base__", "__" .. modname .. "__")
	return literalReplace(val, oldname, itemname)
end

local function replaceSpritesInTable(tab, new, hr)
	if not tab.filename then return end
	tab.filename = new
	if tab.hr_version then
		tab.hr_version.filename = hr
	end
end

local function reparentSpritesDynamic(from, to, entry)
	if entry.filename then
		entry.filename = genReparentedFilename(from, to, entry.filename)
	elseif entry.picture then
		entry.picture = genReparentedFilename(from, to, entry.picture)
	end
	if entry.hr_version then
		if entry.hr_version.filename then
			entry.hr_version.filename = genReparentedFilename(from, to, entry.hr_version.filename)
		elseif entry.picture then
			entry.hr_version.picture = genReparentedFilename(from, to, entry.hr_version.picture)
		end
	end
end

local function replaceSpritesInTableDynamic(modname, itemname, oldname, entry)
	if entry.filename then
		entry.filename = genNewFilename(modname, itemname, oldname, entry.filename)
	elseif entry.picture then
		entry.picture = genNewFilename(modname, itemname, oldname, entry.picture)
	end
	if entry.hr_version then
		if entry.hr_version.filename then
			entry.hr_version.filename = genNewFilename(modname, itemname, oldname, entry.hr_version.filename)
		elseif entry.picture then
			entry.hr_version.picture = genNewFilename(modname, itemname, oldname, entry.hr_version.picture)
		end
	end
end

local function suffixSpritesInTableDynamic(entry, suffix)
	if not entry.filename then return end
	entry.filename = suffixFilename(entry.filename, suffix)
	if entry.hr_version then
		entry.hr_version.filename = suffixFilename(entry.hr_version.filename, suffix)
	end
end

function replaceSprites(obj, new, hr)
	if obj.picture then
		replaceSpritesInTable(obj.picture, new, hr)
	end
	if obj.pictures then
		for _,pic in pairs(obj.pictures) do
			replaceSpritesInTable(pic, new, hr)
		end
	end
	if obj.sprites then
		for _,pic in pairs(obj.sprites) do
			replaceSpritesInTable(pic, new, hr)
		end
	end
	if obj.animation then
		if obj.animation.layers then
			for _,lyr in pairs(obj.animation.layers) do
				replaceSpritesInTable(lyr, new, hr)
			end
		else
			replaceSpritesInTable(obj.animation, new, hr)
		end
	end
end

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

function reparentSprites(from, to, obj)
	--log("Reparenting sprites in " .. obj.name)
	if obj.icon then
		obj.icon = genReparentedFilename(from, to, obj.icon)
	end
	if obj.icons then
		for _,ico in pairs(obj.icons) do
			ico.filename = genReparentedFilename(from, to, ico.filename)
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
	if obj.variants then
		for __,cat in pairs(obj.variants) do
			for _,pic in pairs(cat) do
				reparentSpritesDynamic(from, to, pic)
			end
		end
	end
end

function replaceSpritesDynamic(modname, oldname, obj)
	if type(obj) ~= "table" then error("Tried to resprite a primitive object!") end
	if not obj.name then error("Cannot resprite a nameless object: " .. serpent.block(obj)) end
	log("Replacing sprites from '" .. oldname .. "' in __" .. modname .. "__/" .. obj.type .. "/" .. obj.name)
	if obj.icon then
		obj.icon = genNewFilename(modname, obj.name, oldname, obj.icon)
	end
	if obj.icons then
		for _,ico in pairs(obj.icons) do
			ico.filename = genNewFilename(modname, obj.name, oldname, ico.filename)
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

function suffixSpritesDynamic(obj, suffix)
	if obj.icon then
		obj.icon = suffixFilename(obj.icon, suffix)
	end
	if obj.icons then
		for _,ico in pairs(obj.icons) do
			ico.filename = suffixFilename(ico.filename, suffix)
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

function copyObject(category, name, newname)
	log("Cloning object '" .. category .. "/" .. name .. "' into '" .. newname .. "'...")
	local base = data.raw[category][name]
	if not base then error("Object data.raw[" .. category .. "][" .. name .. "] does not exist!") end
    local obj = table.deepcopy(base)
    if obj.minable then
		obj.minable.result = newname
    end
	if obj.mineable then
		obj.mineable.result = newname
	end
	if obj.place_result then
		obj.place_result = newname
	end
	if obj.result then
		obj.result = newname
	end
	if obj.order then
		obj.order = literalReplace(obj.order, "[" .. obj.name .. "]", "[" .. newname .. "]")
	end
    obj.name = newname
	return obj
end

function createSignalOutput(modname, name, signalname)
	local obj = copyObject("constant-combinator", "constant-combinator", name)
	replaceSpritesDynamic(modname, "constant-combinator", obj)
	local item = copyObject("item", "constant-combinator", name)
	replaceSpritesDynamic(modname, "constant-combinator", item)
	local signal = copyObject("virtual-signal", "signal-everything", signalname)
	signal.icon = "__" .. modname .. "__/graphics/icons/" .. signalname .. ".png"
	return {entity = obj, item = item, signal = signal}
end

local function createCircuitSprite()
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

local function createCircuitActivitySprite()
	local ret = {
        filename = "__core__/graphics/empty.png",
        width = 1,
        height = 1,
        frame_count = 1,
        shift = {-0.296875, -0.078125},
    }
	return ret
end

local function createCircuitConnections()
	local ret = {
        shadow = {
          red = {0.375, 0.5625},
          green = {-0.125, 0.5625}
        },
        wire = {
          red = {0.375, 0.15625},
          green = {-0.125, 0.15625}
        }
    }
	return ret
end

function createFixedSignalAnchor(name)
	local obj = copyObject("constant-combinator", "constant-combinator", name)
	
	obj.sprites = {
      north = createCircuitSprite(),
      west = createCircuitSprite(),
      east = createCircuitSprite(),
      south = createCircuitSprite(),
    }

    obj.activity_led_sprites = {
	  north = createCircuitActivitySprite(),
      west = createCircuitActivitySprite(),
      east = createCircuitActivitySprite(),
      south = createCircuitActivitySprite(),
    }
	
	obj.circuit_wire_connection_points = {
      createCircuitConnections(),
      createCircuitConnections(),
      createCircuitConnections(),
      createCircuitConnections(),
    }
	
	--obj.selectable_in_game = false
	obj.destructible = false
	obj.collision_box = nil
	obj.max_health = 100
	obj.collision_mask = nil
	obj.minable = nil
	obj.order = "z"
	obj.flags = {"placeable-neutral", "player-creation", "not-on-map", "placeable-off-grid", "not-blueprintable", "not-deconstructable"}
	
	return obj
end
