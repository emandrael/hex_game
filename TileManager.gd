extends Node2D

var boardsManager : BoardManager = get_tree().root.get_child(0);
var layout : Layout = boardsManager.get_node('Layout')
@export var player_units : Dictionary = {}
@export var enemy_units : Dictionary = {}
@onready var unitsNode : Node = self;


@export var map : Dictionary = {}

# Called when the node enters the scene tree for the first time.
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
