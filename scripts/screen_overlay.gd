extends CanvasLayer

func _ready():
	visible = false  # Hide at start

func show_restart():
	visible = true

func show_victory():
	visible = true
	
func _on_Button_pressed():
	get_tree().reload_current_scene()
	

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_restart_button_mouse_entered() -> void:
	$HoverSFX.play()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
	
func _on_quit_button_mouse_entered() -> void:
	$HoverSFX.play()
	
