extends Node3D

@export var isRandom = true
@export var setSpeed = 1.0
@export var variance = 0.5

var speed

func _ready():
	if isRandom:
		var rng = RandomNumberGenerator.new()
		speed = rng.randf_range(setSpeed - variance, setSpeed + variance)
	else:
		speed = setSpeed

func _physics_process(delta):
	self.rotate(Vector3(0,1,0), speed * delta)
