extends State


func enter_state() -> void:
	SignalBus.player_killed.emit()
	player.hide()
