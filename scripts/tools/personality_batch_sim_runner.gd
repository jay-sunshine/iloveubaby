extends SceneTree

const DEFAULT_SCENE_PATH := "res://scenes/battle_demo.tscn"
const DEFAULT_MATCH_COUNT := 60
const DEFAULT_MAX_SIM_SEC := 240.0
const DEFAULT_TIME_SCALE := 8.0
const DEFAULT_SEED_START := 20260316
const DEFAULT_OUTPUT_DIR := "tmp/reports"
var _sim_team_a_roles: PackedStringArray = PackedStringArray(["cavalry", "shield", "spear", "archer", "strategist_s", "strategist_a"])
var _sim_team_b_roles: PackedStringArray = PackedStringArray(["spear", "shield", "cavalry", "archer", "strategist_b", "strategist_c"])
const GOLD_TRAIT_IDS := [
	"xionglue",
	"baozhu",
	"longdan",
	"xianji_gold",
	"quanbian",
	"huoshen",
	"feijiang",
	"rendun",
	"shenwei",
	"huangtian_gold",
	"doujiang",
	"jueshuo",
	"wusheng",
	"wolong",
	"fengchu",
	"shenji_gold",
	"bawang"
]

var _scene_path: String = DEFAULT_SCENE_PATH
var _match_count: int = DEFAULT_MATCH_COUNT
var _max_sim_sec: float = DEFAULT_MAX_SIM_SEC
var _time_scale: float = DEFAULT_TIME_SCALE
var _seed_start: int = DEFAULT_SEED_START
var _output_dir: String = DEFAULT_OUTPUT_DIR
var _output_prefix: String = "personality_batch"
var _mirror_enabled: bool = false
var _symmetric_enabled: bool = false
var _mirror_swap_team_enabled: bool = true
var _paired_spawn_template_enabled: bool = false
var _disable_all_traits: bool = false
var _single_trait_id: String = ""
var _single_trait_level: int = 2
var _lock_env_profile: String = ""
const LOCK_ENV_V11_UNITS_PER_TEAM := 6
const LOCK_ENV_V11_SOLDIERS_PER_UNIT := 4200
const LOCK_ENV_V11_TEAM_SPACING_X := 20.0
const LOCK_ENV_V11_TEAM_FRONT_OFFSET_Z := 6.0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_parse_args()
	var output_paths: Dictionary = _prepare_output_paths()
	var match_csv_abs: String = str(output_paths.get("match_csv_abs", "")).strip_edges()
	var trait_csv_abs: String = str(output_paths.get("trait_csv_abs", "")).strip_edges()
	if match_csv_abs.is_empty() or trait_csv_abs.is_empty():
		push_error("output paths resolve failed")
		quit(1)
		return
	var scene_res: Resource = load(_scene_path)
	if not (scene_res is PackedScene):
		push_error("scene load failed: %s" % _scene_path)
		quit(1)
		return
	var packed_scene: PackedScene = scene_res as PackedScene

	var match_rows: Array = []
	var trait_rows: Array = []
	var run_count: int = maxi(1, _match_count)
	var seed_cursor: int = _seed_start
	var i: int = 0
	while i < run_count:
		var match_index: int = i + 1
		var mirror_leg: bool = _mirror_enabled and ((match_index - 1) % 2 == 1)
		var pair_index: int = int(floor(float(match_index - 1) / 2.0)) + 1 if _mirror_enabled else match_index
		var seed_value: int = _seed_start + i
		if _mirror_enabled:
			if mirror_leg:
				seed_value = seed_cursor - 1
			else:
				seed_value = seed_cursor
				seed_cursor += 1
		var result_any: Variant = await _run_single_match(packed_scene, match_index, seed_value, pair_index, mirror_leg)
		var result: Dictionary = result_any as Dictionary if result_any is Dictionary else {}
		var match_row_any: Variant = result.get("match_row", {})
		var match_row: Dictionary = match_row_any as Dictionary if match_row_any is Dictionary else {}
		if match_row.is_empty():
			match_row = {
				"match_index": match_index,
				"pair_index": pair_index,
				"mirror_leg": mirror_leg,
				"seed": seed_value,
				"winner": "error_empty_result",
				"timeout": true
			}
		match_rows.append(match_row)
		var one_trait_rows: Array = result.get("trait_rows", [])
		for row_any in one_trait_rows:
			if row_any is Dictionary:
				trait_rows.append(row_any as Dictionary)
		var winner_text: String = str(match_row.get("winner", "draw"))
		var timeout: bool = bool(match_row.get("timeout", false))
		print("match %d/%d done, pair=%d mirror=%s winner=%s timeout=%s" % [match_index, run_count, pair_index, str(mirror_leg), winner_text, str(timeout)])
		i += 1

	_write_match_csv(match_csv_abs, match_rows)
	_write_trait_csv(trait_csv_abs, trait_rows)
	_print_summary(match_rows, match_csv_abs, trait_csv_abs)
	quit()

