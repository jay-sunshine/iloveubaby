extends Node3D
class_name ProjectileTraceVfx

@export var line_duration_sec: float = 0.45
@export var trail_length_ratio: float = 0.38
@export var trail_head_alpha: float = 0.96
@export var trail_tail_alpha: float = 0.16
@export var base_color: Color = Color(1.0, 0.98, 0.9, 0.98)
@export var emission_color: Color = Color(1.0, 0.98, 0.9, 1.0)
@export var emission_energy: float = 1.7
@export var force_no_depth_test: bool = true

var trace_mesh_node: MeshInstance3D = null
var trace_mesh: ImmediateMesh = null
var trace_trails: Array[Dictionary] = []
var trace_timer: float = 0.0
var trace_total: float = 0.0

func _ready() -> void:
	_ensure_trace_mesh()
	visible = false
	set_process(false)

func configure_visual(duration_sec: float, length_ratio: float, head_alpha: float, tail_alpha: float) -> void:
	line_duration_sec = maxf(0.02, duration_sec)
	trail_length_ratio = clampf(length_ratio, 0.08, 0.95)
	trail_head_alpha = clampf(head_alpha, 0.0, 1.0)
	trail_tail_alpha = clampf(tail_alpha, 0.0, 1.0)
	_apply_trace_material()

func configure_color(albedo: Color, emission: Color, emission_mul: float = 1.7) -> void:
	base_color = albedo
	emission_color = emission
	emission_energy = maxf(0.0, emission_mul)
	_apply_trace_material()

func play_trails(trails: Array, duration_sec: float = -1.0) -> void:
	_ensure_trace_mesh()
	_ensure_world_space_identity()
	trace_trails.clear()
	for trail_any in trails:
		if trail_any is Dictionary:
			trace_trails.append((trail_any as Dictionary).duplicate())
	if trace_trails.is_empty():
		stop()
		return
	trace_timer = maxf(0.04, duration_sec if duration_sec > 0.0 else line_duration_sec)
	trace_total = trace_timer
	visible = true
	_render_trace(0.0)
	set_process(true)

func stop() -> void:
	trace_timer = 0.0
	trace_total = 0.0
	trace_trails.clear()
	if trace_mesh_node != null:
		trace_mesh_node.visible = false
	visible = false
	set_process(false)

func _process(delta: float) -> void:
	if trace_mesh_node == null:
		set_process(false)
		return
	if trace_timer <= 0.0:
		trace_mesh_node.visible = false
		visible = false
		set_process(false)
		return
	trace_timer = maxf(0.0, trace_timer - delta)
	var total: float = maxf(0.001, trace_total)
	var progress: float = clampf(1.0 - trace_timer / total, 0.0, 1.0)
	_render_trace(progress)
	if trace_timer <= 0.0:
		trace_mesh_node.visible = false
		visible = false
		set_process(false)

func _ensure_trace_mesh() -> void:
	if trace_mesh_node != null and is_instance_valid(trace_mesh_node) and trace_mesh != null:
		_ensure_world_space_identity()
		return
	trace_mesh_node = get_node_or_null("TraceMesh") as MeshInstance3D
	if trace_mesh_node == null:
		trace_mesh_node = MeshInstance3D.new()
		trace_mesh_node.name = "TraceMesh"
		add_child(trace_mesh_node)
	trace_mesh_node.top_level = true
	_ensure_world_space_identity()
	trace_mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	trace_mesh_node.visible = false
	if trace_mesh == null or not is_instance_valid(trace_mesh):
		trace_mesh = ImmediateMesh.new()
	trace_mesh_node.mesh = trace_mesh
	_apply_trace_material()

func _ensure_world_space_identity() -> void:
	if trace_mesh_node == null or not is_instance_valid(trace_mesh_node):
		return
	if trace_mesh_node.global_transform != Transform3D.IDENTITY:
		trace_mesh_node.global_transform = Transform3D.IDENTITY

func _apply_trace_material() -> void:
	if trace_mesh_node == null:
		return
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = force_no_depth_test
	mat.vertex_color_use_as_albedo = true
	mat.albedo_color = base_color
	mat.emission_enabled = true
	mat.emission = emission_color
	mat.emission_energy_multiplier = emission_energy
	trace_mesh_node.material_override = mat

