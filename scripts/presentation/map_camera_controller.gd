extends Camera3D
class_name MapCameraController

signal zoom_lod_changed(level: int, total_levels: int, height: float)

var _move_speed := 220.0
var _zoom_speed := 40.0
var _rotate_speed_deg := 80.0
var _min_height := 180.0
var _max_height := 800.0
var _distance_ratio := 0.72
var _yaw_deg := 0.0
var _tilt_deg := 58.0
var _lod_tilt_deg: Array[float] = []
var _lod_distance_ratio: Array[float] = []
var _focus := Vector3.ZERO
var _height := 360.0
var _target_height := 360.0
var _half_map_x := 700.0
var _half_map_z := 700.0
var _use_discrete_lod_zoom: bool = true
var _lod_level_heights: Array[float] = []
var _lod_index: int = 0
var _lod_move_speed_scale_max: float = 18.0
var _zoom_smooth_enabled: bool = true
var _lod_transition_seconds: float = 0.24
var _zoom_snap_epsilon: float = 0.05
var _overview_mode: bool = false
var _overview_tilt_deg: float = 88.0
var _overview_distance_ratio: float = 0.02

func configure(camera_rules: Dictionary, map_size: Dictionary) -> void:
	_move_speed = float(camera_rules.get("move_speed", _move_speed))
	_zoom_speed = float(camera_rules.get("zoom_speed", _zoom_speed))
	_rotate_speed_deg = float(camera_rules.get("rotate_speed_deg", _rotate_speed_deg))
	_min_height = float(camera_rules.get("min_height", _min_height))
	_max_height = float(camera_rules.get("max_height", _max_height))
	_height = clampf(float(camera_rules.get("default_height", _height)), _min_height, _max_height)
	_yaw_deg = float(camera_rules.get("yaw_deg", _yaw_deg))
	_tilt_deg = float(camera_rules.get("tilt_deg", _tilt_deg))
	_distance_ratio = float(camera_rules.get("distance_ratio", _distance_ratio))
	var raw_lod_tilts: Array = camera_rules.get("lod_tilt_deg", [])
	var raw_lod_dist: Array = camera_rules.get("lod_distance_ratio", [])
	if camera_rules.has("overview_tilt_deg"):
		_overview_tilt_deg = clampf(float(camera_rules.get("overview_tilt_deg", _overview_tilt_deg)), 10.0, 89.0)
	if camera_rules.has("overview_distance_ratio"):
		_overview_distance_ratio = clampf(float(camera_rules.get("overview_distance_ratio", _overview_distance_ratio)), 0.01, 2.0)
	_use_discrete_lod_zoom = bool(camera_rules.get("use_discrete_lod_zoom", true))
	_lod_move_speed_scale_max = maxf(1.0, float(camera_rules.get("lod_move_speed_scale_max", 18.0)))
	_zoom_smooth_enabled = bool(camera_rules.get("zoom_smooth_enabled", true))
	_lod_transition_seconds = maxf(0.05, float(camera_rules.get("lod_transition_seconds", 0.24)))
	_half_map_x = float(map_size.get("x", 1200.0)) * 0.5
	_half_map_z = float(map_size.get("z", 1200.0)) * 0.5
	_configure_lod_levels(camera_rules, map_size)
	_configure_lod_tilts(raw_lod_tilts)
	_configure_lod_distance_ratios(raw_lod_dist)
	_set_height(float(camera_rules.get("default_height", _height)), true, false, true)
	far = float(camera_rules.get("far_clip", maxf(_max_height * 6.0, 50000.0)))
	_rebuild_transform()
	emit_signal("zoom_lod_changed", _lod_index + 1, _lod_level_heights.size(), _target_height)

func _ready() -> void:
	_rebuild_transform()

