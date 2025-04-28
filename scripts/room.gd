extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

func _ready():
	spawn_enemies()

func spawn_enemies():
	for i in range(4):  # Loop to spawn 4 enemies
		var enemy = enemy_scene.instantiate()
		enemy.position = Vector2(100 * i, 93)  
		add_child(enemy)
		enemy.add_to_group("enemy") 
		#print("Enemy spawned at position: ", enemy.position)
