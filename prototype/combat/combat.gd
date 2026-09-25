extends Node2D
## Owns actor lifetime and collision routing, not actor decisions or progression.
signal enemy_killed(kind: String)
signal hit_confirmed(at: Vector2, direction: Vector2)
signal enemy_defeated(at: Vector2)
const C = preload("res://core/tuning.gd")
const Infantry = preload("res://enemies/infantry.tscn")
const Archer = preload("res://enemies/archer.tscn")
const Raider = preload("res://enemies/raider.tscn")
const Elite = preload("res://enemies/elite/elite.tscn")
const Arrow = preload("res://combat/arrow.tscn")
var rider: Node2D
var bow: Node
var enemies: Array[Node2D] = []
var arrows: Array[Node2D] = []
var kills := 0
var escaped := 0
var next_id := 0

func reset() -> void:
	# Include retired actors awaiting queue_free; no child survives restart.
	for actor in get_children():
		actor.free()
	enemies.clear()
	arrows.clear()
	kills = 0
	escaped = 0
	next_id = 0

func spawn_enemy(route: int, start_x: float, kind: String) -> Node2D:
	var scene: PackedScene = {"infantry": Infantry, "archer": Archer, "raider": Raider, "elite": Elite}[kind]
	var enemy = scene.instantiate()
	next_id += 1
	enemy.configure(next_id, route, start_x, rider)
	enemy.died.connect(_on_death.bind(enemy))
	enemy.escaped_screen.connect(_on_escape)
	enemy.attack_requested.connect(fire_hostile)
	enemies.append(enemy)
	add_child(enemy)
	return enemy

func spawn_arrow(data: Dictionary) -> void:
	var arrow = Arrow.instantiate()
	arrow.configure(data)
	arrows.append(arrow)
	add_child(arrow)

func fire_hostile(origin: Vector2, velocity: Vector2, source: int) -> void:
	spawn_arrow({"pos": origin, "velocity": velocity, "source": source, "hostile": true, "damage": 1.0})

func _on_death(kind: String, enemy: Node2D) -> void:
	enemy_defeated.emit(enemy.hit_center())
	kills += 1
	enemy_killed.emit(kind)

func _on_escape() -> void:
	escaped += 1

func source_active(source: int) -> bool:
	for enemy in enemies:
		if enemy.id == source and enemy.hp > 0.0 and not enemy.escaped:
			return true
	return false

func elite_actor() -> Node2D:
	for enemy in enemies:
		if enemy.kind == "elite" and enemy.hp > 0.0:
			return enemy
	return null

func step(delta: float, road_speed: float = C.ROAD_SPEED) -> void:
	for enemy in enemies:
		if enemy.hp > 0.0:
			enemy.step(delta, road_speed)
	bow.step(delta)
	for arrow in arrows:
		arrow.step(delta)
		if arrow.hostile:
			if not source_active(arrow.source):
				arrow.consumed = true
			elif arrow.intersects(rider.hit_center(), 14.0):
				rider.hurt()
				arrow.consumed = true
		else:
			for enemy in enemies:
				if enemy.hp > 0.0 and not enemy.escaped and arrow.intersects(enemy.hit_center(), 12.0):
					var impact := Geometry2D.get_closest_point_to_segment(enemy.hit_center(), arrow.previous, arrow.pos)
					enemy.take_damage(arrow.payload())
					hit_confirmed.emit(impact, arrow.velocity)
					arrow.consumed = true
					break
	cleanup()
	var target = bow.pick_target()
	for enemy in enemies:
		enemy.selected = enemy == target
		enemy.queue_redraw()

func cleanup() -> void:
	for arrow in arrows.duplicate():
		if arrow.expired():
			arrows.erase(arrow)
			arrow.visible = false
			arrow.queue_free()
	for enemy in enemies.duplicate():
		if enemy.hp <= 0.0 or enemy.x < -30.0:
			enemies.erase(enemy)
			enemy.visible = false
			enemy.queue_free()

func clear_arrows() -> void:
	for arrow in arrows:
		arrow.free()
	arrows.clear()
