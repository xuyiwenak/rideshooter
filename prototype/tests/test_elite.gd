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
	game.director.start_elite()
	var elite = game.combat.enemies[0]
	var states := {}
	game.bow.shot_left = 1000.0
	for frame in 1800:
		game.rider.health = 3
		game._process(1.0 / 60.0)
		states[elite.state] = true
	check(states.has("LOCKED") and states.has("CHARGE") and states.has("OPEN") and states.has("AIM") and states.has("THROW"), "Elite uses both committed attacks and recovery")
	check(game.director.run_left == C.RUN_TIME and game.road.road_scroll > 0.0, "Road pauses but background moves")
	check(game.director.spawn_index == 0 and game.combat.enemies.size() == 1, "No ordinary waves during elite")
	check(elite.x >= C.PLAYER_X + 18.0 and elite.x <= 450.0 and not elite.escaped, "Elite stays onscreen")
	game.reset_run()
	game.growth.enabled = false
	game.director.start_elite()
	elite = game.combat.enemies[0]
	elite.step(1.2)
	check(elite.state == "CHANGE LANE" and elite.lane == 1, "Elite selects player's lane")
	game.rider.lane = 0
	game.rider.target_lane = 0
	elite.step(0.5)
	elite.step(0.9)
	check(elite.lane == 1 and elite.state == "CHARGE", "Locked charge does not follow lane switch")
	for frame in 40:
		elite.step(1.0 / 60.0)
	check(game.rider.health == 3, "Changing lanes avoids charge")
	elite.state = "CHARGE"
	elite.x = 160.0
	elite.contact = false
	game.rider.lane = 1
	game.rider.target_lane = 1
	elite.step(0.016)
	check(game.rider.health == 2, "Charge contact damages player")
	game.rider.invulnerable_left = 0.0
	elite.state = "RETURN"
	elite.x = 140.0
	elite.step(0.016)
	check(game.rider.health == 2, "Returning elite cannot damage player")
	elite.state = "CHARGE"
	elite.x = 160.0
	elite.contact = false
	game.rider.charge_left = 0.4
	var hp: float = elite.hp
	elite.step(0.016)
	elite.step(0.016)
	check(elite.hp == hp - 4.0 and game.rider.health == 2, "Counter-charge deals four damage once without instant kill")
	elite.state = "CHARGE"
	elite.x = 160.0
	elite.contact = false
	game.rider.charge_left = 0.0
	game.rider.jump_left = C.JUMP_TIME / 2.0
	elite.step(0.016)
	check(game.rider.health == 2, "Jump avoids elite contact")
	elite.state = "OPEN"
	hp = elite.hp
	hurt(game, elite, 1.0)
	check(elite.hp == hp - 1.5, "Open window amplifies arrow damage")
	hurt(game, elite, 100.0)
	check(game.director.elite_defeated and game.combat.kills == 1, "Elite death restores road state")
	game._process(0.1)
	check(game.director.run_left < C.RUN_TIME and game.combat.enemies.is_empty(), "Road resumes and dead elite clears")
	game.reset_run()
	game.growth.enabled = false
	game.director.elite_practice = true
	game.director.start_elite()
	hurt(game, game.combat.enemies[0], 100.0)
	game._process(1.0)
	check(game.director.run_left == C.RUN_TIME, "Practice victory stops simulation")
	var restart := InputEventKey.new()
	restart.pressed = true
	restart.keycode = KEY_R
	game._unhandled_key_input(restart)
	check(game.director.elite_practice and game.director.elite_active() and game.combat.enemies.size() == 1 and game.combat.enemies[0].hp == C.ELITE_HP, "R restarts clean elite practice")
	restart.keycode = KEY_F1
	game._unhandled_key_input(restart)
	check(not game.director.elite_practice and not game.director.elite_started and game.combat.enemies.is_empty(), "F1 returns to full road run")
	# Complete a full integrated run; the helper plays aggressively only during elite.
	game.growth.enabled = false
	var elite_count := 0
	for frame in 10000:
		game.rider.health = 3
		game._process(1.0 / 60.0)
		if game.director.elite_active():
			for enemy in game.combat.enemies:
				if enemy.kind == "elite":
					elite_count += 1
					hurt(game, enemy, 100.0)
		if game.director.run_left == 0.0:
			break
	check(elite_count == 1 and game.director.elite_defeated and game.director.run_left == 0.0, "Full run encounters elite once and completes")
	# Verify normal arrows can win the encounter without direct test damage.
	game.reset_run()
	game.growth.enabled = false
	game.director.start_elite()
	for frame in 7200:
		game.rider.health = 3
		game._process(1.0 / 60.0)
		if game.director.elite_defeated:
			break
	check(game.director.elite_defeated, "Actual automatic arrows can defeat elite")
	game.free()
	print("Elite checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)


func hurt(game, enemy: Node2D, amount: float, burning := false) -> void:
	enemy.take_damage(Damage.new(amount, game.build.skill_levels.burn if burning else 0))
