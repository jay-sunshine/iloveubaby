extends SceneTree

const DEFAULT_SCENE_PATH := "res://scenes/battle_demo.tscn"
const DEFAULT_MATCH_COUNT := 10
const DEFAULT_MAX_SIM_SEC := 240.0
const DEFAULT_TIME_SCALE := 8.0
const DEFAULT_SEED_START := 20260318
const DEFAULT_OUTPUT_DIR := "tmp/reports"
const DEFAULT_OUTPUT_PREFIX := "battle_duration"
const DEFAULT_UNITS_PER_TEAM := 1
const DEFAULT_SOLDIERS_PER_UNIT := 5000
const DEFAULT_TEAM_SPACING_X := 12.0
const DEFAULT_TEAM_FRONT_OFFSET_Z := 6.0
const DEFAULT_ROLE := "infantry"
const DEFAULT_WEATHER_STATE := "sunny"
const DEFAULT_DAY_PHASE := "day"

var _scene_path: String = DEFAULT_SCENE_PATH
var _match_count: int = DEFAULT_MATCH_COUNT
var _max_sim_sec: float = DEFAULT_MAX_SIM_SEC
var _time_scale: float = DEFAULT_TIME_SCALE
var _seed_start: int = DEFAULT_SEED_START
var _output_dir: String = DEFAULT_OUTPUT_DIR
var _output_prefix: String = DEFAULT_OUTPUT_PREFIX
var _units_per_team: int = DEFAULT_UNITS_PER_TEAM
var _soldiers_per_unit: int = DEFAULT_SOLDIERS_PER_UNIT
var _team_spacing_x: float = DEFAULT_TEAM_SPACING_X
var _team_front_offset_z: float = DEFAULT_TEAM_FRONT_OFFSET_Z
var _team_a_roles: PackedStringArray = PackedStringArray([DEFAULT_ROLE])
var _team_b_roles: PackedStringArray = PackedStringArray([DEFAULT_ROLE])
var _symmetric_roles: bool = true
var _weather_state: String = DEFAULT_WEATHER_STATE
var _weather_day_phase: String = DEFAULT_DAY_PHASE
var _disable_personality: bool = true
var _auto_release_enabled: bool = true
var _force_spawn_template: bool = true
var _reissue_order_interval_sim_sec: float = 10.0
var _unit_attack_damage_override: float = -1.0
var _unit_max_hp_override: float = -1.0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_parse_args()
	var output_paths: Dictionary = _prepare_output_paths()
	var match_csv_abs: String = str(output_paths.get("match_csv_abs", "")).strip_edges()
	var summary_json_abs: String = str(output_paths.get("summary_json_abs", "")).strip_edges()
	if match_csv_abs.is_empty() or summary_json_abs.is_empty():
		push_error("output paths resolve failed")
		Engine.time_scale = 1.0
		quit(1)
		return

	var scene_res: Resource = load(_scene_path)
	if not (scene_res is PackedScene):
		push_error("scene load failed: %s" % _scene_path)
		Engine.time_scale = 1.0
		quit(1)
		return
	var packed_scene: PackedScene = scene_res as PackedScene

	var rows: Array[Dictionary] = []
	var total: int = maxi(1, _match_count)
	for i in range(total):
		var match_index: int = i + 1
		var seed_value: int = _seed_start + i
		var row: Dictionary = await _run_single_match(packed_scene, match_index, seed_value)
		rows.append(row)
		print(
			"match ",
			match_index,
			"/",
			total,
			" winner=",
			str(row.get("winner", "draw")),
			" sim_sec=",
			str(snappedf(float(row.get("sim_elapsed_sec", 0.0)), 0.01)),
			" timeout=",
			str(row.get("timeout", false))
		)

	_write_match_csv(match_csv_abs, rows)
	var summary: Dictionary = _build_summary(rows)
	_write_summary_json(summary_json_abs, summary)
	_print_summary(summary, match_csv_abs, summary_json_abs)

	Engine.time_scale = 1.0
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
		elif text.begins_with("--units_per_team="):
			_units_per_team = maxi(1, int(text.trim_prefix("--units_per_team=").strip_edges().to_int()))
		elif text.begins_with("--soldiers_per_unit="):
			_soldiers_per_unit = maxi(1, int(text.trim_prefix("--soldiers_per_unit=").strip_edges().to_int()))
		elif text.begins_with("--team_spacing_x="):
			_team_spacing_x = maxf(4.0, float(text.trim_prefix("--team_spacing_x=").strip_edges().to_float()))
		elif text.begins_with("--team_front_offset_z="):
			_team_front_offset_z = maxf(2.0, absf(float(text.trim_prefix("--team_front_offset_z=").strip_edges().to_float())))
		elif text.begins_with("--role="):
			var role_id: String = _normalize_role_id(text.trim_prefix("--role=").strip_edges())
			if not role_id.is_empty():
				_team_a_roles = PackedStringArray([role_id])
				_team_b_roles = PackedStringArray([role_id])
		elif text.begins_with("--team_a_roles="):
			_team_a_roles = _parse_role_array(text.trim_prefix("--team_a_roles=").strip_edges(), PackedStringArray([DEFAULT_ROLE]))
		elif text.begins_with("--team_b_roles="):
			_team_b_roles = _parse_role_array(text.trim_prefix("--team_b_roles=").strip_edges(), PackedStringArray([DEFAULT_ROLE]))
		elif text.begins_with("--symmetric="):
			_symmetric_roles = _parse_bool_arg(text.trim_prefix("--symmetric=").strip_edges())
		elif text == "--symmetric":
			_symmetric_roles = true
		elif text == "--no_symmetric":
			_symmetric_roles = false
		elif text.begins_with("--weather_state="):
			var weather: String = text.trim_prefix("--weather_state=").strip_edges().to_lower()
			if not weather.is_empty():
				_weather_state = weather
		elif text.begins_with("--day_phase="):
			var phase: String = text.trim_prefix("--day_phase=").strip_edges().to_lower()
			if not phase.is_empty():
				_weather_day_phase = _normalize_day_phase(phase)
		elif text.begins_with("--disable_personality="):
			_disable_personality = _parse_bool_arg(text.trim_prefix("--disable_personality=").strip_edges())
		elif text == "--disable_personality":
			_disable_personality = true
		elif text == "--enable_personality":
			_disable_personality = false
		elif text.begins_with("--auto_release_enabled="):
			_auto_release_enabled = _parse_bool_arg(text.trim_prefix("--auto_release_enabled=").strip_edges())
		elif text == "--auto_release_enabled":
			_auto_release_enabled = true
		elif text == "--no_auto_release":
			_auto_release_enabled = false
		elif text.begins_with("--force_spawn_template="):
			_force_spawn_template = _parse_bool_arg(text.trim_prefix("--force_spawn_template=").strip_edges())
		elif text == "--force_spawn_template":
			_force_spawn_template = true
		elif text == "--no_force_spawn_template":
			_force_spawn_template = false
		elif text.begins_with("--reissue_order_interval_sim_sec="):
			_reissue_order_interval_sim_sec = maxf(0.0, float(text.trim_prefix("--reissue_order_interval_sim_sec=").strip_edges().to_float()))
		elif text.begins_with("--unit_attack_damage_override="):
			_unit_attack_damage_override = float(text.trim_prefix("--unit_attack_damage_override=").strip_edges().to_float())
		elif text.begins_with("--unit_max_hp_override="):
			_unit_max_hp_override = float(text.trim_prefix("--unit_max_hp_override=").strip_edges().to_float())

	if _output_prefix.is_empty():
		_output_prefix = DEFAULT_OUTPUT_PREFIX
	if _symmetric_roles:
		_team_b_roles = _team_a_roles

