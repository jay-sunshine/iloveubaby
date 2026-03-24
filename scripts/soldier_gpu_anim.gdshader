shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

uniform vec4 u_team_color : source_color = vec4(0.9, 0.3, 0.2, 1.0);
uniform float u_state = 0.0;
uniform float u_sway_mul = 1.0;
uniform float u_move_cycle_mul = 1.0;
uniform float u_idle_cycle_mul = 1.0;
uniform float u_anim_intensity = 1.0;
uniform vec3 u_attack_dir_local = vec3(0.0, 0.0, 1.0);
uniform sampler2D u_albedo_tex : source_color;
uniform bool u_use_albedo_tex = false;
uniform float u_team_tint_strength = 0.35;

mat3 rot_x(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat3(
		vec3(1.0, 0.0, 0.0),
		vec3(0.0, c, -s),
		vec3(0.0, s, c)
	);
}

mat3 rot_z(float a) {
	float c = cos(a);
	float s = sin(a);
	return mat3(
		vec3(c, -s, 0.0),
		vec3(s, c, 0.0),
		vec3(0.0, 0.0, 1.0)
	);
}

void vertex() {
	float seed = INSTANCE_CUSTOM.r;
	float t = TIME + seed * 13.173;
	float up = 0.0;
	float pitch = 0.0;
	float roll = 0.0;
	vec3 shove = vec3(0.0);
	float anim_intensity = clamp(u_anim_intensity, 0.0, 1.0);
	float sway = clamp(u_sway_mul, 0.0, 1.2);

	if (u_state < 0.5) {
		float idle_w = clamp(u_idle_cycle_mul, 0.2, 2.0);
		up = sin(t * 1.35 * idle_w) * 0.015;
		roll = sin(t * 1.1 * idle_w) * 0.02 * sway;
	} else if (u_state < 1.5) {
		float move_mul = mix(0.55, 1.0, clamp(u_sway_mul, 0.0, 1.0));
		float w = t * 7.2 * clamp(u_move_cycle_mul, 0.2, 2.0);
		up = abs(sin(w)) * 0.085 * move_mul;
		pitch = sin(w) * 0.14 * move_mul;
		roll = sin(w * 0.45) * 0.045 * sway;
	} else if (u_state < 2.5) {
		float hit = max(0.0, sin(t * 6.0));
		up = hit * 0.08;
		pitch = -hit * 0.2;
		shove = normalize(u_attack_dir_local) * (hit * 0.06);
	} else if (u_state < 3.5) {
		float r = t * 5.3;
		up = abs(sin(r)) * 0.07;
		pitch = -0.16 + sin(r) * 0.05;
		roll = sin(r * 0.6) * 0.045 * sway;
		shove = normalize(u_attack_dir_local) * 0.05;
	} else {
		float rush = t * 9.0;
		up = abs(sin(rush)) * 0.08;
		pitch = sin(rush) * 0.12;
	}

	VERTEX = (rot_z(roll * anim_intensity) * rot_x(pitch * anim_intensity)) * VERTEX;
	VERTEX += shove * anim_intensity;
	VERTEX.y += up * anim_intensity;
}

void fragment() {
	if (u_use_albedo_tex) {
		vec3 base_col = texture(u_albedo_tex, UV).rgb;
		vec3 tint_mul = mix(vec3(1.0), u_team_color.rgb, clamp(u_team_tint_strength, 0.0, 1.0));
		ALBEDO = base_col * tint_mul;
	} else {
		ALBEDO = u_team_color.rgb;
	}
	ROUGHNESS = 0.88;
	METALLIC = 0.02;
}
