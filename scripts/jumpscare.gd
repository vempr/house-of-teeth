extends CanvasLayer

signal start_game_directly

const anim_names := ["bite", "bleed", "chew"]
var i := 0


func _ready() -> void:
	%Title.modulate.a = 0.0
	%MainMenuButton.modulate.a = 0.0
	%RetryButton.modulate.a = 0.0
	visible = false


func _on_animated_sprite_animation_finished() -> void:
	i += 1
	if i < anim_names.size():
		%AnimatedSprite.play(anim_names[i])


func _on_game_player_died() -> void:
	%DelayTimer.start()


func _on_delay_timer_timeout() -> void:
	%Distorted.stop()
	%Bite.play(0.2)
	%BoneSnap.play(0.2)
	visible = true
	%Desaturate.visible = false
	%AnimatedSprite.play(anim_names[i])
	%AnimationPlayer.play("zoom")
	
	get_parent().pill_wore_off.emit()
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(%Title, "modulate:a", 1.0, 3.0)
	tween.tween_property(%MainMenuButton, "modulate:a", 1.0, 3.0)
	tween.tween_property(%RetryButton, "modulate:a", 1.0, 3.0)


func _on_retry_button_pressed() -> void:
	GLOBAL.start_directly = true
	await Fade.fade_out().finished
	start_game_directly.emit()
	get_tree().reload_current_scene()
	Fade.fade_in()


func _on_main_menu_button_pressed() -> void:
	await Fade.fade_out().finished
	get_tree().reload_current_scene()
	Fade.fade_in()
