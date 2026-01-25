extends Node2D
signal weapon_updated(w_name,w_icon,w_uses)


@export var weapons: = []

var current_weapon = 0
var active_weapon
@onready var weapon_swap_cd: Timer = $"../../Timers/Weapon_swap_cd"
var player: Player
var s_attacking = false
var k_attacking = false
var attack_dir = "forward"
var s_attack_press_time = 0
var k_attack_press_time = 0
var stored_velocity
var controller = false
func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null)
	
	for Weapon in get_children():
		weapons.append(Weapon)
	active_weapon = $Kunai
	player.active_weapon = 	active_weapon
	weapon_update()

func _process(delta: float) -> void:
	if Input.is_action_pressed("down")and not s_attacking:
		rotation_degrees = 90
		attack_dir = "down"
		$Sword/Sword_Slash.position.y = 70
		$Sword/Sword_Slash.position.x = 0
		$Sword/Area2D.position.y = 35
		$Sword/Area2D.position.x = 0
	elif Input.is_action_pressed("up")and not s_attacking:
		rotation_degrees = -90
		scale = Vector2(1,-1)
		attack_dir = "up"
		$Sword/Sword_Slash.position.y = 70
		$Sword/Sword_Slash.position.x = 70
		$Sword/Area2D.position.y = 35
		$Sword/Area2D.position.x = 70
	elif not s_attacking:
		rotation_degrees = 0
		attack_dir = "forward"
		scale = Vector2(1,1)
		$Sword/Sword_Slash.position.y = 0
		$Sword/Sword_Slash.position.x = 0
		$Sword/Area2D.position.y = 0
		$Sword/Area2D.position.x = 0
		#if (player.active_state.can_attack 
	#and not s_attacking 
	#and not k_attacking):
	#if true:
		#if Input.is_action_just_released("attack_light") and $"../../Timers/attack_cd".is_stopped() and player.active_state.can_attack:
			#$"../../State_Machine/AnimationTree".active = true
			#if s_attack_press_time < 0.5:
				#Eventbus.emit_signal("_heavy_impact_shake",0.2,3)
				#$Sword.attack()
				#s_attacking = true
				#s_attack_press_time = 0
				#$"../vfx".visible = false
			#
			#else:
				#$"../vfx".visible = false
				#s_attack_press_time = 0
			#
		#elif Input.is_action_just_released("attack_light"):
			#$"../../State_Machine/AnimationTree".active = true
			#s_attack_press_time = 0
			#s_attacking = false
		#
		#if Input.is_action_just_pressed("attack_light"):
			#stored_velocity = player.velocity
		##if Input.is_action_just_released("attack_light"):
			##player.velocity = stored_velocity
			#
		#if (Input.is_action_pressed("attack_light") 
		#and $"../../Timers/attack_cd".is_stopped() 
		#and not k_attacking 
		#and s_attack_press_time<0.5
		#and player.active_state.can_attack):
			#s_attacking = true
			#s_attack_press_time += delta
			#if s_attack_press_time > 0.2:
				#player.velocity = Vector2.ZERO
				#$"../../State_Machine/AnimationTree".active = false
				#$"../../AnimationPlayer".play("Stance")
				#$"../vfx".visible = true
				#pass #DoSomething
			#if s_attack_press_time >= 0.5:
				#player.velocity = Vector2(stored_velocity.x,0)
				#$"../../Timers/press_event_cd".start()
				#if player.ink_current >= $Sword.ink_cost :
					#$Sword.ability()
					#$"../vfx".visible = false
					#
				#elif player.ink_current < $Sword.ink_cost :
					#SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.CANTPRESS)
					#Eventbus.emit_signal("_not_enough_ink")
					#$"../vfx".visible = false
					#$"../../State_Machine/AnimationTree".active = true
					#s_attacking = false
		#elif Input.is_action_pressed("attack_light") and not k_attacking:
			#$"../vfx".visible = false
			#$"../../State_Machine/AnimationTree".active = true
			#s_attacking = false
#
#
##----- ICH WEINE IN DESIGN CHANGES -----#
#
		#if (Input.is_action_just_released("ability") 
		#and $"../../Timers/attack_cd".is_stopped() 
		#and  player.active_state.can_attack):
			#if k_attack_press_time < 0.5 and k_attack_press_time >0:
				#k_attacking = true
				#Eventbus.emit_signal("_heavy_impact_shake",0.2,2)
				#active_weapon.attack()
				#$"../vfx".visible = false
				#k_attack_press_time = 0
			#else:
				#$"../vfx".visible = false
				#k_attack_press_time = 0
				#k_attacking = false
		#
		#elif Input.is_action_just_released("attack_light"):
			#$"../../State_Machine/AnimationTree".active = true
			#k_attack_press_time = 0
			#k_attacking = false
		#
