extends StaticBody2D

signal chest_opened(has_tooth: bool)

@export var has_tooth := false
var in_open_zone := false
var opened := false


func _ready() -> void:
	%ClosedSprite.visible = true
	%ClosedSpriteShader.visible = true
	%ClosedSpriteShader.modulate.a = 0.0
	%OpenSprite.visible = false
	%Tooth.visible = false


func _process(_delta: float) -> void:
	if opened == false:
		if Input.is_action_just_pressed("open_chest") && in_open_zone:
			%Chest.play()
			%Player.play_open_chest_animation()
			
			%ClosedSpriteShader.visible = false
			%ClosedSprite.visible = false
			%OpenSprite.visible = true
			
			opened = true
			chest_opened.emit(has_tooth)
			
			if has_tooth:
				%Tooth.visible = true
				%AnimationPlayer.play("tooth")
				%Bone.play()


func _on_open_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if opened == false:
			var tween = create_tween()
			tween.tween_property(%ClosedSpriteShader, "modulate:a", 1.0, 0.2)
		
		in_open_zone = true


func _on_open_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		if opened == false:
			var tween = create_tween()
			tween.tween_property(%ClosedSpriteShader, "modulate:a", 0.0, 0.1)
		
		in_open_zone = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "tooth":
		var tween = create_tween()
		tween.parallel().tween_property(%Tooth, "modulate:a", 0.0, 1.0)
		tween.parallel().tween_property(%OpenSprite, "modulate:a", 0.5, 1.0)
