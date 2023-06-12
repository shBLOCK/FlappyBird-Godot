extends ParallaxBackground


func _process(delta):
	if Globals.running:
		self.scroll_offset.x -= Globals.game_speed * delta
