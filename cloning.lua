require "strings"

local function genNewFilename(modname, itemname, oldname, filename)
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

local function replaceSpritesInTableDynamic(modname, itemname, oldname, entry)
	if not entry.filename then return end
	entry.filename = genNewFilename(modname, itemname, oldname, entry.filename)
	if entry.hr_version then
		entry.hr_version.filename = genNewFilename(modname, itemname, oldname, entry.hr_version.filename)
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

function replaceSpritesDynamic(modname, oldname, obj)
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
end

function copyObject(category, name, newname)
    local obj = table.deepcopy(data.raw[category][name])
    obj.name = newname
    if obj.minable then
		obj.minable.result = newname
    end
	if obj.mineable then
		obj.mineable.result = newname
	end
	if obj.place_result then
		obj.place_result = newname
	end
	return obj
end

function createSignalOutput(modname, name)
	local obj = copyObject("constant-combinator", "constant-combinator", name)
	replaceSpritesDynamic(modname, "constant-combinator", obj)
	return obj
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
