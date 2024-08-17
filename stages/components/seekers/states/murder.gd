extends State

var kill_complete: bool = false

func _ready() -> void:
	SignalBus.player_killed.connect(_on_player_killed)


func update(delta: float) -> State:
	if kill_complete:
		return states.patrol
	player.drag_position = seeker.reel_kill_line(delta)
	return null


func enter_state() -> void:
	player.kill_position = seeker.global_position
	seeker.build_kill_line()
	SignalBus.player_caught.emit()


func exit_state() -> void:
	for line in seeker.kill_line_refs:
		line.queue_free()
	seeker.kill_line_refs = []


func _on_player_killed() -> void:
	kill_complete = true
