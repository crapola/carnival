extends CheckButton

## Mute button
##
## Toggles an audio bus.

## Bus name.
@export var bus_name:StringName="":
	set(value):
		bus_name=value
		_bus_index=AudioServer.get_bus_index(bus_name)

var _bus_index:int

func _ready()->void:
	set_pressed_no_signal(!AudioServer.is_bus_mute(_bus_index))
	toggled.connect(func(enable:bool)->void:
		AudioServer.set_bus_mute(_bus_index,!enable))
