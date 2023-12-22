extends Node2D

var hexLabel = preload("res://Nodes/HexLabel.tscn")

@onready var board : Board = get_parent()
@onready var layout = board.layout;
@onready var map = board.map;

@export var show_debug_hex_coords : bool = false;

func _draw():
	for tile in map.values():
		var point = HexHelper.hex_to_pixel(layout,tile.hex_coordinate);
		if show_debug_hex_coords:
			var hexLabelInstance = hexLabel.instantiate() 
			hexLabelInstance.text = str(tile.hex_coordinate);
			hexLabelInstance.position = point;
			hexLabelInstance.position.x -= 50;
			hexLabelInstance.position.y -= 10;
			add_child(hexLabelInstance);
