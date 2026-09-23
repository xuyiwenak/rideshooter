extends Node2D
## The sole source of road speed and travelled distance.
const C = preload("res://core/tuning.gd")
var rider: Node2D
var speed := C.ROAD_SPEED
var road_scroll := 0.0
var passed := 0
var obstacles: Array[Dictionary] = []

func reset() -> void:
	speed = C.ROAD_SPEED
	road_scroll = 0.0
	passed = 0
	obstacles.clear()
	queue_redraw()

func step_speed(delta: float) -> void:
	var target := C.ROAD_SPEED * (1.8 if rider.charge_left > 0.0 else 1.0)
	speed = move_toward(speed, target, C.ROAD_SPEED * 5.0 * delta)
	road_scroll += speed * delta
	queue_redraw()

func step_obstacles(delta: float) -> void:
	for obstacle in obstacles:
		var old_x: float = obstacle.x
		obstacle.x -= speed * delta
		if not obstacle.resolved and old_x >= C.PLAYER_X - 20.0 and obstacle.x <= C.PLAYER_X + 20.0 and rider.collision_lane() == obstacle.lane:
			if rider.charge_left > 0.0:
				obstacle.resolved = true
				obstacle.x = -100.0
				passed += 1
			elif rider.jump_height() < 20.0:
				obstacle.resolved = true
				rider.hurt()
		if obstacle.x < C.PLAYER_X - 28.0 and not obstacle.resolved:
			obstacle.resolved = true
			passed += 1
	obstacles = obstacles.filter(func(item: Dictionary) -> bool: return item.x > -25.0)

func _draw() -> void:
	for route in 3:
		var y: float = C.LANE_Y[route]
		draw_rect(Rect2(0, y - 26, C.WIDTH, 48), Color("665b4d"))
		draw_line(Vector2(0, y + 23), Vector2(C.WIDTH, y + 23), Color("b9a98d"), 2.0)
		for mark in 10:
			var x := fposmod(float(mark * 58) - road_scroll, 580.0)
			draw_rect(Rect2(x, y + 11, 18, 2), Color("a49378"))
		# Non-colliding roadside landmarks never occupy the danger strip.
		for mark in 7:
			var x := fposmod(mark * 83.0 + route * 29.0 - road_scroll, 581.0) - 35.0
			draw_line(Vector2(x, y + 30), Vector2(x + 2, y + 25), Color("98ac71"), 2.0)
			if mark % 2 == 0:
				draw_rect(Rect2(x, y + 24, 3, 3), Color("e6c56f"))
			else:
				draw_rect(Rect2(x + 10, y + 27, 5, 2), Color("9c9281"))
	for obstacle in obstacles:
		var y: float = C.LANE_Y[obstacle.lane]
		draw_rect(Rect2(obstacle.x - 12, y - 16, 24, 20), Color("a24b3f"))
		draw_line(Vector2(obstacle.x - 12, y - 16), Vector2(obstacle.x, y - 26), Color("e0b78a"), 3.0)
		draw_line(Vector2(obstacle.x, y - 26), Vector2(obstacle.x + 12, y - 16), Color("e0b78a"), 3.0)
