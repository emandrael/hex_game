extends Node2D

class_name ActionManager

signal delete_travel_attack_nodes
signal disable_units_but(Unit)
signal re_enable_units

@onready var board : Board = get_parent()
@onready var map =  board.map;
@onready var layout =  board.layout;
@onready var selection_manager : SelectionZoneManager = get_parent().get_node('Selection Manager')

@export var selected_hex : Hex;
@export var selected_game_piece : GamePiece;

@export var debug_travel : bool = true;
@export var debug_attack : bool = true;

@export var selected_unit_potential_routes : Dictionary = {}

func get_selectable_tiles_in_range(starting_hex: Hex, distance_from_tile : int):
	if starting_hex.key not in board.map:
		return
	
	var frontier : Array[Hex] = [];
	frontier.append(starting_hex)
	
	var reached : Dictionary = {};
	
	var came_from : Dictionary = {}
	came_from[starting_hex.key] = null

	while not frontier.is_empty():
		var current_hex : Hex = frontier.pop_at(0)
		
		if current_hex.key not in board.map:
			continue
		
		var neighbours_of_current_hex : Array[Hex] = current_hex.get_hex_neighbours()
		
		for neighbour in neighbours_of_current_hex:
			if neighbour.key not in reached:
				if neighbour.hex_distance_from(starting_hex) > distance_from_tile: # We can use this for set radiuses.
					continue
				if neighbour.key in board.map:
					frontier.append(neighbour)
					reached[neighbour.key] = neighbour
					
	var selectable_tiles_in_range : Array[Hex] = [] 
	for tile in reached.values():
		selectable_tiles_in_range.append(tile as Hex)
	
	return selectable_tiles_in_range

func get_all_potential_move_spaces(start_hex: Hex, game_piece_move_steps : int):
	if start_hex.key not in board.map:
		return
	
	var frontier : DS.PriorityQueue = DS.PriorityQueue.new([],[])
	
	frontier.insert(0,start_hex)
	
	var distances : Dictionary = {}
	distances[start_hex.key] = 0
	
	while not frontier.isEmpty:
		var current: Hex = frontier.remove_root()
		
		if current.key not in board.map:
			continue
		
		var neighbours_of_current_hex : Array[Hex] = current.get_hex_neighbours()
		
		for neighbour in neighbours_of_current_hex:
			if neighbour.key in board.map:
				var movement_cost = 0;
				
				if board.is_tile_not_free_at_hex(neighbour):
					movement_cost += INF;
				else:
					movement_cost += (board.map[neighbour.key] as Tile).terrain_type
				
				var new_movement_cost = distances[current.key] + movement_cost;
				
				if neighbour.key not in distances or new_movement_cost < distances[neighbour.key]:
					
					distances[neighbour.key] = new_movement_cost
					frontier.insert(movement_cost,neighbour)

	return distances
	
func get_hex_path(starting_hex : Hex, goal_hex : Hex):
#	This uses an implementation of the A* to be used in my Hex Game.
	
	if starting_hex.key not in board.map or goal_hex.key not in board.map:
		return
	
#	The frontier is what we use to find all of our routes. By the end of the while loop, it should be empty.
#	We're using an implementation of PriorityQueue.
	var frontier : DS.PriorityQueue = DS.PriorityQueue.new([],[])
	frontier.insert(0,starting_hex)

#	We will be using the came_from dictionary, to eventually get the path of our route.
	var came_from : Dictionary = {}
	came_from[starting_hex.key] = null
	
#	This keeps tracks of the costs of going from route to route.
	var cost_so_far : Dictionary = {}
	cost_so_far[starting_hex.key] = (board.map[starting_hex.key] as Tile).terrain_type

	while not frontier.isEmpty:
		var current : Hex = frontier.remove_root()
		
#		If the current isn't in the board then continue.
		if current.key not in board.map:
			continue
		
		if current == goal_hex:
			break
		
		var neighbours_of_current : Array[Hex] = current.get_hex_neighbours()
		
		for neighbour in neighbours_of_current:
			if neighbour.key in board.map:
				var new_cost = cost_so_far[current.key];
				
				if board.is_tile_not_free_at_hex(neighbour):
					new_cost = INF;
				else:
					new_cost += (board.map[neighbour.key] as Tile).terrain_type
				
				if neighbour.key not in cost_so_far or new_cost < cost_so_far[neighbour.key]:
					cost_so_far[neighbour.key] = new_cost
					var priority = new_cost + goal_hex.hex_distance_from(neighbour)
					frontier.insert(priority,neighbour)
					came_from[neighbour.key] = current
	
	var current = goal_hex;
	var path : Array[Hex] = []
	
	if cost_so_far[goal_hex.key] == INF:
		return path
	
	while current and current != starting_hex: 
		path.append(current)
		current = came_from[current.key]
	path.reverse() # optional
	
	return path

