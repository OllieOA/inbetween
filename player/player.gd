class_name Player extends CharacterBody2D

@onready var states: Node = $States
@onready var state_label: Label = $StateLabel

@onready var casts: Node2D = $Casts
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var player_camera: Camera2D = $PlayerCamera

@onready var player_light: PointLight2D = $PlayerLight
@onready var hide_emitter: CPUParticles2D = $HideEmitter
@onready var hide_progress: TextureProgressBar = $HideProgress
@onready var dash_progress: TextureProgressBar = $DashProgress
@onready var dialogue_display: CanvasLayer = $PlayerCamera/DialogueDisplay
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var land_emitter_l: CPUParticles2D = $LandEmitterL
@onready var land_emitter_r: CPUParticles2D = $LandEmitterR


# states
var curr_state: State = null
var prev_state: State = null

# inputs
var movement_input: Vector2 = Vector2.ZERO
var jump_input: bool = false
var jump_input_actuation: bool = false
var hide_input: bool = false
var block_hide_input: bool = false
var block_jump_input: bool = false
var dash_input: bool = false 
var dash_input_actuation: bool = false

#region mechanics
# JUMP
const MAX_JUMPS: int = 2
var jumps_available: int = 2
var jump_buffer: float = 0.1
var jump_buffer_timer: Timer
var jump_velocity: float = 0.0
var double_jump_velocity: float = 0.0

# DASH
var can_dash: bool = true
var dash_buffer_timer: Timer
var dash_buffer: float = 0.2
var dash_cooldown_timer: Timer
var dash_cooldown: float = 1.0
var curr_dash_direction: Vector2 = Vector2.ZERO

# HIDE
var can_hide: bool = true
var curr_hide_time: float = 0.0
var max_hide_time: float = 2.0  # seconds
var max_hide_penalty: float = 3.0
var hide_penalty_active: bool = false

# SLIDE
var cast_refs: Array[RayCast2D] = []
var wall_direction: Vector2 = Vector2.ZERO
var can_grab_wall: bool = true
var wall_grab_buffer_timer: Timer
var wall_grab_buffer: float = 0.5

# CAUGHT AND DEATH
var kill_position: Vector2 = Vector2.ZERO
var drag_position: Vector2 = Vector2.ZERO
var is_caught: bool = false

# DIALOGUE
var is_in_dialogue: bool = false
signal dialogue_completed
var can_gravity: bool = true
var camera_override_active: bool = false
var camera_height: float = 40.0
var camera_position_target: Vector2 = Vector2.ZERO
var mouse_bias: Vector2 = Vector2.ZERO
var max_mouse_bias: float = 300.0
var enable_mouse_bias: bool = false
#endregion

# movement
var camera_offset: float = 5.0
var acceleration: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.RIGHT
var friction: float = 40.0
var max_acceleration: float = 9000.0
var can_move: bool = true
var is_next_to_wall: bool = false

# gravity
var gravity: float = 0.0
var default_gravity: float = 0.0
var max_jump_height: int = 80
var min_jump_height: int = 40
var double_jump_height: int = 40
var jump_duration: float = 0.3
var falling_gravity_multiplier: float = 1.2
var release_gravity_multiplier: float = 0.0

var marked_for_crash: bool = false

# animation
const IDLE_INDEX: int = 0
const MOVE_INDEX: int = 1
const JUMP_INDEX: int = 2
const FALL_INDEX: int = 3
const SLIDE_INDEX: int = 4
const HIDE_INDEX: int = 5


func _init() -> void:
	default_gravity = get_base_gravity()
	jump_velocity = get_first_jump_velocity()
	double_jump_velocity = get_double_jump_velocity()
	release_gravity_multiplier = get_release_gravity_multiplier()


