extends SubViewport

var seekers: Array[BaseSeeker] = []
var polys: Array[Polygon2D] = []
var curr_camera: Camera2D
var screen_texture_mask: ViewportTexture
var subtract_lines: Array[Line2D] = []


func _ready() -> void:
	size = Vector2(640, 360)


func _process(delta: float) -> void:
	for poly in polys:
		poly.free()
	for line in subtract_lines:
		line.free()
	polys = []
	subtract_lines = []
	for seeker in seekers:
		if not is_instance_valid(seeker):
			continue
		if not seeker.polygon_viewer_notifier.is_on_screen():
			continue
		# Draw poly
		var adjusted_poly_points: PackedVector2Array = []
		var adjusted_point: Vector2 = Vector2.ZERO
		for point in seeker.get_polygon_points():
			adjusted_point = point - curr_camera.global_position - curr_camera.offset + (size / 2.0)
			adjusted_poly_points.append(adjusted_point)
		var new_poly = Polygon2D.new()
		new_poly.polygon = adjusted_poly_points
		polys.append(new_poly)
		
		# Subtract the tongue line
		
		for kill_line_ref in seeker.kill_line_refs:
			var adjusted_line_points: PackedVector2Array = []
			var global_subject_line_points = seeker.get_global_line_points(kill_line_ref)
			for point in global_subject_line_points:
				adjusted_point = point - curr_camera.global_position - curr_camera.offset + (size / 2.0)
				adjusted_line_points.append(adjusted_point)
			var new_line = Line2D.new()
			new_line.points = adjusted_line_points
			new_line.width = kill_line_ref.width
			new_line.default_color = Color(0, 0, 0, 1)
			subtract_lines.append(new_line)

	for poly in polys:
		add_child(poly)
	for line in subtract_lines:
		add_child(line)

	await RenderingServer.frame_post_draw
	screen_texture_mask = get_texture()


func add_seeker(new_seeker: BaseSeeker) -> void:
	seekers.append(new_seeker)