func _parse_args() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for arg in args:
		var text: String = str(arg).strip_edges()
		if text.begins_with("--scene="):
			_scene_path = text.trim_prefix("--scene=").strip_edges()
		elif text.begins_with("--matches="):
			_match_count = maxi(1, int(text.trim_prefix("--matches=").strip_edges().to_int()))
		elif text.begins_with("--max_sim_sec="):
			_max_sim_sec = maxf(10.0, float(text.trim_prefix("--max_sim_sec=").strip_edges().to_float()))
		elif text.begins_with("--time_scale="):
			_time_scale = clampf(float(text.trim_prefix("--time_scale=").strip_edges().to_float()), 0.25, 32.0)
		elif text.begins_with("--seed_start="):
			_seed_start = int(text.trim_prefix("--seed_start=").strip_edges().to_int())
		elif text.begins_with("--out_dir="):
			_output_dir = text.trim_prefix("--out_dir=").strip_edges()
		elif text.begins_with("--prefix="):
			_output_prefix = text.trim_prefix("--prefix=").strip_edges()
		elif text.begins_with("--mirror="):
			_mirror_enabled = _parse_bool_arg(text.trim_prefix("--mirror=").strip_edges())
		elif text == "--mirror":
			_mirror_enabled = true
		elif text.begins_with("--symmetric="):
			_symmetric_enabled = _parse_bool_arg(text.trim_prefix("--symmetric=").strip_edges())
		elif text == "--symmetric":
			_symmetric_enabled = true
		elif text.begins_with("--mirror_swap_team="):
			_mirror_swap_team_enabled = _parse_bool_arg(text.trim_prefix("--mirror_swap_team=").strip_edges())
		elif text == "--no_mirror_swap_team":
			_mirror_swap_team_enabled = false
		elif text == "--mirror_swap_team":
			_mirror_swap_team_enabled = true
		elif text.begins_with("--paired_spawn_template="):
			_paired_spawn_template_enabled = _parse_bool_arg(text.trim_prefix("--paired_spawn_template=").strip_edges())
		elif text == "--paired_spawn_template":
			_paired_spawn_template_enabled = true
		elif text == "--no_paired_spawn_template":
			_paired_spawn_template_enabled = false
		elif text.begins_with("--disable_traits="):
			_disable_all_traits = _parse_bool_arg(text.trim_prefix("--disable_traits=").strip_edges())
		elif text == "--disable_traits":
			_disable_all_traits = true
		elif text.begins_with("--single_trait="):
			_single_trait_id = _normalize_trait_id(text.trim_prefix("--single_trait=").strip_edges())
		elif text.begins_with("--single_trait_level="):
			_single_trait_level = clampi(int(text.trim_prefix("--single_trait_level=").strip_edges().to_int()), 1, 2)
		elif text.begins_with("--lock_env="):
			_lock_env_profile = text.trim_prefix("--lock_env=").strip_edges().to_lower()
	if _output_prefix.is_empty():
		_output_prefix = "personality_batch"
	if not _single_trait_id.is_empty():
		_disable_all_traits = false

func _parse_bool_arg(raw: String) -> bool:
	var text: String = raw.strip_edges().to_lower()
	return text == "1" or text == "true" or text == "yes" or text == "y" or text == "on"

func _normalize_trait_id(raw: String) -> String:
	return raw.strip_edges().to_lower()

func _prepare_output_paths() -> Dictionary:
	var stamp: String = Time.get_datetime_string_from_system(false, false)
	stamp = stamp.replace("-", "").replace(":", "").replace("T", "_")
	var out_dir_abs: String = _resolve_path_to_absolute(_output_dir)
	if out_dir_abs.is_empty():
		return {}
	var mk_err: Error = DirAccess.make_dir_recursive_absolute(out_dir_abs)
	if mk_err != OK:
		push_error("mkdir failed: %s err=%d" % [out_dir_abs, int(mk_err)])
		return {}
	var match_name: String = "%s_matches_%s.csv" % [_output_prefix, stamp]
	var trait_name: String = "%s_traits_%s.csv" % [_output_prefix, stamp]
	return {
		"match_csv_abs": out_dir_abs.path_join(match_name),
		"trait_csv_abs": out_dir_abs.path_join(trait_name)
	}

func _resolve_path_to_absolute(path_text: String) -> String:
	var clean: String = path_text.strip_edges()
	if clean.is_empty():
		return ""
	if clean.begins_with("res://") or clean.begins_with("user://"):
		return ProjectSettings.globalize_path(clean)
	if clean.find(":") >= 0:
		return clean
	if clean.begins_with("/") or clean.begins_with("\\\\"):
		return clean
	return ProjectSettings.globalize_path("res://" + clean)

