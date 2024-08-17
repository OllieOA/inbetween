extends CPUParticles2D


var valid_point_options: Array[Vector2] = []  # Cant be Packed - need pick_random()
var new_point: Vector2 = Vector2.ZERO
var parent_ref: BaseSeeker
var reemission_check: Timer

func _ready() -> void:
	finished.connect(_update_position)
	reemission_check = Timer.new()
	reemission_check.wait_time = 0.1
	reemission_check.one_shot = true
	reemission_check.timeout.connect(_check_reemission)
	add_child(reemission_check)


func start_emitting() -> void:
	emitting = true


func _update_position() -> void:
	valid_point_options = parent_ref.end_beam_points
	if len(valid_point_options) == 0:
		print("Not enough points!")
		return
	
	new_point = valid_point_options.pick_random()
	global_position = new_point
	global_rotation = parent_ref.global_rotation - (PI / 2)
	emitting = true


func _process(delta: float) -> void:
	if not emitting and reemission_check.is_stopped():
		reemission_check.start()


func _check_reemission() -> void:
	if not emitting:
		emitting = true
