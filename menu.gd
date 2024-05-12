extends Control

## Menu displayed on title and in-game when pressing escape.

@onready var _start_button:Button=%Start as Button

func _ready()->void:
	_start_button.grab_focus()

func _input(event:InputEvent)->void:
	if event.is_action_pressed("ui_cancel") and not _start_button.visible:
		visible=not visible
