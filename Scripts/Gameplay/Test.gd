extends Node2D

var hexLabel = preload("res://Nodes/HexLabel.tscn")


var p_hex = Hex.new(1,0,-1)
@onready var map : Dictionary = (get_parent() as BoardManager).map;

func _draw():
	var layout = self.get_parent().get_child(1)
	for _tile in map.values():
		var tile : Tile = _tile;
		HexHelper.draw_hex(self,layout,tile.hex_coordinate,Color.WHEAT,Color.BLACK,2)
		var point = HexHelper.hex_to_pixel(layout,tile.hex_coordinate);
		var hexLabelInstance = hexLabel.instantiate()
		hexLabelInstance.text = str(tile.hex_coordinate);
		hexLabelInstance.position = point;
		hexLabelInstance.position.x -= 50;
		hexLabelInstance.position.y -= 10;
		get_parent().get_child(0).add_child(hexLabelInstance)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
