extends SceneTree

const C = preload("res://core/tuning.gd")
const Damage = preload("res://combat/damage.gd")

func _initialize() -> void:
	call_deferred("_capture")

func save_frame(game, name: String) -> bool:
	game.refresh_views()
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "user://%s.png" % name
	var result := root.get_texture().get_image().save_png(path)
	print(ProjectSettings.globalize_path(path))
	return result == OK

func _capture() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.initialize()
	game.set_process(false)
	game.growth.gain(3)
	if not await save_frame(game, "growth_choice"):
		quit(1)
		return
	game.reset_run()
	game.build.skill_levels.multishot = 2
	game.build.skill_levels.burn = 2
	game.build.check_evolutions()
	for lane in 3:
		game.combat.spawn_enemy(lane, 330.0, "infantry")
	game.bow.shoot_volley(game.combat.enemies[1])
	for frame in 12:
		game.combat.step(1.0 / 60.0)
	if not await save_frame(game, "growth_arrow_rain"):
		quit(1)
		return
	game.free()
	quit()
