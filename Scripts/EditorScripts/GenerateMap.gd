@tool
extends EditorScript

var board_tile = preload("res://Nodes/Board_Tile.tscn")

func generate_map():
	var tiles = get_scene().get_node('Board/Tiles');
	var layout : Layout = get_scene().get_node('Board/Layout');
		
	(get_scene().get_node('Board').map as Dictionary).clear()
	get_scene().get_node('Board').map = BoardHelper.create_hex_map(4);

	print(get_scene().get_node('Board').map)

	for tile in tiles.get_children():
		tile.queue_free();
#
	(layout as Layout).orientation = Layout.set_orientation((layout as Layout).type) 
	
	for _tile in get_scene().get_node('Board').map.values():
		# Draws the board.
		var tile : Tile = _tile;
		# HexHelper.draw_hex(self,layout,tile.hex_coordinate,Color.HOT_PINK,Color.WHITE,5)
		var tile_node = board_tile.instantiate() as Sprite2D;
		tile.board_tile = tile_node
	
		tile.terrain_type = Tile.TerrainType.Plains;
		
		if tile.terrain_type == Tile.TerrainType.Water:
			tile_node.frame = 2
		else:
			tile_node.frame = 0;
		tile_node.position = HexHelper.hex_to_pixel(layout,tile.hex_coordinate)
		# In order to get the ordering right for these tiles in the
		# game, we're doing some ordering with the z index. Making
		# it equal to (-10 + -q coords). That way all the tiles look great when on the screen.
		tile_node.z_index = -10 - tile.hex_coordinate.q;
		tile_node.name = 'Tile ' + str(tile.hex_coordinate) 
		tiles.add_child(tile_node)
		tile_node.set_owner(tiles.get_tree().get_edited_scene_root())

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	generate_map()
