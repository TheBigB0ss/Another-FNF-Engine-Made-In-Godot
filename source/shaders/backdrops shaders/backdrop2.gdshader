shader_type canvas_item;

uniform float tile_size = 100.0;
uniform vec2 scroll_speed = vec2(0.5, 0.5);

void fragment() {
	vec2 screen_uv = FRAGCOORD.xy / tile_size;
	screen_uv += TIME * scroll_speed;
	vec2 uv = fract(screen_uv);
	COLOR = texture(TEXTURE, uv);
}