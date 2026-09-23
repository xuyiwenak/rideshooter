extends SceneTree

const C = preload("res://core/tuning.gd")
const Damage = preload("res://combat/damage.gd")

# Native rendering smoke test; saves three representative states to user://.
func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.initialize()
	game.set_process(false)
	game.reset_run("elite")
	for stage in ["LOCKED", "OPEN", "AIM"]:
		var reached := false
		for frame in 600:
			game._process(1.0 / 60.0)
			if not game.combat.enemies.is_empty() and game.combat.enemies[0].state == stage:
				reached = true
				break
		if not reached:
			push_error("Preview did not reach state: " + stage)
			quit(1)
			return
		game.refresh_views()
		await process_frame
		await RenderingServer.frame_post_draw
		var path := "user://elite_%s.png" % stage.to_lower()
		var result := root.get_texture().get_image().save_png(path)
		if result != OK:
			quit(1)
			return
		print(ProjectSettings.globalize_path(path))
	game.free()
	quit()
