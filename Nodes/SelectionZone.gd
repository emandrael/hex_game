extends Node2D

class_name SelectionZone

signal highlight_hex(hex)
signal unhighlight_hex(hex)

@export var hex:Hex = Hex.new(1,-1,0);

@onready var boardmanager:BoardManager = get_tree().root.get_child(0);
# Called when the node enters the scene tree for the first time.
func _ready():
	highlight_hex.connect(boardmanager._on_highlight_hex)
	unhighlight_hex.connect(boardmanager._on_unhighlight_hex)

func _on_area_2d_mouse_entered():
	highlight_hex.emit(hex)

func _on_area_2d_mouse_exited():
	unhighlight_hex.emit(hex)
