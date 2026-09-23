extends RefCounted
## Scores a snapshot only at decision boundaries. Never interrupts telegraphs.
## Inspired by utility selection and LimboAI's attack/reposition separation;
## this implementation has no plugin dependency or copied upstream code.
var cooldowns := {"charge": 0.0, "spear": 0.0, "reposition": 0.0}
var last_action := ""
var repeats := 0
var last_scores: Dictionary = {}

func step(delta: float) -> void:
	for action in cooldowns:
		cooldowns[action] = maxf(0.0, cooldowns[action] - delta)

func choose(distance: float, same_lane: bool) -> String:
	last_scores = {
		"charge": 35.0 + (45.0 if same_lane else 0.0) + (15.0 if distance < 300.0 else 0.0),
		"spear": 35.0 + (30.0 if distance > 220.0 else 0.0),
		"reposition": 10.0 + (65.0 if not same_lane else 0.0)
	}
	var best := "wait"
	var score := -INF
	for action in last_scores:
		if cooldowns[action] > 0.0 or (action == last_action and repeats >= 2):
			last_scores[action] = -INF
		elif action == last_action:
			last_scores[action] -= 25.0
		if last_scores[action] > score:
			score = last_scores[action]
			best = action
	return best

func commit(action: String) -> void:
	if action == "wait":
		return
	repeats = repeats + 1 if action == last_action else 1
	last_action = action
	cooldowns[action] = 4.0 if action == "reposition" else 6.0
