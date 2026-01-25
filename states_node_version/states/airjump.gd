extends PlayerState
var jumped

func enter(previous_state_path: String, data := {}) -> void:
	$"../AnimationTree".set("parameters/conditions/Jump", true)
	
	player.velocity.y = 0
	player.velocity.y = -player.jump_height * player.air_jump_multiplier
	jumped = false
	player.grab_ready = true
	SoundsManager.create_2d_audio_at_location(player.global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.MC_JUMP)


func physics_update(delta: float) -> void:
	player.jump_correction()
	if Input.is_action_just_released("jump") and player.velocity.y < -player.jump_cutoff and not jumped:
		player.velocity.y = -player.jump_cutoff
		jumped = true
		
	var input_direction_x := Input.get_axis("left", "right")
	input_direction_x = sign(input_direction_x)
	
	if not player.is_currently_charging:
		player.velocity.x = player.speed * input_direction_x
	
	if sign(player.velocity.x)>0:
		player.pivot.scale.x = 1
	elif sign(player.velocity.x) < 0:
		player.pivot.scale.x = -1
		
		
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	
	if (Input.is_action_just_pressed("jump") 
	and (player.can_walljump 
	or player.last_jump_normal != player.last_wallnormal)
	and player.on_wall):
		finished.emit(WALLJUMP)
	
	if (player.velocity.y >=0 
	and player.on_wall):
		finished.emit(CLIMBING)
		
		
	elif player.velocity.y >= 0:
		player.can_grab = true
		finished.emit(FALLING)

func exit():
	$"../AnimationTree".set("parameters/conditions/Jump", false)
	player.grab_ready = true
	player.can_grab = true
