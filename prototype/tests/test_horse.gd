extends SceneTree

var checks := 0
var failures := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.bow.shot_left = 999.0
	var rider = game.rider
	var frames_seen := {}
	for frame in 48:
		game._process(1.0 / 60.0)
		frames_seen[int(rider.gait_phase)] = true
	check(frames_seen.size() == 6 and not rider.hoof_dust.is_empty(), "Main game advances all six frames and emits hoof dust")
	var phase: float = rider.gait_phase
	var dust: Array = rider.hoof_dust.duplicate(true)
	game.growth.gain(3)
	game._process(0.25)
	await create_timer(0.15).timeout
	check(rider.gait_phase == phase and rider.hoof_dust == dust, "Upgrade and real idle frames freeze animation and dust")
	game.growth.choose(0)
	game._process(0.1)
	check(rider.gait_phase != phase and rider.hoof_dust != dust, "Choosing a card resumes visuals")
	rider.handle_key(KEY_SPACE)
	phase = rider.gait_phase
	for frame in 30:
		game._process(1.0 / 60.0)
	check(rider.gait_phase == phase and rider.hoof_dust.is_empty(), "Jump holds pose, emits no dust, and old dust expires")
	game._process(0.15)
	check(rider.jump_left == 0.0 and rider.hoof_dust.size() >= 3, "Landing emits a short burst")
	game.reset_run()
	check(rider.gait_phase == 0.0 and rider.hoof_dust.is_empty() and rider.dust_left == 0.0, "Restart clears animation and dust")
	game._process(0.1)
	var normal_phase: float = rider.gait_phase
	var normal_dust_count: int = rider.hoof_dust.size()
	game.reset_run()
	rider.handle_key(KEY_E)
	game._process(0.1)
	check(rider.gait_phase > normal_phase and rider.hoof_dust.size() > normal_dust_count, "Sprint speeds animation and increases dust")
	var ground: float = rider.hoof_dust[0].pos.y
	rider.start_switch(-1)
	game._process(0.1)
	check(absf(rider.hoof_dust[0].pos.y - ground) < 2.0 and rider.position.y < ground - 15.0, "Previous dust stays on original lane during lane change")
	phase = rider.gait_phase
	dust = rider.hoof_dust.duplicate(true)
	rider.health = 0
	game._process(0.2)
	check(rider.gait_phase == phase and rider.hoof_dust == dust, "Death freezes visuals")
	game.reset_run()
	game.director.run_left = 0.0
	game.director.elite_defeated = true
	game._process(0.2)
	check(game.director.finished() and rider.gait_phase == 0.0 and rider.hoof_dust.is_empty(), "Finished run freezes visuals")
	game.free()
	await create_timer(0.1).timeout
	print("Horse checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)
