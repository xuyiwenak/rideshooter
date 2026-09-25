extends Node
## Road progress controls encounters. Attack timers remain in actor real time.
signal elite_requested(route: int, start_x: float)
const C = preload("res://core/tuning.gd")
@export var config: EncounterConfig = preload("res://config/encounters/encounter_default.tres")
var combat: Node2D
var road: Node2D
var run_left := 0.0
var spawn_left := 0.0
var spawn_index := 0
var elite_started := false
var elite_defeated := false
var elite_practice := false

func reset() -> void:
	run_left = config.run_length
	spawn_left = config.first_wave_delay
	spawn_index = 0
	elite_started = false
	elite_defeated = false
	elite_practice = false

func elite_active() -> bool:
	return elite_started and not elite_defeated

func finished() -> bool:
	return run_left <= 0.0 or (elite_practice and elite_defeated)

func start_elite() -> void:
	if elite_started:
		return
	elite_started = true
	elite_requested.emit(config.elite_spawn_lane, config.elite_spawn_x)

func on_kill(kind: String) -> void:
	if kind == "elite":
		elite_defeated = true
		spawn_left = config.first_wave_delay

func step(delta: float) -> void:
	if elite_active() or finished():
		return
	var advance: float = delta * road.speed / C.ROAD_SPEED
	run_left = maxf(0.0, run_left - advance)
	if not elite_started and run_left <= config.elite_trigger_remaining:
		run_left = config.elite_trigger_remaining
		start_elite()
		return
	if run_left > config.pre_elite_spawn_stop_remaining or elite_defeated:
		spawn_left -= advance
		if spawn_left <= 0.0:
			spawn_left += config.wave_interval
			spawn_group(spawn_index)
			spawn_index += 1

func spawn_group(index: int) -> void:
	if config.lane_cycle.is_empty() or config.patterns.is_empty():
		return
	var route: int = config.lane_cycle[index % config.lane_cycle.size()]
	var pattern: WavePattern = config.patterns[index % config.patterns.size()]
	for spawn in pattern.enemies:
		combat.spawn_enemy((route + spawn.lane_offset) % 3, spawn.start_x, spawn.kind)
	if pattern.has_obstacle:
		road.obstacles.append({"x": pattern.obstacle_start_x,
			"lane": (route + pattern.obstacle_lane_offset) % 3, "resolved": false})
