--require "arrays"
require "util"

 ---@type [string]
ALL_COLORS = {}

 ---@type {string: [string]}
local COLORS_LOOKUP = {}

 ---@type {string: [string]}
local COLORS_PRIMARY = {}

 ---@type {string: [string]}
local COLORS_SECONDARY = {}

 ---@type {string: int32}
RENDER_COLORS = {}

---@param tile LuaTile|data.TilePrototype|string
local function calculateColor(tile)
	if type(tile) == "table" or type(tile) == "userdata" then tile = tile.name end
	local colors = {}
	for part in string.gmatch(tile, "[^%-]+") do		
		local li = COLORS_PRIMARY[part]
		if li and #li > 0 then
			for _,color in pairs(li) do
				table.insert(colors, color)
			end
		end
		
		if #colors == 0 then --only go to secondary if there are no primaries
			li = COLORS_SECONDARY[part]
			if li and #li > 0 then
				for _,color in pairs(li) do
					table.insert(colors, color)
				end
			end	
		end
	end
	COLORS_LOOKUP[tile] = colors
end

---@param tile LuaTile
---@return [string],boolean
function getColorsForTile(tile)
	if not tile.valid then return ALL_COLORS,false end
	if string.find(tile.name, "water") then
		return ALL_COLORS,true --need some way to prevent rainbow water
	end
	
	if not COLORS_LOOKUP[tile.name] then
		calculateColor(tile)
	end
	return table.deepcopy(COLORS_LOOKUP[tile.name]),false
end

---@param color string
---@param render int32
---@param tiles1 [string]
---@param tiles2? [string]
local function addColor(color, render, tiles1, tiles2)
	for _,tile in pairs(tiles1) do
		if COLORS_PRIMARY[tile] == nil then COLORS_PRIMARY[tile] = {} end
		table.insert(COLORS_PRIMARY[tile], color)
	end
	
	if tiles2 then
		for _,tile in pairs(tiles2) do
			if COLORS_SECONDARY[tile] == nil then COLORS_SECONDARY[tile] = {} end
			table.insert(COLORS_SECONDARY[tile], color)
		end
	end
	
	table.insert(ALL_COLORS, color)
	RENDER_COLORS[color] = render
end

---@param tile LuaTile
---@param rand LuaRandomGenerator|fun(int, int): int
---@return string?,boolean
function getRandomColorForTile(tile, rand)
	local colors,water = getColorsForTile(tile)
	if colors == nil or #colors == 0 then return nil,false end
	local sel = colors[rand(1, #colors)]
	if water then
		
	end
	return sel, water
end

addColor("red", 0xff0000, {"red", "dustyrose"})
addColor("orange", 0xFF7F00, {"orange", "brown"}, {"desert", "dirt"})
addColor("yellow", 0xffD800, {"yellow", "tan", "beige", "cream", "olive"}, {"desert", "sand"})
addColor("green", 0x00ff00, {"green"}, {"grass"})
addColor("cyan", 0x00ffff, {"ice", "frozen", "turqoise"})
addColor("argon", 0x4CCCFF, {"blue", "turqoise"})
addColor("blue", 0x0045ff, {"blue"})
addColor("purple", 0xA426FF, {"purple", "mauve", "aubergine"})
addColor("magenta", 0xFF00FF, {"purple", "violet"})
addColor("white", 0xffffff, {"snow", "white", "black", "beige", "grey", "gray"})