func _sample_path_point(start: Vector3, end: Vector3, t: float, arc_height: float, line_mode: bool) -> Vector3:
	var clamped_t: float = clampf(t, 0.0, 1.0)
	var point: Vector3 = start.lerp(end, clamped_t)
	if not line_mode:
		point.y += maxf(0.0, arc_height) * (4.0 * clamped_t * (1.0 - clamped_t))
	return point

func _sample_path_tangent(start: Vector3, end: Vector3, t: float, arc_height: float, line_mode: bool) -> Vector3:
	var t0: float = clampf(t - 0.015, 0.0, 1.0)
	var t1: float = clampf(t + 0.015, 0.0, 1.0)
	var p0: Vector3 = _sample_path_point(start, end, t0, arc_height, line_mode)
	var p1: Vector3 = _sample_path_point(start, end, t1, arc_height, line_mode)
	var tan: Vector3 = p1 - p0
	if tan.length_squared() <= 0.000001:
		tan = end - start
	if tan.length_squared() <= 0.000001:
		return Vector3.FORWARD
	return tan.normalized()

func _add_colored_tri(v0: Vector3, c0: Color, v1: Vector3, c1: Color, v2: Vector3, c2: Color) -> void:
	trace_mesh.surface_set_color(c0)
	trace_mesh.surface_add_vertex(v0)
	trace_mesh.surface_set_color(c1)
	trace_mesh.surface_add_vertex(v1)
	trace_mesh.surface_set_color(c2)
	trace_mesh.surface_add_vertex(v2)

func _render_blade_trail(trail: Dictionary, start: Vector3, end: Vector3, side_vec: Vector3, tail_t: float, head_t: float, arc_height: float, line_mode: bool, tail_col: Color, head_col: Color) -> void:
	var side_len: float = maxf(0.008, side_vec.length())
	var side_dir: Vector3 = side_vec.normalized()
	if side_dir.length_squared() <= 0.000001:
		side_dir = Vector3.RIGHT
	var face_to_target: bool = bool(trail.get("blade_face_to_target", false))
	var face_dir: Vector3 = trail.get("blade_face_dir", end - start)
	face_dir.y = 0.0
	if face_dir.length_squared() <= 0.000001:
		face_dir = end - start
	if face_dir.length_squared() <= 0.000001:
		face_dir = Vector3.FORWARD
	face_dir = face_dir.normalized()
	var segments: int = clampi(int(trail.get("blade_segments", 7)), 3, 14)
	var curve_mul: float = maxf(0.0, float(trail.get("blade_curve", 0.68)))
	var curve_sign: float = 1.0 if float(trail.get("blade_curve_sign", 1.0)) >= 0.0 else -1.0
	var tail_white_ratio: float = clampf(float(trail.get("blade_tail_white_ratio", 0.0)), 0.0, 0.95)
	var body_mul: float = clampf(float(trail.get("blade_body_mul", 1.85)), 0.6, 3.0)
	var tip_mul: float = clampf(float(trail.get("blade_tip_mul", 1.9)), 0.6, 3.4)

	var has_prev: bool = false
	var prev_inner: Vector3 = Vector3.ZERO
	var prev_outer: Vector3 = Vector3.ZERO
	var prev_col: Color = tail_col

	for i in range(segments + 1):
		var u: float = float(i) / maxf(1.0, float(segments))
		var t: float = lerpf(tail_t, head_t, u)
		var point: Vector3 = _sample_path_point(start, end, t, arc_height, line_mode)
		var right_vec: Vector3 = Vector3.ZERO
		if face_to_target:
			right_vec = Vector3(-face_dir.z, 0.0, face_dir.x).normalized()
		else:
			var tangent: Vector3 = _sample_path_tangent(start, end, t, arc_height, line_mode)
			right_vec = tangent.cross(Vector3.UP).normalized()
		if right_vec.length_squared() <= 0.000001:
			right_vec = side_dir
		if not face_to_target and right_vec.dot(side_dir) < 0.0:
			right_vec = -right_vec

		var width_profile: float = sin(u * PI)
		var half_width: float = side_len * body_mul * maxf(0.04, width_profile)
		var bow: float = 1.0 - abs(u * 2.0 - 1.0)
		var center_shift: float = side_len * curve_mul * curve_sign * bow * 0.9
		var center: Vector3 = point + right_vec * center_shift
		var inner: Vector3 = center - right_vec * (half_width * 0.38)
		var outer: Vector3 = center + right_vec * (half_width * 1.0)
		var col: Color = tail_col.lerp(head_col, u)
		if tail_white_ratio > 0.0 and u < tail_white_ratio:
			var w: float = 1.0 - clampf(u / maxf(0.0001, tail_white_ratio), 0.0, 1.0)
			var white_col := Color(1.0, 1.0, 1.0, col.a)
			col = col.lerp(white_col, w)

		if has_prev:
			_add_colored_tri(prev_inner, prev_col, prev_outer, prev_col, outer, col)
			_add_colored_tri(prev_inner, prev_col, outer, col, inner, col)

		prev_inner = inner
		prev_outer = outer
		prev_col = col
		has_prev = true

	if has_prev:
		var head_tan: Vector3 = _sample_path_tangent(start, end, head_t, arc_height, line_mode)
		var tip: Vector3 = _sample_path_point(start, end, head_t, arc_height, line_mode) + head_tan * side_len * tip_mul
		_add_colored_tri(prev_inner, prev_col, prev_outer, prev_col, tip, head_col)

