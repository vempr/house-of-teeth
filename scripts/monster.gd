extends Node2D

enum PLANE { HORIZONTAL, VERTICAL, DIAGONAL }

signal player_attacked

@export var plane := PLANE.HORIZONTAL
@onready var speed := randi_range(70, 100)
var direction := Vector2.ZERO
var player_being_attacked := false
var is_moving := true


func _ready() -> void:
	match plane:
		PLANE.HORIZONTAL:
			if randf() > 0.5:
				direction.x = 1
			else:
				direction.x = -1
				%AnimatedSprite.flip_h = true
		PLANE.VERTICAL:
			if randf() > 0.5:
				direction.y = 1
			else:
				direction.y = -1
		PLANE.DIAGONAL:
			direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()


func _physics_process(delta: float) -> void:
	if !is_moving:
		return
	
	position += direction * speed * delta
	return
	
	#match plane:
		#PLANE.HORIZONTAL:
			#position.x += direction.x * speed * delta
			#
			#if direction.x > 0 && %RayCastRight.is_colliding():
				#direction.x = -1
				#%AnimatedSprite.flip_h = true
			#elif direction.x < 0 && %RayCastLeft.is_colliding():
				#direction.x = 1
				#%AnimatedSprite.flip_h = false
		#
		#PLANE.VERTICAL:
			#position.y += direction.y * speed * delta
			#
			#if direction.y > 0 && %RayCastDown.is_colliding():
				#direction.y = -1
			#elif direction.y < 0 && %RayCastUp.is_colliding():
				#direction.y = 1
		#
		#PLANE.DIAGONAL:
			#position += direction * speed * delta
			#
			#if direction.x > 0 && %RayCastRight.is_colliding():
				#direction.x = -abs(direction.x)
				#%AnimatedSprite.flip_h = true
			#elif direction.x < 0 && %RayCastLeft.is_colliding():
				#direction.x = abs(direction.x)
				#%AnimatedSprite.flip_h = false
			#
			#if direction.y > 0 && %RayCastDown.is_colliding():
				#direction.y = -abs(direction.y)
			#elif direction.y < 0 && %RayCastUp.is_colliding():
				#direction.y = abs(direction.y)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D && is_moving:
		player_being_attacked = true
		%AnimatedSprite.play("attack")
		await %AnimatedSprite.animation_finished
		%AnimatedSprite.play("walk")
		%AttackTimer.start()
		
		if player_being_attacked:
			player_attacked.emit()


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D && is_moving:
		player_being_attacked = false


func _on_attack_timer_timeout() -> void:
	if !is_moving:
		return
	
	if player_being_attacked:
		%AnimatedSprite.play("attack")
		await %AnimatedSprite.animation_finished
		%AnimatedSprite.play("walk")
		
		if player_being_attacked:
			player_attacked.emit()
	else:
		%AttackTimer.stop()
		%AnimatedSprite.play("walk")


func stop() -> void:
	is_moving = false
	%AnimatedSprite.stop()
	%AttackTimer.stop()
	%Areas.process_mode = Node.PROCESS_MODE_DISABLED


func die() -> void:
	%AnimatedSprite.play("die")


func _on_area_right_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		if direction.x > 0 && is_moving:
			direction.x = -abs(direction.x)
			%AnimatedSprite.flip_h = true


func _on_area_left_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		if direction.x < 0 && is_moving:
			direction.x = abs(direction.x)
			%AnimatedSprite.flip_h = false


func _on_area_up_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		if direction.y < 0 && is_moving:
			direction.y = abs(direction.y)


func _on_area_down_body_entered(body: Node2D) -> void:
	if body is not CharacterBody2D:
		if direction.y > 0 && is_moving:
			direction.y = -abs(direction.y)
