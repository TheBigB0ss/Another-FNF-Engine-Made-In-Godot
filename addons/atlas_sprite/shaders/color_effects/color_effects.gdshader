shader_type canvas_item;

uniform int color_mode = 0;
uniform vec4 tint_color : source_color = vec4(1.0);
uniform float alpha_multiplier : hint_range(0.0, 1.0) = 1.0;

uniform vec4 channel_multiplier = vec4(1.0);
uniform vec4 channel_offset = vec4(0.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 result = tex * COLOR;

	if (color_mode == 1) {
		result.a *= alpha_multiplier;
	} else if (color_mode == 2) {
		result.rgb = result.rgb * channel_multiplier.rgb + channel_offset.rgb;
		result.a = result.a * channel_multiplier.a + channel_offset.a;
	} else if (color_mode == 3) {
		result.rgb = mix(result.rgb, tint_color.rgb, tint_color.a);
	}

	COLOR = result;
}
