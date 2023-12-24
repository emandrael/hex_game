extends Node

class_name BoardHelper

static func create_hex_map(size:int) -> Dictionary:
	var map : Dictionary = {}
	var N = size;
	for q in range(-N,N+1):
		var r1 = max(-N, -q - N);
		var r2 = min( N, -q + N);
		for r in range(r1,r2+1):
			var hex = Hex.create_and_set_param(q,r,-q-r);
			var tile = Tile.create_and_set_param(hex,null,null,null);
			tile.resource_name = str(hex);
			map[str(hex)] = tile 	# Stores into a dictionary called
			print(map[str(hex)])
	return map;

static func create_hex_array(size:int) -> Array[Array]:
	var map :  Array[Array] = [];
	for q in range(0,size-1):
		map.append([])
		for r  in range(0,size-1):
			map[q].append(null)
	var N = size;
	for q in range(-N,N+1):
		var r1 = max(-N, -q - N);
		var r2 = min( N, -q + N);
		for r in range(r1,r2+1):
			var hex = Hex.create_and_set_param(q,r,-q-r)
			map[q][r] = Tile.create_and_set_param(hex,null,null,null) # Stores into a dictionary called
													# map
	return map;
