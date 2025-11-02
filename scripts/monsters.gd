extends Node2D

signal monsters_died


func _on_game_player_won() -> void:
	var monsters := get_children()
	for monster in monsters:
		if monster.name != "Random":
			monster.stop()
		else:
			monster.visible = false
			monster.process_mode = Node.PROCESS_MODE_DISABLED
	
	modulate.a = 0.0
	visible = true
	var tween = create_tween()
	tween.set_trans(tween.TRANS_QUAD).tween_property(self, "modulate:a", 1.0, 3.0)
	
	await tween.finished
	for monster in monsters:
		if monster.name != "Random":
			monster.die()
	
	z_index = -1
	monsters_died.emit()


func _on_chests_rand_chest_spawned(at: int) -> void:
	match at:
		0:
			$Random/Left.queue_free()
		1:
			$Random/Middle.queue_free()
		2:
			$Random/Right.queue_free()
