extends Node3D
class_name DebugChargeUnit

enum State {
	IDLE,
	MOVE,
	CHASE,
	CHARGE,
	BLOCKED
}

const PROBE_FRONT_LEFT := "front_left"
const PROBE_FRONT_CENTER := "front_center"
const PROBE_FRONT_RIGHT := "front_right"
const PROBE_LEFT := "left"
const PROBE_RIGHT := "right"

@export var display_name: String = "Unit"
@export var team_id: int = 0
@export var walk_speed: float = 8.0
@export var charge_speed: float = 20.0
@export var engage_distance: float = 4.0
@export var charge_end_gap: float = 2.8
@export var collision_front_radius: float = 2.0
@export var collision_side_radius: float = 1.3
@export var body_color: Color = Color(0.25, 0.55, 0.95, 1.0)
@export var turn_rate_deg: float = 240.0
@export var reengage_lock_time: float = 0.55

var state: State = State.IDLE
var selected: bool = false
var move_goal: Vector3 = Vector3.ZERO
var target_unit: DebugChargeUnit = null
var charge_goal: Vector3 = Vector3.ZERO
var charge_target: DebugChargeUnit = null
var charge_hit_done: bool = false
var last_move_note: String = ""
var last_zoc_mul: float = 1.0
var last_probe_worlds: Dictionary = {}
var detour_goal: Vector3 = Vector3.INF
var detour_forward: Vector3 = Vector3.ZERO
var detour_time_left: float = 0.0
var motion_dir: Vector3 = Vector3.FORWARD
var reengage_time_left: float = 0.0

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var ring_mesh: MeshInstance3D = $SelectionRing
@onready var name_label: Label3D = $NameLabel

func _ready() -> void:
	_setup_visuals()
	motion_dir = get_forward_flat()
	_update_selection_visual()

func _physics_process(delta: float) -> void:
	if detour_time_left > 0.0:
		detour_time_left = maxf(0.0, detour_time_left - delta)
		if detour_time_left <= 0.0:
			clear_temporary_detour()
	if reengage_time_left > 0.0:
		reengage_time_left = maxf(0.0, reengage_time_left - delta)
	match state:
		State.IDLE:
			if _has_valid_target(target_unit):
				_face_towards(target_unit.global_position)
		State.MOVE:
			_process_move(delta)
		State.CHASE:
			_process_chase(delta)
		State.CHARGE:
			_process_charge(delta)
		State.BLOCKED:
			if charge_target != null:
				_process_charge(delta)
			elif _has_valid_target(target_unit):
				_process_chase(delta)
			elif move_goal.distance_to(global_position) > 0.08 or has_active_detour():
				_process_move(delta)

func setup_unit(new_name: String, new_team_id: int, new_color: Color) -> void:
	display_name = new_name
	team_id = new_team_id
	body_color = new_color
	_setup_visuals()

func set_selected(enabled: bool) -> void:
	selected = enabled
	_update_selection_visual()

func is_dead() -> bool:
	return false

func get_forward_flat() -> Vector3:
	var forward: Vector3 = -global_basis.z
	forward.y = 0.0
	if forward.length_squared() <= 0.0001:
		return Vector3.FORWARD
	return forward.normalized()

func get_half_extents() -> Vector2:
	return Vector2(collision_side_radius, collision_front_radius)

func get_logic_radius() -> float:
	return maxf(collision_front_radius, collision_side_radius) * 1.08

func get_probe_local_offsets() -> Dictionary:
	var hx: float = collision_side_radius
	var hz: float = collision_front_radius
	return {
		PROBE_FRONT_LEFT: Vector3(-hx * 0.78, 0.0, -hz - 0.75),
		PROBE_FRONT_CENTER: Vector3(0.0, 0.0, -hz - 0.95),
		PROBE_FRONT_RIGHT: Vector3(hx * 0.78, 0.0, -hz - 0.75),
		PROBE_LEFT: Vector3(-hx - 1.05, 0.0, 0.0),
		PROBE_RIGHT: Vector3(hx + 1.05, 0.0, 0.0)
	}

