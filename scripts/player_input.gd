extends MultiplayerSynchronizer

@export var is_jumping := false
@export var input_direction := Vector2()
@export var camera: Camera3D

func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera.make_current()
	else:
		set_process(false)
		set_process_input(false)
	
func _process(_delta: float):
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if Input.is_action_just_pressed("jump"):
		jump.rpc()

@rpc("call_local")
func jump():
	is_jumping = true
