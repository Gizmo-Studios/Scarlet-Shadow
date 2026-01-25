extends Area2D
@export var only_lock_vertical : bool = false
@export var lock_panning: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	body.change_camera_region_enter_v(global_position,lock_panning,!only_lock_vertical)
	pass # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	body.change_camera_region_exit()
	pass # Replace with function body.
