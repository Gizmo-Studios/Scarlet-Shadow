# Character that moves and jumps.
class_name Player extends CharacterBody2D

signal weapon_updated(w_name,w_icon,w_uses)
signal took_damage(old_health, new_health)
signal player_dead()
signal ink_changed(ink_percentage)

@export_group("Player Settings")
@export var tufan_sounds = false
@export var max_health = 3 ## Max Healt / How many hits can the Player take
@export var jump_height :=1300 ## Max Jump Height
@export var jump_cutoff := 500.0 ## Min Jump Height
@export var gravity = 3500 ## Player Gravity 
@export var max_stamina = 30  ## maximum stamina 
@export var wall_jump_height_multi = 0.8
@export var wall_jump_distance_multi = 1.5
@export var air_jump_multiplier : float = 1
@export var fast_fall_multiplier = 1
@export var max_fall_speed = 1200
@export var i_frame_duration : float = 2 ## Duration that the player cant take any damage
@export var speed_curve : Curve ## Curve that is sampled to change the player Speed base on the Ink Percantage
@export var i_frame_curve : Curve ## Invincibility Frame Blinking Animation (alpha curve)

@export var camera_zone : Node2D

@export_group("Grapple Settings")
@export var grapple_check_length = 600 ## Grappling Hook check length from player
@export var grapple_check_width = 50.0 ## Grappling Hook check width 
@export_flags_2d_physics var grapple_floor_check ## Dont Change, its just easier to use then Bit-offsets
@export_flags_2d_physics var grapple_cast_check ## Dont Change, its just easier to use then Bit-offsets

@export_group("Ink Settings")
@export var ink_max : float = 200.0 ## Maximun amount of ink
@export var ink_min_treshold : float = 0.2 ## Point when the UI should change color
@export var ink_max_treshold : float = 0.8 ## Point when the UI should change color
@export var ink_current : float = 0.0 ## set starting ink
@export var ink_gain : float = 50 ## ink gain when standing in Ink Puddles

@export_group("VFX Scenes")
@export var wj_effect : PackedScene ## Sprite for the walljump
@export var coinbag: PackedScene
#@export var click_check_radius = 100
#@export var hook_range = 600
var custom_cursor = preload("res://Assets/Abilities/T_Anker_Point.png")
## Booleans
var can_airjump = true
var can_walljump = true
var on_wall = false
var can_climb = true
var is_grappling = false
var has_point= false
var is_alive = true
var is_on_ink = false
var invincible_active
var is_attacking = {"value": false, "weapon":""}
var is_currently_charging
var on_floor = false
var _can_grab = false
var can_grab = false : get = get_can_grab, set = set_can_grab
var on_ledge = false
var grab_ready = false
var dying = false
var paused
var save_bag_pos = global_position

## Wall Normal Checks for Wall Jump
var last_wallnormal = 0
var last_jump_normal = 0
var wall_normal
var wall_coll_pos = Vector2.ZERO

## Hook Points and Anchors for the Grapple
var hook_point 
var anchors : Array[Node2D]

## Launch dir and force for the Launching state
var launch_force = 0 
var launch_dir

## Current stats of the Player
var speed = 0
var current_health = 5
var direction = 0
var active_weapon 
var active_state
var stamina
var ink_max_bar
var ink_percentage : float
var spawn_point
var speed_buff  = 1

## Assigning Scene Nodes to Variables for easy use
@onready var camera_controls: Marker2D = $Pivot/Default_Pos
@onready var inventory: Node2D = $Inventory
@onready var ink_bg: ColorRect = $Control/ink_bg
@onready var ink_fill: ColorRect = $Control/ink_fill
@onready var player_sprite: Sprite2D = $Pivot/Sprite2D
@onready var pivot: Node2D = $Pivot
@onready var wall_ray: RayCast2D = $Pivot/WallCheck_1
@onready var wall_ray2: RayCast2D = $Pivot/WallCheck_2
@onready var fsm := $State_Machine
@onready var weapon_socket: Node2D = $Pivot/Weapon_Socket
@onready var grapple_check_area: CollisionShape2D =  $Pivot/Grapple_Pivot/GrappleChecker/CollisionShape2D
#@onready var grapple_check_area: CollisionShape2D = $Grapple_Pivot/GrappleChecker/CollisionShape2D
@onready var debug_checker: ColorRect =  $Pivot/Grapple_Pivot/GrappleChecker/debug_checker
@onready var grapple_pivot: Node2D = $Pivot/Grapple_Pivot
@onready var grapple_obstacle_check: RayCast2D =  $Pivot/Grapple_Pivot/grapple_obstacle_check
@onready var wall_coyote: Timer = $Timers/wall_coyote
@onready var jump_coyote: Timer = $Timers/jump_coyote

