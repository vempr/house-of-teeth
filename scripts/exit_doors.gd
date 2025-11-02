extends Node2D


func _on_monsters_monsters_died() -> void:
	for door in get_children():
		door.static_open()
