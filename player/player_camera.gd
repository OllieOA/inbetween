extends CameraWithNegativeSupport

@onready var negative_shader: ColorRect = $CanvasLayer/NegativeShader


func _ready() -> void:
	SeekerTextureBuilder.curr_camera = self


func _process(delta: float) -> void:
	negative_shader.material.set_shader_parameter("screen_mask", SeekerTextureBuilder.screen_texture_mask)
