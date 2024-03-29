extends Node

class_name HexDirections

var directions : Dictionary = {
	2 : Hex.create_and_set_param(1, 0, -1),
	1 : Hex.create_and_set_param(1, -1, 0), 
	6 : Hex.create_and_set_param(0, -1, 1),
	5 : Hex.create_and_set_param(-1, 0, 1), 
	4 : Hex.create_and_set_param(-1, 1, 0), 
	3 : Hex.create_and_set_param(0, 1, -1)};

func get_direction_int_representation(direction_coord : Hex) -> int:
    if direction_coord.equal_to(directions[1]):
        return 1;
    if direction_coord.equal_to(directions[2]):
        return 2;
    if direction_coord.equal_to(directions[3]):
        return 3;
    if direction_coord.equal_to(directions[4]):
        return 4;
    if direction_coord.equal_to(directions[5]):
        return 5;
    if direction_coord.equal_to(directions[6]):
        return 6;
    else:
        return -1;