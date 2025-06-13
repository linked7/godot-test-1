extends Node3D

class_name Map

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
@onready var input_ip: LineEdit = $MainMenu/InputIP
@onready var input_port: LineEdit = $MainMenu/InputPort

func _on_host_pressed() -> void:
	peer.create_server(22223)
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$MainMenu.hide()
	
func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	player.global_position = $SpawnPoint.global_position
	
	Items.create_item("carrot", $SpawnPoint.global_position, Vector3())
	Items.create_item("apple", $SpawnPoint.global_position, Vector3(0, 90, 0))
	Items.create_item("carrot", $SpawnPoint.global_position, Vector3())
	Items.create_item("apple", $SpawnPoint.global_position, Vector3(0, 90, 0))
	Items.create_item("carrot", $SpawnPoint.global_position, Vector3())
	Items.create_item("apple", $SpawnPoint.global_position, Vector3(0, 90, 0))
	Items.create_item("carrot", $SpawnPoint.global_position, Vector3())
	Items.create_item("apple", $SpawnPoint.global_position, Vector3(0, 90, 0))
	Items.create_item("carrot", $SpawnPoint.global_position, Vector3())
	Items.create_item("apple", $SpawnPoint.global_position, Vector3(0, 90, 0))
	Items.create_item("carrot", $SpawnPoint.global_position, Vector3())
	Items.create_item("apple", $SpawnPoint.global_position, Vector3(0, 90, 0))
	
	
func exit_game(id = 1):
	multiplayer.peer_disconnected.connect(del_player(id))
	del_player(id)

func _on_join_pressed() -> void:
	peer.create_client(input_ip.text, input_port.text.to_int())
	multiplayer.multiplayer_peer = peer
	$MainMenu.hide()
	
func del_player(id):
	rpc("_del_player",id)
	
@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
