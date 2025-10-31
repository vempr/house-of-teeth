extends CanvasLayer

const PILL_SATURATION := 0.1


func _on_game_pill_used() -> void:
	%Monsters.visible = true
	%ShaderRect.material.set_shader_parameter("enable_compression", true)
	%BlackOverlay.visible = false
	
	var curr_sat = %DesaturateRect.material.get_shader_parameter("saturation")
	var new_sat = curr_sat - PILL_SATURATION
	if new_sat < 0.0:
		new_sat = 0.0
	%DesaturateRect.material.set_shader_parameter("saturation", new_sat)


func _on_game_pill_wore_off() -> void:
	%Monsters.visible = false
	%ShaderRect.material.set_shader_parameter("enable_compression", false)
	%BlackOverlay.visible = true
	
	var curr_sat = %DesaturateRect.material.get_shader_parameter("saturation")
	var new_sat = curr_sat + PILL_SATURATION
	if new_sat > 0.5:
		new_sat = 0.5
	%DesaturateRect.material.set_shader_parameter("saturation", new_sat)
