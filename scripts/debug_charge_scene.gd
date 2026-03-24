extends Node3D

const SIDE_LEFT := -1
const SIDE_RIGHT := 1

@export var walk_half_extents: Vector2 = Vector2(42.0, 24.0)
@export var zoc_radius_margin: float = 2.0
@export var zoc_speed_mul_per_enemy: float = 0.68
@export var zoc_speed_mul_min: float = 0.24
@export var zoc_front_dot_threshold: float = -0.05
@export var sidepass_extra_clearance: float = 1.0
@export var logic_radius_padding: float = 0.15
@export var detour_forward_push: float = 4.2

var selected_unit = null

@onready var camera: Camera3D = $Camera3D
@onready var status_label: Label = $CanvasLayer/Panel/VBoxContainer/Status
@onready var tips_label: Label = $CanvasLayer/Panel/VBoxContainer/Tips

func _ready() -> void:
	add_to_group("debug_charge_field")
	_setup_units()
	_update_status("Left click friendly, right click enemy, press 1 to charge, S to stop.")
	if tips_label != null:
		tips_label.text = "Square visuals with circular logic: front ZOC, goal-based sidepass and charge re-engage."

func _process(_delta: float) -> void:
	if selected_unit == null or not is_instance_valid(selected_unit):
		return
	var zoc_text: String = "x%.2f" % float(selected_unit.last_zoc_mul)
	var note: String = selected_unit.last_move_note
	if note.is_empty():
		note = "idle"
	status_label.text = "Selected: %s | State: %s | ZOC: %s | Note: %s" % [selected_unit.display_name, str(selected_unit.state), zoc_text, note]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(mouse_event.position)
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_right_click(mouse_event.position)
	elif event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_1:
			_handle_charge_key()
		elif key_event.keycode == KEY_S and selected_unit != null:
			selected_unit.issue_stop_order()
			_update_status("Stopped.")

func can_walk_at_world(world_pos: Vector3) -> bool:
	return absf(world_pos.x) <= walk_half_extents.x and absf(world_pos.z) <= walk_half_extents.y

func notify_charge_hit(attacker, defender) -> void:
	if attacker == null or defender == null:
		return
	_update_status("%s hit %s and pierced the target line." % [attacker.display_name, defender.display_name])

func resolve_unit_motion(unit, goal: Vector3, move_dir: Vector3, step_len: float, mode: String, target) -> Dictionary:
	var dir: Vector3 = move_dir
	dir.y = 0.0
	if dir.length_squared() <= 0.0001:
		dir = unit.get_forward_flat()
	else:
		dir = dir.normalized()
	var zoc_mul: float = _compute_zoc_mul(unit, unit.global_position, mode, target, dir)
	var actual_step: float = maxf(0.0, step_len) * zoc_mul
	var desired_pos: Vector3 = unit.global_position + dir * actual_step
	var result := {
		"position": unit.global_position,
		"forward": dir,
		"zoc_mul": zoc_mul,
		"note": "blocked"
	}
	if actual_step <= 0.0001:
		result.note = "zoc_stop"
		return result
	if not can_walk_at_world(desired_pos):
		result.note = "map_block"
		return result
	var blocker = _find_blocking_unit_circle(unit, desired_pos, mode, target)
	if blocker == null:
		result.position = desired_pos
		result.note = "advance"
		return result
	if mode == "move":
		var sidepass: Dictionary = _try_circle_sidepass(unit, blocker, dir, actual_step, goal)
		if bool(sidepass.get("ok", false)):
			result.position = sidepass.position
			result.forward = sidepass.forward
			result.note = String(sidepass.get("note", "sidepass"))
			result.detour_goal = sidepass.get("detour_goal", sidepass.position)
			result.detour_sec = float(sidepass.get("detour_sec", 0.9))
			return result
		result.note = "blocked"
		return result
	if mode == "chase" or mode == "reengage":
		if blocker == target:
			result.note = "engage_front"
		else:
			var sidepass2: Dictionary = _try_circle_sidepass(unit, blocker, dir, actual_step, goal)
			if bool(sidepass2.get("ok", false)):
				result.position = sidepass2.position
				result.forward = sidepass2.forward
				result.note = String(sidepass2.get("note", "chase_sidepass"))
				result.detour_goal = sidepass2.get("detour_goal", sidepass2.position)
				result.detour_sec = float(sidepass2.get("detour_sec", 0.8 if mode == "reengage" else 1.0))
			else:
				result.note = "blocked"
		return result
	if mode == "charge":
		if blocker == target:
			result.position = desired_pos
			result.note = "charge_pierce"
			return result
		result.note = "charge_blocked"
		return result
	return result