func _ready() -> void:
	for state in states.get_children():
		state.states = states
		state.player = self
	curr_state = states.fall
	for cast in casts.get_children():
		cast_refs.append(cast)
	
	jump_buffer_timer = Timer.new()
	add_child(jump_buffer_timer)
	jump_buffer_timer.wait_time = jump_buffer
	jump_buffer_timer.one_shot = true
	
	dash_buffer_timer = Timer.new()
	add_child(dash_buffer_timer)
	dash_buffer_timer.wait_time = dash_buffer
	dash_buffer_timer.one_shot = true
	
	dash_cooldown_timer = Timer.new()
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.wait_time = dash_cooldown
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooltime_timeout)
	
	wall_grab_buffer_timer = Timer.new()
	add_child(wall_grab_buffer_timer)
	wall_grab_buffer_timer.wait_time = wall_grab_buffer
	wall_grab_buffer_timer.one_shot = true
	wall_grab_buffer_timer.timeout.connect(_on_wall_grab_timeout)
	
	hide_progress.max_value = max_hide_time
	dash_progress.max_value = dash_cooldown
	
	PlayerLocationCache.player_ref = self
	SignalBus.player_caught.connect(_on_player_caught)
	SignalBus.dialogue_triggered.connect(_on_dialogue_triggered)
	SignalBus.dialogue_complete.connect(_on_conversation_complete)


func _process(delta: float) -> void:
	if not camera_override_active:
		mouse_bias = Vector2.ZERO
		var mouse_dist = get_global_mouse_position().distance_to(global_position)
		var mouse_dir = get_global_mouse_position().direction_to(global_position)
		if enable_mouse_bias:
			mouse_bias = Vector2(clamp(mouse_dist, 0, max_mouse_bias), 0).rotated(mouse_dir.angle())
		camera_position_target = camera_offset * last_direction - Vector2(0, camera_height) - mouse_bias
		player_camera.set_new_offset(camera_position_target)
	hide_progress.value = curr_hide_time
	dash_progress.value = dash_cooldown_timer.time_left
	
	if velocity.x > 0 and curr_state != states.idle:
		player_sprite.flip_h = false
	elif velocity.x < 0 and curr_state != states.idle:
		player_sprite.flip_h = true
	
	if curr_state == states.slide:
		if wall_direction == Vector2.RIGHT and player_sprite.flip_h:
			player_sprite.flip_h = false
		elif wall_direction == Vector2.LEFT and not player_sprite.flip_h:
			player_sprite.flip_h = true
	
	match curr_state:
		states.idle:
			player_sprite.frame = IDLE_INDEX
		states.move, states.dash:
			player_sprite.frame = MOVE_INDEX
		states.jump:
			player_sprite.frame = JUMP_INDEX
		states.fall:
			player_sprite.frame = FALL_INDEX
		states.slide:
			player_sprite.frame = SLIDE_INDEX
		states.hide:
			player_sprite.frame = HIDE_INDEX


func _physics_process(delta: float) -> void:
	if can_hide and curr_state != states.hide:
		curr_hide_time = clamp(curr_hide_time - delta, 0, max_hide_time)
	else:
		curr_hide_time = clamp(curr_hide_time - (delta / max_hide_penalty), 0, max_hide_time)
		if curr_hide_time == 0.0:
			can_hide = true
	if marked_for_crash:
		crash_next_frame()
	player_input()
	is_next_to_wall = get_next_to_wall() != Vector2.ZERO
	change_state(curr_state.update(delta))
	state_label.text = str(curr_state.get_name())
	move_and_slide()
	PlayerLocationCache.update_points_on_circle(global_position, 5)


func player_input():
	# Reset inputs
	movement_input = Vector2.ZERO
	jump_input = false
	jump_input_actuation = false
	dash_input = false
	dash_input_actuation = false
	hide_input = false
	enable_mouse_bias = false
	
	movement_input.x += Input.get_axis("move_left", "move_right")
	
	# Jumps
	if Input.is_action_pressed("jump") and not block_jump_input:
		jump_input = true
	if Input.is_action_just_pressed("jump") and not block_jump_input:
		jump_input_actuation = true

	# Dash
	if Input.is_action_just_pressed("move_left") and can_dash:
		check_dash(Vector2.LEFT)
	if Input.is_action_just_pressed("move_right") and can_dash:
		check_dash(Vector2.RIGHT)
	
	# Hide
	if Input.is_action_pressed("hide") and not block_hide_input:
		hide_input = true

	# Reset
	if Input.is_action_just_pressed("restart") and not SceneManager.in_hub:
		SceneManager.change_scene_to(SceneManager.curr_scene)
	
	# Inspect
	if Input.is_action_pressed("inspect") and not SceneManager.in_hub:
		enable_mouse_bias = true


