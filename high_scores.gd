extends Control

## Title screen high score display.

@onready var reset:Button=$Reset as Button
@onready var score:Label=%Score as Label
@onready var time:Label=%Time as Label

var profile:Profile=Profile.load()

func _init()->void:
	if profile.high_score==0:
		queue_free()

func _ready()->void:
	if OS.is_debug_build():
		reset.visible=true
	else:
		reset.free()
	score.text=str(profile.high_score)
	time.text=Clock.format_time(profile.time_played)

func _notification(what:int)->void:
	match what:
		NOTIFICATION_EXIT_TREE:
			print_debug("Saving profile.")
			profile.save()

func _reset()->void:
	print_debug("Profile reset.")
	profile=Profile.new()
