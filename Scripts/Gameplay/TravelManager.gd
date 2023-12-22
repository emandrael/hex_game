extends Node2D

class_name TravelZonesManager

signal delete_travel_nodes
signal disable_units_but(Unit)
signal re_enable_units


@onready var board : Board = get_parent()
@onready var map =  board.map;
@onready var layout =  board.layout;

@export var selected_hex : Hex;
@export var selected_unit : Unit;

func _draw():
	if(selected_hex):
		var neighbours = selected_hex.get_hex_neighbours()
		for neighbour in neighbours:
			# Checks if the map has a tile with the neighbours coords.
			if map.has(neighbour.to_string()) && board.is_tile_occupied_at_hex(neighbour):
				HexHelper.draw_hex(self,layout,neighbour,Color.TRANSPARENT,Color.AQUAMARINE)
				var snd_neighbours = neighbour.get_hex_neighbours()
				for snd_neighbour in snd_neighbours:
					if map.has(snd_neighbour.to_string()) && board.is_tile_occupied_at_hex(snd_neighbour) && snd_neighbour.is_not_in(neighbours) && snd_neighbour.not_equal_to(selected_hex):
						HexHelper.draw_hex(self,layout,snd_neighbour,Color.TRANSPARENT,Color.RED)
					

func _on_sprite_2d_select_unit(unit, hex):
	if(selected_hex):
		if(selected_hex.equal_to(hex)):
			delete_travel_nodes.emit()
			queue_redraw()
			selected_hex = null
			return
	selected_hex = hex;
	selected_unit = unit;
	disable_units_but.emit(unit)
	print("Unit Selected: " + str(unit))
	queue_redraw();

func _on_travel_from(node:Unit,hex : Hex):
	var travel_zone = preload("res://Nodes/Travel_Zone.tscn")
	if !selected_hex:
		return
	delete_travel_nodes.emit()
	
	var all_travel_zones : Dictionary = {}
	var neighbours = selected_hex.get_hex_neighbours()
	
	
	for neighbour in neighbours:
		# Checks if the map has a tile with 
		# the neighbours coords.

		if map.has(str(neighbour)):
			var tile : Tile = map[str(neighbour)];
			if board.is_tile_occupied_at_hex(neighbour):
				var point = HexHelper.hex_to_pixel(layout,neighbour);
				var new_travel_zone : TravelZone = (travel_zone.instantiate() as TravelZone)
				new_travel_zone.init(point,1,neighbour,[neighbour])
				
				delete_travel_nodes.connect(new_travel_zone.queue_free)
				
				all_travel_zones[new_travel_zone.hex.to_string()] = new_travel_zone;

				var snd_neighbours = neighbour.get_hex_neighbours()
				for snd_neighbour in snd_neighbours:
					if map.has(snd_neighbour.to_string()) && snd_neighbour.is_not_in(neighbours) && snd_neighbour.not_equal_to(selected_hex) && board.is_tile_occupied_at_hex(snd_neighbour):
						var newer_travel_zone : TravelZone = (travel_zone.instantiate() as TravelZone)
						var snd_point = HexHelper.hex_to_pixel(layout,snd_neighbour);
						newer_travel_zone.init(snd_point,2,snd_neighbour,new_travel_zone.route_to_node.duplicate(true))
						newer_travel_zone.route_to_node.append(snd_neighbour)
						
						delete_travel_nodes.connect(newer_travel_zone.queue_free)
						
						all_travel_zones[newer_travel_zone.hex.to_string()] = newer_travel_zone;

	for zone in all_travel_zones.values():
		add_child(zone);

func _on_travel_to(hex,travel_cost,route):
	if selected_hex == null || selected_unit == null:
		return;
	delete_travel_nodes.emit()
	# Unit that was on the previous hex becomes null.
	(map[str(selected_hex)] as Tile).unit = null;
	# Unit that was on the previous hex becomes null.
	(map[str(hex)] as Tile).unit = selected_unit;
	self.queue_redraw()

	selected_unit.set_route(route);
	selected_unit.move()
	
	selected_hex = null
	selected_unit = null
	
	re_enable_units.emit()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
