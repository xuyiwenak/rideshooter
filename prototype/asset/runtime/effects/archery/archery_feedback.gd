extends Node2D
## Presentation only. Main advances particles and explicitly pauses gameplay audio.
const MAX_BURSTS := 48
const MAX_VOICES := 6
const LICENSED_PATHS := {
	&"release": "res://asset/runtime/audio/sfx/ovani_starter/bow_shoot.wav",
	&"hit": "res://asset/runtime/audio/sfx/ovani_starter/arrow_hit.wav",
	&"shield": "res://asset/runtime/audio/sfx/ovani_starter/shield_block.wav",
	&"reward": "res://asset/runtime/audio/sfx/ovani_starter/loot_gold.wav",
	&"select": "res://asset/runtime/audio/sfx/ovani_starter/click_bounce.wav",
	&"gallop": "res://asset/runtime/audio/sfx/ovani_starter/horse_gallop_loop.wav",
	&"field": "res://asset/runtime/audio/sfx/ovani_starter/grassy_field_loop.wav"
}
const SOUNDS := {
	&"release": [preload("res://asset/runtime/audio/sfx/bow_release_01.wav"), preload("res://asset/runtime/audio/sfx/bow_release_02.wav"), preload("res://asset/runtime/audio/sfx/bow_release_03.wav")],
	&"hit": [preload("res://asset/runtime/audio/sfx/arrow_hit_01.wav"), preload("res://asset/runtime/audio/sfx/arrow_hit_02.wav"), preload("res://asset/runtime/audio/sfx/arrow_hit_03.wav")],
	&"defeat": [preload("res://asset/runtime/audio/sfx/enemy_defeat_01.wav"), preload("res://asset/runtime/audio/sfx/enemy_defeat_02.wav"), preload("res://asset/runtime/audio/sfx/enemy_defeat_03.wav")]
}
var bursts: Array[Dictionary] = []
var voices: Array[AudioStreamPlayer] = []
var ui_voices: Array[AudioStreamPlayer] = []
var gallop_voice: AudioStreamPlayer
var field_voice: AudioStreamPlayer
var licensed_streams: Dictionary = {}
var cooldowns := {&"release": 0.0, &"hit": 0.0, &"defeat": 0.0, &"shield": 0.0}
var variants := {&"release": 0, &"hit": 0, &"defeat": 0, &"shield": 0}
var paused := false

func _ready() -> void:
	ensure_audio_ready()

func ensure_audio_ready() -> void:
	# Some SceneTree checks call main.initialize before child _ready notifications.
	if gallop_voice != null:
		return
	for kind in LICENSED_PATHS:
		var path: String = LICENSED_PATHS[kind]
		if ResourceLoader.exists(path):
			var stream := load(path) as AudioStream
			if stream != null:
				licensed_streams[kind] = stream
	for index in MAX_VOICES:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		voices.append(voice)
	for index in 2:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		ui_voices.append(voice)
	gallop_voice = AudioStreamPlayer.new()
	add_child(gallop_voice)
	gallop_voice.stream = licensed_streams.get(&"gallop")
	gallop_voice.volume_db = -23.0
	field_voice = AudioStreamPlayer.new()
	add_child(field_voice)
	field_voice.stream = licensed_streams.get(&"field")
	field_voice.volume_db = -32.0

func _exit_tree() -> void:
	for voice in voices + ui_voices + [gallop_voice, field_voice]:
		voice.stop()
		voice.stream = null

func reset() -> void:
	ensure_audio_ready()
	bursts.clear()
	for key in cooldowns:
		cooldowns[key] = 0.0
		variants[key] = 0
	for voice in voices + ui_voices + [gallop_voice, field_voice]:
		voice.stop()
	set_paused(false)
	queue_redraw()

func set_paused(value: bool) -> void:
	paused = value
	for voice in voices:
		voice.stream_paused = value
	gallop_voice.stream_paused = value
	field_voice.stream_paused = value

func step(delta: float) -> void:
	if paused:
		return
	for key in cooldowns:
		cooldowns[key] = maxf(0.0, cooldowns[key] - delta)
	for burst in bursts:
		burst.age += delta
	bursts = bursts.filter(func(b: Dictionary) -> bool: return b.age < b.duration)
	queue_redraw()
	if is_inside_tree() and field_voice.stream != null and not field_voice.playing:
		field_voice.play()

