extends Node3D

@export var light: OmniLight3D
@export var cam: Node3D
var time = 0
var base = 4

func _process(delta):
	time += delta
	cam.rotate(Vector3(0,1,0), delta * 0.1)
	var intensity = 0.8 + (0.2 * sin(time*7*0.1)) + (0.1 * sin(time*19*0.1))  + (0.05 * sin(time*31*0.1))
	light.omni_range = base * intensity
	light.light_size = base * intensity * 0.9
