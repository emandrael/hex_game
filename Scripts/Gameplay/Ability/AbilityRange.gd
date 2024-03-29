extends Node

class_name AbilityRange

var ability_range : int = 1;
var direction_oriented:
	get:
		return false;
var game_piece : GamePiece;
var direction : Hex;

func get_tiles_in_range(board : Board) ->  Array[Hex]:
	return [];