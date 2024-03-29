extends Node2D

class_name AttackZone

signal getting_attacked(game_piece:GamePiece)

@export var hex:Hex;
@export var defending_game_piece : GamePiece
@onready var travel_attack_zone_manager : UnitManager = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	getting_attacked.connect(travel_attack_zone_manager._on_attack_unit)
	
func init(_pos : Vector2,_hex_coords:Hex):
	position = _pos;
	hex = _hex_coords;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_debug(_debug : bool):
	var collision_shape : CollisionShape2D = get_node('Area2D/CollisionShape2D')
	collision_shape.visible = _debug;

func _on_area_2d_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton) && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		print('attacked oh no!')
		getting_attacked.emit(defending_game_piece);
