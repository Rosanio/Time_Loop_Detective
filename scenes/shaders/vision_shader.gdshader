shader_type canvas_item;

uniform sampler2D vision_mask : source_color;
uniform float darkness : hint_range(0.0,1.0) = 0.0;

void fragment() {
	vec4 mask = texture(vision_mask, UV);
	float visible = mask.r;

	float alpha = darkness * (1.0 - visible);
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
