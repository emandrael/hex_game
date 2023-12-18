extends Node2D

class_name TravelZone

signal travel_to(hex)

@export var hex:Hex = Hex.new(1,-1,0);

@onready var boardmanager:BoardManager = get_tree().root.get_child(0);
# Called when the node enters the scene tree for the first time.
func _ready():
	travel_to.connect(boardmanager._on_travel_to)

func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	if (event is InputEventMouseButton) && event.pressed:
		travel_to.emit(hex)
