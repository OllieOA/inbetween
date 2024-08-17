extends State

@onready var coyote_timer: Timer = $CoyoteTimer
@export var coyote_duration: float = 0.1

var can_jump: bool = true
var can_jump_states: Array[State] = []
var no_first_jump_states: Array[State] = []

var next_to_wall: Vector2 = Vector2.ZERO


func _ready() -> void:
	call_deferred("populate_valid_jump_states")
	coyote_timer.timeout.connect(_on_coyote_timer_timeout)


func populate_valid_jump_states():
	can_jump_states = [states.idle, states.move, states.slide]
	no_first_jump_states = [states.idle, states.move, states.dash]


func update(delta: float) -> State:
	next_to_wall = player.get_next_to_wall()
	player.player_movement(delta)
	if player.is_on_floor():
		if player.movement_input.x != 0:
			return states.move
		else:
			return states.idle
	if player.dash_input:
		return states.dash
	if next_to_wall != Vector2.ZERO and next_to_wall == player.movement_input:
		return states.slide
	if player.jump_input_actuation and (can_jump or player.jumps_available > 0):
		return states.jump
	if player.hide_input and player.can_hide:
		return states.hide
	return null


func enter_state():
	can_jump = false
	if can_jump_states.has(player.prev_state):
		can_jump = true
		coyote_timer.start(coyote_duration)
	if no_first_jump_states.has(player.prev_state):
		player.jumps_available -= 1
	player.animation_player.play("fall")


func exit_state():
	player.play_land_particles()
	player.animation_player.stop()


func _on_coyote_timer_timeout():
	can_jump = false
