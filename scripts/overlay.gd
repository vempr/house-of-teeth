extends CanvasLayer


func _on_game_pill_used() -> void:
	%ShaderRect.material.set_shader_parameter("enable_compression", true)
	%BlackOverlay.visible = false
	%DesaturateRect.material.set_shader_parameter("saturation", 0.3)


func _on_game_pill_wore_off() -> void:
	%ShaderRect.material.set_shader_parameter("enable_compression", false)
	%BlackOverlay.visible = true
	%DesaturateRect.material.set_shader_parameter("saturation", 0.5)
