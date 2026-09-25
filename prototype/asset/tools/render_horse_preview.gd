extends SceneTree
## Graphical render verification; frames are exported to user://, never .godot/.

func _initialize() -> void:
	call_deferred("render_preview")

func render_preview() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(480, 270)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var preview: Node = load("res://asset/previews/horse_hiphop_preview.tscn").instantiate()
	viewport.add_child(preview)
	var sprite := preview.get_node("Horse/Sprite") as AnimatedSprite2D
	sprite.play(&"run")
	var directory := ProjectSettings.globalize_path("user://horse_hiphop_preview")
	DirAccess.make_dir_recursive_absolute(directory)
	await create_timer(0.6).timeout
	var observed := {}
	for index in 48:
		await create_timer(0.125).timeout
		await RenderingServer.frame_post_draw
		observed[sprite.frame] = true
		var error := viewport.get_texture().get_image().save_png(directory.path_join("frame_%03d.png" % index))
		if error != OK:
			push_error("Preview frame export failed")
			quit(1)
			return
	print("PREVIEW_DIR=", directory)
	print("Observed animation frames: ", observed.size(), "/6")
	quit(0 if observed.size() == 6 else 1)
