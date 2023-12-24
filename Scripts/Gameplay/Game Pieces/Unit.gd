extends Resource


class_name Unit

enum UnitType {
	CAPTAIN,
	MINION,
	STRUCTURE,
}

@export var unit_name : String;
@export var unit_type : UnitType;
@export var health : int = 25;
@export var attack : int = 2;
