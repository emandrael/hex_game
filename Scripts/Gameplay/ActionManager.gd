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

@onready var movement_manager : MovementManager = get_node('MovementManager')

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


func draw_at_each_position(func_at_position : Callable, positions : Array[Hex]):
	if(selected_hex and selected_game_piece):
		var neighbours : Array[Hex] = selected_hex.get_hex_neighbours()
		
		# This draws all of the positions that they Unit can move to.
		#
		
		for position in positions:
			if position.key in board.map:
				func_at_position.call(position)

func draw_movement_zones():
	var game_piece_steps_left = 0;
	
	if selected_game_piece:
		game_piece_steps_left = selected_game_piece.current_steps;
	else:
		return
	
	var positions_can_reach = get_selectable_tiles_in_range(selected_game_piece.hex,game_piece_steps_left);
	draw_at_each_position(func (position):
		if board.is_tile_free_at_hex(position) and selected_game_piece.current_steps > 0:
			if position.key in selected_unit_potential_routes:
				var distance_to_position = selected_unit_potential_routes[position.key];
				
				if distance_to_position <= selected_game_piece.current_steps:
					HexHelper.draw_hex(self,board.layout,position,Color.TRANSPARENT,Color.GREEN)
		,
		positions_can_reach)


func draw_attack_zones():
	if !selected_game_piece:
		return
	var positions_in_attack_reach = get_selectable_tiles_in_range(selected_game_piece.hex, selected_game_piece.attack_range)
	
	draw_at_each_position(func(position):
		if board.is_tile_not_free_at_hex(position):
			var is_enemy = board.is_tile_not_free_at_hex(position) and (map[str(position)] as Tile).unit.ownership != selected_game_piece.ownership and selected_game_piece.total_attacks >= 1;
			if is_enemy:
				HexHelper.draw_hex(self,layout,position,Color.TRANSPARENT,Color.RED)
	,positions_in_attack_reach
	)

func _draw():	
	draw_movement_zones()
	draw_attack_zones()

func _on_unit_selected(game_piece:GamePiece, hex : Hex):
	var travel_zone = preload("res://Nodes/Travel_Zone.tscn")
	var attack_zone = preload("res://Nodes/Attack_Zone.tscn")
	
	var units_total_steps = game_piece.total_steps;
	
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
	
	selected_unit_potential_routes = movement_manager.get_all_potential_move_spaces(game_piece.hex,game_piece.current_steps)
	
	disable_units_but.emit(game_piece)
	
	queue_redraw();
	
	delete_travel_attack_nodes.emit()
	
	var all_travel_zones : Dictionary = {}
	var neighbours = selected_hex.get_hex_neighbours()
	
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
			add_child(zone);
		else:
			zone.set_debug(debug_travel);
			movement_manager.add_child(zone)
		


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

	

