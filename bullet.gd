extends Node2D

@export var speed:float=512

func _physics_process(delta:float)->void:
	position.y-=speed*delta

func on_hit(other:Area2D)->void:
	# If the bullet overlaps many targets, we only want one destroyed.
	# For this reason the bullet must oversee the process.
	if not is_queued_for_deletion():
		queue_free()
		if other.collision_layer==1:
			other.owner.queue_free()
