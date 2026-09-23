extends RefCounted
## Damage payload. Recipients own HP, invulnerability, burning and death.
var amount: float
var burn_level: int

func _init(value: float = 0.0, burning: int = 0) -> void:
	amount = value
	burn_level = burning
