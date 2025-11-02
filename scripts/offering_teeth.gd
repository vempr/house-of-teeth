extends Node2D

@onready var teeth := get_children()
var t_i := 0


func _ready() -> void:
	for tooth in teeth:
		tooth.modulate.a = 0.0


func _on_game_player_won() -> void:
	%OfferingTeethTimer.start()


func _on_offering_teeth_timer_timeout() -> void:
	if t_i >= 32:
		%OfferingTeethTimer.stop()
		%BoneShell.stop()
		return
	
	var tween = create_tween()
	tween.tween_property(teeth[t_i], "modulate:a", 1.0, 0.3)
	teeth[t_i].play_anim()
	t_i += 1
