extends Node2D

class_name MovementManager

@onready var action_manager : ActionManager;

var board : Board;


# Called when the node enters the scene tree for the first time.
func _ready():
	action_manager = get_parent()
	action_manager.ready.connect(func ():
		board = action_manager.board;
	)

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

func _on_travel_to(hex,travel_cost):
	if board.is_tile_not_free_at_hex(hex):
		action_manager.queue_redraw()
		return
	
	if action_manager.selected_hex == null || action_manager.selected_game_piece == null:
		return;

	
	var route = get_hex_path(action_manager.selected_game_piece.hex,hex)
	
	action_manager.delete_travel_attack_nodes.emit()
	# If there is a unit at the location of the selected travel, the the unit won't move there.
	
	# Unit that was on the previous hex becomes null.
	(board.map[str(action_manager.selected_hex)] as Tile).unit = null;
	# Unit that was on the previous hex becomes null.
	(board.map[str(hex)] as Tile).unit = action_manager.selected_game_piece;
	action_manager.queue_redraw()
	
	action_manager.selected_game_piece.set_route(route);
	action_manager.selected_game_piece.move()
	action_manager.selected_hex = null
	action_manager.selected_game_piece = null
	
	action_manager.re_enable_units.emit()
