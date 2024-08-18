class_name ScenePit extends Node2D

@onready var exit_area: Area2D = $ExitArea
@export var next_scene: String

var world_ref: int
var level_ref: int


func _ready() -> void:
	exit_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	SignalBus.level_completed.emit(world_ref, level_ref)
	SignalBus.world_completed.emit(world_ref)
	SceneManager.change_scene_to(next_scene)
