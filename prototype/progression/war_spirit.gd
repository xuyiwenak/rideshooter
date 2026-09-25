extends Node
## Queues choices while retaining surplus XP. The game loop owns pausing.
signal upgrade_opened
signal choice_confirmed
@export var config: GrowthConfig = preload("res://config/progression/growth_default.tres")
var build: Node
var enabled := true
var war_spirit := 0
var war_spirit_need := 0
var growth_level := 0
var pending_upgrades := 0
var upgrade_open := false
var upgrade_options: Array[String] = []

func reset() -> void:
	war_spirit = 0
	war_spirit_need = config.first_upgrade_cost
	growth_level = 0
	pending_upgrades = 0
	upgrade_open = false
	upgrade_options.clear()

func on_kill(kind: String) -> void:
	gain(config.elite_kill_reward if kind == "elite" else config.normal_kill_reward)

func gain(amount: int) -> void:
	if not enabled:
		return
	war_spirit += amount
	while war_spirit >= war_spirit_need:
		war_spirit -= war_spirit_need
		growth_level += 1
		pending_upgrades += 1
		war_spirit_need += config.cost_increase_per_level
	if pending_upgrades > 0 and not upgrade_open:
		open_upgrade()

func next_path_skill(first: String, second: String) -> String:
	if build.skill_levels[first] < 2:
		return first
	if build.skill_levels[second] < 2:
		return second
	return ""

func open_upgrade() -> void:
	upgrade_options.clear()
	var preferred: Array[String] = [next_path_skill("multishot", "burn"),
		next_path_skill("ram", "shield"), "rapid" if growth_level % 2 == 1 else "heal"]
	for skill in preferred + ["heal", "rapid", "burn", "shield", "multishot", "ram"]:
		if skill != "" and build.skill_levels[skill] < 2 and skill not in upgrade_options:
			upgrade_options.append(skill)
			if upgrade_options.size() == 3:
				break
	upgrade_open = not upgrade_options.is_empty()
	if not upgrade_open:
		pending_upgrades = 0
	else:
		upgrade_opened.emit()

func choose(index: int) -> void:
	if not upgrade_open or index < 0 or index >= upgrade_options.size():
		return
	build.acquire(upgrade_options[index])
	pending_upgrades -= 1
	upgrade_open = false
	choice_confirmed.emit()
	if pending_upgrades > 0:
		open_upgrade()
