extends CanvasLayer

const anim_names := ["bite", "bleed", "chew"]
var i := 0


func _ready() -> void:
	visible = false


func _on_animated_sprite_animation_finished() -> void:
	i += 1
	if i < anim_names.size():
		%AnimatedSprite.play(anim_names[i])


func _on_game_player_died() -> void:
	%DelayTimer.start()


func _on_delay_timer_timeout() -> void:
	visible = true
	%Desaturate.visible = false
	%HUD.visible = false
	%AnimatedSprite.play(anim_names[i])
	%AnimationPlayer.play("zoom")
	
	get_parent().pill_wore_off.emit()
