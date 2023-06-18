extends Node2D


@export var pipe_scene: PackedScene

@onready var Obstacles := $Obstacles

const SPACING = 100
var _next_pos := 0.0
var _generating = false

func start_generation():
	_next_pos = Helper.get_camera_rect_no_smooth(get_viewport()).end.x + Pipe.WIDTH * 0.5
	_generating = true

func stop_generation():
	_generating = false

func clear():
	for obj in Obstacles.get_children():
		obj.queue_free()

func _process(_delta):
	if _generating:
		var edge = Helper.get_camera_rect_no_smooth(get_viewport()).end.x + Pipe.WIDTH * 0.5
		if _next_pos < edge:
			_generate()

func _generate():
	_gen_pipe_pair(_next_pos)
	_next_pos += SPACING

func _gen_pipe_pair(x_pos: float):
	var mid_pos = Vector2(x_pos, randf_range(-45, 25))
	var gap = randf_range(28, 32)
	
	var top := pipe_scene.instantiate().init(mid_pos - Vector2(0, gap), PI, %Bird, false) as Pipe
	var bottom := pipe_scene.instantiate().init(mid_pos + Vector2(0, gap), 0, %Bird, true) as Pipe
	
	Obstacles.add_child(top)
	Obstacles.add_child(bottom)
