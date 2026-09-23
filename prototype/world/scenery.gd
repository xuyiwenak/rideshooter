extends Node2D
## Parallax reads distance only. Sun is deliberately independent of speed.
var road: Node2D

func _draw() -> void:
	if road == null:
		return
	draw_rect(Rect2(0, 0, 480, 270), Color("647f88"))
	draw_circle(Vector2(439, 65), 10.0, Color("f3d49a"))
	for layer in 2:
		var ratio := 0.025 if layer == 0 else 0.09
		var color := Color("738f8b") if layer == 0 else Color("506e69")
		for peak in 5:
			var x := fposmod(peak * 160.0 - road.road_scroll * ratio, 800.0) - 160.0
			var points := PackedVector2Array([Vector2(x, 95), Vector2(x + 65, 59 + layer * 9), Vector2(x + 170, 95)])
			draw_colored_polygon(points, color)
	draw_rect(Rect2(0, 79, 480, 191), Color("344b41"))
	for mark in 8:
		var x := fposmod(mark * 74.0 - road.road_scroll * 0.35, 592.0) - 40.0
		draw_circle(Vector2(x, 78), 5.0, Color("3c5a4c"))
		draw_circle(Vector2(x + 6, 79), 4.0, Color("3c5a4c"))
