extends State

var kill_complete: bool = false

func _ready() -> void:
	SignalBus.player_killed.connect(_on_player_killed)


func update(delta: float) -> State:
	if kill_complete:
		return states.patrol
	return null


func enter_state() -> void:
	player.kill_position = seeker.global_position
	seeker.build_kill_line()


func _on_player_killed() -> void:
	kill_complete = true
