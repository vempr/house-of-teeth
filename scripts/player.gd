extends CharacterBody2D

const MAX_SPEED := 300.0
const ACCELERATION := MAX_SPEED / 0.15
const FRICTION := ACCELERATION

var health := 5
var last_direction := Vector2.ZERO
var current_velocity := Vector2.ZERO
@onready var anim := %AnimatedSprite


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		last_direction = direction
		
	if direction != Vector2.ZERO:
		current_velocity = current_velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = current_velocity
	move_and_slide()
	
	if velocity == Vector2.ZERO:
		if abs(last_direction.x) >= abs(last_direction.y):
			anim.play("idle_right")
			anim.flip_h = last_direction.x < 0
		else:
			if last_direction.y < 0:
				anim.play("idle_up")
			else:
				anim.play("idle_down")
	else:
		if direction.y < 0 && direction.x == 0:
			anim.play("walk_up")
		elif direction.y > 0 && direction.x == 0:
			anim.play("walk_down")
		else:
			anim.play("walk_right")
			anim.flip_h = direction.x < 0
