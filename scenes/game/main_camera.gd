extends Camera2D


func update():
	var size := get_viewport_rect().size
	position.x = %Bird.position.x + size.x * 0.25

func force_update():
	update()
	reset_smoothing()

func _ready():
	force_update()

func _process(_delta):
	update()