func get_probe_world_positions(forward_override: Vector3 = Vector3.ZERO, center_override: Vector3 = Vector3.INF) -> Dictionary:
	var forward: Vector3 = forward_override
	if forward.length_squared() <= 0.0001:
		forward = get_forward_flat()
	else:
		forward.y = 0.0
		forward = forward.normalized()
	var right := Vector3(forward.z, 0.0, -forward.x)
	if right.length_squared() <= 0.0001:
		right = Vector3.RIGHT
	else:
		right = right.normalized()
	var center: Vector3 = global_position if center_override == Vector3.INF else center_override
	var out: Dictionary = {}
	var local_offsets: Dictionary = get_probe_local_offsets()
	for probe_name in local_offsets.keys():
		var local: Vector3 = local_offsets[probe_name]
		var world_pos: Vector3 = center + right * local.x + forward * (-local.z)
		out[probe_name] = world_pos
	return out

func has_active_detour() -> bool:
	return detour_goal != Vector3.INF and detour_time_left > 0.0

func clear_temporary_detour() -> void:
	detour_goal = Vector3.INF
	detour_forward = Vector3.ZERO
	detour_time_left = 0.0

func set_temporary_detour(world_goal: Vector3, forward_hint: Vector3, duration_sec: float = 0.9) -> void:
	detour_goal = Vector3(world_goal.x, global_position.y, world_goal.z)
	detour_forward = forward_hint.normalized() if forward_hint.length_squared() > 0.0001 else Vector3.ZERO
	detour_time_left = maxf(0.15, duration_sec)

func issue_move_order(world_pos: Vector3) -> void:
	move_goal = Vector3(world_pos.x, global_position.y, world_pos.z)
	target_unit = null
	charge_target = null
	charge_hit_done = false
	reengage_time_left = 0.0
	last_move_note = ""
	clear_temporary_detour()
	state = State.MOVE

func issue_attack_order(enemy: DebugChargeUnit) -> void:
	if enemy == null or enemy == self or enemy.team_id == team_id:
		return
	target_unit = enemy
	charge_target = null
	charge_hit_done = false
	reengage_time_left = 0.0
	last_move_note = ""
	clear_temporary_detour()
	state = State.CHASE

func issue_stop_order() -> void:
	state = State.IDLE
	move_goal = global_position
	charge_goal = global_position
	charge_target = null
	charge_hit_done = false
	reengage_time_left = 0.0
	last_move_note = ""
	clear_temporary_detour()

func issue_charge() -> bool:
	if not _has_valid_target(target_unit):
		return false
	var to_enemy: Vector3 = target_unit.global_position - global_position
	to_enemy.y = 0.0
	if to_enemy.length_squared() <= 0.0001:
		return false
	var charge_forward: Vector3 = to_enemy.normalized()
	var rear_goal: Vector3 = target_unit.global_position + charge_forward * (target_unit.collision_front_radius + collision_front_radius + charge_end_gap)
	rear_goal.y = global_position.y
	var front_goal: Vector3 = target_unit.global_position - charge_forward * maxf(0.6, target_unit.collision_front_radius + collision_front_radius - 0.35)
	front_goal.y = global_position.y
	var field = _get_field()
	if field != null and field.has_method("can_walk_at_world") and not bool(field.call("can_walk_at_world", rear_goal)):
		if not bool(field.call("can_walk_at_world", front_goal)):
			return false
		charge_goal = front_goal
	else:
		charge_goal = rear_goal
	charge_target = target_unit
	charge_hit_done = false
	reengage_time_left = 0.0
	last_move_note = "charge"
	clear_temporary_detour()
	state = State.CHARGE
	return true

func _process_move(delta: float) -> void:
	var remaining: float = _move_with_field(move_goal, walk_speed, delta, "move", null)
	if remaining <= 0.08 and not has_active_detour():
		state = State.IDLE
	elif _is_block_note(last_move_note):
		state = State.BLOCKED