func _run_single_match(packed_scene: PackedScene, match_index: int, seed_value: int, pair_index: int, mirror_leg: bool) -> Dictionary:
	seed(seed_value)
	Engine.time_scale = _time_scale
	var battle: Node = packed_scene.instantiate()
	if battle == null:
		return {
			"match_row": {
				"match_index": match_index,
				"pair_index": pair_index,
				"mirror_leg": mirror_leg,
				"seed": seed_value,
				"winner": "error",
				"timeout": true
			},
			"trait_rows": []
		}
	_apply_battle_sim_tuning(battle)
	_apply_lock_env_profile(battle)
	get_root().add_child(battle)
	await process_frame
	await process_frame
	_apply_runtime_sim_overrides(battle, mirror_leg)
	await process_frame
	var expected_total_units: int = maxi(2, int(battle.get("units_per_team")) * 2)
	await _wait_for_units_ready(battle, expected_total_units, 90)
	if _paired_spawn_template_enabled:
		_apply_paired_spawn_template(battle, mirror_leg)
	elif mirror_leg:
		_apply_spawn_mirror_transform(battle)
	if mirror_leg and _mirror_swap_team_enabled:
		_swap_unit_team_ids_for_mirror_leg(battle)
		await process_frame
	_normalize_unit_state_for_baseline(battle)
	_enable_auto_controls(battle)
	_assign_demo_personalities(battle, match_index)
	_issue_opening_orders(battle)
	var match_tracker: Dictionary = _create_match_tracker()
	_update_match_tracker(battle, match_tracker)

	var sim_elapsed: float = 0.0
	var frame_count: int = 0
	var timeout: bool = false
	var pps: float = float(Engine.physics_ticks_per_second)
	var sim_sec_per_frame: float = _time_scale / maxf(1.0, pps)
	var max_frames: int = maxi(1, int(ceil(_max_sim_sec / maxf(0.0001, sim_sec_per_frame))))
	while frame_count < max_frames:
		await physics_frame
		frame_count += 1
		sim_elapsed += sim_sec_per_frame
		_update_match_tracker(battle, match_tracker)
		var alive: Dictionary = _get_alive_unit_counts_from_tracker(match_tracker)
		if int(alive.get("team_0_alive_units", 0)) <= 0 or int(alive.get("team_1_alive_units", 0)) <= 0:
			break
	if frame_count >= max_frames:
		timeout = true

	_update_match_tracker(battle, match_tracker)
	var match_row: Dictionary = _build_match_row(match_tracker, match_index, pair_index, mirror_leg, seed_value, sim_elapsed, frame_count, timeout)
	var trait_rows: Array[Dictionary] = _build_trait_rows(match_tracker, match_index, pair_index, mirror_leg, seed_value, str(match_row.get("winner", "draw")), timeout)
	battle.queue_free()
	await process_frame
	return {
		"match_row": match_row,
		"trait_rows": trait_rows
	}

func _apply_battle_sim_tuning(battle: Node) -> void:
	battle.set("randomize_on_ready", false)
	battle.set("embedded_on_strategy_map", false)
	battle.set("enemy_auto_engage_enabled", true)
	battle.set("auto_engage_enabled", true)
	battle.set("auto_release_enabled", true)
	battle.set("show_unit_tags", false)
	battle.set("hover_panel_enabled", false)
	battle.set("tactic_vfx_enabled", false)
	# Keep benchmark comparable: disable demo facility damage/aura sandbox.
	battle.set("demo_facility_test_setup_enabled", false)
	battle.set("debug_allow_control_all_units_for_testing", true)
	battle.set("auto_spawn_demo_units", true)

func _apply_lock_env_profile(battle: Node) -> void:
	var profile: String = _lock_env_profile.strip_edges().to_lower()
	if profile.is_empty() or profile == "off" or profile == "none":
		return
	if profile == "v11":
		# Lock benchmark-critical environment knobs to avoid drift from demo scene evolution.
		battle.set("demo_facility_test_setup_enabled", false)
		battle.set("units_per_team", LOCK_ENV_V11_UNITS_PER_TEAM)
		battle.set("soldiers_per_unit", LOCK_ENV_V11_SOLDIERS_PER_UNIT)
		battle.set("team_spacing_x", LOCK_ENV_V11_TEAM_SPACING_X)
		# Keep spawn line inside battle_demo_simple_terrain walkable bounds to avoid spawn collapse.
		battle.set("team_front_offset_z", LOCK_ENV_V11_TEAM_FRONT_OFFSET_Z)
		battle.set("team_a_unit_roles", _sim_team_a_roles)
		battle.set("team_b_unit_roles", _sim_team_b_roles)

func _apply_runtime_sim_overrides(battle: Node, mirror_leg: bool) -> void:
	battle.set("units_per_team", LOCK_ENV_V11_UNITS_PER_TEAM)
	var lock_profile: String = _lock_env_profile.strip_edges().to_lower()
	if lock_profile == "v11":
		# _ready() reloads rule JSON and can override pre-ready values, so re-apply lock here.
		battle.set("soldiers_per_unit", LOCK_ENV_V11_SOLDIERS_PER_UNIT)
		battle.set("team_spacing_x", LOCK_ENV_V11_TEAM_SPACING_X)
		battle.set("team_front_offset_z", LOCK_ENV_V11_TEAM_FRONT_OFFSET_Z)
	var team_a_roles: PackedStringArray = _sim_team_a_roles
	var team_b_roles: PackedStringArray = _sim_team_b_roles
	if _symmetric_enabled:
		team_b_roles = team_a_roles
	if mirror_leg:
		team_a_roles = _sim_team_b_roles
		team_b_roles = _sim_team_a_roles
		if _symmetric_enabled:
			team_a_roles = _sim_team_a_roles
			team_b_roles = _sim_team_a_roles
	battle.set("team_a_unit_roles", team_a_roles)
	battle.set("team_b_unit_roles", team_b_roles)
	if battle.has_method("_spawn_demo_units"):
		battle.call("_spawn_demo_units")

func _enable_auto_controls(battle: Node) -> void:
	var units_any: Variant = battle.get("units")
	if not (units_any is Array):
		return
	var skill_auto: Dictionary = {}
	var famous_auto: Dictionary = {}
	for unit_any in (units_any as Array):
		if unit_any == null or not is_instance_valid(unit_any):
			continue
		skill_auto[int(unit_any.get_instance_id())] = true
		famous_auto[int(unit_any.get_instance_id())] = true
	battle.set("unit_skill_auto_mode", skill_auto)
	battle.set("unit_famous_auto_mode", famous_auto)

