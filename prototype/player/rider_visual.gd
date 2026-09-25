extends Node2D
## No autonomous animation: Rider and AutoBow supply pose via the shared clock.
@export var skin: RiderSkin = preload("res://asset/runtime/characters/rider/skins/adventurer/rider_skin.tres")
# Alignment corrections for the existing horse's six back silhouettes.
const SEAT_OFFSETS = [Vector2(0, 0), Vector2(-1, 2), Vector2(0, -1), Vector2(1, 0), Vector2(1, -2), Vector2(-1, 0)]
const ARM_RECTS = [Rect2(-14, -50, 32, 34), Rect2(-10, -50, 33, 34), Rect2(-14, -50, 35, 34), Rect2(-15, -50, 32, 34)]
var shot_pose := -1
var lean := 0.0

func sync_pose(horse_frame: int, sprinting: bool, airborne: bool, hurt: bool) -> void:
	position = SEAT_OFFSETS[horse_frame]
	lean = 2.0 if sprinting or airborne else 0.0
	modulate.a = 0.5 if hurt else 1.0
	queue_redraw()

func set_shot_pose(value: int) -> void:
	shot_pose = value
	queue_redraw()

func muzzle() -> Vector2:
	return position + Vector2(18.0 + lean, -34.0)

func _draw() -> void:
	if skin == null:
		return
	# Same hip and stirrup anchors for every upper-body pose.
	draw_texture_rect(skin.saddle, Rect2(-18, -24, 22, 13), false)
	if skin.quiver != null:
		draw_texture_rect(skin.quiver, Rect2(-23 + lean, -38, 10, 19), false)
	draw_texture_rect(skin.body, Rect2(-16, -33, 20, 29), false)
	draw_texture_rect(skin.stirrup, Rect2(-5, -14, 8, 12), false)
	draw_texture_rect(skin.head, Rect2(-23 + lean, -51, 25, 19), false)
	# Full arm/weapon pairs keep grip and string registration per pose.
	var pose := maxi(shot_pose, 0)
	var arm_rect: Rect2 = ARM_RECTS[pose]
	arm_rect.position.x += lean
	if shot_pose < 0:
		# Rest uses the released empty bow pose, lowered slightly.
		pose = 3
		arm_rect = Rect2(-15 + lean, -46, 32, 30)
	draw_texture_rect(skin.arms[pose], arm_rect, false)
