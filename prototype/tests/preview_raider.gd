extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.initialize()
	game.set_process(false)
	game.bow.shot_left = 999.0
	game.combat.spawn_enemy(0, 330.0, "infantry")
	game.combat.spawn_enemy(2, 400.0, "raider")
	game.combat.spawn_enemy(1, 460.0, "archer")
	game._process(0.1)
	game.rider.health = 2
	game.refresh_views()
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "user://raider_warning.png"
	var result := root.get_texture().get_image().save_png(path)
	print(ProjectSettings.globalize_path(path))
	game.free()
	quit(0 if result == OK else 1)
