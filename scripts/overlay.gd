extends CanvasLayer

const PILL_SATURATION := 0.1


func _on_game_pill_used() -> void:
	%Monsters.visible = true
	%ShaderRect.material.set_shader_parameter("enable_compression", true)
	
	var curr_sat = %DesaturateRect.material.get_shader_parameter("saturation")
	var new_sat = curr_sat - PILL_SATURATION
	if new_sat < 0.0:
		new_sat = 0.0
	%DesaturateRect.material.set_shader_parameter("saturation", new_sat)
	
	%BlackOverlay.modulate.a = 0.0
	var tween = create_tween()
	tween.parallel().tween_property(%BlackOverlay, "modulate:a", 1.0, 10.0)


func _on_game_pill_wore_off() -> void:
	%Monsters.visible = false
	%ShaderRect.material.set_shader_parameter("enable_compression", false)
	
	var curr_sat = %DesaturateRect.material.get_shader_parameter("saturation")
	var new_sat = curr_sat + PILL_SATURATION
	if new_sat > 0.5:
		new_sat = 0.5
	%DesaturateRect.material.set_shader_parameter("saturation", new_sat)
