shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back, unshaded;

uniform float curvature_radius = 42003.0;
uniform vec4 dry_sand : source_color = vec4(0.95, 0.89, 0.72, 1.0);
uniform vec4 warm_sand : source_color = vec4(0.91, 0.83, 0.63, 1.0);
uniform vec4 wet_sand : source_color = vec4(0.82, 0.75, 0.56, 1.0);
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
		p = p * 2.0 + vec2(4.0, 7.0);
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
	float angle = atan(p.y, p.x);
	float radial_wobble = 1.0 + sin(angle * 3.0) * 0.06 + sin(angle * 5.0 + 0.8) * 0.04;
	float n = fbm(p * 0.009 + vec2(7.0, 3.0));
	float shape = length(vec2(p.x / ((island_extent.x + n * 28.0) * radial_wobble), p.y / ((island_extent.y + n * 22.0) * radial_wobble)));
	float mask = 1.0 - smoothstep(0.90, 1.03, shape);
	if (mask <= 0.01) {
		discard;
	}
	float shoreline = 1.0 - smoothstep(0.18, 0.34, mask);
	float grain = fbm(p * 0.05 + vec2(9.0, 13.0));
	vec3 color = mix(dry_sand.rgb, warm_sand.rgb, grain * 0.45);
	color = mix(color, wet_sand.rgb, shoreline * 0.55);
	ALBEDO = color;
	EMISSION = color * 0.08;
	ALPHA = 1.0;
}
