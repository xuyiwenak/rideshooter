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
	game.growth.enabled = false
	var enemy = game.combat.spawn_enemy(1, 360.0, "infantry")
	# First actor keeps normal HP to capture a surviving impact and a later defeat.
	var record := AudioEffectRecord.new()
	record.format = AudioStreamWAV.FORMAT_16_BITS
	var effect_index := AudioServer.get_bus_effect_count(0)
	AudioServer.add_bus_effect(0, record)
	record.set_recording_active(true)
	var directory := ProjectSettings.globalize_path("user://archery_feedback_frames")
	DirAccess.make_dir_recursive_absolute(directory)
	var seen := {}
	for frame in 120:
		if frame == 60:
			game.reset_run("arrow")
			game.growth.enabled = false
			for lane in 3:
				enemy = game.combat.spawn_enemy(lane, 360.0 + lane * 12.0, "infantry")
				enemy.hp = 1.0
		game._process(1.0 / 30.0)
		await create_timer(1.0 / 30.0).timeout
		await RenderingServer.frame_post_draw
		var picture := viewport.get_texture().get_image()
		assert(picture.save_png(directory.path_join("frame_%03d.png" % frame)) == OK)
		for burst in game.feedback.bursts:
			if not seen.has(burst.kind):
				seen[burst.kind] = true
				assert(picture.save_png("user://archery_" + str(burst.kind) + ".png") == OK)
	record.set_recording_active(false)
	var recording := record.get_recording()
	assert(recording != null and recording.data.size() > 0)
	assert(recording.save_to_wav("user://archery_feedback_mix.wav") == OK)
	AudioServer.remove_bus_effect(0, effect_index)
	print("ARCHERY_FRAMES=" + directory)
	print("MIX=" + ProjectSettings.globalize_path("user://archery_feedback_mix.wav"))
	print("Observed release/hit/defeat: ", seen)
	viewport.free()
	await process_frame
	quit(0 if seen.size() == 3 else 1)
