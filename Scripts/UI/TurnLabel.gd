extends Label


func _on_end_turn_pressed():
	text = 'e';


func _on_game_manager_turn_change(state : Turn.State):
	match state:
		Turn.State.PLAYER:
			text = 'Player Turn'
		Turn.State.ENEMY:
			text = 'Enemy Turn'
		Turn.State.NEUTRAL:
			text = 'Neutral Turn'

