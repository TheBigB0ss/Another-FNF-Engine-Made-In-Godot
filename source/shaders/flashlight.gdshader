shader_type canvas_item;

uniform vec2 light_position;
uniform float radius = 100.0;
uniform vec2 viewport_size;

void fragment() {
	vec2 pixel_position = SCREEN_UV * viewport_size;
	float dist = distance(pixel_position, light_position);
	float num = dist/radius;
	
	if (dist < radius) {
		COLOR = vec4(0.0, 0.0, 0.0, num);
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}
}