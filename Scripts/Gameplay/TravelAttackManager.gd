extends Node2D

class_name TravelAttackZonesManager

signal delete_travel_nodes
signal disable_units_but(Unit)
signal re_enable_units


@onready var board : Board = get_parent()
@onready var map =  board.map;
@onready var layout =  board.layout;

@export var selected_hex : Hex;
@export var selected_game_piece : GamePiece;

@export var debug : bool = true;

func _draw():
	var zone_colour = Color.PALE_GREEN;
	zone_colour.a = 0.4
	var game_piece_steps_left = 0;
	if selected_game_piece:
		game_piece_steps_left = selected_game_piece.total_steps;
	if(selected_hex):
		var neighbours : Array[Hex] = selected_hex.get_hex_neighbours()
		for neighbour in neighbours:
			# Checks if the map has a tile with the neighbours coords.
			if map.has(str(neighbour)):
				if board.is_tile_free_at_hex(neighbour):
					if selected_game_piece.total_steps > 0:
						HexHelper.draw_hex(self,layout,neighbour,Color.TRANSPARENT,zone_colour)
						var snd_neighbours = neighbour.get_hex_neighbours()
						if game_piece_steps_left > 1:
							for snd_neighbour in snd_neighbours:
								if map.has(str(snd_neighbour)) && snd_neighbour.is_not_in(neighbours) && snd_neighbour.not_equal_to(selected_hex):
									if board.is_tile_free_at_hex(snd_neighbour):
										HexHelper.draw_hex(self,layout,snd_neighbour,Color.TRANSPARENT,zone_colour)
				elif (map[str(neighbour)] as Tile).unit.ownership != selected_game_piece.ownership && selected_game_piece.total_attacks >= 1:
					HexHelper.draw_hex(self,layout,neighbour,Color.TRANSPARENT,Color.RED)

func _on_sprite_2d_select_unit(game_piece : GamePiece, hex):
	if(selected_hex):
		if(selected_hex.equal_to(hex)):
			delete_travel_nodes.emit()
			queue_redraw()
			selected_hex = null
			return
	selected_hex = hex;
	selected_game_piece = game_piece;
	disable_units_but.emit(game_piece)
	print("Unit Selected: " + str(game_piece.unit.unit_name))
	queue_redraw();


func _on_unit_selected(piece:GamePiece,hex : Hex):
	var travel_zone = preload("res://Nodes/Travel_Zone.tscn")
	var attack_zone = preload("res://Nodes/Attack_Zone.tscn")
	var units_total_steps = piece.total_steps;
	if !selected_hex:
		return
	delete_travel_nodes.emit()
	
	var all_travel_zones : Dictionary = {}
	var neighbours = selected_hex.get_hex_neighbours()
	
	for neighbour in (neighbours as Array[Hex]):
		# Checks if the map has a tile with 
		# the neighbours coords.
		if map.has(str(neighbour)):
			var point = HexHelper.hex_to_pixel(layout,neighbour);
			if board.is_tile_free_at_hex(neighbour):
				if selected_game_piece.total_steps > 0:
					var new_travel_zone : TravelZone = (travel_zone.instantiate() as TravelZone)
					new_travel_zone.init(point,1,neighbour,[neighbour])
					
					delete_travel_nodes.connect(new_travel_zone.queue_free)
					
					all_travel_zones[new_travel_zone.hex.to_string()] = new_travel_zone;
					
					var snd_neighbours = neighbour.get_hex_neighbours()
					for snd_neighbour in snd_neighbours:
						if units_total_steps > 1 && map.has(str(snd_neighbour)) && snd_neighbour.is_not_in(neighbours) && snd_neighbour.not_equal_to(selected_hex) && board.is_tile_free_at_hex(snd_neighbour):
							var newer_travel_zone : TravelZone = (travel_zone.instantiate() as TravelZone)
							var snd_point = HexHelper.hex_to_pixel(layout,snd_neighbour);
							newer_travel_zone.init(snd_point,2,snd_neighbour,new_travel_zone.route_to_node.duplicate(true))
							newer_travel_zone.route_to_node.append(snd_neighbour)
							
							delete_travel_nodes.connect(newer_travel_zone.queue_free)
							
							all_travel_zones[newer_travel_zone.hex.to_string()] = newer_travel_zone;
			elif (map[str(neighbour)] as Tile).unit.ownership != selected_game_piece.ownership && selected_game_piece.total_attacks >= 1:
				var new_attack_zone : AttackZone = (attack_zone.instantiate() as AttackZone)
				new_attack_zone.init(point,neighbour)
				delete_travel_nodes.connect(new_attack_zone.queue_free)
				all_travel_zones[str(neighbour)] = new_attack_zone;

	for zone in (all_travel_zones.values()):
		zone.set_debug(debug);
		add_child(zone);

func _on_travel_to(hex,travel_cost,route):

	if board.is_tile_not_free_at_hex(hex):
		self.queue_redraw()
		return
	if selected_hex == null || selected_game_piece == null:
		return;
	delete_travel_nodes.emit()
	# If there is a unit at the location of the selected travel, the the unit won't move there.
	
	# Unit that was on the previous hex becomes null.
	(map[str(selected_hex)] as Tile).unit = null;
	# Unit that was on the previous hex becomes null.
	(map[str(hex)] as Tile).unit = selected_game_piece;
	self.queue_redraw()

	selected_game_piece.set_route(route);
	selected_game_piece.move()
	
	selected_hex = null
	selected_game_piece = null
	
	re_enable_units.emit()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
