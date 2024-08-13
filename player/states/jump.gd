extends State

var next_to_wall: Vector2 = Vector2.ZERO

func update(delta: float) -> State:
	next_to_wall = player.get_next_to_wall()
	player.player_movement(delta)
	if player.velocity.y > 0:
		return states.fall
	if player.dash_input and player.can_dash:
		return states.dash
	if next_to_wall != Vector2.ZERO and player.movement_input == next_to_wall and player.can_grab_wall:
		return states.slide
	if player.jump_input_actuation and player.jumps_available == 1:
		return states.jump
	return null


func enter_state():
	player.jump_buffer_timer.start()
	var target_jump_velocity: int = 0
	if player.jumps_available == 2:
		_first_jump()
	elif player.jumps_available == 1:
		_double_jump()
	player.jumps_available = clamp(player.jumps_available - 1, 0, 2)


func exit_state():
	player.can_grab_wall = false
	player.wall_grab_buffer_timer.start()


func _first_jump() -> void:
	player.velocity.y = -player.jump_velocity


func _double_jump() -> void:
	player.velocity.y = -player.double_jump_velocity




