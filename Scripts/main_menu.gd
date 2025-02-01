extends Control

@export var mainMenu: Control
@export var levelMenu: Control
@export var levelList: Control
var levelButtonFab = preload("res://Prefabs/UI/level_button.tscn")

func _ready():
	Global.menuUI = self
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	build_level_select()
	
func build_level_select():
	for i in Global.levels.size():
		var btn = levelButtonFab.instantiate()
		btn.level = i
		var info = Global.levels[i]
		btn.text = str(info.title," | Par: ", info.par, " | Best: ", info.best)
		levelList.add_child(btn)

func _on_play_pressed():
	var level = Global.furthestLevel % Global.levels.size()
	Global.currentLevel = level
	get_tree().change_scene_to_file(Global.levels[level].path)

func _on_exit_pressed():
	get_tree().quit()

func _on_level_select_pressed():
	mainMenu.visible = false
	levelMenu.visible = true

func _on_back_pressed():
	mainMenu.visible = true
	levelMenu.visible = false
