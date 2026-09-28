shader_type canvas_item;
render_mode unshaded;

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
	vec4 tex = texture(TEXTURE, UV);
	
	if (tex.a <= 0.0) {
		discard;
	}
	
	vec3 background = texture(screen_texture, SCREEN_UV).rgb;
	vec3 result = tex.rgb;
	
	switch (blend_mode) {
		case 0: // ADD
			result = blend_add(tex.rgb, background);
			break;
		case 1: // ALPHA
			result = tex.rgb;
			break;
		case 2: // DARKEN
			result = blend_darken(tex.rgb, background);
			break;
		case 3: // DIFFERENCE
			result = blend_difference(tex.rgb, background);
			break;
		case 4: // ERASE
			result = background;
			break;
		case 5: // HARD LIGHT
			result = blend_hard_light(tex.rgb, background);
			break;
		case 6: // INVERT
			result = 1.0 - background;
			break;
		case 7: // LAYER
			result = tex.rgb;
			break;
		case 8: // LIGHTEN
			result = blend_lighten(tex.rgb, background);
			break;
		case 9: // MULTIPLY
			result = tex.rgb * background;
			break;
		case 10: // NORMAL
			result = tex.rgb;
			break;
		case 11: // OVERLAY
			result = blend_overlay(tex.rgb, background);
			break;
		case 12: // SCREEN
			result = blend_screen(tex.rgb, background);
			break;
		case 13: // SHADER
			result = tex.rgb;
			break;
		case 14: // SUBTRACT
			result = blend_subtract(tex.rgb, background);
			break;
	}
	COLOR = vec4(result, tex.a);
}