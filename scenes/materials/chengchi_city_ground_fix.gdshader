shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D original_albedo : source_color;
uniform sampler2D original_normal : hint_normal;
uniform sampler2D ground_albedo : source_color, repeat_enable;
uniform vec3 ground_tint : source_color = vec3(0.82, 0.96, 0.78);
uniform float ground_uv_scale = 7.5;
uniform float ground_max_y = 0.048;
uniform float ground_fade = 0.012;
uniform float ground_min_up_dot = 0.72;
uniform float ground_up_fade = 0.08;
uniform float base_roughness = 1.0;
uniform float base_specular = 0.08;

varying vec3 local_pos;
varying vec3 local_normal;

void vertex() {
	local_pos = VERTEX;
	local_normal = NORMAL;
}

void fragment() {
	vec3 sampled_normal = normalize(local_normal);
	float up_mask = smoothstep(ground_min_up_dot - ground_up_fade, ground_min_up_dot + 0.02, sampled_normal.y);
	float height_mask = 1.0 - smoothstep(ground_max_y - ground_fade, ground_max_y + ground_fade, local_pos.y);
	float ground_mask = clamp(up_mask * height_mask, 0.0, 1.0);

	vec3 base_albedo = texture(original_albedo, UV).rgb;
	vec3 ground_color = texture(ground_albedo, local_pos.xz * ground_uv_scale).rgb * ground_tint;
	ALBEDO = mix(base_albedo, ground_color, ground_mask);

	vec3 base_normal = texture(original_normal, UV).rgb;
	NORMAL_MAP = mix(base_normal, vec3(0.5, 0.5, 1.0), ground_mask);
	NORMAL_MAP_DEPTH = mix(1.0, 0.0, ground_mask);

	ROUGHNESS = base_roughness;
	METALLIC = 0.0;
	SPECULAR = base_specular;
}
