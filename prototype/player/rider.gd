extends Node2D
## Owns rider movement, health, shield and clock-driven horse visuals.
signal shield_blocked(at: Vector2)
const C = preload("res://core/tuning.gd")
const HORSE_FRAMES = preload("res://asset/runtime/characters/horse_hiphop/horse_hiphop_sprite_frames.tres")
var hoof_dust: Array[Dictionary] = []
var dust_left := 0.0
var visual: Node2D:
	get:
		return $Visual
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
	visual.set_shot_pose(-1)
	visual.sync_pose(0, false, false, false)
	hoof_dust.clear()
	dust_left = 0.0
	position = Vector2(C.PLAYER_X, ground_y())
	queue_redraw()

func step(delta: float) -> void:
	var was_airborne := jump_left > 0.0
	if not was_airborne:
		gait_phase = fmod(gait_phase + delta * HORSE_FRAMES.get_animation_speed(&"run") * (1.6 if charge_left > 0.0 else 1.0), HORSE_FRAMES.get_frame_count(&"run"))
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
	step_dust(delta, was_airborne and jump_left == 0.0)
	visual.sync_pose(int(gait_phase), charge_left > 0.0, jump_left > 0.0, invulnerable_left > 0.0 and fmod(invulnerable_left, 0.16) < 0.08)
	queue_redraw()

func step_dust(delta: float, landed: bool) -> void:
	# World positions leave old dust on its original lane during jumps/switches.
	for puff in hoof_dust:
		puff.life -= delta
		puff.pos += Vector2(-65.0, -8.0) * delta
	hoof_dust = hoof_dust.filter(func(puff: Dictionary) -> bool: return puff.life > 0.0)
	if jump_left > 0.0:
		dust_left = 0.0
		return
	dust_left -= delta
	if dust_left <= 0.0 or landed:
		dust_left = 0.06 if charge_left > 0.0 else 0.12
		for index in (3 if landed else 1):
			hoof_dust.append({"pos": Vector2(C.PLAYER_X - 22.0 - index * 5.0, ground_y() + 9.0), "life": 0.45, "size": 4.0 if charge_left > 0.0 or landed else 2.5})

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

func arrow_origin() -> Vector2:
	return Vector2(C.PLAYER_X, ground_y() - jump_height()) + visual.muzzle()

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
			shield_blocked.emit(hit_center())
			return
		health = maxi(0, health - 1)
		invulnerable_left = 0.9

func _draw() -> void:
	var py := 0.0
	for puff in hoof_dust:
		var age: float = 1.0 - puff.life / 0.45
		draw_circle(puff.pos - position, puff.size * (1.0 + age), Color(0.8, 0.72, 0.54, (1.0 - age) * 0.6))
	if charge_left > 0.0:
		for trail in 3:
			draw_line(Vector2(-32 - trail * 11, -10 + trail * 6), Vector2(-50 - trail * 11, -10 + trail * 6), Color("d6c89b"), 2.0)
	draw_ellipse(Vector2(0, jump_height() + 11.0), 25.0, 4.0, Color(0, 0, 0, 0.28))
	var tint := Color(1.0, 1.0, 1.0, 0.5) if invulnerable_left > 0.0 and fmod(invulnerable_left, 0.16) < 0.08 else Color.WHITE
	# 512px virtual frame, feet at y440; same ground/attack anchors as graybox.
	draw_texture_rect(HORSE_FRAMES.get_frame_texture(&"run", int(gait_phase)), Rect2(-36.0, 9.0 - 440.0 * 72.0 / 512.0, 72.0, 72.0), false, tint)
	if shield_active:
		draw_arc(Vector2(0, py - 17.0), 31.0, 0.0, TAU, 32, Color("8ed9e8"), 2.0)
