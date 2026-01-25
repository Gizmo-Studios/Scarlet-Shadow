extends CanvasLayer

@onready var player =  $".."#ref the player tree
@onready var input_button_scene = preload("res://Scenes/UI/input_Buttons.tscn")
@onready var action_list_keyboard = $SettingsUI2/ControllSettings/Keyboard/Keyboard/ScrollContainer/Keyboard
@onready var action_list_controller = $SettingsUI2/ControllSettings/Controller/Controller/ScrollContainer/Controller


@export var heart_grey_texture: Texture2D
@export var heart_texture: Texture2D # Das Icon für ein volles Herz
@onready var heart_container = $PlayerHUD/Health_Ink/VBoxContainer/Healthbar # Der HBoxContainer oder GridContainer

var keyboard = false
var is_remapping = false
var action_to_remap = null
var remapping_button = null
var previous_event = null
var coins = 0

var input_actions = {
	"left": "Move left",
	"right": "Move right",
	"up": "Look up",
	"down": "Look down",
	"dash": "Dash",
	"jump": "Jump",
	"attack_light": "Sword Attack",
	"kunai_attack": "Kunai Attack",
	"sword_abi": "Sword Ability",
	"kunai_abi": "Kunai Ability",
	"attack_heavy": "Grapling hook",
	"interact": "Interact",
}

func _ready() -> void:
	load_key_bindings_from_settings()
	create_action_list()
	print(coins)
	var video_settings = ConfigFileHandle.load_video_settings()
	
	var audio_settings = ConfigFileHandle.load_audio_settings()
	$SettingsUI2/AudioSettings/Audio/Audio/MasterVolume/HSlider.value = min(audio_settings.master_volume, -5)
	print($SettingsUI2/AudioSettings/Audio/Audio/MasterVolume/HSlider.value)
	Eventbus.connect("_player_shrine", heal)
	Eventbus.connect("_not_enough_ink", flash_ink)
	

func load_key_bindings_from_settings():
	var keybindings = ConfigFileHandle.load_keybindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])
	
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().current_scene.scene_file_path == "res://Scenes/UI/main_title.tscn":
			return
		elif Engine.time_scale == 0:
			player.show_pause_menu()
		else:
			pass
			
	$PlayerHUD/MarginContainer3/VBoxContainer/Label.text = str(Global.coins)
	coins = Global.coins



func _on_kuma_took_damage(old_health: int, new_health: int) -> void:#stupid way to hide the icons on HP loss
	health_update(new_health)
	for i in range(player.max_health - new_health):
		var heart = TextureRect.new()
		heart.texture = heart_grey_texture
		heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		heart_container.add_child(heart)

func _on_kuma_player_dead() -> void:#activate all five heart pictures again
	heal()

func heal():
	for child in heart_container.get_children():
		
		child.queue_free()
	
	for i in range(player.max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		heart_container.add_child(heart)

func health_update(new_health: int = 1):
	# Entferne alte Herzen
	for child in heart_container.get_children():
		child.queue_free()
	
	# Erstelle neue Herzen basierend auf der aktuellen HP
	for i in range(new_health):
		
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		heart.visible = true
		heart_container.add_child(heart)



func _on_kuma_ink_changed(ink_percentage: Variant) -> void:#cringe way to show the inkbar based on player signal
	var ink_value = ink_percentage * 200#get numbers between 1 and 200
	var ink_value_int = int(ink_value)#can only use integer i think, not sure might not be necessary
	$PlayerHUD/Health_Ink/VBoxContainer/Control2/ProgressBar.value = ink_value_int


func _on_kuma_weapon_updated(w_name: Variant, w_icon: Variant, w_uses: Variant) -> void:#cringe way to show the right icons based on player signal
	if w_name == "Kunai" && w_uses > -1:
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/KunaiIcon.visible = true
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/KunaiAmmunition.visible = true
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/KunaiAmmunition.text =str(w_uses)
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/KatanaIcon.visible = false
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/Katana.visible = false
	elif w_name == "Sword":
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/KunaiIcon.visible = false
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/KunaiAmmunition.visible = false
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/Katana.text =str("∞")
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/KatanaIcon.visible = true
		$PlayerHUD/NinePatchRect/MarginContainer/VBoxContainer/Katana.visible = true

func no_UI_shown():
	$SettingsUI2.hide()
	$PauseMenu.hide()
	$SettingsUI2/VideoSettings.hide()
	$SettingsUI2/ControllSettings.hide()
	$SettingsUI2/AudioSettings.hide()


#PauseMenu
func _on_resume_pressed() -> void:
	player.show_pause_menu()

func _on_load_pressed() -> void:
	Engine.time_scale = 1
	player.show_pause_menu()
	player.dies()

func _on_settings_pressed() -> void:
	$PauseMenu.hide()
	$SettingsUI2.show()
	$SettingsUI2/SettingsMenu/SettingsMenu/SettnigsMenu/Video.grab_focus()

func _on_quit_pressed() -> void:
	player.show_pause_menu()
	get_tree().change_scene_to_file("res://Scenes/UI/main_title.tscn")


#SettingsMenu
func _on_video_pressed() -> void:
	$SettingsUI2/VideoSettings.show()
	$SettingsUI2/ControllSettings.hide()
	$SettingsUI2/AudioSettings.hide()

	$SettingsUI2/VideoSettings/Video/VideoSettings/Resolution/ResolutionButton.grab_focus()

func _on_audio_pressed() -> void:
	$SettingsUI2/VideoSettings.hide()
	$SettingsUI2/ControllSettings.hide()
	$SettingsUI2/AudioSettings.show()
	$SettingsUI2/AudioSettings/Audio/Audio/MasterVolume/HSlider.grab_focus()

func _on_controlls_pressed() -> void:
	$SettingsUI2/VideoSettings.hide()
	$SettingsUI2/ControllSettings.show()
	$SettingsUI2/AudioSettings.hide()
	$SettingsUI2/ControllSettings/Keyboard/HBoxContainer/ResetButton.grab_focus()

func _on_exit_pressed() -> void:
	if get_tree().current_scene.scene_file_path == "res://Scenes/UI/main_title.tscn":
		get_tree().change_scene_to_file("res://Scenes/UI/main_title.tscn")
	else:
		$SettingsUI2.hide()
		$SettingsUI2/VideoSettings.hide()
		$SettingsUI2/ControllSettings.hide()
		$SettingsUI2/AudioSettings.hide()
		$PauseMenu.show()
		$PauseMenu/Texture/PauseMenuButtons/PauseMenu/Resume.grab_focus()


#VideoSettings
func _on_resolution_button_item_selected(index: int) -> void:
	match index:
		4:
			DisplayServer.window_set_size(Vector2i(1280,720))
		3:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(2560,1440))
		0:
			DisplayServer.window_set_size(Vector2i(3840,2160))

