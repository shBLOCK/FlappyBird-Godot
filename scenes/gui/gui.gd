extends CanvasLayer
class_name GUI


enum {START, PLAYING, GAMEOVER}

@onready var SCREENS := {
	START: $StartScreen,
	PLAYING: $PlayingScreen,
	GAMEOVER: $GameOverScreen,
}
@onready var current: Control = SCREENS[START]

func _ready():
	for s in SCREENS.values():
		if s != current:
			remove_child(s)

func change_screen(screen: int):
	remove_child(current)
	current = SCREENS[screen]
	add_child(current)
	if current.has_method("_on_changed_to"):
		current._on_changed_to()

func transition_to(screen: int):
	$Transition/AudioStreamPlayer.play()
	$Transition/AnimationPlayer.play("transition")
	await $Transition/AnimationPlayer.animation_finished
	change_screen(screen)
	$Transition/AnimationPlayer.play_backwards("transition")
