extends Node2D


var held : bool = false;
var offset : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if held:
		global_position = get_global_mouse_position() - offset;

func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	if (event is InputEventMouseButton) && (event).pressed && event.button_index == MOUSE_BUTTON_LEFT:
		offset = get_global_mouse_position() - global_position;
		held = true;
	if (event is InputEventMouseButton) && (event).is_released() && event.button_index == MOUSE_BUTTON_LEFT:
		held = false;
