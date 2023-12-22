extends Node2D

class_name TravelZone

@export var travel_cost : int;  
@export var hex:Hex = Hex.new(1,-1,0);
@export var route_to_node : Array[Hex] = []

signal travel_to(hex:Hex, travel_cost:int, route:Array[Hex])

@onready var travel_zone_manager:TravelZonesManager = get_parent();
# Called when the node enters the scene tree for the first time.
func _ready():
	travel_to.connect(travel_zone_manager._on_travel_to)

func init(_pos : Vector2,_travel_cost:int,_hex_coords:Hex,_route_to_node:Array[Hex]):
	position = _pos;
	travel_cost = _travel_cost;
	hex = _hex_coords;
	route_to_node = _route_to_node;
	
	if _travel_cost == 2:
		(self.get_child(0).get_child(0) as CollisionShape2D).debug_color.a = (self.get_child(0).get_child(0) as CollisionShape2D).debug_color.a/2;

func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	if (event is InputEventMouseButton) && event.pressed:
		travel_to.emit(hex,travel_cost,route_to_node)
