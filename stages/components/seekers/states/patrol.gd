extends State


func update(delta: float) -> State:
	seeker.rotation += delta * seeker.rotation_rate
	if seeker.check_if_player_in_view():
		#return null
		return states.murder
	return null
