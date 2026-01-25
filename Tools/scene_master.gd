@tool
extends Node2D

@export_enum("X", "A", "B", "C","D","E") var zone: String = "X":
	set(value):
		zone = value
		update_shape_color()
		
@export var scene : String:
	set(value):
		scene = value
		update_shape_color()

@export var entry_launch_force = 0.0:
	set(value):
		entry_launch_force = value
		
var launch_dir = Vector2.ZERO


const COLOR_MAP := {
	"X": Color.RED,
	"A": Color.GREEN,
	"B": Color.ORANGE,
	"C": Color.DEEP_PINK,
	"D": Color.GOLD,
	"E": Color.PURPLE,
}


@onready var launch_Point: Marker2D = $EntryPoint/Launch_Point
@onready var entry_point: Marker2D = $EntryPoint
@onready var activate_area: Timer = $Activate_Area

func update_shape_color():
	var collision_shape: CollisionShape2D = $Zone/CollisionShape2D
	if scene:
		collision_shape.debug_color = COLOR_MAP.get(zone, Color.WHITE)
	else:
		collision_shape.debug_color = COLOR_MAP.get( Color.WHITE, Color.WHITE)
	self.name = "Zone_Portal_"+ str(zone)
	add_to_group("Zone_Portal_" + str(zone))
	for group in get_groups():
		if group != "Zone_Portal_" + str(zone):
			remove_from_group(group)
	notify_property_list_changed() 

func _ready() -> void:
	launch_dir = (launch_Point.global_position-entry_point.global_position).normalized()
	if not Engine.is_editor_hint():
		var collision_shape: CollisionShape2D = $Zone/CollisionShape2D
		collision_shape.disabled = true
		activate_area.start()
		$EntryPoint/TextureRect.visible = false
	
func _process(delta: float) -> void:
	pass

func on_Zone_Exit(body: Node2D) -> void:
	Eventbus.emit_signal("_zone_changed",scene,"Zone_Portal_" + str(zone))
	pass # Replace with function body.


func _on_activate_area_timeout() -> void:
	$Zone/CollisionShape2D.disabled = false
