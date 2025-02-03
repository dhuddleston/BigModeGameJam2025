extends Node

var power = 0.0
var strokes: int = 0

var mainMenu = "res://Scenes/MainMenu.tscn"
#Put your levels in this array, along with their title and the score for par
#It controls the course progression and is used to generate the level select
var levels: Array[Level] = [
	Level.new("res://Scenes/Levels/IntroCutscene_Level.tscn", "Prologue", 0),
	Level.new("res://Scenes/Levels/around_the_corner_revamp.tscn", "Around the Corner", 3),
	Level.new("res://Scenes/Levels/StraightShot_Level.tscn", "Approach", 5),
	Level.new("res://Scenes/Levels/balance.tscn", "Balance", 4),
	Level.new("res://Scenes/Levels/Basement_Level.tscn", "Worlds Below", 6)
]

var currentLevel: int = 0
var furthestLevel: int = 0 #Furthest level that is unlocked

var levelUI: Control
var menuUI: Control

func _ready():
	SaveData.loadProgress()

class Level:
	var path: String
	var title: String
	var par: int
	var best
	func _init(path: String, title: String, par: int):
		self.path = path
		self.title = title
		self.par = par

func getRandomBird():
	var rng = RandomNumberGenerator.new()
	var birds = ["Falcon","Owl","Woodpecker","Peafowl","Crow","Raven","Robin","Kestrel","Hawk","Buzzard",\
		"Kingfisher","Pelican","Flamingo","Penguin","Turkey","Sparrow","Ostrich","Canary","Goldfish",\
		"Cardinal","Blue Jay","Hummingbird","Mockingbird","Parrot","Parakeet","Kea","Cassowary","Toucan",\
		"Heron","Spoonbill","Goose","Duck","Dodo","Swan","Emu","Stork","Bat","Freebird","Roc","Phoenix",\
		"Griffon","Dragon"] #A list of creatures that are all definitely very real birds
	return birds[rng.randi_range(0,birds.size()-1)]
