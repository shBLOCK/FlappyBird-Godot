@tool
extends Control


@export var source: Control:
	set(value):
		source = value
		_update_source()

func _sync():
	if source == null:
		self.position = Vector2.ZERO
		self.size = Vector2.ZERO
		return
	var rect = source.get_global_rect()
	self.set_global_position(rect.position)
	self.set_size(rect.size)

var _source_resized_signal: Signal

func _update_source():
	if not _source_resized_signal.is_null():
		_source_resized_signal.disconnect(_on_source_resized)
	if source == null:
		return
	_source_resized_signal = source.resized
	_source_resized_signal.connect(_on_source_resized)
	_sync()

func _ready():
	_update_source()

func _on_source_resized():
	_sync()

#func _notification(what):
#	match what:
#		NOTIFICATION_RESIZED, NOTIFICATION_TRANSFORM_CHANGED, NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
#			print("self resize")
#			_sync()
