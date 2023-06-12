@tool
extends Node


var bobbing = false
var time := 0.0

func reset(bird: Bird):
	bird.position = $Marker2D.position

func bob(bird: Bird):
	var pos = $Marker2D.position
	pos.y += sin(time * PI) * 5
	bird.position = pos

func _process(delta):
	if Engine.is_editor_hint():
		bobbing = true
	
	time += delta
	if bobbing:
		bob($"../Bird")
