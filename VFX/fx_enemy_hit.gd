extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_vfx(pos):
	
	var dir = Vector2.UP
	$GPUParticles2D.process_material.set_direction(Vector3(dir.x,-abs(dir.y),0))
	
	$Ink_Splash.restart()
	
	$GPUParticles2D.restart()
	$GPUParticles2D.emitting = true
	
	$GPUParticles2D2.restart()
	$GPUParticles2D2.emitting = true
	
	$Ring.restart()
	$Ring.emitting = true
	
	SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.WOLF_DAMAGE)
	SoundsManager.create_2d_audio_at_location(global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.INK_SPLASH_01)


func _on_ink_splash_finished() -> void:
	queue_free()
	pass # Replace with function body.
