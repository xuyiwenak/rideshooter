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
func count_bursts(fx: Node, kind: StringName) -> int:
	return fx.bursts.filter(func(b: Dictionary) -> bool: return b.kind == kind).size()
func run_checks() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	var fx = game.feedback
	check(fx.voices.size() == 6, "Fixed six-voice audio pool")
	var enemy = game.combat.spawn_enemy(1, 400.0, "infantry")
	game.bow.step(0.3)
	check(fx.bursts.is_empty(), "No sound or flash during bow preparation")
	game.bow.step(0.15)
	check(count_bursts(fx, &"release") == 1 and fx.variants[&"release"] == 1, "One release cue on actual arrow creation")
	check(fx.bursts[0].pos.is_equal_approx(game.rider.arrow_origin()), "Release is at current bow anchor")
	game.reset_run("arrow")
	for lane in 3:
		game.combat.spawn_enemy(lane, 380.0, "infantry")
	game.bow.step(game.build.shot_interval() * 0.81)
	check(game.combat.arrows.size() == 3 and count_bursts(fx, &"release") == 1 and fx.variants[&"release"] == 1, "Three-arrow volley makes one release sound")
	game.reset_run()
	game.bow.shot_left = 999.0
	enemy = game.combat.spawn_enemy(1, 300.0, "infantry")
	game.combat.spawn_arrow({"pos": Vector2(280, 151), "velocity": Vector2(420, 0), "hostile": false, "source": 0, "damage": 1.0})
	game.combat.step(0.025)
	check(enemy.hp == 2.0 and count_bursts(fx, &"hit") == 1, "Real swept collision emits one impact")
	check(fx.bursts[0].pos.distance_to(enemy.hit_center()) < 12.0, "Impact appears within collision surface")
	game.combat.step(0.025)
	check(count_bursts(fx, &"hit") == 1, "Consumed arrow cannot replay impact")
	var snapshot: Array = fx.bursts.duplicate(true)
	game.growth.gain(3)
	game._process(0.2)
	await create_timer(0.1).timeout
	check(fx.bursts == snapshot and fx.paused, "Choice pauses effect age through wall-clock frames")
	check(fx.voices[0].stream_paused and fx.voices.all(func(v: AudioStreamPlayer) -> bool: return not v.playing or v.stream_paused), "Choice also pauses audio voices")
	game.growth.choose(0)
	game._process(0.05)
	check(not fx.paused and fx.bursts != snapshot, "Choice resumes feedback")
	game.reset_run()
	check(fx.bursts.is_empty() and fx.voices.all(func(v: AudioStreamPlayer) -> bool: return not v.playing), "Restart clears visual and audio tails")
	game.bow.shot_left = 999.0
	enemy = game.combat.spawn_enemy(1, 300.0, "infantry")
	enemy.hp = 1.0
	game.combat.spawn_arrow({"pos": Vector2(280, 151), "velocity": Vector2(420, 0), "hostile": false, "source": 0, "damage": 1.0})
	game.combat.step(0.025)
	check(count_bursts(fx, &"defeat") == 1 and count_bursts(fx, &"hit") == 1 and game.combat.kills == 1, "Lethal hit emits one pop and preserves one kill")
	game.combat.step(0.025)
	check(count_bursts(fx, &"defeat") == 1, "Cleanup does not replay death")
	game.reset_run()
	game.bow.shot_left = 999.0
	game.combat.spawn_enemy(1, 70.0, "infantry")
	game.combat.step(0.01)
	check(fx.bursts.is_empty(), "Escaping is not a defeat")
	game.combat.spawn_arrow({"pos": Vector2(480, 100), "velocity": Vector2(420, 0), "hostile": false, "source": 0, "damage": 1.0})
	game.combat.step(0.1)
	check(count_bursts(fx, &"hit") == 0, "Misses do not emit impact sounds")
	for index in 80:
		fx.hit(Vector2(300, 150), Vector2.RIGHT)
	check(fx.bursts.size() == fx.MAX_BURSTS and fx.variants[&"hit"] == 1, "Burst cap and sound cooldown suppress spam")
	fx.step(0.5)
	check(fx.bursts.is_empty(), "Expired effects are reclaimed")
	fx.release(Vector2(150, 130), Vector2.RIGHT)
	snapshot = fx.bursts.duplicate(true)
	game.rider.health = 0
	game._process(0.2)
	check(fx.bursts == snapshot and fx.paused, "Death freezes audio and visual feedback")
	game.reset_run()
	fx.release(Vector2(150, 130), Vector2.RIGHT)
	game.director.run_left = 0
	game.director.elite_defeated = true
	game._process(0.2)
	check(fx.paused and fx.bursts[0].age == 0.0, "Run completion freezes feedback")
	game.free()
	await create_timer(0.1).timeout
	print("Archery feedback checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)
