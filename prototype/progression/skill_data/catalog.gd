extends RefCounted
## Display data lives outside combat and UI code.
const NAMES := {
	"multishot": "MULTISHOT", "burn": "BURN", "ram": "RAM",
	"shield": "SHIELD", "rapid": "RAPID FIRE", "heal": "KILL HEAL"
}
const DESCRIPTIONS := {
	"multishot": "Extra target per shot",
	"burn": "Arrows deal damage over time",
	"ram": "More elite counter damage",
	"shield": "Block one hit, then recharge",
	"rapid": "Shorter auto-shot interval",
	"heal": "Heal after enough kills"
}
