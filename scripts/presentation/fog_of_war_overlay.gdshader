shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, blend_mix;

uniform float u_map_size_x = 960.0;
uniform float u_map_size_z = 720.0;
uniform int u_center_count = 0;
uniform vec4 u_centers[96];
uniform float u_dark_alpha : hint_range(0.0, 1.0) = 0.52;
uniform float u_soft_edge = 26.0;
uniform float u_ring_width = 20.0;
uniform float u_ring_strength : hint_range(0.0, 1.0) = 0.18;
uniform vec4 u_dark_color : source_color = vec4(0.01, 0.02, 0.03, 1.0);

varying vec3 v_world_pos;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = vec2(v_world_pos.x, v_world_pos.z);
	float revealed = 0.0;
	float ring_acc = 0.0;
	for (int i = 0; i < 96; i++) {
		if (i >= u_center_count) {
			break;
		}
		vec4 center = u_centers[i];
		float radius = center.z;
		if (radius <= 0.0) {
			continue;
		}
		vec2 center_pos = center.xy;
		float d = distance(p, center_pos);
		float inner = radius - u_soft_edge;
		float outer = radius + u_soft_edge;
		float vis = 1.0 - smoothstep(inner, outer, d);
		revealed = max(revealed, vis);
		float ring = smoothstep(radius - u_ring_width, radius - 1.0, d) * (1.0 - smoothstep(radius, radius + u_ring_width, d));
		ring_acc = max(ring_acc, ring);
	}
	float alpha = (1.0 - revealed) * u_dark_alpha;
	ALBEDO = u_dark_color.rgb;
	EMISSION = vec3(0.18, 0.24, 0.3) * (ring_acc * u_ring_strength);
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	ALPHA = clamp(alpha, 0.0, 1.0);
}