func _parse_bool_arg(raw: String) -> bool:
	var text: String = raw.strip_edges().to_lower()
	return text == "1" or text == "true" or text == "yes" or text == "y" or text == "on"

func _role_list_contains_siege(roles: PackedStringArray) -> bool:
	for role_any in roles:
		var role_id: String = _normalize_role_id(str(role_any))
		if role_id == "siege" or role_id.begins_with("siege_") or role_id.begins_with("siege:") or role_id.begins_with("siege-"):
			return true
	return false

func _should_enable_facility_setup() -> bool:
	return _role_list_contains_siege(_team_a_roles) or _role_list_contains_siege(_team_b_roles)

func _normalize_role_id(raw: String) -> String:
	var role: String = raw.strip_edges().to_lower()
	return role

func _normalize_day_phase(raw: String) -> String:
	var phase: String = raw.strip_edges().to_lower()
	if phase == "night" or phase == "evening" or phase == "pm" or phase == "dark":
		return "night"
	return "day"

func _parse_role_array(raw: String, fallback: PackedStringArray) -> PackedStringArray:
	var out := PackedStringArray()
	for token_any in raw.split(","):
		var role: String = _normalize_role_id(str(token_any))
		if role.is_empty():
			continue
		out.append(role)
	return fallback if out.is_empty() else out

