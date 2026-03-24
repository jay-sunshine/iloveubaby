shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always, depth_test_disabled;

uniform sampler2D id_mask : source_color, filter_nearest, repeat_disable;
uniform sampler2D border_mask : source_color, filter_linear, repeat_disable;
uniform sampler2D label_mask : source_color, filter_linear, repeat_disable;

uniform vec4 region_color_01 : source_color = vec4(0.91, 0.89, 0.58, 0.92);
uniform vec4 region_color_02 : source_color = vec4(0.62, 0.88, 0.67, 0.92);
uniform vec4 region_color_03 : source_color = vec4(0.93, 0.82, 0.54, 0.92);
uniform vec4 region_color_04 : source_color = vec4(0.91, 0.72, 0.80, 0.92);
uniform vec4 region_color_05 : source_color = vec4(0.73, 0.90, 0.67, 0.92);
uniform vec4 region_color_06 : source_color = vec4(0.95, 0.90, 0.67, 0.92);
uniform vec4 region_color_07 : source_color = vec4(0.86, 0.69, 0.84, 0.92);
uniform vec4 region_color_08 : source_color = vec4(0.95, 0.91, 0.73, 0.92);
uniform vec4 region_color_09 : source_color = vec4(0.92, 0.81, 0.56, 0.92);
uniform vec4 region_color_10 : source_color = vec4(0.72, 0.92, 0.69, 0.92);
uniform vec4 region_color_11 : source_color = vec4(0.68, 0.88, 0.62, 0.92);
uniform vec4 region_color_12 : source_color = vec4(0.91, 0.70, 0.79, 0.92);
uniform vec4 region_color_13 : source_color = vec4(0.92, 0.79, 0.53, 0.92);

uniform vec4 border_color : source_color = vec4(0.27, 0.12, 0.06, 1.0);
uniform vec4 label_color : source_color = vec4(0.12, 0.07, 0.03, 1.0);
uniform float overlay_opacity : hint_range(0.0, 1.0) = 1.0;

vec4 get_region_color(int region_index) {
	if (region_index == 1) { return region_color_01; }
	if (region_index == 2) { return region_color_02; }
	if (region_index == 3) { return region_color_03; }
	if (region_index == 4) { return region_color_04; }
	if (region_index == 5) { return region_color_05; }
	if (region_index == 6) { return region_color_06; }
	if (region_index == 7) { return region_color_07; }
	if (region_index == 8) { return region_color_08; }
	if (region_index == 9) { return region_color_09; }
	if (region_index == 10) { return region_color_10; }
	if (region_index == 11) { return region_color_11; }
	if (region_index == 12) { return region_color_12; }
	if (region_index == 13) { return region_color_13; }
	return vec4(0.0);
}

void fragment() {
	vec2 uv = UV;
	int region_index = int(round(texture(id_mask, uv).r * 255.0));
	vec4 base = get_region_color(region_index);
	float border_alpha = texture(border_mask, uv).a;
	float label_alpha = texture(label_mask, uv).a;
	float detail_mask = step(0.001, base.a);
	vec3 color = base.rgb;
	float alpha = base.a;
	float border_mix = border_alpha * border_color.a * detail_mask;
	float label_mix = label_alpha * label_color.a * detail_mask;
	color = mix(color, border_color.rgb, border_mix);
	alpha = max(alpha, border_mix);
	color = mix(color, label_color.rgb, label_mix);
	alpha = max(alpha, label_mix);
	ALBEDO = color;
	ALPHA = alpha * overlay_opacity;
}
