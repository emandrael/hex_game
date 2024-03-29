extends Node2D

class_name GamePiece

enum GamePieceState {
	IDLE,
	MOVING,
	ATTACKING,
	TIRED,
	DEATH,
	FREED,
}

signal unit_selected(unit : GamePiece,hex : Hex)
signal is_moving
signal is_finished_moving(game_piece:GamePieceState);

signal is_battle_started(game_piece:GamePieceState);
signal is_battle_finished(game_piece:GamePieceState);
signal death_animation_finished(game_piece:GamePiece);

signal health_depleted(amount:int,previous:int,new:int);
signal heath_gained(amount:int,previous:int,new:int);

var hex:Hex;
var move_commands : Array[Hex] = [];



@export var total_steps: int = 2;
@export var current_steps : int = total_steps

@export var total_attacks: int = 1;
@export var attack_range : int = 1; 

@export var ownership : Turn.State;
@export var unit : Unit;

@export var curr_health : int;
@export var curr_attack : int;

@export var piece_state : GamePieceState;

@onready var game_manager:GameManager = get_parent().get_parent().get_parent();
@onready var board:Board = get_parent().get_parent();
@onready var travel_zone_manager:UnitManager = board.get_node('UnitManager');
@onready var sprite = get_node("Unit_Sprite")

@onready var health_bubble : Sprite2D = get_node('Health');
@onready var attack_bubble : Sprite2D = get_node('Attack');
@onready var health_label : Label = get_node("Health/Label");
@onready var attack_label : Label = get_node("Attack/Label")
@onready var timer : Timer = get_node('Timer')
@onready var anim_player : AnimationPlayer = get_node('SpriteAnimator');
@onready var buff_debuff_animator : AnimationPlayer = get_node('BuffDebuffAnimator');

func set_health_label(new_health:int):
	health_label.text = str(new_health)

func set_attack_label(new_attack:int):
	attack_label.text = str(new_attack);

func lose_health(amount:int):
	var prev_health = curr_health;
	var new_health = curr_health - amount
	curr_health = new_health;
	set_health_label(curr_health)
	health_depleted.emit(amount,prev_health,new_health);

func gain_health(amount:int):
	var prev_health = curr_health;
	var new_health = curr_health + amount
	curr_health = new_health;
	set_health_label(curr_health)
	heath_gained.emit(amount,prev_health,new_health);


func _process(_delta):
	match piece_state:
		GamePieceState.IDLE:
			anim_player.play('idle')
		
		GamePieceState.MOVING:
			anim_player.play('move')
		
		GamePieceState.TIRED:
			pass
			
		GamePieceState.DEATH:
			# We need to add a new state called freed and assign it as soon as we start
			# the death animation because we will be getting issues otherwise.
			piece_state = GamePieceState.FREED
			anim_player.play('death')
			health_bubble.visible = false;
			attack_bubble.visible = false;
			await anim_player.animation_finished;
			self.queue_free()
			await self.tree_exited;
			death_animation_finished.emit(self);
			is_battle_finished.emit(self)
		
		GamePieceState.FREED:
			pass;
		
		GamePieceState.ATTACKING:
			anim_player.play('attack')
			await anim_player.animation_finished;
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play('idle')
	unit_selected.connect(travel_zone_manager._on_unit_selected)
	travel_zone_manager.disable_units_but.connect(_on_disable_units_but)
	travel_zone_manager.re_enable_units.connect(_on_re_enable_units)
	(game_manager as SimpleGameManager).turn_change.connect(_on_turn_change);
	
	curr_health = self.unit.health;
	set_health_label(curr_health)
	curr_attack = self.unit.attack;
	set_attack_label(curr_attack)

	total_steps = self.unit.movement_range;



func _on_turn_change(turn_state : Turn.State):
	if ownership == turn_state:
		current_steps = total_steps;
		total_attacks = 1;
		piece_state = GamePieceState.IDLE;

func _on_re_enable_units():
	pass;

func _on_disable_units_but(unit):
	pass;

signal do_damage


func attack(defending_game_piece:GamePiece):
	if piece_state == GamePieceState.IDLE && total_attacks >= 1:
		total_attacks -= 1;
		current_steps = 0;
		# Attacking Unit Attacks First
		is_battle_started.emit();
		self.piece_state = GamePieceState.ATTACKING;
		check_hex_dir_then_flip_sprite_from_direction(hex,defending_game_piece.hex);
		timer.start(0.5)
		await timer.timeout;
		await do_damage;
		defending_game_piece.lose_health(self.curr_attack)
		defending_game_piece.buff_debuff_animator.play('hit')
		await anim_player.animation_finished;
		piece_state = GamePieceState.IDLE;
		
		# Attacking Unit Attacks Second
		defending_game_piece.piece_state = GamePieceState.ATTACKING;
		defending_game_piece.check_hex_dir_then_flip_sprite_from_direction(defending_game_piece.hex,hex);
		timer.start(0.5)
		await timer.timeout;
		await defending_game_piece.do_damage;
		self.lose_health(defending_game_piece.curr_attack);
		self.buff_debuff_animator.play('hit')
		await defending_game_piece.anim_player.animation_finished;
		defending_game_piece.piece_state = GamePieceState.IDLE;
		
		if defending_game_piece.curr_health <= 0:
			defending_game_piece.piece_state = GamePieceState.DEATH;
			await defending_game_piece.anim_player.animation_finished;
		if self.curr_health <= 0:
			self.piece_state = GamePieceState.DEATH;
			await anim_player.animation_finished;




func check_hex_dir_then_flip_sprite_from_direction(from:Hex,to:Hex):
	var move_direction : int = HexHelper.get_hex_direction(from,to)
	if move_direction == 1 || move_direction == 2 || move_direction == 6:
		sprite.flip_h = false;
	else:
		sprite.flip_h = true;

func move():
	if piece_state == GamePieceState.IDLE:
		piece_state = GamePieceState.MOVING;
		is_moving.emit()
		var move_steps = move_commands.size()
		current_steps -= move_steps;
		for move in range(move_steps):
			var prev_hex = hex;
			var hex_to_move_to = move_commands.pop_front();
			hex = hex_to_move_to
			check_hex_dir_then_flip_sprite_from_direction(prev_hex,hex_to_move_to)
			var tween = create_tween()
			tween.tween_property(self,'position',HexHelper.hex_to_pixel(board.layout,hex_to_move_to),0.2);
			await tween.finished
		if current_steps == 0:
			piece_state = GamePieceState.TIRED;
		else:
			piece_state = GamePieceState.IDLE;
		is_finished_moving.emit(self)
		print(is_finished_moving.get_connections())
		if total_attacks >= 1:
			piece_state = GamePieceState.IDLE;

func set_route(move_steps : Array[Hex]):
	move_commands = move_steps

func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	# THINK ABOUT HOW TO DECOUPLE THIS FROM THE GAME MANAGER, THIS IS ONLY FOR THE SIMPLE GAME MANAGER
	if (event is InputEventMouseButton) && event.pressed && piece_state == GamePieceState.IDLE && game_manager.current_turn == ownership:
		unit_selected.emit(self,hex)