func _issue_opening_orders(battle: Node) -> void:
	var units_any: Variant = battle.get("units")
	if not (units_any is Array):
		return
	for unit_any in (units_any as Array):
		if unit_any == null or not is_instance_valid(unit_any):
			continue
		if bool(unit_any.get("dead")):
			continue
		var enemy: Variant = battle.call("get_closest_enemy", unit_any)
		if enemy == null or not is_instance_valid(enemy):
			continue
		if unit_any.has_method("issue_attack_order"):
			unit_any.call("issue_attack_order", enemy)

func _get_alive_unit_counts(battle: Node) -> Dictionary:
	var team0: int = 0
	var team1: int = 0
	var units_any: Variant = battle.get("units")
	if units_any is Array:
		for unit_any in (units_any as Array):
			if unit_any == null or not is_instance_valid(unit_any):
				continue
			if bool(unit_any.get("dead")):
				continue
			var team_id: int = int(unit_any.get("team_id"))
			if team_id == 0:
				team0 += 1
			elif team_id == 1:
				team1 += 1
	return {
		"team_0_alive_units": team0,
		"team_1_alive_units": team1
	}

func _wait_for_units_ready(battle: Node, expected_total: int, max_frames: int) -> void:
	var target: int = maxi(2, expected_total)
	var wait_frames: int = maxi(1, max_frames)
	for _i in range(wait_frames):
		if _collect_units_from_battle(battle).size() >= target:
			return
		await process_frame

func _collect_units_from_battle(battle: Node) -> Array:
	var out: Array = []
	var units_any: Variant = battle.get("units")
	if not (units_any is Array):
		return out
	for unit_any in (units_any as Array):
		if unit_any == null or not is_instance_valid(unit_any):
			continue
		out.append(unit_any)
	return out

func _collect_team_units_sorted_x(battle: Node, team_id: int) -> Array:
	var out: Array = []
	for unit in _collect_units_from_battle(battle):
		if unit == null or not is_instance_valid(unit):
			continue
		if int(unit.get("team_id")) != team_id:
			continue
		out.append(unit)
	out.sort_custom(func(a, b) -> bool:
		if not (a is Node3D) or not (b is Node3D):
			return int(a.get_instance_id()) < int(b.get_instance_id())
		var ax: float = (a as Node3D).global_position.x
		var bx: float = (b as Node3D).global_position.x
		if absf(ax - bx) <= 0.0001:
			return int(a.get_instance_id()) < int(b.get_instance_id())
		return ax < bx
	)
	return out

func _apply_paired_spawn_template(battle: Node, mirror_leg: bool) -> void:
	var center: Vector3 = Vector3.ZERO
	var center_any: Variant = battle.get("spawn_center")
	if center_any is Vector3:
		center = center_any as Vector3
	var spacing: float = clampf(float(battle.get("team_spacing_x")), 4.0, 10.0)
	var front: float = clampf(absf(float(battle.get("team_front_offset_z"))), 10.0, 18.0)
	var team0_units: Array = _collect_team_units_sorted_x(battle, 0)
	var team1_units: Array = _collect_team_units_sorted_x(battle, 1)
	var team0_sign: float = 1.0 if not mirror_leg else -1.0
	var team1_sign: float = -1.0 if not mirror_leg else 1.0
	_place_team_units_with_template(battle, team0_units, center, spacing, front * team0_sign)
	_place_team_units_with_template(battle, team1_units, center, spacing, front * team1_sign)

func _place_team_units_with_template(battle: Node, units_arr: Array, center: Vector3, spacing: float, z_offset: float) -> void:
	var count: int = units_arr.size()
	if count <= 0:
		return
	for idx in range(count):
		var unit = units_arr[idx]
		if unit == null or not is_instance_valid(unit):
			continue
		if not (unit is Node3D):
			continue
		var x: float = (float(idx) - float(count - 1) * 0.5) * spacing
		var pos: Vector3 = Vector3(center.x + x, center.y, center.z + z_offset)
		if battle.has_method("_terrain_height_at_world"):
			pos.y = float(battle.call("_terrain_height_at_world", pos))
		var node_3d: Node3D = unit as Node3D
		node_3d.global_position = pos
		var euler: Vector3 = node_3d.rotation_degrees
		euler.y = 0.0 if z_offset >= 0.0 else 180.0
		node_3d.rotation_degrees = euler

func _apply_spawn_mirror_transform(battle: Node) -> void:
	var center: Vector3 = Vector3.ZERO
	var center_any: Variant = battle.get("spawn_center")
	if center_any is Vector3:
		center = center_any as Vector3
	for unit in _collect_units_from_battle(battle):
		if unit == null or not is_instance_valid(unit):
			continue
		if not (unit is Node3D):
			continue
		var node_3d: Node3D = unit as Node3D
		var world_pos: Vector3 = node_3d.global_position
		var rel: Vector3 = world_pos - center
		rel.x = -rel.x
		rel.z = -rel.z
		var mirrored: Vector3 = center + rel
		if battle.has_method("_terrain_height_at_world"):
			mirrored.y = float(battle.call("_terrain_height_at_world", mirrored))
		node_3d.global_position = mirrored
		var euler: Vector3 = node_3d.rotation_degrees
		euler.y = fposmod(euler.y + 180.0, 360.0)
		node_3d.rotation_degrees = euler

