extends Node2D


class_name GamePiece

enum GamePieceState {
	IDLE,
	MOVING,
	ATTACKING,
	TIRED,
}

signal select_game_piece(unit,hex)
signal unit_selected(unit,hex)
signal is_moving
signal is_finished_moving(game_piece:GamePieceState);

var hex:Hex;
var move_commands : Array[Hex] = [];

@export var total_steps: int = 2;
@export var total_attacks: int = 1;

@export var ownership : Turn.State;
@export var unit : Unit;
@export var piece_state : GamePieceState;

@onready var game_manager:GameManager = get_parent().get_parent().get_parent();
@onready var board:Board = get_parent().get_parent();
@onready var travel_zone_manager:TravelAttackZonesManager = board.get_node('Travel_Attack Manager');
@onready var sprite = get_node("Sprite2D")


# Called when the node enters the scene tree for the first time.
func _ready():
	select_game_piece.connect(travel_zone_manager._on_sprite_2d_select_unit)
	unit_selected.connect(travel_zone_manager._on_unit_selected)
	travel_zone_manager.disable_units_but.connect(_on_disable_units_but)
	travel_zone_manager.re_enable_units.connect(_on_re_enable_units)
	
	(game_manager as SimpleGameManager).turn_change.connect(_on_turn_change);


func _on_turn_change(turn_state : Turn.State):
	if ownership == turn_state:
		total_steps = 2;
		piece_state = GamePieceState.IDLE;

func _on_re_enable_units():
	pass;

func _on_disable_units_but(unit):
	pass;

func move():
	if piece_state == GamePieceState.IDLE:
		piece_state = GamePieceState.MOVING;
		is_moving.emit()
		var move_steps = move_commands.size()
		total_steps -= move_steps;
		for move in range(move_steps):
			var hex_to_move_to = move_commands.pop_front();
			hex = hex_to_move_to
			var tween = create_tween()
			tween.tween_property(self,'position',HexHelper.hex_to_pixel(board.layout,hex_to_move_to),0.2);
			await tween.finished
			print('Moved to ' + str(hex))
		print('Finished Moving')
		if total_steps == 0:
			piece_state = GamePieceState.TIRED;
		else:
			piece_state = GamePieceState.IDLE;
		is_finished_moving.emit(self)
		if total_attacks >= 1:
			piece_state = GamePieceState.IDLE;

func set_route(move_steps : Array[Hex]):
	move_commands = move_steps

func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	# THINK ABOUT HOW TO DECOUPLE THIS FROM THE GAME MANAGER, THIS IS ONLY FOR THE SIMPLE GAME MANAGER
	if (event is InputEventMouseButton) && event.pressed && piece_state == GamePieceState.IDLE && game_manager.current_turn == ownership:
		select_game_piece.emit(self,hex)
		unit_selected.emit(self,hex)
