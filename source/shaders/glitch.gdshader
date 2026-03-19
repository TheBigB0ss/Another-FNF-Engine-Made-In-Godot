shader_type canvas_item;

/* Glitch Effect Shader by Yui Kinomoto @arlez80 MIT License */

uniform float shake_power = 0.03;
uniform float shake_rate : hint_range(0.0, 1.0) = 0.2;
uniform float shake_speed = 5.0;
uniform float shake_block_size = 30.5;
uniform float shake_color_rate : hint_range(0.0, 1.0) = 0.01;

uniform bool use_screen_texture = false;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

float random(float seed) {
	return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
	vec2 uv = use_screen_texture ? SCREEN_UV : UV;
	float enable_shift = float(random(trunc(TIME * shake_speed)) < shake_rate);

	vec2 fixed_uv = uv;
	fixed_uv.x += (random((trunc(uv.y * shake_block_size) / shake_block_size) + TIME) - 0.5)
		* shake_power * enable_shift;

	vec4 pixel_color;
	if (use_screen_texture) {
		pixel_color = texture(SCREEN_TEXTURE, fixed_uv);
		pixel_color.r = mix(
			pixel_color.r,
			texture(SCREEN_TEXTURE, fixed_uv + vec2(shake_color_rate, 0.0)).r,
			enable_shift
		);
		pixel_color.b = mix(
			pixel_color.b,
			texture(SCREEN_TEXTURE, fixed_uv + vec2(-shake_color_rate, 0.0)).b,
			enable_shift
		);
	} else {
		pixel_color = texture(TEXTURE, fixed_uv);
		pixel_color.r = mix(
			pixel_color.r,
			texture(TEXTURE, fixed_uv + vec2(shake_color_rate, 0.0)).r,
			enable_shift
		);
		pixel_color.b = mix(
			pixel_color.b,
			texture(TEXTURE, fixed_uv + vec2(-shake_color_rate, 0.0)).b,
			enable_shift
		);
	}

	COLOR = pixel_color;
}

