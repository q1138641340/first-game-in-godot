shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.45, 0.02, 1.0);
uniform float glow_radius : hint_range(1.0, 10.0) = 4.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 ps = vec2(1.0) / vec2(textureSize(TEXTURE, 0));

	// Check if surrounding area has text → this pixel gets glow
	float glow = 0.0;
	int steps = 8;
	for (int i = 0; i < steps; i++) {
		float angle = float(i) * 0.785; // PI/4
		for (int j = 1; j <= 3; j++) {
			float dist = float(j) * glow_radius / 3.0;
			vec2 off = vec2(cos(angle), sin(angle)) * dist * ps;
			float s = texture(TEXTURE, UV + off).a;
			glow += s * (1.0 / float(j)) * 0.25;
		}
	}

	glow = clamp(glow, 0.0, 1.0);

	// Text on top, glow behind
	COLOR.rgb = mix(glow_color.rgb, tex.rgb, tex.a);
	COLOR.a = max(tex.a, glow * 0.9);
}
