extends CharacterBody2D

signal died                                      # BARU

@export var walk_speed = 150.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var deceleration = 0.1
@onready var grak = $AnimatedSprite2D
const JUMP_VELOCITY = -400.0

var is_dead := false                             # BARU


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# BARU: kalau sudah mati, tidak bisa gerak atau lompat
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * walk_speed, walk_speed * acceleration)
		grak.play("walk")
		grak.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
		grak.play("idle")

	move_and_slide()


# BARU: dipanggil oleh Spike saat mengenai player
func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity.x = 0
	grak.play("die")
	died.emit()
