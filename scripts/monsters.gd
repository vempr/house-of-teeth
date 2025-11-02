extends Node2D

signal monsters_died


func _on_game_player_won() -> void:
	var monsters := get_children()
	for monster in monsters:
		monster.stop()
	
	modulate.a = 0.0
	visible = true
	var tween = create_tween()
	tween.set_trans(tween.TRANS_QUAD).tween_property(self, "modulate:a", 1.0, 3.0)
	
	await tween.finished
	for monster in monsters:
		monster.die()
	
	z_index = -1
	monsters_died.emit()
