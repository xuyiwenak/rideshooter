extends SceneTree

const C = preload("res://core/tuning.gd")
var checks := 0
var failures := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func _initialize() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.initialize()
	game.set_process(false)
	game.bow.shot_left = 999.0
	var fixed = game.combat.spawn_enemy(0, 420.0, "infantry")
	var raider = game.combat.spawn_enemy(0, 420.0, "raider")
	game.combat.step(0.01)
	check(raider.move_state == "WARN" and raider.destination_lane == 1 and raider.y == C.LANE_Y[0], "Raider warns before adjacent lane change")
	check(raider.x < fixed.x and fixed.lane == 0, "Raider approaches faster while infantry holds its lane")
	game.rider.lane = 2
	game.rider.target_lane = 2
	for frame in 48:
		game.combat.step(1.0 / 60.0)
	check(raider.lane == 1 and is_equal_approx(raider.y, C.LANE_Y[1]), "Committed move ignores new player lane and never skips a lane")
	check(raider.move_cooldown > 0.0 and fixed.lane == 0, "Lane change has recovery and fixed enemy stays fixed")
	game.reset_run()
	game.bow.shot_left = 999.0
	raider = game.combat.spawn_enemy(0, C.PLAYER_X + 100.0, "raider")
	game.combat.step(0.01)
	check(raider.move_state == "CHASE", "No last-second lane switch beside player")
	raider.x = 400.0
	game.combat.step(0.01)
	game.growth.gain(3)
	var timer: float = raider.move_left
	var pos: Vector2 = raider.position
	game._process(0.2)
	check(raider.move_left == timer and raider.position == pos, "Upgrade pauses mobile enemy warning and movement")
	game.growth.choose(0)
	game._process(0.1)
	check(raider.move_left < timer, "Mobile enemy resumes after choice")
	game.reset_run()
	game.bow.shot_left = 999.0
	raider = game.combat.spawn_enemy(1, C.PLAYER_X + 5, "raider")
	raider.y = C.LANE_Y[0]
	game.combat.step(0.001)
	check(game.rider.health == 3, "Contact uses visible position, not destination lane")
	raider.y = C.LANE_Y[1]
	game.combat.step(0.001)
	check(game.rider.health == 2, "Raider contact damages player when physically aligned")
	game.reset_run()
	game.build.acquire("shield")
	game.rider.handle_key(KEY_E)
	game.rider.hurt()
	check(game.rider.health == 3 and game.rider.shield_active, "Sprint iframe blocks damage without consuming shield")
	game.bow.shot_left = 999.0
	var archer = game.combat.spawn_enemy(0, 450.0, "archer")
	game.combat.fire_hostile(game.rider.hit_center(), Vector2.ZERO, archer.id)
	game.combat.step(0.01)
	check(game.rider.health == 3 and game.rider.shield_active and game.combat.arrows.is_empty(), "Sprint evades projectile and consumes projectile, not shield")
	game.road.obstacles.append({"x": C.PLAYER_X + 1, "lane": 1, "resolved": false})
	game.road.step_obstacles(0.01)
	check(game.rider.health == 3 and game.rider.shield_active, "Sprint also blocks obstacle damage")
	game.rider.step(C.CHARGE_TIME)
	game.rider.shield_active = false
	game.rider.hurt()
	check(game.rider.health == 2, "Sprint immunity ends with its window")
	game.reset_run()
	game.director.spawn_group(1)
	var lanes: Array[int] = []
	var kinds: Array[String] = []
	for enemy in game.combat.enemies:
		lanes.append(enemy.lane)
		kinds.append(enemy.kind)
	check(lanes.has(0) and lanes.has(1) and lanes.has(2) and kinds.has("infantry") and kinds.has("raider"), "Encounter mixes fixed and mobile enemies across all three lanes")
	game.reset_run()
	check(game.combat.get_child_count() == 0, "Restart removes mobile enemy state")
	game.free()
	print("Raider checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)