func _physics_process(delta: float) -> void:
	_update_zoom_transition(delta)

	var move_vec := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		move_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		move_vec.x += 1.0
	if Input.is_key_pressed(KEY_W):
		move_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		move_vec.y += 1.0

	if Input.is_key_pressed(KEY_Q):
		_yaw_deg += _rotate_speed_deg * delta
	if Input.is_key_pressed(KEY_E):
		_yaw_deg -= _rotate_speed_deg * delta

	if move_vec.length_squared() > 0.0:
		move_vec = move_vec.normalized()
		var yaw_rad := deg_to_rad(_yaw_deg)
		var forward := Vector3(sin(yaw_rad), 0.0, cos(yaw_rad))
		var right := Vector3(forward.z, 0.0, -forward.x)
		var speed_mul := 1.8 if Input.is_key_pressed(KEY_SHIFT) else 1.0
		var zoom_ratio: float = clampf(_height / maxf(_min_height, 1.0), 1.0, _lod_move_speed_scale_max * _lod_move_speed_scale_max)
		var zoom_speed_mul: float = clampf(sqrt(zoom_ratio), 1.0, _lod_move_speed_scale_max)
		_focus += (right * move_vec.x + forward * move_vec.y) * _move_speed * zoom_speed_mul * speed_mul * delta
		_clamp_focus()

	_rebuild_transform()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if not mb.pressed or mb.is_echo():
			return
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			if _use_discrete_lod_zoom:
				_step_lod(-1)
			else:
				_set_height(_height - _zoom_speed, false, true)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if _use_discrete_lod_zoom:
				_step_lod(1)
			else:
				_set_height(_height + _zoom_speed, false, true)
		return

func _clamp_focus() -> void:
	var margin_x: float = _compute_pan_margin(_half_map_x)
	var margin_z: float = _compute_pan_margin(_half_map_z)
	_focus.x = clampf(_focus.x, -_half_map_x - margin_x, _half_map_x + margin_x)
	_focus.z = clampf(_focus.z, -_half_map_z - margin_z, _half_map_z + margin_z)

func _compute_pan_margin(half_extent: float) -> float:
	var fov_margin: float = _height * tan(deg_to_rad(fov * 0.5))
	var offset_margin: float = _height * (_overview_distance_ratio if _overview_mode else _distance_ratio)
	return clampf(maxf(320.0, fov_margin + offset_margin), 320.0, half_extent * 0.45)

func _rebuild_transform() -> void:
	var active_tilt_deg: float = _overview_tilt_deg if _overview_mode else _get_active_lod_tilt_deg()
	var active_distance_ratio: float = _overview_distance_ratio if _overview_mode else _get_active_lod_distance_ratio()
	var yaw := deg_to_rad(_yaw_deg)
	var offset := Vector3(
		sin(yaw) * _height * active_distance_ratio,
		_height,
		cos(yaw) * _height * active_distance_ratio
	)
	global_position = _focus + offset
	look_at(_focus, Vector3.UP)
	rotation_degrees.x = -active_tilt_deg

func _get_active_lod_tilt_deg() -> float:
	if _lod_tilt_deg.is_empty():
		return _tilt_deg
	var idx: int = clampi(_lod_index, 0, _lod_tilt_deg.size() - 1)
	return _lod_tilt_deg[idx]

func _get_active_lod_distance_ratio() -> float:
	if _lod_distance_ratio.is_empty():
		return _distance_ratio
	var idx: int = clampi(_lod_index, 0, _lod_distance_ratio.size() - 1)
	return _lod_distance_ratio[idx]

func _configure_lod_tilts(raw_tilts: Array) -> void:
	_lod_tilt_deg.clear()
	for value_any in raw_tilts:
		_lod_tilt_deg.append(clampf(float(value_any), 10.0, 89.0))
	if _lod_tilt_deg.is_empty():
		return
	var lod_count: int = _lod_level_heights.size()
	if _lod_tilt_deg.size() > lod_count:
		_lod_tilt_deg = _lod_tilt_deg.slice(0, lod_count)
	elif _lod_tilt_deg.size() < lod_count:
		var fallback: float = _lod_tilt_deg[_lod_tilt_deg.size() - 1]
		while _lod_tilt_deg.size() < lod_count:
			_lod_tilt_deg.append(fallback)

func _configure_lod_distance_ratios(raw_ratios: Array) -> void:
	_lod_distance_ratio.clear()
	for value_any in raw_ratios:
		_lod_distance_ratio.append(clampf(float(value_any), 0.0, 2.0))
	if _lod_distance_ratio.is_empty():
		return
	var lod_count: int = _lod_level_heights.size()
	if _lod_distance_ratio.size() > lod_count:
		_lod_distance_ratio = _lod_distance_ratio.slice(0, lod_count)
	elif _lod_distance_ratio.size() < lod_count:
		var fallback: float = _lod_distance_ratio[_lod_distance_ratio.size() - 1]
		while _lod_distance_ratio.size() < lod_count:
			_lod_distance_ratio.append(fallback)

