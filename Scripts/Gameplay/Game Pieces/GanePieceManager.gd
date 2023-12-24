extends Node2D



@export var player_units : Array[GamePiece] = []
@export var enemy_units : Array[GamePiece] = []

var board : Board;
var layout: Layout;
var map : Dictionary;
func _enter_tree():
	board = get_parent();
	map = board.map;
	layout = board.layout;
	print(layout)

func set_game_piece_location(game_piece : GamePiece):
	var point = game_piece.position;
	var frac_hex = HexHelper.pixel_to_hex(board.layout,point);
	var round_hex = HexHelper.hex_round(frac_hex);
	var hex_world_pos = HexHelper.hex_to_pixel(board.layout, round_hex);
	
	game_piece.hex = round_hex;
	game_piece.position = hex_world_pos;
	
	(map[(game_piece.hex.get_key())] as Tile).set_unit_with_hex(game_piece)
	
	match game_piece.ownership:
		Turn.State.ENEMY:
			enemy_units.append(game_piece)
		Turn.State.PLAYER:
			player_units.append(game_piece)

func set_all_game_piece_locations(game_pieces : Array[Node]):
	for game_piece in game_pieces:
		set_game_piece_location(game_piece);

func _ready():
	var children = get_children()
	print((children) is Array[GamePiece])
	set_all_game_piece_locations(children)
	
#	for _tile in map.values():
#		var point = HexHelper.hex_to_pixel(layout,_tile.hex_coordinate);
#		if _tile.hex_coordinate.q == 1  && _tile.hex_coordinate.r == -1 && _tile.hex_coordinate.s == 0:
#			var sprite = preload("res://Nodes/GamePieces/EnemyPiece.tscn")
#			var unit : Node2D = sprite.instantiate()
#			unit.hex = _tile.hex_coordinate;
#			unit.position = point;
#			(map[_tile.get_key()] as Tile).unit = unit;
#			add_child(unit)
#		if _tile.hex_coordinate.q == 1  && _tile.hex_coordinate.r == -2 && _tile.hex_coordinate.s == 1:
#			var sprite = preload("res://Nodes/GamePieces/PlayerPiece.tscn")
#			var unit : Node2D = sprite.instantiate()
#			unit.hex = _tile.hex_coordinate;
#			unit.position = point;
#			(map[_tile.get_key()] as Tile).unit = unit;
#			add_child(unit)
#		if _tile.hex_coordinate.q == -1  && _tile.hex_coordinate.r == 1 && _tile.hex_coordinate.s == 0:
#			var sprite = preload("res://Nodes/GamePieces/PlayerPiece.tscn")
#			var unit : Node2D = sprite.instantiate()
#			unit.hex = _tile.hex_coordinate;
#			unit.position = point;
#			(map[_tile.get_key()] as Tile).unit = unit;
#			add_child(unit)
