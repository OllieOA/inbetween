extends State


func update(delta: float) -> State:
	player.player_movement(delta)
	if abs(player.velocity.x) <= 10 and player.movement_input == Vector2.ZERO:
		return states.idle
	if player.can_hide and player.hide_input:
		return states.hide
	if player.velocity.y > 0:
		return states.fall
	if player.jump_input_actuation:
		return states.jump
	if player.dash_input and player.can_dash:
		return states.dash
	return null


func enter_state() -> void:
	player.jumps_available = 2
