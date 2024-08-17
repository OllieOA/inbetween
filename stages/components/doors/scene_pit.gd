class_name ScenePit extends Node2D

@onready var exit_area: Area2D = $ExitArea
@export var next_scene: String


func _ready() -> void:
	exit_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	SceneManager.change_scene_to(next_scene)
