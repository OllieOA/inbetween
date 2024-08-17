@tool
class_name BasePlatform extends AnimatableBody2D

enum Type {STANDARD, SEETHROUGH, ACTIVATED, NEGATIVE}
enum CollisionLayers {
	DEFAULT = 1,
	WALLS = 2,
	PLATFORMS = 3,
	PLAYER = 4,
	SEE_THROUGH_PLATFORMS = 6
}

const PLATFORM_HEIGHT: int = 8
const PLATFORM_LINE_OFFSET: int = 2
const PLATFORM_BORDER_OUTER_COLOR: Color = Color.WHITE
const OFF_WHITE_CHANNEL_VAL: float = 0.8901960784
const PLATFORM_BORDER_INNER_COLOR: Color = Color(
	OFF_WHITE_CHANNEL_VAL, 
	OFF_WHITE_CHANNEL_VAL, 
	OFF_WHITE_CHANNEL_VAL
	)

@export_group("Construction Properties")
@export var toggle_rebuild: bool = false
@export var platform_length: int = 16
@export var platform_type: Type
@export var platform_inner_texture: Texture
@export var on_tint: Color = Color.WHITE
@export var off_tint: Color = Color.BLACK
@export var top_only: bool = false

@export_group("Movement Properties")
@export var cycle_time: float = 0.0
@export_range(0.0, 1.0) var cycle_offset: float = 0.0
@export var property_movement_specs: Array[PropertyMoverSpecifier] = []

@onready var generated_objects: Node2D = $GeneratedObjects
@onready var platform_collider: CollisionShape2D = $PlatformCollider
@onready var property_mover: PropertyMover = $PropertyMover

var texture_defined: bool = false


func _ready() -> void:
	property_mover.property_movement_specs = property_movement_specs
	property_mover.target_node = self
	property_mover.cycle_time = cycle_time
	property_mover.cycle_offset = cycle_offset
	_rebuild_platform()


func _process(delta):
	if Engine.is_editor_hint():
		if toggle_rebuild:
			_rebuild_platform()
			toggle_rebuild = false


func _build_line_border(points: PackedVector2Array, target_color: Color, top_only: bool) -> Line2D:
	var new_line: Line2D = Line2D.new()
	var new_points: PackedVector2Array = points
	if top_only:  #  Note - always start bottom left
		new_points = [points[1], points[2]]
	new_line.points = new_points
	new_line.width = 1
	new_line.default_color = target_color
	new_line.closed = not top_only
	return new_line


func _rebuild_platform() -> void:
	if platform_length % 16 != 0 or platform_length == 0:
		push_error("Platform length ", str(platform_length), " cannot be zero, and must be a multiple of 16!")
		return
	for generated_child in generated_objects.get_children():
		generated_child.queue_free()
	texture_defined = platform_inner_texture != null
	# First, construct the inner repeating pattern from platform_inner_texture
	var new_polygon: Polygon2D = Polygon2D.new()
	var poly_points: PackedVector2Array = [
		Vector2(0, PLATFORM_HEIGHT),
		Vector2(0, 0), 
		Vector2(platform_length, 0),
		Vector2(platform_length, PLATFORM_HEIGHT),
		]
	new_polygon.polygon = poly_points
	if texture_defined:
		new_polygon.texture = platform_inner_texture
		new_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	else:
		new_polygon.color = Color.BLACK
	new_polygon.position += Vector2(PLATFORM_LINE_OFFSET, PLATFORM_LINE_OFFSET)
	generated_objects.add_child(new_polygon)
	
	# Then add lines
	var offset_poly_points: PackedVector2Array = []
	for point in poly_points:
		offset_poly_points.append(point + Vector2(PLATFORM_LINE_OFFSET, PLATFORM_LINE_OFFSET))
	var point_offset_order: PackedVector2Array = [
		Vector2(-0.5, 0.5),
		Vector2(-0.5, -0.5),
		Vector2(0.5, -0.5),
		Vector2(0.5, 0.5),
	]
	var inner_line_points: PackedVector2Array = []
	var outer_line_points: PackedVector2Array = []
	
	for p_idx in range(len(offset_poly_points)):
		inner_line_points.append(offset_poly_points[p_idx] + (point_offset_order[p_idx]))
		outer_line_points.append(offset_poly_points[p_idx] + (point_offset_order[p_idx] * 3))
	
	var new_inner_line: Line2D = _build_line_border(inner_line_points, PLATFORM_BORDER_INNER_COLOR, top_only)
	var new_outer_line: Line2D = _build_line_border(outer_line_points, PLATFORM_BORDER_OUTER_COLOR, top_only)
	generated_objects.add_child(new_inner_line)
	generated_objects.add_child(new_outer_line)
	
	# Add collision
	var new_collider_shape: RectangleShape2D = RectangleShape2D.new()
	new_collider_shape.size = Vector2(
		platform_length + 2*PLATFORM_LINE_OFFSET, 
		PLATFORM_HEIGHT + 2*PLATFORM_LINE_OFFSET
		)
	platform_collider.shape = new_collider_shape
	platform_collider.position = Vector2(new_collider_shape.size.x/2, new_collider_shape.size.y/2)
	
	set_collision_layer_value(CollisionLayers.PLATFORMS, true)
	set_collision_layer_value(CollisionLayers.DEFAULT, false)
	
	set_collision_mask_value(CollisionLayers.PLAYER, true)
	set_collision_mask_value(CollisionLayers.PLATFORMS, true)
	set_collision_mask_value(CollisionLayers.WALLS, false)
	set_collision_mask_value(CollisionLayers.DEFAULT, false)
	
	# Fix ownership
	new_polygon.set_owner(self)
	new_inner_line.set_owner(self)
	new_outer_line.set_owner(self)
