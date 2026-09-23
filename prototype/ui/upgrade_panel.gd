extends Node2D
## Displays choices and emits intent; progression applies the selected skill.
signal selected(index: int)
const Catalog = preload("res://progression/skill_data/catalog.gd")
var growth: Node
var build: Node

func handle_key(key: int) -> void:
	if key >= KEY_1 and key <= KEY_3:
		selected.emit(key - KEY_1)

func _unhandled_input(event: InputEvent) -> void:
	if growth == null or not growth.upgrade_open:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for index in growth.upgrade_options.size():
			if Rect2(19 + index * 153, 67, 137, 139).has_point(get_global_mouse_position()):
				selected.emit(index)
				get_viewport().set_input_as_handled()
				queue_redraw()
				return

func _draw() -> void:
	if growth == null or not growth.upgrade_open:
		return
	draw_rect(Rect2(0, 0, 480, 270), Color(0.03, 0.05, 0.08, 0.9))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(155, 42), "LEVEL UP - CHOOSE 1", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("fff1ba"))

	for index in growth.upgrade_options.size():
		var x: float = 19.0 + index * 153.0
		var skill: String = growth.upgrade_options[index]
		var next_level: int = build.skill_levels[skill] + 1
		var tint: Color = [Color("668fc2"), Color("c27d55"), Color("8ea966")][index]
		draw_rect(Rect2(x, 67, 137, 139), Color("202c3a"))
		draw_rect(Rect2(x, 67, 137, 5), tint)
		draw_string(font, Vector2(x + 9, 91), "%d  %s" % [index + 1, Catalog.NAMES[skill]], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
		draw_string(font, Vector2(x + 9, 110), "LEVEL %d / 2" % next_level, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, tint)
		draw_string(font, Vector2(x + 9, 137), Catalog.DESCRIPTIONS[skill], HORIZONTAL_ALIGNMENT_LEFT, 119, 9, Color("d5d8db"))
	var hint := "Press 1 / 2 / 3 or click a card"
	draw_string(font, Vector2(110, 232), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("d5d8db"))
