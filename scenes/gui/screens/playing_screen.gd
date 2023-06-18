extends Control


signal start_game
signal pause_changed(pause: bool)

var pending_start := true

func _input(event):
	if pending_start:
		if event.is_action_pressed("flap"):
			get_viewport().set_input_as_handled()
			pending_start = false
			$AnimationPlayer.play("fade")
			start_game.emit()

func update_score(score: int):
	$Score.text = str(score)

func _on_changed_to():
	update_score(0)
	show()
	pending_start = true
	$AnimationPlayer.stop()

func _on_pause_button_toggled(button_pressed):
	pause_changed.emit(button_pressed)
