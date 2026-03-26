extends Camera3D

@export var move_speed: float = 220.0
@export var sprint_multiplier: float = 2.8
@export var zoom_step: float = 80.0
@export var min_distance: float = 180.0
@export var max_distance: float = 8000.0
@export var rotate_sensitivity: float = 0.005
@export var key_rotate_speed_deg: float = 78.0
@export var vertical_move_speed: float = 180.0
@export var default_focus_point: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var default_distance: float = 2200.0
@export var default_yaw_deg: float = 0.0
@export var default_pitch_deg: float = -4.0

var focus_point: Vector3 = Vector3.ZERO
var orbit_distance: float = 2200.0
var yaw: float = 0.0
var pitch: float = 0.0
var rotating: bool = false

func _ready() -> void:
	reset_view()

func reset_view() -> void:
	focus_point = default_focus_point
	orbit_distance = clampf(default_distance, min_distance, max_distance)
	yaw = deg_to_rad(default_yaw_deg)
	pitch = deg_to_rad(default_pitch_deg)
	_rebuild_transform()

func _physics_process(delta: float) -> void:
	var input_vec := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_vec.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vec.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vec.y += 1.0

	if input_vec.length_squared() > 0.0:
		input_vec = input_vec.normalized()
		var speed := move_speed * (sprint_multiplier if Input.is_key_pressed(KEY_SHIFT) else 1.0)
		var forward := Vector3(sin(yaw), 0.0, cos(yaw))
		var right := Vector3(forward.z, 0.0, -forward.x)
		focus_point += (right * input_vec.x + forward * input_vec.y) * speed * delta
		_rebuild_transform()

	var vertical_sign := 0.0
	if Input.is_key_pressed(KEY_R):
		vertical_sign += 1.0
	if Input.is_key_pressed(KEY_C):
		vertical_sign -= 1.0
	if absf(vertical_sign) > 0.001:
		focus_point.y += vertical_sign * vertical_move_speed * delta
		_rebuild_transform()

	var rotate_sign: float = 0.0
	if Input.is_key_pressed(KEY_Q):
		rotate_sign += 1.0
	if Input.is_key_pressed(KEY_E):
		rotate_sign -= 1.0
	if absf(rotate_sign) > 0.001:
		yaw += deg_to_rad(key_rotate_speed_deg * rotate_sign * delta)
		_rebuild_transform()

	if Input.is_key_pressed(KEY_F):
		reset_view()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_echo():
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_RIGHT:
			rotating = mb.pressed
			return
		if mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			orbit_distance = maxf(min_distance, orbit_distance - zoom_step)
			_rebuild_transform()
		elif mb.pressed and mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			orbit_distance = minf(max_distance, orbit_distance + zoom_step)
			_rebuild_transform()

	if rotating and event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		yaw -= mm.relative.x * rotate_sensitivity
		pitch = clampf(pitch - mm.relative.y * rotate_sensitivity, deg_to_rad(-89.0), deg_to_rad(22.0))
		_rebuild_transform()

func _rebuild_transform() -> void:
	var cp := cos(pitch)
	var offset := Vector3(
		sin(yaw) * cp,
		-sin(pitch),
		cos(yaw) * cp
	) * orbit_distance
	global_position = focus_point + offset
	look_at(focus_point, Vector3.UP)
