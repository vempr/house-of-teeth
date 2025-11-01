extends Node2D

signal pill_used
signal pill_wore_off
signal update_hud(teeth: int, pills: int)
signal player_died


var game_state := {
	"health": 5,
	"teeth": 0,
	"pills": 0,
}


func _ready() -> void:
	%Monsters.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("use_pill") && game_state.pills > 0 && game_state.health > 0:
		game_state.pills -= 1
		update_hud.emit(game_state.teeth, game_state.pills)
		pill_used.emit()
		%PillTimer.start()


func _on_chest_opened(has_tooth: bool) -> void:
	if has_tooth:
		game_state.teeth += 1
		update_hud.emit(game_state.teeth, game_state.pills)


func _on_pill_picked_up() -> void:
	game_state.pills += 1
	update_hud.emit(game_state.teeth, game_state.pills)


func _on_pill_timer_timeout() -> void:
	pill_wore_off.emit()


func _on_monster_player_attacked() -> void:
	if game_state.health == 0:
		return
	
	%BlackOverlay.modulate.a = 0.0
	var tween = create_tween()
	tween.parallel().tween_property(%BlackOverlay, "modulate:a", 1.0, 0.4)
	
	game_state.health -= 1
	if game_state.health == 0:
		pill_used.emit() # reveal monster(s) that player died to
		%Monsters.process_mode = Node.PROCESS_MODE_DISABLED
		player_died.emit()
		return
	
	var new_sat = %DesaturateRect.material.get_shader_parameter("saturation") - 0.1
	if new_sat < 0.0:
		new_sat = 0.0
	%DesaturateRect.material.set_shader_parameter("saturation", new_sat)
