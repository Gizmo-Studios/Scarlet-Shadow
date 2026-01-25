extends PlayerState
var launched
func enter(previous_state_path: String, data := {}) -> void:
	$"../AnimationTree".set("parameters/conditions/LedgeGrap", true)
	if $"../../Pivot/WallCheck_2".is_colliding():
		$"../../Pivot".scale.x *=-1
	player.on_ledge = true
	$Holding.start()


func physics_update(delta: float) -> void:
	player.velocity.x = 30 * player.direction
	player.velocity.y += player.gravity * player.fast_fall_multiplier * delta
	
	var input_direction_x := Input.get_axis("left", "right")
	input_direction_x = sign(input_direction_x)
	if sign(input_direction_x) != sign(player.direction) and sign(input_direction_x) != 0 :
		player.can_grab = false
		player.grab_ready = false
		finished.emit(FALLING)
	#
	#if sign(player.velocity.x)>0:
		#player.pivot.scale.x = 1
	#elif sign(player.velocity.x) < 0:
		#player.pivot.scale.x = -1
		#
		#
	#player.velocity.y += player.gravity * delta
	#player.move_and_slide()
	#
	
	
	player.move_and_slide()
	if not player.on_wall:
		finished.emit(FALLING)
		
	if Input.is_action_just_pressed("jump"):
		player.launch_player(1000)
func exit():
	$"../AnimationTree".set("parameters/conditions/LedgeGrap", false)
	$Holding.stop()
	player.on_ledge = false
	player.stamina = 0


func _on_holding_timeout() -> void:
	player.grab_ready = false
	player.can_grab = false
	finished.emit(FALLING)
	pass # Replace with function body.
