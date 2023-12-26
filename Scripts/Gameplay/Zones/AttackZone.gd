extends Node2D

class_name AttackZone

@export var hex:Hex;

func init(_pos : Vector2,_hex_coords:Hex):
	position = _pos;
	hex = _hex_coords;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func set_debug(_debug : bool):
	var collision_shape : CollisionShape2D = get_node('Area2D/CollisionShape2D')
	match _debug:
		true:
			collision_shape.debug_color.a = 0.3;
		false:
			collision_shape.debug_color.a = 0;
