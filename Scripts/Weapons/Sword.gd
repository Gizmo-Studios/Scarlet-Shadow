extends Weapon

@export var sword_abi_proj : PackedScene
@export var hit_effect :  PackedScene

@onready var weapon_socket : Node2D = $".."
@onready var sword_hit: Area2D = $Area2D
@export_flags_2d_physics var enemy_layer
@onready var sword_slash: Node2D = $Sword_Slash



var enemy
var attacking = false
var attack_scale = 0
var enemies = []
var checked_enemies = []
var points: Array = []  # Stores lightning bolt positions

func attack():
	super.attack()
	$"../../../State_Machine/AnimationTree".active = false
	
	if weapon_socket.attack_dir == "down":
		$"../../../AnimationPlayer".play("Attack_Down")
	elif weapon_socket.attack_dir == "up":
		$"../../../AnimationPlayer".play("Attack_Up")
	else:
		$"../../../AnimationPlayer".play("Attack_Front")
	if Global.tufan_sounds:
		SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.SLASH)
	else:
		SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.SIMPLESLASH)
	sword_slash.play_animation()
	$AnimationPlayer.play("Slash")
	$"../../../Timers/attack_cd".start()
	weapon_socket.s_attacking = true 


func _sword_slash_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		spawn_hit_fx(body)
		player.impact_frame()
		
	
		if weapon_socket.attack_dir == "down":
			if "launch_force" in body:
				weapon_socket.launch_player(body.launch_force)
			else:
				weapon_socket.launch_player()
		body.take_damage()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner.has_method("take_damage"):
		if weapon_socket.attack_dir == "down":
			spawn_hit_fx(area.owner)
			weapon_socket.launch_player(area.owner.launch_force)
			if area.owner.is_in_group("Spike"):
				if Global.tufan_sounds:
					SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.SPIKESLASH)
				else:
					SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.SPIKEHIT)


	elif area.has_method("take_damage"):
		area.take_damage()


func spawn_hit_fx(body):
	var dir = body.global_position - player.global_position
	var hit = hit_effect.instantiate()
	hit.angle_min = rad_to_deg(dir.normalized().angle())
	hit.angle_max = rad_to_deg(dir.normalized().angle())
	hit.global_position = body.global_position
	player.impact_frame()
	get_tree().get_root().add_child(hit)

func _on_ability_range_body_entered(body: Node2D) -> void:
	enemy = body
 


func _on_ability_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func ability():
	super.ability()
	enemies = []
	checked_enemies = []
	enemy = null
	weapon_socket.s_attacking = true
	if $Attack_Loop.is_stopped():
		$Sword_Ability_Test/Area2D/CollisionShape2D.disabled = false
		var tween = get_tree().create_tween()
		$"../../../Shockwave".visible = true
		tween.tween_method(change_shock,0.0,5,0.2)
		tween.tween_callback($"../../../Shockwave".set_visible.bind(false))
		$"../../../GPUParticles2D".emitting = true
		SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.TIMESTOP)
		Engine.time_scale = 0.2
	
		await get_tree().create_timer(0.1).timeout
		$Attack_Loop.start()

func change_shock(value):
	pass
	$"../../../Shockwave".scale = Vector2(value,value)
	
func teleport_slash():
	pass




func check_uses_left():
	pass

func start_ability_attack(body):
	checked_enemies.append(body)
	checked_enemies = find_nearby_enemies(body,500,checked_enemies)
	enemies = checked_enemies
	enemies = enemies.filter(func(obj): return obj.is_in_group("Enemy"))
	
	if enemies.size()>=1:
		player.invincible_active = true
		var index
		var temp
		var shortest_distance = INF
		#for i in range(enemies.size()):
			#if (enemies[i].global_position-player.global_position).length()<shortest_distance:
				#shortest_distance = (enemies[i].global_position-player.global_position).length()
				#temp = enemies[i]
			#enemies.erase(temp)
			#enemies.insert(0,temp)
		enemies = sort_by_distance(player,enemies)
		chain_lightning_effect(enemies)
	else:
		push_and_clean()

func sort_by_distance(player: Node2D, enemiess: Array) -> Array:
	enemiess.sort_custom(func(a, b): return a.global_position.distance_to(player.global_position) < b.global_position.distance_to(player.global_position))
	return enemiess
	
func chain_lightning_effect(enemies: Array):
	var tween = create_tween()
	tween.set_parallel(false)  # Ensures animations play sequentially
	player.use_ink(ink_cost)
	for i in range(len(enemies)):
		var start_pos = enemies[i].global_position
		tween.tween_property(player,"global_position",start_pos,0.05)
		tween.tween_callback(impact_sound)
		tween.tween_interval(0.1)
		
	# Final callback to clear the effect

	tween.tween_callback(push_and_clean)

func impact_sound():
	SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.BRUSHSWIPE)
	$Line2D.add_point(player.global_position)
	
	
func push_and_clean():
	for i in range(len(enemies)):
		if enemies[i] != null:
			enemies[i].take_damage()
	player.push_out_of_ground()
	enemy = null
	
	weapon_socket.s_attacking = false
	await get_tree().create_timer(0.2).timeout
	player.invincible_active = false
	$Sword_Ability_Test/Area2D/CollisionShape2D.disabled = true
	$"../../../GPUParticles2D".emitting = false
	$Line2D.clear_points()


#
#func safe_teleport(target_pos: Vector2):
	#var safe_pos = target_pos
	#var attempts = 10  # Number of tries to adjust position
	#var offset = 16  # How far to move out of obstacles each time
#
	## Check if the target position is already safe
	#if not player.test_move(transform, safe_pos - global_position):
		#global_position = safe_pos
		#return
#
	## Try moving away from the obstacle
	#for i in range(attempts):
		#var direction = Vector2.RIGHT.rotated(deg_to_rad(i * (360 / attempts)))
		#var new_pos = safe_pos + direction * offset
#
		#if not player.test_move(transform, new_pos - global_position):
			#global_position = new_pos
			#return

func find_nearby_enemies(enemy: Node2D, range: float, checked_enemies: Array):
	var space_state = get_world_2d().direct_space_state
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = range

	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(circle_shape)
	query.transform = enemy.global_transform
	query.collision_mask = enemy_layer
	query.exclude = checked_enemies  # Prevent duplicate checks

	var results = space_state.intersect_shape(query, 10)  # Max 10 results

	for result in results:
		var other_enemy = result.collider
		if other_enemy and other_enemy != enemy and other_enemy not in checked_enemies:
			checked_enemies.append(other_enemy)
			find_nearby_enemies(other_enemy, range, checked_enemies)  # Recursive search

	return checked_enemies



func _on_attack_loop_timeout() -> void:
	
	Engine.time_scale = 1
	
	if enemy != null:
		start_ability_attack(enemy)
	else:
		weapon_socket.s_attacking = false
		$"../../../GPUParticles2D".emitting = false

	$Sword_Ability_Test/Area2D/CollisionShape2D.disabled = true



# Draw the lightning effect
func _draw():
	if points.size() < 2:
		return  # No lines to draw

	for i in range(points.size() - 1):
		var start_pos = points[i]
		var end_pos = points[i + 1]
		draw_line(start_pos, end_pos, Color(1, 1, 1), 2)  # White lightning bolt


func _on_sword_slash_finished() -> void:
	$"../../../Timers/attack_cd".start()
	weapon_socket.s_attacking = false
	attacking = false
	pass # Replace with function body.


func _on_attack_cd_timeout() -> void:
	weapon_socket.s_attacking = false
	pass # Replace with function body.
