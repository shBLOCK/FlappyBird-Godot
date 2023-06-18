extends Area2D
class_name Pipe


static var WIDTH := 26.0

var should_score: bool
var bird: Bird
var was_on_left_side: bool

@warning_ignore("shadowed_variable")
func init(pos: Vector2, angle: float, bird: Bird, should_score: bool):
	self.position = pos;
	self.rotation = fposmod(angle, TAU)
	self.bird = bird
	self.should_score = should_score
	
	if rotation > PI*0.5 and rotation < PI*1.5:
		for child in get_children():
			if child is Sprite2D:
				child.flip_h = true
	
	return self

func _ready():
	detect_scoring(true)


func detect_scoring(first_time := false):
	if not should_score:
		return
	
	var is_on_left_side = bird.global_position.x < self.global_position.x
	
	if not first_time:
		if is_on_left_side != was_on_left_side:
			bird.increase_score(1)
	was_on_left_side = is_on_left_side

func _physics_process(_delta):
	if Globals.running:
		detect_scoring()

func _exited_screen():
	if position.x < get_viewport().get_camera_2d().get_screen_center_position().x:
		queue_free()
