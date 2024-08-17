extends CameraWithNegativeSupport

@onready var negative_shader: ColorRect = $CanvasLayer/NegativeShader
var target_offset: Vector2


func _ready() -> void:
	SeekerTextureBuilder.curr_camera = self


func _process(delta: float) -> void:
	negative_shader.material.set_shader_parameter("screen_mask", SeekerTextureBuilder.screen_texture_mask)
	offset = lerp(offset, target_offset, 0.2)


func set_new_offset(new_offset: Vector2) -> void:
	target_offset = new_offset
