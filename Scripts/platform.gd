extends Node2D

const PLATFORM_COUNT = 23
const MIN_X_DIFFERENCE = 100  # jarak minimal antar platform biar gak sejajar
const COIN_CHANCE = 0.5       # COIN
const COIN_OFFSET_Y = -40     # COIN
const SPAWN_SAFE_X = 120.0    # TEMBUS: jarak horizontal dari player yg dianggap "dekat"
const SPAWN_SAFE_Y = 60.0     # TEMBUS: jarak vertikal dari player yg dianggap "dekat"

var platform_scene = preload("res://Scenes/platform.tscn")
var coin_scene = preload("res://Scenes/coin.tscn")

var score := 0
var ghost_platforms: Array = []   # TEMBUS: platform yang sementara tembus

@onready var score_label: Label = $UI/ScoreLabel
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var player = $Player

func _ready():
	randomize()
	update_score_label()
	game_over_label.hide()
	player.died.connect(_on_player_died)
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
		
		# TEMBUS: kalau platform muncul dekat posisi spawn player, buat tembus dulu
		if is_near_player(platform.global_position):
			set_platform_solid(platform, false)
			ghost_platforms.append(platform)
		
		if randf() < COIN_CHANCE:
			spawn_coin(Vector2(last_x, last_y + COIN_OFFSET_Y))

# TEMBUS: cek tiap frame, kalau player sudah menjauh, platform jadi solid lagi
func _physics_process(_delta: float) -> void:
	if ghost_platforms.is_empty():
		return
	for platform in ghost_platforms.duplicate():
		# margin 1.5x supaya baru solid setelah player benar-benar keluar
		if not is_near_player(platform.global_position, 1.5):
			set_platform_solid(platform, true)
			ghost_platforms.erase(platform)

# TEMBUS
func is_near_player(pos: Vector2, margin := 1.0) -> bool:
	var p = player.global_position
	return abs(pos.x - p.x) < SPAWN_SAFE_X * margin and abs(pos.y - p.y) < SPAWN_SAFE_Y * margin

# TEMBUS: nyalakan/matikan collision semua shape di dalam platform
func set_platform_solid(platform: Node, solid: bool) -> void:
	for shape in platform.find_children("*", "CollisionShape2D", true, false):
		shape.set_deferred("disabled", not solid)
	for poly in platform.find_children("*", "CollisionPolygon2D", true, false):
		poly.set_deferred("disabled", not solid)

func spawn_coin(pos: Vector2) -> void:
	var coin = coin_scene.instantiate()
	coin.position = pos
	coin.collected.connect(_on_coin_collected)
	$CoinContainer.add_child(coin)

func _on_coin_collected() -> void:
	score += 1
	update_score_label()

func update_score_label() -> void:
	score_label.text = "Skor: %d" % score

func _on_player_died() -> void:
	$MobSpawner.stop()
	game_over_label.show()
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
