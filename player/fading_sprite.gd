extends Sprite2D

var curr_alpha: float = 1.0
var per_decay_rate: float = 15.0  # per second
var march_direction: Vector2 = Vector2.ZERO
var march_speed: float = 100.0

func _process(delta: float) -> void:
	global_position += march_direction.normalized() * delta * march_speed
	curr_alpha = clamp(curr_alpha - (delta * per_decay_rate), 0.0, 1.0)
	modulate.a = curr_alpha
	modulate.r = curr_alpha
	modulate.g = curr_alpha
	if curr_alpha == 0:
		queue_free()
