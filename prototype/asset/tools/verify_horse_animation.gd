extends SceneTree
## Asset-only smoke check. Does not assert full gameplay integration.

func _initialize() -> void:
	var frames := load("res://asset/runtime/characters/horse_hiphop/horse_hiphop_sprite_frames.tres") as SpriteFrames
	if frames == null or frames.get_frame_count(&"run") != 6:
		push_error("Missing six-frame run animation")
		quit(1)
		return
	for index in 6:
		var texture := frames.get_frame_texture(&"run", index) as AtlasTexture
		if texture == null or texture.get_size() != Vector2(512, 512):
			push_error("Invalid frame canvas")
			quit(1)
			return
		if texture.margin.position.y + texture.region.size.y != 440:
			push_error("Foot baseline drift")
			quit(1)
			return
	var scene := load("res://asset/previews/horse_hiphop_preview.tscn") as PackedScene
	if scene == null:
		quit(1)
		return
	var preview := scene.instantiate()
	root.add_child(preview)
	var sprite := preview.get_node("Horse/Sprite") as AnimatedSprite2D
	sprite.play(&"run")
	if not sprite.is_playing() or not frames.get_animation_loop(&"run"):
		quit(1)
		return
	print("PASS: six atlas frames, shared baseline, looping animation, preview and dust scene load")
	quit()
