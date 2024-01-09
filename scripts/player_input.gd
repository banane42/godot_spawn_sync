extends MultiplayerSynchronizer

@export var is_jumping := false
@export var input_direction := Vector2()
@export var mouse_motion := Vector2()
var previous_mouse_motion := Vector2()
@export var camera: Camera3D
@export var player: Node3D

#Only runs if local client
func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera.make_current()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		previous_mouse_motion = event.relative		

func _process(_delta: float):
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if Input.is_action_just_pressed("jump"):
		jump.rpc()
	
	if Input.is_action_just_released("shoot"):
		player.shoot.rpc_id(1)

func _physics_process(_delta: float):
	if mouse_motion.distance_to(previous_mouse_motion) > 0.0:
		mouse_motion = previous_mouse_motion
	else:
		previous_mouse_motion = Vector2.ZERO
		mouse_motion = Vector2.ZERO

func _rotate_camera(mouse_vec: Vector2):
	camera.rotate_x(-mouse_vec.y * player.LOOK_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, -PI * 0.5, PI * 0.5)
	

@rpc("call_local")
func jump():
	is_jumping = true
