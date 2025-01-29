extends Control


func _on_play_pressed():
	var level = Global.currentLevel % Global.levels.size()
	get_tree().change_scene_to_file(Global.levels[level].path)

func _on_level_select_pressed():
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()
