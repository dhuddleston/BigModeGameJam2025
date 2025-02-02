extends Button

var level

func _on_pressed():
	Global.currentLevel = level
	get_tree().change_scene_to_file(Global.levels[level].path)
