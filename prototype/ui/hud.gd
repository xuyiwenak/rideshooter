extends Node2D
## Presentation-only bindings. No HP changes, damage or upgrade application.
var rider: Node2D
var director: Node
var combat: Node2D
var growth: Node
var build: Node

func _draw() -> void:
	if rider == null:
		return
	# Leave the rider column clear when the top-lane rider jumps.
	draw_rect(Rect2(180, 0, 300, 54), Color("1e2735"))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(188, 17), "W/S lane  SPACE jump  SHIFT/E sprint  R restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)
	draw_string(font, Vector2(188, 35), "Kill %d  Road %d  CD %.1f  XP %d/%d" % [combat.kills, ceili(director.run_left), rider.charge_cooldown_left, growth.war_spirit, growth.war_spirit_need], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)
	var status := "F1 base  F2 elite  F3 arrow rain  F4 iron cavalry"
	if build.arrow_rain:
		status = "ARROW RAIN | Burning multi-target volley"
	elif build.iron_cavalry:
		status = "IRON CAVALRY | Shielded stronger charge"
	if director.elite_active():
		status = "ROAD PAUSED | Red: charge / Purple: spear / Green: open"
	draw_string(font, Vector2(188, 50), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("e7c988"))
	# Head indicators share the UI layer so overlapping actor atlases cannot hide them.
	for enemy in combat.enemies:
		if enemy.kind == "elite" or enemy.hp <= 0.0:
			continue
		var enemy_anchor: Vector2 = enemy.position + Vector2(-12, -41)
		draw_rect(Rect2(enemy_anchor, Vector2(24, 3)), Color("302e38"))
		draw_rect(Rect2(enemy_anchor, Vector2(24.0 * enemy.hp / enemy.max_hp, 3)), Color("b8d789"))
		if enemy.selected and not enemy.escaped:
			draw_circle(enemy.position + Vector2(0, -49), 3.0, Color("fff1ba"))
	var elite = combat.elite_actor()
	if elite != null:
		var color: Color = elite.state_color()
		var anchor: Vector2 = elite.position + Vector2(-24, -59)
		draw_rect(Rect2(anchor, Vector2(48, 5)), Color("302e38"))
		draw_rect(Rect2(anchor, Vector2(48 * elite.hp / elite.max_hp, 5)), color)
	# Draw in the UI layer so the top lane's jumping health remains visible.
	var health_anchor := Vector2(rider.position.x - 16, maxf(4.0, rider.position.y - 58))
	draw_rect(Rect2(health_anchor - Vector2(2, 2), Vector2(36, 10)), Color("1e2735"))
	for pip in 3:
		draw_rect(Rect2(health_anchor + Vector2(pip * 11, 0), Vector2(9, 6)), Color("ef7979") if pip < rider.health else Color("54464e"))
	if rider.health <= 0 or director.finished():
		draw_rect(Rect2(100, 87, 280, 87), Color(0.05, 0.08, 0.12, 0.9))
		var result := "Road complete" if rider.health > 0 else "Horse down - try again"
		if director.elite_practice and director.elite_defeated and rider.health > 0:
			result = "Elite defeated - well ridden!"
		draw_string(font, Vector2(127, 123), result, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
		draw_string(font, Vector2(165, 151), "Press R to restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
