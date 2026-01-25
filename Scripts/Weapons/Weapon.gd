extends Node2D

class_name Weapon

@export var w_name : String
@export var w_icon : Texture2D
@export var w_max_uses : int
@export var w_uses_left : int
@export var ink_cost : float

var player: Player

func _setup(_name:String,_icon:Texture2D,_uses:int):
	w_name = _name
	w_icon = _icon
	w_max_uses = _uses
	w_uses_left = w_max_uses 
	
	
func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null)
	_enter()

func _enter():
	pass
func _process(delta: float) -> void:
	pass
func attack():
	player.player_attacks(w_name)
	pass

func ability():
	player.player_ability(w_name)
	pass

func get_uses_left(item : Item = null):
	return w_uses_left
