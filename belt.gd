class_name Belt
extends TargetContainer

## Belt
##
## The central rows of targets.

## Spacing between targets.
const target_size:float=64

## Belt keeps spawning new targets.
var spawning:bool=true

## Callback to get player ammo from main script.
var get_player_ammo:Callable
## Callback to get rank from main script.
var get_rank:Callable

@onready var _path:Path2D=$Path2D as Path2D

func _ready()->void:
	_fill()

func _physics_process(delta:float)->void:
	for follow:PathFollow2D in _path.get_children() as Array[PathFollow2D]:
		follow.progress+=delta*speed
		# Feed belt with new target.
		if follow.progress<delta*speed:
			var refill_chance:float=0.2+get_rank.call()*0.3
			if follow.get_child_count()==0 and refill_chance>randf():
				# Spawn ammo box if needed.
				var total_ammo:int=_get_ammo_available()+get_player_ammo.call()
				if total_ammo<20:
					var t:=preload("res://targets/ammo_box.tscn").instantiate() as Target
					_add_target(follow,t)
				# Spawn regular target.
				elif spawning:
					var t:Target
					# Duck more probable when rank is high.
					var rank:float=get_rank.call()
					if rank>randf():
						t=preload("res://targets/duck.tscn").instantiate() as Target
					else:
						t=Target.instance_random()
					_add_target(follow,t)
					t.apply_rank(rank)

## Get number of targets currently in the belt.
func get_target_count()->int:
	var sum:int=0
	for hook:Node in _path.get_children():
		var target:Target=hook.get_child(0) as Target if hook.get_child_count()>0 else null
		if target:
			sum+=1
	return sum

## Halt the belt.
func stop(time:float=1.0)->void:
	_path.propagate_call("set_physics_process",[false])
	_path.propagate_call("stop") # Stop duck timer.
	super.stop(time)

# Fill belt with targets.
func _fill()->void:
	var length:float=_path.curve.get_baked_length()
	var fill_percentage:float=0.7
	var ammo_boxes:int=5
	var num_targets:int=int(length/target_size)
	var targets:Array[Target]=[]
	var t:Target
	const BONUS:String="BONUS"
	for c in BONUS:
		t=preload("res://targets/letter.tscn").instantiate() as Target
		t.letter.text=c
		targets.append(t)
	for i in ammo_boxes:
		t=preload("res://targets/ammo_box.tscn").instantiate() as Target
		targets.append(t)
	for i in fill_percentage*num_targets-BONUS.length()-ammo_boxes:
		t=Target.instance_random()
		targets.append(t)
	for i in (1.0-fill_percentage)*num_targets-1:
		targets.append(null)
	assert(targets.size()==num_targets)
	targets.shuffle()
	for i in targets.size():
		var path_follow:=PathFollow2D.new()
		path_follow.loop=true
		path_follow.rotates=false
		path_follow.progress=i*target_size
		_path.add_child(path_follow)
		if targets[i]:
			_add_target(path_follow,targets[i])

# Count ammo currently in the belt.
func _get_ammo_available()->int:
	var ammo_sum:int=0
	for hook:Node in _path.get_children():
		var target:Target=hook.get_child(0) as Target if hook.get_child_count()>0 else null
		if target:
			ammo_sum+=target.ammo
	return ammo_sum
