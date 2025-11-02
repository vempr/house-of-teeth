extends Node2D

signal offer(there: bool)
signal actually_offer

var can_offer := false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("offer") && can_offer:
		actually_offer.emit()


func _on_offering_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		can_offer = true
		offer.emit(true)


func _on_offering_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		can_offer = false
		offer.emit(false)
