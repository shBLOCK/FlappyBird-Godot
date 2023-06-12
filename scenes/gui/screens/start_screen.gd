extends Control


signal prepare_game

func _on_play_button_pressed():
	await get_parent().transition_to(GUI.PLAYING)
	prepare_game.emit()
