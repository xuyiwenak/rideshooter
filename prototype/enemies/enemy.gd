extends Node2D
## Common lifecycle for ordinary enemies and mounted elites.
signal died(kind: String)
signal escaped_screen
signal attack_requested(origin: Vector2, velocity: Vector2, source: int)
const C = preload("res://core/tuning.gd")
const Damage = preload("res://combat/damage.gd")
@export var bow_config: BowConfig = preload("res://config/weapons/bow_default.tres")
@export_enum("infantry", "archer", "raider", "elite") var kind := "infantry"
@export var visual_frames: SpriteFrames
@export var visual_size := Vector2(48, 48)
var visual_clock := 0.0
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
		var durations: Array[float] = [0.0, bow_config.burn_level_1_duration, bow_config.burn_level_2_duration]
		burn_left = maxf(burn_left, durations[active_burn_level])
	if hp <= 0.0:
		visible = false
		died.emit(kind)
	queue_redraw()

func step_status(delta: float) -> void:
	if hp > 0.0 and not escaped:
		visual_clock += delta
	hit_flash = maxf(0.0, hit_flash - delta)
	if burn_left > 0.0 and hp > 0.0 and not escaped:
		burn_tick -= minf(delta, burn_left)
		burn_left = maxf(0.0, burn_left - delta)
		while burn_tick <= 0.0 and hp > 0.0:
			burn_tick += bow_config.burn_tick_interval
			var tick_damage: float = [0.0, bow_config.burn_level_1_tick_damage,
				bow_config.burn_level_2_tick_damage][active_burn_level]
			take_damage(Damage.new(tick_damage))

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
	if warning > 0.0 and not fired and not escaped:
		var aim := Vector2(C.PLAYER_X, C.LANE_Y[aim_lane] - 15.0) - position
		draw_line(Vector2(0, -15), aim, Color("eeaa56"), 1.0)
		draw_arc(aim, 15.0, 0.0, TAU, 24, Color("eeaa56"), 2.0)
	if kind in ["infantry", "raider"] and x < C.PLAYER_X + 100.0 and not escaped:
		draw_line(Vector2(-24, 8), Vector2(16, 8), Color("ff9d64"), 3.0)
	draw_character()
	draw_status()

func draw_status() -> void:
	if burn_left > 0.0 and not escaped:
		draw_circle(Vector2(10, -35), 4.0, Color("ff8a42"))
	if hit_flash > 0.0:
		draw_circle(Vector2(0, -15), 4.0 + hit_flash * 20.0, Color("fff1ba"))

func visual_animation() -> StringName:
	if kind == "archer":
		if fired:
			return &"release"
		if warning > 0.0:
			return &"aim"
	return &"run"

func visual_frame() -> int:
	var animation := visual_animation()
	if visual_frames == null or not visual_frames.has_animation(animation):
		return 0
	var count := visual_frames.get_frame_count(animation)
	return int(visual_clock * visual_frames.get_animation_speed(animation)) % maxi(count, 1)

func draw_character() -> void:
	if visual_frames == null:
		return
	var animation := visual_animation()
	var texture := visual_frames.get_frame_texture(animation, visual_frame())
	# Every atlas uses a square canvas: pivot x=50%, foot y=440/512.
	# Appearance never changes hit_center(), contact ranges or arrow collision.
	var tint := Color(0.5, 0.5, 0.5) if escaped else Color.WHITE
	draw_ellipse(Vector2(0, 5), visual_size.x * 0.24, 2.5, Color(0, 0, 0, 0.22))
	var pulse := sin(clampf(hit_flash / 0.18, 0.0, 1.0) * PI)
	var size := visual_size * Vector2(1.0 + pulse * 0.10, 1.0 - pulse * 0.10)
	if hit_flash > 0.11:
		tint = Color(2.0, 2.0, 2.0)
	draw_texture_rect(texture, Rect2(Vector2(-size.x * 0.5,
		4.0 - size.y * 440.0 / 512.0), size), false, tint)
