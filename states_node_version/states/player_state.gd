# Boilerplate class to get full autocompletion and type checks for the `player` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name PlayerState extends State

const IDLE = "Idle"
const RUNNING = "Running"
const JUMPING = "Jumping"
const FALLING = "Falling"
const DASH = "Dash"
const CLIMBING = "Climbing"
const WALLJUMP = "Walljump"
const AIRJUMP = "Airjump"
const GRAPPLE = "Grappling"
const HOOK = "Hooking"
const LAUNCH = "Launching"
const GRAB = "LedgeGrapping"


var player: Player
@export var can_attack : bool = true


func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null)
