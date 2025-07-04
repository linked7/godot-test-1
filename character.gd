extends CharacterBody3D

var speed
const SPEED_SPRINT = 4.0
const SPEED_WALK = 2.0
const JUMP_VELOCITY = 2.25
const SENSITIVITY = 0.003

const FOV_BASE = 75.0
const FOV_CHANGE = 1.5

const USE_RANGE = 2.0

var gravity = Vector3(0, -7.8, 0) # 9.8 is the default
var vb_frequency = 8.0
var vb_amp = 0.04
var vb_sin = 0.0

@export var inventory = []

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = is_multiplayer_authority()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)

func _physics_process(delta: float) -> void:
	
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("quit"):
		$"../".exit_game(name.to_int())
		get_tree().quit()
		
	# mouse relesing
	if Input.is_action_just_pressed("camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_released("camera"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if Input.is_action_just_released("inventory"):
		$"../Interface".hide()
	
	if Input.is_action_just_pressed("inventory"):
		$"../Interface".show()
		
	if Input.is_action_just_pressed("use"):
		use()
		
	if Input.is_action_just_pressed("drop") and inventory.size() > 0:
		var item = inventory[randi() % inventory.size()]
		inventory_remove_item( item )

	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#Handle Sprint
	if Input.is_action_pressed("move_sprint"):
		speed = SPEED_SPRINT
	else: 
		speed = SPEED_WALK

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed 
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	#else:
		#velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		#velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
		
	#viewbob
	vb_sin += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headbob(vb_sin)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPEED_SPRINT * 2)
	var target_fov = FOV_BASE + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()
	
func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * vb_frequency) * vb_amp
	pos.x = cos(time * vb_frequency / 2) * vb_amp
	return pos
	
# A player using an entity
func use():
	cast_ray()

func cast_ray():
	var from = camera.global_position
	var to = from + camera.global_transform.basis.z * -USE_RANGE  # negative Z is forward

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)

	var result = space_state.intersect_ray(query)

	if result:
		if result.collider.has_method("on_use"):
			result.collider.on_use( self )
			pass

func inventory_add_item(item):
	#inventory.insert(inventory.size() + 1, item)
	inventory.push_front(item)
	$"../Interface/Inventory".create_inventory_item(item)
	
	
	#if inventory.has(item):
	#	inventory[item] += 1
	#else:
	#	inventory[item] = 1
	
func inventory_remove_item_random():
	var item = inventory[1]
	inventory.pop_front()
	Items.create_item(item, global_position, Vector3(0,0,0))
	
func inventory_remove_item(item):
	if inventory.has(item):
		inventory.pop_at( inventory.find(item) ) # Remove the first instance of the item in the inventory
		Items.create_item(item, global_position, Vector3(0,0,0))
	
	#if inventory.has(item):
	#	inventory[item] -= 1
		
	#	if inventory[item] <	 1:
	#		inventory.erase(item)
	