@onready var jump_buffer: Timer = $Timers/jump_buffer
@onready var i_frames_hit: Timer = $Timers/IFrames
@onready var weapon_swap_cd: Timer = $Timers/Weapon_swap_cd
@onready var camera: Camera2D = $Camera2D

#@onready var animation_player: AnimationPlayer = $Pivot/Sprite2D/AnimationPlayer


@export var jump_trail_vfx : PackedScene
@export var jump_cloud_vfx : PackedScene
@onready var marker_2d_2: Marker2D = $Marker2D2

func _ready() -> void:
	Global.tufan_sounds = tufan_sounds
	#Input.set_mouse_mode(4)
	if FileAccess.file_exists("user://savegame.save"):
		SaveAndLoad.load_player()
		await SaveAndLoad.load_player()
	#Engine.time_scale = 0.05
	stamina = max_stamina
	current_health = max_health
	took_damage.emit(current_health, current_health)
	ink_percentage = ink_current/ink_max
	ink_changed.emit(ink_percentage)
	#connect("kunai_gone",_kunai_gone)
	i_frames_hit.wait_time = i_frame_duration
	ink_max_bar = ink_fill.size.x
	
	grapple_check_area.shape.size.x = grapple_check_length
	grapple_check_area.shape.size.y = grapple_check_width
	grapple_check_area.position.x = grapple_check_length/2
	debug_checker.size.x = grapple_check_length
	debug_checker.size.y = grapple_check_width
	debug_checker.position.y = -grapple_check_width/2
	grapple_obstacle_check.target_position.x = grapple_check_length -10
	spawn_point  = global_position
	Global.last_checkpoint  = global_position
	InteractionManager.player = get_tree().get_first_node_in_group("Player")
	
	
func _process(_delta: float) -> void:
	#$Pivot/Kunai_Ring.visible = weapon_socket.active_weapon.w_uses_left >0
	$Collect_Ink.visible = on_ink()
	is_currently_charging = ((weapon_socket.s_attack_press_time >=0.2 
								and weapon_socket.s_attacking) 
								or  
								(weapon_socket.k_attack_press_time >=0.2 
								and weapon_socket.k_attacking))
	
	if on_floor and $Timers/bag_spot_check.is_stopped():
		save_bag_pos = global_position
		$Timers/bag_spot_check.start()
		
	Global.player_position = global_position
	#print(fsm.state.name)
	speed = speed_curve.sample(ink_percentage) * speed_buff 

	#grapple_pivot.look_at(get_global_mouse_position())
	if anchors.size()>0:
		
		grapple_obstacle_check.target_position.x = (grapple_obstacle_check.global_position - anchors[0].global_position).length()-10
		if grapple_obstacle_check.is_colliding():
			$Marker2D/TextureRect.modulate.g=0
			$Marker2D/TextureRect.modulate.b=0
			has_point = false
		else:
			$Marker2D/TextureRect.modulate.g=1
			$Marker2D/TextureRect.modulate.b=1
			has_point = true
			
		$Marker2D/TextureRect.visible = true
		$Marker2D.global_position = anchors[0].global_position
		
	else:
		$Marker2D/TextureRect.visible = false
		has_point = false
	
	$Control.visible = debug_ui_visible()

		
	inking(on_ink(),_delta)
		
	if not i_frames_hit.is_stopped():
		player_sprite.modulate.a = i_frame_curve.sample((i_frames_hit.time_left / i_frames_hit.wait_time)*-1+1)
		

	active_state = fsm.state
	

		
	if Input.is_action_just_pressed("attack_heavy") and has_point:
				hook_point = anchors[0].global_position
				$State_Machine.changeState("Grappling")
				
		#var found_objects = []
		#for obj in get_tree().get_nodes_in_group("Anchor"):
			#var obj_position = obj.global_position
			#if get_global_mouse_position().distance_to(obj_position) <= click_check_radius:
				#found_objects.append(obj)
		#
		#
		#if found_objects.size() == 0:
			#has_point = false
		#elif hook_range < (global_position - found_objects[0].global_position).length():
			#has_point = false
		#else:
			#hook_point = found_objects[0].global_position
			#if found_objects[0].is_in_group("Temp"):
				#found_objects[0].destroy()
				#
			#var space_state = get_world_2d().direct_space_state
			#var result = space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position,hook_point.global_position, grapple_floor_check))
			#if result.size() > 0:
				#has_point = false
			#else:
				#has_point = true
				#$Timers/hold_grapple.start()
