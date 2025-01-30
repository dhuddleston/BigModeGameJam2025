extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false

func _on_play_pressed():
	var level = Global.furthestLevel % Global.levels.size()
	Global.currentLevel = level
	get_tree().change_scene_to_file(Global.levels[level].path)

func _on_level_select_pressed():
	pass # Replace with function body.

func _on_exit_pressed():
	get_tree().quit()
