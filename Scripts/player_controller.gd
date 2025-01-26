extends Node3D

#TODO: prevent hitting the ball while it's still rolling
#TODO: reset the ball if it falls out of the map or doesn't stop rolling
#TODO: prevent flipping the camera upside down
#TODO: pull the camera closer in if it would be moved into an obstacle

#Constants
const camMinDist = 1.0 #Minimum camera distance from the ball when zooming in
const camMaxDist = 6.0 #Maximum camera distance from the ball when zooming out
const camZoomSpeed = 0.08 #Zoom scroll rate

const camLookSensitivityX = 0.005 #Horizontal look sensitivity
const camLookSensitivityY = 0.005 #Vertical look sensitivity
const swingGainSensitivity = 0.1 #Mouse movement to power gauge adjustment sensitivity
const swingCoefficient = 0.75 #Conversion constant from swing power (1-100) to physics force

#Subnodes
var cameraRoot #Follows the ball around. rotates around global Y only to track the "forward" look direction
var cameraArm #Child of camera root. Rotates around its local X to raise/lower the camera angle
var camera #Main camera. Looks backwords along the "camera arm" vector, directly at the ball.
var powerVisual #Swing power visualizer. child of camera root so that it always points "forwards"
var golfBall #The golf ball. Has physics, can roll freely.

#Vars
var isLooking = false;
var isSwinging = false;
var swingPower = 0;
const swingMaxPower = 100;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cameraRoot = get_node("CameraRoot")
	cameraArm = get_node("CameraRoot/CameraArm")
	camera = get_node("CameraRoot/CameraArm/Camera3D")
	golfBall = get_node("GolfBall")
	powerVisual = get_node("CameraRoot/PowerVisualizer")

func _physics_process(delta):
	cameraRoot.set_position(golfBall.get_position())
	
func _process(delta):
	powerVisual.set_scale(Vector3(1,1,swingPower/100.0))

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
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
	cameraArm.rotate_object_local(Vector3(1,0,0), camLookSensitivityY * delta.y)
	#TODO: prevent rotating past true up/down which can be disorienting

func zoomIn():
	var targetDist = max(camera.transform.origin.z - camZoomSpeed, camMinDist)
	camera.transform.origin = Vector3(0,0,targetDist)
	
func zoomOut():
	var targetDist = min(camera.transform.origin.z + camZoomSpeed, camMaxDist)
	camera.transform.origin = Vector3(0,0,targetDist)

func adjustSwing(delta):
	swingPower = swingPower + swingGainSensitivity * delta
	swingPower = clamp(swingPower, 0, swingMaxPower)
	
func hitBall():
	var forward = -cameraRoot.global_transform.basis.z
	golfBall.apply_impulse(forward * swingPower * swingCoefficient)
	isSwinging = false
	swingPower = 0;
	powerVisual.visible = false
