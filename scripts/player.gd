extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const LOOK_SENSITIVITY = 0.005

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var player := 1:
	set(id):
		player = id
		$InputSynchron.set_multiplayer_authority(id)

@onready var input = $InputSynchron
@export var camera_mount: Node3D

# Only runs if this is the server
func _ready():
	set_process(multiplayer.is_server())
	#set_physics_process(multiplayer.is_server())

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if input.is_jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY

	input.is_jumping = false

	var direction = (transform.basis * Vector3(
		input.input_direction.x, 
		0, 
		input.input_direction.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	rotate_y(-input.mouse_motion.x * LOOK_SENSITIVITY)
	camera_mount.rotate_x(-input.mouse_motion.y * LOOK_SENSITIVITY)
	camera_mount.rotation.x = clamp(camera_mount.rotation.x, -PI * 0.5, PI * 0.5)
	#input.input_rotation = Vector2()

	move_and_slide()
