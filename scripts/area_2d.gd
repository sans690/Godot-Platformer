extends Area2D

var player_in_area = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true
		print("Player entered area")

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		print("Player exited area")

func _process(delta):
	if player_in_area and Input.is_physical_key_pressed(KEY_Q):
		print("Q pressed while in area")
		get_tree().change_scene_to_file("res://scenes/room.tscn")
