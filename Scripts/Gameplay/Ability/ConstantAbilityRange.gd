extends AbilityRange

class_name ConstantAbilityRange

func get_tiles_in_range(board : Board) ->  Array[Hex]:
    return board.get_selectable_tiles_in_range(game_piece.hex,ability_range);