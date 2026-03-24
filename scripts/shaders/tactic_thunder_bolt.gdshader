shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_opaque;

uniform vec4 u_core_color : source_color = vec4(0.76, 0.82, 1.0, 1.0);
uniform vec4 u_edge_color : source_color = vec4(0.28, 0.2, 1.0, 1.0);
uniform float u_alpha_mul = 1.0;
uniform float u_energy_mul = 3.8;
uniform float u_noise_mul = 1.0;
uniform float u_seed = 1.0;

float hash11(float p) {
	return fract(sin(p * 127.1) * 43758.5453123);
}

void fragment() {
	vec2 uv = UV;
	float x = uv.x * 2.0 - 1.0;
	float y = uv.y;
	float time = TIME;

	float jitter = sin(y * 52.0 + time * 22.0 + u_seed * 3.7) * 0.14 * u_noise_mul;
	jitter += sin(y * 93.0 - time * 14.0 + u_seed * 5.3) * 0.08 * u_noise_mul;
	jitter += sin(y * 141.0 + time * 31.0 + u_seed * 2.1) * 0.05 * u_noise_mul;
	float taper = mix(1.18, 0.46, clamp(y, 0.0, 1.0));
	float local_x = abs(x - jitter) / max(0.12, taper);

	float core_w = 0.2;
	float halo_w = 0.58;
	float core = smoothstep(core_w, core_w * 0.18, local_x);
	float halo = smoothstep(halo_w, halo_w * 0.22, local_x);

	float strip = floor(y * 34.0 + time * 14.0 + u_seed * 8.0);
	float stripe_noise = hash11(strip);
	float stripe_gate = smoothstep(0.03, 0.56, stripe_noise);

	float pulse = 0.7 + 0.3 * sin(time * 42.0 + y * 78.0 + u_seed * 6.0);
	float alpha = (core * 1.22 + halo * 0.52) * stripe_gate * pulse * u_alpha_mul;
	alpha = clamp(alpha, 0.0, 1.0);
	if (alpha <= 0.003) {
		discard;
	}

	vec3 col = mix(u_edge_color.rgb, u_core_color.rgb, clamp(core * 1.35, 0.0, 1.0));
	float energy = u_energy_mul * (1.0 + core * 0.95 + pulse * 0.38);
	ALBEDO = col;
	EMISSION = col * energy;
	ALPHA = alpha * clamp(u_core_color.a, 0.0, 1.0);
}
