extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	$"../AnimationTree".set("parameters/conditions/Walljump", true)
	player.wall_jump_start()
	player.jump_fx()
	SoundsManager.create_2d_audio_at_location(player.global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.MC_JUMP)
	player.grab_ready = true

	
func physics_update(delta: float) -> void:
	var input_direction_x := Input.get_axis("left", "right")
	input_direction_x = sign(input_direction_x)
	if not player.is_currently_charging:	
		if (sign(input_direction_x) != sign(player.velocity.x)) and sign(input_direction_x) != 0:
			player.velocity.x = move_toward(player.velocity.x,player.speed * input_direction_x,100)
		else:
			player.velocity.x = move_toward(player.velocity.x,player.speed * input_direction_x,30)
	
	if sign(player.velocity.x)>0:
		player.pivot.scale.x = 1
	elif sign(player.velocity.x) < 0:
		player.pivot.scale.x = -1
		
		
		
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	if Input.is_action_just_pressed("jump"):
		if player.on_wall:
			if player.can_walljump or player.last_jump_normal != player.last_wallnormal:
				finished.emit(WALLJUMP)
		
		elif player.can_airjump:
			player.can_airjump = false
			#player.velocity.y = -player.jump_height
			$"../AnimationTree".set("parameters/conditions/Reset", true)
			finished.emit(AIRJUMP)
	
	if (player.velocity.y >=0 
	and player.on_wall):
		finished.emit(CLIMBING)	
		
	elif player.velocity.y >= 0:
		player.can_grab = true
		finished.emit(FALLING)
		

func exit():
	$"../AnimationTree".set("parameters/conditions/Walljump", false)
	player.grab_ready = true
	player.can_grab = true
