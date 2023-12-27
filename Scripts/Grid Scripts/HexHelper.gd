extends Node

class_name HexHelper

static func hex_round(h:FractionalHex) -> Hex:
	var q = int(round(h.q));
	var r = int(round(h.r));
	var s = int(round(h.s));
	var q_diff = abs(q - h.q);
	var r_diff = abs(r - h.r);
	var s_diff = abs(s - h.s);
	if (q_diff > r_diff and q_diff > s_diff):
		q = -r - s;
	elif (r_diff > s_diff):
		r = -q - s;
	else:
		s = -q - r;
	return Hex.create_and_set_param(q, r, s)

static func hex_lerp(a, b,t:float):
	return FractionalHex.new(lerp(a.q, b.q, t),
						lerp(a.r, b.r, t),
						lerp(a.s, b.s, t));

static func hex_direction(direction:int):
	assert (0 <= direction && direction < 6, "Value not below 6")
	direction = (6 + (direction % 6)) % 6;
	var dir = HexDirections.new().directions;
	return dir[direction];

static func get_hex_direction(from:Hex,to:Hex) -> int:
	var hex = to.hex_subtract(from);
	if hex.q == 1 && hex.r == 0 && hex.s == -1:
		return 1;
	elif hex.q == 1 && hex.r == -1 && hex.s == 0:
		return 2
	elif hex.q == 0 && hex.r == -1 && hex.s == 1:
		return 3
	elif hex.q == -1 && hex.r == 0 && hex.s == 1:
		return 4
	elif hex.q == -1 && hex.r == 1 && hex.s == 0:
		return 5
	elif hex.q == 0 && hex.r == 1 && hex.s == -1:
		return 6
	return -1;
		

static func hex_linedraw(a:Hex,b:Hex) -> Array[Hex]:
	var N = a.hex_distance_from(b);
	var a_nudge = FractionalHex.new(a.q + 1e-06, a.r + 1e-06, a.s - 2e-06)
	var b_nudge = FractionalHex.new(b.q + 1e-06, b.r + 1e-06, b.s - 2e-06)
	var results:Array[Hex] = []
	var step:float = 1.0/max(N,1);
	for i in range(0, N + 1):
		var app = (hex_round(hex_lerp(a_nudge, b_nudge, step * i)))
		results.append(app)
	return results

static func hex_to_pixel(layout:Layout, h:Hex) -> Vector2:
	var M = layout.orientation;
	var x:float = (M.f0 * h.q + M.f1 * h.r) * layout.size.x;
	var y:float = (M.f2 * h.q + M.f3 * h.r) * layout.size.y;
	return Vector2(x + layout.origin.x, y + layout.origin.y);

static func pixel_to_hex(layout:Layout, p:Vector2) -> FractionalHex:
	var M = layout.orientation;
	var pt : Vector2 = Vector2((p.x - layout.origin.x) / layout.size.x,(p.y - layout.origin.y) / layout.size.y);
	var q : float = M.b0 * pt.x + M.b1 * pt.y;
	var r :float = M.b2 * pt.x + M.b3 * pt.y;
	return FractionalHex.new(q, r, -q - r);

static func hex_corner_offset(layout:Layout,corner:int) -> Vector2:
	var size : Vector2 = layout.size;
	var angle  : float = 2.0 * PI * (layout.orientation.start_angle + corner) / 6;
	return Vector2(size.x * cos(angle), size.y * sin(angle))

static func polygon_corners(layout, h) -> Array[Vector2]:
	var corners : Array[Vector2] = [];
	var center = hex_to_pixel(layout, h)
	for i in range(0, 6):
		var offset = hex_corner_offset(layout, i)
		corners.append(Vector2(center.x + offset.x, center.y + offset.y))
	return corners

static func draw_hex(_self:Node2D,layout:Layout,hex_coordinates:Hex,shape_colour : Color,line_colour:Color, size:int = 5):
		var points = polygon_corners(layout,hex_coordinates)
		_self.draw_polygon(points,[shape_colour])
		points.append(points[0])
		_self.draw_polyline(points,line_colour,size)