func _expand_roles_to_units(roles: PackedStringArray, count: int) -> PackedStringArray:
	var out := PackedStringArray()
	var safe_count: int = maxi(1, count)
	var src: PackedStringArray = roles
	if src.is_empty():
		src = PackedStringArray([DEFAULT_ROLE])
	for i in range(safe_count):
		out.append(str(src[i % src.size()]))
	return out

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
	return {
		"match_csv_abs": out_dir_abs.path_join("%s_matches_%s.csv" % [_output_prefix, stamp]),
		"summary_json_abs": out_dir_abs.path_join("%s_summary_%s.json" % [_output_prefix, stamp])
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

func _run_single_match(packed_scene: PackedScene, match_index: int, seed_value: int) -> Dictionary:
	seed(seed_value)
	Engine.time_scale = _time_scale

	var battle: Node = packed_scene.instantiate()
	if battle == null:
		return _make_error_row(match_index, seed_value, "error_instantiate")

	_apply_pre_ready_tuning(battle)
	get_root().add_child(battle)
	await process_frame
	await process_frame
	_apply_post_ready_overrides_and_respawn(battle)
	await process_frame
	await _wait_for_units_ready(battle, _units_per_team * 2, 120)

	_apply_unit_runtime_neutralization(battle)
	if _force_spawn_template:
		_apply_spawn_template(battle)
		await process_frame
	if _auto_release_enabled:
		_enable_auto_controls(battle)
	else:
		_disable_auto_controls(battle)
	_issue_opening_orders(battle)

	var initial_stats: Dictionary = _collect_troop_stats(battle)
	var stats: Dictionary = initial_stats.duplicate(true)
	var sim_elapsed: float = 0.0
	var frame_count: int = 0
	var timeout: bool = false
	var objective_winner_team: int = -1
	var objective_message: String = ""
	var order_reissue_left: float = maxf(0.0, _reissue_order_interval_sim_sec)

	var pps: float = float(Engine.physics_ticks_per_second)
	var sim_sec_per_frame: float = _time_scale / maxf(1.0, pps)
	var max_frames: int = maxi(1, int(ceil(_max_sim_sec / maxf(0.0001, sim_sec_per_frame))))
	while frame_count < max_frames:
		await physics_frame
		frame_count += 1
		sim_elapsed += sim_sec_per_frame
		if _reissue_order_interval_sim_sec > 0.001:
			order_reissue_left -= sim_sec_per_frame
			if order_reissue_left <= 0.0:
				_issue_opening_orders(battle)
				order_reissue_left = maxf(0.001, _reissue_order_interval_sim_sec)
		stats = _collect_troop_stats(battle)
		var objective_team: int = _collect_demo_objective_winner_team(battle)
		if objective_team >= 0:
			objective_winner_team = objective_team
			break
		if int(stats.get("team_0_alive_units", 0)) <= 0 or int(stats.get("team_1_alive_units", 0)) <= 0:
			break
	if frame_count >= max_frames:
		timeout = true

	stats = _collect_troop_stats(battle)
	var siege_snapshot: Dictionary = _collect_demo_siege_snapshot(battle)
	if objective_winner_team < 0:
		objective_winner_team = int(siege_snapshot.get("objective_winner_team", objective_winner_team))
	objective_message = str(siege_snapshot.get("objective_message", "")).strip_edges()
	var facility_damage_any: Variant = siege_snapshot.get("facility_damage_by_variant", {})
	var facility_damage_by_variant: Dictionary = (facility_damage_any as Dictionary) if facility_damage_any is Dictionary else {}
	var proc_counts_any: Variant = siege_snapshot.get("proc_counts", {})
	var proc_counts: Dictionary = (proc_counts_any as Dictionary) if proc_counts_any is Dictionary else {}
	var winner: String = _resolve_winner(stats, objective_winner_team)
	var team0_initial: int = maxi(1, int(initial_stats.get("team_0_initial_troops", _soldiers_per_unit * _units_per_team)))
	var team1_initial: int = maxi(1, int(initial_stats.get("team_1_initial_troops", _soldiers_per_unit * _units_per_team)))
	var team0_alive_troops: int = maxi(0, int(stats.get("team_0_alive_troops", 0)))
	var team1_alive_troops: int = maxi(0, int(stats.get("team_1_alive_troops", 0)))

	battle.queue_free()
	await process_frame

	return {
		"match_index": match_index,
		"seed": seed_value,
		"winner": winner,
		"timeout": timeout,
		"sim_elapsed_sec": sim_elapsed,
		"frame_count": frame_count,
		"team0_alive_units": int(stats.get("team_0_alive_units", 0)),
		"team1_alive_units": int(stats.get("team_1_alive_units", 0)),
		"team0_initial_troops": team0_initial,
		"team1_initial_troops": team1_initial,
		"team0_alive_troops": team0_alive_troops,
		"team1_alive_troops": team1_alive_troops,
		"team0_loss_ratio": clampf(1.0 - float(team0_alive_troops) / float(team0_initial), 0.0, 1.0),
		"team1_loss_ratio": clampf(1.0 - float(team1_alive_troops) / float(team1_initial), 0.0, 1.0),
		"objective_winner_team": objective_winner_team,
		"objective_message": objective_message,
		"ram_facility_damage": float(facility_damage_by_variant.get("ram", 0.0)),
		"ladder_facility_damage": float(facility_damage_by_variant.get("ladder", 0.0)),
		"catapult_facility_damage": float(facility_damage_by_variant.get("catapult", 0.0)),
		"ram_proc_on_hit_burn": int(proc_counts.get("ram:on_hit_burn", 0)),
		"ram_proc_facility_burn": int(proc_counts.get("ram:facility_burn", 0)),
		"ram_proc_skill": int(proc_counts.get("ram:skill_ram", 0)),
		"ladder_proc_on_hit_morale": int(proc_counts.get("ladder:on_hit_morale", 0)),
		"ladder_proc_facility_morale": int(proc_counts.get("ladder:facility_morale", 0)),
		"ladder_proc_skill": int(proc_counts.get("ladder:skill_ladder", 0)),
		"catapult_proc_on_hit_splash": int(proc_counts.get("catapult:on_hit_splash", 0)),
		"catapult_proc_facility_splash": int(proc_counts.get("catapult:facility_splash", 0)),
		"catapult_proc_skill": int(proc_counts.get("catapult:skill_catapult", 0))
	}

func _make_error_row(match_index: int, seed_value: int, winner: String) -> Dictionary:
	return {
		"match_index": match_index,
		"seed": seed_value,
		"winner": winner,
		"timeout": true,
		"sim_elapsed_sec": 0.0,
		"frame_count": 0,
		"team0_alive_units": 0,
		"team1_alive_units": 0,
		"team0_initial_troops": 0,
		"team1_initial_troops": 0,
		"team0_alive_troops": 0,
		"team1_alive_troops": 0,
		"team0_loss_ratio": 1.0,
		"team1_loss_ratio": 1.0,
		"objective_winner_team": -1,
		"objective_message": "",
		"ram_facility_damage": 0.0,
		"ladder_facility_damage": 0.0,
		"catapult_facility_damage": 0.0,
		"ram_proc_on_hit_burn": 0,
		"ram_proc_facility_burn": 0,
		"ram_proc_skill": 0,
		"ladder_proc_on_hit_morale": 0,
		"ladder_proc_facility_morale": 0,
		"ladder_proc_skill": 0,
		"catapult_proc_on_hit_splash": 0,
		"catapult_proc_facility_splash": 0,
		"catapult_proc_skill": 0
	}

func _apply_pre_ready_tuning(battle: Node) -> void:
	var facility_setup_enabled: bool = _should_enable_facility_setup()
	battle.set("randomize_on_ready", false)
	battle.set("embedded_on_strategy_map", false)
	battle.set("auto_spawn_demo_units", true)
	battle.set("demo_facility_test_setup_enabled", facility_setup_enabled)
	battle.set("demo_siege_ai_apply_to_player_team", facility_setup_enabled)
	battle.set("demo_siege_ai_only_facility_mode", facility_setup_enabled)
	battle.set("enemy_auto_engage_enabled", true)
	battle.set("auto_engage_enabled", true)
	battle.set("auto_release_enabled", _auto_release_enabled)
	battle.set("show_unit_tags", false)
	battle.set("hover_panel_enabled", false)
	battle.set("tactic_vfx_enabled", false)
	battle.set("debug_allow_control_all_units_for_testing", true)
	if battle.has_method("setup_weather_context"):
		battle.call("setup_weather_context", {
			"weather": {
				"state": _weather_state,
				"day_phase": _weather_day_phase,
				"wind_dir": [1.0, 0.0],
				"wind_strength": 0.0
			}
		})

func _apply_post_ready_overrides_and_respawn(battle: Node) -> void:
	var facility_setup_enabled: bool = _should_enable_facility_setup()
	var team_a_roles: PackedStringArray = _expand_roles_to_units(_team_a_roles, _units_per_team)
	var team_b_src: PackedStringArray = _team_a_roles if _symmetric_roles else _team_b_roles
	var team_b_roles: PackedStringArray = _expand_roles_to_units(team_b_src, _units_per_team)
	if facility_setup_enabled:
		if battle.has_method("set_strategy_map_view"):
			battle.call("set_strategy_map_view", null)
		battle.set("embedded_on_strategy_map", false)
	battle.set("units_per_team", _units_per_team)
	battle.set("soldiers_per_unit", _soldiers_per_unit)
	battle.set("team_spacing_x", _team_spacing_x)
	battle.set("team_front_offset_z", _team_front_offset_z)
	if _unit_max_hp_override > 0.0:
		battle.set("unit_base_max_hp", maxf(1.0, _unit_max_hp_override))
	if _unit_attack_damage_override > 0.0:
		battle.set("unit_base_attack_damage", maxf(0.1, _unit_attack_damage_override))
	battle.set("team_a_unit_roles", team_a_roles)
	battle.set("team_b_unit_roles", team_b_roles)
	if battle.has_method("_spawn_demo_units"):
		battle.call("_spawn_demo_units")

func _wait_for_units_ready(battle: Node, expected_total: int, max_frames: int) -> void:
	var target: int = maxi(2, expected_total)
	var wait_frames: int = maxi(1, max_frames)
	for _i in range(wait_frames):
		var stats: Dictionary = _collect_troop_stats(battle)
		var unit_count: int = int(stats.get("total_units", 0))
		if unit_count >= target:
			return
		await process_frame

func _collect_troop_stats(battle: Node) -> Dictionary:
	var team0_alive_units: int = 0
	var team1_alive_units: int = 0
	var team0_alive_troops: int = 0
	var team1_alive_troops: int = 0
	var team0_initial_troops: int = 0
	var team1_initial_troops: int = 0
	var total_units: int = 0
	var units_any: Variant = battle.get("units")
	if units_any is Array:
		for unit_any in (units_any as Array):
			if unit_any == null or not is_instance_valid(unit_any):
				continue
			var team_id: int = int(unit_any.get("team_id"))
			if team_id != 0 and team_id != 1:
				continue
			total_units += 1
			var initial_troops: int = maxi(0, int(unit_any.get("troop_count")))
			var alive_troops: int = initial_troops
			if unit_any.has_method("get_alive_troop_count"):
				alive_troops = maxi(0, int(unit_any.call("get_alive_troop_count")))
			var is_dead: bool = bool(unit_any.get("dead"))
			if team_id == 0:
				team0_initial_troops += initial_troops
				team0_alive_troops += alive_troops
				if not is_dead and alive_troops > 0:
					team0_alive_units += 1
			else:
				team1_initial_troops += initial_troops
				team1_alive_troops += alive_troops
				if not is_dead and alive_troops > 0:
					team1_alive_units += 1
	return {
		"total_units": total_units,
		"team_0_alive_units": team0_alive_units,
		"team_1_alive_units": team1_alive_units,
		"team_0_alive_troops": team0_alive_troops,
		"team_1_alive_troops": team1_alive_troops,
		"team_0_initial_troops": team0_initial_troops,
		"team_1_initial_troops": team1_initial_troops
	}

func _collect_demo_objective_winner_team(battle: Node) -> int:
	if battle == null or not is_instance_valid(battle):
		return -1
	if battle.has_method("get_demo_objective_winner_team"):
		return int(battle.call("get_demo_objective_winner_team"))
	if battle.has_method("has_demo_objective_result") and bool(battle.call("has_demo_objective_result")):
		var snapshot: Dictionary = _collect_demo_siege_snapshot(battle)
		return int(snapshot.get("objective_winner_team", -1))
	return -1

func _collect_demo_siege_snapshot(battle: Node) -> Dictionary:
	if battle == null or not is_instance_valid(battle):
		return {}
	if not battle.has_method("get_demo_siege_debug_snapshot"):
		return {}
	var snapshot_any: Variant = battle.call("get_demo_siege_debug_snapshot")
	if snapshot_any is Dictionary:
		return (snapshot_any as Dictionary).duplicate(true)
	return {}

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

func _apply_spawn_template(battle: Node) -> void:
	var center: Vector3 = Vector3.ZERO
	var center_any: Variant = battle.get("spawn_center")
	if center_any is Vector3:
		center = center_any as Vector3
	var team0_units: Array = _collect_team_units_sorted_x(battle, 0)
	var team1_units: Array = _collect_team_units_sorted_x(battle, 1)
	_place_team_units_with_template(battle, team0_units, center, _team_spacing_x, _team_front_offset_z)
	_place_team_units_with_template(battle, team1_units, center, _team_spacing_x, -_team_front_offset_z)

func _place_team_units_with_template(battle: Node, units_arr: Array, center: Vector3, spacing: float, z_offset: float) -> void:
	var count: int = units_arr.size()
	if count <= 0:
		return
	var safe_spacing: float = maxf(3.0, spacing)
	for idx in range(count):
		var unit = units_arr[idx]
		if not (unit is Node3D):
			continue
		var x: float = (float(idx) - float(count - 1) * 0.5) * safe_spacing
		var pos: Vector3 = Vector3(center.x + x, center.y, center.z + z_offset)
		if battle.has_method("_terrain_height_at_world"):
			pos.y = float(battle.call("_terrain_height_at_world", pos))
		var node_3d: Node3D = unit as Node3D
		node_3d.global_position = pos
		var euler: Vector3 = node_3d.rotation_degrees
		euler.y = 0.0 if z_offset >= 0.0 else 180.0
		node_3d.rotation_degrees = euler

func _apply_unit_runtime_neutralization(battle: Node) -> void:
	var units_any: Variant = battle.get("units")
	if not (units_any is Array):
		return
	for unit_any in (units_any as Array):
		if unit_any == null or not is_instance_valid(unit_any):
			continue
		if not _disable_personality:
			continue
		unit_any.set("personality_event_framework_enabled", false)
		unit_any.set("main_battle_personality_trait_id", "")
		unit_any.set("vice_1_battle_personality_trait_id", "")
		unit_any.set("vice_2_battle_personality_trait_id", "")
		unit_any.set("main_battle_personality_level", 0)
		unit_any.set("vice_1_battle_personality_level", 0)
		unit_any.set("vice_2_battle_personality_level", 0)
		unit_any.set("personality_attack_bonus_pct", 0.0)
		unit_any.set("personality_defense_bonus_pct", 0.0)
		unit_any.set("personality_speed_bonus_pct", 0.0)
		unit_any.set("personality_spirit_bonus_flat", 0.0)

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

func _disable_auto_controls(battle: Node) -> void:
	battle.set("unit_skill_auto_mode", {})
	battle.set("unit_famous_auto_mode", {})

func _issue_opening_orders(battle: Node) -> void:
	var units_any: Variant = battle.get("units")
	if not (units_any is Array):
		return
	var facility_setup_enabled: bool = _should_enable_facility_setup()
	for unit_any in (units_any as Array):
		if unit_any == null or not is_instance_valid(unit_any):
			continue
		if bool(unit_any.get("dead")):
			continue
		if facility_setup_enabled:
			var role_id: String = _normalize_role_id(str(unit_any.get("combat_role_id")))
			if role_id == "siege":
				continue
		var enemy: Variant = battle.call("get_closest_enemy", unit_any) if battle.has_method("get_closest_enemy") else null
		if enemy == null or not is_instance_valid(enemy):
			continue
		if unit_any.has_method("issue_attack_order"):
			unit_any.call("issue_attack_order", enemy)

func _resolve_winner(stats: Dictionary, objective_winner_team: int = -1) -> String:
	if objective_winner_team == 0:
		return "team_0_by_objective"
	if objective_winner_team == 1:
		return "team_1_by_objective"
	var team0_alive_units: int = int(stats.get("team_0_alive_units", 0))
	var team1_alive_units: int = int(stats.get("team_1_alive_units", 0))
	var team0_alive_troops: int = int(stats.get("team_0_alive_troops", 0))
	var team1_alive_troops: int = int(stats.get("team_1_alive_troops", 0))
	if team0_alive_units <= 0 and team1_alive_units > 0:
		return "team_1"
	if team1_alive_units <= 0 and team0_alive_units > 0:
		return "team_0"
	if team0_alive_troops > team1_alive_troops:
		return "team_0_by_troops"
	if team1_alive_troops > team0_alive_troops:
		return "team_1_by_troops"
	return "draw"

func _build_summary(rows: Array[Dictionary]) -> Dictionary:
	var durations: Array[float] = []
	var timeout_count: int = 0
	var team0_win: int = 0
	var team1_win: int = 0
	var draw_count: int = 0
	for row in rows:
		durations.append(float(row.get("sim_elapsed_sec", 0.0)))
		if bool(row.get("timeout", false)):
			timeout_count += 1
		var winner: String = str(row.get("winner", "draw"))
		if winner.begins_with("team_0"):
			team0_win += 1
		elif winner.begins_with("team_1"):
			team1_win += 1
		else:
			draw_count += 1

	var total: int = rows.size()
	var avg_sec: float = 0.0
	for sec in durations:
		avg_sec += sec
	if total > 0:
		avg_sec /= float(total)
	var sorted: Array[float] = durations.duplicate()
	sorted.sort()

	return {
		"matches": total,
		"time_scale": _time_scale,
		"max_sim_sec": _max_sim_sec,
		"units_per_team": _units_per_team,
		"soldiers_per_unit": _soldiers_per_unit,
		"team_a_roles": _team_a_roles,
		"team_b_roles": _team_a_roles if _symmetric_roles else _team_b_roles,
		"weather_state": _weather_state,
		"day_phase": _weather_day_phase,
		"disable_personality": _disable_personality,
		"auto_release_enabled": _auto_release_enabled,
		"force_spawn_template": _force_spawn_template,
		"reissue_order_interval_sim_sec": _reissue_order_interval_sim_sec,
		"unit_attack_damage_override": _unit_attack_damage_override,
		"unit_max_hp_override": _unit_max_hp_override,
		"duration_avg_sec": avg_sec,
		"duration_median_sec": _percentile(sorted, 0.5),
		"duration_p90_sec": _percentile(sorted, 0.9),
		"duration_min_sec": sorted[0] if not sorted.is_empty() else 0.0,
		"duration_max_sec": sorted[sorted.size() - 1] if not sorted.is_empty() else 0.0,
		"timeout_count": timeout_count,
		"team0_win_count": team0_win,
		"team1_win_count": team1_win,
		"draw_count": draw_count
	}

func _percentile(sorted_values: Array[float], q: float) -> float:
	if sorted_values.is_empty():
		return 0.0
	var clamped_q: float = clampf(q, 0.0, 1.0)
	var idx: int = int(ceil(float(sorted_values.size()) * clamped_q)) - 1
	idx = clampi(idx, 0, sorted_values.size() - 1)
	return float(sorted_values[idx])

func _write_match_csv(abs_path: String, rows: Array[Dictionary]) -> void:
	var headers: PackedStringArray = PackedStringArray([
		"match_index",
		"seed",
		"winner",
		"timeout",
		"sim_elapsed_sec",
		"frame_count",
		"team0_alive_units",
		"team1_alive_units",
		"team0_initial_troops",
		"team1_initial_troops",
		"team0_alive_troops",
		"team1_alive_troops",
		"team0_loss_ratio",
		"team1_loss_ratio",
		"objective_winner_team",
		"objective_message",
		"ram_facility_damage",
		"ladder_facility_damage",
		"catapult_facility_damage",
		"ram_proc_on_hit_burn",
		"ram_proc_facility_burn",
		"ram_proc_skill",
		"ladder_proc_on_hit_morale",
		"ladder_proc_facility_morale",
		"ladder_proc_skill",
		"catapult_proc_on_hit_splash",
		"catapult_proc_facility_splash",
		"catapult_proc_skill"
	])
	var file: FileAccess = FileAccess.open(abs_path, FileAccess.WRITE)
	if file == null:
		push_error("open csv failed: %s" % abs_path)
		return
	file.store_line(",".join(headers))
	for row in rows:
		var values := PackedStringArray()
		for h in headers:
			values.append(_csv_escape(str(row.get(h, ""))))
		file.store_line(",".join(values))
	file.flush()
	file.close()

func _write_summary_json(abs_path: String, summary: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(abs_path, FileAccess.WRITE)
	if file == null:
		push_error("open summary json failed: %s" % abs_path)
		return
	file.store_string(JSON.stringify(summary, "\t"))
	file.flush()
	file.close()

func _csv_escape(raw: String) -> String:
	var text: String = raw
	var needs_quote: bool = text.find(",") >= 0 or text.find("\"") >= 0 or text.find("\n") >= 0 or text.find("\r") >= 0
	if text.find("\"") >= 0:
		text = text.replace("\"", "\"\"")
	if needs_quote:
		return "\"" + text + "\""
	return text

func _print_summary(summary: Dictionary, match_csv_abs: String, summary_json_abs: String) -> void:
	print("--- battle duration summary ---")
	print(
		"matches=",
		int(summary.get("matches", 0)),
		" timeout=",
		int(summary.get("timeout_count", 0)),
		" team0_win=",
		int(summary.get("team0_win_count", 0)),
		" team1_win=",
		int(summary.get("team1_win_count", 0)),
		" draw=",
		int(summary.get("draw_count", 0))
	)
	print(
		"duration_sec avg=",
		str(snappedf(float(summary.get("duration_avg_sec", 0.0)), 0.01)),
		" median=",
		str(snappedf(float(summary.get("duration_median_sec", 0.0)), 0.01)),
		" p90=",
		str(snappedf(float(summary.get("duration_p90_sec", 0.0)), 0.01)),
		" min=",
		str(snappedf(float(summary.get("duration_min_sec", 0.0)), 0.01)),
		" max=",
		str(snappedf(float(summary.get("duration_max_sec", 0.0)), 0.01))
	)
	print("match_csv=", match_csv_abs)
	print("summary_json=", summary_json_abs)