func _process_chase(delta: float) -> void:
	if not _has_valid_target(target_unit):
		state = State.IDLE
		return
	var to_enemy: Vector3 = target_unit.global_position - global_position
	to_enemy.y = 0.0
	var dist: float = to_enemy.length()
	if dist <= engage_distance and not has_active_detour():
		state = State.IDLE
		_face_towards(target_unit.global_position)
		last_move_note = "engaged"
		return
	var goal: Vector3 = target_unit.global_position - to_enemy.normalized() * engage_distance
	goal.y = global_position.y
	var move_mode: String = "reengage" if reengage_time_left > 0.0 else "chase"
	var remaining: float = _move_with_field(goal, walk_speed, delta, move_mode, target_unit)
	if (remaining <= 0.1 and not has_active_detour()) or last_move_note == "engage_front" or last_move_note == "engaged":
		state = State.IDLE
	elif _is_block_note(last_move_note):
		state = State.BLOCKED

func _process_charge(delta: float) -> void:
	var remaining: float = _move_with_field(charge_goal, charge_speed, delta, "charge", charge_target)
	if _has_valid_target(charge_target) and not charge_hit_done:
		var hit_dist: float = charge_target.collision_front_radius + collision_front_radius + 0.35
		if _flat_distance_to(charge_target.global_position) <= hit_dist:
			charge_hit_done = true
			var field = _get_field()
			if field != null and field.has_method("notify_charge_hit"):
				field.call("notify_charge_hit", self, charge_target)
	if remaining <= 0.12:
		var resume_target: DebugChargeUnit = charge_target
		charge_target = null
		clear_temporary_detour()
		if _has_valid_target(resume_target):
			target_unit = resume_target
			reengage_time_left = reengage_lock_time
			last_move_note = "charge_reengage"
			motion_dir = _flat_dir_to(global_position, resume_target.global_position)
			state = State.CHASE
		else:
			state = State.IDLE
	elif last_move_note == "charge_blocked" or last_move_note == "map_block":
		state = State.BLOCKED

func _move_with_field(goal: Vector3, speed: float, delta: float, mode: String, target) -> float:
	var active_goal: Vector3 = goal
	if has_active_detour():
		active_goal = detour_goal
		if global_position.distance_to(detour_goal) <= 0.9:
			clear_temporary_detour()
			active_goal = goal
	var delta_pos: Vector3 = active_goal - global_position
	delta_pos.y = 0.0
	var dist: float = delta_pos.length()
	if dist <= 0.0001:
		last_move_note = "arrived"
		last_zoc_mul = 1.0
		return 0.0
	var desired_dir: Vector3 = delta_pos / dist
	var turn_step: float = deg_to_rad(maxf(1.0, turn_rate_deg) * maxf(0.0, delta))
	motion_dir = _blend_flat_dir(motion_dir, desired_dir, turn_step)
	var field = _get_field()
	var step_len: float = minf(dist, maxf(0.0, speed) * maxf(0.0, delta))
	if field != null and field.has_method("resolve_unit_motion"):
		var motion: Dictionary = field.call("resolve_unit_motion", self, active_goal, motion_dir, step_len, mode, target)
		var next_pos: Vector3 = motion.get("position", global_position)
		last_zoc_mul = float(motion.get("zoc_mul", 1.0))
		last_move_note = String(motion.get("note", ""))
		var probe_forward: Vector3 = motion.get("forward", motion_dir)
		probe_forward.y = 0.0
		if probe_forward.length_squared() > 0.0001:
			motion_dir = _blend_flat_dir(motion_dir, probe_forward.normalized(), turn_step * 0.7)
		last_probe_worlds = get_probe_world_positions(motion_dir, next_pos)
		if motion.has("detour_goal"):
			set_temporary_detour(motion.get("detour_goal", next_pos), motion_dir, float(motion.get("detour_sec", 0.9)))
		if next_pos.distance_to(global_position) > 0.0001:
			global_position = Vector3(next_pos.x, global_position.y, next_pos.z)
			_face_towards(global_position + motion_dir)
		return maxf(0.0, active_goal.distance_to(global_position))
	var next_direct: Vector3 = global_position + motion_dir * step_len
	global_position = Vector3(next_direct.x, global_position.y, next_direct.z)
	_face_towards(global_position + motion_dir)
	last_zoc_mul = 1.0
	last_move_note = "direct"
	last_probe_worlds = get_probe_world_positions(motion_dir, global_position)
	return maxf(0.0, active_goal.distance_to(global_position))

