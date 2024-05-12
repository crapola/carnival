class_name Gun
extends Node2D

## Gun
##
## The player gun.

## Emitted when out of ammo for good and game should end.
signal ammo_depleted

## Number of bullets left.
@export var ammo:int=15:
	set(value):
		# TODO:
		if not _ammo_label:
			await ready
		_low_ammo_warning_update(ammo,value)
		ammo=max(0,value)
		_ammo_label.value=ammo
		_check_loss()

## Speed when using key controls.
@export var speed:float=256

# Bullet in flight.
var _bullet:Node2D
# Using mouse or not.
var _mouse:bool=true

@onready var _ammo_label:LabelInteger=$Ammo as LabelInteger
@onready var _animation_player:AnimationPlayer=$AnimationPlayer as AnimationPlayer

func _ready()->void:
	# Invoke setter so that the label displays correct value.
	# TODO
	ammo=ammo

func _input(event:InputEvent)->void:
	if event.is_action_pressed("shoot") and _bullet==null:
		_shoot()
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		_mouse=false
	if event is InputEventMouseMotion:
		_mouse=true

func _process(delta:float)->void:
	if _mouse:
		_move_using_mouse(delta)
	else:
		_move_using_keyboard(delta)
	# Clamp position.
	var width:=get_viewport_rect().size.x
	global_position.x=clampf(global_position.x,64,width-64)

func _check_loss()->void:
	if _bullet!=null:
		if not _bullet.is_queued_for_deletion():
			await _bullet.tree_exited
			if not is_inside_tree():
				return
			await get_tree().process_frame
			if ammo==0:
				ammo_depleted.emit()
	else:
		if ammo==0:
			ammo_depleted.emit()

func _low_ammo_warning_update(current_ammo:int,new_ammo:int)->void:
	if current_ammo>=10 and new_ammo<10:
		_ammo_label.scale=Vector2(2,2)
		_ammo_label.add_theme_color_override("font_color",Color.RED)
	if current_ammo<10 and new_ammo>=10:
		_ammo_label.scale=Vector2.ONE
		_ammo_label.remove_theme_color_override("font_color")

func _move_using_keyboard(delta:float)->void:
	position.x+=Input.get_axis("ui_left","ui_right")*speed*delta

func _move_using_mouse(_delta:float)->void:
	global_position.x=get_global_mouse_position().x

func _shoot()->void:
	_bullet=preload("res://bullet.tscn").instantiate() as Node2D
	_bullet.scale*=0.25
	_bullet.position=position
	add_child(_bullet)
	_animation_player.stop()
	_animation_player.play("shoot")
	ammo-=1
