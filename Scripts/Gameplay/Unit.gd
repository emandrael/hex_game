extends Sprite2D

class_name Unit


signal select_unit(unit,hex)
signal travel_from(unit,hex)

var hex:Hex;
var move_commands : Array[Hex] = [];


@onready var board:Board = get_parent().get_parent();
@onready var travel_zone_manager:TravelZonesManager = board.get_node('Travel Manager');




var disabled : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	print('E')
	select_unit.connect(travel_zone_manager._on_sprite_2d_select_unit)
	travel_from.connect(travel_zone_manager._on_travel_from)
	
	travel_zone_manager.disable_units_but.connect(_on_disable_units_but)
	travel_zone_manager.re_enable_units.connect(_on_re_enable_units)
	
	print(str(self)+ " : Connections DIS - " +str(travel_zone_manager.disable_units_but.get_connections().size()))
	print(str(self)+ " : Connections RE - " +str(travel_zone_manager.re_enable_units.get_connections().size()))

func _on_re_enable_units():
	disabled = false;

func _on_disable_units_but(unit):
	if unit == self:
		disabled = false;
	else:
		disabled = true;

func move():
	disabled = true;
	var move_steps = move_commands.size()
	for move in range(move_steps):
		var hex_to_move_to = move_commands.pop_front();
		hex = hex_to_move_to
		var tween = create_tween()
		tween.tween_property(self,'position',HexHelper.hex_to_pixel(board.layout,hex_to_move_to),0.2);
		await tween.finished
	disabled = false;
	

	

func set_route(move_steps : Array[Hex]):
	move_commands = move_steps

func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	
	if (event is InputEventMouseButton) && event.pressed && !disabled:
		select_unit.emit(self,hex)
		travel_from.emit(self,hex)
	

	if (event is InputEventMouseButton) && !event.pressed:
		pass
