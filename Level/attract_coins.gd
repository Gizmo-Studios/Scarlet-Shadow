extends Marker2D
var coin_shader = load("res://particle_to_point.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var my_shader = load("res://part_to_point_attractor.gdshader")
	#coin_shader.shader = my_shader
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		var lobal_position =  canvas_to_world($".")
		coin_shader.set_shader_parameter("target_position",Vector3(lobal_position.x,lobal_position.y,0.0))



func canvas_to_world(canvas_object) -> Vector2:
	var canvas_position = canvas_object.global_position
	var viewport_transform = get_viewport().canvas_transform  # Get the camera transform
	return viewport_transform.affine_inverse() * canvas_position
