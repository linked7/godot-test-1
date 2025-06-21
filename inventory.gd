extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func create_inventory_item(itemID: String) -> Node:
	var item_scene = preload("res://inventory_item.tscn")
	var item = item_scene.instantiate()
	var source = Items.item_defs[itemID]
	
	item.itemID = itemID
	item.itemName = source["itemName"]
	item.get_node("Sprite").texture = load(source["sprite"])

	# Get the InventoryArea CollisionShape2D
	var shape_node = get_node("/root/Map/Interface/Inventory/InventoryArea/CollisionShape2D")
	var shape = shape_node.shape as RectangleShape2D
	var size = shape.size  # Vector2(x, y)
	var center = shape_node.global_position

	# Calculate random position within bounds
	var half_size = size * 0.5
	var rand_x = randf_range(-half_size.x, half_size.x)
	var rand_y = randf_range(-half_size.y, half_size.y)
	var item_pos = center + Vector2(rand_x, rand_y)

	var parent = get_node("/root/Map/Interface/Inventory/Items")
	parent.add_child(item)
	item.global_position = item_pos

	return item
