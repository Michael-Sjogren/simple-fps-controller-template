extends KinematicBody
# mouse
export(float, 0 , .01) var mouse_sensitivty = 0.003
# physics
export(float, 0 , 20) var gravity_scale = 1.0
export(float, 0 , 200) var jump_speed = 4
# movement
export(float, 0 , 10000) var move_speed = 5
# A higher floatiness value means slower acceleration and deceleration
export(float, 0 , 1) var floatiness = .85

var _velocity = Vector3.ZERO
var _move_input:Vector3

onready var head:Spatial = $Head
onready var cam:Camera = $Head/Camera

func _ready():
	_toggle_cursor()

func _physics_process(delta):
	_move(delta)

func _unhandled_input(event):
	_move_input = Vector3(
		Input.get_axis("move_left" , "move_right"),
		0,
		Input.get_axis("move_forward" , "move_backward")
	).normalized()
	
	if event.is_action_pressed("ui_cancel"):
		var mode = Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE \
		else Input.MOUSE_MODE_VISIBLE
		Input.set_mouse_mode(mode)
	
	if event is InputEventMouseMotion:
		_head_look(-event.relative)

func _toggle_cursor():
	var mode = Input.MOUSE_MODE_CAPTURED if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE \
	else Input.MOUSE_MODE_VISIBLE
	Input.set_mouse_mode(mode)

func _move(delta:float):
	var goal_vel:Vector3 = cam.global_transform.basis * _move_input * move_speed
	var new_vel:Vector3 = _velocity.linear_interpolate(goal_vel , 1-floatiness)
	new_vel.y = _velocity.y
	new_vel.y += -9.8 * gravity_scale * delta
	_velocity = new_vel
	if Input.is_action_just_pressed("jump") and is_on_floor():
		_jump()
	_velocity = move_and_slide(_velocity , Vector3.UP)

func _jump():
	_velocity.y = jump_speed

func _head_look(motion:Vector2):
	head.rotate_y(motion.x * mouse_sensitivty)
	cam.rotation.x =  clamp( cam.rotation.x + motion.y * mouse_sensitivty , -PI/2 , PI/2 )
