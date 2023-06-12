extends CanvasLayer


func flash():
	$AnimationPlayer.play("flash")

func get_flashing():
	return $AnimationPlayer.current_animation == "flash"
