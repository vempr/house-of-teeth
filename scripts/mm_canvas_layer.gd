extends CanvasLayer

signal start_game


func _ready() -> void:
	if GLOBAL.game_won:
		%Description.text = "You woke up in a house that wasn't supposed to exist. You made your offering before they consumed you!"
	elif GLOBAL.start_directly:
		_on_button_pressed()


func _on_button_pressed() -> void:
	start_game.emit()
	visible = false
