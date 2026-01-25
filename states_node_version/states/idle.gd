extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	$"../AnimationTree".set("parameters/conditions/Idle", true)
	player.recover_stamina()
	player.can_grab = false
	

func physics_update(_delta: float) -> void:
	player.update_gravity(_delta)
	player.move_and_slide()

	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump") or not player.jump_buffer.is_stopped():
		finished.emit(JUMPING)
	elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		finished.emit(RUNNING)

func exit():
	$"../AnimationTree".set("parameters/conditions/Idle", false)
