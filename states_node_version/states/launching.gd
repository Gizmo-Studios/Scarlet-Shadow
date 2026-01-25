extends PlayerState
var launched

func enter(previous_state_path: String, data := {}) -> void:
	$"../AnimationTree".set("parameters/conditions/Launching", true)
	player.can_grab = true
	player.velocity.y = 0
	player.velocity = player.launch_dir*player.launch_force
	launched = true
	player.grab_ready = true
	SoundsManager.create_2d_audio_at_location(player.global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.MC_JUMP)

func physics_update(delta: float) -> void:
	var input_direction_x := Input.get_axis("left", "right")
	input_direction_x = sign(input_direction_x)
	if not player.is_currently_charging:
		player.velocity.x = move_toward(player.velocity.x , player.speed * input_direction_x, 20)
	
	if sign(player.velocity.x)>0:
		player.pivot.scale.x = 1
	elif sign(player.velocity.x) < 0:
		player.pivot.scale.x = -1
		
		
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	if Input.is_action_just_pressed("jump"):
		if (player.is_on_wall_only() or player.wall_ray.is_colliding()) and (player.can_walljump or player.last_wallnormal != player.wall_normal):
			finished.emit(WALLJUMP)
		
		elif player.can_airjump:
			print(player.can_airjump)
			player.can_airjump = false
			finished.emit(AIRJUMP)
		
	if player.velocity.y >= 0:
		finished.emit(FALLING)

func exit():
	$"../AnimationTree".set("parameters/conditions/Launching", false)
