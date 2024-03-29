
extends Node2D

class_name Board

var board_tile = preload("res://Nodes/Board_Tile.tscn")


@export var map : Dictionary;

@onready var layout : Layout;


func _enter_tree():
	layout = get_node("Layout");
	

func _draw():
	for _tile in map.values():
		# Draws the board.
		# HexHelper.draw_hex(self,layout,tile.hex_coordinate,Color.HOT_PINK,Color.WHITE,5)
		pass

func free_game_piece_from_tile(game_piece: GamePiece):
#	(map[str(game_piece.hex)] as Tile).unit = null;
	pass

func is_tile_free_at_hex(hex_coords : Hex) -> bool:
	return (map[str(hex_coords)] as Tile).unit == null;
	
func is_tile_not_free_at_hex(hex_coords : Hex) -> bool:
	return (map[str(hex_coords)] as Tile).unit != null;

func get_game_pieces_from_hexes(hexes : Array[Hex]):
	var game_pieces : Array[GamePiece] = []
	for hex in hexes:
		if is_tile_not_free_at_hex(hex):
			game_pieces.append((map[hex.key] as Tile).unit)
	return game_pieces

func get_selectable_tiles_in_range(starting_hex: Hex, distance_from_tile : int):
	if starting_hex.key not in map:
		return
	
	var frontier : Array[Hex] = [];
	frontier.append(starting_hex)

	var reached : Dictionary = {};
	
	var came_from : Dictionary = {}
	came_from[starting_hex.key] = null

	while not frontier.is_empty():
		var current_hex : Hex = frontier.pop_at(0)
		
		if current_hex.key not in map:
			continue
		
		var neighbours_of_current_hex : Array[Hex] = current_hex.get_hex_neighbours()
		
		for neighbour in neighbours_of_current_hex:
			if neighbour.key not in reached:
				if neighbour.hex_distance_from(starting_hex) > distance_from_tile: # We can use this for set radiuses.
					continue
				if neighbour.key in map:
					frontier.append(neighbour)
					reached[neighbour.key] = neighbour
					
	var selectable_tiles_in_range : Array[Hex] = [] 
	for tile in reached.values():
		selectable_tiles_in_range.append(tile as Hex)
	
	return selectable_tiles_in_range