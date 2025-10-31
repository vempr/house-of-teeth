extends Node2D

signal pill_used
signal pill_wore_off

var game_state := {
	"teeth": 0,
	"pills": 0,
}


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("use_pill") && game_state.pills > 0:
		game_state.pills -= 1
		pill_used.emit()
		%PillTimer.start()


func _on_chest_opened(has_tooth: bool) -> void:
	if has_tooth:
		game_state.teeth += 1


func _on_pill_picked_up() -> void:
	game_state.pills += 1


func _on_pill_timer_timeout() -> void:
	pill_wore_off.emit()
