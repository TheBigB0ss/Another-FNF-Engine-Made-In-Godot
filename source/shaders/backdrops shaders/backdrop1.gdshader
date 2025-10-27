shader_type canvas_item;

uniform vec2 scroll_speed = vec2(50.0, 0.0);
uniform float time : hint_range(0, 1000);

void fragment() {
	vec2 uv = UV;
	uv += scroll_speed * TIME / vec2(textureSize(TEXTURE, 0));
	uv = fract(uv);
	COLOR = texture(TEXTURE, uv);
}
