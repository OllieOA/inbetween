class_name BaseDialogue extends Resource

enum Speaker {PLAYER, GUIDE}

@export var speaker: Speaker
@export_multiline var dialogue: String
