extends CharacterBody2D
@export var SPEED = 300.0
var direction = -1
@export var health = 3
@export var launch_force = 600
@export var loot_table : Array[Item]

func _physics_process(delta: float) -> void:
	if is_on_wall() or not $Pivot/RayCast2D.is_colliding():
		$Pivot.scale.x *=-1
		direction *=-1
	velocity.x = direction * SPEED
	move_and_slide()

func take_damage():
	health -=1 
	if health <=0:
		die()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.has_method("take_damage"))
	if body.has_method("take_damage"):
		body.take_damage()
	pass # Replace with function body.

func die():
	for items in loot_table:
		if items.drop_chance >= randf_range(0,1):
			for i in range(0,randi_range(items.drop_amount_min,items.drop_amount_max)):
				var item = items.prefab.instantiate()
				get_tree().get_root().add_child(item)
				item.linear_velocity.x = randi_range(-500,500)
				item.item = items.duplicate()
				item.item.current = 1
				item.global_position = global_position
		queue_free()
