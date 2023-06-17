extends CanvasGroup


func set_uniform(value, uniform: StringName):
	material.set_shader_parameter(uniform, value)
