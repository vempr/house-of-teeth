extends CanvasLayer


func _ready() -> void:
	%Pills.text = "0"
	%Teeth.text = "0/32"


func _on_game_update_hud(teeth: int, pills: int) -> void:
	%Teeth.text = str(teeth) + "/32"
	$Pills.text = str(pills)
