extends Control


signal reset_game

var current_score := 0
var high_score := 0
var _score_tween: Tween

func _on_ok_button_pressed():
	await get_parent().transition_to(GUI.START)
	if _score_tween.is_valid():
		_score_tween.kill()
	for m in _medal_instances:
		if m != null:
			m.free()
	reset_game.emit()
	for player in $MedalSoundPlayers.get_children():
		player.free()
	_last_medal_tween = null
	_last_delay = 0.0

func load_highscore() -> int:
	if not FileAccess.file_exists(Globals.SCORES_FILE):
		save_highscore(0)
		return 0
	var file = FileAccess.open(Globals.SCORES_FILE, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null or not (data is Dictionary):
		return 0
	var highest = data.get("highest", 0)
	match typeof(highest):
		TYPE_INT, TYPE_FLOAT:
			return highest as int
	return 0

func save_highscore(score: int):
	var file = FileAccess.open(Globals.SCORES_FILE, FileAccess.WRITE)
	if file == null:
		return
	
	var json = JSON.new()
	file.store_string(JSON.stringify({"highest": score}))
	file.close()

func _on_changed_to():
	%InfoCard/Score.text = "0"
	high_score = load_highscore()
	%InfoCard/HighScore.text = str(high_score)
	if current_score > high_score:
		save_highscore(current_score)
	%InfoCard/NewLabel.hide()
	
	var t = create_tween().set_parallel()
	
	%GameOverTitle.modulate = Color.TRANSPARENT
	t.tween_property(%GameOverTitle, "modulate", Color.WHITE, 0.5)
	t.tween_method(
		$GameOverTitleAnimator.set_uniform.bind("offset"),
		Vector2.UP * 10.0,
		Vector2.ZERO,
		0.5
	)
	
	%InfoCard.hide()
	t.tween_callback(%InfoCard.show).set_delay(0.5)
	t.tween_method(
		$InfoCardAnimator.set_uniform.bind("offset"),
		Vector2.DOWN * (get_viewport_rect().end.y - %InfoCard.get_global_rect().position.y),
		Vector2.ZERO,
		0.8
	).set_delay(0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	t.tween_callback(_on_info_card_appeared).set_delay(0.5 + 0.8)
	
	%ButtonsContainer.hide()
	t.tween_callback(%ButtonsContainer.show).set_delay(1)
	%ButtonsContainer.modulate = Color.TRANSPARENT
	t.tween_property(%ButtonsContainer, "modulate", Color.WHITE, 0.5).set_delay(1)

func _on_info_card_appeared():
#	current_score = 50
	_last_score = 0
	_score_tween = create_tween()
	var duration = pow(current_score / 5.0, 0.3) * 5.0 / 5.0
	_score_tween.tween_method(_info_card_score_tween_method, 0, current_score + 1, duration)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_QUAD)
	_score_tween.tween_callback(_info_card_score_tween_method.bind(current_score))

class _MedalTier:
	var id: int
	var score: int
	var sound_pitch: float
	var audio_bus: String
	var image: Resource
	
	@warning_ignore("shadowed_variable")
	func _init(id: int, score: int, sound_pitch: float, image: Resource):
		self.id = id
		self.score = score
		self.sound_pitch = sound_pitch
		self.image = image
		
		self.audio_bus = "medal_%d" % self.id
		AudioServer.add_bus()
		var bus_id = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_id, self.audio_bus)
		AudioServer.set_bus_send(bus_id, "Master")
		var effect = AudioEffectPitchShift.new()
		effect.pitch_scale = self.sound_pitch
		AudioServer.add_bus_effect(bus_id, effect)

var MEDAL_TIERS = [
	_MedalTier.new(0, 10, 0.7, preload("res://textures/ui/medal_bronze.tres")),
	_MedalTier.new(1, 20, 0.8, preload("res://textures/ui/medal_silver.tres")),
	_MedalTier.new(2, 30, 0.9, preload("res://textures/ui/medal_gold.tres")),
	_MedalTier.new(3, 40, 1.0, preload("res://textures/ui/medal_platinum.tres")),
]
var _medal_instances = []

var _last_delay := 0.0
var _last_medal_tween: Tween
func _add_medal(tier: _MedalTier):
	var medal: TextureRect = %InfoCard.get_node("Medal").duplicate(0)
	medal.texture = tier.image
	_medal_instances.append(medal)
	%InfoCard.add_child(medal)
	var tween = get_tree().create_tween().bind_node(medal).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	if _last_medal_tween != null:
		var since_last = _last_medal_tween.get_total_elapsed_time()
		var min_interval = tier.id * 0.15
		if since_last < min_interval:
			var delay = (min_interval - since_last) + _last_delay
			tween.tween_interval(delay)
			_last_delay = delay
	
	const DUR = 0.4
	var player = AudioStreamPlayer.new()
	player.bus = tier.audio_bus
	player.stream = preload("res://sounds/medal.wav")
	$MedalSoundPlayers.add_child(player)
	
	tween.tween_callback(player.play)
	tween.parallel().tween_property(medal, "scale", Vector2(1,1), DUR).from(Vector2(2.5, 2.5))
	tween.parallel().tween_property(medal, "modulate", Color.WHITE, DUR).from(Color.TRANSPARENT)
	
	_last_medal_tween = tween

var _last_score := 0
func _info_card_score_tween_method(score: int):
	if score > current_score:
		return
	
	%InfoCard/Score.text = str(score)
	for tier in MEDAL_TIERS:
		if _last_score < tier.score and score >= tier.score:
			_add_medal(tier)
	_last_score = score
	
	if score > high_score:
		high_score = score
		%InfoCard/HighScore.text = str(high_score)
		if not %InfoCard/NewLabel.visible:
			%InfoCard/NewLabel/AnimationPlayer.play("new_label_appear")

func _process(_delta):
	var bus = AudioServer.get_bus_index("Medal")
	AudioServer.get_bus_effect(bus, 0).pitch_scale = randf_range(.5, 2.)