func _compute_zoc_mul(unit, sample_pos: Vector3, mode: String, target, move_dir: Vector3) -> float:
	if mode == "charge":
		return 1.0
	var enemy_count: int = 0
	for other in _get_debug_units():
		if other == unit or other.team_id == unit.team_id:
			continue
		if other == target and (mode == "chase" or mode == "reengage"):
			continue
		if mode == "reengage":
			continue
		var to_enemy: Vector3 = other.global_position - sample_pos
		to_enemy.y = 0.0
		var dist: float = to_enemy.length()
		if dist <= 0.0001:
			enemy_count += 1
			continue
		var radius: float = _unit_logic_radius(other) + _unit_logic_radius(unit) + zoc_radius_margin
		if dist > radius:
			continue
		if move_dir.length_squared() > 0.0001:
			var enemy_dir: Vector3 = to_enemy / dist
			if move_dir.dot(enemy_dir) < zoc_front_dot_threshold:
				continue
		enemy_count += 1
	if enemy_count <= 0:
		return 1.0
	var out: float = pow(maxf(0.05, zoc_speed_mul_per_enemy), float(enemy_count))
	return clampf(out, zoc_speed_mul_min, 1.0)

func _try_circle_sidepass(unit, blocker, move_dir: Vector3, actual_step: float, goal: Vector3) -> Dictionary:
	var best: Dictionary = {"ok": false}
	var best_score: float = INF
	for sign in [SIDE_LEFT, SIDE_RIGHT]:
		var blocker_to_unit: Vector3 = unit.global_position - blocker.global_position
		blocker_to_unit.y = 0.0
		if blocker_to_unit.length_squared() <= 0.0001:
			blocker_to_unit = Vector3(-move_dir.z, 0.0, move_dir.x) * float(sign)
		var away_dir: Vector3 = blocker_to_unit.normalized()
		var tangent_dir: Vector3 = Vector3(-away_dir.z, 0.0, away_dir.x) * float(sign)
		if tangent_dir.dot(move_dir) < 0.0:
			tangent_dir = -tangent_dir
		var clearance: float = _unit_logic_radius(blocker) + _unit_logic_radius(unit) + sidepass_extra_clearance
		var side_anchor: Vector3 = blocker.global_position + away_dir * clearance
		var candidate_pos: Vector3 = side_anchor + tangent_dir.normalized() * maxf(actual_step, clearance * 0.55)
		candidate_pos.y = unit.global_position.y
		if not can_walk_at_world(candidate_pos):
			continue
		if _find_blocking_unit_circle(unit, candidate_pos, "move", null) != null:
			continue
		var detour_goal: Vector3 = candidate_pos + tangent_dir.normalized() * maxf(detour_forward_push, clearance * 1.8)
		detour_goal.y = unit.global_position.y
		if not can_walk_at_world(detour_goal):
			detour_goal = candidate_pos
		var score: float = candidate_pos.distance_to(goal) + detour_goal.distance_to(goal) * 0.35
		var goal_dir: Vector3 = goal - unit.global_position
		goal_dir.y = 0.0
		if goal_dir.length_squared() > 0.0001:
			score -= tangent_dir.normalized().dot(goal_dir.normalized()) * 1.4
		if score < best_score:
			best_score = score
			best = {
				"ok": true,
				"position": candidate_pos,
				"forward": tangent_dir.normalized(),
				"detour_goal": detour_goal,
				"detour_sec": 0.95,
				"note": "sidepass_left" if sign == SIDE_LEFT else "sidepass_right"
			}
	return best

