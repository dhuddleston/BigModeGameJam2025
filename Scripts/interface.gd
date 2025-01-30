extends Control

@export var menu: Control
@export var victoryMenu: Control
@export var strokeCounter: Label
@export var parLabel: Label
@export var levelLabel: Label
@export var victoryLabel: Label
@export var nextLevelButton: Button

func _ready():
	if Global.currentLevel == Global.levels.size():
		nextLevelButton.text = "Main Menu"

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_ESCAPE:
			if menu.visible:
				close()
			else:
				open()

func _process(delta):
	strokeCounter.text = str("Stroke: ", Global.strokes)
	parLabel.text = str("Par: ", Global.levels[Global.currentLevel].par)
	levelLabel.text = Global.levels[Global.currentLevel].title

func close():
	get_tree().paused = false
	menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func open():
	get_tree().paused = true
	menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_continue_button_pressed():
	close()

func _on_restart_button_pressed():
	var level = Global.currentLevel % Global.levels.size()
	close()
	get_tree().change_scene_to_file(Global.levels[level].path)

func _on_exit_level_button_pressed():
	get_tree().change_scene_to_file(Global.mainMenu)

func _on_next_level_button_pressed():
	if Global.currentLevel == Global.levels.size():
		return _on_exit_level_button_pressed()
	Global.currentLevel += 1
	Global.furthestLevel = maxi(Global.currentLevel, Global.furthestLevel)
	get_tree().change_scene_to_file(Global.levels[Global.currentLevel].path)

func show_victory_screen():
	var par = Global.levels[Global.currentLevel].par
	var previousBest = Global.levels[Global.currentLevel].best
	if Global.strokes < previousBest:
		SaveData.saveProgress(Global.currentLevel, Global.strokes)
	
	if Global.strokes == 1:
		victoryLabel.text = "Hole in One!!!"
	elif Global.strokes == par:
		victoryLabel.text = "Par"
	elif Global.strokes > par:
		match (Global.strokes - par):
			1:
				victoryLabel.text = "Bogey..."
			2:
				victoryLabel.text = "Double Bogey..."
			3:
				victoryLabel.text = "Triple Bogey..."
			_:
				victoryLabel.text = "You blew it....."
	elif Global.strokes < par:
		match (par - Global.strokes):
			1:
				victoryLabel.text = "Birdie!"
			2:
				victoryLabel.text = "Eagle!"
			3:
				victoryLabel.text = "Albatross!"
			4:
				victoryLabel.text = "Condor!"
			_:
				victoryLabel.text = str(Global.getRandomBird(),"?!")
	
	if Global.strokes < 0:
		victoryLabel.text = str("ULTRA ",victoryLabel.text)
		
	victoryMenu.visibile = true
