extends Node3D

const SPAWN_RANDOM := 5.0
var player_count := 0

func _ready():
	#If you are not the server, gtf outta heeer
	if !multiplayer.is_server():
		return
	
	#Register callbacks to mulitplayer signals
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	
	Signals.player_death.connect(_player_death)
	Signals.ragdoll_cleanup.connect(_cleanup_ragdoll)
	
	#Add players for all already connected peers
	for net_id in multiplayer.get_peers():
		_add_player(net_id)
	
	#Check if the server is a dedicated one, if not, we are
	#doing a HostClint server. Add a player so the host can play
	if not OS.has_feature("dedicated_server"):
		_add_player(1)

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(_add_player)
	multiplayer.peer_disconnected.disconnect(_remove_player)

func _add_player(net_id: int):
	print("Adding player: " + str(net_id))
	var character = preload("res://objects/player.tscn").instantiate()
	character.player_id = net_id
	character.color = Enums.PlayerColors.values()[player_count % Enums.PlayerColors.values().size()]
	player_count += 1
	
	var pos = Vector2.from_angle(randf() * 2 * PI)
	character.position = Vector3(
		pos.x * SPAWN_RANDOM * randf(),
		0,
		pos.y * SPAWN_RANDOM * randf()
	)
	character.name = str(net_id)
	$Players.add_child(character, true)

func _remove_player(net_id: int):
	if not $Players.has_node(str(net_id)):
		return
	player_count -= 1
	$Players.get_node(str(net_id)).queue_free()
	
func _player_death(player: CharacterBody3D):
	var ragdoll = preload("res://objects/player_ragdoll.tscn").instantiate()
	ragdoll.transform = player.transform
	ragdoll.position = ragdoll.position + Vector3(0, 1, 0)
	#ragdoll.apply_central_force(player.velocity * 10.0)
	ragdoll.apply_central_force(Vector3(0, 1000, 0))
	ragdoll.color = player.color
	$PhysicsObjects.add_child(ragdoll, true)
	
func _cleanup_ragdoll(node_path):
	if !$PhysicsObjects.has_node(node_path):
		return
	$PhysicsObjects.get_node(node_path).queue_free()
