extends State

func update(delta: float) -> State:
	player.curr_hide_time += delta
	if player.curr_hide_time > player.max_hide_time:
		player.penalise_hide()
		return states.idle
	player.player_movement(delta)
	if not player.can_hide or not player.hide_input:
		return states.idle
	if player.jump_input_actuation:
		return states.jump
	if player.velocity.y > 0 and not player.hide_input:
		return states.fall
	if player.dash_input and player.can_dash:
		return states.dash
	return null


func enter_state() -> void:
	player.hide_emitter.emitting = true
	player.can_move = false
	player.velocity.x = 0


func exit_state() -> void:
	player.hide_emitter.emitting = false
	player.check_if_can_move()
