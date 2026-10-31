shader_type canvas_item;
render_mode unshaded;

uniform int color_mode = 0;

uniform float alpha_multiplier = 1.0;

uniform vec4 tint_color : source_color = vec4(1.0);
uniform float tint_amount = 1.0;

uniform vec4 channel_multiplier = vec4(1.0);
uniform vec4 channel_offset = vec4(0.0);

uniform vec4 color_multiplier = vec4(1.0);
uniform vec4 color_offset = vec4(0.0);

uniform int blend_mode = 10;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec3 blend_darken(vec3 s, vec3 b){
	return min(s, b);
}

vec3 blend_lighten(vec3 s, vec3 b){
	return max(s, b);
}

vec3 blend_difference(vec3 s, vec3 b){
	return abs(s - b);
}

vec3 blend_overlay(vec3 s, vec3 b){
	return mix(2.0 * s * b, 1.0 - 2.0 * (1.0 - s) * (1.0 - b), step(0.5, b));
}

vec3 blend_hard_light(vec3 s, vec3 b){
	return mix(2.0 * s * b, 1.0 - 2.0 * (1.0 - s) * (1.0 - b), step(0.5, s));
}

vec3 blend_soft_light(vec3 s, vec3 b){
	return mix(2.0 * s * b + s * s * (1.0 - 2.0 * b), sqrt(s) * (2.0 * b - 1.0) + 2.0 * s * (1.0 - b), step(vec3(0.5), b));
}

vec3 blend_color_dodge(vec3 s, vec3 b){
	return s / (1.0 - b);
}

vec3 blend_linear_dodge(vec3 s, vec3 b){
	return s + b;
}

vec3 blend_burn(vec3 s, vec3 b){
	return 1.0 - (1.0 - s) / b;
}

vec3 blend_linear_burn(vec3 s, vec3 b){
	return s + b - 1.0;
}

vec3 blend_screen(vec3 s, vec3 b){
	return 1.0 - (1.0 - s) * (1.0 - b);
}

vec3 blend_exclusion(vec3 s, vec3 b){
	return s + b - 2.0 * s * b;
}

vec3 blend_invert(vec3 s, vec3 b){
	return 1.0 - b;
}

vec3 blend_add(vec3 s, vec3 b) {
	return min(s + b, vec3(1.0));
}

vec3 blend_subtract(vec3 s, vec3 b) {
	return max(b - s, vec3(0.0));
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV) * COLOR;
	
	if (color_mode == 2) {
		tex.rgb = mix(
			tex.rgb,
			tint_color.rgb,
			clamp(tint_amount, 0.0, 1.0)
		);
	}
	
	tex = tex * color_multiplier + color_offset;
	tex = clamp(tex, vec4(0.0), vec4(1.0));
	
	if (tex.a <= 0.0) {
		discard;
	}
	
	vec3 background = texture(screen_texture, SCREEN_UV).rgb;
	vec3 result = tex.rgb;
	
	switch (blend_mode) {
		case 0:
			result = blend_add(tex.rgb, background);
			break;
		case 1:
			result = tex.rgb;
			break;
		case 2:
			result = blend_darken(tex.rgb, background);
			break;
		case 3:
			result = blend_difference(tex.rgb, background);
			break;
		case 4:
			result = background;
			break;
		case 5:
			result = blend_hard_light(tex.rgb, background);
			break;
		case 6:
			result = 1.0 - background;
			break;
		case 7:
			result = tex.rgb;
			break;
		case 8:
			result = blend_lighten(tex.rgb, background);
			break;
		case 9:
			result = tex.rgb * background;
			break;
		case 10:
			result = tex.rgb;
			break;
		case 11:
			result = blend_overlay(tex.rgb, background);
			break;
		case 12:
			result = blend_screen(tex.rgb, background);
			break;
		case 13:
			result = tex.rgb;
			break;
		case 14:
			result = blend_subtract(tex.rgb, background);
			break;
	}
	
	COLOR = vec4(result, tex.a);
}