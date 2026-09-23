extends Node
## Road progress controls encounters. Attack timers remain in actor real time.
signal elite_requested
const C = preload("res://core/tuning.gd")
var combat: Node2D
var road: Node2D
var run_left := C.RUN_TIME
var spawn_left := 1.4
var spawn_index := 0
var elite_started := false
var elite_defeated := false
var elite_practice := false

func reset() -> void:
	run_left = C.RUN_TIME
	spawn_left = 1.4
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
	elite_requested.emit()

func on_kill(kind: String) -> void:
	if kind == "elite":
		elite_defeated = true
		spawn_left = 1.4

func step(delta: float) -> void:
	if elite_active() or finished():
		return
	var advance: float = delta * road.speed / C.ROAD_SPEED
	run_left = maxf(0.0, run_left - advance)
	if not elite_started and run_left <= 30.0:
		run_left = 30.0
		start_elite()
		return
	if run_left > 36.0 or elite_defeated:
		spawn_left -= advance
		if spawn_left <= 0.0:
			spawn_left += 6.0
			spawn_group(spawn_index)
			spawn_index += 1

func spawn_group(index: int) -> void:
	var route: int = [1, 0, 2][index % 3]
	match index % 3:
		0:
			combat.spawn_enemy(route, 495.0, "infantry")
			combat.spawn_enemy((route + 1) % 3, 540.0, "raider")
			combat.spawn_enemy(route, 660.0, "archer")
		1:
			for offset in 3:
				combat.spawn_enemy((route + offset) % 3, 495.0 + offset * 65.0, "raider" if offset == 1 else "infantry")
		2:
			combat.spawn_enemy(0, 495.0, "archer")
			combat.spawn_enemy(2, 530.0, "raider")
			road.obstacles.append({"x": 740.0, "lane": 1, "resolved": false})