#
#
	#if Input.is_action_pressed("attack_heavy") and not is_grappling and has_point:
		#if $Timers/hold_grapple.is_stopped():
		#$State_Machine.changeState("Grappling")
			## $State_Machine.state.finished.emit("Grappling")
			#
	#if Input.is_action_just_released("attack_heavy") and has_point:
		#if not $Timers/hold_grapple.is_stopped():
			#$State_Machine.changeState("Hooking")
			
	#einmal neu bitte:
	get_the_wall_normal()
	
	if not is_grappling:
		if Input.is_action_just_pressed("dash") and $Timers/dash_cd.is_stopped() and not weapon_socket.s_attacking:
			$Timers/dash_cd.start()
			$State_Machine.changeState("Dash")
			
		#if Input.is_action_just_pressed("jump") and on_wall and can_walljump and not on_ledge and not is_on_floor():
			#if last_wallnormal != wall_normal:
					#last_wallnormal = get_last_wall_normal()
					#$State_Machine.changeState("Walljump")
	if Input.is_action_just_pressed("pause"):
		show_pause_menu()


func show_pause_menu():
	if paused:
		$PrototypeUI/PauseMenu.hide()
		Engine.time_scale = 1
		get_tree().paused = !get_tree().paused
	else:
		$PrototypeUI/PauseMenu.show()
		$PrototypeUI/PauseMenu/Texture/PauseMenuButtons/PauseMenu/Resume.grab_focus()
		Engine.time_scale = 0.001
		get_tree().paused = !get_tree().paused
	paused = !paused

func _physics_process(delta: float) -> void:
	
	

	on_floor = $FloorCheck.is_colliding() or  $FloorCheck2.is_colliding() #or is_on_floor()
	can_climb = $Pivot/ClimbCheck.is_colliding() or $Pivot/ClimbCheck2.is_colliding()
	on_wall = ($Pivot/WallCheck_1.is_colliding() or $Pivot/WallCheck_2.is_colliding()) and not on_floor
	
	if($Pivot/WallCheck_1.is_colliding()):
		last_wallnormal =  sign($Pivot/WallCheck_1.get_collision_normal().x)
		wall_coll_pos =  $Pivot/WallCheck_1.get_collision_point()
	elif($Pivot/WallCheck_2.is_colliding()):
		last_wallnormal = sign($Pivot/WallCheck_2.get_collision_normal().x)
		wall_coll_pos =  $Pivot/WallCheck_2.get_collision_point()
		
	if pivot.scale.x < 0:
		direction = -1
	else:
		direction = 1


func _kunai_gone():
	pass
	
func recover_stamina():
	velocity.x = 0.0
	can_airjump = true
	can_walljump = true
	last_jump_normal = Vector2.ZERO
	stamina  = max_stamina
	
func update_gravity(_delta):
	velocity.y += gravity * _delta

func player_attacks(w_name : String):
	is_attacking = {"value": true, "weapon":w_name}

func player_ability(w_name : String):
	is_attacking = {"value": true, "weapon":w_name}

func set_active_weapon(weapon):
	active_weapon = weapon


