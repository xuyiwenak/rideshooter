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
	for kind in ["infantry", "archer", "raider", "elite"]:
		var actor = game.combat.spawn_enemy(1, 460.0, kind)
		var frames: SpriteFrames = actor.visual_frames
		var valid := frames != null
		var transparent := true
		for animation in frames.get_animation_names():
			valid = valid and frames.get_frame_count(animation) > 0
			for index in frames.get_frame_count(animation):
				var texture: AtlasTexture = frames.get_frame_texture(animation, index)
				valid = valid and texture.region.size.x > 0 and texture.region.size.y > 0
				valid = valid and texture.get_size().x == texture.get_size().y
				valid = valid and texture.margin.position.y + texture.region.size.y == texture.get_height() * 55.0 / 64.0
				transparent = transparent and texture.atlas.get_image().get_pixel(0, 0).a == 0.0
		check(valid and transparent, kind + " has nonempty native atlas resources with alpha")
		var seen := {}
		for frame in 60:
			actor.step_status(1.0 / 60.0)
			seen[actor.visual_frame()] = true
		check(seen.size() == frames.get_frame_count(&"run"), kind + " reaches every running frame on shared clock")
		check(actor.hit_center() == actor.position + Vector2(0, -15), kind + " retains gameplay hit anchor")
	game.reset_run()
	game.bow.shot_left = 999.0
	var archer = game.combat.spawn_enemy(0, 399.0, "archer")
	archer.step(0.01, game.road.speed)
	check(archer.visual_animation() == &"aim" and game.combat.arrows.is_empty(), "Archer draws before firing")
	archer.step(0.85, game.road.speed)
	check(archer.visual_animation() == &"release" and game.combat.arrows.size() == 1, "Actual firing changes to arrow-free release pose")
	archer.step(0.1, game.road.speed)
	check(game.combat.arrows.size() == 1, "Visual pose creates no second projectile")
	var elite = game.combat.spawn_enemy(2, 390.0, "elite")
	for state in ["AIM", "THROW", "LOCKED", "CHARGE", "OPEN", "RETURN"]:
		elite.state = state
		var expected: StringName = {"AIM": &"aim", "THROW": &"release", "LOCKED": &"charge", "CHARGE": &"charge", "OPEN": &"recover", "RETURN": &"run"}[state]
		check(elite.visual_animation() == expected and elite.visual_frames.has_animation(expected), "Elite visible pose matches " + state)
	var phase: float = archer.visual_clock
	var elite_phase: float = elite.visual_clock
	game.growth.gain(3)
	game._process(0.2)
	await create_timer(0.1).timeout
	check(archer.visual_clock == phase and elite.visual_clock == elite_phase, "Choice and wall-clock wait freeze all enemy art")
	game.growth.choose(0)
	game._process(0.1)
	check(archer.visual_clock > phase and elite.visual_clock > elite_phase, "Choice resumes enemy art")
	phase = archer.visual_clock
	game.rider.health = 0
	game._process(0.2)
	check(archer.visual_clock == phase, "Player death freezes enemy art")
	game.reset_run()
	check(game.combat.enemies.is_empty() and game.combat.get_child_count() == 0, "Reset removes old enemy visuals")
	var grunt = game.combat.spawn_enemy(1, 400.0, "infantry")
	check(grunt.visual_clock == 0.0, "New enemy starts a clean clock")
	game.director.run_left = 0.0
	game.director.elite_defeated = true
	game._process(0.2)
	check(grunt.visual_clock == 0.0, "Run completion freezes enemy art")
	game.free()
	await create_timer(0.1).timeout
	print("Enemy art checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)
