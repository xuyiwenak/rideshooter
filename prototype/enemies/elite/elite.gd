extends "res://enemies/enemy.gd"
## Executes committed attacks. Brain sees only distance/lane/cooldown history.
const Brain = preload("res://enemies/elite/elite_brain.gd")
var brain = Brain.new()
var state := "APPROACH"
var timer := 1.2
var recovery_time := 1.8
var decision_count := 0

func configure(number: int, route: int, start_x: float, player: Node2D) -> void:
	super.configure(number, route, start_x, player)
	max_hp = C.ELITE_HP
	hp = max_hp
	vx = 0.0

func damage_multiplier() -> float:
	return 1.5 if state == "OPEN" else 1.0

func choose_action() -> void:
	decision_count += 1
	var action: String = brain.choose(x - C.PLAYER_X, lane == rider.collision_lane())
	brain.commit(action)
	match action:
		"charge":
			lane = rider.collision_lane()
			state = "CHANGE LANE"
			timer = 0.5
			contact = false
			recovery_time = 1.8
		"spear":
			aim_lane = rider.collision_lane()
			state = "AIM"
			timer = 0.95
		"reposition":
			lane = rider.collision_lane() if lane != rider.collision_lane() else (lane + 1) % 3
			state = "REPOSITION"
			timer = 0.65
		"wait":
			state = "APPROACH"
			timer = 0.4

func step(delta: float, _road_speed: float = C.ROAD_SPEED) -> void:
	step_status(delta)
	if hp <= 0.0:
		return
	brain.step(delta)
	var old_x := x
	timer = maxf(0.0, timer - delta)
	match state:
		"APPROACH":
			x = move_toward(x, 390.0, 90.0 * delta)
			if timer == 0.0:
				choose_action()
		"CHANGE LANE", "REPOSITION":
			y = move_toward(y, C.LANE_Y[lane], 300.0 * delta)
			if state == "REPOSITION":
				x = move_toward(x, 410.0, 120.0 * delta)
			if timer == 0.0:
				y = C.LANE_Y[lane]
				if state == "CHANGE LANE":
					state = "LOCKED"
					timer = 0.9
				else:
					state = "APPROACH"
					timer = 0.6
		"LOCKED":
			if timer == 0.0:
				state = "CHARGE"
				contact = false
		"CHARGE":
			x = move_toward(x, C.PLAYER_X + 18.0, 460.0 * delta)
			if absf(x - C.PLAYER_X) < 35.0 and lane == rider.collision_lane() and not contact:
				if rider.charge_left > 0.0:
					contact = true
					recovery_time = 2.4
					take_damage(Damage.new(rider.build.counter_damage()))
				elif rider.jump_height() < 20.0:
					contact = true
					rider.hurt()
			if x <= C.PLAYER_X + 18.0:
				state = "RECOIL"
		"RECOIL":
			x = move_toward(x, 225.0, 380.0 * delta)
			if x == 225.0:
				state = "OPEN"
				timer = recovery_time
		"OPEN", "THROW":
			if timer == 0.0:
				state = "RETURN"
		"AIM":
			if timer == 0.0:
				var aim := Vector2(C.PLAYER_X, C.LANE_Y[aim_lane] - 15.0)
				attack_requested.emit(hit_center(), (aim - hit_center()).normalized() * 260.0, id)
				state = "THROW"
				timer = 0.6
		"RETURN":
			x = move_toward(x, 390.0, 200.0 * delta)
			if x == 390.0:
				state = "APPROACH"
				timer = 0.8
	vx = (x - old_x) / maxf(delta, 0.00001)
	queue_redraw()

func state_color() -> Color:
	if state in ["LOCKED", "CHARGE"]:
		return Color("f77862")
	if state == "AIM":
		return Color("d4a0f2")
	if state == "OPEN":
		return Color("aade99")
	if state in ["RETURN", "RECOIL", "REPOSITION"]:
		return Color("8fabbc")
	return Color("e9ad52")

func _draw() -> void:
	var color := state_color()
	if state in ["LOCKED", "CHARGE"]:
		draw_rect(Rect2(Vector2(75, y - 27) - position, Vector2(345, 47)), Color(1, 0.3, 0.2, 0.18))
		draw_line(Vector2(75, y + 18) - position, Vector2(420, y + 18) - position, color, 3.0)
	if state == "AIM":
		var aim := Vector2(C.PLAYER_X, C.LANE_Y[aim_lane] - 15) - position
		draw_line(Vector2(0, -15), aim, color, 2.0)
		draw_arc(aim, 17.0, 0.0, TAU, 24, color, 2.0)
	# Left-facing boar captain shares the ordinary enemy visual clock.
	draw_ellipse(Vector2(0, 7), 26.0, 3.0, Color(color, 0.6))
	draw_character()
	draw_status()

func visual_animation() -> StringName:
	match state:
		"AIM": return &"aim"
		"THROW": return &"release"
		"LOCKED", "CHARGE": return &"charge"
		"OPEN", "RECOIL": return &"recover"
	return &"run"
