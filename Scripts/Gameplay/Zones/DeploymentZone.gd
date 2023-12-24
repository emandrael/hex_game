extends Node2D

class_name DeploymentZone

@onready var deployment_zone_manager : DeploymentZoneManager = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready():
	deployment_zone_manager.delete_deployment_nodes.connect(queue_free);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
