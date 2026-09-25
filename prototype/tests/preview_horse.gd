extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process(false)
	game.bow.shot_left = 999.0
	game.combat.spawn_enemy(0, 340.0, "infantry")
	game.combat.spawn_enemy(2, 420.0, "raider")
	for frame in 30:
		game._process(1.0 / 60.0)
	await snapshot("horse_game_run")
	game.rider.handle_key(KEY_SPACE)
	game._process(0.25)
	await snapshot("horse_game_jump")
	game._process(0.25)
	game._process(0.15)
	game.rider.handle_key(KEY_E)
	game._process(0.2)
	await snapshot("horse_game_sprint")
	game.free()
	quit()

func snapshot(label: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "user://%s.png" % label
	assert(root.get_texture().get_image().save_png(path) == OK)
	print(ProjectSettings.globalize_path(path))