func _on_weapon_socket_weapon_updated(w_name: Variant, w_icon: Variant, w_uses: Variant) -> void:
	weapon_updated.emit(w_name,w_icon,w_uses)
	pass # Replace with function body.
	
func take_damage(damage : int = 1):
	if not invincible_active:
		SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.HIT)
		took_damage.emit(current_health, clamp(current_health-damage,0,max_health))
		i_frames_hit.start()
		invincible_active = true
		current_health -=damage
		if(current_health <= 0):
			dies()
		else:
			Eventbus.emit_signal("_heavy_impact_shake",0.2,6)
			Eventbus.emit_signal("_player_hit")
			


func stop_dash():
	invincible_active = false
	player_sprite.modulate.a = 1
	

func launch_player(force: float = 1500,dir : Vector2 = Vector2.UP):
	velocity.y = 0
	launch_force = force
	launch_dir = dir
	fsm.changeState("Launching")

func impact_frame():
	pass
	#camera.start_shake(0.1, 8)  # 0.2 seconds, 8-pixel magnitude
	#get_tree().paused = true  # Pause the game
	#await get_tree().create_timer(0.1).timeout
	#get_tree().paused = false  # Resume the game


func _on_i_frames_timeout() -> void:
	player_sprite.modulate.a = 1
	invincible_active = false
	pass # Replace with function body.

func on_ink():
	return is_on_ink

func set_on_ink(value):
	is_on_ink = value

func use_ink(value):
	
	ink_current -= value
	ink_percentage = ink_current/ink_max
	change_ink_ui()
	ink_changed.emit(ink_percentage)
	
	$Timers/Show_Ink.start()
		
func inking(value,delta):
	if value:
		$Dust_Walking.emitting = false
		player_sprite.modulate = Color.DIM_GRAY
		ink_current = clamp(ink_current+ ink_gain * delta,0,ink_max)
		ink_percentage = ink_current/ink_max
		#$Timers/Show_Ink.start()
		ink_changed.emit(ink_percentage)
	else:
		player_sprite.modulate = Color.WHITE
		
	change_ink_ui()
		
func change_ink_ui():
	ink_changed.emit(ink_percentage)
	$Timers/Show_Ink.start()
	if ink_fill:
		ink_fill.size.x = ink_percentage*ink_max_bar
	#if ink_percentage > ink_max_treshold:
		#ink_fill.color.r = 1
	elif ink_percentage < ink_min_treshold:
		ink_fill.color.r = 0.5
	else:
		ink_fill.color.r = 0


func wall_jump_start():
		last_jump_normal = last_wallnormal
		velocity.y = -jump_height*wall_jump_height_multi
		velocity.x = speed*wall_jump_distance_multi*sign(last_jump_normal)
		can_walljump = false

func debug_ui_visible():
	return not $Timers/Show_Ink.is_stopped()

func has_in_inventory(item_name : String, count : int = 1) -> bool:
	return inventory.check_item(item_name, count)
	
func use_inventory_item(item:Item,needed_number)-> bool:
	if check_inventory(item) >= needed_number:
		inventory.use_item(item,needed_number)
		return true
	else:
		return false
	
func check_inventory(item:Item)-> int:
	return inventory.item_count(item)

func loot_item(item:Item):
	inventory.add_item(item)
	if item.item_type == "Weapon":
		SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.WEAPONSWAP)
		weapon_socket.set_weapon(weapon_socket.get_weapon_index(item.name))
		weapon_updated.emit(active_weapon.w_name,active_weapon.w_icon,active_weapon.get_uses_left())

	
func increase_ink(ink_amount):
	ink_current = clamp(ink_current+ink_amount,0,ink_max)
	ink_percentage = ink_current/ink_max
	change_ink_ui()


func switch_state(state_name):
	$State_Machine.changeState(state_name)


func _on_grapple_checker_body_entered(body: Node2D) -> void:
	anchors.append(body)
	if anchors.size()>1:
		var index
		var temp
		var shortest_distance = INF
		for i in range(anchors.size()):
			if (anchors[i].global_position-global_position).length()<shortest_distance:
				shortest_distance = (anchors[i].global_position-global_position).length()
				temp = anchors[i]
		anchors.erase(temp)
		anchors.insert(0,temp)
				
		
				
	pass # Replace with function body.

