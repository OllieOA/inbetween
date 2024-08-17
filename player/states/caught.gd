extends State

const max_move: float = 5.0


func update(delta: float) -> State:
	player.global_position = player.drag_position
	if player.global_position.distance_to(player.kill_position) <= (max_move + 1.0):
		return states.kill
	return null


func enter_state() -> void:
	player.can_hide = false
	player.can_move = false
	player.can_dash = false
	player.jumps_available = 0
	player.velocity = Vector2.ZERO
	player.drag_position = player.global_position
