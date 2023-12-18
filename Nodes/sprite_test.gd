extends Sprite2D

signal select_unit(unit,hex)

var hex:Hex;

@onready var boardmanager:BoardManager = get_tree().root.get_child(0);

# Called when the node enters the scene tree for the first time.
func _ready():
	select_unit.connect(boardmanager._on_sprite_2d_select_unit)
	
func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	if (event is InputEventMouseButton) && event.pressed:
		select_unit.emit(self,hex)

	if (event is InputEventMouseButton) && !event.pressed:
		pass
