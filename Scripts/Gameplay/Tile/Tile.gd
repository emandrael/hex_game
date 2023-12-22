extends Node2D

class_name Tile

@export var hex_coordinate : Hex;
@export var unit : Node;
@export var sprite : Sprite2D;
@export var properties : TileProperties;

func _ready():
	sprite = get_node('Sprite2D')

func _init(_hex,_unit,_properties):
	hex_coordinate = _hex;
	_unit = unit;
	properties = _properties;

func _to_string():
	return str(hex_coordinate) + " Node: " + str(unit) + " Properties " +  str(properties)

func get_key() -> String:
	return hex_coordinate.to_string()
