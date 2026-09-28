extends Node2D

@export var spike_scene: PackedScene = preload("res://Scenes/spike.tscn")
@export var spawn_interval := 3.0     # jeda antar tusukan
@export var warning_time := 1.5       # lama peringatan sebelum jatuh
@export var spike_width := 30.0       # lebar area merah (samakan dgn lebar tusukan)
@export var x_range := 250.0          # sebaran x dari posisi player

var active := true

func _ready() -> void:
	randomize()
	$SpawnTimer.wait_time = spawn_interval
	$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
	$SpawnTimer.start()

func stop() -> void:
	active = false
	$SpawnTimer.stop()

func _on_spawn_timer_timeout() -> void:
	if not active:
		return
	var player = get_tree().get_first_node_in_group("player")
	var cam = get_viewport().get_camera_2d()
	if player == null or cam == null:
		return
	
	var x = player.global_position.x + randf_range(-x_range, x_range)
	var center = cam.get_screen_center_position()
	
	# 1) peringatan merah: kolom tinggi di posisi x
	var warning = ColorRect.new()
	warning.color = Color(1, 0, 0, 0.35)
	warning.size = Vector2(spike_width, 4000)
	add_child(warning)
	warning.global_position = Vector2(x - spike_width / 2.0, center.y - 2000)
	
	# berkedip
	var tween = warning.create_tween().set_loops()
	tween.tween_property(warning, "modulate:a", 0.3, 0.15)
	tween.tween_property(warning, "modulate:a", 1.0, 0.15)
	
	# 2) tunggu, biar player sempat menghindar
	await get_tree().create_timer(warning_time).timeout
	warning.queue_free()
	if not active:
		return
	
	# 3) tusukan jatuh dari atas layar
	var screen_h = get_viewport_rect().size.y / cam.zoom.y
	var top_y = cam.get_screen_center_position().y - screen_h / 2.0
	var spike = spike_scene.instantiate()
	add_child(spike)
	spike.global_position = Vector2(x, top_y - 150)
