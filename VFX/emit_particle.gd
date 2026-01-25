extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Eventbus.connect("_player_hit",emit_all_particle)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func emit_all_particle():
	for child in get_children():
		child.restart()
		child.emitting = true
