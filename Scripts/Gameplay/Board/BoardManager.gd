extends Node2D
class_name BoardManager

@export var test_unit_vector_pos : Vector3;

@onready var layout = get_node('Board/Layout');

@onready var travel_zones_node : Node = get_node('Board/Travel Manager')


@onready var map : Dictionary = get_node("Board").map;

func _on_sprite_2d_tree_entered():
	print('fff')

func _on_sprite_2d_ready():
	print('dddd')
