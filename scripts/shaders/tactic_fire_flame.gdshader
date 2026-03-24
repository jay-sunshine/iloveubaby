shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, blend_add;

uniform vec4 u_core_color : source_color = vec4(1.0, 0.68, 0.22, 1.0);
uniform vec4 u_edge_color : source_color = vec4(1.0, 0.28, 0.08, 1.0);
uniform float u_time = 0.0;
uniform float u_intensity = 1.0;

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float radial = 1.0 - clamp(length(vec2(uv.x * 1.18, uv.y * 0.78)), 0.0, 1.0);
	float vertical = smoothstep(-0.96, 0.96, uv.y);
	float flicker = 0.74 + sin(u_time * 8.6 + UV.y * 16.8 + UV.x * 11.2) * 0.26;
	float curl = 0.55 + 0.45 * sin((UV.y - u_time * 1.9) * 22.0 + sin(UV.x * 7.2 + u_time * 3.1) * 2.8);
	float alpha = pow(max(radial, 0.0), 1.42) * vertical * curl * flicker * clamp(u_intensity, 0.15, 2.6);
	alpha = clamp(alpha, 0.0, 1.0);
	vec3 color_mix = mix(u_edge_color.rgb, u_core_color.rgb, pow(alpha, 0.52));
	ALBEDO = color_mix;
	EMISSION = color_mix * (2.05 + flicker * 1.7);
	ALPHA = alpha * u_core_color.a;
}