func player_movement(delta: float):
	if not can_move:
		return
	acceleration = Vector2.ZERO
	# Horizontal
	if movement_input.x > 0 and can_move:
		acceleration.x = max_acceleration
		last_direction = Vector2.RIGHT
	elif movement_input.x < 0 and can_move:
		acceleration.x = -max_acceleration
		last_direction = Vector2.LEFT
	
	velocity.x *= 1.0 / (1.0 + (delta * friction))
	
	# Vertical
	gravity = modify_gravity(default_gravity)
	if not is_on_floor() and can_gravity:
		acceleration.y = gravity
	
	# Summarise
	velocity += acceleration * delta


func change_state(input_state: State) -> void:
	if input_state != null:
		prev_state = curr_state
		curr_state = input_state
		
		prev_state.exit_state()
		curr_state.enter_state()
		PlayerLocationCache.update_player_state(curr_state)


func get_state(state_name: String) -> State:
	return states.all_states.get(state_name, null)


func get_state_name() -> String:
	return curr_state.get_name().to_lower()


func get_next_to_wall() -> Vector2:
	for cast in cast_refs:
		cast.force_raycast_update()
		if cast.is_colliding():
			if cast.target_position.x > 0:
				return Vector2.RIGHT
			else:
				return Vector2.LEFT
	return Vector2.ZERO


func check_dash(test_dash_direction: Vector2) -> void:
	if not dash_buffer_timer.is_stopped() and test_dash_direction == curr_dash_direction and can_dash:
		dash_buffer_timer.stop()
		change_state(states.dash)
	else:
		dash_buffer_timer.start()
		curr_dash_direction = test_dash_direction


func penalise_hide() -> void:
	can_hide = false
	hide_progress.modulate = Color.RED


func hide_penalty_complete() -> void:
	can_hide = true
	hide_progress.modulate = Color.WHITE


func check_if_can_move() -> void:
	can_move = true
	if curr_state == states.hide:
		can_move = false


func get_base_gravity() -> float:
	return (2 * max_jump_height) / pow(jump_duration, 2)


func get_first_jump_velocity() -> float:
	return (2 * max_jump_height) / jump_duration


func get_double_jump_velocity() -> float:
	return sqrt(abs(2 * default_gravity * max_jump_height))


func get_release_gravity_multiplier() -> float:
	var release_gravity = pow(jump_velocity, 2.0) / (2.0 / min_jump_height)
	return release_gravity / default_gravity


func modify_gravity(curr_gravity: float) -> float:
	if curr_state == states.fall:
		curr_gravity *= falling_gravity_multiplier
	elif velocity.y < 0.0:
		if not jump_input:
			curr_gravity *= release_gravity_multiplier / 2000.0
	
	return curr_gravity


func start_dialogue() -> void:
	dialogue_display.load_conversation(PlayerLocationCache.guide_ref.curr_loaded_dialogue)


func play_land_particles() -> void:
	land_emitter_l.emitting = true
	land_emitter_r.emitting = true


func set_camera_override(new_offset: Vector2) -> void:
	player_camera.set_new_offset(new_offset)
	camera_override_active = true


func remove_camera_override() -> void:
	camera_override_active = false


func _on_dash_cooltime_timeout() -> void:
	can_dash = true


func _on_wall_grab_timeout() -> void:
	can_grab_wall = true


func _on_player_caught() -> void:
	change_state(states.caught)


func _on_dialogue_triggered() -> void:
	change_state(states.dialogue)
	start_dialogue()


func _on_conversation_complete() -> void:
	change_state(states.idle)


func crash_next_frame():
	OS.crash("intentionally killed")
