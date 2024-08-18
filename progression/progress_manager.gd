extends Node

signal max_room_unlock_updated
signal unlock_updated

var first_launch: bool = true
var next_hub_spawn_fall: bool = false
var last_hub_door_position: Vector2 = Vector2.ZERO

var level_entered: Dictionary = {}
var level_completed: Dictionary = {}
var world_completed: Dictionary = {}
var post_world_dialogue_completed: Dictionary = {
	0: false,
	1: false,
	2: false,
	3: false,
	4: false
}
var max_room_unlock: int = 0

var door_unlocked: Dictionary = {
	1: false,
	2: false,
	3: false,
	4: false
}

func mark_level_entered(world: int, level: int) -> void:
	if not world in level_entered:
		level_entered[world] = []
	if not level in level_entered[world]:
		level_entered[world][level] = true


func check_level_entered(world: int, level: int) -> bool:
	if not world in level_entered:
		return false
	if not level in level_entered[world]:
		return false
	return level_entered[world][level]
