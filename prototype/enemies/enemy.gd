extends Node2D
## Common lifecycle for ordinary enemies and mounted elites.
signal died(kind: String)
signal escaped_screen
signal attack_requested(origin: Vector2, velocity: Vector2, source: int)
const C = preload("res://core/tuning.gd")
const Damage = preload("res://combat/damage.gd")
@export_enum("infantry", "archer", "raider", "elite") var kind := "infantry"
var rider: Node2D
var id := 0
var lane := 1
var hp := 3.0
var max_hp := 3.0
var warning := -1.0
var aim_lane := 1
var fired := false
var contact := false
var escaped := false
var selected := false
var burn_left := 0.0
var burn_tick := 0.0
var active_burn_level := 0
var hit_flash := 0.0
var vx := -C.ENEMY_SPEED
var x: float:
	get: return position.x
	set(value): position.x = value
var y: float:
	get: return position.y
	set(value): position.y = value

func configure(number: int, route: int, start_x: float, player: Node2D) -> void:
	id = number
	lane = route
	aim_lane = route
	position = Vector2(start_x, C.LANE_Y[lane])
	rider = player
	max_hp = 2.0 if kind == "archer" else 3.0
	hp = max_hp

func ground_y() -> float:
	return position.y

func hit_center() -> Vector2:
	return position + Vector2(0, -15)

func damage_multiplier() -> float:
	return 1.0

func take_damage(hit: RefCounted) -> void:
	if hp <= 0.0 or escaped:
		return
	hp = maxf(0.0, hp - hit.amount * damage_multiplier())
	hit_flash = 0.18
	if hit.burn_level > 0 and hp > 0.0:
		active_burn_level = maxi(active_burn_level, hit.burn_level)
		burn_left = maxf(burn_left, 1.5 + active_burn_level * 0.75)
	if hp <= 0.0:
		visible = false
		died.emit(kind)
	queue_redraw()

func step_status(delta: float) -> void:
	hit_flash = maxf(0.0, hit_flash - delta)
	if burn_left > 0.0 and hp > 0.0 and not escaped:
		burn_tick -= minf(delta, burn_left)
		burn_left = maxf(0.0, burn_left - delta)
		while burn_tick <= 0.0 and hp > 0.0:
			burn_tick += 0.5
			take_damage(Damage.new(0.35 * active_burn_level))

func step_movement(delta: float, road_speed: float) -> void:
	# Stationary-world opponent: subtract the rider's extra road speed.
	vx = -C.ENEMY_SPEED - (road_speed - C.ROAD_SPEED)
	x += vx * delta

func step(delta: float, road_speed: float) -> void:
	step_movement(delta, road_speed)
	if x < C.PLAYER_X - 28.0:
		if not escaped and hp > 0.0:
			escaped = true
			escaped_screen.emit()
		queue_redraw()
		return
	step_status(delta)
	if hp <= 0.0:
		return
	if kind == "archer" and x < 400.0 and not fired:
		if warning < 0.0:
			warning = 0.85
			aim_lane = rider.collision_lane()
		warning -= delta
		if warning <= 0.0:
			fired = true
			var aim := Vector2(C.PLAYER_X, C.LANE_Y[aim_lane] - 15.0)
			attack_requested.emit(hit_center(), (aim - hit_center()).normalized() * 260.0, id)
	if absf(x - C.PLAYER_X) < 29.0 and absf(y - rider.ground_y()) < 22.0:
		if rider.charge_left > 0.0:
			take_damage(Damage.new(99.0))
		elif not contact and rider.jump_height() < 20.0:
			contact = true
			rider.hurt()
	queue_redraw()

func _draw() -> void:
	var color := Color("bf644e") if kind == "infantry" else Color("ba85cc")
	if kind == "raider":
		color = Color("e3a34c")
	if escaped:
		color = color.darkened(0.5)
	if warning > 0.0 and not fired and not escaped:
		var aim := Vector2(C.PLAYER_X, C.LANE_Y[aim_lane] - 15.0) - position
		draw_line(Vector2(0, -15), aim, Color("eeaa56"), 1.0)
		draw_arc(aim, 15.0, 0.0, TAU, 24, Color("eeaa56"), 2.0)
	if kind in ["infantry", "raider"] and x < C.PLAYER_X + 100.0 and not escaped:
		draw_line(Vector2(-24, 8), Vector2(16, 8), Color("ff9d64"), 3.0)
	draw_rect(Rect2(-9, -22, 18, 24), color)
	draw_circle(Vector2(0, -28), 6.0, Color("e6c49a"))
	if kind in ["infantry", "raider"]:
		draw_line(Vector2(-14, 0), Vector2(-14, -37), Color("d7d5c7"), 2.0)
	else:
		draw_arc(Vector2(-11, -18), 10.0, PI / 2.0, PI * 1.5, 8, Color("e7c988"), 2.0)
	draw_rect(Rect2(-12, -41, 24, 3), Color("302e38"))
	draw_rect(Rect2(-12, -41, 24.0 * hp / max_hp, 3), Color("b8d789"))
	if selected and not escaped:
		draw_circle(Vector2(0, -49), 3.0, Color("fff1ba"))
	draw_status()

func draw_status() -> void:
	if burn_left > 0.0 and not escaped:
		draw_circle(Vector2(10, -35), 4.0, Color("ff8a42"))
	if hit_flash > 0.0:
		draw_circle(Vector2(0, -15), 4.0 + hit_flash * 20.0, Color("fff1ba"))
