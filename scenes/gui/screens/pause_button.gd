extends TextureButton


func _input(event):
	if event.is_action_pressed("flap"):
		if button_pressed:
			button_pressed = false
			get_viewport().set_input_as_handled()
