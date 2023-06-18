class_name Helper

static func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

static func get_camera_rect(viewport: Viewport) -> Rect2:
	var rect := viewport.get_visible_rect()
	var cam := viewport.get_camera_2d()
	if cam == null:
		return rect
	rect.position += cam.get_screen_center_position() - rect.size * 0.5
	return rect

static func get_camera_rect_no_smooth(viewport: Viewport) -> Rect2:
	var rect := viewport.get_visible_rect()
	var cam := viewport.get_camera_2d()
	if cam == null:
		return rect
	rect.position += cam.position - rect.size * 0.5
	return rect
