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

enum Dialogues {
	INTRO, 
	INTRO_SUMMARY, 
	POST_WORLD_1, 
	POST_WORLD_1_SUMMARY, 
	POST_WORLD_2, 
	POST_WORLD_2_SUMMARY, 
	POST_WORLD_3, 
	POST_WORLD_3_SUMMARY, 
	POST_WORLD_4,
	POST_WORLD_4_SUMMARY
	} 
	

@onready var dialogue_ref: Dictionary = {
	Dialogues.INTRO: load("res://player/dialogue/conversations/intro.tres"),
	Dialogues.INTRO_SUMMARY: load("res://player/dialogue/conversations/post_intro.tres"),
	Dialogues.POST_WORLD_1: load("res://player/dialogue/conversations/post_world_1.tres"),
	Dialogues.POST_WORLD_1_SUMMARY: load("res://player/dialogue/conversations/post_world_1_summary.tres"),
	Dialogues.POST_WORLD_2: load("res://player/dialogue/conversations/post_world_2.tres"),
	Dialogues.POST_WORLD_2_SUMMARY: load("res://player/dialogue/conversations/post_world_2_summary.tres"),
	Dialogues.POST_WORLD_3: load("res://player/dialogue/conversations/post_world_3.tres"),
	Dialogues.POST_WORLD_3_SUMMARY: load("res://player/dialogue/conversations/post_world_3_summary.tres"),
	Dialogues.POST_WORLD_4: load("res://player/dialogue/conversations/post_world_4.tres"),
	Dialogues.POST_WORLD_4_SUMMARY: load("res://player/dialogue/conversations/post_world_4_summary.tres")
}

@onready var part_1_dialogues: Array = [
	dialogue_ref[Dialogues.INTRO], 
	dialogue_ref[Dialogues.POST_WORLD_1], 
	dialogue_ref[Dialogues.POST_WORLD_2], 
	dialogue_ref[Dialogues.POST_WORLD_3], 
	dialogue_ref[Dialogues.POST_WORLD_4]
]

@onready var part_2_dialogue_lookup: Dictionary = {
	dialogue_ref[Dialogues.INTRO]: dialogue_ref[Dialogues.INTRO_SUMMARY],
	dialogue_ref[Dialogues.POST_WORLD_1]: dialogue_ref[Dialogues.POST_WORLD_1_SUMMARY],
	dialogue_ref[Dialogues.POST_WORLD_2]: dialogue_ref[Dialogues.POST_WORLD_2_SUMMARY],
	dialogue_ref[Dialogues.POST_WORLD_3]: dialogue_ref[Dialogues.POST_WORLD_3_SUMMARY],
	dialogue_ref[Dialogues.POST_WORLD_4]: dialogue_ref[Dialogues.POST_WORLD_4_SUMMARY]
}

var curr_loaded_dialogue: BaseConversation


func _ready() -> void:
	sit_position = global_position
	hover_position = global_position + Vector2(69, -26)
	target_position = sit_position
	SignalBus.dialogue_triggered.connect(activate)
	SignalBus.dialogue_complete.connect(_on_dialogue_complete)
	PlayerLocationCache.guide_ref = self
	set_correct_dialogue()


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


func set_correct_dialogue() -> void:
	if ProgressManager.post_world_dialogue_completed[ProgressManager.max_room_unlock]:
		curr_loaded_dialogue = part_2_dialogue_lookup[part_1_dialogues[ProgressManager.max_room_unlock]]
	else:
		curr_loaded_dialogue = part_1_dialogues[ProgressManager.max_room_unlock]


func activate() -> void:
	jiggle_enabled = true
	anchor_position = hover_position


func deactivate() -> void:
	jiggle_enabled = false
	anchor_position = sit_position
	target_position = sit_position


func _on_dialogue_complete() -> void:
	deactivate()
	if part_1_dialogues.has(curr_loaded_dialogue):
		ProgressManager.post_world_dialogue_completed[part_1_dialogues.find(curr_loaded_dialogue)] = true
		curr_loaded_dialogue = part_2_dialogue_lookup[curr_loaded_dialogue]
		if ProgressManager.max_room_unlock == 0:
			ProgressManager.max_room_unlock += 1
		ProgressManager.door_unlocked[ProgressManager.max_room_unlock] = true
		ProgressManager.unlock_updated.emit()
