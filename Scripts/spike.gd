extends Area2D

@export var fall_speed := 500.0
@export var max_lifetime := 6.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# hapus otomatis kalau sudah lama, biar tidak menumpuk
	get_tree().create_timer(max_lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position.y += fall_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()
