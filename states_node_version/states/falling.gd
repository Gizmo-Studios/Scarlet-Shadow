extends PlayerState

@export var landing_fx : PackedScene


func enter(previous_state_path: String, data := {}) -> void:
	$"../AnimationTree".set("parameters/conditions/Falling", true)
	pass
	
func physics_update(delta: float) -> void:
	var input_direction_x := Input.get_axis("left", "right")
	if not player.is_currently_charging:
		input_direction_x = sign(input_direction_x)
		player.velocity.x = player.speed * input_direction_x
		

	player.velocity.y += player.gravity * player.fast_fall_multiplier * delta
	player.velocity.y  = clamp(player.velocity.y,-INF,player.max_fall_speed)
	player.move_and_slide()
	
	#Rotate Player Sprite
	if sign(player.velocity.x)>0:
		player.pivot.scale.x = 1
	elif sign(player.velocity.x) < 0:
		player.pivot.scale.x = -1
	
	if (player.can_climb 
	and player.on_wall 
	and sign(input_direction_x) != sign(player.last_wallnormal) 
	and sign(input_direction_x) != 0):
		finished.emit(CLIMBING)
	
		
	if Input.is_action_just_pressed("jump"):
		
		if not $"../../Timers/jump_coyote".is_stopped():
			finished.emit(JUMPING)
		elif ((player.can_walljump or player.last_wallnormal != player.wall_normal) 
			#and sign(input_direction_x) != sign(player.last_wallnormal) 
			and (sign(input_direction_x) != 0 or not player.can_airjump)
			and player.on_wall):
				finished.emit(WALLJUMP)
		
		elif player.can_airjump:
			player.can_airjump = false
			finished.emit(AIRJUMP)
		
		else:
			player.jump_buffer.start()
	
	if player.on_wall and not player.on_floor and player.can_grab and player.grab_ready and not player.can_climb:
		finished.emit(GRAB)
	#else:
		#player.can_grab = false
		
	
		
	if (#player.is_on_floor() and 
		player.on_floor):
		if is_equal_approx(player.velocity.x, 0.0):
			var fx =  landing_fx.instantiate()
			fx.global_position = $Marker2D.global_position
			get_tree().get_root().add_child(fx)
			if Global.tufan_sounds:
				SoundsManager.create_2d_audio_at_location(player.global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.LANDING)
			else:
				SoundsManager.create_2d_audio_at_location(player.global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.MC_LAND)
	
			finished.emit(IDLE)
		else:
			var fx =  landing_fx.instantiate()
			fx.global_position = $Marker2D.global_position
			get_tree().get_root().add_child(fx)

			if Global.tufan_sounds:
				SoundsManager.create_2d_audio_at_location(player.global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.LANDING)
			else:
				SoundsManager.create_2d_audio_at_location(player.global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.MC_LAND)
			finished.emit(RUNNING)

func exit():
	$"../AnimationTree".set("parameters/conditions/Falling", false)
