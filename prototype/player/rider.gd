extends Node2D
## Owns rider movement, health, shield and placeholder visuals.
const C = preload("res://core/tuning.gd")
var build: Node
var lane := 1
var target_lane := 1
var switch_left := 0.0
var jump_left := 0.0
var charge_left := 0.0
var charge_cooldown_left := 0.0
var invulnerable_left := 0.0
var health := 3
var shield_active := false
var shield_restore_left := 0.0
var gait_phase := 0.0

func reset() -> void:
	lane = 1
	target_lane = 1
	switch_left = 0.0
	jump_left = 0.0
	charge_left = 0.0
	charge_cooldown_left = 0.0
	invulnerable_left = 0.0
	health = 3
	shield_active = false
	shield_restore_left = 0.0
	gait_phase = 0.0
	position = Vector2(C.PLAYER_X, ground_y())
	queue_redraw()

func step(delta: float) -> void:
	gait_phase += delta * (22.0 if charge_left > 0.0 else 14.0)
	switch_left = maxf(0.0, switch_left - delta)
	if switch_left == 0.0:
		lane = target_lane
	jump_left = maxf(0.0, jump_left - delta)
	charge_left = maxf(0.0, charge_left - delta)
	charge_cooldown_left = maxf(0.0, charge_cooldown_left - delta)
	invulnerable_left = maxf(0.0, invulnerable_left - delta)
	if not shield_active and build.skill_levels.shield > 0:
		shield_restore_left = maxf(0.0, shield_restore_left - delta)
		if shield_restore_left == 0.0:
			shield_active = true
	position = Vector2(C.PLAYER_X, ground_y() - jump_height())
	queue_redraw()

func handle_key(key: int) -> void:
	if (key == KEY_W or key == KEY_UP) and switch_left == 0.0:
		start_switch(-1)
	elif (key == KEY_S or key == KEY_DOWN) and switch_left == 0.0:
		start_switch(1)
	elif key == KEY_SPACE and jump_left == 0.0:
		jump_left = C.JUMP_TIME
	elif (key == KEY_SHIFT or key == KEY_E) and charge_cooldown_left == 0.0:
		charge_left = C.CHARGE_TIME
		charge_cooldown_left = C.CHARGE_COOLDOWN
		if build.iron_cavalry:
			shield_active = true
	queue_redraw()

func on_skill_acquired(skill: String) -> void:
	if skill == "shield":
		shield_active = true
		shield_restore_left = 0.0
	queue_redraw()

func heal(amount: int) -> void:
	health = mini(3, health + amount)

func hit_center() -> Vector2:
	return Vector2(C.PLAYER_X, ground_y() - jump_height() - 15.0)

func start_switch(direction: int) -> void:
	var next_lane := clampi(lane + direction, 0, 2)
	if next_lane != lane:
		target_lane = next_lane
		switch_left = C.SWITCH_TIME

func collision_lane() -> int:
	if switch_left > C.SWITCH_TIME / 2.0:
		return lane
	return target_lane

func ground_y() -> float:
	if switch_left == 0.0:
		return C.LANE_Y[target_lane]
	var t := 1.0 - switch_left / C.SWITCH_TIME
	return lerpf(C.LANE_Y[lane], C.LANE_Y[target_lane], t * t * (3.0 - 2.0 * t))

func jump_height() -> float:
	if jump_left == 0.0:
		return 0.0
	return sin((1.0 - jump_left / C.JUMP_TIME) * PI) * 36.0

func hurt() -> void:
	if invulnerable_left <= 0.0 and charge_left <= 0.0:
		if shield_active:
			shield_active = false
			shield_restore_left = build.shield_restore_time()
			invulnerable_left = 0.35
			return
		health = maxi(0, health - 1)
		invulnerable_left = 0.9

func _draw() -> void:
	var py := 0.0
	var horse_color := Color("d9a061") if invulnerable_left == 0.0 else Color("fff5d7")
	if charge_left > 0.0:
		for trail in 3:
			draw_line(Vector2(-32 - trail * 11, -10 + trail * 6), Vector2(-50 - trail * 11, -10 + trail * 6), Color("d6c89b"), 2.0)
		horse_color = Color("f0c37b")
	draw_ellipse(Vector2(0, jump_height() + 14.0), 23.0, 4.0, Color(0, 0, 0, 0.28))
	draw_rect(Rect2(-22.0, py - 19.0, 43.0, 17.0), horse_color)
	draw_rect(Rect2(12.0, py - 28.0, 13.0, 16.0), horse_color)
	var stride := sin(gait_phase) * 4.0 if jump_left == 0.0 else 0.0
	draw_line(Vector2(-14, -3), Vector2(-14 + stride, 9), Color("765341"), 5.0)
	draw_line(Vector2(12, -3), Vector2(12 - stride, 9), Color("765341"), 5.0)
	draw_rect(Rect2(-10.0, py - 35.0, 14.0, 17.0), Color("4074a0"))
	draw_circle(Vector2(-3.0, py - 41.0), 7.0, Color("e6c49a"))
	draw_line(Vector2(3.0, py - 29.0), Vector2(23.0, py - 33.0), Color("e7c988"), 2.0)
	if shield_active:
		draw_arc(Vector2(0, py - 17.0), 31.0, 0.0, TAU, 32, Color("8ed9e8"), 2.0)
