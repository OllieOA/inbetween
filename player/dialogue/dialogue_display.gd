extends CanvasLayer

const GUIDE_DIALOGUE_CENTER: Vector2 = Vector2(139, 200)
const PLAYER_DIALOGUE_CENTER: Vector2 = Vector2(351, 50)
const DIALOGUE_PANEL = preload("res://player/dialogue/dialogue_panel.tscn")

var conversation: Array[BaseDialogue]
var conversation_idx: int
var curr_dialogue: DialoguePanel


func load_conversation(target_conversation: BaseConversation) -> void:
	conversation = target_conversation.conversation
	conversation_idx = -1
	play_next_dialogue()


func play_next_dialogue() -> void:
	if curr_dialogue != null:
		curr_dialogue.queue_free()
	conversation_idx += 1
	if conversation_idx == len(conversation):
		SignalBus.dialogue_complete.emit()
		return
	
	var new_dialogue = DIALOGUE_PANEL.instantiate()
	curr_dialogue = new_dialogue
	add_child(new_dialogue)
	new_dialogue.single_dialogue_complete.connect(play_next_dialogue)
	new_dialogue.set_label_text(conversation[conversation_idx].dialogue)
	var target_position: Vector2 = GUIDE_DIALOGUE_CENTER
	if conversation[conversation_idx].speaker == BaseDialogue.Speaker.PLAYER:
		target_position = PLAYER_DIALOGUE_CENTER
	new_dialogue.set_dialogue_position(target_position)
