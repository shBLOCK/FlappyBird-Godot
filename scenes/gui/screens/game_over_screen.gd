extends Control


signal reset_game

var current_score := 0
var _score_tween: Tween

func reset():
	pass

func _on_ok_button_pressed():
	await get_parent().transition_to(GUI.START)
	if _score_tween.is_valid():
		_score_tween.kill()
	for m in _medal_instances:
		m.free()
	reset()
	reset_game.emit()

func _on_changed_to():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("appear")

func _info_card_appeared():
	$InfoCard/Score.text = "0"
	_last_score = 0
	current_score = 50
	_score_tween = create_tween()
	var duration := 0.5
	if current_score > 10:
		duration = 1.0
	if current_score > 20:
		duration = 2.0
	_score_tween.tween_method(_info_card_score_tween_method, 0, current_score, duration)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_QUAD)

class _MedalTier:
	var score: int
	var sound_pitch: float
#	var audio_bus: int
	var image: Resource
	
	func _init(score: int, sound_pitch: float, image: Resource):
		self.score = score
		self.sound_pitch = sound_pitch
		self.image = image
#		AudioServer.add_bus()
#		AudioServer.set_bus_send(0, AudioServer.get_bus_name(0))
#		self.audio_bus = AudioServer.bus_count - 1
#		var effect = AudioEffectPitchShift.new()
#		effect.pitch_scale = self.sound_pitch
#		AudioServer.add_bus_effect(self.audio_bus, effect)

var MEDAL_TIERS = [
	_MedalTier.new(10, 0.7, preload("res://textures/ui/medal_bronze.tres")),
	_MedalTier.new(20, 0.8, preload("res://textures/ui/medal_silver.tres")),
	_MedalTier.new(30, 0.9, preload("res://textures/ui/medal_gold.tres")),
	_MedalTier.new(40, 1.0, preload("res://textures/ui/medal_platinum.tres")),
]
var _medal_instances = []

func _add_medal(tier: _MedalTier):
	var medal: TextureRect = $InfoCard/Medal.duplicate(0)
	medal.texture = tier.image
	_medal_instances.append(medal)
	$InfoCard.add_child(medal)
	var tween = get_tree().create_tween().bind_node(medal).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	const DUR = 0.3
#	$MedalSound.bus = AudioServer.get_bus_name(tier.audio_bus)
	#TODO: find better solution for pitch change
	var bus = AudioServer.get_bus_index("Medal")
	AudioServer.get_bus_effect(bus, 0).pitch_scale = tier.sound_pitch
	$MedalSound.play()
	tween.tween_property(medal, "scale", Vector2(1,1), DUR).from(Vector2(2,2))
	tween.tween_property(medal, "modulate", Color.WHITE, DUR).from(Color.TRANSPARENT)

var _last_score := 0
func _info_card_score_tween_method(score: int):
	$InfoCard/Score.text = str(score)
	for tier in MEDAL_TIERS:
		if _last_score < tier.score and score >= tier.score:
			_add_medal(tier)
	_last_score = score
	
