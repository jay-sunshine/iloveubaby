extends Camera3D
class_name BattleCameraController

@export var move_speed: float = 18.0
@export var sprint_multiplier: float = 2.0
@export var edge_scroll_enabled: bool = false
@export var edge_scroll_margin_px: float = 24.0
@export var edge_scroll_speed_mul: float = 1.0
@export var zoom_speed: float = 1.5
@export var rotate_sensitivity: float = 0.006
@export var rotate_key_speed_deg: float = 90.0
@export var min_distance: float = 4.0
@export var max_distance: float = 60.0

var focus_point: Vector3 = Vector3.ZERO
var distance: float = 14.0
var yaw: float = 0.0
var pitch: float = -0.65
var rotating: bool = false
var explicit_focus: bool = false
var movement_input_enabled: bool = true

func _ready() -> void:
	# Force-disable mouse edge scroll to avoid accidental camera drift while issuing RTS commands.
	edge_scroll_enabled = false
	var forward: Vector3 = -global_basis.z
	forward.y = clampf(forward.y, -0.98, 0.98)
	yaw = atan2(forward.x, forward.z)
	pitch = clampf(asin(forward.y), -1.2, -0.22)
	if not explicit_focus:
		focus_point = Vector3(global_position.x, 0.0, global_position.z - 18.0)
	distance = clampf(global_position.distance_to(focus_point), min_distance, max_distance)
	_rebuild_transform()

func set_focus_point(world_pos: Vector3) -> void:
	explicit_focus = true
	focus_point = Vector3(world_pos.x, 0.0, world_pos.z)
	_rebuild_transform()

func set_movement_input_enabled(enabled: bool) -> void:
	movement_input_enabled = enabled

func _physics_process(delta: float) -> void:
	if not movement_input_enabled:
		return
	var input_vec := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vec.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vec.y += 1.0
	if edge_scroll_enabled:
		var rect := get_viewport().get_visible_rect()
		var mouse := get_viewport().get_mouse_position()
		if mouse.x <= edge_scroll_margin_px:
			input_vec.x -= 1.0
		elif mouse.x >= rect.size.x - edge_scroll_margin_px:
			input_vec.x += 1.0
		if mouse.y <= edge_scroll_margin_px:
			input_vec.y -= 1.0
		elif mouse.y >= rect.size.y - edge_scroll_margin_px:
			input_vec.y += 1.0

	var transform_changed: bool = false
	if input_vec.length_squared() > 0.0:
		input_vec = input_vec.normalized()
		var forward := Vector3(sin(yaw), 0.0, cos(yaw))
		var right := Vector3(forward.z, 0.0, -forward.x)
		var speed := move_speed * (sprint_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1.0)
		speed *= maxf(0.1, edge_scroll_speed_mul)
		focus_point += (right * input_vec.x + forward * input_vec.y) * speed * delta
		focus_point.y = 0.0
		transform_changed = true

	var rotate_sign: float = 0.0
	if Input.is_key_pressed(KEY_Q):
		rotate_sign += 1.0
	if Input.is_key_pressed(KEY_E):
		rotate_sign -= 1.0
	if absf(rotate_sign) > 0.001:
		yaw += deg_to_rad(rotate_key_speed_deg * rotate_sign * delta)
		transform_changed = true

	if transform_changed:
		_rebuild_transform()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not event.is_echo():
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_MIDDLE:
			rotating = true
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = maxf(min_distance, distance - zoom_speed)
			_rebuild_transform()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = minf(max_distance, distance + zoom_speed)
			_rebuild_transform()
	elif event is InputEventMouseButton and not event.pressed:
		var mb_release: InputEventMouseButton = event
		if mb_release.button_index == MOUSE_BUTTON_MIDDLE:
			rotating = false

	if rotating and event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event
		yaw -= mm.relative.x * rotate_sensitivity
		pitch = clampf(pitch - mm.relative.y * rotate_sensitivity, -1.2, -0.22)
		_rebuild_transform()

func _rebuild_transform() -> void:
	var cp := cos(pitch)
	var offset := Vector3(
		sin(yaw) * cp,
		-sin(pitch),
		cos(yaw) * cp
	) * distance
	global_position = focus_point + offset
	look_at(focus_point, Vector3.UP)
