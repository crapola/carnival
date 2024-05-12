class_name LabelInteger
extends Label

## Label Integer
##
## A [Label] that specializes in displaying an [int] value.

## Integer value.
var value:int=0:
	set(v):
		value=v
		text=str(v)
	get:
		return value

func _init()->void:
	value=int(text)
