extends Node2D

@onready var player: Player = $Player
@onready var start_button: TextureButton = $StartButton/StartButton
@onready var title: TextureRect = $StartButton/Title

@onready var doors: Node2D = $Doors

func _ready() -> void:
	SceneManager.in_hub = true
	start_button.pressed.connect(_on_start_pressed)
	if ProgressManager.first_launch:
		ProgressManager.first_launch = false
		player.jumps_available = 0
		player.can_gravity = false
		player.can_move = false
		player.can_dash = false
		player.can_hide = false
		player.block_hide_input = true
		player.block_jump_input = true
		player.animation_player.play("fall")
		player.set_camera_override(Vector2(-150, 0))
	else:
		title.hide()
		start_button.hide()
	ProgressManager.unlock_updated.connect(_on_progress_updated)
	figure_out_doors()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_dialogue") and start_button.pressed.is_connected(_on_start_pressed):
		_on_start_pressed()


func figure_out_doors() -> void:
	for door in doors.get_children():
		if door.door_num > 0 and door.door_num <= 4:
			if ProgressManager.door_unlocked[door.door_num]:
				door.unlock_door()


func _on_start_pressed() -> void:
	player.can_gravity = true
	player.can_move = true
	player.can_dash = true
	player.block_hide_input = false
	player.block_jump_input = false
	var fade_tween = create_tween()
	fade_tween.tween_property(start_button, "modulate", Color(1, 1, 1, 0), 0.5)
	player.remove_camera_override()
	fade_tween.tween_property(title, "modulate", Color(1, 1, 1, 0), 1.0)
	player.velocity.y = 0.1
	start_button.pressed.disconnect(_on_start_pressed)


func _on_progress_updated() -> void:
	figure_out_doors()