func _configure_lod_levels(camera_rules: Dictionary, map_size: Dictionary) -> void:
	_lod_level_heights.clear()
	var raw_heights: Array = camera_rules.get("lod_level_heights", [])
	for value_any in raw_heights:
		var h: float = float(value_any)
		if h <= 0.0:
			continue
		_lod_level_heights.append(h)
	if _lod_level_heights.size() < 2:
		var map_span: float = maxf(float(map_size.get("x", 1200.0)), float(map_size.get("z", 1200.0)))
		var auto_min: float = maxf(_min_height, map_span * 0.009)
		var auto_max: float = maxf(_max_height, map_span * 0.87)
		_lod_level_heights = [
			auto_min,
			auto_min * 3.2,
			auto_min * 10.5,
			auto_min * 31.0,
			auto_max
		]
	_lod_level_heights.sort()
	var deduped: Array[float] = []
	for h in _lod_level_heights:
		if deduped.is_empty() or absf(deduped[deduped.size() - 1] - h) > 0.01:
			deduped.append(h)
	_lod_level_heights = deduped
	if _lod_level_heights.size() < 2:
		_lod_level_heights = [_min_height, _max_height]
	_min_height = _lod_level_heights[0]
	_max_height = _lod_level_heights[_lod_level_heights.size() - 1]
	_lod_index = _nearest_lod_index(_height)

func _step_lod(delta_index: int) -> void:
	if _lod_level_heights.size() < 2:
		return
	_set_lod_index(_lod_index + delta_index, true, false)

func _set_lod_index(index: int, rebuild_now: bool, instant: bool = false) -> void:
	if _lod_level_heights.size() < 2:
		return
	var clamped_idx: int = clampi(index, 0, _lod_level_heights.size() - 1)
	var target_lod_height: float = _lod_level_heights[clamped_idx]
	if clamped_idx == _lod_index and absf(_target_height - target_lod_height) <= 0.01:
		return
	_lod_index = clamped_idx
	_target_height = target_lod_height
	if instant or not _zoom_smooth_enabled:
		_height = _target_height
	emit_signal("zoom_lod_changed", _lod_index + 1, _lod_level_heights.size(), _target_height)
	if rebuild_now:
		_rebuild_transform()

func _set_height(target_height: float, snap_to_lod: bool, rebuild_now: bool, instant: bool = false) -> void:
	var clamped: float = clampf(target_height, _min_height, _max_height)
	if _use_discrete_lod_zoom and snap_to_lod and _lod_level_heights.size() >= 2:
		_set_lod_index(_nearest_lod_index(clamped), rebuild_now, instant)
		return
	_target_height = clamped
	_lod_index = _nearest_lod_index(_target_height)
	if instant or not _zoom_smooth_enabled:
		_height = _target_height
	if rebuild_now:
		_rebuild_transform()

func _nearest_lod_index(height_value: float) -> int:
	if _lod_level_heights.is_empty():
		return 0
	var best_i: int = 0
	var best_delta: float = absf(_lod_level_heights[0] - height_value)
	for i in range(1, _lod_level_heights.size()):
		var d: float = absf(_lod_level_heights[i] - height_value)
		if d < best_delta:
			best_delta = d
			best_i = i
	return best_i

func _update_zoom_transition(delta: float) -> void:
	if absf(_target_height - _height) <= _zoom_snap_epsilon:
		_height = _target_height
		return
	if not _zoom_smooth_enabled:
		_height = _target_height
		return
	var blend: float = 1.0 - exp(-delta * 8.0 / _lod_transition_seconds)
	_height = lerpf(_height, _target_height, clampf(blend, 0.0, 1.0))


func set_overview_mode(enabled: bool, center_focus: bool = false) -> void:
	_overview_mode = enabled
	if center_focus:
		_focus = Vector3.ZERO
		_clamp_focus()
	_rebuild_transform()


func is_overview_mode() -> bool:
	return _overview_mode


func get_current_lod_level() -> int:
	return _lod_index + 1


func get_total_lod_levels() -> int:
	return _lod_level_heights.size()


func get_current_target_height() -> float:
	return _target_height

