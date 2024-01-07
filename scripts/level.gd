extends Node3D

const SPAWN_RANDOM := 5.0

func _ready():
	#If you are not the server, gtf outta heeer
	if not multiplayer.is_server():
		return
	
	#Register callbacks to mulitplayer signals
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	
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
	character.player = net_id
	
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
	$Players.get_node(str(net_id)).queue_free()
