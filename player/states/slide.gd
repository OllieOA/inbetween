extends State

@export var climb_speed: float = 50.0
@export var slide_friction: float = 0.8

var wall_direction: Vector2 = Vector2.ZERO

func update(delta: float) -> State:
	slide_movement(delta)
	wall_direction = player.get_next_to_wall()
	if wall_direction == Vector2.ZERO:
		return states.fall
	if player.jump_input_actuation:
		return states.jump
	if player.is_on_floor():
		return states.idle
	if player.hide_input and player.can_hide:
		return states.hide
	return null


func slide_movement(delta: float) -> void:
	player.player_movement(delta)
	player.velocity.y *= slide_friction


func enter_state() -> void:
	player.jumps_available = 2
