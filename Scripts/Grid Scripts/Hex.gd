extends Node

class_name Hex
var q:int:
	get:
		return q;
var r:int:
	get:
		return r;
var s:int:
	get:
		return s;
		

func _init(_q,_r,_s):
	q = _q;
	r = _r;
	s = _s;
	assert((q+r+s) == 0,'Coordinates do not add to 0'); 
	

func equal_to(b:Hex):
	return q == b.q && r == b.r && s == b.s;

func not_equal_to(b:Hex):
	return !equal_to(b);

func hex_add(b) -> Hex:
	return Hex.new(q + b.q, r + b.r, s + b.s)

func hex_subtract(b) -> Hex:
	return Hex.new(q - b.q, r - b.r, s - b.s)

func hex_multiply(k) -> Hex:
	return Hex.new(q * k, r * k, s * k);

func hex_length() -> int:
	return (abs(q) + abs(r) + abs(s)) / 2
	
func hex_distance_from(b) -> int:
	return self.hex_subtract(b).hex_length()

func hex_direction(direction:int):
	assert (0 <= direction && direction < 6, "Value not below 6")
	direction = (6 + (direction % 6)) % 6;
	var dir = HexDirections.new().directions;
	return dir[direction];

func get_hex_neighbours() -> Array[Hex]:
	var neighbours : Array[Hex] = []
	var directions = HexDirections.new().directions;
	for dir in directions:
		neighbours.append(self.hex_add(dir))
	return neighbours;

func hex_neighbor_at(direction:int):
	return hex_add(hex_direction(direction));

func _to_string():
#	return ('q:'+str(q) + ' ' + 'r:'+str(r) + ' ' + 's:'+str(s) + ' ');
	return (str(q) + ' ' +str(r) + ' ' + str(s) + ' ');

