shader_type canvas_item;

uniform int effect_type : hint_enum("DREAMY:0", "WAVY:1", "HEAT WAVE HORIZONTAL:2", "HEAT WAVE VERTICAL:3", "FLAG:4") = 0;
uniform float u_speed = 1.0;
uniform float u_frequency = 10.0;
uniform float u_amplitude = 0.01;

uniform bool pixel_snap = true;

uniform vec2 u_texel_size = vec2(0.001, 0.001);

uniform float pixel_step = 1.0;

vec2 snap_uv(vec2 uv) {
	if (!pixel_snap) {
		return uv;
	}
	
	vec2 step_size = max(u_texel_size * pixel_step, vec2(0.000001));
	return floor(uv / step_size + 0.5) * step_size;
}

vec2 sine_wave(vec2 uv) {
	float t = TIME * u_speed;
	
	float x = 0.0;
	float y = 0.0;
	
	if (effect_type == 0) {
		x = sin(uv.y * u_frequency + t) * u_amplitude;
	}
	else if (effect_type == 1) {
		y = sin(uv.x * u_frequency + t) * u_amplitude;
	}
	else if (effect_type == 2) {
		x = sin(uv.x * u_frequency + t) * u_amplitude;
	}
	else if (effect_type == 3) {
		y = sin(uv.y * u_frequency + t) * u_amplitude;
	}
	else if (effect_type == 4) {
		x = sin(uv.y * u_frequency + t) * u_amplitude;
		y = sin(uv.x * u_frequency + t) * u_amplitude;
	}
	
	return vec2(x, y);
}

void fragment() {
	vec2 uv = UV;
	vec2 displacement = sine_wave(uv);
	
	if (pixel_snap) {
		vec2 step_size = max(
			u_texel_size * pixel_step,
			vec2(0.000001)
		);
		displacement = round(displacement / step_size) * step_size;
	}
	
	uv += displacement;
	
	COLOR = texture(TEXTURE, uv);
}