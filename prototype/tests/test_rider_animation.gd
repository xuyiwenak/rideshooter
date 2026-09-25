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
	var bow = game.bow
	var visual = game.rider.visual
	var enemy = game.combat.spawn_enemy(1, 400.0, "infantry")
	check(visual.skin.head is AtlasTexture and visual.skin.arms.size() == 4, "Independent head/body and four arm resources load")
	bow.step(0.1)
	check(bow.pose == 0 and game.combat.arrows.is_empty(), "Reach behind before shooting")
	bow.step(0.05)
	check(bow.pose == 1 and game.combat.arrows.is_empty(), "Nock without premature arrow")
	bow.step(0.12)
	check(bow.pose == 2 and game.combat.arrows.is_empty(), "Draw without premature arrow")
	game.rider.handle_key(KEY_SPACE)
	game.rider.step(0.1)
	bow.step(0.18)
	check(bow.pose == 3 and game.combat.arrows.size() == 1, "Release creates one arrow")
	check(game.combat.arrows[0].pos.is_equal_approx(game.rider.arrow_origin()), "Arrow starts at visual bow anchor, including jump and seat offset")
	bow.step(0.03)
	check(game.combat.arrows.size() == 1, "Release pose does not create repeated arrows")
	var before: float = bow.pose_left
	game.growth.gain(3)
	game._process(0.2)
	await create_timer(0.1).timeout
	check(bow.pose_left == before and visual.shot_pose == 3, "Choice pause freezes pose even through wall-clock frames")
	game.growth.choose(0)
	game._process(0.03)
	check(bow.pose_left < before, "Choice resumes shot clock")
	game.reset_run()
	check(bow.pose == -1 and visual.shot_pose == -1 and game.combat.arrows.is_empty(), "Reset clears pose, timer and projectiles")
	# Keep enemies stationary by stepping bow only to isolate shot cadence.
	for level in 3:
		game.reset_run()
		game.build.skill_levels.rapid = level
		enemy = game.combat.spawn_enemy(1, 400.0, "infantry")
		var release_times: Array[float] = []
		var time := 0.0
		var previous_count := 0
		for frame in 2000:
			time += 0.001
			bow.step(0.001)
			if game.combat.arrows.size() > previous_count:
				release_times.append(time)
				previous_count = game.combat.arrows.size()
			if release_times.size() == 3:
				break
		check(release_times.size() == 3 and absf(release_times[1] - release_times[0] - game.build.shot_interval()) < 0.002, "Continuous cadence matches weapon config at rapid level %d" % level)
	game.reset_run()
	enemy = game.combat.spawn_enemy(1, 400.0, "infantry")
	bow.step(0.3)
	enemy.hp = 0.0
	bow.step(0.2)
	check(bow.pose == 2 and game.combat.arrows.is_empty(), "Lost target holds loaded bow without firing")
	game.combat.spawn_enemy(1, 350.0, "infantry")
	bow.step(0.01)
	check(bow.pose == 3 and game.combat.arrows.size() == 1, "New valid target releases held arrow once")
	game.reset_run("arrow")
	for lane in 3:
		game.combat.spawn_enemy(lane, 350.0 + lane * 20, "infantry")
	bow.step(game.build.shot_interval() * 0.81)
	check(game.combat.arrows.size() == 3 and bow.pose == 3, "One release event produces evolved volley")
	var original_skin: Resource = visual.skin
	var replacement := original_skin.duplicate()
	replacement.quiver = null
	visual.skin = replacement
	check(game.rider.health == 3 and game.build.arrow_rain and bow.pose == 3, "Skin resource swap and empty back slot preserve gameplay")
	visual.skin = original_skin
	game.rider.health = 0
	before = bow.pose_left
	game._process(0.2)
	check(bow.pose_left == before, "Death freezes rider animation")
	game.free()
	# Let the audio server release playback instances before quitting SceneTree.
	await create_timer(0.1).timeout
	print("Rider animation checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)
