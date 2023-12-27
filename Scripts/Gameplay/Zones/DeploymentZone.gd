extends StaticBody2D

class_name DeploymentZone

@export var hex : Hex;

@onready var deployment_zone_manager : DeploymentZoneManager = get_parent();
@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	deployment_zone_manager.delete_deployment_nodes.connect(_on_delete_deployment_nodes);

func _on_delete_deployment_nodes():
	deployment_zone_manager.all_zones.erase(str(self))
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.is_dragging:
		sprite.visible = true;
		sprite.play()
	else:
		sprite.visible = false;
		sprite.pause()

func set_debug(_debug : bool):
	var collision_shape : CollisionShape2D = get_node('CollisionShape2D')
	collision_shape.visible = _debug;
