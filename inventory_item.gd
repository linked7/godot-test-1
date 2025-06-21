extends Area2D

class_name InventoryItem

@export var item_scene : PackedScene

@export var itemID: String
@export var itemName: String
var lifted = false

func _unhandled_input(event):
	if event is InputEventMouseButton and not event.pressed:
		lifted = false
	if lifted and event is InputEventMouseMotion:
		position += event.relative

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		lifted = true
