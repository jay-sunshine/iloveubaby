shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, unshaded;

uniform float curvature_radius = 42003.0;
uniform vec4 deep_color : source_color = vec4(0.08, 0.54, 0.80, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.24, 0.88, 0.96, 1.0);
uniform vec4 lagoon_color : source_color = vec4(0.54, 1.0, 0.98, 1.0);
uniform vec2 island_extent = vec2(470.0, 250.0);

varying vec2 flat_pos_v;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 4; i++) {
		value += noise(p) * amplitude;
		p = p * 2.0 + vec2(4.2, 7.8);
		amplitude *= 0.5;
	}
	return value;
}

void vertex() {
	flat_pos_v = VERTEX.xz;
	float dist2 = min(dot(flat_pos_v, flat_pos_v), curvature_radius * curvature_radius * 0.999999);
	float sphere_y = sqrt(max(curvature_radius * curvature_radius - dist2, 0.0)) - curvature_radius;
	VERTEX.y = sphere_y;
}

void fragment() {
	vec2 p = flat_pos_v;
	float island_shape = length(vec2(p.x / island_extent.x, p.y / island_extent.y));
	float shore = 1.0 - smoothstep(0.86, 1.46, island_shape);
	float lagoon_bias = 1.0 - smoothstep(0.62, 1.06, island_shape);
	float ripple = fbm(p * 0.006) * 0.6 + fbm(p * 0.02 + vec2(11.0, 5.0)) * 0.4;
	vec3 base = mix(deep_color.rgb, shallow_color.rgb, clamp(shore * 0.74 + ripple * 0.08, 0.0, 1.0));
	base = mix(base, lagoon_color.rgb, lagoon_bias * 0.44);
	vec3 view_dir = normalize(VIEW);
	float fresnel = pow(1.0 - abs(view_dir.y), 2.6);
	vec3 color = base + vec3(0.06, 0.10, 0.10) * fresnel;
	ALBEDO = color;
	EMISSION = color * 0.10;
	ALPHA = clamp(mix(0.92, 0.78, shore) + fresnel * 0.04, 0.76, 0.96);
}
