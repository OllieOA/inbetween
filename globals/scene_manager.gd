extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

var target_scene: String
var curr_scene: String
var in_hub: bool
var scene_trans_time: float = 0.3

const hub_world: String = "res://stages/levels/hub_world.tscn"
const transition_level = "res://stages/levels/transition_level.tscn"

func _ready() -> void:
	color_rect.color.a = 0


func change_scene_to(next_scene: String) -> void:
	var fade_tween = get_tree().create_tween()
	target_scene = next_scene
	fade_tween.finished.connect(_change_scene)
	fade_tween.tween_property(color_rect, "color", Color(0, 0, 0, 1), scene_trans_time)
	fade_tween.play()


func _change_scene() -> void:
	var fade_tween = get_tree().create_tween()
	get_tree().change_scene_to_file(transition_level)
	get_tree().change_scene_to_file(target_scene)
	fade_tween.tween_property(color_rect, "color", Color(0, 0, 0, 0), scene_trans_time)
	fade_tween.play()
	if target_scene == hub_world:
		in_hub = true
	else:
		in_hub = false
	curr_scene = target_scene
	
