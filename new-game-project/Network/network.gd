extends Node

var lobby_id = 0
var peer : MultiplayerPeer
var network_object_spawn : Node3D

var lobby_list_container : Control

var scene_dictionary : Dictionary[int, PackedScene]
var object_dictionary : Dictionary[int, PackedScene]

signal scene_change(scene_id)
signal peer_connected(peer_id)

func _init():
	OS.set_environment("SteamAppID", "480")
	OS.set_environment("SteamGameID", "480")
	Steam.steamInitEx()

func _ready():
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)

func _on_host_pressed():
	print("host button pressed")
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 32)

func _process(_delta):
	Steam.run_callbacks()
	if peer != null && peer.get_connection_status() == peer.CONNECTION_DISCONNECTED:
		print("disconnected")

func _on_lobby_created(_connect, id):
	print("Lobby Created!! " + str(id))
	peer = SteamMultiplayerPeer.new()
	if _connect:
		lobby_id = id
		Steam.setLobbyJoinable(lobby_id, true)
		Steam.setLobbyData(lobby_id,"name", str(Steam.getPersonaName() + " TEST LOBBY"))
		Steam.setLobbyData(lobby_id,"game", "surface")
		
		var error = peer.create_host(0)
		if error == OK:
			multiplayer.set_multiplayer_peer(peer)
			multiplayer.peer_connected.connect(_on_connecting_client)
			print(lobby_id)
			switch_scene(1)
		else:
			print("error creating lobby: %s " % error)

func join_lobby(id):
	print("Attempting join on " + str(id) + " ")
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.joinLobby(id)

func _open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("game","surface", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func _on_lobby_match_list(lobbies):
	if lobby_list_container.get_child_count() > 0:
		for v in lobby_list_container.get_children():
			v.queue_free()
			
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var mem_count = Steam.getNumLobbyMembers(lobby)
		
		var bt = Button.new()
		bt.set_text(str(lobby_name, "| Player Count: ", mem_count))
		bt.set_size(Vector2(100,5))
		bt.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		
		lobby_list_container.add_child(bt)

func _on_connecting_client(client_ID):
	print("Client Connected: " + str(client_ID))
	peer_connected.emit(client_ID) #notify the rest of the program
	if client_ID != 1:
		switch_scene.rpc_id(client_ID, 1) # 1 is main level
		spawn_network_object.rpc_id(client_ID, Vector3(0,20,0), Vector3(0,0,0), Basis.IDENTITY, 0, client_ID)

func _on_lobby_joined(lobby_ID, perms, invite_lock, error):
	if error == 1:
		if Steam.getLobbyOwner(lobby_ID) != Steam.getSteamID():
			print("We're in!!")
			#spawn in player
			peer = SteamMultiplayerPeer.new()
			error = peer.create_client(Steam.getLobbyOwner(lobby_ID), 0)
			if error == OK:
				print("connecting to host... ")
				multiplayer.set_multiplayer_peer(peer)
				
			else:
				print("error creating client: %s " % str(error))
	else:
		print("error joining host: %s " % str(error))

@rpc("any_peer", "call_local")
func spawn_network_object(pos : Vector3, vel : Vector3, rot : Basis, scene_ID : int, network_id) -> void:
	if multiplayer.get_unique_id() == 1:
		var b = object_dictionary[scene_ID].instantiate()
		b.set_multiplayer_authority(network_id)
		b.name = str(multiplayer.get_unique_id())
		network_object_spawn.add_child(b, true)
		b.linear_velocity = rot * vel
		b.global_position = pos
		print("called from " + str(multiplayer.get_remote_sender_id()))

@rpc("authority", "call_local")
func switch_scene(scene_ID : int) -> void:
	print("attempting to switch scene to ID " + str(scene_ID))
	scene_change.emit(scene_ID)

func rpc_ping_handle(msg: String):
	rpc_ping.rpc(msg)

@rpc("any_peer", "call_local")
func rpc_ping(msg : String) -> void:
	print(msg)
