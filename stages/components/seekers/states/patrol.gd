extends State

var curr_player_state_name: String = ""
var ignore_player_states: Array[String] = ["hide", "kill", "caught", "dash"]


func update(delta: float) -> State:
	curr_player_state_name = player.get_state_name()
	if seeker.check_if_player_in_view():
		if not ignore_player_states.has(curr_player_state_name):
			return states.murder
	return null
