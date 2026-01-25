extends PlayerState
var hook_force = 2000
var finished_grappling = false
var hook_point
var hook_dir
var hooking
var rope_length = 50
var distance 
var no_point = false

func enter(previous_state_path: String, data := {}) -> void:
	$"../AnimationTree".set("parameters/conditions/Hooking", true)
	player.can_grab = true
	hook_point = player.hook_point
	hook_dir = hook_point-player.global_position
	distance = hook_dir.length()
	$"../../db_hook".points[1] = $"../../db_hook".to_local(hook_point)
	$"../../db_hook".visible = true
	hooking = true
	$"../../Timers/hook_max".start()
	player.is_grappling = true
	
func physics_update(delta: float) -> void:

	$"../../db_hook".points[1] = $"../../db_hook".to_local(hook_point)
	if sign(player.velocity.x)>0:
		player.pivot.scale.x = 1
	elif sign(player.velocity.x) < 0:
		player.pivot.scale.x = -1
	
	if distance > rope_length:
		hook_dir = hook_point-player.global_position
		distance = hook_dir.length()
		player.velocity = hook_force*hook_dir.normalized()
			
	else:
		hooking = false
	
		
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	#	



	if Input.is_action_just_pressed("jump") and not hooking:

		player.is_grappling = false
		$"../../db_hook".visible = false
		if (player.is_on_wall_only() or player.wall_ray.is_colliding()) and (player.can_walljump or player.last_wallnormal != player.wall_normal):
			finished.emit(WALLJUMP)
	
		elif player.can_airjump:
			print(player.can_airjump)
			player.can_airjump = false
			finished.emit(AIRJUMP)
	if not hooking:
		player.is_grappling = false
		$"../../db_hook".visible = false
		player.launch_player(1000,player.velocity.normalized())
		
	if player.is_on_floor() and not hooking:
		player.is_grappling = false
		$"../../db_hook".visible = false
		finished.emit(RUNNING)


func _on_hook_max_timeout() -> void:
	$"../AnimationTree".set("parameters/conditions/Hooking", false)
	hooking = false
	pass # Replace with function body.

func exit():
	player.is_grappling = false
	$"../../db_hook".visible = false
