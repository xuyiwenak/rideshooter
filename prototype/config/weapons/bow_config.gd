class_name BowConfig
extends Resource
## Inspector-editable values for the currently implemented bow skill line.

@export_category("Base Shot")
@export_range(0.05, 3.0, 0.01, "suffix:s") var base_shot_interval := 0.55
@export_range(50.0, 1000.0, 5.0, "suffix:px/s") var projectile_speed := 420.0
@export_range(0.0, 20.0, 0.05) var same_lane_damage := 1.0
@export_range(0.0, 20.0, 0.05) var adjacent_lane_damage := 0.5

@export_category("Multishot")
@export_range(0, 8, 1) var multishot_level_1_extra_targets := 1
@export_range(0, 8, 1) var multishot_level_2_extra_targets := 2
@export_range(1, 9, 1) var arrow_rain_total_targets := 3

@export_category("Rapid Fire")
@export_range(0.1, 1.0, 0.01) var rapid_level_1_interval_multiplier := 0.82
@export_range(0.1, 1.0, 0.01) var rapid_level_2_interval_multiplier := 0.66

@export_category("Burn")
@export_range(0.05, 3.0, 0.05, "suffix:s") var burn_tick_interval := 0.50
@export_range(0.0, 10.0, 0.05) var burn_level_1_tick_damage := 0.35
@export_range(0.0, 10.0, 0.05) var burn_level_2_tick_damage := 0.70
@export_range(0.0, 20.0, 0.05, "suffix:s") var burn_level_1_duration := 2.25
@export_range(0.0, 20.0, 0.05, "suffix:s") var burn_level_2_duration := 3.00
