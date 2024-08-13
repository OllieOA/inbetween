extends SubViewport

var seekers: Array[BaseSeeker] = []
var polys: Array[Polygon2D] = []
var curr_camera: Camera2D
var screen_texture_mask: ViewportTexture


func _ready() -> void:
	size = Vector2(640, 360)


func _process(delta: float) -> void:
	for poly in polys:
		poly.free()
	polys = []
	for seeker in seekers:
		if not seeker.polygon_viewer_notifier.is_on_screen():
			continue
		
		var adjusted_poly_points: PackedVector2Array = []
		var adjusted_point: Vector2 = Vector2.ZERO
		for point in seeker.get_polygon_points():
			adjusted_point = point - curr_camera.global_position - curr_camera.offset + (size / 2.0)
			adjusted_poly_points.append(adjusted_point)
		var new_poly = Polygon2D.new()
		add_child(new_poly)
		new_poly.polygon = adjusted_poly_points
		polys.append(new_poly)

	await RenderingServer.frame_post_draw
	screen_texture_mask = get_texture()


func add_seeker(new_seeker: BaseSeeker) -> void:
	seekers.append(new_seeker)
