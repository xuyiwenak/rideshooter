extends SceneTree

const C = preload("res://core/tuning.gd")
const Damage = preload("res://combat/damage.gd")
const Brain = preload("res://enemies/elite/elite_brain.gd")
var failures := 0
var checks := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func _initialize() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.initialize()
	game.initialize()
	var enemy = game.combat.spawn_enemy(1, 350.0, "infantry")
	enemy.take_damage(Damage.new(99.0))
	enemy.take_damage(Damage.new(99.0))
	check(game.combat.kills == 1 and game.growth.war_spirit == 1, "Death signal rewards exactly once, including repeated initialization")
	game.combat.cleanup()
	game.reset_run()
	check(game.combat.get_child_count() == 0 and game.combat.enemies.is_empty(), "Restart frees active and retired actor nodes")
	game.director.start_elite()
	var elite = game.combat.enemies[0]
	game.bow.shot_left = 999.0
	elite.state = "AIM"
	elite.timer = 0.7
	elite.brain.commit("spear")
	game.road.obstacles.append({"x": 300.0, "lane": 0, "resolved": false})
	game.combat.spawn_arrow({"pos": Vector2(240, 151), "velocity": Vector2(420, 0), "hostile": false, "source": 0, "damage": 1.0})
	game.growth.gain(3)
	var road_before: float = game.road.road_scroll
	var arrow_before: Vector2 = game.combat.arrows[0].pos
	game._process(0.25)
	check(game.road.road_scroll == road_before and elite.timer == 0.7 and elite.brain.cooldowns.spear == 6.0 and game.combat.arrows[0].pos == arrow_before and game.road.obstacles[0].x == 300.0, "Upgrade freezes road, actor AI, projectiles and cooldowns together")
	game.growth.choose(0)
	game._process(0.1)
	check(elite.timer < 0.7 and game.road.road_scroll > road_before and game.director.run_left == C.RUN_TIME, "Selecting a skill resumes combat while elite road gate stays closed")
	game.reset_run()
	game.bow.shot_left = 999.0
	enemy = game.combat.spawn_enemy(0, 350.0, "infantry")
	game.road.obstacles.append({"x": 350.0, "lane": 0, "resolved": false})
	game._process(0.2)
	var normal_x: float = enemy.x
	var normal_obstacle: float = game.road.obstacles[0].x
	var normal_distance: float = game.road.road_scroll
	game.reset_run()
	game.bow.shot_left = 999.0
	enemy = game.combat.spawn_enemy(0, 350.0, "infantry")
	game.road.obstacles.append({"x": 350.0, "lane": 0, "resolved": false})
	game.rider.handle_key(KEY_E)
	game._process(0.2)
	check(enemy.x < normal_x and game.road.obstacles[0].x < normal_obstacle and game.road.road_scroll > normal_distance, "Sprint accelerates ground, obstacles and ordinary enemies consistently")
	check(game.rider.position.x == C.PLAYER_X and is_equal_approx(game.rider.charge_cooldown_left, C.CHARGE_COOLDOWN - 0.2), "Rider remains fixed horizontally and cooldown uses wall time")
	game.rider.handle_key(KEY_A)
	game.rider.handle_key(KEY_D)
	check(game.rider.position.x == C.PLAYER_X, "No left-right movement introduced")
	game.reset_run("elite")
	elite = game.combat.enemies[0]
	game.bow.shot_left = 999.0
	elite.state = "AIM"
	elite.timer = 0.3
	elite.aim_lane = 1
	game.rider.lane = 0
	game.rider.target_lane = 0
	game.combat.step(0.31)
	check(elite.state == "THROW" and elite.aim_lane == 1 and game.combat.arrows.size() == 1, "Spear fires once at the previously locked lane")
	var arrow = game.combat.arrows[0]
	var expected: Vector2 = (Vector2(C.PLAYER_X, C.LANE_Y[1] - 15.0) - elite.hit_center()).normalized()
	check(arrow.velocity.normalized().is_equal_approx(expected), "Spear direction follows telegraph rather than latest player lane")
	game.combat.step(0.05)
	check(game.combat.arrows.size() == 1 and elite.decision_count == 0, "Committed attack neither redecides nor fires twice")
	game.reset_run("elite")
	elite = game.combat.enemies[0]
	game.bow.shot_left = 999.0
	elite.state = "CHARGE"
	elite.x = 160.0
	game.rider.charge_left = 0.4
	elite.step(0.1)
	elite.step(0.3)
	check(elite.state == "OPEN" and elite.timer == 2.4 and game.rider.health == 3, "Counter-charge earns a longer safe damage window")
	var brain = Brain.new()
	check(brain.choose(260.0, true) == "charge" and brain.choose(360.0, false) == "reposition", "Position changes decision without player input reading")
	brain.commit("charge")
	check(brain.choose(260.0, true) == "spear", "Attack cooldown enables another attack")
	brain.step(10.0)
	brain.commit("spear")
	brain.step(10.0)
	brain.commit("spear")
	brain.step(10.0)
	check(brain.choose(360.0, false) != "spear", "Same attack cannot be chosen three consecutive times")
	game.reset_run()
	game.build.skill_levels.burn = 2
	enemy = game.combat.spawn_enemy(0, 80.0, "infantry")
	enemy.burn_left = 3.0
	enemy.active_burn_level = 2
	enemy.hp = 0.1
	game.combat.step(0.1)
	check(enemy.escaped and game.combat.kills == 0 and game.growth.war_spirit == 0, "Escaped enemies cannot grant late burning rewards")
	# Real combat, real level choices and the elite gate in one simulation.
	game.reset_run()
	for frame in 16000:
		game.rider.health = 3
		if game.growth.upgrade_open:
			game.growth.choose(0)
		var target = game.bow.pick_target()
		if target != null:
			game.rider.start_switch(clampi(target.lane - game.rider.lane, -1, 1))
		game._process(1.0 / 60.0)
		if game.director.finished():
			break
	check(game.director.finished() and game.director.elite_defeated and game.build.arrow_rain, "Complete run earns an evolution and clears elite through actual combat")
	game.reset_run()
	check(game.combat.get_child_count() == 0 and game.rider.health == 3 and not game.build.arrow_rain and not game.growth.upgrade_open, "Final reset clears entities, build and choice state")
	game.free()
	print("Integration checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)
