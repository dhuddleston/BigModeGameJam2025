extends Node

var config: ConfigFile

func loadProgress():
	config = ConfigFile.new()
	var err = config.load("user://save.cfg")
	if err != OK:
		return
	
	var furthestBeaten = -1
	for level in config.get_sections():
		var num = int(level.split("_")[1]) #Parse level number
		var score = int(config.get_value(level, "best"))
		Global.levels[num].best = score
		if num > furthestBeaten:
			furthestBeaten = num
	Global.furthestLevel = furthestBeaten+1

func saveProgress(level: int, score: int):
	config = ConfigFile.new()
	config.load("user://save.cfg")
	
	config.set_value(str("level_",level), "best", score)
	config.save("user://save.cfg")
	