func _render_trace(progress: float) -> void:
	if trace_mesh == null:
		return
	if trace_trails.is_empty():
		trace_mesh_node.visible = false
		return
	trace_mesh_node.visible = true
	var p: float = clampf(progress, 0.0, 1.0)
	var has_draw_window: bool = false
	for trail_any in trace_trails:
		if not (trail_any is Dictionary):
			continue
		var trail_delay: float = clampf(float((trail_any as Dictionary).get("delay", 0.0)), 0.0, 0.92)
		if p >= trail_delay:
			has_draw_window = true
			break
	if not has_draw_window:
		trace_mesh.clear_surfaces()
		return
	var len_ratio: float = clampf(trail_length_ratio, 0.08, 0.95)
	var tail_a: float = clampf(trail_tail_alpha, 0.0, 1.0)
	var head_a: float = clampf(trail_head_alpha, 0.0, 1.0)
	trace_mesh.clear_surfaces()
	trace_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, trace_mesh_node.material_override)
	for trail_any in trace_trails:
		var trail: Dictionary = trail_any
		var start: Vector3 = trail.get("start", Vector3.ZERO)
		var end: Vector3 = trail.get("end", start)
		var side_vec: Vector3 = trail.get("side", Vector3.RIGHT * 0.03)
		var delay: float = clampf(float(trail.get("delay", 0.0)), 0.0, 0.92)
		if p < delay:
			continue
		var local_p: float = clampf((p - delay) / maxf(0.001, 1.0 - delay), 0.0, 1.0)
		var head_t: float = local_p
		var tail_t: float = maxf(0.0, head_t - len_ratio)
		if head_t <= tail_t + 0.001:
			head_t = minf(1.0, tail_t + 0.02)
		var arc_height: float = float(trail.get("arc_height", 1.0))
		var line_mode: bool = bool(trail.get("line_mode", false))
		var head: Vector3 = _sample_path_point(start, end, head_t, arc_height, line_mode)
		var tail: Vector3 = _sample_path_point(start, end, tail_t, arc_height, line_mode)
		var tail_col: Color = trail.get("tail_color", base_color)
		var head_col: Color = trail.get("head_color", base_color)
		tail_col.a *= tail_a
		head_col.a *= head_a
		if bool(trail.get("blade_mode", false)):
			_render_blade_trail(trail, start, end, side_vec, tail_t, head_t, arc_height, line_mode, tail_col, head_col)
			continue
		var side_head: Vector3 = side_vec
		var side_tail: Vector3 = side_vec * 0.72
		var v0: Vector3 = tail - side_tail
		var v1: Vector3 = tail + side_tail
		var v2: Vector3 = head - side_head
		var v3: Vector3 = head + side_head
		_add_colored_tri(v0, tail_col, v1, tail_col, v2, head_col)
		_add_colored_tri(v2, head_col, v1, tail_col, v3, head_col)
	trace_mesh.surface_end()
