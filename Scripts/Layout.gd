extends Node2D

class_name Layout

@export var type : Orientation.Types;

var orientation : Orientation;

@export var size:Vector2;
@export var origin:Vector2;

func _init():
	orientation = set_orientation(type);

func _ready():
	print(self)

func _to_string():
	var str = "Size: {sz}, Origin: {o}, Orientation: {or}".format({"o":origin,"sz":size,"or":Orientation.Types.find_key(type)})
	return str;

func set_orientation(orientaion:Orientation.Types):
	match orientaion:
		Orientation.Types.FLAT:
			return Orientation.new(3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0),
				2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0,
				0.0);
		Orientation.Types.POINTY:
			return Orientation.new(sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,
				sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0,
				0.5);
