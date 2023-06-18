extends Node


@onready var window := get_window()


func _ready():
	Globals.running = true
	%Bird.hide()

func _on_gui_prepare_game():
	%Bird.show()
	Globals.running = true

func _on_gui_start_game():
	%Bird.state = Bird.FLYING
	%Bird.flap()
	%WorldManager.start_generation()

func _on_bird_score_changed(_bird: Bird, new_score: int, _old_score: int):
	%GUI/PlayingScreen.update_score(new_score)

func _on_bird_hit(_bird):
	Globals.running = false
	%WorldManager.stop_generation()
	$ScreenFlash.flash()
	%GUI/PlayingScreen.hide()

func _on_bird_died(_bird):
	%GUI.SCREENS[GUI.GAMEOVER].current_score = %Bird.score
	%GUI.change_screen(GUI.GAMEOVER)

func _on_gui_reset_game():
	%Bird.hide()
	%Bird.state = Bird.IDLE
	%MainCamera.force_update()
	Globals.running = true
	%WorldManager.clear()

func _on_gui_pause(pause: bool):
	get_tree().paused = pause