func _draw():
	var zone_colour = Color.PALE_GREEN;
	zone_colour.a = 1;
	var game_piece_steps_left = 0;
	
	if selected_game_piece:
		game_piece_steps_left = selected_game_piece.current_steps;
	
	if(selected_hex):
		var neighbours : Array[Hex] = selected_hex.get_hex_neighbours()
		
		# This draws all of the positions that they Unit can move to.
		var positions_can_reach = get_selectable_tiles_in_range(selected_game_piece.hex,game_piece_steps_left);
		for position in positions_can_reach:
			if position.key in board.map:
				var point = HexHelper.hex_to_pixel(layout,position);
				if board.is_tile_free_at_hex(position) and selected_game_piece.current_steps > 0:
					if position.key in selected_unit_potential_routes:
						var distance_to_position = selected_unit_potential_routes[position.key];

						if distance_to_position <= selected_game_piece.current_steps:
							HexHelper.draw_hex(self,layout,position,Color.TRANSPARENT,zone_colour)
		
		# This draws all of the positions that they Unit can attack.
		var positions_in_attack_reach = get_selectable_tiles_in_range(selected_game_piece.hex, selected_game_piece.attack_range)
		for position in positions_in_attack_reach:
			if board.is_tile_not_free_at_hex(position):
				var is_enemy = board.is_tile_not_free_at_hex(position) and (map[str(position)] as Tile).unit.ownership != selected_game_piece.ownership and selected_game_piece.total_attacks >= 1;
				if is_enemy:
					HexHelper.draw_hex(self,layout,position,Color.TRANSPARENT,Color.RED)

func _on_sprite_2d_select_unit(game_piece : GamePiece, hex):
	if(selected_hex):
		if(selected_hex.equal_to(hex)):
			delete_travel_attack_nodes.emit()
			queue_redraw()
			selected_hex = null
			return
	selected_hex = hex;
	selected_game_piece = game_piece;
	selected_unit_potential_routes = {}
	
	var positions_can_reach = get_selectable_tiles_in_range(selected_game_piece.hex,selected_game_piece.current_steps);
	
	selected_unit_potential_routes = get_all_potential_move_spaces(game_piece.hex,game_piece.current_steps)
	
	disable_units_but.emit(game_piece)

	queue_redraw();


func _on_unit_selected(piece:GamePiece):
	var travel_zone = preload("res://Nodes/Travel_Zone.tscn")
	var attack_zone = preload("res://Nodes/Attack_Zone.tscn")
	var units_total_steps = piece.total_steps;
	if !selected_hex:
		return
	delete_travel_attack_nodes.emit()
	
	var all_travel_zones : Dictionary = {}
	var neighbours = selected_hex.get_hex_neighbours()
	
	var positions_can_reach = get_selectable_tiles_in_range(piece.hex,max(piece.current_steps,piece.attack_range));
	
	for position in positions_can_reach:
		if position.key in board.map:
			var tile_at_pos : Tile = (map[position.key] as Tile)
			var point = HexHelper.hex_to_pixel(layout,position);
			
			if board.is_tile_free_at_hex(position) and selected_game_piece.current_steps > 0:
				if position.key in selected_unit_potential_routes:
					var distance_to_position = selected_unit_potential_routes[position.key];
					if distance_to_position <= selected_game_piece.current_steps:
						var new_travel_zone : TravelZone = (travel_zone.instantiate() as TravelZone)
	#					new_travel_zone.init(point,1,position,route)
						new_travel_zone.init(point,1,position)
						delete_travel_attack_nodes.connect(new_travel_zone.queue_free)
						all_travel_zones[new_travel_zone.hex.to_string()] = new_travel_zone;
						
			elif board.is_tile_not_free_at_hex(position) and tile_at_pos.unit and tile_at_pos.unit.ownership != selected_game_piece.ownership and selected_game_piece.total_attacks >= 1:
				var new_attack_zone : AttackZone = (attack_zone.instantiate() as AttackZone)
				new_attack_zone.init(point,position)
				new_attack_zone.defending_game_piece = (map[position.key] as Tile).unit
				delete_travel_attack_nodes.connect(new_attack_zone.queue_free)
				all_travel_zones[position.key] = new_attack_zone;

	for zone in (all_travel_zones.values()):
		if zone is AttackZone:
			zone.set_debug(debug_attack);
		else:
			zone.set_debug(debug_travel);
		add_child(zone);


@export var able_to_attack : bool = true;

func _on_attack_unit(defending_game_piece:GamePiece):
	delete_travel_attack_nodes.emit()
	self.queue_redraw()
	if not able_to_attack:
		return;
	if selected_game_piece.piece_state == GamePiece.GamePieceState.ATTACKING || defending_game_piece.piece_state == GamePiece.GamePieceState.ATTACKING:
		return;
	if selected_hex == null || selected_game_piece == null || defending_game_piece == null:
		return;
	able_to_attack = false;
	selected_game_piece.attack(defending_game_piece);
	await defending_game_piece.anim_player.animation_finished;
	able_to_attack = true;

	
func _on_travel_to(hex,travel_cost):
	
	if board.is_tile_not_free_at_hex(hex):
		self.queue_redraw()
		return
	
	if selected_hex == null || selected_game_piece == null:
		return;
	
	var route = get_hex_path(selected_game_piece.hex,hex)
	
	delete_travel_attack_nodes.emit()
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