func _find_blocking_unit_circle(unit, sample_pos: Vector3, mode: String, target):
	for other in _get_debug_units():
		if other == unit:
			continue
		if mode == "charge" and other == target:
			continue
		var limit: float = _unit_logic_radius(unit) + _unit_logic_radius(other)
		if _flat_distance(sample_pos, other.global_position) <= limit:
			return other
	return null

func _unit_logic_radius(unit) -> float:
	return maxf(0.5, float(unit.get_logic_radius()) + logic_radius_padding)

func _flat_distance(a: Vector3, b: Vector3) -> float:
	var d: Vector3 = a - b
	d.y = 0.0
	return d.length()

func _get_debug_units() -> Array:
	var out: Array = []
	for child in $Units.get_children():
		if child != null and child.has_method("get_logic_radius"):
			out.append(child)
	return out

func _handle_left_click(screen_pos: Vector2) -> void:
	var hit: Dictionary = _raycast_from_screen(screen_pos)
	if hit.is_empty():
		_set_selected_unit(null)
		return
	var collider: Object = hit.get("collider")
	var unit = _extract_unit_from_collider(collider)
	if unit != null and int(unit.team_id) == 0:
		_set_selected_unit(unit)
		_update_status("Selected %s." % unit.display_name)
	else:
		_set_selected_unit(null)

func _handle_right_click(screen_pos: Vector2) -> void:
	if selected_unit == null:
		return
	var hit: Dictionary = _raycast_from_screen(screen_pos)
	if hit.is_empty():
		return
	var collider: Object = hit.get("collider")
	var unit = _extract_unit_from_collider(collider)
	if unit != null and int(unit.team_id) != int(selected_unit.team_id):
		selected_unit.issue_attack_order(unit)
		_update_status("Locked %s. Press 1 to test charge." % unit.display_name)
		return
	if hit.has("position"):
		var move_pos: Vector3 = hit.position
		move_pos.y = 0.0
		if can_walk_at_world(move_pos):
			selected_unit.issue_move_order(move_pos)
			_update_status("Move to %.1f, %.1f" % [move_pos.x, move_pos.z])

func _handle_charge_key() -> void:
	if selected_unit == null:
		return
	var ok: bool = selected_unit.issue_charge()
	if ok:
		_update_status("Charge started.")
	else:
		_update_status("Charge failed: no target or invalid landing point.")

func _set_selected_unit(unit) -> void:
	if selected_unit != null and is_instance_valid(selected_unit):
		selected_unit.set_selected(false)
	selected_unit = unit
	if selected_unit != null:
		selected_unit.set_selected(true)

func _extract_unit_from_collider(collider: Object):
	if collider == null:
		return null
	if collider.has_method("issue_charge") and collider.has_method("setup_unit"):
		return collider
	if collider is Area3D:
		var parent_node: Node = (collider as Area3D).get_parent()
		if parent_node != null and parent_node.has_method("issue_charge") and parent_node.has_method("setup_unit"):
			return parent_node
	if collider is CollisionObject3D:
		var owner: Node = (collider as Node).get_parent()
		if owner != null and owner.has_method("issue_charge") and owner.has_method("setup_unit"):
			return owner
	return null

func _raycast_from_screen(screen_pos: Vector2) -> Dictionary:
	var from: Vector3 = camera.project_ray_origin(screen_pos)
	var to: Vector3 = from + camera.project_ray_normal(screen_pos) * 500.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_bodies = true
	query.collide_with_areas = true
	return get_world_3d().direct_space_state.intersect_ray(query)

func _update_status(text: String) -> void:
	if status_label != null:
		status_label.text = text

func _setup_units() -> void:
	$Units/CavalryA.setup_unit("Cavalry A", 0, Color(0.28, 0.56, 0.92, 1.0))
	$Units/SpearsB.setup_unit("Spears B", 1, Color(0.82, 0.34, 0.28, 1.0))
	$Units/ArchersB.setup_unit("Archers B", 1, Color(0.78, 0.48, 0.22, 1.0))
