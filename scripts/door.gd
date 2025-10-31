extends StaticBody2D

enum DOOR_TYPE { ROUNDED, SQUARE, NONE }

@export var mirrored := false
@export var door_type := DOOR_TYPE.NONE
var can_open_door := false
var is_open := false


func _ready() -> void:
	if door_type == DOOR_TYPE.NONE:
		if randf() < 0.5:
			door_type = DOOR_TYPE.ROUNDED
		else:
			door_type = DOOR_TYPE.SQUARE
	
	match door_type:
		DOOR_TYPE.ROUNDED:
			%Rounded.visible = true
			%Square.visible = false
			%ClosedRoundedSprite.visible = true
			%OpenRoundedSprite.visible = false
			
			if mirrored:
				%ClosedRoundedSprite.flip_h = true
				%OpenRoundedSprite.flip_h = true
		
		DOOR_TYPE.SQUARE:
			%Rounded.visible = false
			%Square.visible = true
			%ClosedSquareSprite.visible = true
			%OpenSquareSprite.visible = false
			
			if mirrored:
				%ClosedSquareSprite.flip_h = true
				%OpenSquareSprite.flip_h = true


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_door") && can_open_door:
		is_open = !is_open
		if is_open:
			%CollisionShape.set_deferred("disabled", true)
			match door_type:
				DOOR_TYPE.ROUNDED:
					%ClosedRoundedSprite.visible = false
					%OpenRoundedSprite.visible = true
				DOOR_TYPE.SQUARE:
					%ClosedSquareSprite.visible = false
					%OpenSquareSprite.visible = true
		else:
			%CollisionShape.set_deferred("disabled", false)
			match door_type:
				DOOR_TYPE.ROUNDED:
					%ClosedRoundedSprite.visible = true
					%OpenRoundedSprite.visible = false
				DOOR_TYPE.SQUARE:
					%ClosedSquareSprite.visible = true
					%OpenSquareSprite.visible = false


func _on_openable_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		can_open_door = true


func _on_openable_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		can_open_door = false
