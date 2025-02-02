extends Node3D

#TODO: reset the ball if it never stops rolling
#TODO: pull the camera closer in if it would be moved into an obstacle

#Constants - Camera control
const camMinDist = 0.6 #Minimum camera distance from the ball when zooming in
const camMaxDist = 3.0 #Maximum camera distance from the ball when zooming out
const camZoomSpeed = 0.08 #Zoom scroll rate
const camLookSensitivityX = 0.005 #Horizontal look sensitivity
const camLookSensitivityY = -0.005 #Vertical look sensitivity
const swingGainSensitivity = 0.1 #Mouse movement to power gauge adjustment sensitivity
const maxCameraElevation = -85 #Maximum allowed elevation of the camera (in degrees)
const minCameraElevation = -10 #Minimum allowed elevation of the camera (in degrees)

#Constants - Gameplay
const swingMaxPower = 40.0;
const swingCoefficient = .5 #Conversion constant from swing power (1-100) to physics force
const brightLightCoef = 0.8 #Fraction of the light radius before brightness begins to falloff
const stoppingVel = 0.0005 #Square magnitude such that if the ball's velocity is below it it's basically done rolling
const stoppingCheck = 0.1 #Time (in sec) the ball must remain stopped before they can hit it again

@export var baseLightRange: float = 2.0 #How far the light is allowed to shine passively
@export var maxLightRange: float = 8.0 #How far the light is allowed to shine at max power
@export var lightAdjustSpeed: float = 1.0 #How far the light is allowed to shine at max power
@export var killPlane: float = -5.0 #Y value that falling below will trigger a respawn

#Subnodes
var cameraRoot #Follows the ball around. rotates around global Y only to track the "forward" look direction
var cameraArm #Child of camera root. Rotates around its local X to raise/lower the camera angle
var camera #Main camera. Looks backwords along the "camera arm" vector, directly at the ball.
var powerVisual #Swing power visualizer. child of camera root so that it always points "forwards"
var readyVisual #Visualizer to indicate they player can hit the ball again.
var golfBall #The golf ball. Has physics, can roll freely.
var ballLight #Light source of the ball.
var checkpoint #Stores the last stopped position of the ball in case they go OOB.

#Vars
var isLooking = false;
var isSwinging = false;
var isRolling = false;
var stoppedTime = 0;
var swingPower = 0;
var levelComplete = false;


var targetLightRange

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cameraRoot = get_node("CameraRoot")
	cameraArm = get_node("CameraRoot/CameraArm")
	camera = get_node("CameraRoot/CameraArm/Camera3D")
	golfBall = get_node("GolfBall")
	ballLight = get_node("GolfBall/BallLight")
	powerVisual = get_node("CameraRoot/PowerVisualizer")
	readyVisual = get_node("CameraRoot/ReadyVisualizer")
	checkpoint = get_node("Checkpoint")
	
	ballLight.omni_range = baseLightRange
	ballLight.light_size = baseLightRange * brightLightCoef
	targetLightRange = baseLightRange
	
	checkpoint.set_position(golfBall.get_position())
	Global.power = 0.0
	Global.strokes = 0

func _physics_process(delta):
	if golfBall.get_linear_velocity().length_squared() < 0.1:
		golfBall.set_linear_velocity(0.99 * golfBall.get_linear_velocity())
	if golfBall.get_linear_velocity().length_squared() < 0.005:
		golfBall.set_linear_velocity(0.5 * golfBall.get_linear_velocity())
	if golfBall.get_linear_velocity().length_squared() < 0.08:
		golfBall.set_linear_velocity(0.95 * golfBall.get_linear_velocity())
	#print("vel: ", golfBall.get_linear_velocity().length_squared())
	cameraRoot.set_position(golfBall.get_position())
	if isRolling:
		if golfBall.get_linear_velocity().length_squared() < stoppingVel:
			stoppedTime += delta
		else:
			stoppedTime = 0
		
		if stoppedTime >= 0.1:
			isRolling = false
			checkpoint.set_position(golfBall.get_position())
			readyVisual.visible = true
			targetLightRange = baseLightRange
			Global.power = 0.0
	
	if golfBall.global_position.y < killPlane:
		respawn()


func _process(delta):
	powerVisual.set_scale(Vector3(1,1,swingPower/swingMaxPower))
	ballLight.omni_range = lerp(ballLight.omni_range, targetLightRange, delta * lightAdjustSpeed)
	ballLight.light_size = lerp(ballLight.light_size, targetLightRange * brightLightCoef, delta * lightAdjustSpeed)

func _input(event):
	if levelComplete:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed() and !isRolling:
				isSwinging = true
				powerVisual.visible = true
			elif event.is_released() and isSwinging:
				hitBall()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				isLooking = true
			elif event.is_released():
				isLooking = false
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoomIn()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoomOut()
	elif event is InputEventMouseMotion:
		if isLooking:
			rotateCamera(event.relative)
		elif isSwinging:
			adjustSwing(event.relative.y)
	elif event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_SPACE:
			isSwinging = false #Cancel active swing if space is pressed
			swingPower = 0
			powerVisual.visible = false
			
func rotateCamera(delta):
	cameraRoot.rotate(Vector3(0,1,0), -1 * camLookSensitivityX * delta.x)
	var targetRot = cameraArm.get_rotation_degrees().x + rad_to_deg(camLookSensitivityY * delta.y)
	if (targetRot >= maxCameraElevation and targetRot <= minCameraElevation):
		cameraArm.rotate_object_local(Vector3(1,0,0), camLookSensitivityY * delta.y)

func zoomIn():
	var targetDist = max(camera.transform.origin.z - camZoomSpeed, camMinDist)
	camera.transform.origin = Vector3(0,0,targetDist)
	
func zoomOut():
	var targetDist = min(camera.transform.origin.z + camZoomSpeed, camMaxDist)
	camera.transform.origin = Vector3(0,0,targetDist)

func adjustSwing(delta):
	swingPower = swingPower + swingGainSensitivity * delta
	swingPower = clamp(swingPower, 0.0, swingMaxPower)
	
func hitBall():
	Global.strokes += 1
	Global.power = swingPower/swingMaxPower
	var forward = -cameraRoot.global_transform.basis.z
	golfBall.apply_impulse(forward * swingPower * swingCoefficient)
	targetLightRange = lerp(baseLightRange, maxLightRange, swingPower/swingMaxPower)
	isSwinging = false
	swingPower = 0
	powerVisual.visible = false
	readyVisual.visible = false
	isRolling = true
	stoppedTime = 0

func respawn():
	Global.power = 0.0
	golfBall.set_linear_velocity(Vector3(0,0,0))
	golfBall.set_angular_velocity(Vector3(0,0,0))
	golfBall.set_position(checkpoint.get_position())
	targetLightRange = baseLightRange
	ballLight.omni_range = baseLightRange
	isRolling = false
	readyVisual.visible = true
	
func win():
	if !levelComplete:
		levelComplete = true
		Global.levelUI.show_victory_screen()
