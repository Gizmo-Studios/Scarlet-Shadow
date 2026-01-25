extends PlayerState

@export var DASH_DURATION := 0.2
@export var DASH_SPEED := 400.0
@export var speed_curve : Curve
@onready var dash_timer : Timer = $"../../Timers/dash_timer"
@onready var dash_fx: Node2D = $Dash_FX

func _ready() -> void:
	super._ready()
	dash_timer.wait_time = DASH_DURATION


func enter(previous_state_path: String, data := {}) -> void:
	$"../AnimationTree".active = false
	$"../../AnimationPlayer".play("Dash_Start")
	SoundsManager.create_2d_audio_at_location(player.global_position,SoundEffectSettings.SOUND_EFFECT_TYPE.DASHING)
	dash_timer.start()
	player.velocity=  Vector2.ZERO
	$"../../Timers/IFrames".stop()
	player.invincible_active = true
	dash_fx.dash_start(player.direction)


func physics_update(_delta: float) -> void:
	var progress = (((dash_timer.time_left/ DASH_DURATION)*-1)+1)
	player.velocity.x += speed_curve.sample(progress)*DASH_SPEED*player.direction
	player.move_and_slide()
	
	if $"../../Timers/dash_timer".is_stopped():
		if not player.is_on_floor():
			finished.emit(FALLING)
		else:
			finished.emit(IDLE)

func exit():
	dash_fx.dash_end()
	$"../../AnimationPlayer".play("Dash_End")
	player.stop_dash()
	
