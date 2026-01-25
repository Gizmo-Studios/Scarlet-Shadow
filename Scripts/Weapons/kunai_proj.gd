extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func destroy():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	queue_free()



func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage()
	destroy()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner.has_method("take_damage"):
		area.owner.take_damage()
	elif area.has_method("take_damage"):
		area.take_damage()
