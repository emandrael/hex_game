extends Node

class_name Tile

var hex_coordinate : Hex;
var unit : Node;
var properties : TileProperties;

func _init(_hex,_unit,_properties):
	hex_coordinate = _hex;
	_unit = unit;
	properties = _properties;

func _to_string():
	return str(hex_coordinate) + " Node: " + str(unit) + " Properties " +  str(properties)

func get_key() -> String:
	return hex_coordinate.to_string()