func _normalize_unit_state_for_baseline(battle: Node) -> void:
	for unit in _collect_units_from_battle(battle):
		if unit == null or not is_instance_valid(unit):
			continue
		if _symmetric_enabled and unit.has_method("set_stance"):
			unit.call("set_stance", 0)
		# Keep sim stats complete and deterministic even if runtime gameplay uses lighter defaults.
		unit.set("personality_event_debug_stats_enabled", true)
		unit.set("personality_event_light_tick_interval_sec", 0.0)

func _swap_unit_team_ids_for_mirror_leg(battle: Node) -> void:
	for unit in _collect_units_from_battle(battle):
		if unit == null or not is_instance_valid(unit):
			continue
		var team_id: int = int(unit.get("team_id"))
		if team_id != 0 and team_id != 1:
			continue
		unit.set("team_id", 1 - team_id)

func _create_match_tracker() -> Dictionary:
	return {
		"units": {}
	}

func _create_unit_tracker_entry(unit) -> Dictionary:
	var alive_troops: int = _safe_alive_troops(unit)
	return {
		"team_id": int(unit.get("team_id")),
		"initial_troops": maxi(0, int(unit.get("troop_count"))),
		"alive": not bool(unit.get("dead")),
		"alive_troops": alive_troops,
		"trigger_total": maxi(0, int(unit.get("personality_event_debug_trigger_total"))),
		"blocked_total": maxi(0, int(unit.get("personality_event_debug_blocked_total"))),
		"forced_total": maxi(0, int(unit.get("personality_event_debug_forced_total"))),
		"trigger_by_key": _copy_counter_map(unit.get("personality_event_debug_trigger_by_key")),
		"blocked_by_key": _copy_counter_map(unit.get("personality_event_debug_blocked_by_key")),
		"forced_by_key": _copy_counter_map(unit.get("personality_event_debug_forced_by_key"))
	}

func _safe_alive_troops(unit) -> int:
	if unit == null or not is_instance_valid(unit):
		return 0
	if unit.has_method("get_alive_troop_count"):
		return maxi(0, int(unit.call("get_alive_troop_count")))
	return maxi(0, int(unit.get("troop_count")))

func _copy_counter_map(src_any: Variant) -> Dictionary:
	var out: Dictionary = {}
	if not (src_any is Dictionary):
		return out
	var src: Dictionary = src_any as Dictionary
	for key_any in src.keys():
		var key: String = str(key_any).strip_edges().to_lower()
		if key.is_empty():
			continue
		out[key] = maxi(0, int(src.get(key_any, 0)))
	return out

func _merge_counter_map_max(dst: Dictionary, src_any: Variant) -> void:
	if not (src_any is Dictionary):
		return
	var src: Dictionary = src_any as Dictionary
	for key_any in src.keys():
		var key: String = str(key_any).strip_edges().to_lower()
		if key.is_empty():
			continue
		var value: int = maxi(0, int(src.get(key_any, 0)))
		dst[key] = maxi(int(dst.get(key, 0)), value)

func _update_match_tracker(battle: Node, tracker: Dictionary) -> void:
	var units_by_id: Dictionary = tracker.get("units", {}) as Dictionary
	var seen: Dictionary = {}
	for unit in _collect_units_from_battle(battle):
		if unit == null or not is_instance_valid(unit):
			continue
		var unit_id: int = int(unit.get_instance_id())
		seen[unit_id] = true
		var data: Dictionary = units_by_id.get(unit_id, {}) as Dictionary
		if data.is_empty():
			data = _create_unit_tracker_entry(unit)
		else:
			data["team_id"] = int(unit.get("team_id"))
			data["initial_troops"] = maxi(int(data.get("initial_troops", 0)), maxi(0, int(unit.get("troop_count"))))
			data["trigger_total"] = maxi(int(data.get("trigger_total", 0)), maxi(0, int(unit.get("personality_event_debug_trigger_total"))))
			data["blocked_total"] = maxi(int(data.get("blocked_total", 0)), maxi(0, int(unit.get("personality_event_debug_blocked_total"))))
			data["forced_total"] = maxi(int(data.get("forced_total", 0)), maxi(0, int(unit.get("personality_event_debug_forced_total"))))
		data["alive"] = not bool(unit.get("dead"))
		data["alive_troops"] = _safe_alive_troops(unit)
		var trigger_by_key: Dictionary = data.get("trigger_by_key", {}) as Dictionary
		var blocked_by_key: Dictionary = data.get("blocked_by_key", {}) as Dictionary
		var forced_by_key: Dictionary = data.get("forced_by_key", {}) as Dictionary
		_merge_counter_map_max(trigger_by_key, unit.get("personality_event_debug_trigger_by_key"))
		_merge_counter_map_max(blocked_by_key, unit.get("personality_event_debug_blocked_by_key"))
		_merge_counter_map_max(forced_by_key, unit.get("personality_event_debug_forced_by_key"))
		data["trigger_by_key"] = trigger_by_key
		data["blocked_by_key"] = blocked_by_key
		data["forced_by_key"] = forced_by_key
		units_by_id[unit_id] = data
	for unit_id_any in units_by_id.keys():
		var unit_id: int = int(unit_id_any)
		if seen.has(unit_id):
			continue
		var data: Dictionary = units_by_id.get(unit_id, {}) as Dictionary
		if data.is_empty():
			continue
		data["alive"] = false
		data["alive_troops"] = 0
		units_by_id[unit_id] = data
	tracker["units"] = units_by_id

