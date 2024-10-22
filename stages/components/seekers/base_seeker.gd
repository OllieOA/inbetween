class_name BaseSeeker extends Node2D

@onready var seeker_view_polygon: Polygon2D = $SeekerViewPolygon
@onready var polygon_viewer_notifier: VisibleOnScreenNotifier2D = $PolygonViewerNotifier
@onready var rays: Node2D = $Rays
@onready var ray_spawn_line: Line2D = $RaySpawnLine
@onready var state_label: Label = $StateLabel
@onready var seeker_states: Node = $SeekerStates

@onready var particles: Node2D = $Particles


var global_polygon_points: PackedVector2Array = []
var end_beam_points: Array[Vector2] = []
var ray_refs: Array[RayCast2D] = []
var kill_line_refs: Array[Line2D]

enum CollisionLayers {
	DEFAULT = 1,
	WALLS = 2,
	PLATFORMS = 3,
	PLAYER = 4,
}

var seeker_active: bool = true
var global_points: PackedVector2Array = []
var rotation_rate = 0.2

var min_num_rays: int = 10
var max_angle: float = 0.0
var view_distance: float = 1000.0

var drag_speed: float = 1000.0
var drag_point: Vector2

var curr_state: State = null
var prev_state: State = null

@export var cycle_time: float = -1.0


func _ready() -> void:
	for state in seeker_states.get_children():
		state.states = seeker_states
		state.seeker = self
		state.player = PlayerLocationCache.player_ref
	curr_state = seeker_states.patrol
	
	SeekerTextureBuilder.add_seeker(self)
	seeker_view_polygon.color = Color(255, 255, 255, 0)
	build_rays()
	ray_spawn_line.hide()
	
	for particle_emitter in particles.get_children():
		particle_emitter.parent_ref = self
		particle_emitter.start_emitting()


func build_rays() -> void:
	var total_line_len: float = 0.0
	for idx in range(len(ray_spawn_line.points) - 1):
		total_line_len += ray_spawn_line.get_point_position(idx).distance_to(ray_spawn_line.get_point_position(idx + 1))
	var target_segment_length: float = total_line_len / min_num_rays
	
	var curr_segment_length = total_line_len
	while curr_segment_length > target_segment_length:
		var new_line_points: PackedVector2Array = []
		var new_mid_point: Vector2 = Vector2.ZERO
		for idx in range(len(ray_spawn_line.points) - 1):
			new_line_points.append(ray_spawn_line.points[idx])
			new_mid_point = lerp(ray_spawn_line.points[idx], ray_spawn_line.points[idx + 1], 0.5)
			new_line_points.append(new_mid_point)
		new_line_points.append(ray_spawn_line.points[-1])
		ray_spawn_line.points = new_line_points
		curr_segment_length = ray_spawn_line.points[0].distance_to(ray_spawn_line.points[1])

	for idx in len(ray_spawn_line.points):
		var new_ray: RayCast2D = RayCast2D.new()
		new_ray.position = ray_spawn_line.points[idx]
		new_ray.target_position = Vector2(1000, 0)
		new_ray.set_collision_mask_value(CollisionLayers.WALLS, true)
		new_ray.set_collision_mask_value(CollisionLayers.PLATFORMS, true)
		new_ray.set_collision_mask_value(CollisionLayers.DEFAULT, false)
		new_ray.set_collision_mask_value(CollisionLayers.PLAYER, false)
		rays.add_child(new_ray)
		ray_refs.append(new_ray)


func _physics_process(delta: float) -> void:
	update_polygon()
	change_state(curr_state.update(delta))
	state_label.text = str(curr_state.get_name())


func change_state(input_state: State) -> void:
	if input_state != null:
		prev_state = curr_state
		curr_state = input_state
		
		prev_state.exit_state()
		curr_state.enter_state()


func get_polygon_points() -> PackedVector2Array:
	global_points = []
	if not seeker_active:
		return global_points
	for point in seeker_view_polygon.polygon:
		global_points.append(to_global(point))
	return global_points


func update_polygon() -> void:
	var new_polygon_points: PackedVector2Array = []
	var new_polygon_points_global: PackedVector2Array = []
	var new_end_beam_points_global: Array[Vector2] = []
	for point in ray_spawn_line.points:
		new_polygon_points.append(point)
		new_polygon_points_global.append(to_global(point))
	var collision_point: Vector2 = Vector2.ZERO
	var collision_normal: Vector2 = Vector2.ZERO
	for idx in range(len(ray_spawn_line.points)-1, -1, -1):
		collision_point = ray_refs[idx].get_collision_point()
		collision_normal = ray_refs[idx].get_collision_normal()
		new_polygon_points_global.append(collision_point)
		new_polygon_points.append(to_local(collision_point))
		new_end_beam_points_global.append(collision_point)
	
	seeker_view_polygon.polygon = new_polygon_points
	global_polygon_points = new_polygon_points_global
	end_beam_points = new_end_beam_points_global
	
	var min_view_rect_x: float = 1e6
	var min_view_rect_y: float = 1e6
	var max_view_rect_x: float = -1e6
	var max_view_rect_y: float = -1e6
	
	for point in new_polygon_points:
		if point.x < min_view_rect_x:
			min_view_rect_x = point.x
		if point.x > max_view_rect_x:
			max_view_rect_x = point.x
			
		if point.y < min_view_rect_y:
			min_view_rect_y = point.y
		if point.y > max_view_rect_y:
			max_view_rect_y = point.y
	
	var new_view_rect: Rect2 = Rect2(
		Vector2(min_view_rect_x, min_view_rect_y), 
		Vector2(max_view_rect_x - min_view_rect_x, max_view_rect_y - min_view_rect_y)
		)
	polygon_viewer_notifier.rect = new_view_rect


func check_if_player_in_view() -> bool:
	for point in PlayerLocationCache.player_test_points:
		if Geometry2D.is_point_in_polygon(point, global_polygon_points):
			return true
	return false


func build_kill_line() -> void:
	kill_line_refs = []
	var target_point: Vector2 = to_local(PlayerLocationCache.player_ref.global_position)
	var new_line = Line2D.new()
	new_line.points = [to_local(global_position), target_point]
	new_line.width = 5
	new_line.default_color = Color.RED
	new_line.material = CanvasItemMaterial.new()
	new_line.material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	add_child(new_line)
	kill_line_refs.append(new_line)


func reel_kill_line(delta: float) -> Vector2:
	var new_drag_point: Vector2 = global_position
	# TODO: Replace with verlet chain
	for line in kill_line_refs:
		var anchor_point = line.points[0]
		var outer_point = line.points[-1]
		var curr_dist = anchor_point.distance_to(outer_point)
		if curr_dist < (delta * drag_speed):
			line.hide()
			return new_drag_point
		
		#line.points = [anchor_point, new_outer_point]
		line.points = [anchor_point, to_local(PlayerLocationCache.player_test_points[0])]
		var new_outer_point = (curr_dist - (delta * drag_speed)) * anchor_point.direction_to(outer_point)
		new_drag_point = new_outer_point
	return to_global(new_drag_point)


func get_global_line_points(line: Line2D) -> PackedVector2Array:
	var global_line_points = []
	for point in line.points:
		global_line_points.append(to_global(point))
	return global_line_points
