extends State

var dash_direction = Vector2.ZERO
var dash_speed: float = 1000.0
var dashing: bool = false

@export var dash_duration: float = 0.15
@onready var dash_timer: Timer = $DashTimer

const FADING_SPRITE = preload("res://player/fading_sprite.tscn")

func _ready() -> void:
	dash_timer.timeout.connect(_on_dash_timer_timeout)


func update(delta: float) -> State:
	if not dashing:
		if player.is_on_floor():
			return states.idle
		else:
			return states.fall
	
	# Drop a fading sprite
	var new_fading_sprite = FADING_SPRITE.instantiate()
	player.add_child(new_fading_sprite)
	new_fading_sprite.hframes = player.player_sprite.hframes
	new_fading_sprite.frame = player.player_sprite.frame
	new_fading_sprite.flip_h = player.player_sprite.flip_h
	new_fading_sprite.top_level = true
	new_fading_sprite.global_position = player.global_position
	new_fading_sprite.march_direction = dash_direction
	
	return null


func enter_state() -> void:
	player.can_dash = false
	dashing = true
	dash_timer.start(dash_duration)
	if player.movement_input != Vector2.ZERO:
		dash_direction = player.movement_input
	else:
		dash_direction = player.last_direction
	player.velocity = dash_direction.normalized() * dash_speed


func exit_state() -> void:
	dashing = false
	player.dash_cooldown_timer.start()


func _on_dash_timer_timeout():
	dashing = false
