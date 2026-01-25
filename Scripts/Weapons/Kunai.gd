extends Weapon

@export var kunai_proj : PackedScene
@export var kunai_abi_proj : PackedScene
@export var kunai_item : Item
@export var kunai_max_distance : float
@onready var weapon_socket: Node2D = $".."


	
func attack():
	super.attack()
	if weapon_socket.use_item(kunai_item):
		var dir = $Aim/Sprite2D.global_position-global_position
		var kunai = kunai_proj.instantiate()
		get_tree().get_root().add_child(kunai)
		kunai.linear_velocity = kunai.linear_velocity * dir.normalized()
		kunai.rotation = dir.normalized().angle()
		kunai.global_position = global_position
		$"..".weapon_update()
		weapon_socket.s_attacking = false
		SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.THROW)
		$"../../throw_fx".play_vfx()
	$"../../../Timers/attack_cd".start()
	weapon_socket.s_attacking = false



func ability():
	super.ability()
	if weapon_socket.use_item(kunai_item):
		player.use_ink(ink_cost)
		var dir = $Aim/Sprite2D.global_position-global_position
		var kunai = kunai_abi_proj.instantiate()
		get_tree().get_root().add_child(kunai)
		kunai.linear_velocity = kunai.linear_velocity * dir.normalized()
		kunai.rotation = dir.normalized().angle()
		kunai.global_position = global_position
		kunai.connect("stopped_moving",hook_to_kunai)
		$"..".weapon_update()
		weapon_socket.s_attacking = false
		SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.THROW)
		$"../../throw_fx".play_vfx()
	$"../../../Timers/attack_cd".start()
	weapon_socket.s_attacking = false


func get_uses_left(item = kunai_item):
	return weapon_socket.get_items_left(item)

func hook_to_kunai(kunai_pos):
	player.hook_point = kunai_pos
	player.switch_state("Hooking")

func check_uses_left():
	w_uses_left = weapon_socket.get_items_left(kunai_item)
	pass
