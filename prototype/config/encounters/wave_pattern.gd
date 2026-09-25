class_name WavePattern
extends Resource
## A repeatable wave, relative to one lane from EncounterConfig.lane_cycle.

@export var enemies: Array[WaveEnemy] = []
@export_category("Optional Obstacle")
@export var has_obstacle := false
@export_range(0, 2, 1) var obstacle_lane_offset := 0
@export_range(480.0, 1200.0, 5.0, "suffix:px") var obstacle_start_x := 740.0
