extends AbilityRange

class_name ConeAbilityRange

var cones : Dictionary = {
	1 : [5,3],
	2 : [6,4],
	3 : [1,5],
	4 : [2,6],
	5 : [1,3],
	6 : [2,4],
}



func get_tiles_in_range(board : Board) ->  Array[Hex]:
	var hex_direction = HexDirections.new();
	var arr : Array[Hex] = [];
	var hex_location = game_piece.hex.hex_add(direction);
	arr.append(hex_location)
	for dir in cones[hex_direction.get_direction_int_representation(direction)]:
		arr.append(hex_location.hex_add(hex_direction.directions[dir]))
	return arr;
