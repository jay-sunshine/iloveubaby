shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.97, 0.97, 0.95, 0.96);
uniform vec4 edge_color : source_color = vec4(0.84, 0.84, 0.81, 1.0);
uniform float grain_scale : hint_range(40.0, 320.0) = 170.0;
uniform float grain_strength : hint_range(0.0, 0.12) = 0.03;
uniform float vignette_strength : hint_range(0.0, 0.35) = 0.14;
uniform float sheen_strength : hint_range(0.0, 0.2) = 0.06;

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	vec2 uv = UV;
	vec2 cell = floor(uv * grain_scale);
	float n = hash12(cell) * 2.0 - 1.0;
	float edge_dist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
	float edge_mask = smoothstep(0.0, 0.08, edge_dist);
	float vignette = (1.0 - edge_mask) * vignette_strength;
	float sheen = smoothstep(0.0, 1.0, 1.0 - abs(uv.y - 0.2) * 1.9) * sheen_strength;
	vec3 col = base_color.rgb;
	col += vec3(n * grain_strength + sheen - vignette);
	col = mix(edge_color.rgb, col, edge_mask);
	COLOR = vec4(clamp(col, 0.0, 1.0), base_color.a);
}
