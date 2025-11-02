extends CharacterBody2D

const NORMAL_SPEED := 250.0
const PILLED_SPEED := 300.0

var MAX_SPEED := NORMAL_SPEED
var ACCELERATION := MAX_SPEED / 0.15
var FRICTION := ACCELERATION

var last_direction := Vector2.ZERO
var current_velocity := Vector2.ZERO
@onready var anim := %AnimatedSprite
var is_playing_open_anim := false
var is_playing_hurt_anim := false
var is_dead := false


func _ready() -> void:
	%HealthBar.value = 5.0


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		last_direction = direction
	
	if direction != Vector2.ZERO:
		current_velocity = current_velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = current_velocity
	move_and_slide()
	
	if is_playing_hurt_anim:
		return
	
	if direction == Vector2.ZERO:
		if abs(last_direction.x) >= abs(last_direction.y):
			if !is_playing_open_anim:
				anim.play("idle_right")
			anim.flip_h = last_direction.x < 0
		else:
			if !is_playing_open_anim:
				if last_direction.y < 0:
					anim.play("idle_up")
				else:
					anim.play("idle_down")
	else:
		if MAX_SPEED == NORMAL_SPEED:
			if direction.y < 0 && direction.x == 0:
				if !is_playing_open_anim:
					anim.play("walk_up")
			elif direction.y > 0 && direction.x == 0:
				if !is_playing_open_anim:
					anim.play("walk_down")
			else:
				if !is_playing_open_anim:
					anim.play("walk_right")
				anim.flip_h = direction.x < 0
		else:
			if direction.y < 0 && direction.x == 0:
				if !is_playing_open_anim:
					anim.play("run_up")
			elif direction.y > 0 && direction.x == 0:
				if !is_playing_open_anim:
					anim.play("run_down")
			else:
				if !is_playing_open_anim:
					anim.play("run_right")
				anim.flip_h = direction.x < 0


func play_open_chest_animation() -> void:
	is_playing_open_anim = true
	
	if last_direction.y < 0 && last_direction.x == 0:
		anim.play("open_up")
	elif last_direction.y > 0 && last_direction.x == 0:
		anim.play("open_down")
	else:
		anim.play("open_right")
		anim.flip_h = last_direction.x < 0
	
	await anim.animation_finished
	is_playing_open_anim = false


func _on_pill_used() -> void:
	MAX_SPEED = PILLED_SPEED


func _on_pill_wore_off() -> void:
	MAX_SPEED = NORMAL_SPEED


func _on_monster_player_attacked() -> void:
	if is_dead:
		return
	
	%HealthBar.value -= 1.0
	if %HealthBar.value <= 0.0:
		%HealthBar.visible = false
		is_dead = true
		
		if last_direction.y < 0 && last_direction.x == 0:
			anim.play("die_up")
		elif last_direction.y > 0 && last_direction.x == 0:
			anim.play("die_down")
		else:
			anim.play("die_right")
			anim.flip_h = last_direction.x < 0
		
		return
	
	is_playing_hurt_anim = true
	
	if last_direction.y < 0 && last_direction.x == 0:
		anim.play("hurt_up")
	elif last_direction.y > 0 && last_direction.x == 0:
		anim.play("hurt_down")
	else:
		anim.play("hurt_right")
		anim.flip_h = last_direction.x < 0
	
	await anim.animation_finished
	is_playing_hurt_anim = false
