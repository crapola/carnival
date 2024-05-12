class_name Bonus
extends Control

## Bonus
##
## Bonus display.

## Emitted when the bonus has been completed in the correct order.
signal completed(points:int)

const bonus_string:StringName=&"BONUS"

## Base increment value per target.
@export var points:int=5

# Current bonus total.
var _bonus:int
# Word found so far.
var _found:String

@onready var _animation_player:AnimationPlayer=%AnimationPlayer as AnimationPlayer
@onready var _letters:RichTextLabel=%Letters as RichTextLabel
@onready var _message:Label=%Message as Label

func _ready()->void:
	_letters.text="[center][color=gray]"+bonus_string+"[/color][/center]"
	increase()

## Add a letter.
func add_letter(character:String)->void:
	_update_letters(character)
	if _found.length()<bonus_string.length() and _correct_order():
		_found+=character
		if _correct_order():
			print_debug("Correct order ",_found)
			if _bonus_completed():
				_message.text="+%d"%_bonus
				_message.add_theme_color_override("font_color",Color.GREEN)
				_flash()
				completed.emit(_bonus)
				# Wait for duration of flashing and hide.
				await get_tree().create_timer(5).timeout
				visible=false
		else:
			print_debug("Incorrect order ",_found)
			_message.text="0"
			_message.add_theme_color_override("font_color",Color.RED)
			_flash()
			_letters.modulate.a=0.5

## Increase bonus by [member points]+[param extra].
## The bonus stops increasing as soon as any letter is shot.
func increase(extra:int=0)->void:
	if len(_found)==0:
		_bonus+=points+extra
		_message.text="%d"%_bonus
	else:
		_message.modulate.a=1

func _bold_letter(character:String)->String:
	return "[b][color=white]%s[/color][/b]"%character

func _bonus_completed()->bool:
	return _found==bonus_string

func _correct_order()->bool:
	var expected:=bonus_string.substr(0,len(_found))
	return _found==expected

func _flash()->void:
	for i in 10:
		_animation_player.queue("flash")

# Highlight letter in the visual.
func _update_letters(character:String)->void:
	var index:int=_letters.text.find(character)
	_letters.text=_letters.text.erase(index)
	_letters.text=_letters.text.insert(index,_bold_letter(character))
