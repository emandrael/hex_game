extends Sprite2D

class_name Unit

signal select_unit(unit,hex)
signal travel_from(hex)

var hex:Hex;

@onready var boardmanager:BoardManager = get_tree().root.get_child(0);

# Called when the node enters the scene tree for the first time.
func _ready():
	select_unit.connect(boardmanager._on_sprite_2d_select_unit)
	travel_from.connect(boardmanager._on_travel_from)

func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	if (event is InputEventMouseButton) && event.pressed:
		select_unit.emit(self,hex)
		travel_from.emit(hex)

	if (event is InputEventMouseButton) && !event.pressed:
		pass
