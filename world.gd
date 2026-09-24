class_name World
extends RefCounted

var player
var enemies = []
var items = []


func is_occupied(position: Vector2i) -> bool:
	if player != null and player.grid_position == position:
		return true
	for enemy in enemies:
		if enemy.grid_position == position:
			return true
	for item in items:
		if item.grid_position == position:
			return true
	return false
