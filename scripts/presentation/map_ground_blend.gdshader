shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

uniform float u_map_size_x = 960.0;
uniform float u_map_size_z = 720.0;
uniform vec4 u_color_grass : source_color = vec4(0.33, 0.57, 0.31, 0.95);
uniform vec4 u_color_road : source_color = vec4(0.63, 0.56, 0.38, 0.98);
uniform vec4 u_color_forest : source_color = vec4(0.16, 0.39, 0.19, 0.98);
uniform vec4 u_color_swamp : source_color = vec4(0.28, 0.36, 0.24, 0.98);
uniform vec4 u_color_sand : source_color = vec4(0.69, 0.62, 0.42, 0.98);
uniform vec4 u_color_water : source_color = vec4(0.18, 0.43, 0.67, 0.82);
uniform vec4 u_color_mountain : source_color = vec4(0.45, 0.43, 0.41, 0.98);

varying vec3 v_world_pos;

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash12(i);
	float b = hash12(i + vec2(1.0, 0.0));
	float c = hash12(i + vec2(0.0, 1.0));
	float d = hash12(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float soft_ellipse(vec2 p, vec2 center, vec2 radius, float feather) {
	vec2 safe_radius = max(radius, vec2(0.001));
	vec2 n = (p - center) / safe_radius;
	float level = 1.0 - dot(n, n);
	return smoothstep(-feather, feather, level);
}

float road_band(float axis_dist, float half_width, float feather) {
	float d = abs(axis_dist) - half_width;
	return 1.0 - smoothstep(-feather, feather, d);
}

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = vec2(v_world_pos.x, v_world_pos.z);

	float road_h = road_band(p.y + 24.0, 18.0, 5.0) * (1.0 - smoothstep(u_map_size_x * 0.46, u_map_size_x * 0.5, abs(p.x)));
	float road_v = road_band(p.x - 72.0, 16.0, 5.0) * (1.0 - smoothstep(u_map_size_z * 0.45, u_map_size_z * 0.49, abs(p.y)));
	float road = clamp(road_h + road_v, 0.0, 1.0);

	float mountain = soft_ellipse(p, vec2(-250.0, -120.0), vec2(180.0, 130.0), 0.1);
	float water = soft_ellipse(p, vec2(120.0, 90.0), vec2(170.0, 105.0), 0.12);
	float swamp = soft_ellipse(p, vec2(150.0, 80.0), vec2(230.0, 145.0), 0.13);
	float sand = soft_ellipse(p, vec2(290.0, -190.0), vec2(170.0, 120.0), 0.12);
	float forest = soft_ellipse(p, vec2(-40.0, 220.0), vec2(250.0, 150.0), 0.12);

	water *= (1.0 - mountain);
	swamp *= (1.0 - mountain) * (1.0 - water);
	sand *= (1.0 - mountain) * (1.0 - water) * (1.0 - swamp);
	forest *= (1.0 - mountain) * (1.0 - water);
	road *= (1.0 - mountain) * (1.0 - water * 0.9);

	float occupied = clamp(mountain + water + swamp + sand + forest + road, 0.0, 1.0);
	float grass = 1.0 - occupied;

	float total = grass + road + forest + swamp + sand + water + mountain;
	total = max(total, 0.001);
	grass /= total;
	road /= total;
	forest /= total;
	swamp /= total;
	sand /= total;
	water /= total;
	mountain /= total;

	vec3 col = vec3(0.0);
	col += u_color_grass.rgb * grass;
	col += u_color_road.rgb * road;
	col += u_color_forest.rgb * forest;
	col += u_color_swamp.rgb * swamp;
	col += u_color_sand.rgb * sand;
	col += u_color_water.rgb * water;
	col += u_color_mountain.rgb * mountain;

	vec2 pn = p / max(vec2(u_map_size_x, u_map_size_z), vec2(1.0));
	float n1 = value_noise(pn * 18.0);
	float n2 = value_noise(pn * 42.0);
	float grass_variation = ((n1 * 0.68 + n2 * 0.32) - 0.5) * 0.045;
	col = clamp(col + vec3(grass_variation), vec3(0.0), vec3(1.0));

	ALBEDO = col;
	ROUGHNESS = mix(0.92, 0.2, clamp(water * 1.25, 0.0, 1.0));
	METALLIC = mix(0.02, 0.06, clamp(water, 0.0, 1.0));
}
