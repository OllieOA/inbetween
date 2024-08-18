class_name Guide extends Node2D

@onready var guide_sprite: Sprite2D = $GuideSprite

var activated: bool = false
var sit_position: Vector2
var hover_position: Vector2

var anchor_position: Vector2
var target_position: Vector2
var new_target_offset: Vector2
var jiggle_enabled: bool = false
var max_jiggle_size: float = 10

enum Dialogues {INTRO, POST_INTRO, POST_WORLD_1, POST_WORLD_2, POST_WORLD_3, POST_WORLD_4}

var dialogue_ref: Dictionary = {
	Dialogues.INTRO: load("res://player/dialogue/conversations/intro.tres")
}

var curr_loaded_dialogue: BaseConversation


func _ready() -> void:
	sit_position = global_position
	hover_position = global_position + Vector2(69, -26)
	target_position = sit_position
	SignalBus.dialogue_triggered.connect(activate)
	SignalBus.dialogue_complete.connect(deactivate)
	PlayerLocationCache.guide_ref = self
	curr_loaded_dialogue = dialogue_ref[Dialogues.INTRO]


func _process(delta: float) -> void:
	if global_position.distance_to(sit_position) < 5:
		guide_sprite.frame = 1
	else:
		guide_sprite.frame = 0
	
	if jiggle_enabled:
		if global_position.distance_to(target_position) < 1:
			new_target_offset = Vector2(randf() * max_jiggle_size, 0).rotated(randf() * 2 * PI)
			target_position = anchor_position + new_target_offset
	global_position = lerp(global_position, target_position, 0.05)


func activate() -> void:
	jiggle_enabled = true
	anchor_position = hover_position
	PlayerLocationCache.player_ref


func deactivate() -> void:
	jiggle_enabled = false
	anchor_position = sit_position
	target_position = sit_position
