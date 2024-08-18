class_name DialoguePanel extends PanelContainer

signal single_dialogue_complete

@onready var dialogue: Label = $MarginContainer/HBoxContainer/Dialogue
@onready var next_icon: TextureRect = $MarginContainer/HBoxContainer/NextIcon

var char_per_sec: float = 30.0
var chars_to_show: float = 0.0
var num_char: int = 0
var dialogue_complete: bool = false
var prompt_timer: Timer


func _ready() -> void:
	next_icon.modulate.a = 0
	dialogue.visible_ratio = 0


func set_label_text(text: String) -> void:
	dialogue.text = text


func set_dialogue_position(target_position: Vector2) -> void:
	position = target_position


func _process(delta: float) -> void:
	if dialogue.visible_ratio == 1 and not dialogue_complete:
		dialogue_complete = true
		start_prompt()
	
	if not dialogue_complete:
		chars_to_show += delta * char_per_sec
		dialogue.visible_characters = chars_to_show
	
	if Input.is_action_just_pressed("skip_dialogue"):
		if not dialogue_complete:
			dialogue.visible_ratio = 1
		else:
			single_dialogue_complete.emit()


func start_prompt() -> void:
	prompt_timer = Timer.new()
	prompt_timer.timeout.connect(_flip_prompt)
	prompt_timer.wait_time = 0.5
	add_child(prompt_timer)
	prompt_timer.start()


func _flip_prompt() -> void:
	next_icon.modulate.a = abs(1 - next_icon.modulate.a)
