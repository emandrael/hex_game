
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

