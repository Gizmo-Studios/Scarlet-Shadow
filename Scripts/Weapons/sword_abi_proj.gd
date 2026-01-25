extends RigidBody2D
var set_scale = Vector2.ZERO
func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage()
	queue_free()

func _physics_process(delta: float) -> void:
	if linear_velocity.x < 0:
		$Sprite2D.flip_h = true
