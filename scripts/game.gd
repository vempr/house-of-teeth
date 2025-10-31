extends Node2D

var game_state := {
	"teeth": 0
}


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_chest_opened(has_tooth: bool) -> void:
	if has_tooth:
		game_state.teeth += 1