#
		#if Input.is_action_just_pressed("ability"):
			#stored_velocity = player.velocity
		##if Input.is_action_just_released("ability"):
			##stored_velocity = player.velocity
		#if (Input.is_action_pressed("ability") 
		#and $"../../Timers/attack_cd".is_stopped() 
		#and not s_attacking
		#and k_attack_press_time<0.5
		#and player.active_state.can_attack
		#and get_items_left($Kunai.kunai_item)>0):
			#
			#k_attack_press_time += delta
			#k_attacking = true
			#
			#if k_attack_press_time > 0.2:
				#
				#player.velocity = Vector2.ZERO
				#$"../vfx".visible = true
				#player.velocity.y = 0
				#pass #DoSomething
			#if k_attack_press_time >= 0.5:
				#player.velocity = Vector2(stored_velocity.x,0)
				#if player.ink_current >= active_weapon.ink_cost and get_items_left($Kunai.kunai_item)>0:
					#k_attacking = true
					#active_weapon.ability()
					##k_attack_press_time = 0
					#$"../vfx".visible = false
					#
				#else:
					#SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.CANTPRESS)
					#Eventbus.emit_signal("_not_enough_ink")
					#$"../vfx".visible = false
					#k_attacking = false
		#elif Input.is_action_pressed("ability") and not s_attacking:
			#$"../vfx".visible = false
			#$"../../State_Machine/AnimationTree".active = true
			#k_attacking = false


	if $"../../Timers/attack_cd".is_stopped() and player.active_state.can_attack and not s_attacking:
		if Input.is_action_just_pressed("attack_light"):
			$Sword.attack()
			Eventbus.emit_signal("_heavy_impact_shake",0.2,3)


		if Input.is_action_just_pressed("kunai_attack") and get_items_left($Kunai.kunai_item)>0:
			Eventbus.emit_signal("_heavy_impact_shake",0.2,2)
			$Kunai.attack()


		if Input.is_action_just_pressed("sword_abi"):
			if player.ink_current >= $Sword.ink_cost:
				Eventbus.emit_signal("_heavy_impact_shake",0.2,2)
				$Sword.ability()
			else:
				Eventbus.emit_signal("_not_enough_ink")
				SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.CANTPRESS)


		if Input.is_action_just_pressed("kunai_abi") and get_items_left($Kunai.kunai_item)>0:
			if player.ink_current >= $Kunai.ink_cost:
				$Kunai.ability()
			else:
				Eventbus.emit_signal("_not_enough_ink")
				SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.CANTPRESS)



func switch_weapon(dir : int):
	weapon_swap_cd.start()
	if current_weapon + dir > weapons.size()-1:
		current_weapon = (current_weapon+dir)%weapons.size()
		
	elif (current_weapon+dir)<0:
		print("weapon" + str( weapons.size()-1))
		current_weapon = weapons.size()-1
	else:
		current_weapon+=dir
		
	set_weapon(current_weapon)

func weapon_update():
	weapon_updated.emit(active_weapon.w_name,active_weapon.w_icon,active_weapon.get_uses_left())


func use_item(item:Item,needed_number := 1)-> bool:
	
	if player.use_inventory_item(item,needed_number):
		active_weapon.w_uses_left = get_items_left(item)
		return true
	return false

func get_items_left(item :Item):
	return player.check_inventory(item)

func launch_player(launch_force = null, dire = null):
	if launch_force != null:
		player.launch_player(launch_force)

func set_weapon(index):
	active_weapon = $Kunai
	player.set_active_weapon(active_weapon)
	active_weapon.check_uses_left()
	weapon_updated.emit(active_weapon.w_name,active_weapon.w_icon,active_weapon.get_uses_left())

func get_weapon_index(w_name):
	var index = 0
	for i in range(weapons.size()):
		if weapons[i].w_name == w_name:
			index  = i
	return index

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		print("controller")
		controller = true
		Global.controller_index = event.device
	elif event is InputEventKey:
		print("mouse")
		controller = false
	pass
	
