extends Node2D

const max_num_lines: int = 4
var lines: Array[Line2D] = []
var enabled: bool = true

var line_spawn_chance: float = 0.3
var line_spawn_y_offset: float = 300
var line_spawn_x_offset: float = 96

var line_speed: float = 4000.0

var min_line_length: float = 20.0
var max_line_length: float = 30.0


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	var lines = get_children()
	for line in lines:
		line.position.y -= delta * line_speed / line.width
		if line.position.y < -line_spawn_y_offset:
			line.queue_free()


	if len(lines) < max_num_lines:
		if randf() <= line_spawn_chance:
			var new_line = Line2D.new()
			new_line.points = [Vector2.ZERO, Vector2(0.0, min_line_length + randf() * (max_line_length - min_line_length))]
			new_line.width = 1 + randf()
			add_child(new_line)
			new_line.position = Vector2(2 * (randf() - 0.5) * line_spawn_x_offset, line_spawn_y_offset)


