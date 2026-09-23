extends Node
## Target selection and volley construction. Projectiles live in Combat.
const C = preload("res://core/tuning.gd")
var rider: Node2D
var build: Node
var combat: Node2D
var shot_left := 0.0

func reset() -> void:
	shot_left = 0.0

func step(delta: float) -> void:
	shot_left = maxf(0.0, shot_left - delta)
	if shot_left == 0.0:
		var target = pick_target()
		if target != null:
			shoot_volley(target)
			shot_left = build.shot_interval()

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
	var origin := Vector2(C.PLAYER_X + 23.0, rider.ground_y() - rider.jump_height() - 22.0)
	var vx: float = target.vx
	var flight: float = maxf(0.02, (target.x - origin.x) / (420.0 - vx))
	var impact := Vector2(target.x + vx * flight, target.ground_y() - 15.0)
	combat.spawn_arrow({"pos": origin, "velocity": (impact - origin) / flight,
		"hostile": false, "source": 0, "damage": 1.0 if target.lane == rider.collision_lane() else 0.5,
		"burn_level": build.skill_levels.burn})

func shoot_volley(target: Node2D) -> void:
	shoot(target)
	var extra: int = 2 if build.arrow_rain else build.skill_levels.multishot
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
