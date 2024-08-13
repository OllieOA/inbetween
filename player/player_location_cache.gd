extends Node

var player_state: State
var player_test_points: PackedVector2Array = []
var new_player_test_points: PackedVector2Array = []
var player_ref: Player

const NUM_POINTS_TO_CACHE: int = 5


func update_points_on_circle(centre_point: Vector2, radius: float) -> void:
	new_player_test_points = [centre_point]
	var angle_step: float = 2 * PI / NUM_POINTS_TO_CACHE
	var curr_angle: float = 0.0
	for idx in range(NUM_POINTS_TO_CACHE):
		new_player_test_points.append(centre_point + Vector2(radius, 0).rotated(curr_angle))
		curr_angle += angle_step

	player_test_points = new_player_test_points


func update_player_state(state: State) -> void:
	player_state = state
