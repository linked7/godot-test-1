extends Node

# Add this to the bottom of items.gd

@export var item_defs = {
	"apple": {
		"itemID": "apple",
		"itemName": "Apple",
		"sprite": "res://sprites/apple.png"
	},
	"carrot": {
		"itemID": "carrot",
		"itemName": "Carrot",
		"sprite": "res://sprites/carrot.png"
	}
}

func create_item(itemID: String, pos: Vector3, _ang: Vector3) -> Node:
	var item_scene = preload("res://item.tscn") # your base item scene
	var item = item_scene.instantiate()
	var source = Items.item_defs[itemID]
	
	item.itemID = itemID
	item.itemName = source["itemName"]
	item.get_node("Sprite").texture = load(source["sprite"])

	
	item.global_position = pos
	#item.global_rotation_degrees = ang
	var main = get_node("/root/Map")
	main.add_child(item)
	
	return item
