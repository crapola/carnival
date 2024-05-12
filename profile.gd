class_name Profile
extends Resource

## Persistent player info.

## High score.
@export var high_score:int=0
## Time played in seconds.
@export var time_played:int=0
## Furthest stage reached.
@export var stage:int=0

const PATH:String="user://profile.tres"

func _init()->void:
	take_over_path(PATH)

## Save to [member Resource.resource_path], which defaults to [constant PATH].
func save()->void:
	if ResourceSaver.save(self)!=OK:
		printerr("Couldn't save profile to ",resource_path)

## Load from [constant PATH].
static func load()->Profile:
	var profile:Profile
	if FileAccess.file_exists(PATH):
		profile=load(PATH) as Profile
	if profile:
		print_debug("Loaded profile from ",profile.resource_path)
	if not profile:
		profile=Profile.new()
		print_debug("New profile created with path ",profile.resource_path)
	return profile
