extends SceneTree
## Exercises Inspector resources through the real scene and kill signals.
const Damage = preload("res://combat/damage.gd")
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
	var default_growth: GrowthConfig = game.growth.config
	var default_encounter: EncounterConfig = game.director.config
	check(default_growth.normal_kill_reward == 2 and default_growth.elite_kill_reward == 8,
		"Default rewards load from the growth resource")
	check(default_encounter.wave_interval == 5.0 and default_encounter.patterns.size() == 3,
		"Wave timing and composition load from the encounter resource")

	var custom_growth := GrowthConfig.new()
	custom_growth.first_upgrade_cost = 4
	custom_growth.cost_increase_per_level = 2
	custom_growth.normal_kill_reward = 3
	custom_growth.elite_kill_reward = 11
	game.growth.config = custom_growth
	game.reset_run()
	check(game.growth.war_spirit_need == 4, "Restart initializes custom first upgrade cost")
	game.combat.spawn_enemy(1, 350.0, "infantry").take_damage(Damage.new(99.0))
	check(game.growth.war_spirit == 3 and not game.growth.upgrade_open,
		"Normal kill pays the configured amount exactly once")
	game.director.start_elite()
	game.combat.elite_actor().take_damage(Damage.new(99.0))
	check(game.growth.growth_level == 2 and game.growth.war_spirit == 4
		and game.growth.war_spirit_need == 8 and game.growth.pending_upgrades == 2,
		"Elite reward and per-level cost apply with overflow")

	var custom_encounter := EncounterConfig.new()
	custom_encounter.run_length = 42.0
	custom_encounter.elite_trigger_remaining = 21.0
	custom_encounter.pre_elite_spawn_stop_remaining = 25.0
	custom_encounter.first_wave_delay = 0.7
	custom_encounter.wave_interval = 2.0
	custom_encounter.elite_spawn_lane = 0
	custom_encounter.elite_spawn_x = 430.0
	custom_encounter.lane_cycle = PackedInt32Array([2])
	var pattern := WavePattern.new()
	var spawn := WaveEnemy.new()
	spawn.kind = "archer"
	spawn.lane_offset = 1
	spawn.start_x = 555.0
	pattern.enemies.append(spawn)
	pattern.has_obstacle = true
	pattern.obstacle_lane_offset = 2
	pattern.obstacle_start_x = 700.0
	custom_encounter.patterns.append(pattern)
	game.director.config = custom_encounter
	game.reset_run()
	check(game.director.run_left == 42.0 and game.director.spawn_left == 0.7,
		"Custom road length and first wave delay initialize together")
	game.director.step(0.69)
	check(game.combat.enemies.is_empty(), "No wave before configured first delay")
	game.director.step(0.02)
	check(game.combat.enemies.size() == 1 and game.combat.enemies[0].kind == "archer"
		and game.combat.enemies[0].lane == 0 and game.combat.enemies[0].x == 555.0,
		"Custom wave entry controls count, kind, lane and position")
	check(game.road.obstacles.size() == 1 and game.road.obstacles[0].lane == 1
		and game.road.obstacles[0].x == 700.0 and is_equal_approx(game.director.spawn_left, 1.99),
		"Obstacle placement and repeat interval use encounter config")
	game.director.step(25.0)
	check(game.director.run_left == 21.0 and game.director.elite_active()
		and game.combat.elite_actor().lane == 0 and game.combat.elite_actor().x == 430.0,
		"Configured elite gate clamps road and uses elite spawn settings")

	game.growth.config = default_growth
	game.director.config = default_encounter
	game.reset_run()
	# Advance the director's road clock; all spawned enemies stay alive to count the budget.
	for frame in 5000:
		game.director.step(1.0 / 60.0)
		if game.director.elite_active():
			game.combat.elite_actor().take_damage(Damage.new(99.0))
			game.combat.cleanup()
		if game.director.finished():
			break
	check(game.director.finished() and game.director.elite_defeated
		and game.director.spawn_index == 11 and game.combat.enemies.size() == 33,
		"Full configured road creates eleven three-enemy waves and one elite")
	for enemy in game.combat.enemies.duplicate():
		enemy.take_damage(Damage.new(99.0))
	game.combat.cleanup()
	check(game.combat.kills == 34 and game.growth.growth_level == 9
		and game.growth.pending_upgrades == 9 and game.growth.war_spirit == 11,
		"Thirty-three normal kills plus elite grant 74 spirit and nine upgrades")
	for choice in 9:
		game.growth.choose(0)
	check(game.build.arrow_rain and game.growth.pending_upgrades == 0
		and not game.growth.upgrade_open,
		"Nine earned choices resolve without breaking the existing skill pool")
	game.reset_run()
	check(game.growth.war_spirit_need == default_growth.first_upgrade_cost
		and game.director.run_left == default_encounter.run_length
		and game.director.spawn_index == 0 and game.combat.enemies.is_empty(),
		"Restart resets configured growth and encounter state")
	game.free()
	print("Run config checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)
