extends Node2D

class_name SelectionZoneManager

@export var highlighted_hex : Hex;
@export var debug : bool = true;
@export var route_highlighted : Array[Hex] = []

@onready var board : Board = get_parent();
@onready var layout: Layout = board.layout;
@onready var map = board.map;

@onready var action_manager : ActionManager = get_parent().get_node('ActionManager')




func _ready():
	set_selection_zones()
func _draw():
	if highlighted_hex:
		HexHelper.draw_hex(self,layout,highlighted_hex,Color.TRANSPARENT,Color.ORANGE_RED)
func _on_highlight_hex(hex):
	highlighted_hex = hex;
	self.queue_redraw()

func _on_unhighlight_hex(hex):
	highlighted_hex = null;
	self.queue_redraw()

func set_selection_zones():
	var selection_zone = preload("res://Nodes/Selection_Zone.tscn")
	for tile in map.values():
		var point = HexHelper.hex_to_pixel(layout,tile.hex_coordinate);
		var new_selection_zone : SelectionZone = selection_zone.instantiate()
		new_selection_zone.position = point
		new_selection_zone.hex = tile.hex_coordinate
		new_selection_zone.set_debug(debug)
		add_child(new_selection_zone)
