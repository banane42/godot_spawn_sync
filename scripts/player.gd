extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const LOOK_SENSITIVITY = 0.005

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var color: Enums.PlayerColors
var health := 3

@export var player_id := 1:
	set(id):
		player_id = id
		$InputSynchron.set_multiplayer_authority(id)

@onready var input = $InputSynchron
@onready var mesh = $Model/Mesh
@export var camera_mount: Node3D
@export var raycast: RayCast3D

# Only runs if this is the server
func _ready():
	set_process(multiplayer.is_server())
	_set_material()

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

	move_and_slide()
	
	for col_idx in get_slide_collision_count():
		var col := get_slide_collision(col_idx)
		if col.get_collider() is RigidBody3D:
			col.get_collider().apply_central_impulse(-col.get_normal() * 0.3)

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
		
@rpc("any_peer", "call_local")
func shoot():
	# If not server. Do not execute
	if !multiplayer.is_server():
		return
	
	if raycast.is_colliding():
		var player = raycast.get_collider()
		print("Hit player " + str(player.player_id))
		player.recieve_damage.rpc()
	
@rpc("call_local")	
func recieve_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector3.ZERO
