extends Resource

class_name Tile

enum TerrainType {
	Plains = 1,
	Forest = 5,
	Water = 10,
	Obstacle = int(INF),
}



@export var hex_coordinate : Hex;
var unit : GamePiece;
var board_tile : Node2D;
@export var terrain_type : TerrainType;
@export var properties : TileProperties;

static func create_and_set_param(_hex,_unit,_board_tile,_properties) -> Tile:
	var tile = Tile.new()
	tile.hex_coordinate = _hex;
	tile.unit = _unit;
	tile.properties = _properties;
	tile.board_tile = _board_tile;
	return tile;

func set_unit_with_hex(_unit: GamePiece, _hex : Hex = _unit.hex):
	unit = _unit;
	hex_coordinate = _hex;

func _to_string():
	return str(hex_coordinate) + " Node: " + str(unit) + " Properties " +  str(properties)

func get_key() -> String:
	return hex_coordinate.to_string()