#func _input(event: InputEvent) -> void:
	#if Input.is_action_pressed("ui_accept"):
		#Global.respawn_all_enemies()
		
		
		
func _on_grapple_checker_body_exited(body: Node2D) -> void:
	anchors.erase(body)
	pass # Replace with function body.

func push_out_of_ground():
	if $Inside_Check_S.is_colliding():
		global_position.y -= 40
		
	if $Inside_Check_N.is_colliding():
		global_position.y += 40
		
	

func respawn():
	global_position = spawn_point
	print(spawn_point)
	

func get_the_wall_normal():
	pass

func get_can_grab():
	return can_grab
	
func set_can_grab(value):
	if grab_ready and value and not $Pivot/ClimbCheck.is_colliding():
		$LedgeGrab.set_deferred("disabled",!value)
		can_grab = value
	elif not value:
		$LedgeGrab.set_deferred("disabled",!value)
		can_grab = value
	
func jump_correction():
	if not $Corner_Checks/Corner_Slide.is_colliding():
		if not ($Corner_Checks/Corner_SlideL.is_colliding() and $Corner_Checks/Corner_SlideR.is_colliding()):
			if $Corner_Checks/Corner_SlideL.is_colliding():
				global_position.x +=25
			elif $Corner_Checks/Corner_SlideR.is_colliding():
				global_position.x -=25

func dies():
	
	if not dying and $Timers/respawn.is_stopped():
		
		dying =  true
		player_dead.emit()
		Eventbus.emit_signal("_player_shrine")
		$State_Machine/AnimationTree.active = false
		$AnimationPlayer.play("Dying")
		self.process_mode = Node.PROCESS_MODE_DISABLED  # Freeze the node

func jump_fx():
	
	#var fx =  jump_cloud_vfx.instantiate()
	#fx.global_position = $Marker2D2.global_position
	#get_tree().get_root().add_child(fx)
	
	var fx =  jump_trail_vfx.instantiate()
	fx.process_material.set("direction",velocity.normalized())
	fx.global_position = $Marker2D2.global_position
	get_tree().get_root().add_child(fx)


func change_camera_region_enter(pos: Vector2,block_pan:bool, both : bool):
	camera_controls.pan_camera_overwrite(pos,block_pan,both)
	
func change_camera_region_enter_v(pos: Vector2,block_pan:bool, both : bool):
	camera_controls.pan_camera_overwrite_v(pos,block_pan,both)

func change_camera_region_exit():
	camera_controls.pan_camera_overwrite_exit()
	
func change_camera_region(pos: Vector2,block_pan:bool, both : bool):
	camera_controls.pan_camera_overwrite(pos,block_pan,both)

func buff_player(type):
	
	if type == 0:
		ink_max += 25
		pass
	elif type == 1:
		max_health +=1
		current_health = max_health
		took_damage.emit(current_health, current_health)
		pass
	elif type == 2:
		$Timers/attack_cd.wait_time -= 0.05

		pass
		
func play_foot_steps():
	if on_ink():
		SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.INKSTEP)
	else:
		if Global.tufan_sounds:
			SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.WALK)
		else:
			SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.STEP)

func heal():
	current_health = max_health
	took_damage.emit(current_health, current_health)
	$Pivot/HeilungKuma.heal_fx()


func on_death():
	
		var bag = coinbag.instantiate()
		if Global.coins%2 != 0:
			bag.coins +=1
			Global.coins -=1
		bag.coins += Global.coins/2
		Global.coins /= 2
		bag.global_position = save_bag_pos
		bag.linear_velocity.y = -400
		get_tree().root.call_deferred("add_child",bag)
		global_position = Global.last_checkpoint
		current_health = max_health
		await get_tree().create_timer(0.2).timeout
		$State_Machine/AnimationTree.active = true
		$Timers/respawn.start()
		self.process_mode = Node.PROCESS_MODE_INHERIT
		dying = false


func play_pop():
	SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.POP)
	pass

func disable():
	self.process_mode = Node.PROCESS_MODE_DISABLED

func enable():
	self.process_mode = Node.PROCESS_MODE_INHERIT
