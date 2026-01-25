extends PlayerState
# Grappling hook properties
var hook_point = Vector2.ZERO   # Anchor point for the grappling hook
var rope_length = 200.0
var rope_max = 200.0       # Length of the rope
var velocity = Vector2.ZERO     # Current velocity of the character
var gravity = 5000          # Gravity force (pixels/second^2)
var finished_grappling = false
var no_point = false

func enter(previous_state_path: String, data := {}) -> void:
	$"../AnimationTree".set("parameters/conditions/Grappling", true)
	player.can_grab = false
	#player.hook_point.connect("kunai_gone",_kunai_gone)
	player.is_grappling = true
	no_point = false
	player.velocity.y = 0
	velocity = Vector2.ZERO
	finished_grappling = false
	#radius = (player.position - get_viewport().get_mouse_position()).length()
	hook_point = player.hook_point # Initialize position on the orbit
	rope_length = (player.global_position - hook_point).length()
	#player.position = center + Vector2(radius, 0)
	$"../../db_hook".points[1] = $"../../db_hook".to_local(hook_point)
	$"../../db_hook".visible = true
	player.can_airjump = true
	## Initialize velocity tangential to the circle
	#velocity = Vector2(0, speed)
	
	

	
func physics_update(delta: float) -> void:
	
	
	$"../../db_hook".points[1] = $"../../db_hook".to_local(hook_point)
	if sign(player.velocity.x)>0:
		player.pivot.scale.x = 1
	elif sign(player.velocity.x) < 0:
		player.pivot.scale.x = -1
		
	if not finished_grappling:# Calculate the radial vector and distance
		var radial_vector = player.global_position - hook_point
		var distance = radial_vector.length()

		# Correct the length of the rope (keep the character constrained)
		if distance > rope_length:
			player.global_position = hook_point + radial_vector.normalized() * rope_length
		
		rope_length = move_toward(rope_length,rope_max,5)
		# Normalize the radial vector
		var radial_unit = radial_vector.normalized()

		# Gravity force acting on the character
		var gravity_force = Vector2(0, gravity)

		# Calculate tangential velocity
		var tangent = -radial_unit.orthogonal()
		velocity += gravity_force * delta# gravity_force * delta

		# Remove radial velocity (project velocity onto the tangent)
		velocity -= radial_unit * velocity.dot(radial_unit)
		
		player.velocity = velocity
		# Apply movement
	else:
		$"../../db_hook".visible = false
		var input_direction_x := Input.get_axis("left", "right")
		input_direction_x = sign(input_direction_x)
		player.velocity.x = player.speed * input_direction_x
		player.velocity.y += player.gravity * delta
	
	
	if player.is_on_ceiling():
		finished_grappling = true
	
	
	player.move_and_slide()


	if Input.is_action_just_released("attack_heavy") or finished_grappling:
		
		player.is_grappling = false
		finished_grappling = true
		$"../../db_hook".visible = false
		if Input.is_action_just_pressed("jump"):
			if (player.is_on_wall_only() or player.wall_ray.is_colliding()) and (player.can_walljump or player.last_wallnormal != player.wall_normal):
				finished.emit(WALLJUMP)
		
			elif player.can_airjump:
				print(player.can_airjump)
				player.can_airjump = false
				finished.emit(AIRJUMP)
		
			
		if player.is_on_floor():
			finished.emit(RUNNING)
			
		finished.emit(FALLING)
			
func _kunai_gone():
	player.has_point = false #nicht so gut, lieber weniger if / else, parents 
	finished_grappling = true

func exit() -> void:
	$"../AnimationTree".set("parameters/conditions/Grappling", false)
	$"../../db_hook".visible = false
	player.has_point = false
