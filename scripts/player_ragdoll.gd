extends RigidBody3D

@export var mesh: MeshInstance3D
var color: Enums.PlayerColors

func _ready():
	_set_material()
	set_process(multiplayer.is_server())
	set_physics_process(multiplayer.is_server())
	set_process_input(multiplayer.is_server())
	
	if !multiplayer.is_server():
		return
	
	$CleanupTimer.start()
	rotate_x(randf() * deg_to_rad(5.0))
	rotate_z(randf() * deg_to_rad(5.0))

func _set_material():
	match color:
		Enums.PlayerColors.RED:
			mesh.material_override = load("res://assets/player_red.material")
		Enums.PlayerColors.GREEN:
			mesh.material_override = load("res://assets/player_green.material")
		Enums.PlayerColors.BLUE:
			mesh.material_override = load("res://assets/player_blue.material")
		Enums.PlayerColors.WHITE:
			mesh.material_override = load("res://assets/player_white.material")


func _on_cleanup_timer_timeout() -> void:
	Signals.ragdoll_cleanup.emit(get_path())
