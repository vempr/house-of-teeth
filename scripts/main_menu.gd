extends Node2D

@onready var camera := %MainMenuCamera
@onready var center_pos = camera.position

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var target_pos = lerp(camera.position, mouse_pos, delta * 0.05)
	
	var offset = target_pos - center_pos
	if offset.length() > 50:
		offset = offset.normalized() * 50

	camera.position = center_pos + offset


func _on_mm_canvas_layer_start_game() -> void:
	%MainMenuCamera.enabled = false
	%HUD.visible = true
