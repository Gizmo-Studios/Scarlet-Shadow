extends CanvasLayer

@export var player : Player
@onready var ink_fill: ColorRect = $Control/ink_fill
var ink_max
var ink_current
@onready var ink_fill2: ColorRect = $Control/ink_fill/ink_fill2

func _ready() -> void:
	ink_max = ink_fill.size.x
	ink_current = 1
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_kuma_weapon_updated(w_name: Variant, w_icon: Variant, w_uses: Variant) -> void:
	$VBoxContainer/TextureRect.texture = w_icon
	$VBoxContainer/Label.text = w_name
	if w_uses == -1:
		w_uses ="∞"

	$VBoxContainer/Label2.text = "Uses: " + str(w_uses)
	pass # Replace with function body.


func _on_kuma_ink_changed(ink_percentage: Variant) -> void:
	if ink_fill:
		ink_fill.size.x = ink_percentage*ink_max
	if ink_percentage > 0.8:
		ink_fill2.color.r = remap(ink_percentage,0.8,1,0,1)
		
	else:
		ink_fill2.color.r = 0
	
