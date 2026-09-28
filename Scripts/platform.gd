extends Node2D

const PLATFORM_COUNT = 23
const MIN_X_DIFFERENCE = 100
const COIN_CHANCE = 0.5
const COIN_OFFSET_Y = -40

var platform_scene = preload("res://Scenes/platform.tscn")
var coin_scene = preload("res://Scenes/coin.tscn")

var score := 0

@onready var score_label: Label = $UI/ScoreLabel

func _ready():
	randomize()
	update_score_label()
	generate_platforms()

func generate_platforms():
	var last_x = 500.0
	var last_y = 585.0
	
	for i in range(PLATFORM_COUNT):
		var platform = platform_scene.instantiate()
		
		var new_x
		var attempts = 0
		while true:
			new_x = last_x + randf_range(-150, 150)
			if abs(new_x - last_x) >= MIN_X_DIFFERENCE:
				break
			attempts += 1
			if attempts > 50:
				new_x = last_x + MIN_X_DIFFERENCE
				break
		
		last_x = new_x
		last_y -= 75
		
		platform.position = Vector2(last_x, last_y)
		$PlatformContainer.add_child(platform)
		
		if randf() < COIN_CHANCE:
			spawn_coin(Vector2(last_x, last_y + COIN_OFFSET_Y))

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
