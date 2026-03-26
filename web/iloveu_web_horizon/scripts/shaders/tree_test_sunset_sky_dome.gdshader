shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never, blend_mix;

varying vec3 local_pos_v;

uniform vec4 zenith_color : source_color = vec4(0.28, 0.20, 0.44, 1.0);
uniform vec4 upper_sky_color : source_color = vec4(0.82, 0.54, 0.66, 1.0);
uniform vec4 horizon_color : source_color = vec4(1.0, 0.72, 0.52, 1.0);
uniform vec4 horizon_glow_color : source_color = vec4(1.0, 0.56, 0.30, 1.0);
uniform vec4 sun_color : source_color = vec4(1.0, 0.84, 0.42, 1.0);
uniform vec3 sun_direction = vec3(0.0, -0.035, -1.0);

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
	for (int i = 0; i < 5; i++) {
		value += noise(p) * amplitude;
		p = p * 2.02 + vec2(3.0, 7.8);
		amplitude *= 0.5;
	}
	return value;
}

void vertex() {
	local_pos_v = VERTEX;
}

void fragment() {
	vec3 dir = normalize(local_pos_v);
	vec3 sun_dir = normalize(sun_direction);
	float sky_grad = smoothstep(-0.20, 0.76, dir.y);
	vec3 color = mix(horizon_color.rgb, upper_sky_color.rgb, sky_grad);
	color = mix(color, zenith_color.rgb, smoothstep(0.32, 0.98, dir.y));
	float warm_band = 1.0 - smoothstep(0.0, 0.18, abs(dir.y + 0.015));
	color = mix(color, horizon_glow_color.rgb, warm_band * 0.62);
	vec2 cloud_uv = vec2(atan(dir.x, dir.z) / 6.28318530718 + 0.5, dir.y * 0.5 + 0.5);
	float cloud_noise = fbm(cloud_uv * vec2(7.0, 22.0) + vec2(0.0, 1.1));
	float streak_noise = fbm(cloud_uv * vec2(14.0, 38.0) + vec2(4.0, 0.7));
	float cloud_band = smoothstep(-0.10, 0.18, dir.y) * (1.0 - smoothstep(0.26, 0.58, dir.y));
	float clouds = smoothstep(0.46, 0.72, cloud_noise) * cloud_band;
	float streaks = smoothstep(0.52, 0.78, streak_noise) * cloud_band;
	color = mix(color, vec3(1.0, 0.70, 0.62), clouds * 0.26);
	color = mix(color, vec3(1.0, 0.82, 0.72), streaks * 0.16);
	float sun_dot = max(dot(dir, sun_dir), 0.0);
	float sun_disc = pow(sun_dot, 3400.0);
	float sun_glow = pow(sun_dot, 28.0);
	color += sun_color.rgb * (sun_disc * 0.78 + sun_glow * 0.20);
	ALBEDO = color;
	EMISSION = color * 0.22 + sun_color.rgb * (sun_disc * 0.22 + sun_glow * 0.04);
	ALPHA = 1.0;
}
