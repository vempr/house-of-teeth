extends Node2D

signal picked_up_pill

@export var on_table := false
var can_be_picked_up := false
var picked_up := false


func _ready() -> void:
	%Sprite.visible = true
	%Sprite.flip_h = randi_range(0, 1) == 0
	
	%SpriteShader.visible = true
	%SpriteShader.modulate.a = 0.0
	%SpriteShader.flip_h = %Sprite.flip_h
	if %SpriteShader.flip_h:
		%SpriteShader.scale.x = 6.0
	
	if on_table:
		%PillShadowTable.visible = true
		%PillShadow.visible = false
	else:
		%PillShadowTable.visible = false
		%PillShadow.visible = true


func _process(_delta: float) -> void:
	if picked_up == false:
		if Input.is_action_just_pressed("pick_up") && can_be_picked_up:
			%Ding.play()
			picked_up = true
			picked_up_pill.emit()
			
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 0.1)
			await tween.finished
			queue_free()


func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if picked_up == false:
			var tween = create_tween()
			tween.tween_property(%SpriteShader, "modulate:a", 1.0, 0.2)
		
		can_be_picked_up = true


func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		if picked_up == false:
			var tween = create_tween()
			tween.tween_property(%SpriteShader, "modulate:a", 0.0, 0.1)
		
		can_be_picked_up = false
