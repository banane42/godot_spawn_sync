extends MultiplayerSynchronizer

@export var is_jumping := false
@export var input_direction := Vector2()
@export var input_rotation := Vector2()
@export var camera: Camera3D
@export var player: Node3D

#Only runs if local client
func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera.make_current()
	else:
		set_process(false)
		set_process_input(false)
	
func _process(_delta: float):
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	input_rotation = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	camera.rotate_x(-input_rotation.y * player.LOOK_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, -PI * 0.5, PI * 0.5)
	
	if Input.is_action_just_pressed("jump"):
		jump.rpc()

@rpc("call_local")
func jump():
	is_jumping = true
