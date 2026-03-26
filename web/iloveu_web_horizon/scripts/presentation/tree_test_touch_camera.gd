extends Camera3D

const CAMERA_PRESETS := [
	{
		"name": "Sunset Reveal",
		"focus": Vector3(0.0, -4.0, 60.0),
		"distance": 2080.0,
		"yaw_deg": 0.0,
		"pitch_deg": -12.0
	},
	{
		"name": "Confession Wide",
		"focus": Vector3(0.0, 0.0, 20.0),
		"distance": 1860.0,
		"yaw_deg": 0.0,
		"pitch_deg": -28.0
	},
	{
		"name": "Heart Close",
		"focus": Vector3(18.0, 0.0, 26.0),
		"distance": 1180.0,
		"yaw_deg": -11.0,
		"pitch_deg": -24.0
	}
]

@export var default_focus_point: Vector3 = Vector3.ZERO
@export var default_distance: float = 2080.0
@export var default_yaw_deg: float = 0.0
@export var default_pitch_deg: float = -12.0
@export var min_distance: float = 260.0
@export var max_distance: float = 3600.0
@export var drag_rotate_sensitivity: float = 0.008
@export var pinch_zoom_sensitivity: float = 1.35
@export var auto_rotate_speed_deg: float = 1.8
@export var enable_auto_rotate: bool = false

var _focus_point: Vector3 = Vector3.ZERO
var _orbit_distance: float = 2360.0
var _yaw: float = 0.0
var _pitch: float = 0.0
var _mouse_dragging: bool = false
var _touch_points: Dictionary = {}
var _last_pinch_distance: float = -1.0
var _current_preset_index: int = 0

func _ready() -> void:
	_apply_preset_by_index(0)

func reset_view() -> void:
	_apply_preset_by_index(_current_preset_index)

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_F):
		reset_view()
		return
	if enable_auto_rotate and not _mouse_dragging and _touch_points.is_empty():
		_yaw += deg_to_rad(auto_rotate_speed_deg) * delta
		_rebuild_transform()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		_handle_key_input(event as InputEventKey)
		return
	if event is InputEventMouseButton and not event.is_echo():
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_mouse_dragging = mb.pressed
			return
		if mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_apply_zoom(-90.0)
			return
		if mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_apply_zoom(90.0)
			return
	if event is InputEventMouseMotion and _mouse_dragging:
		var mm := event as InputEventMouseMotion
		_apply_rotation(mm.relative)
		return
	if event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
		return
	if event is InputEventScreenDrag:
		_handle_screen_drag(event as InputEventScreenDrag)
		return

func _handle_key_input(event: InputEventKey) -> void:
	if not event.pressed or event.is_echo():
		return
	match event.keycode:
		KEY_1:
			_apply_preset_by_index(0)
		KEY_2:
			_apply_preset_by_index(1)
		KEY_3:
			_apply_preset_by_index(2)
		KEY_SPACE:
			_apply_preset_by_index((_current_preset_index + 1) % CAMERA_PRESETS.size())

func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_points[event.index] = event.position
	else:
		_touch_points.erase(event.index)
	if _touch_points.size() < 2:
		_last_pinch_distance = -1.0

func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	_touch_points[event.index] = event.position
	if _touch_points.size() >= 2:
		var points: Array = _touch_points.values()
		var pinch_distance := (points[0] as Vector2).distance_to(points[1] as Vector2)
		if _last_pinch_distance > 0.0:
			var delta := _last_pinch_distance - pinch_distance
			_apply_zoom(delta * pinch_zoom_sensitivity)
		_last_pinch_distance = pinch_distance
		return
	_apply_rotation(event.relative)

func _apply_rotation(delta_vec: Vector2) -> void:
	_yaw -= delta_vec.x * drag_rotate_sensitivity
	_pitch = clampf(_pitch - delta_vec.y * drag_rotate_sensitivity, deg_to_rad(-70.0), deg_to_rad(-8.0))
	_rebuild_transform()

func _apply_zoom(delta_amount: float) -> void:
	_orbit_distance = clampf(_orbit_distance + delta_amount, min_distance, max_distance)
	_rebuild_transform()

func _apply_preset_by_index(index: int) -> void:
	if CAMERA_PRESETS.is_empty():
		_focus_point = default_focus_point
		_orbit_distance = clampf(default_distance, min_distance, max_distance)
		_yaw = deg_to_rad(default_yaw_deg)
		_pitch = deg_to_rad(default_pitch_deg)
		_last_pinch_distance = -1.0
		_rebuild_transform()
		return
	_current_preset_index = clampi(index, 0, CAMERA_PRESETS.size() - 1)
	var preset: Dictionary = CAMERA_PRESETS[_current_preset_index]
	_focus_point = preset.get("focus", default_focus_point)
	_orbit_distance = clampf(float(preset.get("distance", default_distance)), min_distance, max_distance)
	_yaw = deg_to_rad(float(preset.get("yaw_deg", default_yaw_deg)))
	_pitch = deg_to_rad(float(preset.get("pitch_deg", default_pitch_deg)))
	_last_pinch_distance = -1.0
	_rebuild_transform()

func _rebuild_transform() -> void:
	var cp := cos(_pitch)
	var offset := Vector3(
		sin(_yaw) * cp,
		-sin(_pitch),
		cos(_yaw) * cp
	) * _orbit_distance
	global_position = _focus_point + offset
	look_at(_focus_point, Vector3.UP)

