class_name EncounterConfig
extends Resource
## One road's duration, elite gate and repeatable ordinary waves.

@export_category("Road And Elite")
@export_range(10.0, 300.0, 0.5, "suffix:road s") var run_length := 60.0
@export_range(1.0, 300.0, 0.5, "suffix:road s") var elite_trigger_remaining := 30.0
@export_range(1.0, 300.0, 0.5, "suffix:road s") var pre_elite_spawn_stop_remaining := 36.0
@export_range(0, 2, 1) var elite_spawn_lane := 1
@export_range(400.0, 1200.0, 5.0, "suffix:px") var elite_spawn_x := 450.0

@export_category("Wave Timing")
@export_range(0.1, 30.0, 0.1, "suffix:road s") var first_wave_delay := 1.4
@export_range(0.5, 30.0, 0.1, "suffix:road s") var wave_interval := 5.0

@export_category("Wave Composition")
@export var lane_cycle := PackedInt32Array([1, 0, 2])
@export var patterns: Array[WavePattern] = []
