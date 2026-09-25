class_name GrowthConfig
extends Resource
## Rewards and level costs for one run.

@export_category("War Spirit Rewards")
@export_range(0, 20, 1) var normal_kill_reward := 2
@export_range(0, 50, 1) var elite_kill_reward := 8

@export_category("Upgrade Costs")
@export_range(1, 50, 1) var first_upgrade_cost := 3
@export_range(0, 20, 1) var cost_increase_per_level := 1
