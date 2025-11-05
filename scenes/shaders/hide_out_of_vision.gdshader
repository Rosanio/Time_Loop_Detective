shader_type canvas_item;

uniform sampler2D vision_mask;
uniform float fade_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float mask_val = texture(vision_mask, SCREEN_UV).r;
	color.rgb *= mix(0.0, 1.0, mask_val);
	color.a *= mix(0.0, 1.0, mask_val);
	COLOR = color;
}
