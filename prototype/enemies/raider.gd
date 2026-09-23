extends "res://enemies/enemy.gd"
## A faster melee enemy: commit to one adjacent lane, warn, then move.
const WINDUP := 0.35
const MOVE_TIME := 0.42
var move_state := "CHASE"
var move_left := 0.0
var move_cooldown := 0.0
var from_y := 0.0
var destination_lane := 1

func step_movement(delta: float, road_speed: float) -> void:
	vx = -130.0 - (road_speed - C.ROAD_SPEED)
	x += vx * delta
	if escaped or x < C.PLAYER_X - 28.0:
		return
	move_cooldown = maxf(0.0, move_cooldown - delta)
	match move_state:
		"CHASE":
			# Never start a last-instant lane change beside the rider.
			if x < 440.0 and x > C.PLAYER_X + 150.0 and move_cooldown == 0.0 and lane != rider.collision_lane():
				destination_lane = lane + clampi(rider.collision_lane() - lane, -1, 1)
				from_y = y
				move_state = "WARN"
				move_left = WINDUP
		"WARN":
			move_left = maxf(0.0, move_left - delta)
			if move_left == 0.0:
				move_state = "MOVE"
				move_left = MOVE_TIME
		"MOVE":
			move_left = maxf(0.0, move_left - delta)
			var t := 1.0 - move_left / MOVE_TIME
			y = lerpf(from_y, C.LANE_Y[destination_lane], t * t * (3.0 - 2.0 * t))
			if t >= 0.5:
				lane = destination_lane
			if move_left == 0.0:
				move_state = "CHASE"
				move_cooldown = 0.8

func _draw() -> void:
	super._draw()
	if move_state in ["WARN", "MOVE"] and not escaped:
		var target := Vector2(-35.0, C.LANE_Y[destination_lane] - y)
		draw_line(Vector2(0, 6), target, Color("ffd166"), 2.0)
		draw_circle(target, 4.0, Color("ffd166"))
