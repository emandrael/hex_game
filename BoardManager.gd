extends Node2D
class_name BoardManager

@export var selected_hex:Hex;
@onready var sprites = get_node("Test/Units/Sprite2D")


func _draw():
	if(selected_hex):
		var neighbours = selected_hex.get_hex_neighbours()
		print(neighbours)
		var layout:Layout = get_node("Layout")
		for nei in neighbours:
			var points = HexHelper.polygon_corners(layout,nei);
			print(points)
			draw_polygon(points,[Color.TRANSPARENT])
			points.append(points[0])
			draw_polyline(points,Color.GREEN,5)
	
func _on_sprite_2d_select_unit(unit, hex):
	if(selected_hex):
		if(selected_hex.equal_to(hex)):
			print('Already Selected')
			return
	selected_hex = hex;
	print("Hex Selected: " + str(selected_hex))
	self.queue_redraw();


func _on_sprite_2d_tree_entered():
	print('fff')


func _on_sprite_2d_ready():
	print('dddd')
