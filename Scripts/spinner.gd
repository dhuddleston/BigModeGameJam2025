extends Node3D

@export var speed: float = 1.0
@export var minRotation: float = 0.0
@export var maxRotation: float = 180.0
@export var reverseDir: bool = false

var remainingRotation = 0
var spinReady = true
@export var isPlatform = false

var oldParent
var exitedTime
var exiting = false
var ball
	
func _physics_process(delta):
	if !spinReady and Global.power == 0:
		spinReady = true
	if spinReady and Global.power > 0:
		spinReady = false
		remainingRotation = lerp(deg_to_rad(minRotation), deg_to_rad(maxRotation), Global.power)
	if(remainingRotation > 0):
		var step = delta * speed
		if step > remainingRotation:
			step = remainingRotation
			remainingRotation = 0
		else:
			remainingRotation -= step
		var dir = -1 if reverseDir else 1
		self.rotate_object_local(Vector3(1,0,0), step * dir)
	
	if exiting:
		exitedTime += delta
		if exitedTime > 0.15:
			exiting = false
			exitedTime = 0.0
			if oldParent != null:
				ball.reparent(oldParent)

func _on_body_entered(body):
	if isPlatform:
		exiting = false
		exitedTime = 0.0
		var otherParent = body.get_parent()
		ball = body
		if otherParent != self:
			oldParent = otherParent
			body.reparent(self)


func _on_body_exited(body):
	if isPlatform and !exiting:
		exiting = true
		exitedTime = 0.0
