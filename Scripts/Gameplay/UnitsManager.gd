extends Node2D

@export var player_units : Dictionary = {}
@export var enemy_units : Dictionary = {}

var board : Board;
var layout: Layout;
var map : Dictionary;

func _enter_tree():
	board = get_parent();
	map = board.map;
	layout = board.layout;
	print(layout)

func _ready():
	var sprite = preload("res://Nodes/sprite_test.tscn")
	for tile in map.values():
		var point = HexHelper.hex_to_pixel(layout,tile.hex_coordinate);
		if tile.hex_coordinate.q == 1  && tile.hex_coordinate.r == -1 && tile.hex_coordinate.s == 0:
			var unit : Node2D = sprite.instantiate()
			unit.hex = tile.hex_coordinate;
			unit.position = point;
			(map[tile.get_key()] as Tile).unit = unit;
			add_child(unit)
		if tile.hex_coordinate.q == 1  && tile.hex_coordinate.r == -2 && tile.hex_coordinate.s == 1:
			var unit : Node2D = sprite.instantiate()
			unit.hex = tile.hex_coordinate;
			unit.position = point;
			(map[tile.get_key()] as Tile).unit = unit;
			add_child(unit)
	print()
