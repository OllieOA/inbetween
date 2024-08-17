class_name SceneDoor extends Node2D

const ICON_1: int = 0 
const ICON_2: int = 1 
const ICON_3: int = 2 
const ICON_4: int = 3
const ICON_LOCK: int = 4
const ICON_NEXT: int = 5

var door_num_lookup: Dictionary = {
	1: ICON_1,
	2: ICON_2,
	3: ICON_3,
	4: ICON_4
}

@export var door_num: int = 0
@export var exit_door: bool
@export var next_scene: String
@export var overhead_text: String

var can_be_activated: bool = false
var door_active: bool = true
 
@onready var door_sprite: Sprite2D = $DoorSprite
@onready var icon_sprite: Sprite2D = $IconSprite
@onready var stats_label: Label = $StatsLabel
@onready var activation_area: Area2D = $ActivationArea


func _ready() -> void:
	icon_sprite.frame = ICON_LOCK
	activation_area.body_entered.connect(_on_body_entered)
	activation_area.body_exited.connect(_on_body_exited)
	stats_label.hide()
	if overhead_text != "":
		stats_label.text = overhead_text
	if exit_door:
		icon_sprite.frame = ICON_NEXT
		can_be_activated = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("activate_door") and can_be_activated:
		print("TRYING TO CHANGE TO ", next_scene)
		SceneManager.change_scene_to(next_scene)


func set_icon(num: int) -> void:
	icon_sprite.frame = num


func unlock_door() -> void:
	icon_sprite.frame = door_num_lookup[door_num]
	can_be_activated = true


func _on_body_entered(body: Node2D) -> void:
	if can_be_activated:
		stats_label.show()


func _on_body_exited(body: Node2D) -> void:
	stats_label.hide()
	
