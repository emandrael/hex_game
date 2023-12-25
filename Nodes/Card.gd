extends Node2D

class_name Card

signal mouse_released
signal deploy(game_piece_scene : PackedScene, deployment_zone : DeploymentZone);
var is_in_draggable_zone : bool;
@export var game_piece_scene : PackedScene;
@export var zone_ref : DeploymentZone;
@onready var game_piece_manager : GamePieceManager = get_parent().get_parent().get_parent().get_node('Game Piece Manager')


var held : bool = false :
	set(b):
		if not b:
			position = Vector2.ZERO;
		held = b;
		Global.is_dragging = b;

var offset : Vector2



# Called when the node enters the scene tree for the first time.
func _ready():
	deploy.connect(game_piece_manager._on_deploy)

func _process(delta):
	if Input.is_action_just_released("M1"):
		mouse_released.emit()
		if is_in_draggable_zone:
			deploy.emit(game_piece_scene,zone_ref)
	if held:
		global_position = get_global_mouse_position() - offset;


func _on_mouse_region_pressed():
	offset = get_global_mouse_position() - global_position;
	held = true;
	await mouse_released
	held = false;


func _on_area_2d_body_entered(body:DeploymentZone):
	if body.is_in_group('deployment_zones'):
		zone_ref = body;
		is_in_draggable_zone = true;


func _on_area_2d_body_exited(body):
	if body.is_in_group('deployment_zones'):
		is_in_draggable_zone = false;
