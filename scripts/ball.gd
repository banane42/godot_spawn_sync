extends RigidBody3D

func _ready() -> void:
	set_physics_process(multiplayer.is_server())
