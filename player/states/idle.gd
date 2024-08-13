extends State


func update(delta: float) -> State:
	player.player_movement(delta)
	if player.movement_input.x != 0:
		return states.move
	if player.jump_input_actuation:
		return states.jump
	if player.velocity.y > 0:
		return states.fall
	if player.dash_input and player.can_dash:
		return states.dash
	if player.hide_input and player.can_hide:
		return states.hide
	return null


func enter_state() -> void:
	player.jumps_available = 2
