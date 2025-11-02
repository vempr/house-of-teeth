extends Node2D


func _ready() -> void:
	var pills := get_children()
	
	for i in range(15):
		var rand_i := randi_range(0, pills.size() - 1)
		pills.remove_at(rand_i)
	
	for unused_pill in pills:
		unused_pill.queue_free()
