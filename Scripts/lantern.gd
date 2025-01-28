extends Node

const brightLightCoef = 0.8 #Fraction of the light radius before brightness begins to falloff

@export var baseRange: float = 3.0
@export var maxRange: float = 6.0

@export var changeSpeed: float = 1.0
@export var light: OmniLight3D

func _ready():
	light.omni_range = baseRange
	light.light_size = baseRange * brightLightCoef
	
func _process(delta):
	var targetRange = lerp(baseRange, maxRange, Global.power)
	var targetSize = brightLightCoef * targetRange
	light.omni_range = lerp(light.omni_range, targetRange, delta * changeSpeed)
	light.light_size = lerp(light.light_size, targetSize, delta * changeSpeed)
