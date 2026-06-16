shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;
uniform float speed = 10.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	float blink = (sin(TIME * speed) + 1.0) / 2.0;
	float final_strength = flash_strength * blink;
	
	vec3 final_color = mix(tex.rgb, flash_color.rgb, final_strength);
	
	COLOR = vec4(final_color, tex.a);
}