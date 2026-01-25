extends Area2D


func _process(delta: float) -> void:
	pass



func _on_body_exited(body: Node2D) -> void:
	$CanvasLayer.hide()


func _on_body_entered(body: Node2D) -> void:
	$CanvasLayer.show()
	pass # Replace with function body.
