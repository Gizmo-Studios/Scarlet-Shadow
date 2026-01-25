extends CanvasLayer
var keyboard = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("float_in")
	var file = FileAccess.open("user://savegame.save",FileAccess.READ)
	if file == null || file.get_length() == 0:
		$MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/Continue.disabled = true
		$MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/NewGame.grab_focus()
	else:
		$MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/Continue.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		keyboard = true
	if event is InputEventJoypadMotion || event is InputEventJoypadButton:
		if keyboard == true:
			if $Control.visible:
				$Control/Return.grab_focus()
			elif $MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/Continue.disabled == false:
				$MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/Continue.grab_focus()
			else:
				$MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/NewGame.grab_focus()
			keyboard = false

#MainMenu
func _on_continue_pressed() -> void:
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/UI/loadingscreen.tscn")
	#Load safe File

func _on_new_game_pressed() -> void:
	var file = FileAccess.open("user://savegame.save",FileAccess.READ)
	if file == null:
		Engine.time_scale = 1
		get_tree().change_scene_to_file("res://Scenes/UI/loadingscreen.tscn")
		SaveAndLoad.delete_game()
	elif file.get_length() == 0:
		Engine.time_scale = 1
		get_tree().change_scene_to_file("res://Scenes/UI/loadingscreen.tscn")
		SaveAndLoad.delete_game()
	else:
		$MainTitleUI/HBoxContainer.show()
		$MainTitleUI/MainTitleUI.hide()
		$MainTitleUI/HBoxContainer/Return.grab_focus()





func _on_settings_pressed() -> void:
	var canvas_layer = load("res://Scenes/UI/UIChristopher.tscn").instantiate()
	$".".add_child(canvas_layer)
	$PrototypeUI/PlayerHUD.hide()
	$PrototypeUI/PauseMenu.hide()
	$PrototypeUI/SettingsUI2.show()
	$PrototypeUI/SettingsUI2/ColorRect.hide()
	$PrototypeUI/SettingsUI2/SettingsMenu/SettingsMenu/SettnigsMenu/Video.grab_focus()
	$MainTitleUI/MainTitleUI.hide()
	$MainTitleUI/CreditsButton.hide()

func _on_exit_pressed() -> void:
	get_tree().quit()#quit game


func _on_return_pressed() -> void:
	$MainTitleUI/HBoxContainer.hide()
	$MainTitleUI/MainTitleUI.show()
	$MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/NewGame.grab_focus()


func _on_yes_pressed() -> void:
	Engine.time_scale = 1
	#SaveAndLoad.delete_game()
	SaveAndLoad.delete_game()
	get_tree().change_scene_to_file("res://Scenes/UI/loadingscreen.tscn")
	Engine.time_scale = 1


func _on_credits_button_pressed() -> void:
	$Control.show()
	$MainTitleUI.hide()
	$Control/Return.grab_focus()
	$AnimationPlayer.play("Credits_float_in")

func _on_return_credits_pressed() -> void:
	$AnimationPlayer.play("Titel_float_in")
	$Control.hide()
	$MainTitleUI.show()
	if $MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/Continue.disabled == false:
		$MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/Continue.grab_focus()
	else:
		$MainTitleUI/MainTitleUI/MarginContainer/VBoxContainer/NewGame.grab_focus()




#External Links
func _on_logo_pressed() -> void:
	OS.shell_open("https://s4g.itch.io/scarlet-shadow")

func _on_christopher_pressed() -> void:
	OS.shell_open("https://www.linkedin.com/in/christopher-tietz-826951337/")

func _on_aljoscha_pressed() -> void:
	OS.shell_open("https://www.artstation.com/aljoschafaryn6")

func _on_carol_pressed() -> void:
	OS.shell_open("https://www.artstation.com/bubbles_73")

func _on_malik_pressed() -> void:
	OS.shell_open("https://www.artstation.com/wolfipixel")

func _on_leonie_pressed() -> void:
	OS.shell_open("https://www.artstation.com/shogun_787")

func _on_denis_pressed() -> void:
	OS.shell_open("https://www.artstation.com/denis_3d")

func _on_norbert_pressed() -> void:
	OS.shell_open("https://www.youtube.com/watch?v=xvFZjo5PgG0")

func _on_tufan_pressed() -> void:
	OS.shell_open("https://s4g.itch.io/scarlet-shadow")
