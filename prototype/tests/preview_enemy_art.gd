extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 540)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var game = load("res://main.tscn").instantiate()
	viewport.add_child(game)
	game.scale = Vector2(2, 2)
	game.get_node("UI").transform = Transform2D(0.0, Vector2.ZERO).scaled(Vector2(2, 2))
	game.set_process(false)
	game.bow.shot_left = 999.0
	game.growth.enabled = false
	# Staged placement in the real main scene: four roles together for art review.
	game.combat.spawn_enemy(0, 245.0, "infantry")
	game.combat.spawn_enemy(0, 385.0, "archer")
	game.combat.spawn_enemy(1, 290.0, "raider")
	var elite = game.combat.spawn_enemy(2, 370.0, "elite")
	game._process(0.1)
	await save_frame(viewport, "enemy_art_overview")
	var overview := viewport.get_texture().get_image()
	for actor in game.combat.enemies:
		if actor.kind != "elite":
			var pixel: Vector2i = Vector2i((actor.position + Vector2(0, -40)) * 2)
			assert(overview.get_pixelv(pixel).is_equal_approx(Color("b8d789")), "Enemy health bar must remain visible")
	for state in ["AIM", "LOCKED", "OPEN"]:
		elite.state = state
		elite.aim_lane = 1
		elite.queue_redraw()
		game.refresh_views()
		await save_frame(viewport, "enemy_art_" + state.to_lower())
	# Normal main clock excerpt, enemy HP raised only to show animation clearly.
	elite.state = "APPROACH"
	elite.timer = 1.2
	game.bow.shot_left = 0.0
	for actor in game.combat.enemies:
		actor.hp = 999.0
		actor.max_hp = 999.0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://enemy_demo_frames"))
	for frame in 72:
		game._process(1.0 / 30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		assert(viewport.get_texture().get_image().save_png("user://enemy_demo_frames/frame_%03d.png" % frame) == OK)
	print("ENEMY_FRAMES=" + ProjectSettings.globalize_path("user://enemy_demo_frames"))
	viewport.free()
	quit()

func save_frame(viewport: SubViewport, name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "user://" + name + ".png"
	assert(viewport.get_texture().get_image().save_png(path) == OK)
	print(ProjectSettings.globalize_path(path))
