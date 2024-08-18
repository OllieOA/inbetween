class_name BaseLevel extends Node2D

const GUIDE_PANEL = preload("res://entities/guide_panel.tscn")
var guide_panel: GuidePanel
@onready var guide_panel_canvas: CanvasLayer = $GuidePanelCanvas
@onready var respawn_canvas: CanvasLayer = $RespawnCanvas

@export var tips: Array[String]
@export var start_with_tips: bool = true
@export var world_num: int
@export var level_num: int


func _ready() -> void:
	SceneManager.curr_scene = scene_file_path
	SignalBus.player_killed.connect(_on_player_killed)
	if start_with_tips:
		start_tips()


func start_tips():
	for child in guide_panel_canvas.get_children():
		child.queue_free()
	guide_panel = GUIDE_PANEL.instantiate()
	guide_panel_canvas.add_child(guide_panel)
	guide_panel.modulate = Color(1, 1, 1, 0)
	guide_panel.position += Vector2(16, -16)
	var fade_in_tween: Tween = get_tree().create_tween()
	fade_in_tween.tween_property(guide_panel, "modulate", Color(1, 1, 1, 1), 0.3)
	await fade_in_tween.finished

	var panel_buffer_timer: Timer = Timer.new()
	panel_buffer_timer.wait_time = 3.0
	panel_buffer_timer.one_shot = true
	panel_buffer_timer.autostart = false
	guide_panel.add_child(panel_buffer_timer)
	guide_panel.show()
	for tip in tips:
		guide_panel.set_text(tip)
		await guide_panel.hint_complete
		panel_buffer_timer.start()
		await panel_buffer_timer.timeout
	var fade_out_tween: Tween = get_tree().create_tween()
	fade_out_tween.tween_property(guide_panel, "modulate", Color(1, 1, 1, 0), 0.3)
	fade_out_tween.play()
	await fade_out_tween.finished
	guide_panel.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hint"):
		start_tips()


func _on_player_killed() -> void:
	var respawn_guide_panel = GUIDE_PANEL.instantiate()
	respawn_guide_panel.modulate = Color(1, 1, 1, 0)
	respawn_guide_panel.position += Vector2(314, -16)
	respawn_canvas.add_child(respawn_guide_panel)
	var fade_in_tween: Tween = get_tree().create_tween()
	fade_in_tween.tween_property(respawn_guide_panel, "modulate", Color(1, 1, 1, 1), 0.3)
	fade_in_tween.play()
	await fade_in_tween.finished
	
	respawn_guide_panel.set_text("No matter - press R to retry this section!")
	
