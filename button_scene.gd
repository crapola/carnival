extends Button

## This Button changes current scene to file [member scene_path] when pressed.

## Path to scene.
@export var scene_path:String

func _init()->void:
	pressed.connect(func()->void:get_tree().change_scene_to_file(scene_path))
