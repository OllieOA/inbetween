shader_type canvas_item;

uniform sampler2D screen_mask;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment(){
	vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	vec3 tex_mask = textureLod(screen_mask, SCREEN_UV, 0.0).rgb;
	if (tex_mask.r == 1.0) {
		c.rgb = vec3(1.0) - c.rgb;
	}
	COLOR.rgb = c;
}