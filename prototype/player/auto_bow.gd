extends Node
## Target selection and volley construction. Projectiles live in Combat.
signal released(origin: Vector2, direction: Vector2)
const C = preload("res://core/tuning.gd")
@export var bow_config: BowConfig = preload("res://config/weapons/bow_default.tres")
var rider: Node2D
var build: Node
var combat: Node2D
var shot_left := 0.0
var pose := -1
var pose_left := 0.0
var cycle_time := 0.55
const POSE_WEIGHTS = [0.25, 0.20, 0.35, 0.20]

func reset() -> void:
	shot_left = 0.0
	pose = -1
	pose_left = 0.0
	cycle_time = build.shot_interval()
	rider.visual.set_shot_pose(-1)

func step(delta: float) -> void:
	shot_left = maxf(0.0, shot_left - delta)
	if pose < 0:
		if shot_left > 0.0 or pick_target() == null:
			return
		cycle_time = build.shot_interval()
		pose = 0
		pose_left = cycle_time * POSE_WEIGHTS[0]
	pose_left -= delta
	while pose_left <= 0.0:
		if pose == 2:
			var target = pick_target()
			if target == null:
				# Hold the loaded bow; do not conjure a second arrow or dry-fire.
				pose_left = 0.0
				break
			shoot_volley(target)
			shot_left = cycle_time
		pose += 1
		if pose == 4:
			if pick_target() == null:
				pose = -1
				pose_left = 0.0
				break
			pose = 0
			cycle_time = build.shot_interval()
		pose_left += cycle_time * POSE_WEIGHTS[pose]
	rider.visual.set_shot_pose(pose)

func pick_target() -> Node2D:
	var best: Node2D = null
	var best_score := INF
	for enemy in combat.enemies:
		var gap: int = absi(enemy.lane - rider.collision_lane())
		if enemy.hp <= 0.0 or enemy.x < C.PLAYER_X + 24.0 or enemy.x > C.WIDTH - 8.0 or gap > 1:
			continue
		var score: float = gap * 1000.0 + enemy.x
		if score < best_score:
			best = enemy
			best_score = score
	return best

func shoot(target: Node2D) -> void:
	var origin: Vector2 = rider.arrow_origin()
	var vx: float = target.vx
	var flight: float = maxf(0.02, (target.x - origin.x) / (bow_config.projectile_speed - vx))
	var impact := Vector2(target.x + vx * flight, target.ground_y() - 15.0)
	combat.spawn_arrow({"pos": origin, "velocity": (impact - origin) / flight,
		"hostile": false, "source": 0,
		"damage": bow_config.same_lane_damage if target.lane == rider.collision_lane() else bow_config.adjacent_lane_damage,
		"burn_level": build.skill_levels.burn})

func shoot_volley(target: Node2D) -> void:
	shoot(target)
	var multishot_extra: int = [0, bow_config.multishot_level_1_extra_targets,
		bow_config.multishot_level_2_extra_targets][build.skill_levels.multishot]
	var extra: int = bow_config.arrow_rain_total_targets - 1 if build.arrow_rain else multishot_extra
	var used_ids = [target.id]
	for count in extra:
		var best: Node2D = null
		var best_score := INF
		for enemy in combat.enemies:
			if enemy.id in used_ids or enemy.hp <= 0.0 or enemy.escaped or enemy.x < C.PLAYER_X + 24.0 or enemy.x > C.WIDTH - 8.0:
				continue
			var score: float = absf(enemy.lane - target.lane) * 1000.0 + enemy.x
			if score < best_score:
				best = enemy
				best_score = score
		if best == null:
			break
		used_ids.append(best.id)
		shoot(best)
	released.emit(rider.arrow_origin(), target.hit_center() - rider.arrow_origin())
