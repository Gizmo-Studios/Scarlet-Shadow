extends RigidBody2D

signal kunai_gone
signal stopped_moving(pos)

var start_pos
var current_distance
@export var max_distance = 500
@export var despawn_on_impact = 10
@export var despwan_after_hook = 2
var is_stopped = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_stopped = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if start_pos == null:
		start_pos = global_position
		
	if is_stopped and not freeze:
		stopped_moving.emit(global_position)
		$Sprite2D2.visible = true
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
		freeze = true
		add_to_group("Anchor")

func destroy():
	await get_tree().create_timer(despwan_after_hook).timeout
	emit_signal("kunai_gone")
	queue_free()
	


func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage()
	else:
		start_despawn()
	

func _physics_process(delta: float) -> void:
	if start_pos == null:
		start_pos = global_position
	if not is_stopped:
		current_distance = (start_pos-global_position).length()
	if current_distance > max_distance:
		start_despawn()
		is_stopped = true

func start_despawn():
	$Sprite2D2.visible = true
	is_stopped = true
	await get_tree().create_timer(despawn_on_impact).timeout
	queue_free()
	
