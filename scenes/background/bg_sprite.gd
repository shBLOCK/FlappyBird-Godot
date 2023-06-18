extends Sprite2D


@export var speed_scale := 1.0

func _ready():
	# Move to camera position
	self.position.y -= get_viewport_rect().size.y * 0.5

func _process(_delta):
	var rect := Helper.get_camera_rect(get_viewport())
	
	self.position.x = rect.position.x
	self.region_rect.size.x = rect.size.x
	self.region_rect.position.x = rect.position.x * speed_scale
