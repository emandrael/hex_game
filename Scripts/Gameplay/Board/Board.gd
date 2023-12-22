extends Node2D

class_name Board

var board_tile = preload("res://Nodes/Board_Tile.tscn")

@export var map : Dictionary = {}

@onready var layout : Layout;

func _enter_tree():
	map =  BoardHelper.create_hex_map(4);
	layout = get_node("Layout");

func _ready():
	for _tile in map.values():
			# Draws the board.
			var tile : Tile = _tile;
			# HexHelper.draw_hex(self,layout,tile.hex_coordinate,Color.HOT_PINK,Color.WHITE,5)
			var tile_node = board_tile.instantiate();
			tile_node.position = HexHelper.hex_to_pixel(layout,tile.hex_coordinate)
			# In order to get the ordering right for these tiles in the
			# game, we're doing some ordering with the z index. Making
			# it equal to (-10 + -q coords). That way all the tiles look great when on the screen.
			tile_node.z_index = -10 - tile.hex_coordinate.q;
			tile_node.name = 'Tile - ' + str(tile.hex_coordinate) 
			get_node("Tiles").add_child(tile_node)

func _draw():
	layout = get_node('Layout')
	for _tile in map.values():
		# Draws the board.
		var tile : Tile = _tile;
		# HexHelper.draw_hex(self,layout,tile.hex_coordinate,Color.HOT_PINK,Color.WHITE,5)
		var tile_node = board_tile.instantiate();
		tile_node.position = HexHelper.hex_to_pixel(layout,tile.hex_coordinate)
		# In order to get the ordering right for these tiles in the
		# game, we're doing some ordering with the z index. Making
		# it equal to (-10 + -q coords). That way all the tiles look great when on the screen.
		tile_node.z_index = -10 - tile.hex_coordinate.q;
		tile_node.name = 'Tile - ' + str(tile.hex_coordinate) 
		get_node("Tiles").add_child(tile_node)

func is_tile_occupied_at_hex(hex_coords : Hex) -> bool:
	return (map[str(hex_coords)] as Tile).unit == null;
	
func is_tile_unoccupied_at_hex(hex_coords : Hex) -> bool:
	return (map[str(hex_coords)] as Tile).unit != null;

