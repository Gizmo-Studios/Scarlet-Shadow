extends CharacterBody2D

@export var loot_table : Array[Item]

const SPEED = 300.0

var scale_value 
var attack
var player
var launch_force = 600
var health = 1

@onready var center: Marker2D = $Center
@onready var fly_intervall: Timer = $FlyIntervall

func _ready() -> void:
	fly_intervall.start()
	scale_value = $".".scale.x
	center.global_position = global_position
	
func _physics_process(delta: float) -> void:
	velocity.y = move_toward(velocity.y,0,0.1)
	velocity.x = move_toward(velocity.x,0,0.1)
	
	if velocity.x < 0:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
		
	move_and_slide()



func _on_fly_intervall_timeout() -> void:
	var dir  = Vector2(randf_range(-1,1),randf_range(-1,1))
	if attack:
		dir = player.global_position- global_position
	
	elif (center.global_position - global_position).length() > 600:
		dir=center.global_position - global_position
	velocity = dir.normalized()*SPEED
	fly_intervall.start()


func _on_area_2d_body_entered(body: Node2D) -> void:
	attack = true
	player = get_node(body.get_path())
	pass # Replace with function body.

func take_damage():
	health -=1
	if health <= 0:
		call_deferred("die")

func die():
	for items in loot_table:
		if items.drop_chance >= randf_range(0,1):
			#for i in range(0,randi_range(items.drop_amount_min,items.drop_amount_max)):
			var item = items.prefab.instantiate()
			get_tree().get_root().add_child(item)
			item.linear_velocity.x = randi_range(-500,500)
			item.item = items.duplicate()
			item.item.current = randi_range(items.drop_amount_min,items.drop_amount_max)
			item.global_position = global_position
		queue_free()

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage()
	pass # Replace with function body.
