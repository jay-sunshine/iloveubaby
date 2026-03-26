shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

uniform vec4 near_sand : source_color = vec4(0.92, 0.84, 0.70, 1.0);
uniform vec4 lagoon_tint : source_color = vec4(0.46, 0.86, 0.84, 1.0);
uniform vec4 deep_tint : source_color = vec4(0.16, 0.52, 0.70, 1.0);
uniform vec2 island_extent = vec2(520.0, 160.0);

varying vec3 world_pos_v;

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
		p = p * 2.01 + vec2(3.0, 9.0);
		amplitude *= 0.5;
	}
	return value;
}

void vertex() {
	world_pos_v = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_pos_v.xz;
	float island_shape = length(vec2(p.x / island_extent.x, p.y / island_extent.y));
	float depth_band = smoothstep(0.66, 1.82, island_shape);
	float grain = fbm(p * 0.02);
	float lagoon_band = smoothstep(0.74, 1.28, island_shape);
	vec3 sand = mix(near_sand.rgb, lagoon_tint.rgb, depth_band * 0.42);
	vec3 color = mix(sand, deep_tint.rgb, smoothstep(1.08, 2.08, island_shape));
	color = mix(color, lagoon_tint.rgb, lagoon_band * 0.18);
	color = mix(color, near_sand.rgb, grain * 0.03);
	ALBEDO = color;
	ROUGHNESS = 0.98;
	SPECULAR = 0.04;
	METALLIC = 0.0;
}
