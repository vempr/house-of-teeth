extends Node2D

signal rand_chest_spawned(at: int)

@onready var normal_chests := %Normal.get_children()
@onready var random_chests := %Random.get_children()


func _ready() -> void:
	for i in range(32 - 1):
		var rand_i := randi_range(0, normal_chests.size() - 1)
		normal_chests[rand_i].has_tooth = true
		normal_chests.remove_at(rand_i)
	
	var rand_chest_i := randi_range(0, 2)
	random_chests[rand_chest_i].has_tooth = true
	rand_chest_spawned.emit(rand_chest_i)