func _build_team_stats_from_tracker(tracker: Dictionary) -> Dictionary:
	var out: Dictionary = {
		"team_0": {
			"total_units": 0,
			"alive_units": 0,
			"dead_units": 0,
			"initial_troops": 0,
			"alive_troops": 0,
			"trigger_total": 0,
			"blocked_total": 0,
			"forced_total": 0,
			"trigger_by_key": {},
			"blocked_by_key": {},
			"forced_by_key": {}
		},
		"team_1": {
			"total_units": 0,
			"alive_units": 0,
			"dead_units": 0,
			"initial_troops": 0,
			"alive_troops": 0,
			"trigger_total": 0,
			"blocked_total": 0,
			"forced_total": 0,
			"trigger_by_key": {},
			"blocked_by_key": {},
			"forced_by_key": {}
		}
	}
	var units_by_id: Dictionary = tracker.get("units", {}) as Dictionary
	for unit_id_any in units_by_id.keys():
		var data: Dictionary = units_by_id.get(unit_id_any, {}) as Dictionary
		if data.is_empty():
			continue
		var team_id: int = int(data.get("team_id", -1))
		if team_id != 0 and team_id != 1:
			continue
		var team_key: String = "team_%d" % team_id
		var team_stats: Dictionary = out.get(team_key, {}) as Dictionary
		team_stats["total_units"] = int(team_stats.get("total_units", 0)) + 1
		team_stats["initial_troops"] = int(team_stats.get("initial_troops", 0)) + maxi(0, int(data.get("initial_troops", 0)))
		var alive: bool = bool(data.get("alive", false))
		if alive:
			team_stats["alive_units"] = int(team_stats.get("alive_units", 0)) + 1
			team_stats["alive_troops"] = int(team_stats.get("alive_troops", 0)) + maxi(0, int(data.get("alive_troops", 0)))
		team_stats["trigger_total"] = int(team_stats.get("trigger_total", 0)) + maxi(0, int(data.get("trigger_total", 0)))
		team_stats["blocked_total"] = int(team_stats.get("blocked_total", 0)) + maxi(0, int(data.get("blocked_total", 0)))
		team_stats["forced_total"] = int(team_stats.get("forced_total", 0)) + maxi(0, int(data.get("forced_total", 0)))
		var trigger_by_key: Dictionary = team_stats.get("trigger_by_key", {}) as Dictionary
		var blocked_by_key: Dictionary = team_stats.get("blocked_by_key", {}) as Dictionary
		var forced_by_key: Dictionary = team_stats.get("forced_by_key", {}) as Dictionary
		_accumulate_debug_key_map(trigger_by_key, data.get("trigger_by_key", {}))
		_accumulate_debug_key_map(blocked_by_key, data.get("blocked_by_key", {}))
		_accumulate_debug_key_map(forced_by_key, data.get("forced_by_key", {}))
		team_stats["trigger_by_key"] = trigger_by_key
		team_stats["blocked_by_key"] = blocked_by_key
		team_stats["forced_by_key"] = forced_by_key
		team_stats["dead_units"] = maxi(0, int(team_stats.get("total_units", 0)) - int(team_stats.get("alive_units", 0)))
		out[team_key] = team_stats
	return out

func _get_alive_unit_counts_from_tracker(tracker: Dictionary) -> Dictionary:
	var team_stats: Dictionary = _build_team_stats_from_tracker(tracker)
	var team0: Dictionary = team_stats.get("team_0", {}) as Dictionary
	var team1: Dictionary = team_stats.get("team_1", {}) as Dictionary
	return {
		"team_0_alive_units": int(team0.get("alive_units", 0)),
		"team_1_alive_units": int(team1.get("alive_units", 0))
	}

func _collect_team_units(battle: Node, team_id: int, active_only: bool = true) -> Array:
	var out: Array = []
	for child in _collect_units_from_battle(battle):
		if child == null or not is_instance_valid(child):
			continue
		if int(child.get("team_id")) != team_id:
			continue
		if active_only:
			if bool(child.get("dead")):
				continue
		out.append(child)
	return out

func _assign_demo_personalities(battle: Node, match_index: int) -> void:
	var trait_count: int = GOLD_TRAIT_IDS.size()
	if trait_count <= 0:
		return
	for team_id in [0, 1]:
		var team_units: Array = _collect_team_units(battle, team_id, true)
		for idx in range(team_units.size()):
			var unit = team_units[idx]
			if unit == null or not is_instance_valid(unit):
				continue
			if _disable_all_traits:
				_apply_unit_personality_slots(unit, "", 0, "", 0, "", 0)
				continue
			if not _single_trait_id.is_empty():
				_apply_unit_personality_slots(unit, _single_trait_id, _single_trait_level, "", 0, "", 0)
				continue
			var base: int = _personality_base_index(match_index, team_id, idx, trait_count)
			var main_trait: String = GOLD_TRAIT_IDS[base]
			var vice_trait_1: String = GOLD_TRAIT_IDS[(base + 5) % trait_count]
			var vice_trait_2: String = GOLD_TRAIT_IDS[(base + 11) % trait_count]
			_apply_unit_personality_slots(unit, main_trait, 2, vice_trait_1, 1, vice_trait_2, 1)

