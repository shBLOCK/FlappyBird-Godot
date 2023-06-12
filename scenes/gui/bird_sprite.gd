@tool
extends Control


func _process(_delta):
	custom_minimum_size.x = $AnimatedSprite2D.sprite_frames.get_frame_texture("fly", 0).get_width()
	$AnimatedSprite2D.position = self.size / 2
