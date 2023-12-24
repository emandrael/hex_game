extends GameManager
class_name SimpleGameManager

signal turn_change(state : Turn.State)

@export var current_turn : Turn.State;
@export var current_phase : Phase.State;

func _on_end_turn_pressed():
	process_turn(current_turn)

func process_turn(state : Turn.State):
	match state:
		Turn.State.PLAYER:
			current_turn = Turn.State.ENEMY
		Turn.State.ENEMY:
			current_turn = Turn.State.PLAYER
	turn_change.emit(current_turn)
