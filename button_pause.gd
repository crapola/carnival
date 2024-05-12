extends Control

## Pause node.
##
## This node pauses the scene tree when it is visible and unpauses when hidden.

func _notification(what:int)->void:
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if is_visible_in_tree():
				grab_focus()
			if is_inside_tree():
				get_tree().paused=is_visible_in_tree()
		NOTIFICATION_EXIT_TREE:
			get_tree().paused=false
