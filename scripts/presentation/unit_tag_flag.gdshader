shader_type canvas_item;
render_mode blend_mix;

uniform vec4 cloth_color : source_color = vec4(0.56, 0.16, 0.15, 0.92);
uniform vec4 edge_color : source_color = vec4(0.40, 0.10, 0.10, 0.95);
uniform float notch_depth : hint_range(0.06, 0.45) = 0.22;
uniform float tassel_count : hint_range(6.0, 7.0) = 7.0;
uniform float edge_width : hint_range(0.005, 0.06) = 0.02;
uniform float grain_strength : hint_range(0.0, 0.12) = 0.035;
uniform float vertical_shade : hint_range(0.0, 0.35) = 0.12;
uniform float weave_strength : hint_range(0.0, 0.25) = 0.14;
uniform float weave_scale : hint_range(20.0, 220.0) = 118.0;
uniform float fold_strength : hint_range(0.0, 0.35) = 0.13;
uniform float thread_highlight : hint_range(0.0, 0.22) = 0.08;

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float cloth_weave(vec2 uv) {
	float sx = 6.2831853 * (uv.x * weave_scale);
	float sy = 6.2831853 * (uv.y * weave_scale * 0.82);
	float warp = sin(sx);
	float weft = sin(sy);
	float cross = warp * weft;
	float fiber = 0.5 + 0.5 * cross;
	float cell = hash12(floor(uv * vec2(weave_scale * 0.45, weave_scale * 0.38)));
	float worn = mix(0.84, 1.08, cell);
	return fiber * worn;
}

void fragment() {
	vec2 uv = UV;
	float n = max(6.0, round(tassel_count));
	float slots = max(11.0, 2.0 * n - 1.0);
	float y = clamp(uv.y, 0.0, 0.999999);
	float slot_id = floor(y * slots);
	float is_tassel_slot = 1.0 - step(0.5, mod(slot_id, 2.0));
	float body_right = 1.0 - notch_depth;
	float x_limit = mix(body_right, 1.0, is_tassel_slot);
	if (uv.x < 0.0 || uv.x > x_limit || uv.y < 0.0 || uv.y > 1.0) {
		discard;
	}

	float right_dist = x_limit - uv.x;
	float left_dist = uv.x;
	float top_dist = uv.y;
	float bottom_dist = 1.0 - uv.y;
	float edge_dist = min(min(left_dist, right_dist), min(top_dist, bottom_dist));
	float edge_mix = 1.0 - smoothstep(edge_width, edge_width * 1.8, edge_dist);

	// Keep cloth fully static: no TIME-based animation.
	float grain = hash12(floor(uv * vec2(172.0, 118.0))) * 2.0 - 1.0;
	float weave = cloth_weave(uv);
	float cross_highlight = max(0.0, weave - 0.55) * thread_highlight;
	float fold = sin((uv.x * 3.4 + uv.y * 0.9) * 3.1415926) * 0.5 + 0.5;
	float fold_tone = (fold - 0.5) * 2.0;
	float shade = 1.0
		- uv.y * vertical_shade
		+ (weave - 0.5) * weave_strength
		+ fold_tone * fold_strength
		+ cross_highlight
		+ grain * grain_strength;
	shade = clamp(shade, 0.62, 1.26);
	vec3 base = cloth_color.rgb * shade;
	vec3 color = mix(base, edge_color.rgb, edge_mix * 0.92);
	float alpha = cloth_color.a;
	COLOR = vec4(color, alpha);
}
