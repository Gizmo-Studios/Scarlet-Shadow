extends PlayerState
@onready var wall_hang_timer: Timer = $"../../Timers/wall_hang_timer"
var press_timer = 0

func enter(previous_state_path: String, data := {}) -> void:
	$"../../Dust_Walking".emitting = true
	
	$"../AnimationTree".set("parameters/conditions/Climbing", true)
	player.can_grab = false
	player.velocity.y = 0
	press_timer = 0
	pass

func physics_update(delta: float) -> void:
	var input_direction_x := Input.get_axis("left", "right")
	input_direction_x = sign(input_direction_x)
	
	if Vector2(player.last_wallnormal,0.0).dot(Vector2(input_direction_x,0)) <= 0 and (0 < player.stamina):
		player.velocity.y = 0
		player.stamina -= 80*delta
		
	elif Vector2(player.last_wallnormal,0.0).dot(Vector2(input_direction_x,0)) <= 0 :
		player.velocity.y += player.gravity * 0.1 * delta
			
	else:
		press_timer += delta
		print(press_timer)
	if press_timer > 0.25:
		player.velocity.y += player.gravity * player.fast_fall_multiplier * delta
		player.velocity.x = player.speed * input_direction_x
	
	
	
	player.move_and_slide()
	
	
	#Rotate Player Sprite
	if sign(player.get_wall_normal().x)>0:
		player.pivot.scale.x = 1
	elif sign(player.get_wall_normal().x) < 0:
		player.pivot.scale.x = -1
		
			
	
	if player.is_on_floor() or player.on_floor:
		if is_equal_approx(player.velocity.x, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUNNING)	
			
	elif not player.on_wall:
		$"../../Timers/wall_coyote".start()
		finished.emit(FALLING)
	
	elif Input.is_action_just_pressed("jump") and (player.can_walljump or player.last_jump_normal != player.last_wallnormal):
		finished.emit(WALLJUMP)
		
func exit():
	$"../../Dust_Walking".emitting = false
	$"../AnimationTree".set("parameters/conditions/Climbing", false)
