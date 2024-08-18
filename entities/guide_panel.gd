class_name GuidePanel extends PanelContainer

signal write_complete

@onready var hint_text: Label = $MarginContainer/HBoxContainer/HintText

var hint_complete: bool = false
var char_per_sec: float = 50.0
var chars_to_show: float = 0.0


func _process(delta: float) -> void:
	if hint_text.visible_ratio == 1 and not hint_complete:
		hint_complete = true
		write_complete.emit()
	
	if not hint_complete:
		chars_to_show += delta * char_per_sec
		hint_text.visible_characters = chars_to_show


func set_text(new_text: String) -> void:
	hint_text.text = new_text
	hint_text.visible_ratio = false
	chars_to_show = 0
	hint_complete = false
