class_name Clock

## Clock
##
## An Object that tracks time elapsed since its instantiation.

var _start:int

func _init(seconds:int=0)->void:
	_start=Time.get_ticks_msec()-seconds*1000

## Get seconds elapsed since this Clock was instantiated.
func elapsed_seconds()->int:
	@warning_ignore("integer_division")
	return (Time.get_ticks_msec()-_start)/1000

## Get time elapsed since this Clock was instantiated as HH:MM:SS String.
func elapsed_string()->String:
	return Clock.format_time(elapsed_seconds())

## Format seconds to HH:MM:SS String.
static func format_time(time_seconds:int)->String:
	return Time.get_time_string_from_unix_time(time_seconds)
