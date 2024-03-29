extends AbilityRange


func get_tiles_in_range(board : Board) ->  Array[Hex]:
    var arr : Array[Hex] = [];
    arr.append(game_piece.hex);
    return arr;