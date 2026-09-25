class_name WaveEnemy
extends Resource
## One ordinary enemy in a wave. Lane offset wraps across three lanes.

@export_enum("infantry", "archer", "raider") var kind := "infantry"
@export_range(0, 2, 1) var lane_offset := 0
@export_range(480.0, 1200.0, 5.0, "suffix:px") var start_x := 495.0
