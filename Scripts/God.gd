extends KinematicBody
var speed = 10 
var acceleration = 20
var gravity = 0
var jump = 5
var mouse_on = false
var mouse_sensitivity = 0.5

var direction = Vector3()
var velocity = Vector3()
var fall= Vector3()
onready var head = $Head
func _ready():
	mouse_on=true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event):
	if event is InputEventMouseMotion and not mouse_on:
		rotate_y(deg2rad(-event.relative.x*mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y*mouse_sensitivity))
		#head.rotation.x = clamp(head.rotation.x,deg2rad(180),deg2rad(360))

func _process(delta):
	direction = Vector3()
	
	if(Input.is_action_just_pressed("jump")):
		fall.y=jump
	if(Input.is_action_just_pressed("ui_cancel")):
		if not mouse_on:
			mouse_on=true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			mouse_on=false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if(Input.is_action_pressed("move_forward")):
		direction-=transform.basis.z
	elif(Input.is_action_pressed("move_backward")):
		direction+=transform.basis.z
	
	if(Input.is_action_pressed("move_left")):
		direction-=transform.basis.x
	elif(Input.is_action_pressed("move_right")):
		direction+=transform.basis.x
		
	if(Input.is_action_pressed("move_up")):
		direction+=transform.basis.y
	elif(Input.is_action_pressed("move_down")):
		direction-=transform.basis.y
		
	direction = direction.normalized()
	
	move_and_slide(direction*speed,Vector3.UP)

		
