shader_type canvas_item;

uniform int effect_type : hint_enum("DREAMY:0", "WAVY:1", "HEAT WAVE HORIZONTAL:2", "HEAT WAVE VERTICAL:3", "FLAG:4") = 0;
uniform float u_speed = 1.0;
uniform float u_frequency = 10.0;
uniform float u_amplitude = 0.01;

vec2 sine_wave(vec2 uv) {
	float x = 0.0;
	float y = 0.0;

	if (effect_type == 0) {
		float offsetX = sin(uv.y * u_frequency + TIME * u_speed) * u_amplitude;
		uv.x += offsetX;
	}
	else if (effect_type == 1) {
		float offsetY = sin(uv.x * u_frequency + TIME * u_speed) * u_amplitude;
		uv.y += offsetY;
	}
	else if (effect_type == 2) {
		x = sin(uv.x * u_frequency + TIME * u_speed) * u_amplitude;
	}
	else if (effect_type == 3) {
		y = sin(uv.y * u_frequency + TIME * u_speed) * u_amplitude;
	}
	else if (effect_type == 4) {
		y = sin(uv.y * u_frequency + 10.0 * uv.x + TIME * u_speed) * u_amplitude;
		x = sin(uv.x * u_frequency + 5.0 * uv.y + TIME * u_speed) * u_amplitude;
	}

	return uv + vec2(x, y);
}

void fragment() {
	vec2 uv = UV;
	uv = sine_wave(uv);
	COLOR = texture(TEXTURE, uv);
}