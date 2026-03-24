shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D albedo_tex : source_color;
uniform float alpha_cutoff : hint_range(0.0, 1.0, 0.01) = 0.45;

uniform float roughness_value : hint_range(0.0, 1.0, 0.01) = 0.88;
uniform float ao_strength : hint_range(0.0, 1.0, 0.01) = 0.72;

uniform float toon_steps : hint_range(2.0, 6.0, 1.0) = 3.0;
uniform float light_wrap : hint_range(0.0, 0.5, 0.01) = 0.12;

uniform float rim_strength : hint_range(0.0, 1.0, 0.01) = 0.14;
uniform float rim_power : hint_range(1.0, 8.0, 0.1) = 3.4;

void fragment() {
	vec4 tex = texture(albedo_tex, UV);
	if (tex.a < alpha_cutoff) {
		discard;
	}

	ALBEDO = tex.rgb;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_cutoff;
	METALLIC = 0.0;
	SPECULAR = 0.0;
	ROUGHNESS = roughness_value;
	AO = ao_strength;

	float rim = pow(1.0 - max(dot(normalize(NORMAL), normalize(VIEW)), 0.0), rim_power);
	EMISSION = ALBEDO * rim * rim_strength;
}

void light() {
	float ndl = max(dot(NORMAL, LIGHT) + light_wrap, 0.0);
	float step_count = max(toon_steps, 2.0);
	float toon = floor(ndl * step_count) / (step_count - 1.0);
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ATTENUATION * toon;
}
