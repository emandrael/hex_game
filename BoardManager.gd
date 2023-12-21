extends Node2D
class_name BoardManager

signal delete_travel_nodes
signal disable_units_but(Unit)
signal re_enable_units

@export var test_unit_vector_pos : Vector3;

@export var selected_hex:Hex;
@export var selected_unit : Unit;

@export var highlighted_hex:Hex;

@onready var sprite = preload("res://Nodes/sprite_test.tscn")
@onready var selection_zone = preload("res://Nodes/Selection_Zone.tscn")

@onready var travel_zone = preload("res://Nodes/Travel_Zone.tscn")

@onready var layout = get_node('Layout');
@export var map : Dictionary = {}

@export var player_units : Dictionary = {}
@export var enemy_units : Dictionary = {}
@onready var unitsNode : Node = get_node('Board/Units')

@export var travel_zones: Array[Hex] = []

@onready var travel_zones_node : Node = get_node('Board/Travel Zones')
@onready var selection_zones : Node = get_node('Board/Selection Zones')

func _ready():
#	Creates a Hexagonal Map of Size 4
	var N = 4
	for q in range(-N,N+1):
		var r1 = max(-N, -q - N);
		var r2 = min( N, -q + N);
		for r in range(r1,r2+1):
			var hex = Hex.new(q,r,-q-r)
			map[str(hex)] = Tile.new(hex,null,null) # Stores into a dictionary called
													# map

	for _tile in map.values():
		var tile : Tile = _tile;
		var point = HexHelper.hex_to_pixel(layout,tile.hex_coordinate);
		var new_selection_zone : SelectionZone = selection_zone.instantiate()
		new_selection_zone.position = point
		new_selection_zone.hex = tile.hex_coordinate
		selection_zones.add_child(new_selection_zone)
		
		
		if tile.hex_coordinate.q == test_unit_vector_pos.x  && tile.hex_coordinate.r == test_unit_vector_pos.y && tile.hex_coordinate.s == test_unit_vector_pos.z:
			var unit : Node2D = sprite.instantiate()
			unit.hex = tile.hex_coordinate;
			unit.position = point;
			(map[tile.get_key()] as Tile).unit = unit;
			unitsNode.add_child(unit)
		if tile.hex_coordinate.q == 1  && tile.hex_coordinate.r == -1 && tile.hex_coordinate.s == 0:
			var unit : Node2D = sprite.instantiate()
			unit.hex = tile.hex_coordinate;
			unit.position = point;
			(map[tile.get_key()] as Tile).unit = unit;
			unitsNode.add_child(unit)
		
	
func _draw():
	var layout:Layout = get_node("Layout")
	if highlighted_hex:
		HexHelper.draw_hex(self,layout,highlighted_hex,Color.TRANSPARENT,Color.SKY_BLUE)
	if(selected_hex):
		var neighbours = selected_hex.get_hex_neighbours()
		for neighbour in neighbours:
			# Checks if the map has a tile with the neighbours coords.
			if map.has(neighbour.to_string()):
				HexHelper.draw_hex(self,layout,neighbour,Color.TRANSPARENT,Color.AQUAMARINE)
				var snd_neighbours = neighbour.get_hex_neighbours()
				for snd_neighbour in snd_neighbours:
					if map.has(snd_neighbour.to_string()) && snd_neighbour.is_not_in(neighbours) && snd_neighbour.not_equal_to(selected_hex):
						HexHelper.draw_hex(self,layout,snd_neighbour,Color.TRANSPARENT,Color.RED)
					

func _on_highlight_hex(hex):
	highlighted_hex = hex;
	self.queue_redraw()
func _on_unhighlight_hex(hex):
	highlighted_hex = null;
	self.queue_redraw()

func _on_travel_from(hex : Hex):
	if !selected_hex:
		return
	travel_zones = [];
	delete_travel_nodes.emit()
	print(selected_hex)
	var all_travel_zones : Dictionary = {}
	var neighbours = selected_hex.get_hex_neighbours()
	
	
	for neighbour in neighbours:
		# Checks if the map has a tile with 
		# the neighbours coords.
		if (map.has(neighbour.to_string())):
			var point = HexHelper.hex_to_pixel(layout,neighbour);
			var new_travel_zone : TravelZone = (travel_zone.instantiate() as TravelZone)
			new_travel_zone.init(point,1,neighbour,[neighbour])
			
			delete_travel_nodes.connect(new_travel_zone.queue_free)
			
			all_travel_zones[new_travel_zone.hex.to_string()] = new_travel_zone;

			var snd_neighbours = neighbour.get_hex_neighbours()
			for snd_neighbour in snd_neighbours:
				if map.has(snd_neighbour.to_string()) && snd_neighbour.is_not_in(neighbours) && snd_neighbour.not_equal_to(selected_hex):
					var newer_travel_zone : TravelZone = (travel_zone.instantiate() as TravelZone)
					var snd_point = HexHelper.hex_to_pixel(layout,snd_neighbour);
					travel_zones.append(snd_neighbour)
					newer_travel_zone.init(snd_point,2,snd_neighbour,new_travel_zone.route_to_node.duplicate(true))
					newer_travel_zone.route_to_node.append(snd_neighbour)
					
					delete_travel_nodes.connect(newer_travel_zone.queue_free)
					
					all_travel_zones[newer_travel_zone.hex.to_string()] = newer_travel_zone;

	for zone in all_travel_zones.values():
		travel_zones_node.add_child(zone);

func _on_travel_to(hex,travel_cost,route):
	delete_travel_nodes.emit()
	self.queue_redraw()
	selected_hex = null
	selected_unit.set_route(route);
	selected_unit.move()
	re_enable_units.emit()

func _on_sprite_2d_select_unit(unit, hex):
	if(selected_hex):
		if(selected_hex.equal_to(hex)):
			print('Deselected')
			delete_travel_nodes.emit()
			self.queue_redraw()
			selected_hex = null
			return
	selected_hex = hex;
	selected_unit = unit;
	disable_units_but.emit(unit)
	print("Unit Selected: " + str(unit))
	self.queue_redraw();
	

func _on_sprite_2d_tree_entered():
	print('fff')

func _on_sprite_2d_ready():
	print('dddd')
