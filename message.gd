class_name Message
extends Label

## Timed message.

var _timer:Timer=Timer.new()

func _ready()->void:
	hide()
	add_child(_timer)
	_timer.timeout.connect(hide)
	_timer.one_shot=true

## Show message and hide after [param hold_time] seconds.
## If [param hold_time] is not provided, it is determinated from the text length.
func say(message:String,hold_time:float=0.0)->void:
	show()
	text=message
	if hold_time==0.0:
		const reading_speed:float=10.0 # Characters per seconds.
		hold_time=0.75+len(text)/reading_speed
	_timer.start(hold_time)
