extends Node2D
@export var enemy_hit_slow : float  = 0.07
@export var enemy_hit_slow_duration = 0.3

@export var player_hit_slow : float  = 0.07
@export var player_hit_slow_duration = 0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Eventbus.connect("_enemy_hit",freeze_game)
	Eventbus.connect("_player_hit",hit_stop)
	pass

func freeze_game():
	Engine.time_scale = enemy_hit_slow
	await get_tree().create_timer(enemy_hit_slow_duration*enemy_hit_slow).timeout
	Engine.time_scale = 1

func player_freeze_game():
		Engine.time_scale = player_hit_slow
		await get_tree().create_timer(player_hit_slow_duration*player_hit_slow).timeout
		Engine.time_scale = 1
		
func hit_stop():
	var duration = 0.3
	# Freeze specific nodes (e.g., player, enemies)
	for node in get_tree().get_nodes_in_group("freezable"):
		node.process_mode = Node.PROCESS_MODE_DISABLED  # Freeze the node

	await get_tree().create_timer(duration).timeout

	for node in get_tree().get_nodes_in_group("freezable"):
		node.process_mode = Node.PROCESS_MODE_INHERIT  # Resume the node
