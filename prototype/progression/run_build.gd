extends Node
## Owns the current build; no knowledge of enemies, UI or the game root.
signal skill_acquired(skill: String)
signal heal_requested(amount: int)
const C = preload("res://core/tuning.gd")
var skill_levels := {"multishot": 0, "burn": 0, "ram": 0, "shield": 0, "rapid": 0, "heal": 0}
var arrow_rain := false
var iron_cavalry := false
var heal_kills := 0

func reset() -> void:
	for skill in skill_levels:
		skill_levels[skill] = 0
	arrow_rain = false
	iron_cavalry = false
	heal_kills = 0

func acquire(skill: String) -> void:
	if not skill_levels.has(skill) or skill_levels[skill] >= 2:
		return
	skill_levels[skill] += 1
	check_evolutions()
	skill_acquired.emit(skill)

func check_evolutions() -> void:
	arrow_rain = skill_levels.multishot >= 2 and skill_levels.burn >= 2
	iron_cavalry = skill_levels.ram >= 2 and skill_levels.shield >= 2

func shot_interval() -> float:
	return C.SHOT_INTERVAL * [1.0, 0.82, 0.66][skill_levels.rapid]

func shield_restore_time() -> float:
	return [99.0, 10.0, 7.0][skill_levels.shield]

func counter_damage() -> float:
	return 4.0 + skill_levels.ram * 2.0

func on_kill(_kind: String) -> void:
	if skill_levels.heal == 0:
		return
	heal_kills += 1
	var need := 6 if skill_levels.heal == 1 else 4
	if heal_kills >= need:
		heal_kills = 0
		heal_requested.emit(1)

func apply_preset(preset: String) -> void:
	var components := ["multishot", "burn"] if preset == "arrow" else ["ram", "shield"]
	for skill in components:
		acquire(skill)
		acquire(skill)
