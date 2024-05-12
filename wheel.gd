class_name Wheel
extends TargetContainer

## Wheel
##
## Spinning wheel of flags.

## Root node of flag targets.
@onready var flags:Node2D=$Flags as Node2D

func _ready()->void:
	_create_flags()

func _physics_process(delta:float)->void:
	rotate(delta*speed)

## See [method TargetContainer.cleared].
func cleared()->bool:
	return flags.get_child_count()==0 or ( flags.get_child_count()==1 and flags.get_child(0).is_queued_for_deletion()==true )

func _create_flags()->void:
	for i in 8:
		var flag:=preload("res://targets/flag.tscn").instantiate() as Target
		var r:float=45*i
		flag.rotation_degrees+=r
		flag.position=Vector2.from_angle(deg_to_rad(r))*32.0
		_add_target(flags,flag)
