extends CanvasLayer

var curr_t := 0
var curr_p := 0


func _ready() -> void:
	%Pills.text = "0"
	%Teeth.text = "0/32"
	
	%OfferComplete.visible = true
	%OfferIncomplete.visible = true
	%OfferComplete.modulate.a = 0.0
	%OfferIncomplete.modulate.a = 0.0
	
	visible = GLOBAL.start_directly
	GLOBAL.start_directly = false
	
	%Introduction.modulate.a = 1.0


func _on_game_update_hud(teeth: int, pills: int) -> void:
	curr_t = teeth
	curr_p = pills
	
	%Teeth.text = str(teeth) + "/32"
	$Pills.text = str(pills)
	%OfferIncomplete.text = "You need " + str(32 - teeth) + " more teeth to complete the offering."


func _on_areas_offer(there: bool) -> void:
	var tween = create_tween()
	
	if there:
		if curr_t >= 32:
			tween.tween_property(%OfferComplete, "modulate:a", 1.0, 0.5)
		else:
			tween.tween_property(%OfferIncomplete, "modulate:a", 1.0, 0.5)
	else:
		if curr_t >= 32:
			tween.tween_property(%OfferComplete, "modulate:a", 0.0, 0.5)
		else:
			tween.tween_property(%OfferIncomplete, "modulate:a", 0.0, 0.5)


func _on_areas_actually_offer() -> void:
	if curr_t < 32:
		return
	
	visible = false


func _on_intro_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(%Introduction, "modulate:a", 0.0, 2.0)
