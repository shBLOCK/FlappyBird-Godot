extends ParallaxLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var t := 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	$Day.self_modulate.a = remap(sin(t), -1, 1, 0, 1)
