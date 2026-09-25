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
	var fx = game.feedback
	check(fx.licensed_streams.size() == 7, "All seven local licensed clips loaded")
	check(fx.gallop_voice.stream != null and fx.field_voice.stream != null, "Continuous clips assigned")
	fx.step(0.02)
	fx.sync_riding(game.rider)
	check(fx.field_voice.playing and fx.gallop_voice.playing, "Field and gallop start on the shared clock")
	game.rider.jump_left = 0.2
	fx.sync_riding(game.rider)
	check(not fx.gallop_voice.playing and fx.field_voice.playing, "Jump silences hooves but retains ambience")
	game.rider.jump_left = 0.0
	game.rider.charge_left = 0.2
	fx.sync_riding(game.rider)
	check(fx.gallop_voice.playing and fx.gallop_voice.pitch_scale > 1.0, "Charge speeds up hooves")
	fx.set_paused(true)
	check(fx.gallop_voice.stream_paused and fx.field_voice.stream_paused, "Gameplay loops pause with the menu")
	fx.set_paused(false)
	game.rider.charge_left = 0.0
	game.rider.shield_active = true
	game.rider.hurt()
	check(not game.rider.shield_active and fx.bursts.any(func(b: Dictionary) -> bool: return b.kind == &"shield"), "Real shield consumption triggers feedback")
	check(fx.voices.any(func(v: AudioStreamPlayer) -> bool: return v.stream == fx.licensed_streams[&"shield"]), "Shield uses licensed block sound")
	fx.reset()
	game.growth.gain(3)
	check(game.growth.upgrade_open and fx.ui_voices[0].stream == fx.licensed_streams[&"reward"], "Upgrade opens with reward sound")
	fx.set_paused(true)
	game.growth.choose(0)
	check(fx.ui_voices[1].stream == fx.licensed_streams[&"select"] and fx.ui_voices[1].playing, "Valid choice sounds even while gameplay is paused")
	check(not game.growth.upgrade_open, "Choice closes the upgrade")
	fx.reset()
	var licensed_release: AudioStream = fx.licensed_streams[&"release"]
	fx.licensed_streams.erase(&"release")
	fx.release(Vector2(150, 130), Vector2.RIGHT)
	check(fx.voices[0].stream == fx.SOUNDS[&"release"][0], "Missing licensed release uses original synthesized WAV")
	fx.licensed_streams[&"release"] = licensed_release
	fx.reset()
	check(not fx.gallop_voice.playing and not fx.field_voice.playing and fx.ui_voices.all(func(v: AudioStreamPlayer) -> bool: return not v.playing), "Restart stops loops and UI tails")
	licensed_release = null
	game.free()
	await create_timer(0.3).timeout
	print("Licensed audio checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)
