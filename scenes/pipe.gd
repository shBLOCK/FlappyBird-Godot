extends Area2D
class_name Pipe


@onready var PIPE_END_Y: float = $PipeEndMarker.position.y
@onready var WIDTH: float = $Sprite2D.get_rect().size.x

var end_pos: Vector2
var angle: float
var should_score: bool
var bird: Bird
var was_on_left_side: bool

@warning_ignore("shadowed_variable")
func init(end_pos: Vector2, angle: float, bird: Bird, should_score: bool):
	self.end_pos = end_pos
	self.angle = fposmod(angle, TAU)
	self.bird = bird
	self.should_score = should_score
	return self

func _ready():
	angle = fposmod(angle, TAU)
	
	var flip := PI*0.5 < angle and angle < PI*1.5
	if flip:
		scale.y = -1
	rotation = (angle - PI) if flip else angle
	
	move_local_y(-PIPE_END_Y)
	
	position += end_pos
	position.x += WIDTH * 0.5
	
	detect_scoring(true)


func detect_scoring(first_time := false):
	if not should_score:
		return
	
	var is_on_left_side = bird.global_position.x < $PipeEndMarker.global_position.x
	
	if not first_time:
		if is_on_left_side != was_on_left_side:
			bird.increase_score(1)
	was_on_left_side = is_on_left_side

func _physics_process(delta):
	if Globals.running:
		position.x -= Globals.game_speed * delta
		detect_scoring()

func _exited_screen():
	queue_free()
