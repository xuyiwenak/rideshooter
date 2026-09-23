extends SceneTree

const C = preload("res://core/tuning.gd")
const Damage = preload("res://combat/damage.gd")

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
	game.initialize()
	game.set_process(false)
	game.growth.enabled = false
	game.combat.spawn_enemy(0, 250.0, "infantry")
	game.combat.spawn_enemy(1, 400.0, "infantry")
	check(game.bow.pick_target().lane == 1, "Current lane priority")
	game.rider.lane = 0
	game.rider.target_lane = 0
	check(game.bow.pick_target().lane == 0, "Switch changes target")
	game.bow.shoot(game.bow.pick_target())
	check(game.combat.arrows.back().damage == 1.0, "Same lane full damage")
	game.combat.enemies[0].free()
	game.combat.enemies.remove_at(0)
	game.bow.shoot(game.bow.pick_target())
	check(game.combat.arrows.back().damage == 0.5, "Adjacent lane half damage")
	game.reset_run()
	game.growth.enabled = false
	game.combat.spawn_enemy(1, 350.0, "infantry")
	for frame in 150:
		game.combat.step(1.0 / 60.0)
	check(game.combat.kills == 1, "Automatic arrows kill infantry")
	game.reset_run()
	game.growth.enabled = false
	game.bow.shot_left = 99.0
	game.combat.spawn_enemy(0, 90.0, "archer")
	game.combat.step(0.016)
	check(game.combat.escaped == 1 and game.rider.health == 3 and game.combat.arrows.is_empty(), "Escape without damage or attack")
	game.combat.step(0.016)
	check(game.combat.escaped == 1, "Escape counted once")
	game.reset_run()
	game.growth.enabled = false
	game.bow.shot_left = 99.0
	game.combat.spawn_enemy(0, 390.0, "archer")
	game.combat.step(0.016)
	check(game.combat.enemies[0].warning > 0.0 and game.combat.arrows.is_empty(), "Archer warns first")
	game.rider.lane = 2
	game.rider.target_lane = 2
	for frame in 55:
		game.combat.step(1.0 / 60.0)
	check(game.combat.enemies[0].aim_lane == 1 and not game.combat.arrows.is_empty(), "Archer locks lane before firing")
	game.combat.enemies[0].x = 80.0
	game.combat.step(0.016)
	check(game.combat.arrows.is_empty(), "Escaped archer clears projectiles")
	game.reset_run()
	game.growth.enabled = false
	game.bow.shot_left = 99.0
	game.rider.charge_left = 0.4
	game.combat.spawn_enemy(1, 140.0, "infantry")
	game.combat.step(0.016)
	check(game.combat.kills == 1 and game.rider.health == 3, "Charge kills without damage")
	game.reset_run()
	game.growth.enabled = false
	game.bow.shot_left = 99.0
	game.rider.jump_left = C.JUMP_TIME / 2.0
	game.combat.spawn_enemy(1, 140.0, "infantry")
	game.combat.step(0.016)
	check(game.rider.health == 3, "Jump avoids contact")
	game.rider.jump_left = 0.0
	game.combat.step(0.016)
	game.combat.step(0.016)
	check(game.rider.health == 2, "Contact only damages once")
	game.rider.hurt()
	check(game.rider.health == 2, "Invulnerability prevents stacking")
	game.reset_run()
	game.growth.enabled = false
	check(game.combat.enemies.is_empty() and game.combat.arrows.is_empty() and game.combat.kills == 0 and game.rider.health == 3, "Restart clears state")
	for group in 3:
		game.director.spawn_group(group)
	check(game.combat.enemies.size() == 8 and game.road.obstacles.size() == 1, "Three encounter groups")
	game.reset_run()
	game.growth.enabled = false
	# Isolate the ordinary-combat schedule from the elite road gate.
	game.director.elite_started = true
	game.director.elite_defeated = true
	for frame in 3660:
		game.rider.health = 3
		game._process(1.0 / 60.0)
	check(game.director.run_left == 0.0 and game.director.spawn_index == 10, "Full minute schedule completes")
	game.reset_run()
	game.growth.enabled = false
	game.rider.health = 0
	game._process(1.0)
	check(game.director.run_left == C.RUN_TIME, "Death freezes simulation")
	game.free()
	print("Combat checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)
