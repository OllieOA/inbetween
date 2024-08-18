extends State

var dialogue_complete: bool = false

func _ready() -> void:
	SignalBus.dialogue_complete.connect(_on_dialogue_complete)


func update(delta: float) -> State:
	player.velocity.x = 0.0
	player.player_movement(delta)
	if player.is_on_floor():
		player.can_move = false
	if dialogue_complete:
		return states.idle
	return null


func enter_state() -> void:
	dialogue_complete = false
	var zoom_tween: Tween = get_tree().create_tween()
	zoom_tween.tween_property(player.player_camera, "zoom", Vector2(2, 2), 0.5)
	zoom_tween.play()
	player.set_camera_override((PlayerLocationCache.guide_ref.hover_position - player.global_position) / 2)
	player.can_hide = false
	player.can_dash = false
	player.jumps_available = 0
	player.block_hide_input = true
	player.block_jump_input = true
	player.velocity = Vector2.ZERO


func exit_state() -> void:
	var zoom_tween: Tween = get_tree().create_tween()
	zoom_tween.tween_property(player.player_camera, "zoom", Vector2(1, 1), 0.5)
	zoom_tween.play()
	player.remove_camera_override()
	player.can_hide = true
	player.can_move = true
	player.can_dash = true
	player.block_hide_input = false
	player.block_jump_input = false
	player.jumps_available = 2


func _on_dialogue_complete() -> void:
	dialogue_complete = true
