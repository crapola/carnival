class_name TargetContainer
extends Node2D

## Target Container
##
## Base class for the [Belt] and the [Wheel].

## Emitted when a target is exiting the scene tree.
signal target_exiting_tree(target:Target)

## Speed at which targets move, in pixels or radians per seconds.
@export var speed:float=100

func _notification(what:int)->void:
	if what==NOTIFICATION_EXIT_TREE:
		var cnx:=target_exiting_tree.get_connections()
		print(cnx)

## Return true if there are no targets left.
func cleared()->bool:
	assert(false)
	return false

## Slow to an halt over [param time] seconds with tweening.
func stop(time:float=1.0)->void:
	var t:=create_tween()
	t.set_trans(Tween.TRANS_ELASTIC)
	t.tween_property(self,"speed",0,time)

func _add_target(parent:Node2D,target:Target)->void:
	parent.add_child(target)
	target.tree_exiting.connect(func()->void:
		target_exiting_tree.emit(target))
