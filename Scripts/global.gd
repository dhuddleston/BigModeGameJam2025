extends Node

var power = 0.0

var levels: Array[Level] = [
	Level.new("res://Scenes/ball_test_scene.tscn", "Example 1"),
	Level.new("res://Scenes/Experimental_Level.tscn", "Example 2")
]

var currentLevel: int = 0

class Level:
	var path: String
	var title: String
	func _init(path: String, title: String):
		self.path = path
		self.title = title
