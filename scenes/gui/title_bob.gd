@tool
extends HBoxContainer


var time := 0.0

func _process(delta):
	time += delta
	offset_bottom = remap(sin(time * PI * 2.), -1.0, 1.0, -38.0, -42.0)