func _apply_unit_personality_slots(unit, main_id: String, main_lv: int, vice_1_id: String, vice_1_lv: int, vice_2_id: String, vice_2_lv: int) -> void:
	var main_trait: String = _normalize_trait_id(main_id)
	var vice_trait_1: String = _normalize_trait_id(vice_1_id)
	var vice_trait_2: String = _normalize_trait_id(vice_2_id)
	var lv_main: int = maxi(0, main_lv)
	var lv_1: int = maxi(0, vice_1_lv)
	var lv_2: int = maxi(0, vice_2_lv)
	unit.set("main_battle_personality_trait_id", main_trait)
	unit.set("vice_1_battle_personality_trait_id", vice_trait_1)
	unit.set("vice_2_battle_personality_trait_id", vice_trait_2)
	unit.set("main_battle_personality_level", lv_main)
	unit.set("vice_1_battle_personality_level", lv_1)
	unit.set("vice_2_battle_personality_level", lv_2)
	unit.set("main_battle_personality", ("%s Lv%d" % [main_trait, lv_main]) if not main_trait.is_empty() and lv_main > 0 else "无")
	unit.set("vice_1_battle_personality", ("%s Lv%d" % [vice_trait_1, lv_1]) if not vice_trait_1.is_empty() and lv_1 > 0 else "无")
	unit.set("vice_2_battle_personality", ("%s Lv%d" % [vice_trait_2, lv_2]) if not vice_trait_2.is_empty() and lv_2 > 0 else "无")
	if unit.has_method("_clear_personality_event_runtime_state"):
		unit.call("_clear_personality_event_runtime_state")

func _personality_base_index(match_index: int, team_id: int, slot_index: int, trait_count: int) -> int:
	if trait_count <= 0:
		return 0
	if _symmetric_enabled:
		var base_symmetric: int = (match_index * 19 + slot_index * 3) % trait_count
		if base_symmetric < 0:
			base_symmetric += trait_count
		return base_symmetric
	var base: int = (match_index * 19 + team_id * 7 + slot_index * 3) % trait_count
	if base < 0:
		base += trait_count
	return base

func _accumulate_debug_key_map(dst: Dictionary, src_any: Variant) -> void:
	if not (src_any is Dictionary):
		return
	var src: Dictionary = src_any as Dictionary
	for key_any in src.keys():
		var key: String = str(key_any).strip_edges().to_lower()
		if key.is_empty():
			continue
		dst[key] = int(dst.get(key, 0)) + maxi(0, int(src.get(key_any, 0)))

func _build_match_row(match_tracker: Dictionary, match_index: int, pair_index: int, mirror_leg: bool, seed_value: int, sim_elapsed: float, frame_count: int, timeout: bool) -> Dictionary:
	var all_team_stats: Dictionary = _build_team_stats_from_tracker(match_tracker)
	var team0: Dictionary = all_team_stats.get("team_0", {}) as Dictionary
	var team1: Dictionary = all_team_stats.get("team_1", {}) as Dictionary
	var winner: String = "draw"
	if int(team0.get("alive_units", 0)) > 0 and int(team1.get("alive_units", 0)) <= 0:
		winner = "team_0"
	elif int(team1.get("alive_units", 0)) > 0 and int(team0.get("alive_units", 0)) <= 0:
		winner = "team_1"
	elif timeout:
		var team0_alive_troops: int = int(team0.get("alive_troops", 0))
		var team1_alive_troops: int = int(team1.get("alive_troops", 0))
		if team0_alive_troops > team1_alive_troops:
			winner = "team_0_timeout"
		elif team1_alive_troops > team0_alive_troops:
			winner = "team_1_timeout"
		else:
			winner = "draw_timeout"
	var team0_initial_troops: int = int(team0.get("initial_troops", 0))
	var team1_initial_troops: int = int(team1.get("initial_troops", 0))
	var team0_alive_troops_2: int = int(team0.get("alive_troops", 0))
	var team1_alive_troops_2: int = int(team1.get("alive_troops", 0))
	return {
		"match_index": match_index,
		"pair_index": pair_index,
		"mirror_leg": mirror_leg,
		"seed": seed_value,
		"winner": winner,
		"timeout": timeout,
		"sim_elapsed_sec": sim_elapsed,
		"frame_count": frame_count,
		"team0_total_units": int(team0.get("total_units", 0)),
		"team1_total_units": int(team1.get("total_units", 0)),
		"team0_alive_units": int(team0.get("alive_units", 0)),
		"team1_alive_units": int(team1.get("alive_units", 0)),
		"team0_dead_units": int(team0.get("dead_units", 0)),
		"team1_dead_units": int(team1.get("dead_units", 0)),
		"team0_initial_troops": team0_initial_troops,
		"team1_initial_troops": team1_initial_troops,
		"team0_alive_troops": team0_alive_troops_2,
		"team1_alive_troops": team1_alive_troops_2,
		"team0_inflicted_troops": maxi(0, team1_initial_troops - team1_alive_troops_2),
		"team1_inflicted_troops": maxi(0, team0_initial_troops - team0_alive_troops_2),
		"team0_personality_trigger_total": int(team0.get("trigger_total", 0)),
		"team1_personality_trigger_total": int(team1.get("trigger_total", 0)),
		"team0_personality_blocked_total": int(team0.get("blocked_total", 0)),
		"team1_personality_blocked_total": int(team1.get("blocked_total", 0)),
		"team0_personality_forced_total": int(team0.get("forced_total", 0)),
		"team1_personality_forced_total": int(team1.get("forced_total", 0))
	}

