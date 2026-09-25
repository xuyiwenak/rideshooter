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
	game.combat.spawn_enemy(1, 400.0, "infantry")
	game._process(0.1)
	for pose in 4:
		game.rider.visual.set_shot_pose(pose)
		await process_frame
		await RenderingServer.frame_post_draw
		var path := "user://rider_pose_%d.png" % pose
		assert(viewport.get_texture().get_image().save_png(path) == OK)
		print(ProjectSettings.globalize_path(path))
	game.rider.lane = 0
	game.rider.target_lane = 0
	game.rider.handle_key(KEY_SPACE)
	game._process(0.25)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(viewport.get_texture().get_image().save_png("user://rider_top_jump.png") == OK)
	# A real-clock gameplay excerpt (durable enemy only to keep firing visible).
	game.reset_run()
	var target = game.combat.spawn_enemy(1, 450.0, "infantry")
	target.hp = 999.0
	target.max_hp = 999.0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://rider_demo_frames"))
	for frame in 66:
		game._process(1.0 / 60.0)
		await process_frame
		await RenderingServer.frame_post_draw
		assert(viewport.get_texture().get_image().save_png("user://rider_demo_frames/frame_%03d.png" % frame) == OK)
	print("DEMO_FRAMES=" + ProjectSettings.globalize_path("user://rider_demo_frames"))
	viewport.free()
	quit()
