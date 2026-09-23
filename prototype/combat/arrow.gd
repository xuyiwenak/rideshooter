extends Node2D
## Fixed flight path; collisions use the swept segment from the last step.
const Damage = preload("res://combat/damage.gd")
var velocity := Vector2.ZERO
var previous := Vector2.ZERO
var hostile := false
var source := 0
var damage := 1.0
var burn := false
var burn_level := 0
var consumed := false
var pos: Vector2:
	get: return position
	set(value): position = value

func configure(data: Dictionary) -> void:
	position = data.pos
	previous = position
	velocity = data.velocity
	hostile = data.hostile
	source = data.source
	damage = data.damage
	burn_level = data.get("burn_level", 0)
	burn = burn_level > 0

func step(delta: float) -> void:
	previous = position
	position += velocity * delta
	queue_redraw()

func intersects(center: Vector2, radius: float) -> bool:
	return Geometry2D.get_closest_point_to_segment(center, previous, position).distance_to(center) < radius

func payload() -> RefCounted:
	return Damage.new(damage, burn_level)

func expired() -> bool:
	return consumed or position.x < -30.0 or position.x > 520.0 or position.y < 40.0 or position.y > 270.0

func _draw() -> void:
	var color := Color("ff725f") if hostile else Color("fff1ba")
	if burn:
		color = Color("ff9a47")
	draw_line(-velocity.normalized() * (19.0 if hostile else 12.0), Vector2.ZERO, color, 2.0)
