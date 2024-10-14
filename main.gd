extends Node

## Game script.

@onready var belt:Belt=%Belt as Belt
@onready var bonus:Bonus=%Bonus as Bonus
@onready var center_message:Message=%CenterMessage as Message
@onready var flag_points:LabelInteger=%FlagPoints as LabelInteger
@onready var gun:Gun=$Gun as Gun
@onready var message:=%Message as Message
@onready var rank_timer:Timer=$RankTimer as Timer
@onready var score:LabelInteger=%Score as LabelInteger
@onready var timer:Timer=$Timer as Timer
@onready var wheel:Wheel=$Wheel as Wheel

## Difficulty from 0 (easy) to 1 (hardest).
var rank:float=0.0:set=rank_set,get=rank_get
func rank_get()->float:
	return rank
func rank_set(value:float)->void:
		rank=clampf(value,0,1)
		on_rank_updated(rank)

var _clock:Clock=Clock.new()

func _ready()->void:
	print_debug("Game start.")
	if !OS.is_debug_build():
		set_process_input(false)
	randomize()
	meta_load()
	# Initial rank is higher on late stages.
	rank=minf(0.5,score.value/5000.0)
	# Dependency injection.
	belt.get_player_ammo=func()->int:
		return gun.ammo
	belt.get_rank=rank_get

func _input(event:InputEvent)->void:
	var key:InputEventKey=event as InputEventKey
	if key and key.is_pressed():
		match key.as_text_key_label():
			"W":
				clear()
			"Q":
				game_over()

## Stage cleared.
func clear()->void:
	center_message.say("Cleared!",5.0)
	var ammo_bonus:int=gun.ammo*5
	score.value+=ammo_bonus
	message.say("Ammo bonus: %d points."%ammo_bonus,5)
	timer.stop()
	rank_timer.stop()
	gun.set_process_input(false)
	gun.can_shoot=false
	belt.stop(5.0)
	wheel.stop(5.0)
	await get_tree().create_timer(5.5,false,true,false).timeout
	meta_save()
	propagate_call("set_block_signals",[true])
	get_tree().reload_current_scene()

func decrease_flag_points()->void:
	flag_points.value=maxi(5,flag_points.value-1)

## Game over sequence.
func game_over()->void:
	center_message.say("Game over",7)

	# Inform of a new pb
	var p:=Profile.load()
	var s:String="\nFinal score: %d"%score.value
	if score.value>p.high_score:
		s+="\nNew high score!"

	message.say("You ran out of ammo."+s,7)
	gun.set_process_input(false)
	gun.can_shoot=false
	timer.stop()
	rank_timer.stop()
	belt.stop(5.0)
	wheel.stop(5.0)
	await get_tree().create_timer(7.0,false,true,false).timeout
	quit()

func meta_save()->void:
	get_tree().set_meta("score",score.value)
	get_tree().set_meta("time",_clock.elapsed_seconds())

func meta_load()->void:
	if get_tree().has_meta("score"):
		score.value=get_tree().get_meta("score")
		get_tree().set_meta("score",null)
	if get_tree().has_meta("time"):
		_clock=Clock.new(get_tree().get_meta("time") as int)
		get_tree().set_meta("time",null)

func on_bonus_completed(points:int)->void:
	score.value+=points

func on_obstacle_hit(_area:Area2D)->void:
	decrease_flag_points()

func on_rank_updated(r:float)->void:
	print_debug("Rank increased to %f."%r)
	belt.speed=100+r*100

func on_target_exiting_tree(target:Target)->void:
	# Robber duck reached bottom.
	if target.global_position.y>700:
		var bullets:int=mini(10,gun.ammo)
		gun.ammo-=10
		message.say("The duck ate %d bullets!"%bullets)
		# Don't give points.
		return

	# Bonus letter.
	if target.letter:
		bonus.add_letter(target.letter.text)

	# Flag.
	if target.global_position.y<belt.global_position.y:
		print_debug("Flag hit.")
		score.value+=flag_points.value
		if wheel.cleared():
			belt.spawning=false
			wheel.stop(2.0)
			flag_points.hide()
	else:
		decrease_flag_points()

	# Top rows give more points.
	var hook:Node2D=target.get_parent() as Node2D
	var row:int=int(hook.position.y/64)
	var multiplier:int=3-row
	var points:int=target.points*multiplier
	score.value+=points
	gun.ammo+=target.ammo
	bonus.increase(points)
	print_debug("Target %s destroyed on row %d (X%d) %d points."%[target.name,row,multiplier,points])

func on_timer_timeout()->void:
	# Check victory condition.
	if not belt.spawning and belt.get_target_count()==0:
		clear()

## Back to title.
func quit()->void:
	# Prevent all the Targets' tree_exiting signals from happening.
	propagate_call("set_block_signals",[true])
	save_high_score()
	print_debug("Changing scene to title.")
	get_tree().change_scene_to_file("res://title.tscn")

func rank_increase()->void:
	rank+=0.1

func save_high_score()->void:
	var p:Profile=Profile.load() as Profile
	if score.value>p.high_score:
		p.high_score=score.value
		p.time_played=_clock.elapsed_seconds()
		p.stage=0
		p.save()
		print_debug("New high score saved.")