func _build_trait_rows(match_tracker: Dictionary, match_index: int, pair_index: int, mirror_leg: bool, seed_value: int, winner: String, timeout: bool) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var all_team_stats: Dictionary = _build_team_stats_from_tracker(match_tracker)
	for team_id in [0, 1]:
		var team_key: String = "team_%d" % team_id
		var stats: Dictionary = all_team_stats.get(team_key, {}) as Dictionary
		var trigger_map: Dictionary = stats.get("trigger_by_key", {}) as Dictionary
		var blocked_map: Dictionary = stats.get("blocked_by_key", {}) as Dictionary
		var forced_map: Dictionary = stats.get("forced_by_key", {}) as Dictionary
		var all_keys: Dictionary = {}
		for k_any in trigger_map.keys():
			all_keys[str(k_any)] = true
		for k_any in blocked_map.keys():
			all_keys[str(k_any)] = true
		for k_any in forced_map.keys():
			all_keys[str(k_any)] = true
		for key_any in all_keys.keys():
			var key: String = str(key_any)
			rows.append({
				"match_index": match_index,
				"pair_index": pair_index,
				"mirror_leg": mirror_leg,
				"seed": seed_value,
				"team": "team_%d" % team_id,
				"winner": winner,
				"timeout": timeout,
				"trait_key": key,
				"trigger_count": int(trigger_map.get(key, 0)),
				"blocked_count": int(blocked_map.get(key, 0)),
				"forced_count": int(forced_map.get(key, 0))
			})
	return rows

func _write_match_csv(abs_path: String, rows: Array) -> void:
	var headers: PackedStringArray = PackedStringArray([
		"match_index",
		"pair_index",
		"mirror_leg",
		"seed",
		"winner",
		"timeout",
		"sim_elapsed_sec",
		"frame_count",
		"team0_total_units",
		"team1_total_units",
		"team0_alive_units",
		"team1_alive_units",
		"team0_dead_units",
		"team1_dead_units",
		"team0_initial_troops",
		"team1_initial_troops",
		"team0_alive_troops",
		"team1_alive_troops",
		"team0_inflicted_troops",
		"team1_inflicted_troops",
		"team0_personality_trigger_total",
		"team1_personality_trigger_total",
		"team0_personality_blocked_total",
		"team1_personality_blocked_total",
		"team0_personality_forced_total",
		"team1_personality_forced_total"
	])
	_write_csv(abs_path, headers, rows)

func _write_trait_csv(abs_path: String, rows: Array) -> void:
	var headers: PackedStringArray = PackedStringArray([
		"match_index",
		"pair_index",
		"mirror_leg",
		"seed",
		"team",
		"winner",
		"timeout",
		"trait_key",
		"trigger_count",
		"blocked_count",
		"forced_count"
	])
	_write_csv(abs_path, headers, rows)

func _write_csv(abs_path: String, headers: PackedStringArray, rows: Array) -> void:
	var file: FileAccess = FileAccess.open(abs_path, FileAccess.WRITE)
	if file == null:
		push_error("open csv failed: %s" % abs_path)
		return
	file.store_line(_csv_join(headers))
	for row_any in rows:
		var row: Dictionary = row_any as Dictionary if row_any is Dictionary else {}
		var values: PackedStringArray = PackedStringArray()
		for h in headers:
			values.append(_csv_escape(str(row.get(h, ""))))
		file.store_line(_csv_join(values))
	file.flush()
	file.close()

func _csv_join(values: PackedStringArray) -> String:
	return ",".join(values)

func _csv_escape(raw: String) -> String:
	var text: String = raw
	var needs_quote: bool = text.find(",") >= 0 or text.find("\"") >= 0 or text.find("\n") >= 0 or text.find("\r") >= 0
	if text.find("\"") >= 0:
		text = text.replace("\"", "\"\"")
	if needs_quote:
		return "\"" + text + "\""
	return text

func _print_summary(rows: Array, match_csv_abs: String, trait_csv_abs: String) -> void:
	var team0_win: int = 0
	var team1_win: int = 0
	var draw: int = 0
	var timeout_count: int = 0
	var avg_time: float = 0.0
	for row_any in rows:
		var row: Dictionary = row_any as Dictionary if row_any is Dictionary else {}
		var winner: String = str(row.get("winner", "draw"))
		if winner.begins_with("team_0"):
			team0_win += 1
		elif winner.begins_with("team_1"):
			team1_win += 1
		else:
			draw += 1
		if bool(row.get("timeout", false)):
			timeout_count += 1
		avg_time += float(row.get("sim_elapsed_sec", 0.0))
	if not rows.is_empty():
		avg_time /= float(rows.size())
	print("--- personality batch sim summary ---")
	print("matches=%d team0_win=%d team1_win=%d draw=%d timeout=%d avg_sim_sec=%.2f" % [rows.size(), team0_win, team1_win, draw, timeout_count, avg_time])
	print("match_csv=%s" % match_csv_abs)
	print("trait_csv=%s" % trait_csv_abs)
