class_name Item
extends RefCounted

var grid_position: Vector2i
var symbol: String
var id: String

func _init(position: Vector2i, item_name: String, item_symbol: String):
	grid_position = position
	id = item_name
	symbol = item_symbol
