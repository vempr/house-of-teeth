extends Node2D

signal pill_used
signal pill_wore_off
signal update_hud(teeth: int, pills: int)
signal player_died
signal player_won


var game_state := {
	"health": 5,
	"teeth": 0,
	"pills": 1,
}
var game_won := false


func _ready() -> void:
	%Monsters.visible = false
	%CRT.visible = true
	update_hud.emit(game_state.teeth, game_state.pills)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("use_pill") && game_state.pills > 0 && game_state.health > 0 && !game_won:
		%PillBottle.play()
		%Distorted.play()
		
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
	%Distorted.stop()
	
	if !game_won:
		pill_wore_off.emit()
	else:
		%CRT._on_game_pill_wore_off()


func _on_monster_player_attacked() -> void:
	if game_state.health == 0:
		return
	
	flash()
	
	game_state.health -= 1
	%Hit.play()
	
	if game_state.health == 0:
		pill_used.emit() # reveal monster(s) that player died to
		%Monsters.process_mode = Node.PROCESS_MODE_DISABLED
		player_died.emit()
		return
	
	var new_sat = %DesaturateRect.material.get_shader_parameter("saturation") - 0.1
	if new_sat < 0.0:
		new_sat = 0.0
	%DesaturateRect.material.set_shader_parameter("saturation", new_sat)


func flash() -> void:
	%BlackOverlay.modulate.a = 0.0
	var tween = create_tween()
	tween.parallel().tween_property(%BlackOverlay, "modulate:a", 1.0, 0.4)


func _on_areas_actually_offer() -> void:
	if game_state.teeth < 32:
		return
	
	%BoneShell.play()
	game_won = true
	player_won.emit()


func _on_win_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		GLOBAL.game_won = true
		await Fade.fade_out(5.0, Color.WHITE).finished
		get_tree().reload_current_scene()
		Fade.fade_in(3.0, Color.WHITE)