func sync_riding(rider: Node2D) -> void:
	if not is_inside_tree() or gallop_voice.stream == null or paused:
		return
	if rider.jump_left > 0.0:
		gallop_voice.stop()
	elif not gallop_voice.playing:
		gallop_voice.play()
	gallop_voice.pitch_scale = 1.18 if rider.charge_left > 0.0 else 1.0

func release(at: Vector2, direction: Vector2) -> void:
	add_burst(&"release", at, direction, 0.13)

func hit(at: Vector2, direction: Vector2) -> void:
	add_burst(&"hit", at, direction, 0.22)

func defeat(at: Vector2) -> void:
	add_burst(&"defeat", at, Vector2.LEFT, 0.38)

func shield_block(at: Vector2) -> void:
	add_burst(&"shield", at, Vector2.ZERO, 0.22)

func reward() -> void:
	play_ui_cue(&"reward", ui_voices[0], -15.0)

func select() -> void:
	play_ui_cue(&"select", ui_voices[1], -17.0)

func play_ui_cue(kind: StringName, voice: AudioStreamPlayer, volume: float) -> void:
	if not is_inside_tree() or not licensed_streams.has(kind):
		return
	voice.stop()
	voice.stream = licensed_streams[kind]
	voice.volume_db = volume
	voice.play()

func add_burst(kind: StringName, at: Vector2, direction: Vector2, duration: float) -> void:
	if paused:
		return
	if bursts.size() >= MAX_BURSTS:
		bursts.pop_front()
	bursts.append({"kind": kind, "pos": at, "dir": direction.normalized(), "age": 0.0, "duration": duration})
	play_cue(kind)
	queue_redraw()

func play_cue(kind: StringName) -> void:
	if not is_inside_tree():
		return
	if cooldowns[kind] > 0.0:
		return
	var fallback: Array = SOUNDS.get(kind, [])
	if not licensed_streams.has(kind) and fallback.is_empty():
		return
	for voice in voices:
		if voice.playing:
			continue
		var variant: int = variants[kind] % 3
		voice.stream = licensed_streams.get(kind, fallback[variant] if not fallback.is_empty() else null)
		voice.volume_db = -16.0 if kind == &"release" else -15.0
		voice.pitch_scale = [1.0, 0.97, 1.03][variant]
		voice.play()
		variants[kind] += 1
		cooldowns[kind] = 0.045 if kind == &"release" else 0.065
		return

func _draw() -> void:
	for burst in bursts:
		var t: float = burst.age / burst.duration
		var origin: Vector2 = burst.pos
		var alpha := 1.0 - t
		if burst.kind == &"release":
			var forward: Vector2 = burst.dir
			var side := forward.orthogonal()
			var bend := forward * sin(t * TAU * 2.0) * 3.0 * alpha
			draw_polyline(PackedVector2Array([origin - forward * 3.0 - side * 7.0, origin + bend, origin - forward * 3.0 + side * 7.0]), Color(1, 0.97, 0.8, alpha), 1.0)
			draw_line(origin + forward * 3.0, origin + forward * (7.0 + t * 12.0), Color(1, 1, 0.9, alpha), 1.5)
		elif burst.kind == &"hit":
			var radius := 6.0 * alpha + 2.0
			var points := PackedVector2Array()
			for index in 8:
				var angle := index * TAU / 8.0
				points.append(origin + Vector2.from_angle(angle) * (radius if index % 2 == 0 else radius * 0.3))
			draw_colored_polygon(points, Color(1, 0.93, 0.57, alpha))
			for index in 5:
				var direction := Vector2.from_angle(index * TAU / 5.0 + 0.3)
				var at := origin + direction * (4.0 + t * 15.0) + Vector2(0, t * t * 8.0)
				draw_line(at, at + direction * 3.0 * alpha, Color(1, 0.76, 0.3, alpha), 2.0)
		elif burst.kind == &"shield":
			draw_arc(origin, 10.0 + t * 17.0, 0.0, TAU, 24, Color(0.53, 0.88, 1.0, alpha), 2.0)
		else:
			for index in 5:
				var direction := Vector2.from_angle(index * TAU / 5.0)
				var at := origin + direction * (4.0 + t * 10.0) + Vector2(-t * 6.0, -t * 5.0)
				draw_circle(at, (3.0 + t * 5.0), Color(0.88, 0.81, 0.65, alpha * 0.7))
			for index in 3:
				var at := origin + Vector2((index - 1) * t * 23.0, -sin(t * PI) * (12.0 + index * 3.0))
				draw_rect(Rect2(at, Vector2(3, 2)), Color(0.64, 0.43, 0.23, alpha))
