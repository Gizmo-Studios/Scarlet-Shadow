extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	$"../../Dust_Walking".emitting = true
	$"../AnimationTree".set("parameters/conditions/Running", true)
	player.can_grab = false
	player.recover_stamina()
	#player.can_airjump = true
	#player.can_walljump = true
	#player.last_wallnormal = Vector2.ZERO
	#player.stamina  = player.max_stamina
	#player.velocity.y = 0
	
	
func physics_update(delta: float) -> void:
	

	var input_direction_x := Input.get_axis("left", "right")
	input_direction_x = sign(input_direction_x)
	if not player.is_currently_charging:
		player.velocity.x = player.speed * input_direction_x
	player.velocity.y += player.gravity * delta
	if sign(player.velocity.x)>0:
		player.pivot.scale.x = 1
	elif sign(player.velocity.x) < 0:
		player.pivot.scale.x = -1
		
	player.move_and_slide()	

	if not player.is_on_floor():
		$"../../Timers/jump_coyote".start()
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump") or not player.jump_buffer.is_stopped():
		finished.emit(JUMPING)
	elif is_equal_approx(input_direction_x, 0.0):
		finished.emit(IDLE)

func exit():
	$"../../Dust_Walking".emitting = false
	$"../AnimationTree".set("parameters/conditions/Running", false)
