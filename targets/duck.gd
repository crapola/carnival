class_name Duck
extends Target

## Duck
##
## The duck target can take off.

## Velocity of flying duck.
var velocity:Vector2=Vector2(0,200)
## Internal timer.
@onready var timer:=$Timer as Timer

func _ready()->void:
	set_physics_process(false)

func _physics_process(delta:float)->void:
	position+=velocity*delta
	var phase:float=fmod(get_instance_id(),TAU)
	velocity.x=sin(phase+Engine.get_frames_drawn()*delta*2)*(100+position.y/4)
	flip_h=velocity.x>0
	if position.y>800-32:
		explosion=preload("res://quack.tscn")
		queue_free()

func apply_rank(rank:float)->void:
	var speed:float=100+rank*100
	velocity.y*=(speed/100.0)
	timer.wait_time=100.0/speed

func _on_timer_timeout()->void:
	if global_position.x>64 and global_position.x<600-64 and global_position.y>200 and randi()%3==0:
		top_level=true
		global_position=(get_parent() as Node2D).global_position
		set_physics_process(true)
		velocity.y+=randf_range(0,80)
		timer.stop()
		# Flutter.
		var t:=create_tween()
		t.chain()
		t.tween_property(self,"scale",Vector2.ONE*1.25,0.25)
		t.tween_property(self,"scale",Vector2.ONE,0.25)
		t.set_loops()
