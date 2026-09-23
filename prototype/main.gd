extends Node2D
## Composition root: wires modules, routes input and advances one shared clock.
var rider: Node2D
var bow: Node
var combat: Node2D
var build: Node
var growth: Node
var director: Node
var road: Node2D
var scenery: Node2D
var hud: Node2D
var upgrade_panel: Node2D
var initialized := false

func _ready() -> void:
	initialize()

func initialize() -> void:
	if initialized:
		return
	rider = $Rider
	bow = $Rider/AutoBow
	combat = $Combat
	build = $RunBuild
	growth = $WarSpirit
	director = $EncounterDirector
	road = $Road
	scenery = $Scenery
	hud = $UI/HUD
	upgrade_panel = $UI/UpgradePanel
	rider.build = build
	bow.rider = rider
	bow.build = build
	bow.combat = combat
	combat.rider = rider
	combat.bow = bow
	growth.build = build
	director.combat = combat
	director.road = road
	road.rider = rider
	scenery.road = road
	hud.rider = rider
	hud.director = director
	hud.combat = combat
	hud.growth = growth
	hud.build = build
	upgrade_panel.growth = growth
	upgrade_panel.build = build
	upgrade_panel.selected.connect(growth.choose)
	build.skill_acquired.connect(rider.on_skill_acquired)
	build.heal_requested.connect(rider.heal)
	combat.enemy_killed.connect(build.on_kill)
	combat.enemy_killed.connect(growth.on_kill)
	combat.enemy_killed.connect(director.on_kill)
	director.elite_requested.connect(_spawn_elite)
	initialized = true

func _spawn_elite() -> void:
	combat.spawn_enemy(1, 450.0, "elite")

func _process(delta: float) -> void:
	if not initialized:
		return
	# Bound substeps for collision stability; all modules share pause semantics.
	var remaining := minf(delta, 0.25)
	while remaining > 0.000001:
		if growth.upgrade_open or rider.health <= 0 or director.finished():
			break
		var dt := minf(remaining, 1.0 / 60.0)
		rider.step(dt)
		road.step_speed(dt)
		director.step(dt)
		combat.step(dt, road.speed)
		road.step_obstacles(dt)
		remaining -= dt
	refresh_views()

func refresh_views() -> void:
	rider.queue_redraw()
	road.queue_redraw()
	scenery.queue_redraw()
	hud.queue_redraw()
	upgrade_panel.queue_redraw()

func reset_run(mode: String = "base") -> void:
	combat.reset()
	build.reset()
	growth.reset()
	rider.reset()
	bow.reset()
	road.reset()
	director.reset()
	growth.enabled = mode != "elite"
	if mode == "elite":
		director.elite_practice = true
		director.start_elite()
	elif mode in ["arrow", "iron"]:
		build.apply_preset(mode)
	refresh_views()

func _unhandled_key_input(event: InputEvent) -> void:
	if not initialized or not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_R:
			reset_run("elite" if director.elite_practice else "base")
			return
		KEY_F1:
			reset_run()
			return
		KEY_F2:
			reset_run("elite")
			return
		KEY_F3:
			reset_run("arrow")
			return
		KEY_F4:
			reset_run("iron")
			return
	if growth.upgrade_open:
		upgrade_panel.handle_key(event.keycode)
	elif rider.health > 0 and not director.finished():
		rider.handle_key(event.keycode)
	refresh_views()
