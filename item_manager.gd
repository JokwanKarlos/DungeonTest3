class_name ItemManager
extends RefCounted

var items = []

func add_item(item):
	items.append(item)

func remove_item(item):
	items.erase(item)

func get_item_at(grid_position: Vector2i):
	for item in items:
		if item.grid_position == grid_position:
			return item
	return null
