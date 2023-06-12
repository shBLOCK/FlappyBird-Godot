extends Node


var pipe_scene := preload("res://scenes/pipe.tscn")
@onready var window := get_window()

@export var pipe_y_min := 60
@export var pipe_y_max := 130
@export var pipe_gap_min := 28
@export var pipe_gap_max := 32


func _ready():
	Globals.running = true

func _on_gui_prepare_game():
	$Bird.state = Bird.IDLE
	$Bird.show()
	$BirdResetter.bobbing = true
	Globals.running = true

func _on_gui_start_game():
	$BirdResetter.bobbing = false
	$Bird.state = Bird.FLYING
	$Bird.flap()
	$PipeTimer.start()

func gen_pipe_pair():
	var mid_pos = Vector2(window.content_scale_size.x, randi_range(pipe_y_min, pipe_y_max))
	var gap = randi_range(pipe_gap_min, pipe_gap_max)
	
	var top = pipe_scene.instantiate().init(mid_pos - Vector2(0, gap), PI, $Bird, false)
	var bottom = pipe_scene.instantiate().init(mid_pos + Vector2(0, gap), 0, $Bird, true)
	
	add_child(top)
	add_child(bottom)
	
	top.add_to_group("pipes")
	bottom.add_to_group("pipes")

func _on_pipe_timer_timeout():
	gen_pipe_pair()

func _on_bird_score_changed(_bird: Bird, new_score: int, _old_score: int):
	$GUI/PlayingScreen.update_score(new_score)

func _on_bird_hit(_bird):
	Globals.running = false
	$PipeTimer.stop()
	$ScreenFlash.flash()
	$GUI/PlayingScreen.hide()

func _on_bird_died(_bird):
	$GUI.SCREENS[GUI.GAMEOVER].current_score = $Bird.score
	$GUI.change_screen(GUI.GAMEOVER)

func _on_gui_reset_game():
	$Bird.hide()
	$BirdResetter.reset($Bird)
	Globals.running = true
	get_tree().call_group("pipes", "queue_free")
