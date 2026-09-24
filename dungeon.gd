extends Node

const WIDTH = 40
const HEIGHT = 25
const MAX_ROOMS = 6
const MIN_ROOM_SIZE = 2
const MAX_ROOM_SIZE = 4
const VIEW_DISTANCE = 6

var tiles = []
var explored = []
var visible = []

var rooms: Array[Rect2i] = []
var exit_position: Vector2i

func _ready():
	generate()

func generate():
	visible.clear()
	tiles.clear()
	rooms.clear()
	explored.clear()

	for y in range(HEIGHT):
		var row = []
		var explored_row = []
		var visible_row = []
		
		for x in range(WIDTH):
			row.append("#")
			explored_row.append(false)
			visible_row.append(false)

		tiles.append(row)
		explored.append(explored_row)
		visible.append(visible_row)

	for i in range(MAX_ROOMS):
		var room_width = randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var room_height = randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)

		var room_x = randi_range(1, WIDTH - room_width - 1)
		var room_y = randi_range(1, HEIGHT - room_height - 1)

		var room = Rect2i(
			room_x,
			room_y,
			room_width,
			room_height
		)

		if room_overlaps(room):
			continue

		carve_room(room)

		if rooms.size() > 0:
			var previous_center = Vector2i(rooms[rooms.size() - 1].get_center())
			var current_center = Vector2i(room.get_center())

			carve_corridor(previous_center, current_center)

		rooms.append(room)
		
	if rooms.size() >0:
		exit_position = get_exit_position()

func get_start_position() -> Vector2i:
	if rooms.size() == 0:
		return Vector2i(-1, -1)

	return Vector2i(rooms[0].get_center())


func get_exit_position() -> Vector2i:
	if rooms.size() == 0:
		return Vector2i(-1, -1)

	return Vector2i(rooms[rooms.size() - 1].get_center())

func room_overlaps(new_room: Rect2i) -> bool:
	for room in rooms:
		var expanded_room = room.grow(1)

		if expanded_room.intersects(new_room):
			return true

	return false

func carve_room(room: Rect2i):
	for y in range(room.position.y, room.end.y):
		for x in range(room.position.x, room.end.x):
			tiles[y][x] = "."

func carve_corridor(start: Vector2i, end: Vector2i):
	var current = start

	while current.x != end.x:
		tiles[current.y][current.x] = "."
		
		if current.x < end.x:
			current.x += 1
		else:
			current.x -= 1

	while current.y != end.y:
		tiles[current.y][current.x] = "."
		
		if current.y < end.y:
			current.y += 1
		else:
			current.y -= 1

	tiles[end.y][end.x] = "."

func get_random_floor_position() -> Vector2i:
	for i in range(1000):
		var x = randi_range(0, WIDTH - 1)
		var y = randi_range(0, HEIGHT - 1)
		var grid_position = Vector2i(x, y)

		if not is_wall(grid_position):
			return grid_position

	return Vector2i(-1, -1)

func is_wall(grid_position: Vector2i) -> bool:
	return tiles[grid_position.y][grid_position.x] == "#"

func get_tile(grid_position: Vector2i) -> String:
	return tiles[grid_position.y][grid_position.x]

func get_width() -> int:
	return tiles[0].size()

func get_height() -> int:
	return tiles.size()

func update_visibility(player_position: Vector2i):
	for y in range(HEIGHT):
		for x in range(WIDTH):
			visible[y][x] = false
	
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var grid_position = Vector2i(x, y)

			if has_line_of_sight(player_position, grid_position):
				visible[y][x] = true
				explored[y][x] = true

func has_line_of_sight(start: Vector2i, end: Vector2i) -> bool:
	if start.distance_to(end) > VIEW_DISTANCE:
		return false

	var points = get_line_points(start, end)

	for point in points:
		if is_wall(point) and point != start and point != end:
			return false

	return true

func get_line_points(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	
	var x = start.x
	var y = start.y
	
	var dx = abs(end.x - start.x)
	var dy = abs(end.y - start.y)
	
	var sx = 1 if start.x < end.x else -1
	var sy = 1 if start.y < end.y else -1
	
	var error = dx - dy
	
	for i in range (1000):
		points.append(Vector2i(x,y))
		
		if x == end.x and y == end.y:
			return points
		
		var error2 = error * 2
		
		if error2 > -dy:
			error -= dy
			x += sx
		
		if error2 < dx:
			error += dx
			y += sy
		
	return points
