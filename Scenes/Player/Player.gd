extends CharacterBody3D

@onready var raycast = $Camera/RayCast3D
@onready var holdPosition = $Camera/HoldPosition
const SPEED = 10.0
const JUMP_VELOCITY = 4.5
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
var held_object = Object
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func _ready():
	#Captures mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouseSensibility
		$Camera.rotation.x -= event.relative.y / mouseSensibility
		$Camera.rotation.x = clamp($Camera.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
		
func _physics_process(delta):
	move_and_slide()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
# Push rigidbodies on collide	
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		if collision.get_collider() is RigidBody3D:
			collision.get_collider().apply_central_impulse(-collision.get_normal() * 0.3)
			collision.get_collider().apply_impulse(-collision.get_normal() * 0.01, collision.get_position())


	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
				
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)