func _is_block_note(note: String) -> bool:
	return note == "blocked" or note == "map_block" or note == "zoc_stop"

func _face_towards(world_pos: Vector3) -> void:
	var flat: Vector3 = world_pos - global_position
	flat.y = 0.0
	if flat.length_squared() <= 0.0001:
		return
	var smooth_dir: Vector3 = _blend_flat_dir(get_forward_flat(), flat.normalized(), deg_to_rad(maxf(8.0, turn_rate_deg * 0.12)))
	look_at(global_position + smooth_dir, Vector3.UP)

func _blend_flat_dir(current: Vector3, target: Vector3, max_turn_radians: float) -> Vector3:
	var current_flat: Vector3 = current
	current_flat.y = 0.0
	var target_flat: Vector3 = target
	target_flat.y = 0.0
	if target_flat.length_squared() <= 0.0001:
		if current_flat.length_squared() <= 0.0001:
			return Vector3.FORWARD
		return current_flat.normalized()
	if current_flat.length_squared() <= 0.0001:
		return target_flat.normalized()
	current_flat = current_flat.normalized()
	target_flat = target_flat.normalized()
	var current_angle: float = atan2(current_flat.x, current_flat.z)
	var target_angle: float = atan2(target_flat.x, target_flat.z)
	var next_angle: float = rotate_toward(current_angle, target_angle, maxf(0.0, max_turn_radians))
	return Vector3(sin(next_angle), 0.0, cos(next_angle)).normalized()

func _flat_dir_to(from_pos: Vector3, to_pos: Vector3) -> Vector3:
	var flat: Vector3 = to_pos - from_pos
	flat.y = 0.0
	if flat.length_squared() <= 0.0001:
		return get_forward_flat()
	return flat.normalized()

func _flat_distance_to(world_pos: Vector3) -> float:
	var d: Vector3 = world_pos - global_position
	d.y = 0.0
	return d.length()

func _has_valid_target(unit: DebugChargeUnit) -> bool:
	return unit != null and is_instance_valid(unit) and unit.team_id != team_id and not unit.is_dead()

func _setup_visuals() -> void:
	if body_mesh == null:
		return
	var body_box := BoxMesh.new()
	body_box.size = Vector3(collision_side_radius * 2.0, 1.4, collision_front_radius * 2.0)
	body_mesh.mesh = body_box
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = body_color
	body_mat.roughness = 0.92
	body_mesh.material_override = body_mat
	var ring_cylinder := CylinderMesh.new()
	ring_cylinder.top_radius = maxf(collision_front_radius, collision_side_radius) + 0.35
	ring_cylinder.bottom_radius = ring_cylinder.top_radius
	ring_cylinder.height = 0.06
	ring_mesh.mesh = ring_cylinder
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = Color(1.0, 0.86, 0.28, 0.95)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(1.0, 0.86, 0.28, 1.0)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mesh.material_override = ring_mat
	name_label.text = display_name
	name_label.modulate = Color(0.95, 0.9, 0.8, 1.0)
	var shape := BoxShape3D.new()
	shape.size = Vector3(collision_side_radius * 2.0, 2.2, collision_front_radius * 2.0)
	$PickArea/CollisionShape3D.shape = shape

func _update_selection_visual() -> void:
	if ring_mesh != null:
		ring_mesh.visible = selected

func _get_field():
	return get_tree().get_first_node_in_group("debug_charge_field")
