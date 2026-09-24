extends Node2D
@onready var dungeon = $Dungeon
@onready var player = $Player

var game_world = World.new()
var enemies = []
var turn = 0
var item_manager = ItemManager.new()

const TILE_SIZE = 32
const FONT_SIZE = 24

func _ready():
	player.grid_position = dungeon.get_start_position()
	dungeon.update_visibility(player.grid_position)
	game_world.player = player
	
	var test_item = Item.new(
		dungeon.get_random_floor_position(),
		"Gold",
		"$"
	)
	item_manager.add_item(test_item)
	
	var goblin = Enemy.new(get_random_unoccupied_position(), 5, 1, "g", "goblin")
	enemies.append(goblin)

	var goblin2 = Enemy.new(get_random_unoccupied_position(), 5, 1, "g", "goblin")
	enemies.append(goblin2)

	queue_redraw()
	print("GAME STARTED")

func _draw():
	print("DRAWING")
	for y in range(dungeon.get_height()):
		for x in range(dungeon.get_width()):
			var grid_position = Vector2i(x,y)
			var character = dungeon.get_tile(Vector2i(x,y))
			
			if not dungeon.explored[y][x]:
				character = " "
			elif not dungeon.visible[y][x]:
				character = character
			
			if Vector2i(x,y) == dungeon.exit_position:
				if dungeon.explored[y][x]:
					character = ">"
			
			if Vector2i(x, y) == player.grid_position:
				character = "@"

				
			draw_string(
				ThemeDB.fallback_font,
				Vector2(x * TILE_SIZE, (y+1) * TILE_SIZE),
				character,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				FONT_SIZE
			)
			
			for enemy in enemies:
				if not dungeon.visible[enemy.grid_position.y][enemy.grid_position.x]:
					continue
				draw_string(
					ThemeDB.fallback_font,
					Vector2(
						enemy.grid_position.x * TILE_SIZE,
						(enemy.grid_position.y +1) * TILE_SIZE
					),
					enemy.symbol,
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					FONT_SIZE
				)
			draw_string(
				ThemeDB.fallback_font,
				Vector2(10,(dungeon.get_height()+1) * TILE_SIZE),
				"Turn: " +str(turn),
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				FONT_SIZE
				)
			for item in item_manager.items:
				if not dungeon.visible[item.grid_position.y][item.grid_position.x]:
					continue
				var item_position = item.grid_position
				
				draw_string(
					ThemeDB.fallback_font,
					Vector2(
						item_position.x * TILE_SIZE,
						(item_position.y + 1) * TILE_SIZE
						),
					item.symbol,
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					FONT_SIZE
				)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		print("Key pressed: ", event.keycode)
	if event is InputEventKey and event.pressed and not event.echo:
		var movement = Vector2i.ZERO
		
		if event.keycode == KEY_W:
			movement = Vector2i(0,-1)
		elif event.keycode == KEY_A:
			movement = Vector2i(-1,0)
		elif event.keycode == KEY_S:
			movement = Vector2i(0,1)
		elif event.keycode == KEY_D:
			movement = Vector2i(1,0)
		elif event.keycode == KEY_SPACE:
			movement = Vector2i(0,0)
		
		if movement != Vector2i.ZERO:
			player_turn(movement)
		elif event.keycode == KEY_SPACE:
			wait_turn()

func wait_turn():
	turn += 1
	enemy_turn()
	queue_redraw()

func move_player(direction: Vector2i):
	var new_position = player.grid_position + direction
	var enemy = get_enemy_at(new_position)

	if enemy != null:
		attack_enemy(enemy)
		return true

	if dungeon.is_wall(new_position):
		return false

	player.move(direction)
	dungeon.update_visibility(player.grid_position)
	queue_redraw()

	return true

func player_turn(direction: Vector2i):
	var moved = move_player(direction)
	var item = item_manager.get_item_at(player.grid_position)
	
	if item != null:
		print("Picked up ", item.id)
		item_manager.remove_item(item)
		
	if moved:
		if player.grid_position == dungeon.exit_position:
			descend_dungeon()
		else:
			turn += 1
			enemy_turn()
			print("Turn: ", turn)

func attack_enemy(enemy):
	player.attack(enemy)
	if enemy.hp <= 0:
		enemies.erase(enemy)
	queue_redraw()

func enemy_turn():
	for enemy in enemies:
		enemy.take_turn(player, dungeon, enemies)

func get_enemy_at(position: Vector2i):
	for enemy in enemies:
		if enemy.grid_position == position:
			return enemy
	return null

func get_random_unoccupied_position() -> Vector2i:
	for i in range(1000):
		var grid_position = dungeon.get_random_floor_position()

		if grid_position == player.grid_position:
			continue

		var occupied = false

		for enemy in enemies:
			if enemy.grid_position == grid_position:
				occupied = true
				break

		if not occupied:
			return grid_position

	return Vector2i(-1, -1)

func descend_dungeon():
	dungeon.generate()
	
	player.grid_position = dungeon.get_start_position()
	dungeon.update_visibility(player.grid_position)
	
	for enemy in enemies:
		enemy.queue_free()
	
	enemies.clear()
	
	for i in range(2):
		var enemy = Enemy.new(dungeon.get_random_floor_position(), 5, 1, "g", "goblin")
		enemies.append(enemy)
	
	queue_redraw()
