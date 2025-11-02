extends CanvasLayer

var can_pause := GLOBAL.start_directly


func _ready() -> void:
	visible = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") && can_pause:
		visible = !visible
		get_tree().paused = visible


func _on_mm_canvas_layer_start_game() -> void:
	can_pause = true


func _on_button_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_game_player_died() -> void:
	can_pause = false
