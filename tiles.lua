require "arrays"

function isWaterTile(tile)
	return tile.valid and hasCollisionMask(tile, "water-tile")
end