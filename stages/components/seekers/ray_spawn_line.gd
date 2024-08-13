extends Line2D

@export_range(0, 360) var direction_degrees: float = 0.0
@export var max_distance: float = 1000.0
@export var min_num_rays: int = 20


func _ready() -> void:
	hide()
