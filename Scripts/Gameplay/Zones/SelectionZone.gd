extends Node2D

class_name SelectionZone

signal highlight_hex(hex)
signal unhighlight_hex(hex)

@export var hex:Hex = Hex.new(1,-1,0);

@onready var selection_zone_manager:SelectionZoneManager = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	highlight_hex.connect(selection_zone_manager._on_highlight_hex)
	unhighlight_hex.connect(selection_zone_manager._on_unhighlight_hex)


func _on_area_2d_mouse_entered():
	highlight_hex.emit(hex)

func _on_area_2d_mouse_exited():
	unhighlight_hex.emit(hex)
