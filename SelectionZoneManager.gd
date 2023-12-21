extends Node2D

@on

# Called when the node enters the scene tree for the first time.
func _ready():
	for _tile in map.values():
		var tile : Tile = _tile;
		var point = HexHelper.hex_to_pixel(layout,tile.hex_coordinate);
		var new_selection_zone : SelectionZone = selection_zone.instantiate()
		new_selection_zone.position = point
		new_selection_zone.hex = tile.hex_coordinate
		selection_zones.add_child(new_selection_zone)
		
