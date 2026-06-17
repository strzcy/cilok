extends Node2D

const PLATFORM_COUNT = 23
const MIN_X_DIFFERENCE = 100  # jarak minimal antar platform biar gak sejajar

var platform_scene = preload("res://Scenes/platform.tscn")

func _ready():
	generate_platforms()

func generate_platforms():
	var last_x = 500.0
	var last_y = 585.0
	
	for i in range(PLATFORM_COUNT):
		var platform = platform_scene.instantiate()
		
		# generate x baru yang beda dari sebelumnya
		var new_x
		var attempts = 0
		while true:
			new_x = last_x + randf_range(-150, 150)
			# pastikan beda minimal MIN_X_DIFFERENCE dari posisi sebelumnya
			if abs(new_x - last_x) >= MIN_X_DIFFERENCE:
				break
			attempts += 1
			if attempts > 50:  # safety guard biar ga infinite loop
				new_x = last_x + MIN_X_DIFFERENCE
				break
		
		last_x = new_x
		last_y -= 75  # jarak vertikal tetap
		
		platform.position = Vector2(last_x, last_y)
		$PlatformContainer.add_child(platform)
