extends CanvasLayer
@onready var texture_rect: TextureRect = $TextureRect

func _process(delta: float) -> void:
	texture_rect.texture = SeekerTextureBuilder.screen_texture_mask
