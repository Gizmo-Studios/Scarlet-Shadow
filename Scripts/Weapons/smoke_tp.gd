extends RigidBody2D

signal can_tp(pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fly_Duration.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func _on_fly_duration_timeout() -> void:
	if ($S.is_colliding() and $N.is_colliding()) or ($O.is_colliding() and $W.is_colliding()):
		queue_free()
		
	else:
		if $N.is_colliding():
			can_tp.emit(global_position+Vector2(0,50))
		elif $S.is_colliding():
			can_tp.emit(global_position+Vector2(0,-50))
		else:
			can_tp.emit(global_position)
		queue_free()
