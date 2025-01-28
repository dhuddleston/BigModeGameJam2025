extends Node


@export var light: DirectionalLight3D
@export var anim: AnimationPlayer

var lightningReady = true

func _ready():
	light.light_energy = 0
	
func _process(delta):
	if !lightningReady and Global.power == 0:
		lightningReady = true
	if lightningReady and Global.power > 0:
		lightningReady = false
		if Global.power > 0.7:
			anim.play("LightningLarge")
		elif Global.power > 0.3:
			anim.play("LightningMedium")
		else:
			anim.play("LightningSmall")
