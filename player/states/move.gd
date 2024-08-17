extends State

var animating_move_dir: Vector2


func update(delta: float) -> State:
	player.player_movement(delta)
	if player.velocity.x < 0 and animating_move_dir == Vector2.RIGHT:
		player.animation_player.play("move_left")
		animating_move_dir = Vector2.LEFT
	if player.velocity.x > 0 and animating_move_dir == Vector2.LEFT:
		player.animation_player.play("move_right")
		animating_move_dir = Vector2.RIGHT
	
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
	if player.movement_input.x > 0:
		player.animation_player.play("move_right")
		animating_move_dir = Vector2.RIGHT
	else:
		player.animation_player.play("move_left")
		animating_move_dir = Vector2.LEFT
	


func exit_state() -> void:
	player.animation_player.stop()
