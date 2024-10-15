class_name Target
extends Sprite2D

## Target
##
## Something the player can shoot.

## Ammo given.
@export var ammo:int=0
## Points given.
@export var points:int=1
## Bonus letter, if any.
@export var letter:Label
## Explosion scene.
@export var explosion:PackedScene=preload("res://explosion.tscn")

func _exit_tree()->void:
	if is_blocking_signals():
		return
	if explosion:
		var e:Node2D=explosion.instantiate() as Node2D
		if e.top_level:
			e.global_transform=global_transform
			get_tree().get_root().add_child(e)
		else:
			e.transform=transform
			get_parent().add_child.call_deferred(e)

## Set difficulty.
func apply_rank(_rank:float)->void:
	pass

## Instance a random animal target.
static func instance_random()->Target:
	# TODO: Using preload causes scene "corruption"
	# in those scenes...
	# See https://github.com/godotengine/godot/issues/81462
	#const TARGETS:=[
		#preload("res://targets/none.tscn"),
		#preload("res://targets/ammo_box.tscn"),
		#preload("res://targets/duck.tscn"),
		#preload("res://targets/owl.tscn"),
		#preload("res://targets/rabbit.tscn"),]

	var TARGETS:Array[PackedScene]=[
		load("res://targets/duck.tscn"),
		load("res://targets/owl.tscn"),
		load("res://targets/rabbit.tscn"),
		]
	var r:=randi()%TARGETS.size()
	var target:Target=TARGETS[r].instantiate() as Target
	return target
