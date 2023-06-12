extends Control


signal start_game

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
	show()
	pending_start = true
	$AnimationPlayer.stop()
