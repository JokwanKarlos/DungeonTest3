class_name Enemy
extends Node2D

const VISION_DISTANCE = 6

var grid_position: Vector2i
var hp: int
var damage: int
var symbol: String
var id: String
var last_known_player_position: Vector2i = Vector2i(-1,-1)

func _init(start_position: Vector2i, start_hp: int, start_damage: int, start_symbol: String, start_id: String):
	grid_position = start_position
	hp = start_hp
	damage = start_damage
	symbol = start_symbol
	id = start_id

func take_damage(amount: int):
	hp -= amount

func can_see_player(player, dungeon) -> bool:
	if grid_position.distance_to(player.grid_position) > VISION_DISTANCE:
		return false
	if dungeon.has_line_of_sight(grid_position, player.grid_position):
		print("The ", id, " sees you!")
		return true
	return false

func chase_player(player, dungeon, enemies):
	var direction = Vector2i.ZERO
	var difference = player.grid_position - grid_position
	
	if abs(difference.x) + abs(difference.y) == 1:
		attack_player(player)
		return
	if abs(difference.x) > abs(difference.y):
		direction.x = sign(difference.x)
	else:
		direction.y = sign(difference.y)
	
	try_move(direction, dungeon, enemies, player)

func attack_player(player):
	player.take_damage(damage)
	print(id, " attacks player for ", damage, " damage!")

func investigate_player(dungeon, enemies, player):
	if grid_position == last_known_player_position:
		last_known_player_position = Vector2i(-1,-1)
		wander(dungeon, enemies, player)
		return
	var difference = last_known_player_position - grid_position
	var direction = Vector2i.ZERO
	
	if abs(difference.x) > abs(difference.y):
		direction.x = sign(difference.x)
	else:
		direction.y = sign(difference.y)
	
	try_move(direction, dungeon, enemies, player)
	
func wander(dungeon, enemies, player):
	var directions = [
		Vector2i(1,0),
		Vector2i(0,1),
		Vector2i(-1,0),
		Vector2i(0,-1)
	]
	
	var direction = directions[randi_range(0,directions.size()-1)]
	
	try_move(direction, dungeon, enemies, player)

func try_move(direction: Vector2i, dungeon, enemies, player):
	var new_position = grid_position + direction
	
	if dungeon.is_wall(new_position):
		return
	if new_position == player.grid_position:
		return
	for enemy in enemies:
		if enemy == self:
			continue
		if enemy.grid_position == new_position:
			return
	
	grid_position = new_position
	
func take_turn(player, dungeon, enemies):
	if can_see_player(player,dungeon):
		last_known_player_position = player.grid_position
		chase_player(player, dungeon, enemies)
	elif last_known_player_position != Vector2i(-1,-1):
		investigate_player(dungeon, enemies, player)
	else:
		wander(dungeon, enemies, player)