func _on_window_mode_button_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

#AudioSettings
func _on_h_slider_value_changed(value: float) -> void:
	print($SettingsUI2/AudioSettings/Audio/Audio/MasterVolume/HSlider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	ConfigFileHandle.save_audio_settings("Master", $SettingsUI2/AudioSettings/Audio/Audio/MasterVolume/HSlider.value)



#Input Map
func create_action_list():
	for item in action_list_keyboard.get_children():
		item.queue_free()
	
	for action in input_actions:
		var Keyboard = input_button_scene.instantiate()
		var action_label = Keyboard.find_child("Action")
		var input_button = Keyboard.find_child("Button")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_button.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_button.text= ""
		action_list_keyboard.add_child(Keyboard)
		input_button.pressed.connect(_on_input_button_pressed.bind(Keyboard, action))

func _on_input_button_pressed(Keyboard, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = Keyboard
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			previous_event = events[0]
		else:
			previous_event = null
		Keyboard.find_child("Button").text = "Press Key to bind..."


func _input(event):
	if Input.is_action_pressed("pause"):
		var timer = player.find_child("attack_cd")
		if player.max_health > 3:
			$PauseMenu/Upgrades/VBoxContainer/MarginContainer2/VBoxContainer/Label2.text = str("+",player.max_health - 3)
		if player.ink_max > 200:
			$PauseMenu/Upgrades/VBoxContainer/MarginContainer/VBoxContainer/Label2.text = str("+",player.ink_max - 200)
		if timer.wait_time == 0.3:
			var attackspeed = (1.0/0.3 - 1.0/0.35) / (1.0/0.35) *100
			$PauseMenu/Upgrades/VBoxContainer/MarginContainer4/VBoxContainer/Label2.text = str(snappedf(attackspeed,0.01),"%")
		if timer.wait_time == 0.25:
			var attackspeed = (1.0/0.25 - 1.0/0.35) / (1.0/0.35) *100
			$PauseMenu/Upgrades/VBoxContainer/MarginContainer4/VBoxContainer/Label2.text = str(snappedf(attackspeed,0.01),"%")
	if event is InputEventMouseButton:
		keyboard = true
	if event is InputEventJoypadMotion || event is InputEventJoypadButton:
		if keyboard == true:
			if $PauseMenu.visible:
				$PauseMenu/Texture/PauseMenuButtons/PauseMenu/Resume.grab_focus()
				keyboard = false
			elif $SettingsUI2.visible:
				$SettingsUI2/SettingsMenu/SettingsMenu/SettnigsMenu/Video.grab_focus()
	if is_remapping:
		if event.is_action_pressed("pause"):
			InputMap.action_erase_events(action_to_remap)
			if previous_event:
				InputMap.action_add_event(action_to_remap, previous_event)
			_update_action_list(remapping_button, previous_event)
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			previous_event = null
			return
			
		if event is InputEventKey || event is InputEventMouseButton:
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
					
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			ConfigFileHandle.save_keybinding(action_to_remap, event)
			_update_action_list(remapping_button, event)
		
			is_remapping = false
			action_to_remap = null
			remapping_button  = null
		
			get_viewport().set_input_as_handled()



func _update_action_list(Keyboard, event):
	Keyboard.find_child("Button").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	for action in input_actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			ConfigFileHandle.save_keybinding(action, events[0])
	create_action_list()

func flash_ink():
	var tween = create_tween()
	tween.tween_property($PlayerHUD/Health_Ink/VBoxContainer/Control2/ProgressBar, "modulate", Color(1,0,0,1), 0.3)
	tween.tween_property($PlayerHUD/Health_Ink/VBoxContainer/Control2/ProgressBar, "modulate", Color(1,1,1,1), 0.3)

func flash_ammo():
	var tween = create_tween()
	tween.tween_property($PlayerHUD/Health_Ink/VBoxContainer/Control2/ProgressBar, "modulate", Color(1,0,0,1), 0.3)
	tween.tween_property($PlayerHUD/Health_Ink/VBoxContainer/Control2/ProgressBar, "modulate", Color(1,1,1,1), 0.3)

func _on_menu_button_item_selected(index: int) -> void:
	if index == 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	elif index == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
