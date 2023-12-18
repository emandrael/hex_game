extends Node2D

var hexLabel = preload("res://Nodes/HexLabel.tscn")
var sprite = preload("res://Nodes/sprite_test.tscn")
signal picc

var hexes : Array[Hex] = []

@onready var unitsNode : Node = get_node('Units')

func _ready():
	var a : Hex = Hex.new(-2,2,0);
	var b : Hex = Hex.new(-2,2,0)
	var c : Hex = a.hex_add(b);
	var N = 4
	for q in range(-N,N+1):
		print(q)
		var r1 = max(-N, -q - N);
		var r2 = min( N, -q + N);
		for r in range(r1,r2+1):
			hexes.append(Hex.new(q,r,-q-r))
	
	

var units = []

func _draw():
	var layout = self.get_parent().get_child(1)
	for hex in hexes:
		var points = HexHelper.polygon_corners(layout,hex);
		draw_polygon(points,[Color.BLACK])
		points.append(points[0])
		draw_polyline(points,Color.WHEAT,10)
		var point = HexHelper.hex_to_pixel(layout,hex);
		var hexLabelInstance = hexLabel.instantiate()
		hexLabelInstance.text = str(hex);
		hexLabelInstance.position = point;
		hexLabelInstance.position.x -= 50;
		hexLabelInstance.position.y -= 10;
		get_parent().get_child(0).add_child(hexLabelInstance)
		if hex.q == 1:
			var unit : Node2D = sprite.instantiate()
			unit.hex = hex;
			unit.position = point;
			unitsNode.add_child(unit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
