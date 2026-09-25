extends SceneTree

const C = preload("res://core/tuning.gd")
const Damage = preload("res://combat/damage.gd")

var failures := 0
var checks := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func choose(game, index: int) -> void:
	game.growth.choose(index)

func kill_normal(game, enemy_lane := 1) -> void:
	game.combat.spawn_enemy(enemy_lane, 300.0, "infantry")
	hurt(game, game.combat.enemies.back(), 99.0)
	game.combat.cleanup()

func _initialize() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.initialize()
	game.set_process(false)
	game.growth.gain(8)
	check(game.growth.growth_level == 2 and game.growth.war_spirit == 1 and game.growth.pending_upgrades == 2, "XP overflow creates two queued levels")
	check(game.growth.upgrade_open and game.growth.upgrade_options.size() == 3, "Level up opens three choices")
	var before_time: float = game.director.run_left
	game._process(1.0)
	check(game.director.run_left == before_time, "Upgrade screen pauses the world")
	choose(game, 0)
	check(game.build.skill_levels.multishot == 1 and game.growth.upgrade_open and game.growth.pending_upgrades == 1, "Queued upgrade continues after choice")
	choose(game, 0)
	check(game.build.skill_levels.multishot == 2 and not game.growth.upgrade_open, "Second multishot level applies")
	game.growth.gain(20)
	choose(game, 0)
	choose(game, 0)
	check(game.build.skill_levels.burn == 2 and game.build.arrow_rain, "Multishot II plus Burn II evolves Arrow Rain")
	game.reset_run()
	game.build.skill_levels.multishot = 1
	for lane in 3:
		game.combat.spawn_enemy(lane, 300.0 + lane * 10.0, "infantry")
	game.bow.shoot_volley(game.combat.enemies[1])
	check(game.combat.arrows.size() == 2, "Multishot I creates one extra arrow")
	game.combat.clear_arrows()
	game.build.skill_levels.multishot = 2
	game.build.skill_levels.burn = 2
	game.build.check_evolutions()
	game.bow.shoot_volley(game.combat.enemies[1])
	check(game.combat.arrows.size() == 3 and game.combat.arrows.all(func(a: Node2D) -> bool: return a.burn), "Arrow Rain covers three targets with burning arrows")
	var victim = game.combat.enemies[1]
	var hp: float = victim.hp
	hurt(game, victim, 0.1, true)
	game.combat.step(0.51)
	check(victim.hp < hp - 0.1 and victim.burn_left > 0.0, "Burn deals damage over time")
	game.reset_run()
	game.build.skill_levels.rapid = 2
	check(game.build.shot_interval() < game.build.bow_config.base_shot_interval * 0.7, "Rapid Fire II shortens attack interval")
	var configured_enemy = game.combat.spawn_enemy(0, 450.0, "infantry")
	check(game.build.bow_config == game.bow.bow_config and configured_enemy.bow_config == game.build.bow_config, "Bow modules share the default configuration resource")
	game.build.skill_levels.shield = 1
	game.rider.shield_active = true
	game.rider.hurt()
	check(game.rider.health == 3 and not game.rider.shield_active and game.rider.shield_restore_left == 10.0, "Shield blocks one hit")
	game.rider.invulnerable_left = 0.0
	game.rider.step(10.1)
	check(game.rider.shield_active, "Shield restores automatically")
	game.reset_run()
	game.build.skill_levels.heal = 2
	game.rider.health = 1
	for count in 4:
		kill_normal(game)
	check(game.rider.health == 2 and game.build.heal_kills == 0, "Kill Heal II heals after four kills")
	game.reset_run()
	game.build.skill_levels.ram = 2
	game.build.skill_levels.shield = 2
	game.build.check_evolutions()
	check(game.build.iron_cavalry, "Ram II plus Shield II evolves Iron Cavalry")
	game.director.start_elite()
	var elite = game.combat.enemies[0]
	elite.state = "CHARGE"
	elite.x = 160.0
	game.rider.charge_left = 0.4
	elite.step(0.016)
	check(elite.hp == C.ELITE_HP - 8.0, "Ram II counter-charge deals eight damage")
	game.rider.shield_active = false
	var charge := InputEventKey.new()
	charge.pressed = true
	charge.keycode = KEY_E
	game.rider.charge_left = 0.0
	game.rider.charge_cooldown_left = 0.0
	game._unhandled_key_input(charge)
	check(game.rider.shield_active, "Iron Cavalry restores shield when charging")
	var preset := InputEventKey.new()
	preset.pressed = true
	preset.keycode = KEY_F3
	game._unhandled_key_input(preset)
	check(game.build.arrow_rain and not game.build.iron_cavalry, "F3 loads Arrow Rain preset")
	preset.keycode = KEY_F4
	game._unhandled_key_input(preset)
	check(game.build.iron_cavalry and game.rider.shield_active and not game.build.arrow_rain, "F4 loads Iron Cavalry preset")
	game.reset_run()
	game.reset_run("elite")
	game.growth.gain(99)
	check(not game.growth.upgrade_open and game.growth.war_spirit == 0, "Elite practice stays focused and skips growth")
	game.free()
	print("Growth checks: %d/%d passed" % [checks - failures, checks])
	quit(1 if failures else 0)


func hurt(game, enemy: Node2D, amount: float, burning := false) -> void:
	enemy.take_damage(Damage.new(amount, game.build.skill_levels.burn if burning else 0))
