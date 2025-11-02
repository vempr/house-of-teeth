extends Node

var game_won := false
var start_directly := false


func _ready() -> void:
	var mp = AudioStreamPlayer.new()
	mp.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(mp)
	mp.stream = load("res://sound/Fifty Grand - Severed Arm.mp3")
	mp.pitch_scale = 0.85
	mp.volume_db = -30.0
	mp.play()
