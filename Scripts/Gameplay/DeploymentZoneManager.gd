extends Node2D

class_name DeploymentZoneManager

signal delete_deployment_nodes

@onready var deployment_zone = preload("res://Nodes/Deployment_Zone.tscn")

@onready var game_manager:SimpleGameManager = get_parent().get_parent();
@onready var board : Board = get_parent()
@onready var map =  board.map;
@onready var layout =  board.layout;
@onready var game_piece_manager : GamePieceManager = board.get_node('Game Piece Manager')
@onready var player_units = game_piece_manager.player_units
@onready var enemy_units = game_piece_manager.enemy_units
var all_zones : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	game_manager.turn_change.connect(_on_turn_change);

func _on_game_piece_finished_moving(game_piece:GamePiece):
	spawn_all_deployment_zones_for_owner(game_piece.ownership)

func _on_deploy(game_piece_scene : PackedScene, deployment_zone : DeploymentZone):
	var game_piece : GamePiece =  game_piece_scene.instantiate()
	spawn_all_deployment_zones_for_owner(game_piece.ownership)

func _on_turn_change(state : Turn.State):
	spawn_all_deployment_zones_for_owner(state)

func spawn_all_deployment_zones_for_owner(state : Turn.State):
	all_zones.clear()
	delete_deployment_nodes.emit()
	var all_units : Array[GamePiece] = [] 
	if state == Turn.State.ENEMY:
		return;
	all_units.append_array(player_units)
	all_units.append_array(enemy_units)
	for unit in all_units:
		if unit.ownership == state:
			spawn_deployment_zones_at_unit_neigbours(deployment_zone,unit,map) 

func spawn_deployment_zones_at_unit_neigbours(node_scene:PackedScene,game_piece:GamePiece,map : Dictionary):
	var neighbours = game_piece.hex.get_hex_neighbours()
	
	for neighbour in (neighbours as Array[Hex]):
		# Checks if the map has a tile with 
		# the neighbours coords.
		if map.has(str(neighbour)) && !all_zones.has(str(neighbour)):
			if board.is_tile_occupied_at_hex(neighbour):
				var point = HexHelper.hex_to_pixel(layout,neighbour);
				var new_zone : DeploymentZone = node_scene.instantiate()
				
				game_piece.is_moving.connect(new_zone.queue_free)
				
				if not game_piece.is_finished_moving.is_connected(_on_game_piece_finished_moving):
					game_piece.is_finished_moving.connect(_on_game_piece_finished_moving);
				
				new_zone.hex = neighbour;
				new_zone.position = point;
				all_zones[str(neighbour)] = new_zone;
				add_child(all_zones[str(neighbour)]);
