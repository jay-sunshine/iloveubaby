extends Node3D
class_name StrategyBootstrap

const JsonDataSource := preload("res://scripts/data/json_data_source.gd")
const GameDataRepository := preload("res://scripts/data/game_data_repository.gd")
const LogicApi := preload("res://scripts/logic/logic_api.gd")
const GameLogicFacade := preload("res://scripts/logic/game_logic_facade.gd")
const StrategyMapView := preload("res://scripts/presentation/strategy_map_view.gd")
const StrategyUILayer := preload("res://scripts/presentation/strategy_ui_layer.gd")
const PreloadManager := preload("res://scripts/engine/preload_manager.gd")
const BattlefieldController := preload("res://scripts/battlefield_controller.gd")
const BATTLE_DEMO_SCENE := preload("res://scenes/battle_demo.tscn")

const WORLD_STATE_PATH := "res://data/config/world_state.json"
const INTERNAL_AFFAIRS_PATH := "res://data/config/internal_affairs_rules.json"
const BATTLE_RULES_PATH := "res://data/config/battle_rules.json"
const GENERAL_RULES_PATH := "res://data/config/general_rules.json"
const DIPLOMACY_RULES_PATH := "res://data/config/diplomacy_rules.json"
const AI_RULES_PATH := "res://data/config/ai_rules.json"
const ENGINE_RULES_PATH := "res://data/config/engine_rules.json"
const PRESENTATION_RULES_PATH := "res://data/config/presentation_rules.json"
const REGROUP_RULES_PATH := "res://data/config/regroup_rules.json"
const FIRE_RULES_PATH := "res://data/config/fire_rules.json"
const WEATHER_SETTINGS_PATH := "res://data/config/weather_settings.json"
const OFFICER_ROSTER_PATH := "res://data/config/officer_roster_san14_like_v1.json"
const REGROUP_DEFAULT_SIEGE_CLASS_IDS := ["siege", "engine"]
const REGROUP_DEFAULT_SIEGE_DURABILITY_MAX := 20000.0

const POSITIVE_COLOR_HEX := "4FA3FF"
const NEGATIVE_COLOR_HEX := "E25B5B"
const NEUTRAL_COLOR_HEX := "D7D7D7"
const AIDE_ROLES := [
	{"id": "taishou", "label": "Governor"},
	{"id": "shicao", "label": "Market Officer"},
	{"id": "hucao", "label": "Civil Officer"},
	{"id": "junxu", "label": "Quartermaster"},
	{"id": "bingcao", "label": "Military Officer"},
	{"id": "gongcao", "label": "Works Officer"},
	{"id": "duwei", "label": "Commandant"}
]
const SUPPLY_FOG_GRANARY_KEYWORDS := ["granary", "grain_depot", "supply_depot", "ao_cang", "鏁栦粨", "绮粨", "鍐涚伯", "绮牎"]
const SUPPLY_FOG_CONVOY_KEYWORDS := ["convoy", "supply_cart", "wagon", "wood_ox", "mule", "transport", "杩愮伯", "绮溅", "鏈ㄧ墰", "娴侀┈"]
const SUPPLY_FOG_TROOP_KEYWORDS := ["field_unit", "expedition", "army", "troop", "warband", "閮ㄩ槦", "鍐涘洟", "閲庢垬", "琛屽啗", "鍏靛洟"]
const DEFAULT_TIME_WEATHER_RULES := {
	"enabled": true,
	"battle_phase_cycle": ["day", "night"],
	"battle_phase_day_ratio": 0.42,
	"day_phase_visibility_mul": {"day": 1.0, "night": 0.62},
	"weather_visibility_mul": {
		"sunny": 1.0,
		"clear": 1.0,
		"cloudy": 0.9,
		"windy": 0.93,
		"rain": 0.78,
		"storm": 0.68,
		"fog": 0.56,
		"mist": 0.6
	}
}
var _data_source: JsonDataSource
var _repo: GameDataRepository
var _api
var _logic
var _rules_by_key: Dictionary = {}
var _regroup_base_dataset_cache: Dictionary = {}

var _map_view: StrategyMapView
var _ui_layer: StrategyUILayer
var _preload_manager: PreloadManager

var _snapshot: Dictionary = {}
var _selected_building_id: String = ""

var _phase: String = "internal"
var _seconds_per_day: float = 6.0
var _battle_phase_days: float = 10.0
var _battle_phase_total_seconds: float = 60.0
var _battle_elapsed_seconds: float = 0.0
var _command_cost_city_action: float = 1.0
var _regroup_security_gain: float = 1.2
var _regroup_troop_gain_ratio: float = 0.015
var _merchant_money_gain: float = 300.0
var _max_battle_step_seconds_per_frame: float = 0.2
var _supply_fog_rules: Dictionary = {}
var _time_weather_rules: Dictionary = DEFAULT_TIME_WEATHER_RULES.duplicate(true)
var _runtime_last_day_phase: String = ""

var _save_path: String = WORLD_STATE_PATH
var _preload_paths: Array[String] = []
var _preload_progress: float = 0.0
var _status_message: String = ""
var _supply_debug_overlay_enabled: bool = false
var _battle_demo_instance: Node3D
var _battle_origin_city_id: String = ""
var _battle_demo_units_per_team: int = 6
var _battle_demo_soldiers_per_unit: int = 4200
var _battle_demo_team_spacing_x: float = 20.0
var _battle_demo_front_offset_z: float = 82.0
var _battle_demo_infantry_scale_mul: float = 4.4
var _battle_demo_cavalry_scale_mul: float = 4.0
var _battle_demo_spear_scale_mul: float = 2.0
var _battle_demo_archer_scale_mul: float = 2.0
var _battle_demo_archer_attack_range: float = 18.0
var _battle_demo_archer_attack_interval: float = 1.05
var _battle_demo_skill_cd_charge: float = 10.0
var _battle_demo_skill_cd_breakthrough: float = 14.0
var _battle_demo_skill_cd_sweep: float = 12.0
var _battle_demo_skill_spirit_cost_charge: float = 10.0
var _battle_demo_skill_spirit_cost_breakthrough: float = 14.0
var _battle_demo_skill_spirit_cost_sweep: float = 12.0
var _battle_demo_skill_will_cost_charge: float = 10.0
var _battle_demo_skill_will_cost_breakthrough: float = 14.0
var _battle_demo_skill_will_cost_sweep: float = 12.0
var _battle_demo_soldier_formation_spacing: float = 0.8
var _battle_demo_show_tag_when_near: bool = true
var _battle_demo_tag_height_offset: float = 9.2
var _battle_demo_tag_near_scale: float = 0.62
var _battle_demo_tag_far_scale: float = 0.16
var _battle_demo_show_unit_tags: bool = true
var _battle_demo_team_a_unit_roles: Array[String] = ["cavalry", "shield"]
var _battle_demo_team_b_unit_roles: Array[String] = ["spear", "archer", "strategist_s", "strategist_a", "strategist_b", "strategist_c"]
var _battle_demo_soldier_use_model_albedo_texture: bool = true
var _battle_demo_soldier_team_tint_strength: float = 0.35
var _battle_demo_siege_durability_loss_scale: float = 1.0
var _battle_demo_melee_frontline_width_mul: float = 1.3
var _battle_demo_melee_frontline_depth_mul: float = 0.85
var _battle_demo_melee_contact_distance_mul: float = 1.18
var _battle_demo_melee_contact_distance_bias: float = 0.8
var _battle_demo_melee_activity_radius_mul: float = 1.25
var _battle_demo_melee_activity_radius_visual_weight: float = 0.8
var _battle_demo_unit_player_force_chase_sec: float = 18.0
var _battle_demo_unit_player_force_chase_max_distance: float = 320.0
var _battle_demo_unit_player_force_chase_never_timeout: bool = true
var _battle_demo_unit_player_force_chase_ignore_distance: bool = true
var _battle_demo_unit_nav_goal_retry_max_attempts: int = 3
var _battle_demo_unit_nav_goal_retry_radius_step: float = 3.0
var _battle_demo_unit_nav_goal_retry_directions: int = 12
var _battle_demo_unit_nav_goal_retry_snap_distance_mul: float = 1.35
var _battle_demo_unit_morale_loss_per_10pct_troop: float = 10.0
var _battle_demo_unit_morale_stat_penalty_per_10: float = 0.05
var _battle_demo_unit_morale_zero_hp_loss_per_sec: float = 0.02
var _battle_demo_unit_rout_troop_ratio_normal: float = 0.2
var _battle_demo_unit_rout_troop_ratio_garrison: float = 0.1
var _battle_demo_unit_garrison_morale_loss_mul: float = 0.5
var _battle_demo_unit_morale_loss_countered_bonus: float = 3.0
var _battle_demo_unit_morale_loss_flanked_bonus: float = 4.0
var _battle_demo_unit_morale_loss_out_of_supply_per_sec: float = 2.2
var _battle_demo_unit_morale_loss_special_terrain_per_sec: float = 1.2
var _battle_demo_unit_morale_loss_burning_per_sec: float = 1.0
var _battle_demo_terrain_adaptation_enabled: bool = true
var _battle_demo_terrain_adaptation_interval_sec: float = 0.35
var _battle_demo_terrain_status_hold_sec: float = 0.8
var _battle_demo_role_counter_damage_matrix: Dictionary = {}
var _battle_demo_role_terrain_profiles: Dictionary = {}
var _battle_demo_height_advantage_enabled: bool = true
var _battle_demo_height_advantage_rules: Dictionary = {}
var _battle_demo_role_height_modifiers: Dictionary = {}
var _battle_demo_soft_repulsion_include_same_team: bool = true
var _battle_demo_soft_repulsion_same_team_strength: float = 2.6
var _battle_demo_soft_repulsion_enemy_strength: float = 4.6
var _battle_demo_soft_repulsion_base_padding: float = 0.55
var _battle_demo_soft_repulsion_radius_mul: float = 0.9
var _battle_demo_spear_override_model_path: String = "res://绱犳潗/寤烘ā/鍏电/qingqiangbing.glb"
var _battle_demo_spear_override_albedo_path: String = "res://绱犳潗/寤烘ā/鍏电/qingqiangbing_texture_pbr_20250901.png"
var _battle_demo_archer_override_model_path: String = "res://绱犳潗/寤烘ā/鍏电/gongbing.glb"
var _battle_demo_archer_override_albedo_path: String = "res://绱犳潗/寤烘ā/鍏电/gongbing_texture_pbr_20250901.png"
var _battle_demo_infantry_override_model_path: String = ""
var _battle_demo_infantry_override_albedo_path: String = ""
var _battle_demo_cavalry_override_model_path: String = ""
var _battle_demo_cavalry_override_albedo_path: String = ""
var _battle_demo_shield_override_model_path: String = ""
var _battle_paused: bool = false
var _battle_speed: float = 1.0
var _master_officers: Array = []
var _master_officers_by_id: Dictionary = {}

func _ready() -> void:
	_data_source = JsonDataSource.new()
	var world_state: Dictionary = _data_source.load_dictionary(WORLD_STATE_PATH)
	var master_roster_data: Dictionary = _data_source.load_dictionary(OFFICER_ROSTER_PATH)
	_set_master_officers(master_roster_data.get("officers", []))
	_rules_by_key = {
		"internal_affairs": _data_source.load_dictionary(INTERNAL_AFFAIRS_PATH),
		"battle": _data_source.load_dictionary(BATTLE_RULES_PATH),
		"general": _data_source.load_dictionary(GENERAL_RULES_PATH),
		"diplomacy": _data_source.load_dictionary(DIPLOMACY_RULES_PATH),
		"ai": _data_source.load_dictionary(AI_RULES_PATH),
		"engine": _data_source.load_dictionary(ENGINE_RULES_PATH),
		"presentation": _data_source.load_dictionary(PRESENTATION_RULES_PATH),
		"regroup": _data_source.load_dictionary(REGROUP_RULES_PATH),
		"fire": _data_source.load_dictionary(FIRE_RULES_PATH),
		"weather": _data_source.load_dictionary(WEATHER_SETTINGS_PATH)
	}

	_repo = GameDataRepository.new()
	_repo.bootstrap(world_state, _rules_by_key)
	_api = LogicApi.new(_repo, _data_source)
	_logic = GameLogicFacade.new(_api, _rules_by_key.get("engine", {}))
	_snapshot = _logic.get_world_snapshot()

	var engine_rules: Dictionary = _rules_by_key.get("engine", {})
	_apply_engine_rules(engine_rules)
	_ensure_runtime_meta_defaults(engine_rules)
	_apply_battle_demo_rules(_rules_by_key.get("battle", {}))
	_phase = _logic.get_phase()

	_init_preload()
	_build_presentation(_rules_by_key.get("presentation", {}))
	_select_default_building()
	if _phase != "battle":
		_enter_internal_phase(true)
	else:
		_status_message = ""
		_refresh_presentation()

func _exit_tree() -> void:
	Engine.time_scale = 1.0

func _process(delta: float) -> void:
	_update_cursor_terrain_hint()
	if _phase != "battle":
		_update_hover_info()
		return

	var effective_delta: float = 0.0 if _battle_paused else delta
	_battle_elapsed_seconds = minf(_battle_elapsed_seconds + effective_delta, _battle_phase_total_seconds)
	var current_day_phase: String = _runtime_day_phase()
	if current_day_phase != _runtime_last_day_phase:
		_runtime_last_day_phase = current_day_phase
		_refresh_supply_fog_runtime()
	if _ui_layer != null:
		_ui_layer.refresh(_snapshot, _selected_building_id, _build_hud_state())
	if _battle_elapsed_seconds >= _battle_phase_total_seconds - 0.0001:
		# Delay all city data settlement to the end of battle phase to reduce runtime load.
		_settle_battle_siege_durability_losses()
		_advance_days(_battle_phase_days)
		_enter_internal_phase(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		var key_event: InputEventKey = event
		if key_event.keycode == KEY_F10:
			_supply_debug_overlay_enabled = not _supply_debug_overlay_enabled
			if _map_view != null and _map_view.has_method("set_supply_debug_enabled"):
				_map_view.call("set_supply_debug_enabled", _supply_debug_overlay_enabled)
			_status_message = "supply debug: %s" % ("on" if _supply_debug_overlay_enabled else "off")
			_refresh_presentation()
			return
		if _phase == "internal" and key_event.keycode == KEY_G:
			_spawn_battle_demo()
			_refresh_presentation()
			return
		if _phase == "internal" and key_event.keycode == KEY_H:
			_clear_battle_demo()
			_refresh_presentation()
			return
	if _phase == "battle":
		return
	if not (event is InputEventMouseButton):
		return
	var mb: InputEventMouseButton = event
	if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed or mb.is_echo():
		return
	var hovered: Control = get_viewport().gui_get_hovered_control()
	if hovered != null and _ui_layer != null and _ui_layer.is_pointer_over_interactive_ui(hovered):
		return
	var building_id: String = _map_view.pick_building_from_screen(mb.position)
	if building_id.is_empty():
		_ui_layer.hide_city_command_menu()
		return
	_on_map_building_clicked(building_id, mb.position)

func _apply_engine_rules(engine_rules: Dictionary) -> void:
	_seconds_per_day = maxf(float(engine_rules.get("seconds_per_day", 6.0)), 0.001)
	_battle_phase_days = maxf(float(engine_rules.get("battle_phase_days", 10.0)), 0.1)
	_battle_phase_total_seconds = _seconds_per_day * _battle_phase_days
	_max_battle_step_seconds_per_frame = maxf(float(engine_rules.get("max_battle_step_seconds_per_frame", 0.2)), 0.01)
	_save_path = str(engine_rules.get("runtime_save_path", WORLD_STATE_PATH))

	var command_costs: Dictionary = engine_rules.get("command_costs", {})
	var all_cost: float = maxf(float(command_costs.get("all", 1.0)), 0.0)
	_command_cost_city_action = maxf(float(command_costs.get("city_action", all_cost)), 0.0)

	var command_effects: Dictionary = engine_rules.get("command_effects", {})
	_regroup_security_gain = float(command_effects.get("regroup_security_gain", _regroup_security_gain))
	_regroup_troop_gain_ratio = float(command_effects.get("regroup_troop_gain_ratio", _regroup_troop_gain_ratio))
	_merchant_money_gain = float(command_effects.get("merchant_money_gain", _merchant_money_gain))
	_supply_fog_rules = _build_supply_fog_rules(engine_rules.get("supply_fog_rules", {}))
	_time_weather_rules = _build_time_weather_rules(engine_rules.get("time_weather_rules", {}))

	_preload_paths.clear()
	for path_any in engine_rules.get("preload_resources", []):
		var path: String = str(path_any)
		if not path.is_empty():
			_preload_paths.append(path)
	if _preload_paths.is_empty():
		_preload_paths = [
			"res://绱犳潗/寤烘ā/鍏电/dunbing.glb",
			"res://绱犳潗/寤烘ā/鍏电/qingqibing.glb",
			"res://scripts/unit_controller.gd",
			"res://scripts/battlefield_controller.gd"
		]

func _build_supply_fog_rules(raw_rules: Dictionary) -> Dictionary:
	var out: Dictionary = {
		"enabled": true,
		"base_range_default": 2200.0,
		"base_range_by_type": {
			"city": 4200.0,
			"pass": 2100.0,
			"fort": 2000.0,
			"ferry": 2400.0,
			"resource": 1800.0
		},
		"granary_range_bonus": 1300.0,
		"convoy_range_bonus": 1700.0,
		"link_distance_mul": 1.0,
		"link_distance_max": 7000.0,
		"enemy_reveal_range_mul": 1.0,
		"enemy_reveal_padding": 280.0,
		"enemy_reveal_min_distance": 680.0
	}
	if raw_rules.is_empty():
		return out
	out["enabled"] = bool(raw_rules.get("enabled", out.get("enabled", true)))
	out["base_range_default"] = maxf(120.0, float(raw_rules.get("base_range_default", out.get("base_range_default", 2200.0))))
	out["granary_range_bonus"] = maxf(0.0, float(raw_rules.get("granary_range_bonus", out.get("granary_range_bonus", 1300.0))))
	out["convoy_range_bonus"] = maxf(0.0, float(raw_rules.get("convoy_range_bonus", out.get("convoy_range_bonus", 1700.0))))
	out["link_distance_mul"] = maxf(0.1, float(raw_rules.get("link_distance_mul", out.get("link_distance_mul", 1.0))))
	out["link_distance_max"] = maxf(120.0, float(raw_rules.get("link_distance_max", out.get("link_distance_max", 7000.0))))
	out["enemy_reveal_range_mul"] = maxf(0.1, float(raw_rules.get("enemy_reveal_range_mul", out.get("enemy_reveal_range_mul", 1.0))))
	out["enemy_reveal_padding"] = maxf(0.0, float(raw_rules.get("enemy_reveal_padding", out.get("enemy_reveal_padding", 280.0))))
	out["enemy_reveal_min_distance"] = maxf(0.0, float(raw_rules.get("enemy_reveal_min_distance", out.get("enemy_reveal_min_distance", 680.0))))

	var by_type: Dictionary = (out.get("base_range_by_type", {}) as Dictionary).duplicate(true)
	var raw_by_type: Dictionary = raw_rules.get("base_range_by_type", {})
	if raw_by_type is Dictionary:
		for type_any in raw_by_type.keys():
			var type_key: String = str(type_any).to_lower()
			by_type[type_key] = maxf(120.0, float(raw_by_type.get(type_any, by_type.get(type_key, out.get("base_range_default", 2200.0)))))
	var aliases: Dictionary = {
		"city": "base_range_city",
		"pass": "base_range_pass",
		"fort": "base_range_fort",
		"ferry": "base_range_ferry",
		"resource": "base_range_resource"
	}
	for type_key_any in aliases.keys():
		var type_key: String = str(type_key_any)
		var alias_key: String = str(aliases.get(type_key, ""))
		if alias_key.is_empty() or not raw_rules.has(alias_key):
			continue
		by_type[type_key] = maxf(120.0, float(raw_rules.get(alias_key, by_type.get(type_key, out.get("base_range_default", 2200.0)))))
	out["base_range_by_type"] = by_type
	return out

func _build_time_weather_rules(raw_rules: Dictionary) -> Dictionary:
	var out: Dictionary = DEFAULT_TIME_WEATHER_RULES.duplicate(true)
	if not (raw_rules is Dictionary) or (raw_rules as Dictionary).is_empty():
		return out
	var src: Dictionary = raw_rules as Dictionary
	out["enabled"] = bool(src.get("enabled", out.get("enabled", true)))
	var cycle_any: Variant = src.get("battle_phase_cycle", src.get("turn_day_phase_cycle", out.get("battle_phase_cycle", ["day", "night"])))
	if cycle_any is Array:
		var cycle: Array = []
		for phase_any in (cycle_any as Array):
			var phase: String = _normalize_day_phase(String(phase_any))
			if phase.is_empty():
				continue
			cycle.append(phase)
		if cycle.size() >= 2:
			out["battle_phase_cycle"] = [cycle[0], cycle[1]]
	var day_ratio: float = clampf(float(src.get("battle_phase_day_ratio", out.get("battle_phase_day_ratio", 0.42))), 0.05, 0.95)
	out["battle_phase_day_ratio"] = day_ratio
	var phase_mul_any: Variant = src.get("day_phase_visibility_mul", {})
	if phase_mul_any is Dictionary:
		var phase_mul: Dictionary = (out.get("day_phase_visibility_mul", {}) as Dictionary).duplicate(true)
		for key_any in (phase_mul_any as Dictionary).keys():
			var key: String = _normalize_day_phase(String(key_any))
			phase_mul[key] = clampf(float((phase_mul_any as Dictionary).get(key_any, phase_mul.get(key, 1.0))), 0.15, 2.0)
		out["day_phase_visibility_mul"] = phase_mul
	var weather_mul_any: Variant = src.get("weather_visibility_mul", {})
	if weather_mul_any is Dictionary:
		var weather_mul: Dictionary = (out.get("weather_visibility_mul", {}) as Dictionary).duplicate(true)
		for key_any in (weather_mul_any as Dictionary).keys():
			var key: String = _normalize_weather_state(String(key_any))
			weather_mul[key] = clampf(float((weather_mul_any as Dictionary).get(key_any, weather_mul.get(key, 1.0))), 0.15, 2.0)
		out["weather_visibility_mul"] = weather_mul
	return out

func _normalize_weather_state(raw: String) -> String:
	var state: String = raw.strip_edges().to_lower()
	if state == "sun" or state == "clear":
		return "sunny"
	if state == "overcast":
		return "cloudy"
	if state == "thunder":
		return "storm"
	if state == "mist":
		return "mist"
	if state == "fog":
		return "fog"
	return state if not state.is_empty() else "sunny"

func _normalize_day_phase(raw: String) -> String:
	var phase: String = raw.strip_edges().to_lower()
	if phase == "night" or phase == "evening" or phase == "pm" or phase == "dark":
		return "night"
	return "day"

func _runtime_day_phase() -> String:
	if not bool(_time_weather_rules.get("enabled", true)):
		return "day"
	if _phase != "battle":
		return "day"
	var cycle_any: Variant = _time_weather_rules.get("battle_phase_cycle", ["day", "night"])
	var cycle: Array = cycle_any if cycle_any is Array else ["day", "night"]
	if cycle.is_empty():
		return "day"
	var day_phase_a: String = _normalize_day_phase(String(cycle[0]))
	var day_phase_b: String = day_phase_a
	if cycle.size() > 1:
		day_phase_b = _normalize_day_phase(String(cycle[1]))
	var day_ratio: float = clampf(float(_time_weather_rules.get("battle_phase_day_ratio", 0.42)), 0.05, 0.95)
	var progress: float = 0.0
	if _battle_phase_total_seconds > 0.0001:
		progress = clampf(_battle_elapsed_seconds / _battle_phase_total_seconds, 0.0, 1.0)
	return day_phase_a if progress < day_ratio else day_phase_b

func _runtime_weather_visibility_context() -> Dictionary:
	var meta: Dictionary = _logic.get_meta_snapshot()
	var weather_any: Variant = meta.get("weather", {})
	var weather: Dictionary = weather_any as Dictionary if weather_any is Dictionary else {}
	var day_phase: String = _runtime_day_phase()
	var weather_state: String = _normalize_weather_state(String(weather.get("state", "sunny")))
	var phase_mul_any: Variant = _time_weather_rules.get("day_phase_visibility_mul", {})
	var phase_mul: Dictionary = phase_mul_any as Dictionary if phase_mul_any is Dictionary else {}
	var weather_mul_any: Variant = _time_weather_rules.get("weather_visibility_mul", {})
	var weather_mul: Dictionary = weather_mul_any as Dictionary if weather_mul_any is Dictionary else {}
	var mul_day: float = clampf(float(phase_mul.get(day_phase, phase_mul.get("day", 1.0))), 0.15, 2.0)
	var mul_weather: float = clampf(float(weather_mul.get(weather_state, 1.0)), 0.15, 2.0)
	var visibility_mul: float = clampf(mul_day * mul_weather, 0.15, 2.0)
	return {
		"day_phase": day_phase,
		"weather_state": weather_state,
		"visibility_mul": visibility_mul
	}

func _apply_battle_demo_rules(battle_rules: Dictionary) -> void:
	_battle_demo_units_per_team = maxi(1, int(battle_rules.get("demo_units_per_team", _battle_demo_units_per_team)))
	_battle_demo_soldiers_per_unit = maxi(8, int(battle_rules.get("demo_soldiers_per_unit", _battle_demo_soldiers_per_unit)))
	_battle_demo_team_spacing_x = maxf(8.0, float(battle_rules.get("demo_team_spacing_x", _battle_demo_team_spacing_x)))
	_battle_demo_front_offset_z = maxf(28.0, float(battle_rules.get("demo_front_offset_z", _battle_demo_front_offset_z)))
	_battle_demo_infantry_scale_mul = maxf(1.0, float(battle_rules.get("demo_infantry_scale_mul", _battle_demo_infantry_scale_mul)))
	_battle_demo_cavalry_scale_mul = maxf(1.0, float(battle_rules.get("demo_cavalry_scale_mul", _battle_demo_cavalry_scale_mul)))
	_battle_demo_spear_scale_mul = maxf(1.0, float(battle_rules.get("demo_spear_scale_mul", _battle_demo_spear_scale_mul)))
	_battle_demo_archer_scale_mul = maxf(1.0, float(battle_rules.get("demo_archer_scale_mul", _battle_demo_archer_scale_mul)))
	_battle_demo_archer_attack_range = maxf(6.0, float(battle_rules.get("demo_archer_attack_range", _battle_demo_archer_attack_range)))
	_battle_demo_archer_attack_interval = maxf(0.2, float(battle_rules.get("demo_archer_attack_interval", _battle_demo_archer_attack_interval)))
	_battle_demo_skill_cd_charge = maxf(0.0, float(battle_rules.get("demo_skill_cd_charge", _battle_demo_skill_cd_charge)))
	_battle_demo_skill_cd_breakthrough = maxf(0.0, float(battle_rules.get("demo_skill_cd_breakthrough", _battle_demo_skill_cd_breakthrough)))
	_battle_demo_skill_cd_sweep = maxf(0.0, float(battle_rules.get("demo_skill_cd_sweep", _battle_demo_skill_cd_sweep)))
	_battle_demo_skill_spirit_cost_charge = maxf(0.0, float(battle_rules.get("demo_skill_spirit_cost_charge", _battle_demo_skill_spirit_cost_charge)))
	_battle_demo_skill_spirit_cost_breakthrough = maxf(0.0, float(battle_rules.get("demo_skill_spirit_cost_breakthrough", _battle_demo_skill_spirit_cost_breakthrough)))
	_battle_demo_skill_spirit_cost_sweep = maxf(0.0, float(battle_rules.get("demo_skill_spirit_cost_sweep", _battle_demo_skill_spirit_cost_sweep)))
	_battle_demo_skill_will_cost_charge = maxf(0.0, float(battle_rules.get("demo_skill_will_cost_charge", _battle_demo_skill_will_cost_charge)))
	_battle_demo_skill_will_cost_breakthrough = maxf(0.0, float(battle_rules.get("demo_skill_will_cost_breakthrough", _battle_demo_skill_will_cost_breakthrough)))
	_battle_demo_skill_will_cost_sweep = maxf(0.0, float(battle_rules.get("demo_skill_will_cost_sweep", _battle_demo_skill_will_cost_sweep)))
	_battle_demo_soldier_formation_spacing = maxf(0.3, float(battle_rules.get("demo_soldier_formation_spacing", _battle_demo_soldier_formation_spacing)))
	_battle_demo_show_tag_when_near = bool(battle_rules.get("demo_show_tag_when_near", _battle_demo_show_tag_when_near))
	_battle_demo_show_unit_tags = bool(battle_rules.get("demo_show_unit_tags", _battle_demo_show_unit_tags))
	_battle_demo_team_a_unit_roles = _normalize_role_array(battle_rules.get("demo_team_a_unit_roles", _battle_demo_team_a_unit_roles), ["cavalry", "shield"])
	_battle_demo_team_b_unit_roles = _normalize_role_array(battle_rules.get("demo_team_b_unit_roles", _battle_demo_team_b_unit_roles), ["spear", "archer", "strategist_s", "strategist_a", "strategist_b", "strategist_c"])
	_battle_demo_tag_height_offset = clampf(float(battle_rules.get("demo_tag_height_offset", _battle_demo_tag_height_offset)), 2.0, 40.0)
	_battle_demo_tag_near_scale = clampf(float(battle_rules.get("demo_tag_near_scale", _battle_demo_tag_near_scale)), 0.08, 2.0)
	_battle_demo_tag_far_scale = clampf(float(battle_rules.get("demo_tag_far_scale", _battle_demo_tag_far_scale)), 0.05, _battle_demo_tag_near_scale)
	_battle_demo_soldier_use_model_albedo_texture = bool(battle_rules.get("demo_use_model_albedo_texture", _battle_demo_soldier_use_model_albedo_texture))
	_battle_demo_soldier_team_tint_strength = clampf(float(battle_rules.get("demo_team_tint_strength", _battle_demo_soldier_team_tint_strength)), 0.0, 1.0)
	_battle_demo_siege_durability_loss_scale = clampf(float(battle_rules.get("demo_siege_durability_loss_scale", _battle_demo_siege_durability_loss_scale)), 0.0, 3.0)
	_battle_demo_melee_frontline_width_mul = clampf(float(battle_rules.get("demo_melee_frontline_width_mul", _battle_demo_melee_frontline_width_mul)), 0.5, 3.0)
	_battle_demo_melee_frontline_depth_mul = clampf(float(battle_rules.get("demo_melee_frontline_depth_mul", _battle_demo_melee_frontline_depth_mul)), 0.4, 2.5)
	_battle_demo_melee_contact_distance_mul = clampf(float(battle_rules.get("demo_melee_contact_distance_mul", _battle_demo_melee_contact_distance_mul)), 0.7, 2.5)
	_battle_demo_melee_contact_distance_bias = clampf(float(battle_rules.get("demo_melee_contact_distance_bias", _battle_demo_melee_contact_distance_bias)), 0.0, 8.0)
	_battle_demo_melee_activity_radius_mul = clampf(float(battle_rules.get("demo_melee_activity_radius_mul", _battle_demo_melee_activity_radius_mul)), 0.5, 3.0)
	_battle_demo_melee_activity_radius_visual_weight = clampf(float(battle_rules.get("demo_melee_activity_radius_visual_weight", _battle_demo_melee_activity_radius_visual_weight)), 0.0, 1.0)
	_battle_demo_unit_player_force_chase_sec = maxf(0.0, float(battle_rules.get("demo_player_force_chase_sec", _battle_demo_unit_player_force_chase_sec)))
	_battle_demo_unit_player_force_chase_max_distance = maxf(32.0, float(battle_rules.get("demo_player_force_chase_max_distance", _battle_demo_unit_player_force_chase_max_distance)))
	_battle_demo_unit_player_force_chase_never_timeout = bool(battle_rules.get("demo_player_force_chase_never_timeout", _battle_demo_unit_player_force_chase_never_timeout))
	_battle_demo_unit_player_force_chase_ignore_distance = bool(battle_rules.get("demo_player_force_chase_ignore_distance", _battle_demo_unit_player_force_chase_ignore_distance))
	_battle_demo_unit_nav_goal_retry_max_attempts = maxi(0, int(battle_rules.get("demo_nav_goal_retry_max_attempts", _battle_demo_unit_nav_goal_retry_max_attempts)))
	_battle_demo_unit_nav_goal_retry_radius_step = maxf(0.5, float(battle_rules.get("demo_nav_goal_retry_radius_step", _battle_demo_unit_nav_goal_retry_radius_step)))
	_battle_demo_unit_nav_goal_retry_directions = maxi(4, int(battle_rules.get("demo_nav_goal_retry_directions", _battle_demo_unit_nav_goal_retry_directions)))
	_battle_demo_unit_nav_goal_retry_snap_distance_mul = maxf(1.0, float(battle_rules.get("demo_nav_goal_retry_snap_distance_mul", _battle_demo_unit_nav_goal_retry_snap_distance_mul)))
	_battle_demo_unit_morale_loss_per_10pct_troop = maxf(0.0, float(battle_rules.get("demo_morale_loss_per_10pct_troop", _battle_demo_unit_morale_loss_per_10pct_troop)))
	_battle_demo_unit_morale_stat_penalty_per_10 = clampf(float(battle_rules.get("demo_morale_stat_penalty_per_10", _battle_demo_unit_morale_stat_penalty_per_10)), 0.0, 0.3)
	_battle_demo_unit_morale_zero_hp_loss_per_sec = maxf(0.0, float(battle_rules.get("demo_morale_zero_hp_loss_per_sec", _battle_demo_unit_morale_zero_hp_loss_per_sec)))
	_battle_demo_unit_rout_troop_ratio_normal = clampf(float(battle_rules.get("demo_rout_troop_ratio_normal", _battle_demo_unit_rout_troop_ratio_normal)), 0.01, 0.95)
	_battle_demo_unit_rout_troop_ratio_garrison = clampf(float(battle_rules.get("demo_rout_troop_ratio_garrison", _battle_demo_unit_rout_troop_ratio_garrison)), 0.01, 0.95)
	_battle_demo_unit_garrison_morale_loss_mul = clampf(float(battle_rules.get("demo_garrison_morale_loss_mul", _battle_demo_unit_garrison_morale_loss_mul)), 0.05, 1.0)
	_battle_demo_unit_morale_loss_countered_bonus = maxf(0.0, float(battle_rules.get("demo_morale_loss_countered_bonus", _battle_demo_unit_morale_loss_countered_bonus)))
	_battle_demo_unit_morale_loss_flanked_bonus = maxf(0.0, float(battle_rules.get("demo_morale_loss_flanked_bonus", _battle_demo_unit_morale_loss_flanked_bonus)))
	_battle_demo_unit_morale_loss_out_of_supply_per_sec = maxf(0.0, float(battle_rules.get("demo_morale_loss_out_of_supply_per_sec", _battle_demo_unit_morale_loss_out_of_supply_per_sec)))
	_battle_demo_unit_morale_loss_special_terrain_per_sec = maxf(0.0, float(battle_rules.get("demo_morale_loss_special_terrain_per_sec", _battle_demo_unit_morale_loss_special_terrain_per_sec)))
	_battle_demo_unit_morale_loss_burning_per_sec = maxf(0.0, float(battle_rules.get("demo_morale_loss_burning_per_sec", _battle_demo_unit_morale_loss_burning_per_sec)))
	_battle_demo_terrain_adaptation_enabled = bool(battle_rules.get("demo_terrain_adaptation_enabled", _battle_demo_terrain_adaptation_enabled))
	_battle_demo_terrain_adaptation_interval_sec = maxf(0.1, float(battle_rules.get("demo_terrain_adaptation_interval_sec", _battle_demo_terrain_adaptation_interval_sec)))
	_battle_demo_terrain_status_hold_sec = maxf(0.1, float(battle_rules.get("demo_terrain_status_hold_sec", _battle_demo_terrain_status_hold_sec)))
	_battle_demo_role_counter_damage_matrix = _clone_dict_or_default(
		battle_rules.get("demo_role_counter_damage_matrix", {}),
		{
			"spear": {"cavalry": 1.24, "scout": 1.18},
			"cavalry": {"archer": 1.2, "crossbow": 1.16, "siege": 1.22},
			"archer": {"spear": 1.12},
			"crossbow": {"shield": 1.15, "spear": 1.1},
			"shield": {"archer": 1.08, "crossbow": 1.08},
			"siege": {"shield": 1.18, "infantry": 1.1},
			"scout": {"archer": 1.08},
			"naval": {"siege": 1.08}
		}
	)
	_battle_demo_role_terrain_profiles = _clone_dict_or_default(
		battle_rules.get("demo_role_terrain_profiles", {}),
		{
			"infantry": {"advantage": ["grass", "road"], "disadvantage": ["water"]},
			"shield": {"advantage": ["forest", "mountain"], "disadvantage": ["water", "swamp"]},
			"spear": {"advantage": ["hill", "mountain", "forest"], "disadvantage": ["swamp", "water"]},
			"cavalry": {"advantage": ["grass", "road"], "disadvantage": ["forest", "swamp", "mountain", "water"]},
			"archer": {"advantage": ["forest", "hill"], "disadvantage": ["swamp", "water"]},
			"crossbow": {"advantage": ["road", "grass"], "disadvantage": ["swamp", "water", "forest"]},
			"siege": {"advantage": ["road", "grass"], "disadvantage": ["forest", "swamp", "mountain", "water"]},
			"scout": {"advantage": ["road", "grass", "forest"], "disadvantage": ["water", "swamp"]},
			"naval": {"advantage": ["water"], "disadvantage": ["forest", "swamp", "mountain", "road", "grass"]}
		}
	)
	_battle_demo_height_advantage_enabled = bool(battle_rules.get("demo_height_advantage_enabled", _battle_demo_height_advantage_enabled))
	_battle_demo_height_advantage_rules = _clone_dict_or_default(
		battle_rules.get("demo_height_advantage_rules", {}),
		{
			"height_diff_threshold": 2.0,
			"downhill_probe_distance": 6.0
		}
	)
	_battle_demo_role_height_modifiers = _clone_dict_or_default(
		battle_rules.get("demo_role_height_modifiers", {}),
		{
			"archer": {"high_to_low_attack_mul": 1.15},
			"crossbow": {"high_to_low_attack_mul": 1.1},
			"cavalry": {"downhill_speed_mul": 1.2}
		}
	)
	_battle_demo_soft_repulsion_include_same_team = bool(battle_rules.get("demo_soft_repulsion_include_same_team", _battle_demo_soft_repulsion_include_same_team))
	_battle_demo_soft_repulsion_same_team_strength = maxf(0.1, float(battle_rules.get("demo_soft_repulsion_same_team_strength", _battle_demo_soft_repulsion_same_team_strength)))
	_battle_demo_soft_repulsion_enemy_strength = maxf(0.1, float(battle_rules.get("demo_soft_repulsion_enemy_strength", _battle_demo_soft_repulsion_enemy_strength)))
	_battle_demo_soft_repulsion_base_padding = maxf(0.0, float(battle_rules.get("demo_soft_repulsion_base_padding", _battle_demo_soft_repulsion_base_padding)))
	_battle_demo_soft_repulsion_radius_mul = maxf(0.25, float(battle_rules.get("demo_soft_repulsion_radius_mul", _battle_demo_soft_repulsion_radius_mul)))
	_battle_demo_spear_override_model_path = str(battle_rules.get("demo_spear_override_model_path", _battle_demo_spear_override_model_path))
	_battle_demo_spear_override_albedo_path = str(battle_rules.get("demo_spear_override_albedo_path", _battle_demo_spear_override_albedo_path))
	_battle_demo_archer_override_model_path = str(battle_rules.get("demo_archer_override_model_path", _battle_demo_archer_override_model_path))
	_battle_demo_archer_override_albedo_path = str(battle_rules.get("demo_archer_override_albedo_path", _battle_demo_archer_override_albedo_path))
	_battle_demo_infantry_override_model_path = str(battle_rules.get("demo_infantry_override_model_path", _battle_demo_infantry_override_model_path))
	_battle_demo_infantry_override_albedo_path = str(battle_rules.get("demo_infantry_override_albedo_path", _battle_demo_infantry_override_albedo_path))
	_battle_demo_cavalry_override_model_path = str(battle_rules.get("demo_cavalry_override_model_path", _battle_demo_cavalry_override_model_path))
	_battle_demo_cavalry_override_albedo_path = str(battle_rules.get("demo_cavalry_override_albedo_path", _battle_demo_cavalry_override_albedo_path))
	_battle_demo_shield_override_model_path = str(battle_rules.get("demo_shield_override_model_path", _battle_demo_shield_override_model_path))

func _normalize_role_array(value: Variant, fallback: Array[String]) -> Array[String]:
	var out: Array[String] = []
	if value is Array:
		for role_any in value:
			var role: String = str(role_any).strip_edges().to_lower()
			if role.is_empty():
				continue
			out.append(role)
	if out.is_empty():
		return fallback.duplicate()
	return out

func _clone_dict_or_default(value: Variant, fallback: Dictionary) -> Dictionary:
	if value is Dictionary:
		var dict_value: Dictionary = (value as Dictionary).duplicate(true)
		if not dict_value.is_empty():
			return dict_value
	return fallback.duplicate(true)

func _ensure_runtime_meta_defaults(engine_rules: Dictionary) -> void:
	var meta: Dictionary = _logic.get_meta_snapshot()
	var patch: Dictionary = {}
	var weather_rules: Dictionary = _rules_by_key.get("weather", {})

	var default_max_points: float = float(engine_rules.get("default_max_command_points", 12.0))
	var default_points: float = float(engine_rules.get("default_command_points", default_max_points))
	var default_max_military_orders: float = float(engine_rules.get("default_max_military_orders", 6.0))
	var default_military_orders: float = float(engine_rules.get("default_military_orders", default_max_military_orders))
	if not meta.has("max_command_points"):
		patch["max_command_points"] = default_max_points
	if not meta.has("command_points"):
		patch["command_points"] = default_points
	if not meta.has("max_military_orders"):
		patch["max_military_orders"] = default_max_military_orders
	if not meta.has("military_orders"):
		patch["military_orders"] = default_military_orders
	if not meta.has("phase"):
		patch["phase"] = "internal"
	if not meta.has("city_orders"):
		patch["city_orders"] = {}
	if not meta.has("weather"):
		patch["weather"] = {
			"state": str(weather_rules.get("default_weather_state", "sunny")),
			"wind_dir": weather_rules.get("default_wind_dir", [1.0, 0.0]),
			"wind_strength": float(weather_rules.get("default_wind_strength", 0.0)),
			"day_phase": "day"
		}
	elif meta.get("weather", null) is Dictionary:
		var weather_now: Dictionary = (meta.get("weather", {}) as Dictionary).duplicate(true)
		if not weather_now.has("day_phase"):
			weather_now["day_phase"] = "day"
			patch["weather"] = weather_now

	var max_points: float = float(meta.get("max_command_points", default_max_points))
	if patch.has("max_command_points"):
		max_points = float(patch.get("max_command_points", default_max_points))
	var current_points: float = float(meta.get("command_points", default_points))
	if patch.has("command_points"):
		current_points = float(patch.get("command_points", default_points))
	if current_points > max_points:
		patch["command_points"] = max_points
	if current_points < 0.0:
		patch["command_points"] = 0.0

	var max_military_orders: float = float(meta.get("max_military_orders", default_max_military_orders))
	if patch.has("max_military_orders"):
		max_military_orders = float(patch.get("max_military_orders", default_max_military_orders))
	var current_military_orders: float = float(meta.get("military_orders", default_military_orders))
	if patch.has("military_orders"):
		current_military_orders = float(patch.get("military_orders", default_military_orders))
	if current_military_orders > max_military_orders:
		patch["military_orders"] = max_military_orders
	if current_military_orders < 0.0:
		patch["military_orders"] = 0.0

	if not patch.is_empty():
		_logic.patch_meta(patch, "engine_bootstrap")
		_snapshot = _logic.get_world_snapshot()

func _init_preload() -> void:
	var preload_node: Node = get_node_or_null("PreloadManager")
	if preload_node is PreloadManager:
		_preload_manager = preload_node as PreloadManager
	elif preload_node != null:
		preload_node.set_script(PreloadManager)
		_preload_manager = preload_node as PreloadManager
	if _preload_manager == null:
		_preload_manager = PreloadManager.new()
		_preload_manager.name = "PreloadManager"
		add_child(_preload_manager)

	if DisplayServer.get_name() == "headless":
		_preload_progress = 1.0
		return

	if not _preload_manager.preload_progress.is_connected(_on_preload_progress):
		_preload_manager.preload_progress.connect(_on_preload_progress)
	if not _preload_manager.preload_finished.is_connected(_on_preload_finished):
		_preload_manager.preload_finished.connect(_on_preload_finished)
	_preload_manager.begin(_preload_paths)

func _build_presentation(presentation_rules: Dictionary) -> void:
	var map_node: Node = get_node_or_null("MapView")
	if map_node is StrategyMapView:
		_map_view = map_node as StrategyMapView
	elif map_node != null and map_node is Node3D:
		map_node.set_script(StrategyMapView)
		_map_view = map_node as StrategyMapView
	if _map_view == null:
		_map_view = StrategyMapView.new()
		_map_view.name = "MapView"
		add_child(_map_view)

	var font_path: String = str(presentation_rules.get("font_path", ""))
	var font: FontFile = null
	if not font_path.is_empty():
		font = load(font_path)

	_map_view.setup(_snapshot, presentation_rules, font)
	if _map_view.has_method("set_supply_debug_enabled"):
		_map_view.call("set_supply_debug_enabled", _supply_debug_overlay_enabled)

	var ui_node: Node = get_node_or_null("UILayer")
	if ui_node is StrategyUILayer:
		_ui_layer = ui_node as StrategyUILayer
	elif ui_node != null and ui_node is CanvasLayer:
		ui_node.set_script(StrategyUILayer)
		_ui_layer = ui_node as StrategyUILayer
	if _ui_layer == null:
		_ui_layer = StrategyUILayer.new()
		_ui_layer.name = "UILayer"
		add_child(_ui_layer)

	_ui_layer.setup(_snapshot, presentation_rules.get("ui", {}), font, _build_hud_state())
	if not _ui_layer.city_command_requested.is_connected(_on_city_command_requested):
		_ui_layer.city_command_requested.connect(_on_city_command_requested)
	if not _ui_layer.aide_change_requested.is_connected(_on_aide_change_requested):
		_ui_layer.aide_change_requested.connect(_on_aide_change_requested)
	if not _ui_layer.aide_batch_change_requested.is_connected(_on_aide_batch_change_requested):
		_ui_layer.aide_batch_change_requested.connect(_on_aide_batch_change_requested)
	if not _ui_layer.regroup_plan_confirmed.is_connected(_on_regroup_plan_confirmed):
		_ui_layer.regroup_plan_confirmed.connect(_on_regroup_plan_confirmed)
	if not _ui_layer.city_move_requested.is_connected(_on_city_move_requested):
		_ui_layer.city_move_requested.connect(_on_city_move_requested)
	if not _ui_layer.expedition_plan_confirmed.is_connected(_on_expedition_plan_confirmed):
		_ui_layer.expedition_plan_confirmed.connect(_on_expedition_plan_confirmed)
	if not _ui_layer.proceed_battle_requested.is_connected(_on_proceed_battle_requested):
		_ui_layer.proceed_battle_requested.connect(_on_proceed_battle_requested)
	if not _ui_layer.battle_pause_toggled.is_connected(_on_battle_pause_toggled):
		_ui_layer.battle_pause_toggled.connect(_on_battle_pause_toggled)
	if not _ui_layer.battle_speed_requested.is_connected(_on_battle_speed_requested):
		_ui_layer.battle_speed_requested.connect(_on_battle_speed_requested)
	if not _ui_layer.global_officer_book_requested.is_connected(_on_global_officer_book_requested):
		_ui_layer.global_officer_book_requested.connect(_on_global_officer_book_requested)

func _select_default_building() -> void:
	var units: Array = _get_building_units()
	for unit_any in units:
		if unit_any is Dictionary:
			_selected_building_id = str((unit_any as Dictionary).get("id", ""))
			if not _selected_building_id.is_empty():
				return

func _advance_days(days: float) -> void:
	if days <= 0.0:
		return
	_snapshot = _logic.tick(days)
	_refresh_presentation()

func _build_hud_state() -> Dictionary:
	var meta: Dictionary = _logic.get_meta_snapshot()
	var weather_any: Variant = meta.get("weather", {})
	var weather: Dictionary = weather_any as Dictionary if weather_any is Dictionary else {}
	weather = weather.duplicate(true)
	var vis_ctx: Dictionary = _runtime_weather_visibility_context()
	weather["day_phase"] = String(vis_ctx.get("day_phase", "day"))
	weather["state"] = String(vis_ctx.get("weather_state", weather.get("state", "sunny")))
	return {
		"phase": _phase,
		"calendar_day": float(meta.get("calendar_day", 1.0)),
		"command_points": float(meta.get("command_points", 0.0)),
		"max_command_points": float(meta.get("max_command_points", 0.0)),
		"military_orders": float(meta.get("military_orders", 0.0)),
		"max_military_orders": float(meta.get("max_military_orders", 0.0)),
		"weather": weather,
		"command_cost_city_action": _command_cost_city_action,
		"battle_seconds_elapsed": _battle_elapsed_seconds,
		"battle_seconds_total": _battle_phase_total_seconds,
		"battle_seconds_left": maxf(0.0, _battle_phase_total_seconds - _battle_elapsed_seconds),
		"battle_paused": _battle_paused,
		"battle_speed": _battle_speed,
		"status_message": _status_message,
		"preload_progress": _preload_progress
	}

func _refresh_presentation() -> void:
	_refresh_supply_fog_runtime()
	if _map_view != null:
		_map_view.refresh(_snapshot, _selected_building_id)
	if _ui_layer != null:
		_ui_layer.refresh(_snapshot, _selected_building_id, _build_hud_state())

func _enter_internal_phase(refill_command_points: bool) -> void:
	_clear_battle_demo()
	_battle_origin_city_id = ""
	_phase = "internal"
	_battle_paused = false
	_battle_speed = 1.0
	_apply_global_time_scale()
	_battle_elapsed_seconds = 0.0
	_runtime_last_day_phase = "day"
	_logic.set_phase(_phase)
	_apply_battle_pause_state()
	if refill_command_points:
		_logic.refill_command_points()
	_status_message = ""
	_snapshot = _logic.get_world_snapshot()
	_refresh_presentation()

func _enter_battle_phase() -> void:
	_phase = "battle"
	_battle_paused = false
	_battle_speed = 1.0
	_apply_global_time_scale()
	_battle_elapsed_seconds = 0.0
	_runtime_last_day_phase = _runtime_day_phase()
	_logic.set_phase(_phase)
	_battle_origin_city_id = _resolve_battle_origin_city_id()
	_ui_layer.hide_city_command_menu()
	_ui_layer.hide_command_panel()
	_ui_layer.hide_hover_info()
	if _battle_demo_instance == null or not is_instance_valid(_battle_demo_instance):
		_spawn_battle_demo()
	_apply_battle_pause_state()
	_status_message = ""
	_snapshot = _logic.get_world_snapshot()
	_refresh_presentation()

func _spawn_battle_demo() -> void:
	if _battle_demo_instance != null and is_instance_valid(_battle_demo_instance):
		return
	if BATTLE_DEMO_SCENE == null:
		return
	var node: Node = BATTLE_DEMO_SCENE.instantiate()
	if node.has_method("setup_weather_context"):
		var meta: Dictionary = _logic.get_meta_snapshot()
		node.call("setup_weather_context", {
			"weather": meta.get("weather", {}).duplicate(true),
			"settings_path": WEATHER_SETTINGS_PATH
		})
	if node is BattlefieldController:
		var battle: BattlefieldController = node as BattlefieldController
		var team_a_deployment: Array[Dictionary] = _build_battle_team_a_deployment(_battle_origin_city_id)
		var spawn_center: Vector3 = _find_battle_demo_spawn_center()
		var map_size: Vector2 = _get_runtime_map_size()
		var map_diag: float = map_size.length()
		battle.embedded_on_strategy_map = true
		battle.spawn_center = spawn_center
		battle.units_per_team = _battle_demo_units_per_team
		battle.soldiers_per_unit = _battle_demo_soldiers_per_unit
		battle.team_spacing_x = _battle_demo_team_spacing_x
		battle.team_front_offset_z = _battle_demo_front_offset_z
		battle.auto_engage_max_distance = maxf(120.0, _battle_demo_front_offset_z * 3.0)
		battle.infantry_model_scale_mul = _battle_demo_infantry_scale_mul
		battle.cavalry_model_scale_mul = _battle_demo_cavalry_scale_mul
		battle.spear_model_scale_mul = _battle_demo_spear_scale_mul
		battle.archer_model_scale_mul = _battle_demo_archer_scale_mul
		battle.archer_role_attack_range = _battle_demo_archer_attack_range
		battle.archer_role_attack_interval = _battle_demo_archer_attack_interval
		battle.unit_skill_cd_charge = _battle_demo_skill_cd_charge
		battle.unit_skill_cd_breakthrough = _battle_demo_skill_cd_breakthrough
		battle.unit_skill_cd_sweep = _battle_demo_skill_cd_sweep
		battle.unit_skill_spirit_cost_charge = _battle_demo_skill_spirit_cost_charge
		battle.unit_skill_spirit_cost_breakthrough = _battle_demo_skill_spirit_cost_breakthrough
		battle.unit_skill_spirit_cost_sweep = _battle_demo_skill_spirit_cost_sweep
		battle.unit_skill_will_cost_charge = _battle_demo_skill_will_cost_charge
		battle.unit_skill_will_cost_breakthrough = _battle_demo_skill_will_cost_breakthrough
		battle.unit_skill_will_cost_sweep = _battle_demo_skill_will_cost_sweep
		battle.soldier_formation_spacing = _battle_demo_soldier_formation_spacing
		battle.soldier_use_model_albedo_texture = _battle_demo_soldier_use_model_albedo_texture
		battle.soldier_team_tint_strength = _battle_demo_soldier_team_tint_strength
		battle.show_unit_tags = _battle_demo_show_unit_tags
		battle.team_a_unit_roles = PackedStringArray(_battle_demo_team_a_unit_roles)
		battle.team_b_unit_roles = PackedStringArray(_battle_demo_team_b_unit_roles)
		battle.team_a_deployment = team_a_deployment.duplicate(true)
		battle.melee_frontline_width_mul = _battle_demo_melee_frontline_width_mul
		battle.melee_frontline_depth_mul = _battle_demo_melee_frontline_depth_mul
		battle.melee_contact_distance_mul = _battle_demo_melee_contact_distance_mul
		battle.melee_contact_distance_bias = _battle_demo_melee_contact_distance_bias
		battle.melee_activity_radius_mul = _battle_demo_melee_activity_radius_mul
		battle.melee_activity_radius_visual_weight = _battle_demo_melee_activity_radius_visual_weight
		battle.unit_player_force_chase_sec = _battle_demo_unit_player_force_chase_sec
		battle.unit_player_force_chase_max_distance = _battle_demo_unit_player_force_chase_max_distance
		battle.unit_player_force_chase_never_timeout = _battle_demo_unit_player_force_chase_never_timeout
		battle.unit_player_force_chase_ignore_distance = _battle_demo_unit_player_force_chase_ignore_distance
		battle.unit_nav_goal_retry_max_attempts = _battle_demo_unit_nav_goal_retry_max_attempts
		battle.unit_nav_goal_retry_radius_step = _battle_demo_unit_nav_goal_retry_radius_step
		battle.unit_nav_goal_retry_directions = _battle_demo_unit_nav_goal_retry_directions
		battle.unit_nav_goal_retry_snap_distance_mul = _battle_demo_unit_nav_goal_retry_snap_distance_mul
		battle.unit_morale_loss_per_10pct_troop = _battle_demo_unit_morale_loss_per_10pct_troop
		battle.unit_morale_stat_penalty_per_10 = _battle_demo_unit_morale_stat_penalty_per_10
		battle.unit_morale_zero_hp_loss_per_sec = _battle_demo_unit_morale_zero_hp_loss_per_sec
		battle.unit_rout_troop_ratio_normal = _battle_demo_unit_rout_troop_ratio_normal
		battle.unit_rout_troop_ratio_garrison = _battle_demo_unit_rout_troop_ratio_garrison
		battle.unit_garrison_morale_loss_mul = _battle_demo_unit_garrison_morale_loss_mul
		battle.unit_morale_loss_countered_bonus = _battle_demo_unit_morale_loss_countered_bonus
		battle.unit_morale_loss_flanked_bonus = _battle_demo_unit_morale_loss_flanked_bonus
		battle.unit_morale_loss_out_of_supply_per_sec = _battle_demo_unit_morale_loss_out_of_supply_per_sec
		battle.unit_morale_loss_special_terrain_per_sec = _battle_demo_unit_morale_loss_special_terrain_per_sec
		battle.unit_morale_loss_burning_per_sec = _battle_demo_unit_morale_loss_burning_per_sec
		battle.terrain_adaptation_enabled = _battle_demo_terrain_adaptation_enabled
		battle.terrain_adaptation_interval_sec = _battle_demo_terrain_adaptation_interval_sec
		battle.terrain_status_hold_sec = _battle_demo_terrain_status_hold_sec
		battle.role_counter_damage_matrix = _battle_demo_role_counter_damage_matrix.duplicate(true)
		battle.role_terrain_profiles = _battle_demo_role_terrain_profiles.duplicate(true)
		battle.height_advantage_enabled = _battle_demo_height_advantage_enabled
		battle.height_advantage_rules = _battle_demo_height_advantage_rules.duplicate(true)
		battle.role_height_modifiers = _battle_demo_role_height_modifiers.duplicate(true)
		battle.soft_repulsion_include_same_team = _battle_demo_soft_repulsion_include_same_team
		battle.soft_repulsion_same_team_strength = _battle_demo_soft_repulsion_same_team_strength
		battle.soft_repulsion_enemy_strength = _battle_demo_soft_repulsion_enemy_strength
		battle.soft_repulsion_base_padding = _battle_demo_soft_repulsion_base_padding
		battle.soft_repulsion_radius_mul = _battle_demo_soft_repulsion_radius_mul
		battle.spear_override_model_path = _battle_demo_spear_override_model_path
		battle.spear_override_albedo_path = _battle_demo_spear_override_albedo_path
		battle.archer_override_model_path = _battle_demo_archer_override_model_path
		battle.archer_override_albedo_path = _battle_demo_archer_override_albedo_path
		battle.infantry_override_model_path = _battle_demo_infantry_override_model_path
		battle.infantry_override_albedo_path = _battle_demo_infantry_override_albedo_path
		battle.cavalry_override_model_path = _battle_demo_cavalry_override_model_path
		battle.cavalry_override_albedo_path = _battle_demo_cavalry_override_albedo_path
		battle.shield_override_model_path = _battle_demo_shield_override_model_path
		battle.unit_node_scale = 2.2
		battle.lod_soldier_visible_depth = maxf(360.0, map_diag * 0.08)
		battle.lod_tag_visible_max_depth = maxf(1200.0, map_diag * 1.2)
		battle.unit_tag_near_distance = maxf(18.0, map_diag * 0.001)
		battle.unit_tag_far_distance = maxf(420.0, map_diag * 0.55)
		battle.lod_show_tag_when_near = _battle_demo_show_tag_when_near
		battle.unit_tag_height_offset = _battle_demo_tag_height_offset
		battle.unit_tag_near_scale = _battle_demo_tag_near_scale
		battle.unit_tag_far_scale = _battle_demo_tag_far_scale
		battle.raycast_length = maxf(6500.0, map_diag * 2.5)
		if battle.has_method("set_strategy_map_view"):
			battle.call("set_strategy_map_view", _map_view)
		if battle.has_signal("weather_state_changed"):
			battle.weather_state_changed.connect(_on_battle_weather_state_changed)
	if node is Node3D:
		_battle_demo_instance = node as Node3D
	var battle_root: Node = get_node_or_null("BattleRoot")
	if battle_root != null:
		battle_root.add_child(node)
	else:
		add_child(node)
	_apply_battle_pause_state()

func _clear_battle_demo() -> void:
	if _battle_demo_instance != null and is_instance_valid(_battle_demo_instance):
		_battle_demo_instance.queue_free()
	_battle_demo_instance = null

func _on_battle_weather_state_changed(weather_patch: Dictionary) -> void:
	if weather_patch.is_empty():
		return
	var meta: Dictionary = _logic.get_meta_snapshot()
	var weather_any: Variant = meta.get("weather", {})
	var weather: Dictionary = weather_any as Dictionary if weather_any is Dictionary else {}
	weather = weather.duplicate(true)
	for key_any in weather_patch.keys():
		weather[String(key_any)] = weather_patch.get(key_any)
	weather["day_phase"] = _runtime_day_phase()
	_logic.patch_meta({"weather": weather}, "battle_weather")
	_snapshot = _logic.get_world_snapshot()
	_refresh_presentation()

func _resolve_battle_origin_city_id() -> String:
	var selected_id: String = _selected_building_id.strip_edges()
	if selected_id.is_empty():
		return ""
	var city: Dictionary = _find_city(selected_id)
	if not city.is_empty():
		return selected_id
	var outpost: Dictionary = _find_outpost_building(selected_id)
	if outpost.is_empty():
		return ""
	var city_id: String = str(outpost.get("city_id", "")).strip_edges()
	if city_id.is_empty():
		return ""
	if _find_city(city_id).is_empty():
		return ""
	return city_id

func _settle_battle_siege_durability_losses() -> void:
	if _battle_demo_instance == null or not is_instance_valid(_battle_demo_instance):
		return
	if not (_battle_demo_instance is BattlefieldController):
		return
	var city_id: String = _battle_origin_city_id.strip_edges()
	if city_id.is_empty():
		return
	var city: Dictionary = _find_city(city_id)
	if city.is_empty():
		return
	var battle: BattlefieldController = _battle_demo_instance as BattlefieldController
	var player_team_id: int = int(battle.demo_recon_player_team_id)
	var siege_total_troops: float = 0.0
	var siege_alive_troops: float = 0.0
	for unit_any in battle.units:
		if not (unit_any is UnitController):
			continue
		var unit: UnitController = unit_any as UnitController
		if unit == null or not is_instance_valid(unit):
			continue
		if int(unit.team_id) != player_team_id:
			continue
		var role_id: String = String(unit.combat_role_id).strip_edges().to_lower()
		if role_id.is_empty() and unit.has_method("get_combat_role_id"):
			role_id = String(unit.call("get_combat_role_id")).strip_edges().to_lower()
		if role_id != "siege":
			continue
		var troop_total: float = maxf(1.0, float(unit.troop_count))
		var troop_alive: float = troop_total
		if unit.has_method("get_alive_troop_count"):
			troop_alive = clampf(float(unit.call("get_alive_troop_count")), 0.0, troop_total)
		elif unit.has_method("get_alive_soldier_count"):
			troop_alive = clampf(float(unit.call("get_alive_soldier_count")), 0.0, troop_total)
		siege_total_troops += troop_total
		siege_alive_troops += troop_alive
	if siege_total_troops <= 0.0:
		return
	var loss_ratio: float = clampf((siege_total_troops - siege_alive_troops) / siege_total_troops, 0.0, 1.0)
	var scaled_loss_ratio: float = clampf(loss_ratio * _battle_demo_siege_durability_loss_scale, 0.0, 1.0)
	if scaled_loss_ratio <= 0.0001:
		return

	var dataset: Dictionary = _get_regroup_base_dataset()
	var units: Dictionary = dataset.get("units", {})
	var siege_durability_any: Variant = city.get("siege_durability", {})
	var siege_before: Dictionary = (siege_durability_any as Dictionary).duplicate(true) if siege_durability_any is Dictionary else {}
	if siege_before.is_empty():
		return
	var siege_after: Dictionary = siege_before.duplicate(true)
	var loss_total: float = 0.0
	for unit_id_any in units.keys():
		var unit_id: String = str(unit_id_any)
		if unit_id.is_empty():
			continue
		var unit_data_any: Variant = units.get(unit_id_any, {})
		if not (unit_data_any is Dictionary):
			continue
		var unit_data: Dictionary = unit_data_any
		if not _is_regroup_siege_equipment_unit(unit_data):
			continue
		var before_value: float = maxf(0.0, float(siege_after.get(unit_id, 0.0)))
		if before_value <= 0.0:
			continue
		var loss_value: float = ceil(before_value * scaled_loss_ratio)
		var after_value: float = maxf(0.0, before_value - loss_value)
		siege_after[unit_id] = after_value
		loss_total += before_value - after_value
	if loss_total <= 0.0:
		return
	_logic.apply_city_patch(city_id, {"siege_durability": siege_after}, "battle_siege_durability_loss")
	_snapshot = _logic.get_world_snapshot()

func _apply_global_time_scale() -> void:
	if _phase == "battle" and not _battle_paused:
		Engine.time_scale = _battle_speed
	else:
		Engine.time_scale = 1.0

func _apply_battle_pause_state() -> void:
	if _battle_demo_instance == null or not is_instance_valid(_battle_demo_instance):
		return
	if _battle_demo_instance is BattlefieldController:
		var battle: BattlefieldController = _battle_demo_instance as BattlefieldController
		if battle.has_method("set_units_motion_enabled"):
			var motion_enabled: bool = _phase == "battle" and not _battle_paused
			battle.call("set_units_motion_enabled", motion_enabled)

func _find_battle_demo_spawn_center() -> Vector3:
	if _map_view == null:
		return Vector3.ZERO
	var map_size: Vector2 = _get_runtime_map_size()
	var half_x: float = map_size.x * 0.5
	var half_z: float = map_size.y * 0.5
	var x_span: float = float(_battle_demo_units_per_team - 1) * _battle_demo_team_spacing_x * 0.5
	var clamp_x: float = maxf(0.0, half_x - x_span - 10.0)
	var clamp_z: float = maxf(0.0, half_z - _battle_demo_front_offset_z - 10.0)
	var candidates: Array[Vector3] = [
		Vector3.ZERO,
		Vector3(-160.0, 0.0, 0.0),
		Vector3(160.0, 0.0, 0.0),
		Vector3(0.0, 0.0, -100.0),
		Vector3(0.0, 0.0, 100.0),
		Vector3(-220.0, 0.0, 70.0),
		Vector3(220.0, 0.0, -70.0)
	]
	for center_any in candidates:
		var center: Vector3 = center_any
		center.x = clampf(center.x, -clamp_x, clamp_x)
		center.z = clampf(center.z, -clamp_z, clamp_z)
		if _is_battle_demo_spawn_center_walkable(center):
			return center
	for zi in range(-3, 4):
		for xi in range(-5, 6):
			var center := Vector3(
				clampf(float(xi) * 70.0, -clamp_x, clamp_x),
				0.0,
				clampf(float(zi) * 56.0, -clamp_z, clamp_z)
			)
			if _is_battle_demo_spawn_center_walkable(center):
				return center
	return Vector3.ZERO

func _is_battle_demo_spawn_center_walkable(center: Vector3) -> bool:
	for i in range(_battle_demo_units_per_team):
		var x_offset: float = (float(i) - float(_battle_demo_units_per_team - 1) * 0.5) * _battle_demo_team_spacing_x
		var pos_a := Vector3(center.x + x_offset, 0.0, center.z + _battle_demo_front_offset_z)
		var pos_b := Vector3(center.x + x_offset, 0.0, center.z - _battle_demo_front_offset_z)
		if not _is_battle_demo_spawn_pos_walkable(pos_a):
			return false
		if not _is_battle_demo_spawn_pos_walkable(pos_b):
			return false
	return true

func _is_battle_demo_spawn_pos_walkable(world_pos: Vector3) -> bool:
	if _map_view == null:
		return true
	if _map_view.has_method("can_unit_walk_at_world"):
		return bool(_map_view.call("can_unit_walk_at_world", world_pos))
	var terrain_type: String = _map_view.terrain_type_at_world(world_pos)
	return terrain_type != "water"

func _get_runtime_map_size() -> Vector2:
	var presentation_rules: Dictionary = _rules_by_key.get("presentation", {})
	var map_cfg: Dictionary = presentation_rules.get("map", {})
	var map_size: Dictionary = _snapshot.get("map", {}).get("size", {})
	var src_x: float = float(map_size.get("x", 1200.0))
	var src_z: float = float(map_size.get("z", 1200.0))
	var map_x: float = minf(src_x, float(map_cfg.get("terrain_demo_size_x", 960.0)))
	var map_z: float = minf(src_z, float(map_cfg.get("terrain_demo_size_z", 720.0)))
	return Vector2(maxf(map_x, 320.0), maxf(map_z, 320.0))

func _on_map_building_clicked(building_id: String, screen_pos: Vector2) -> void:
	_selected_building_id = building_id
	_refresh_presentation()
	var building: Dictionary = _find_building_any(building_id)
	var is_player_owned: bool = str(building.get("faction_id", "")) == _get_player_faction_id()
	if _phase == "internal" and not building.is_empty() and is_player_owned:
		var source_id: String = str(building.get("city_id", building.get("id", "")))
		var source_name: String = str(building.get("name", source_id))
		_ui_layer.show_city_command_menu(source_id, source_name, screen_pos)
	else:
		_ui_layer.hide_city_command_menu()

func _on_city_command_requested(city_id: String, action_id: String) -> void:
	if _phase != "internal":
		_status_message = ""
		_refresh_presentation()
		return

	var source_city: Dictionary = _find_city(city_id)
	var source_outpost: Dictionary = _find_outpost_building(city_id)
	var source_is_city: bool = not source_city.is_empty()
	var source_is_outpost: bool = not source_outpost.is_empty()
	if not source_is_city and not source_is_outpost:
		_status_message = ""
		_refresh_presentation()
		return
	var source_name: String = str(source_city.get("name", city_id)) if source_is_city else str(source_outpost.get("name", city_id))
	var source_faction: String = str(source_city.get("faction_id", "")) if source_is_city else str(source_outpost.get("faction_id", ""))
	if source_faction != _get_player_faction_id():
		_status_message = ""
		_refresh_presentation()
		return

	if action_id == "regroup":
		if not source_is_city:
			_status_message = ""
			_refresh_presentation()
			return
		_status_message = "%s征兵为自动结算，受太守与兵曹能力影响，无需手动操作。" % source_name
		_refresh_presentation()
		return
	if action_id == "aides":
		if not source_is_city:
			_status_message = ""
			_refresh_presentation()
			return
		_open_aides_panel(city_id)
		_status_message = ""
		_refresh_presentation()
		return
	if action_id == "expedition_start":
		if not source_is_city:
			_status_message = "Expedition is city-only."
			_refresh_presentation()
			return
		_open_expedition_panel(city_id)
		_status_message = ""
		_refresh_presentation()
		return
	if action_id == "expedition_cancel":
		if not source_is_city:
			_status_message = "Expedition is city-only."
			_refresh_presentation()
			return
		_apply_expedition_order(city_id, source_name, false)
		return
	if action_id == "merchant":
		if not source_is_city:
			_status_message = "Merchant is city-only."
			_refresh_presentation()
			return
		_apply_merchant_trade(city_id, source_name)
		return
	if action_id == "city_info":
		_open_city_info_panel(source_city if source_is_city else source_outpost)
		_status_message = ""
		_refresh_presentation()
		return
	if action_id == "move":
		_status_message = ""
		_refresh_presentation()
		return
	if _is_move_sub_action(action_id):
		_open_move_panel(city_id, action_id)
		_status_message = ""
		_refresh_presentation()
		return
	_status_message = ""
	_refresh_presentation()

func _apply_expedition_order(city_id: String, city_name: String, make_active: bool, payload: Dictionary = {}) -> void:
	var is_active_now: bool = _is_expedition_active(city_id)
	if make_active and is_active_now:
		_status_message = "Expedition already active."
		_refresh_presentation()
		return
	if not make_active and not is_active_now:
		_status_message = "No active expedition."
		_refresh_presentation()
		return
	if not _logic.consume_command_points(_command_cost_city_action):
		_status_message = ""
		_refresh_presentation()
		return
	_set_expedition_active(city_id, make_active, payload)
	_snapshot = _logic.get_world_snapshot()
	var city_now: Dictionary = _find_city(city_id)
	var siege_desc: String = _format_city_siege_durability_summary(city_now)
	var detail: String = ""
	if make_active:
		var officer_names: Array[String] = []
		var officer_names_any: Variant = payload.get("officer_names", [])
		if officer_names_any is Array:
			for name_any in (officer_names_any as Array):
				var officer_name: String = str(name_any).strip_edges()
				if officer_name.is_empty():
					continue
				officer_names.append(officer_name)
		var ship_label: String = str(payload.get("ship_label", payload.get("ship_type", ""))).strip_edges()
		if not officer_names.is_empty() or not ship_label.is_empty():
			detail = " | 编成：%s | 船型：%s" % ["、".join(officer_names), ship_label]
	_status_message = "出征已下达：%s | %s%s" % [city_name, siege_desc, detail] if make_active else "出征已取消：%s | %s" % [city_name, siege_desc]
	if _ui_layer != null:
		_ui_layer.hide_city_command_menu()
		_ui_layer.hide_command_panel()
	_refresh_presentation()

func _is_expedition_active(city_id: String) -> bool:
	var meta: Dictionary = _logic.get_meta_snapshot()
	var city_orders_any: Variant = meta.get("city_orders", {})
	if not (city_orders_any is Dictionary):
		return false
	var city_orders: Dictionary = city_orders_any
	var order_any: Variant = city_orders.get(city_id, {})
	if not (order_any is Dictionary):
		return false
	return bool((order_any as Dictionary).get("expedition_active", false))

func _set_expedition_active(city_id: String, active: bool, payload: Dictionary = {}) -> void:
	var meta: Dictionary = _logic.get_meta_snapshot()
	var city_orders: Dictionary = {}
	var city_orders_any: Variant = meta.get("city_orders", {})
	if city_orders_any is Dictionary:
		city_orders = (city_orders_any as Dictionary).duplicate(true)
	var order_entry: Dictionary = {}
	var order_any: Variant = city_orders.get(city_id, {})
	if order_any is Dictionary:
		order_entry = (order_any as Dictionary).duplicate(true)
	order_entry["expedition_active"] = active
	if active and not payload.is_empty():
		order_entry["officer_ids"] = _unique_string_array(payload.get("officer_ids", []))
		order_entry["officer_names"] = payload.get("officer_names", [])
		order_entry["ship_type"] = str(payload.get("ship_type", order_entry.get("ship_type", "zouge")))
		order_entry["ship_label"] = str(payload.get("ship_label", order_entry.get("ship_label", "走舸")))
		order_entry["combined_stats"] = payload.get("combined_stats", {})
		order_entry["land_profile"] = payload.get("land_profile", {})
		order_entry["water_profile"] = payload.get("water_profile", {})
	order_entry["updated_day"] = float(meta.get("calendar_day", 1.0))
	city_orders[city_id] = order_entry
	_logic.patch_meta({"city_orders": city_orders}, "expedition_order")

func _get_city_order_entry(city_id: String) -> Dictionary:
	var city_key: String = city_id.strip_edges()
	if city_key.is_empty():
		return {}
	var meta: Dictionary = _logic.get_meta_snapshot()
	var city_orders_any: Variant = meta.get("city_orders", {})
	if not (city_orders_any is Dictionary):
		return {}
	var order_any: Variant = (city_orders_any as Dictionary).get(city_key, {})
	if not (order_any is Dictionary):
		return {}
	return (order_any as Dictionary).duplicate(true)

func _normalize_battle_ship_type(raw_type: String) -> String:
	var ship_type: String = raw_type.strip_edges().to_lower()
	match ship_type:
		"", "default":
			return "zouge"
		"zouge", "zoug", "small", "light", "walkboat", "走舸":
			return "zouge"
		"lou", "louchuan", "lou_chuan", "tower", "tower_ship", "advanced", "楼船", "斗舰", "艨艟":
			return "lou_chuan"
		_:
			return ship_type

func _officer_aptitude_score(grade_raw: Variant) -> int:
	var grade: String = str(grade_raw).strip_edges().to_upper()
	match grade:
		"S":
			return 4
		"A":
			return 3
		"B":
			return 2
		"C":
			return 1
		"D", "E":
			return 0
		_:
			return -1

func _officer_aptitude_map(officer: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	var aptitude_any: Variant = officer.get("aptitude", {})
	if not (aptitude_any is Dictionary):
		return out
	var aptitude: Dictionary = aptitude_any as Dictionary
	for key_any in aptitude.keys():
		var key: String = str(key_any).strip_edges().to_lower()
		if key.is_empty():
			continue
		if key == "halberd":
			key = "shield"
		var grade: String = str(aptitude.get(key_any, "C")).strip_edges().to_upper()
		if grade.is_empty():
			grade = "C"
		out[key] = grade
	return out

func _resolve_officer_combat_role(officer: Dictionary, slot_index: int) -> String:
	var aptitude: Dictionary = _officer_aptitude_map(officer)
	var preferred_roles_by_slot: Array = [
		["cavalry", "shield", "spear", "strategist", "archer", "crossbow", "siege", "naval"],
		["spear", "shield", "archer", "cavalry", "crossbow", "strategist", "siege", "naval"],
		["strategist", "archer", "crossbow", "spear", "shield", "cavalry", "siege", "naval"]
	]
	var slot: int = clampi(slot_index, 0, preferred_roles_by_slot.size() - 1)
	var preferred_roles: Array = preferred_roles_by_slot[slot]
	var best_role: String = "shield"
	var best_score: int = -1
	var best_priority: int = 1 << 20
	for i in range(preferred_roles.size()):
		var role: String = str(preferred_roles[i]).strip_edges().to_lower()
		var score: int = _officer_aptitude_score(aptitude.get(role, ""))
		if score > best_score or (score == best_score and i < best_priority):
			best_score = score
			best_role = role
			best_priority = i
	return best_role

func _build_battle_team_a_deployment(city_id: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var city_key: String = city_id.strip_edges()
	if city_key.is_empty():
		return out
	var city: Dictionary = _find_city(city_key)
	if city.is_empty():
		return out
	var order_entry: Dictionary = _get_city_order_entry(city_key)
	if order_entry.is_empty() or not bool(order_entry.get("expedition_active", false)):
		return out
	var selected_ids_any: Variant = order_entry.get("officer_ids", [])
	if not (selected_ids_any is Array):
		return out
	var selected_ids: Array[String] = _unique_string_array(selected_ids_any as Array)
	if selected_ids.is_empty():
		return out
	var roster_any: Variant = city.get("officer_roster", [])
	var roster: Array = _build_city_roster_with_master(roster_any as Array if roster_any is Array else [])
	var selected_ship_type: String = _normalize_battle_ship_type(str(order_entry.get("ship_type", "zouge")))
	for i in range(selected_ids.size()):
		if out.size() >= _battle_demo_units_per_team:
			break
		var officer_id: String = selected_ids[i]
		var officer: Dictionary = _find_officer_by_id(roster, officer_id)
		if officer.is_empty():
			var master_any: Variant = _master_officers_by_id.get(officer_id, {})
			if master_any is Dictionary:
				officer = (master_any as Dictionary).duplicate(true)
		if officer.is_empty():
			continue
		var role_id: String = _resolve_officer_combat_role(officer, i)
		var officer_name: String = str(officer.get("name", officer_id)).strip_edges()
		if officer_name.is_empty():
			officer_name = officer_id
		var aptitude_map: Dictionary = _officer_aptitude_map(officer)
		var aptitude_grade: String = str(aptitude_map.get(role_id, "C")).strip_edges().to_upper()
		if aptitude_grade.is_empty():
			aptitude_grade = "C"
		var battle_personality_any: Variant = officer.get("battle_personality", {})
		var personality_trait_id: String = ""
		if battle_personality_any is Dictionary:
			personality_trait_id = str((battle_personality_any as Dictionary).get("id", "")).strip_edges().to_lower()
		out.append({
			"officer_id": officer_id,
			"officer_name": officer_name,
			"role": role_id,
			"ship_type": selected_ship_type,
			"aptitude": aptitude_grade,
			"personality_trait_id": personality_trait_id,
			"personality_text": personality_trait_id,
			"personality_level": 1 if not personality_trait_id.is_empty() else 0
		})
	return out

func _siege_unit_label(unit_id: String) -> String:
	match unit_id:
		"ram":
			return "冲车/木兽"
		"ladder":
			return "云梯/井阑"
		"catapult":
			return "投石车"
		_:
			return unit_id

func _format_city_siege_durability_summary(city: Dictionary) -> String:
	if city.is_empty():
		return "器械耐久：-"
	var siege_any: Variant = city.get("siege_durability", {})
	if not (siege_any is Dictionary):
		return "器械耐久：暂无"
	var siege: Dictionary = siege_any as Dictionary
	if siege.is_empty():
		return "器械耐久：暂无"
	var ordered_keys: Array[String] = []
	for key in ["ram", "ladder", "catapult"]:
		if siege.has(key):
			ordered_keys.append(key)
	var extra_keys: Array = siege.keys()
	extra_keys.sort()
	for key_any in extra_keys:
		var key: String = str(key_any)
		if key.is_empty() or ordered_keys.has(key):
			continue
		ordered_keys.append(key)
	var parts: Array[String] = []
	for key in ordered_keys:
		parts.append("%s %.0f" % [_siege_unit_label(key), maxf(0.0, float(siege.get(key, 0.0)))])
	if parts.is_empty():
		return "器械耐久：暂无"
	return "器械耐久：%s" % "  ".join(parts)

func _apply_merchant_trade(city_id: String, city_name: String) -> void:
	if not _logic.consume_command_points(_command_cost_city_action):
		_status_message = ""
		_refresh_presentation()
		return
	var city: Dictionary = _find_city(city_id)
	if city.is_empty():
		_status_message = ""
		_refresh_presentation()
		return
	var resources: Dictionary = city.get("resources", {}).duplicate(true)
	resources["money"] = float(resources.get("money", 0.0)) + _merchant_money_gain
	_logic.apply_city_patch(city_id, {"resources": resources}, "merchant")
	_snapshot = _logic.get_world_snapshot()
	_status_message = "Merchant trade +%.0f money (%s)." % [_merchant_money_gain, city_name]
	if _ui_layer != null:
		_ui_layer.hide_city_command_menu()
	_refresh_presentation()

func _open_city_info_panel(building: Dictionary) -> void:
	if _ui_layer == null or building.is_empty():
		return
	var building_name: String = str(building.get("name", building.get("id", "")))
	_ui_layer.show_command_panel("city_info", {
		"title": "City Info - %s" % building_name,
		"content_text": _build_city_info_text(building),
		"show_cancel": false,
		"show_decide": true,
		"decide_text": "Close"
	})

func _on_global_officer_book_requested() -> void:
	if _phase != "internal":
		return
	_open_global_officer_book_panel()
	_status_message = ""
	_refresh_presentation()

func _on_expedition_plan_confirmed(city_id: String, payload: Dictionary) -> void:
	if _phase != "internal":
		_status_message = ""
		_refresh_presentation()
		return
	var city: Dictionary = _find_city(city_id)
	if city.is_empty():
		_status_message = ""
		_refresh_presentation()
		return
	if str(city.get("faction_id", "")) != _get_player_faction_id():
		_status_message = ""
		_refresh_presentation()
		return
	var selected_ids: Array[String] = _unique_string_array(payload.get("officer_ids", []))
	if selected_ids.is_empty():
		_status_message = ""
		_refresh_presentation()
		return
	_apply_expedition_order(city_id, str(city.get("name", city_id)), true, payload)

func _on_city_move_requested(from_city_id: String, payload: Dictionary) -> void:
	if _phase != "internal":
		_status_message = ""
		_refresh_presentation()
		return

	var from_city: Dictionary = _find_city(from_city_id)
	var from_outpost: Dictionary = {}
	var source_is_city: bool = not from_city.is_empty()
	if not source_is_city:
		from_outpost = _find_outpost_building(from_city_id)
	if not source_is_city and from_outpost.is_empty():
		_status_message = ""
		_refresh_presentation()
		return
	var source_faction: String = str(from_city.get("faction_id", "")) if source_is_city else str(from_outpost.get("faction_id", ""))
	if source_faction != _get_player_faction_id():
		_status_message = ""
		_refresh_presentation()
		return
	var source_name: String = str(from_city.get("name", from_city_id)) if source_is_city else str(from_outpost.get("name", from_city_id))

	var target_city_id: String = str(payload.get("target_city_id", ""))
	var target_city: Dictionary = _find_city(target_city_id)
	var target_outpost: Dictionary = {}
	var target_is_city: bool = not target_city.is_empty()
	if not target_is_city:
		target_outpost = _find_outpost_building(target_city_id)
	if (not target_is_city and target_outpost.is_empty()) or target_city_id == from_city_id:
		_status_message = ""
		_refresh_presentation()
		return
	var target_faction: String = str(target_city.get("faction_id", "")) if target_is_city else str(target_outpost.get("faction_id", ""))
	if target_faction != source_faction:
		_status_message = ""
		_refresh_presentation()
		return

	var dispatch_ids: Array[String] = _unique_string_array(payload.get("dispatch_officer_ids", []))
	var recall_ids: Array[String] = _unique_string_array(payload.get("recall_officer_ids", []))
	var transfer: Dictionary = payload.get("transfer", {})
	var mode: String = str(payload.get("mode", "move_dispatch"))
	if not _is_move_sub_action(mode):
		mode = "move_dispatch"
	var money_amount: float = maxf(0.0, float(transfer.get("money", 0.0)))
	var food_amount: float = maxf(0.0, float(transfer.get("food", 0.0)))
	var iron_amount: float = maxf(0.0, float(transfer.get("iron", 0.0)))
	var wood_amount: float = maxf(0.0, float(transfer.get("wood", 0.0)))
	var horse_amount: float = maxf(0.0, float(transfer.get("horse", 0.0)))
	var reserve_amount: float = maxf(0.0, float(transfer.get("reserve_troops", 0.0)))
	var organized_amount: float = maxf(0.0, float(transfer.get("organized_troops", 0.0)))

	match mode:
		"move_dispatch":
			recall_ids = []
			money_amount = 0.0
			food_amount = 0.0
			iron_amount = 0.0
			wood_amount = 0.0
			horse_amount = 0.0
			reserve_amount = 0.0
			organized_amount = 0.0
		"move_recall":
			dispatch_ids = []
			money_amount = 0.0
			food_amount = 0.0
			iron_amount = 0.0
			wood_amount = 0.0
			horse_amount = 0.0
			reserve_amount = 0.0
			organized_amount = 0.0
		"move_transport_resources":
			dispatch_ids = []
			recall_ids = []
			organized_amount = 0.0
		"move_transport_troops":
			dispatch_ids = []
			recall_ids = []
			money_amount = 0.0
			food_amount = 0.0
			iron_amount = 0.0
			wood_amount = 0.0
			horse_amount = 0.0
			reserve_amount = 0.0

	var has_transfer: bool = money_amount > 0.0 or food_amount > 0.0 or iron_amount > 0.0 or wood_amount > 0.0 or horse_amount > 0.0 or reserve_amount > 0.0 or organized_amount > 0.0
	var has_payload: bool = false
	match mode:
		"move_dispatch":
			has_payload = not dispatch_ids.is_empty()
		"move_recall":
			has_payload = not recall_ids.is_empty()
		"move_transport_resources", "move_transport_troops":
			has_payload = has_transfer
		_:
			has_payload = (not dispatch_ids.is_empty()) or (not recall_ids.is_empty()) or has_transfer
	if not has_payload:
		_status_message = ""
		_refresh_presentation()
		return

	var source_state: Dictionary = {}
	if source_is_city:
		source_state = {
			"officer_roster": from_city.get("officer_roster", []).duplicate(true),
			"resources": from_city.get("resources", {}).duplicate(true),
			"stats": from_city.get("stats", {}).duplicate(true),
			"unit_composition": _normalize_unit_composition(from_city.get("unit_composition", {})),
			"personnel": from_city.get("personnel", {}).duplicate(true),
			"officers": from_city.get("officers", {}).duplicate(true)
		}
	else:
		source_state = _get_outpost_move_state(from_city_id)

	var from_resources: Dictionary = source_state.get("resources", {})
	var from_stats: Dictionary = source_state.get("stats", {})
	if money_amount > float(from_resources.get("money", 0.0)) or food_amount > float(from_resources.get("food", 0.0)) or iron_amount > float(from_resources.get("iron", 0.0)) or wood_amount > float(from_resources.get("wood", 0.0)) or horse_amount > float(from_resources.get("horse", 0.0)):
		_status_message = ""
		_refresh_presentation()
		return
	if reserve_amount > float(from_stats.get("reserve_troops", 0.0)) or organized_amount > float(from_stats.get("organized_troops", 0.0)):
		_status_message = ""
		_refresh_presentation()
		return

	var from_roster: Array = source_state.get("officer_roster", []).duplicate(true)
	var target_state: Dictionary = {}
	if target_is_city:
		target_state = {
			"officer_roster": target_city.get("officer_roster", []).duplicate(true),
			"resources": target_city.get("resources", {}).duplicate(true),
			"stats": target_city.get("stats", {}).duplicate(true),
			"unit_composition": _normalize_unit_composition(target_city.get("unit_composition", {})),
			"personnel": target_city.get("personnel", {}).duplicate(true),
			"officers": target_city.get("officers", {}).duplicate(true)
		}
	else:
		target_state = _get_outpost_move_state(target_city_id)
	var target_roster: Array = target_state.get("officer_roster", []).duplicate(true)
	for officer_id in dispatch_ids:
		if _find_officer_by_id(from_roster, officer_id).is_empty():
			_status_message = ""
			_refresh_presentation()
			return
	for officer_id in recall_ids:
		if _find_officer_by_id(target_roster, officer_id).is_empty():
			_status_message = ""
			_refresh_presentation()
			return

	if not _logic.consume_command_points(_command_cost_city_action):
		_status_message = ""
		_refresh_presentation()
		return

	for officer_id in dispatch_ids:
		var officer: Dictionary = _find_officer_by_id(from_roster, officer_id)
		if officer.is_empty():
			continue
		_remove_officer_from_roster(from_roster, officer_id)
		if _find_officer_by_id(target_roster, officer_id).is_empty():
			target_roster.append(officer.duplicate(true))

	for officer_id in recall_ids:
		var officer: Dictionary = _find_officer_by_id(target_roster, officer_id)
		if officer.is_empty():
			continue
		_remove_officer_from_roster(target_roster, officer_id)
		if _find_officer_by_id(from_roster, officer_id).is_empty():
			from_roster.append(officer.duplicate(true))

	var target_resources: Dictionary = target_state.get("resources", {})
	var from_resources_after: Dictionary = from_resources.duplicate(true)
	var target_resources_after: Dictionary = target_resources.duplicate(true)
	from_resources_after["money"] = float(from_resources_after.get("money", 0.0)) - money_amount
	from_resources_after["food"] = float(from_resources_after.get("food", 0.0)) - food_amount
	from_resources_after["iron"] = float(from_resources_after.get("iron", 0.0)) - iron_amount
	from_resources_after["wood"] = float(from_resources_after.get("wood", 0.0)) - wood_amount
	from_resources_after["horse"] = float(from_resources_after.get("horse", 0.0)) - horse_amount
	target_resources_after["money"] = float(target_resources_after.get("money", 0.0)) + money_amount
	target_resources_after["food"] = float(target_resources_after.get("food", 0.0)) + food_amount
	target_resources_after["iron"] = float(target_resources_after.get("iron", 0.0)) + iron_amount
	target_resources_after["wood"] = float(target_resources_after.get("wood", 0.0)) + wood_amount
	target_resources_after["horse"] = float(target_resources_after.get("horse", 0.0)) + horse_amount

	var target_stats: Dictionary = target_state.get("stats", {})
	var from_stats_after: Dictionary = from_stats.duplicate(true)
	var target_stats_after: Dictionary = target_stats.duplicate(true)
	from_stats_after["reserve_troops"] = float(from_stats_after.get("reserve_troops", 0.0)) - reserve_amount
	from_stats_after["organized_troops"] = float(from_stats_after.get("organized_troops", 0.0)) - organized_amount
	target_stats_after["reserve_troops"] = float(target_stats_after.get("reserve_troops", 0.0)) + reserve_amount
	target_stats_after["organized_troops"] = float(target_stats_after.get("organized_troops", 0.0)) + organized_amount
	from_stats_after["troops"] = float(from_stats_after.get("reserve_troops", 0.0)) + float(from_stats_after.get("organized_troops", 0.0))
	target_stats_after["troops"] = float(target_stats_after.get("reserve_troops", 0.0)) + float(target_stats_after.get("organized_troops", 0.0))

	var from_comp: Dictionary = _normalize_unit_composition(source_state.get("unit_composition", {}))
	var target_comp: Dictionary = _normalize_unit_composition(target_state.get("unit_composition", {}))
	var comp_result: Dictionary = _transfer_unit_composition(from_comp, target_comp, organized_amount)
	var from_personnel: Dictionary = {}
	if source_is_city:
		from_personnel = _sanitize_city_personnel_by_roster(from_city, from_roster)
	else:
		from_personnel = _sanitize_outpost_personnel(source_state.get("personnel", {}), from_roster)
	var target_personnel: Dictionary = {}
	if target_is_city:
		target_personnel = _sanitize_city_personnel_by_roster(target_city, target_roster)
	else:
		target_personnel = _sanitize_outpost_personnel(target_state.get("personnel", {}), target_roster)
	var from_officer_scores: Dictionary = {}
	if source_is_city:
		from_officer_scores = _rebuild_officer_scores_by_assignments(from_city.get("officers", {}), from_personnel.get("assignments", {}), from_roster)
	var target_officer_scores: Dictionary = {}
	if target_is_city:
		target_officer_scores = _rebuild_officer_scores_by_assignments(target_city.get("officers", {}), target_personnel.get("assignments", {}), target_roster)

	if source_is_city:
		_logic.apply_city_patch(from_city_id, {
			"resources": from_resources_after,
			"stats": from_stats_after,
			"officer_roster": from_roster,
			"personnel": from_personnel,
			"officers": from_officer_scores,
			"unit_composition": comp_result.get("source_after", {})
		}, "move_panel")
	else:
		var source_patch: Dictionary = {
			"officer_roster": from_roster,
			"resources": from_resources_after,
			"stats": from_stats_after,
			"unit_composition": comp_result.get("source_after", {}),
			"personnel": from_personnel
		}
		_set_outpost_move_state(from_city_id, source_patch)
	if target_is_city:
		_logic.apply_city_patch(target_city_id, {
			"resources": target_resources_after,
			"stats": target_stats_after,
			"officer_roster": target_roster,
			"personnel": target_personnel,
			"officers": target_officer_scores,
			"unit_composition": comp_result.get("target_after", {})
		}, "move_panel")
	else:
		var target_patch: Dictionary = {
			"officer_roster": target_roster,
			"resources": target_resources_after,
			"stats": target_stats_after,
			"unit_composition": comp_result.get("target_after", {}),
			"personnel": target_personnel
		}
		_set_outpost_move_state(target_city_id, target_patch)

	_snapshot = _logic.get_world_snapshot()
	_ui_layer.hide_command_panel()
	var target_name: String = str(target_city.get("name", target_city_id)) if target_is_city else str(target_outpost.get("name", target_city_id))
	_status_message = ""
	_refresh_presentation()

func _evaluate_regroup_plan(city: Dictionary, plans: Array) -> Dictionary:
	var dataset: Dictionary = _build_regroup_dataset(city)
	var units: Dictionary = dataset.get("units", {})
	var resources: Dictionary = city.get("resources", {})
	var stats: Dictionary = city.get("stats", {})
	var composition_after: Dictionary = _normalize_unit_composition(city.get("unit_composition", {}), dataset)
	var siege_durability_any: Variant = city.get("siege_durability", {})
	var siege_durability_after: Dictionary = (siege_durability_any as Dictionary).duplicate(true) if siege_durability_any is Dictionary else {}

	var resources_after: Dictionary = resources.duplicate(true)
	var reserve_before: float = float(stats.get("reserve_troops", 0.0))
	var organized_before: float = float(stats.get("organized_troops", 0.0))

	var total_troop_amount: float = 0.0
	var total_siege_repair_amount: float = 0.0
	var type_count: int = 0

	for plan_any in plans:
		if not (plan_any is Dictionary):
			continue
		var plan: Dictionary = plan_any
		var unit_id: String = _canonical_regroup_unit_id(str(plan.get("unit_id", "")), dataset)
		var amount: int = int(plan.get("amount", 0))
		if unit_id.is_empty() or amount <= 0:
			continue
		var unit: Dictionary = units.get(unit_id, {})
		if unit.is_empty():
			return {"ok": false, "reason": "unit_missing"}
		var batch_size: int = maxi(1, int(unit.get("batch_size", 100)))
		if amount % batch_size != 0:
			return {"ok": false, "reason": "invalid_amount"}

		var cost_for_amount: Dictionary = _calc_regroup_unit_cost_for_amount(unit, amount)
		if _is_regroup_siege_equipment_unit(unit):
			var durability_cap: float = _regroup_siege_unit_durability_cap(unit)
			var durability_current: float = float(siege_durability_after.get(unit_id, 0.0))
			var durability_next: float = durability_current + float(amount)
			if durability_cap > 0.0 and durability_next > durability_cap + 0.0001:
				return {"ok": false, "reason": "siege_durability_cap"}
			total_siege_repair_amount += amount
			siege_durability_after[unit_id] = durability_next
		else:
			total_troop_amount += amount
			composition_after[unit_id] = float(composition_after.get(unit_id, 0.0)) + amount
		for res_key_any in cost_for_amount.keys():
			var res_key: String = str(res_key_any)
			var current: float = float(resources_after.get(res_key, 0.0))
			resources_after[res_key] = current - float(cost_for_amount.get(res_key, 0.0))
		type_count += 1

	if total_troop_amount <= 0.0 and total_siege_repair_amount <= 0.0:
		return {"ok": false, "reason": "empty_plan"}

	for res_key_any in resources_after.keys():
		var res_key: String = str(res_key_any)
		if float(resources_after.get(res_key, 0.0)) < 0.0:
			return {"ok": false, "reason": "insufficient_resources"}

	var reserve_after: float = reserve_before - total_troop_amount
	if reserve_after < 0.0:
		return {"ok": false, "reason": "insufficient_reserve"}
	var organized_after: float = organized_before + total_troop_amount

	return {
		"ok": true,
		"type_count": type_count,
		"total_troop_amount": total_troop_amount,
		"total_siege_repair_amount": total_siege_repair_amount,
		"total_amount": total_troop_amount + total_siege_repair_amount,
		"reserve_after": reserve_after,
		"organized_after": organized_after,
		"resources_after": resources_after,
		"siege_durability_after": siege_durability_after,
		"unit_composition_after": composition_after
	}

func _build_regroup_dataset(city: Dictionary = {}) -> Dictionary:
	var base_dataset: Dictionary = _get_regroup_base_dataset()
	var rules: Dictionary = _rules_by_key.get("regroup", {})
	return _apply_regroup_tech_traits(base_dataset, city, rules)

func _get_regroup_base_dataset() -> Dictionary:
	if not _regroup_base_dataset_cache.is_empty():
		return _regroup_base_dataset_cache.duplicate(true)
	var rules: Dictionary = _rules_by_key.get("regroup", {})
	var dataset: Dictionary = {}
	if bool(rules.get("use_external_source", false)):
		var source_candidates: Array = rules.get("external_source_candidates", [])
		var external_path: String = str(rules.get("external_source_path", ""))
		if source_candidates.is_empty() and not external_path.is_empty():
			source_candidates.append(external_path)
		for path_any in source_candidates:
			var path: String = str(path_any)
			if path.is_empty():
				continue
			if not FileAccess.file_exists(path):
				continue
			var external_data: Dictionary = _data_source.load_dictionary(path)
			if external_data.is_empty():
				continue
			var normalized: Dictionary = _normalize_external_regroup_source(external_data, rules)
			if not normalized.is_empty():
				dataset = normalized
				break
	if dataset.is_empty():
		dataset = {
		"categories": rules.get("categories", []).duplicate(true),
		"units": rules.get("units", {}).duplicate(true),
		"unit_aliases": rules.get("unit_aliases", {}).duplicate(true)
	}
	dataset = _merge_regroup_inline_rules(dataset, rules)
	_regroup_base_dataset_cache = dataset.duplicate(true)
	return _regroup_base_dataset_cache.duplicate(true)

func _merge_regroup_inline_rules(dataset: Dictionary, rules: Dictionary) -> Dictionary:
	var out: Dictionary = dataset.duplicate(true)
	var categories: Array = (out.get("categories", []) as Array).duplicate(true) if out.get("categories", []) is Array else []
	var units: Dictionary = (out.get("units", {}) as Dictionary).duplicate(true) if out.get("units", {}) is Dictionary else {}
	var unit_aliases: Dictionary = (out.get("unit_aliases", {}) as Dictionary).duplicate(true) if out.get("unit_aliases", {}) is Dictionary else {}
	var default_batch_size: int = maxi(1, int(rules.get("default_batch_size", 100)))

	var inline_units_any: Variant = rules.get("units", {})
	if inline_units_any is Dictionary:
		var inline_units: Dictionary = inline_units_any
		for unit_id_any in inline_units.keys():
			var unit_id: String = str(unit_id_any).strip_edges()
			if unit_id.is_empty():
				continue
			var raw_unit_any: Variant = inline_units.get(unit_id_any, {})
			if not (raw_unit_any is Dictionary):
				continue
			var unit: Dictionary = (raw_unit_any as Dictionary).duplicate(true)
			var class_id: String = str(unit.get("class_id", unit_id)).strip_edges()
			if class_id.is_empty():
				class_id = unit_id
			var desc: String = str(unit.get("description", unit.get("base_description", "")))
			var stats: Dictionary = (unit.get("stats", {}) as Dictionary).duplicate(true) if unit.get("stats", {}) is Dictionary else {}
			var base_stats: Dictionary = (unit.get("base_stats", stats) as Dictionary).duplicate(true) if unit.get("base_stats", stats) is Dictionary else stats.duplicate(true)
			var time_sec_per_100: float = float(unit.get("time_sec_per_100", unit.get("base_time_sec_per_100", 100.0)))
			var normalized: Dictionary = unit.duplicate(true)
			normalized["id"] = unit_id
			normalized["class_id"] = class_id
			normalized["is_siege_equipment"] = bool(unit.get("is_siege_equipment", _is_regroup_siege_class_id(class_id, rules)))
			normalized["name"] = str(unit.get("name", unit_id))
			normalized["tier"] = int(unit.get("tier", 1))
			normalized["batch_size"] = maxi(1, int(unit.get("batch_size", default_batch_size)))
			normalized["description"] = desc
			normalized["base_description"] = str(unit.get("base_description", desc))
			normalized["reserve_per_soldier"] = float(unit.get("reserve_per_soldier", 1.0))
			normalized["time_sec_per_100"] = time_sec_per_100
			normalized["base_time_sec_per_100"] = float(unit.get("base_time_sec_per_100", time_sec_per_100))
			normalized["stats"] = stats
			normalized["base_stats"] = base_stats
			if unit.get("cost_per_soldier", {}) is Dictionary:
				normalized["cost_per_soldier"] = (unit.get("cost_per_soldier", {}) as Dictionary).duplicate(true)
			if unit.get("base_cost_per_soldier", {}) is Dictionary:
				normalized["base_cost_per_soldier"] = (unit.get("base_cost_per_soldier", {}) as Dictionary).duplicate(true)
			elif normalized.get("cost_per_soldier", {}) is Dictionary:
				normalized["base_cost_per_soldier"] = (normalized.get("cost_per_soldier", {}) as Dictionary).duplicate(true)
			if unit.get("cost_per_batch", {}) is Dictionary:
				normalized["cost_per_batch"] = (unit.get("cost_per_batch", {}) as Dictionary).duplicate(true)
			units[unit_id] = normalized
			unit_aliases[unit_id] = unit_id
			var aliases_any: Variant = unit.get("aliases", [])
			if aliases_any is Array:
				for alias_any in aliases_any:
					var alias_id: String = str(alias_any).strip_edges()
					if alias_id.is_empty():
						continue
					unit_aliases[alias_id] = unit_id

	var inline_aliases_any: Variant = rules.get("unit_aliases", {})
	if inline_aliases_any is Dictionary:
		var inline_aliases: Dictionary = inline_aliases_any
		for alias_key_any in inline_aliases.keys():
			var alias_key: String = str(alias_key_any).strip_edges()
			var alias_target: String = str(inline_aliases.get(alias_key_any, "")).strip_edges()
			if alias_key.is_empty() or alias_target.is_empty():
				continue
			unit_aliases[alias_key] = alias_target

	var category_index: Dictionary = {}
	for i in range(categories.size()):
		if not (categories[i] is Dictionary):
			continue
		var cat_id: String = str((categories[i] as Dictionary).get("id", "")).strip_edges()
		if cat_id.is_empty():
			continue
		category_index[cat_id] = i

	var inline_categories_any: Variant = rules.get("categories", [])
	if inline_categories_any is Array:
		var inline_categories: Array = inline_categories_any
		for cat_any in inline_categories:
			if not (cat_any is Dictionary):
				continue
			var cat: Dictionary = (cat_any as Dictionary).duplicate(true)
			var cat_id: String = str(cat.get("id", "")).strip_edges()
			if cat_id.is_empty():
				continue
			var label: String = str(cat.get("label", _default_regroup_category_label(cat_id)))
			var cat_units: Array = []
			var raw_cat_units_any: Variant = cat.get("units", [])
			if raw_cat_units_any is Array:
				for unit_key_any in (raw_cat_units_any as Array):
					var unit_key: String = str(unit_key_any).strip_edges()
					if unit_key.is_empty():
						continue
					var mapped_id: String = str(unit_aliases.get(unit_key, unit_key)).strip_edges()
					if mapped_id.is_empty() or not units.has(mapped_id):
						continue
					if not cat_units.has(mapped_id):
						cat_units.append(mapped_id)
			var merged_cat: Dictionary = {
				"id": cat_id,
				"label": label,
				"units": cat_units
			}
			if category_index.has(cat_id):
				categories[int(category_index.get(cat_id, 0))] = merged_cat
			else:
				categories.append(merged_cat)
				category_index[cat_id] = categories.size() - 1

	out["categories"] = categories
	out["units"] = units
	out["unit_aliases"] = unit_aliases
	return out

func _normalize_external_regroup_source(source: Dictionary, rules: Dictionary) -> Dictionary:
	var source_units: Dictionary = source.get("units", {})
	if source_units.is_empty():
		return {}
	var class_order: Array = rules.get("class_order", [])
	if class_order.is_empty():
		class_order = source_units.keys()
	var label_overrides: Dictionary = rules.get("class_label_overrides", {})
	var unit_name_overrides: Dictionary = rules.get("unit_name_overrides", {})
	var resource_alias: Dictionary = rules.get("resource_alias", {})
	var class_extra_cost_per_soldier: Dictionary = rules.get("class_extra_cost_per_soldier", {})
	var default_batch_size: int = maxi(1, int(rules.get("default_batch_size", 100)))
	var explicit_aliases: Dictionary = rules.get("legacy_unit_id_aliases", {})

	var categories: Array = []
	var units: Dictionary = {}
	var unit_aliases: Dictionary = {}
	for legacy_id_any in explicit_aliases.keys():
		var legacy_id: String = str(legacy_id_any).strip_edges()
		var canonical_id: String = str(explicit_aliases.get(legacy_id_any, "")).strip_edges()
		if not legacy_id.is_empty() and not canonical_id.is_empty():
			unit_aliases[legacy_id] = canonical_id
	for class_id_any in class_order:
		var class_id: String = str(class_id_any)
		var entries: Array = _as_regroup_entry_array(source_units.get(class_id, []))
		if entries.is_empty():
			continue
		var base_entry: Dictionary = _pick_regroup_base_entry(entries)
		if base_entry.is_empty():
			continue
		unit_aliases[class_id] = class_id
		for entry_any in entries:
			if not (entry_any is Dictionary):
				continue
			var entry_id: String = str((entry_any as Dictionary).get("id", "")).strip_edges()
			if not entry_id.is_empty():
				unit_aliases[entry_id] = class_id

		var stats: Dictionary = base_entry.get("stats", {})
		var passive: Dictionary = base_entry.get("passive", {})
		var reorganize: Dictionary = base_entry.get("reorganization", {})
		var mapped_cost: Dictionary = _map_regroup_cost_per_soldier(
			reorganize.get("per_soldier_cost", {}),
			resource_alias,
			class_extra_cost_per_soldier.get(class_id, {})
		)
		var base_time_sec_per_100: float = float(reorganize.get("time_sec_per_100", 100.0))
		var base_stats: Dictionary = {
			"physical_attack": int(stats.get("physical_attack", 0)),
			"magic_attack": int(stats.get("magic_attack", 0)),
			"physical_defense": int(stats.get("physical_defense", 0)),
			"magic_defense": int(stats.get("magic_defense", 0)),
			"move_speed": float(stats.get("move_speed", 0.0)),
			"attack_range": float(stats.get("attack_range", 0.0)),
			"attack_speed": float(stats.get("attack_speed", 0.0))
		}

		var unit_id: String = class_id
		var passive_name: String = str(passive.get("name", "")).strip_edges()
		var passive_effect: String = str(passive.get("effect", "")).strip_edges()
		var base_desc: String = passive_effect
		if not passive_name.is_empty():
			base_desc = "%s: %s" % [passive_name, passive_effect]
		var unit_name: String = str(unit_name_overrides.get(class_id, base_entry.get("name", class_id))).strip_edges()
		if unit_name.is_empty():
			unit_name = class_id

		units[unit_id] = {
			"id": unit_id,
			"class_id": class_id,
			"is_siege_equipment": _is_regroup_siege_class_id(class_id, rules),
			"name": unit_name,
			"tier": 1,
			"batch_size": default_batch_size,
			"description": base_desc,
			"base_description": base_desc,
			"reserve_per_soldier": float(reorganize.get("reserve_per_soldier", 1.0)),
			"time_sec_per_100": base_time_sec_per_100,
			"base_time_sec_per_100": base_time_sec_per_100,
			"cost_per_soldier": mapped_cost.duplicate(true),
			"base_cost_per_soldier": mapped_cost.duplicate(true),
			"stats": base_stats.duplicate(true),
			"base_stats": base_stats.duplicate(true)
		}
		var label: String = str(label_overrides.get(class_id, _default_regroup_category_label(class_id)))
		categories.append({
			"id": class_id,
			"label": label,
			"units": [class_id]
		})

	return {
		"categories": categories,
		"units": units,
		"unit_aliases": unit_aliases
	}

func _apply_regroup_tech_traits(dataset: Dictionary, city: Dictionary, rules: Dictionary) -> Dictionary:
	if dataset.is_empty():
		return {}
	var out: Dictionary = dataset.duplicate(true)
	var units_any: Variant = out.get("units", {})
	if not (units_any is Dictionary):
		return out
	var units: Dictionary = units_any
	var city_stats: Dictionary = city.get("stats", {}) if city.get("stats", {}) is Dictionary else {}
	var tech_points: float = float(city_stats.get("tech_points", 0.0))
	var traits_by_class_any: Variant = rules.get("tech_traits", {})
	var traits_by_class: Dictionary = traits_by_class_any if traits_by_class_any is Dictionary else {}
	var int_stat_keys := {
		"physical_attack": true,
		"magic_attack": true,
		"physical_defense": true,
		"magic_defense": true
	}
	var locked_unit_ids: Dictionary = {}

	for unit_id_any in units.keys():
		var unit_id: String = str(unit_id_any)
		if unit_id.is_empty():
			continue
		var unit: Dictionary = units.get(unit_id, {})
		if unit.is_empty():
			continue
		var unlock_tech_points: float = float(unit.get("min_tech_points", 0.0))
		if tech_points + 0.0001 < unlock_tech_points:
			locked_unit_ids[unit_id] = true
			continue
		var class_id: String = str(unit.get("class_id", unit_id))
		var class_traits_any: Variant = traits_by_class.get(class_id, [])
		if not (class_traits_any is Array):
			unit["description"] = _build_regroup_unit_description(str(unit.get("base_description", unit.get("description", ""))), [])
			unit["tech_points"] = tech_points
			unit["tech_tier_active"] = 0
			unit["tech_tier_total"] = 0
			unit["tech_effect_cumulative"] = {
				"stats_add": {},
				"cost_per_soldier_mul": {},
				"time_sec_per_100_mul": 1.0
			}
			unit["tech_traits_active"] = []
			units[unit_id] = unit
			continue
		var class_traits: Array = class_traits_any
		var active_traits: Array = []
		var stats: Dictionary = unit.get("base_stats", unit.get("stats", {})).duplicate(true)
		var cost_per_soldier: Dictionary = unit.get("base_cost_per_soldier", unit.get("cost_per_soldier", {})).duplicate(true)
		var time_sec_per_100: float = float(unit.get("base_time_sec_per_100", unit.get("time_sec_per_100", 100.0)))
		var cumulative_stats_add: Dictionary = {}
		var cumulative_cost_mul: Dictionary = {}
		var cumulative_time_mul: float = 1.0

		for trait_any in class_traits:
			if not (trait_any is Dictionary):
				continue
			var trait_data: Dictionary = trait_any
			var min_tech_points: float = float(trait_data.get("min_tech_points", 0.0))
			if tech_points < min_tech_points:
				continue
			var trait_name: String = str(trait_data.get("name", "")).strip_edges()
			var trait_desc: String = str(trait_data.get("description", "")).strip_edges()
			var stats_add_any: Variant = trait_data.get("stats_add", {})
			var stats_add: Dictionary = stats_add_any if stats_add_any is Dictionary else {}
			var cost_mul_any: Variant = trait_data.get("cost_per_soldier_mul", {})
			var cost_mul: Dictionary = cost_mul_any if cost_mul_any is Dictionary else {}
			var time_mul: float = float(trait_data.get("time_sec_per_100_mul", 1.0))
			active_traits.append({
				"id": str(trait_data.get("id", "")),
				"name": trait_name,
				"description": trait_desc,
				"min_tech_points": min_tech_points,
				"stats_add": stats_add.duplicate(true),
				"cost_per_soldier_mul": cost_mul.duplicate(true),
				"time_sec_per_100_mul": time_mul
			})

			for stat_key_any in stats_add.keys():
				var stat_key: String = str(stat_key_any)
				var add_value: float = float(stats_add.get(stat_key, 0.0))
				var merged: float = float(stats.get(stat_key, 0.0)) + add_value
				cumulative_stats_add[stat_key] = float(cumulative_stats_add.get(stat_key, 0.0)) + add_value
				if int_stat_keys.has(stat_key):
					stats[stat_key] = int(round(merged))
				else:
					stats[stat_key] = merged

			for cost_key_any in cost_mul.keys():
				var cost_key: String = str(cost_key_any)
				var mul: float = float(cost_mul.get(cost_key, 1.0))
				if mul <= 0.0:
					continue
				cost_per_soldier[cost_key] = float(cost_per_soldier.get(cost_key, 0.0)) * mul
				cumulative_cost_mul[cost_key] = float(cumulative_cost_mul.get(cost_key, 1.0)) * mul

			if time_mul > 0.0:
				time_sec_per_100 *= time_mul
				cumulative_time_mul *= time_mul

		unit["stats"] = stats
		unit["cost_per_soldier"] = cost_per_soldier
		unit["time_sec_per_100"] = maxf(1.0, time_sec_per_100)
		unit["tech_points"] = tech_points
		unit["tech_tier_active"] = active_traits.size()
		unit["tech_tier_total"] = class_traits.size()
		unit["tech_traits_active"] = active_traits
		unit["tech_effect_cumulative"] = {
			"stats_add": cumulative_stats_add,
			"cost_per_soldier_mul": cumulative_cost_mul,
			"time_sec_per_100_mul": cumulative_time_mul
		}
		unit["description"] = _build_regroup_unit_description(str(unit.get("base_description", unit.get("description", ""))), active_traits)
		units[unit_id] = unit

	for locked_unit_id_any in locked_unit_ids.keys():
		var locked_unit_id: String = str(locked_unit_id_any)
		if locked_unit_id.is_empty():
			continue
		units.erase(locked_unit_id)

	var categories_any: Variant = out.get("categories", [])
	if categories_any is Array:
		var categories: Array = (categories_any as Array).duplicate(true)
		for i in range(categories.size()):
			if not (categories[i] is Dictionary):
				continue
			var cat: Dictionary = (categories[i] as Dictionary).duplicate(true)
			var raw_units_any: Variant = cat.get("units", [])
			if not (raw_units_any is Array):
				categories[i] = cat
				continue
			var filtered_units: Array = []
			for unit_key_any in (raw_units_any as Array):
				var unit_key: String = str(unit_key_any)
				if unit_key.is_empty():
					continue
				if units.has(unit_key):
					filtered_units.append(unit_key)
			cat["units"] = filtered_units
			categories[i] = cat
		out["categories"] = categories

	var unit_aliases_any: Variant = out.get("unit_aliases", {})
	if unit_aliases_any is Dictionary:
		var unit_aliases: Dictionary = (unit_aliases_any as Dictionary).duplicate(true)
		for alias_key_any in unit_aliases.keys():
			var alias_key: String = str(alias_key_any)
			var target_id: String = str(unit_aliases.get(alias_key_any, ""))
			if target_id.is_empty() or units.has(target_id):
				continue
			unit_aliases.erase(alias_key)
		out["unit_aliases"] = unit_aliases

	out["units"] = units
	return out

func _build_regroup_unit_description(base_desc: String, active_traits: Array) -> String:
	var lines: Array[String] = []
	if not base_desc.is_empty():
		lines.append(base_desc)
	if active_traits.is_empty():
		lines.append("Tech traits active: none.")
		return "\n".join(lines)
	var trait_parts: Array[String] = []
	for trait_any in active_traits:
		if not (trait_any is Dictionary):
			continue
		var trait_data: Dictionary = trait_any
		var trait_name: String = str(trait_data.get("name", "")).strip_edges()
		if trait_name.is_empty():
			continue
		trait_parts.append(trait_name)
	if not trait_parts.is_empty():
		lines.append("Tech traits active: %s" % ", ".join(trait_parts))
	return "\n".join(lines)

func _as_regroup_entry_array(raw: Variant) -> Array:
	if raw is Array:
		return (raw as Array).duplicate(true)
	if raw is Dictionary:
		return [(raw as Dictionary).duplicate(true)]
	return []

func _pick_regroup_base_entry(entries: Array) -> Dictionary:
	var base_entry: Dictionary = {}
	var base_tier: int = 2147483647
	for entry_any in entries:
		if not (entry_any is Dictionary):
			continue
		var entry: Dictionary = entry_any
		var tier: int = int(entry.get("tier", 1))
		if base_entry.is_empty() or tier < base_tier:
			base_entry = entry.duplicate(true)
			base_tier = tier
	return base_entry

func _map_regroup_cost_per_soldier(source_cost_raw: Variant, resource_alias: Dictionary, class_extra_cost_raw: Variant) -> Dictionary:
	var out: Dictionary = {}
	if source_cost_raw is Dictionary:
		var source_cost: Dictionary = source_cost_raw
		for src_key_any in source_cost.keys():
			var src_key: String = str(src_key_any)
			var target_key: String = str(resource_alias.get(src_key, src_key))
			out[target_key] = float(out.get(target_key, 0.0)) + float(source_cost.get(src_key, 0.0))
	if class_extra_cost_raw is Dictionary:
		var class_extra_cost: Dictionary = class_extra_cost_raw
		for extra_key_any in class_extra_cost.keys():
			var extra_key: String = str(extra_key_any)
			var target_key: String = str(resource_alias.get(extra_key, extra_key))
			out[target_key] = float(out.get(target_key, 0.0)) + float(class_extra_cost.get(extra_key, 0.0))
	return out

func _canonical_regroup_unit_id(unit_id: String, dataset: Dictionary = {}) -> String:
	var normalized: String = unit_id.strip_edges()
	if normalized.is_empty():
		return ""
	var lookup_dataset: Dictionary = dataset
	if lookup_dataset.is_empty():
		lookup_dataset = _get_regroup_base_dataset()
	var unit_aliases: Dictionary = lookup_dataset.get("unit_aliases", {})
	if unit_aliases.has(normalized):
		return str(unit_aliases.get(normalized, normalized))
	var units: Dictionary = lookup_dataset.get("units", {})
	if units.has(normalized):
		return normalized
	var tier_token_pos: int = normalized.rfind("_t")
	if tier_token_pos > 0:
		var class_guess: String = normalized.substr(0, tier_token_pos)
		if units.has(class_guess):
			return class_guess
	return normalized

func _normalize_unit_composition(raw: Variant, dataset: Dictionary = {}) -> Dictionary:
	var source: Dictionary = (raw as Dictionary).duplicate(true) if raw is Dictionary else {}
	if source.is_empty():
		return {}
	var lookup_dataset: Dictionary = dataset
	if lookup_dataset.is_empty():
		lookup_dataset = _get_regroup_base_dataset()
	var out: Dictionary = {}
	for unit_id_any in source.keys():
		var unit_id: String = str(unit_id_any)
		var canonical_id: String = _canonical_regroup_unit_id(unit_id, lookup_dataset)
		if canonical_id.is_empty():
			continue
		var amount: float = float(source.get(unit_id_any, 0.0))
		if amount <= 0.0:
			continue
		out[canonical_id] = float(out.get(canonical_id, 0.0)) + amount
	return out

func _default_regroup_category_label(class_id: String) -> String:
	match class_id:
		"cavalry":
			return "cavalry"
		"spear":
			return "spear"
		"shield":
			return "shield"
		"bow":
			return "bow"
		"crossbow":
			return "crossbow"
		"strategist":
			return "strategist"
		"engine":
			return "engine"
		"ship":
			return "ship"
		"scout":
			return "scout"
		_:
			return class_id

func _is_regroup_siege_class_id(class_id: String, rules: Dictionary = {}) -> bool:
	var key: String = class_id.to_lower().strip_edges()
	if key.is_empty():
		return false
	var key_set: Dictionary = {}
	for default_id in REGROUP_DEFAULT_SIEGE_CLASS_IDS:
		var item: String = str(default_id).to_lower().strip_edges()
		if not item.is_empty():
			key_set[item] = true
	var ref_rules: Dictionary = rules
	if ref_rules.is_empty():
		ref_rules = _rules_by_key.get("regroup", {})
	var raw_ids: Variant = ref_rules.get("siege_equipment_class_ids", [])
	if raw_ids is Array:
		for item_any in (raw_ids as Array):
			var item: String = str(item_any).to_lower().strip_edges()
			if item.is_empty():
				continue
			key_set[item] = true
	return key_set.has(key)

func _is_regroup_siege_equipment_unit(unit: Dictionary) -> bool:
	if unit.is_empty():
		return false
	if bool(unit.get("is_siege_equipment", false)):
		return true
	var class_id: String = str(unit.get("class_id", unit.get("id", "")))
	return _is_regroup_siege_class_id(class_id)

func _regroup_siege_unit_durability_cap(unit: Dictionary) -> float:
	if unit.is_empty():
		return REGROUP_DEFAULT_SIEGE_DURABILITY_MAX
	if unit.has("durability_max"):
		return maxf(0.0, float(unit.get("durability_max", REGROUP_DEFAULT_SIEGE_DURABILITY_MAX)))
	return REGROUP_DEFAULT_SIEGE_DURABILITY_MAX

func _calc_regroup_unit_cost_for_amount(unit: Dictionary, amount: int) -> Dictionary:
	var out: Dictionary = {}
	if amount <= 0:
		return out
	if unit.has("cost_per_soldier"):
		var cps: Dictionary = unit.get("cost_per_soldier", {})
		for key_any in cps.keys():
			var key: String = str(key_any)
			out[key] = float(cps.get(key, 0.0)) * float(amount)
		return out
	var batch_size: int = maxi(1, int(unit.get("batch_size", 100)))
	var batches: float = float(amount) / float(batch_size)
	var cpb: Dictionary = unit.get("cost_per_batch", {})
	for key_any in cpb.keys():
		var key: String = str(key_any)
		out[key] = float(cpb.get(key, 0.0)) * batches
	return out

func _on_aide_batch_change_requested(city_id: String, changes: Array) -> void:
	if _phase != "internal":
		_status_message = ""
		_refresh_presentation()
		return
	if changes.is_empty():
		_status_message = ""
		_refresh_presentation()
		return

	var city: Dictionary = _find_city(city_id)
	if city.is_empty() or str(city.get("faction_id", "")) != _get_player_faction_id():
		_status_message = ""
		_refresh_presentation()
		return

	var roster: Array = city.get("officer_roster", [])
	if roster.is_empty():
		_status_message = ""
		_refresh_presentation()
		return

	var assignments: Dictionary = _get_city_assignments(city, roster)
	var personnel: Dictionary = city.get("personnel", {}).duplicate(true)
	var officers_score: Dictionary = city.get("officers", {}).duplicate(true)

	var valid_changes: Array = []
	for change_any in changes:
		if not (change_any is Dictionary):
			continue
		var change: Dictionary = change_any
		var role_id: String = str(change.get("role_id", ""))
		var officer_id: String = str(change.get("officer_id", ""))
		if not _is_valid_aide_role(role_id):
			continue
		var before_id: String = str(assignments.get(role_id, ""))
		if before_id == officer_id:
			continue
		var officer: Dictionary = {}
		if not officer_id.is_empty():
			officer = _find_officer_by_id(roster, officer_id)
			if officer.is_empty():
				continue
		valid_changes.append({
			"role_id": role_id,
			"officer_id": officer_id,
			"officer": officer
		})
	if valid_changes.is_empty():
		_status_message = ""
		_refresh_presentation()
		return

	var total_cost: float = _command_cost_city_action * float(valid_changes.size())
	if not _logic.consume_command_points(total_cost):
		_status_message = ""
		_refresh_presentation()
		return

	var last_role_id: String = "taishou"
	var last_officer_id: String = ""
	for entry_any in valid_changes:
		var entry: Dictionary = entry_any
		var role_id: String = str(entry.get("role_id", ""))
		var officer_id: String = str(entry.get("officer_id", ""))
		var officer: Dictionary = entry.get("officer", {})
		last_role_id = role_id
		last_officer_id = officer_id
		if officer_id.is_empty():
			assignments.erase(role_id)
			officers_score[role_id] = 50.0
			if role_id == "taishou":
				personnel["governor_name"] = "-"
		else:
			assignments[role_id] = officer_id
			officers_score[role_id] = _officer_role_score(officer, role_id)
			if role_id == "taishou":
				personnel["governor_name"] = str(officer.get("name", "-"))

	personnel["assignments"] = assignments
	personnel["officer_count"] = roster.size()
	var patch: Dictionary = {
		"personnel": personnel,
		"officers": officers_score
	}
	_logic.apply_city_patch(city_id, patch, "aides_panel_batch")
	_snapshot = _logic.get_world_snapshot()
	_open_aides_panel(city_id, last_role_id, last_officer_id)
	_status_message = ""
	_refresh_presentation()

func _on_aide_change_requested(city_id: String, role_id: String, officer_id: String) -> void:
	if _phase != "internal":
		_refresh_presentation()
		return
	if not _is_valid_aide_role(role_id):
		_refresh_presentation()
		return
	var city: Dictionary = _find_city(city_id)
	if city.is_empty() or str(city.get("faction_id", "")) != _get_player_faction_id():
		_refresh_presentation()
		return
	var roster: Array = city.get("officer_roster", [])
	var target_officer: Dictionary = {}
	if not officer_id.is_empty():
		target_officer = _find_officer_by_id(roster, officer_id)
		if target_officer.is_empty():
			_refresh_presentation()
			return
	if not _logic.consume_command_points(_command_cost_city_action):
		_refresh_presentation()
		return
	var assignments: Dictionary = _get_city_assignments(city, roster)
	var personnel: Dictionary = city.get("personnel", {}).duplicate(true)
	var officers_score: Dictionary = city.get("officers", {}).duplicate(true)
	if officer_id.is_empty():
		assignments.erase(role_id)
		officers_score[role_id] = 50.0
		if role_id == "taishou":
			personnel["governor_name"] = "-"
	else:
		assignments[role_id] = officer_id
		officers_score[role_id] = _officer_role_score(target_officer, role_id)
		if role_id == "taishou":
			personnel["governor_name"] = str(target_officer.get("name", "-"))
	personnel["assignments"] = assignments
	personnel["officer_count"] = roster.size()
	_logic.apply_city_patch(city_id, {
		"personnel": personnel,
		"officers": officers_score
	}, "aides_panel_single")
	_snapshot = _logic.get_world_snapshot()
	_open_aides_panel(city_id, role_id, officer_id)
	_refresh_presentation()

func _update_hover_info() -> void:
	if _ui_layer == null or _map_view == null:
		return
	var hovered: Control = get_viewport().gui_get_hovered_control()
	if hovered != null and _ui_layer.is_pointer_over_interactive_ui(hovered):
		_ui_layer.hide_hover_info()
		return
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var building_id: String = _map_view.pick_building_from_screen(mouse_pos)
	if building_id.is_empty():
		_ui_layer.hide_hover_info()
		return
	_ui_layer.show_hover_info(mouse_pos, _compose_building_hover_text(building_id))

func _on_preload_progress(progress: float) -> void:
	_preload_progress = clampf(progress, 0.0, 1.0)
	if _ui_layer != null:
		_ui_layer.refresh(_snapshot, _selected_building_id, _build_hud_state())

func _on_preload_finished() -> void:
	_preload_progress = 1.0
	if _ui_layer != null:
		_ui_layer.refresh(_snapshot, _selected_building_id, _build_hud_state())

func _on_regroup_plan_confirmed(city_id: String, plans: Array) -> void:
	if _phase != "internal":
		return
	var city: Dictionary = _find_city(city_id)
	if city.is_empty() or str(city.get("faction_id", "")) != _get_player_faction_id():
		return
	var result: Dictionary = _evaluate_regroup_plan(city, plans)
	if not bool(result.get("ok", false)):
		var reason: String = str(result.get("reason", ""))
		if reason == "siege_durability_cap":
			_status_message = "器械维修超出耐久上限。"
		_refresh_presentation()
		return
	if not _logic.consume_command_points(_command_cost_city_action):
		_refresh_presentation()
		return
	var stats: Dictionary = city.get("stats", {}).duplicate(true)
	stats["reserve_troops"] = float(result.get("reserve_after", stats.get("reserve_troops", 0.0)))
	stats["organized_troops"] = float(result.get("organized_after", stats.get("organized_troops", 0.0)))
	stats["troops"] = float(stats.get("reserve_troops", 0.0)) + float(stats.get("organized_troops", 0.0))
	_logic.apply_city_patch(city_id, {
		"resources": result.get("resources_after", {}).duplicate(true),
		"stats": stats,
		"siege_durability": result.get("siege_durability_after", city.get("siege_durability", {})).duplicate(true),
		"unit_composition": result.get("unit_composition_after", {}).duplicate(true)
	}, "regroup_panel")
	_snapshot = _logic.get_world_snapshot()
	if _ui_layer != null:
		_ui_layer.hide_command_panel()
	_refresh_presentation()

func _on_proceed_battle_requested() -> void:
	_enter_battle_phase()

func _on_battle_pause_toggled(paused: bool) -> void:
	_battle_paused = paused
	_apply_global_time_scale()
	_apply_battle_pause_state()
	if _ui_layer != null:
		_ui_layer.refresh(_snapshot, _selected_building_id, _build_hud_state())

func _on_battle_speed_requested(speed: float) -> void:
	_battle_speed = clampf(speed, 0.25, 8.0)
	_apply_global_time_scale()
	if _ui_layer != null:
		_ui_layer.refresh(_snapshot, _selected_building_id, _build_hud_state())

func _get_building_units() -> Array:
	var out: Array = []
	for city_any in _snapshot.get("cities", []):
		if city_any is Dictionary:
			var city: Dictionary = city_any
			var city_classification_any: Variant = city.get("classification", {})
			var city_classification: Dictionary = (city_classification_any as Dictionary).duplicate(true) if city_classification_any is Dictionary else {}
			var city_stats_any: Variant = city.get("stats", {})
			var city_stats: Dictionary = (city_stats_any as Dictionary).duplicate(true) if city_stats_any is Dictionary else {}
			out.append({
				"id": str(city.get("id", "")),
				"city_id": str(city.get("id", "")),
				"name": str(city.get("name", "")),
				"faction_id": str(city.get("faction_id", "")),
				"type": "city",
				"position": city.get("position", {}).duplicate(true),
				"classification": city_classification,
				"stats": city_stats,
				"defense": city_stats.get("defense", city.get("defense", -1.0)),
				"troops": city_stats.get("troops", city.get("troops", -1.0))
			})
	for unit_any in _snapshot.get("building_units", []):
		if unit_any is Dictionary:
			out.append((unit_any as Dictionary).duplicate(true))
	return out

func _refresh_supply_fog_runtime() -> void:
	if _snapshot.is_empty():
		return
	_snapshot["supply_fog"] = _build_supply_fog_snapshot()

func _build_supply_fog_snapshot() -> Dictionary:
	var fallback: Dictionary = {
		"enabled": false,
		"site_visible": {},
		"site_ranges": {},
		"in_supply_site_ids": [],
		"in_supply_by_faction": {},
		"supply_edges": [],
		"reveal_centers": [],
		"vision_context": _runtime_weather_visibility_context()
	}
	var rules: Dictionary = _supply_fog_rules if not _supply_fog_rules.is_empty() else _build_supply_fog_rules({})
	if not bool(rules.get("enabled", true)):
		return fallback

	var nodes_by_id: Dictionary = {}
	for candidate_any in _collect_supply_node_candidates():
		if not (candidate_any is Dictionary):
			continue
		var node: Dictionary = _normalize_supply_node(candidate_any as Dictionary)
		if node.is_empty():
			continue
		var node_id: String = str(node.get("id", ""))
		if node_id.is_empty():
			continue
		if nodes_by_id.has(node_id):
			var merged: Dictionary = (nodes_by_id[node_id] as Dictionary).duplicate(true)
			if str(merged.get("faction_id", "")).is_empty():
				merged["faction_id"] = str(node.get("faction_id", ""))
			if str(merged.get("name", "")).is_empty():
				merged["name"] = str(node.get("name", node_id))
			if str(merged.get("type", "")).is_empty():
				merged["type"] = str(node.get("type", "site"))
			if not merged.has("position") and node.has("position"):
				merged["position"] = (node.get("position", {}) as Dictionary).duplicate(true)
			nodes_by_id[node_id] = merged
			continue
		nodes_by_id[node_id] = node

	if nodes_by_id.is_empty():
		return fallback

	var node_ids: Array[String] = []
	var node_pos_by_id: Dictionary = {}
	var node_faction_by_id: Dictionary = {}
	var node_range_by_id: Dictionary = {}
	var faction_node_ids: Dictionary = {}
	for node_id_any in nodes_by_id.keys():
		var node_id: String = str(node_id_any)
		var node: Dictionary = (nodes_by_id[node_id] as Dictionary).duplicate(true)
		var pos: Vector2 = _site_position_2d(node)
		node_ids.append(node_id)
		node_pos_by_id[node_id] = pos
		var faction_id: String = str(node.get("faction_id", ""))
		node_faction_by_id[node_id] = faction_id
		node_range_by_id[node_id] = _supply_range_for_node(node)
		if not faction_id.is_empty():
			var faction_list: Array = faction_node_ids.get(faction_id, [])
			faction_list.append(node_id)
			faction_node_ids[faction_id] = faction_list

	var adjacency: Dictionary = {}
	for node_id in node_ids:
		adjacency[node_id] = []
	var edges: Array = []
	var link_mul: float = maxf(0.1, float(rules.get("link_distance_mul", 1.0)))
	var link_max: float = maxf(120.0, float(rules.get("link_distance_max", 7000.0)))
	for i in range(node_ids.size()):
		var id_a: String = node_ids[i]
		var faction_a: String = str(node_faction_by_id.get(id_a, ""))
		if faction_a.is_empty():
			continue
		var pos_a: Vector2 = node_pos_by_id.get(id_a, Vector2.ZERO)
		var range_a: float = float(node_range_by_id.get(id_a, 0.0))
		for j in range(i + 1, node_ids.size()):
			var id_b: String = node_ids[j]
			var faction_b: String = str(node_faction_by_id.get(id_b, ""))
			if faction_a != faction_b:
				continue
			var pos_b: Vector2 = node_pos_by_id.get(id_b, Vector2.ZERO)
			var range_b: float = float(node_range_by_id.get(id_b, 0.0))
			var link_distance: float = minf(link_max, (range_a + range_b) * link_mul)
			if pos_a.distance_to(pos_b) > link_distance:
				continue
			var adj_a: Array = adjacency.get(id_a, [])
			adj_a.append(id_b)
			adjacency[id_a] = adj_a
			var adj_b: Array = adjacency.get(id_b, [])
			adj_b.append(id_a)
			adjacency[id_b] = adj_b
			edges.append({
				"a": id_a,
				"b": id_b,
				"faction_id": faction_a
			})

	var source_node_ids_by_faction: Dictionary = {}
	for faction_any in faction_node_ids.keys():
		var faction_id: String = str(faction_any)
		var ids_any: Variant = faction_node_ids.get(faction_id, [])
		if not (ids_any is Array):
			continue
		var source_ids: Array = []
		for node_id_any in (ids_any as Array):
			var node_id: String = str(node_id_any)
			var node: Dictionary = (nodes_by_id.get(node_id, {}) as Dictionary).duplicate(true)
			if _is_supply_source_node(node):
				source_ids.append(node_id)
		if source_ids.is_empty() and not (ids_any as Array).is_empty():
			source_ids.append(str((ids_any as Array)[0]))
		source_node_ids_by_faction[faction_id] = source_ids

	var in_supply_by_faction: Dictionary = {}
	var in_supply_site_flags: Dictionary = {}
	for faction_any in faction_node_ids.keys():
		var faction_id: String = str(faction_any)
		var sources_any: Variant = source_node_ids_by_faction.get(faction_id, [])
		if not (sources_any is Array):
			continue
		var visited: Dictionary = {}
		var stack: Array = (sources_any as Array).duplicate(true)
		while not stack.is_empty():
			var current: String = str(stack.pop_back())
			if current.is_empty() or visited.has(current):
				continue
			visited[current] = true
			in_supply_site_flags[current] = true
			var neighbors_any: Variant = adjacency.get(current, [])
			if not (neighbors_any is Array):
				continue
			for next_any in (neighbors_any as Array):
				var next_id: String = str(next_any)
				if next_id.is_empty() or visited.has(next_id):
					continue
				stack.append(next_id)
		in_supply_by_faction[faction_id] = visited.keys()

	var in_supply_site_ids: Array = []
	for node_id_any in in_supply_site_flags.keys():
		in_supply_site_ids.append(str(node_id_any))

	var player_faction_id: String = _get_player_faction_id()
	var player_faction_ids_any: Variant = faction_node_ids.get(player_faction_id, [])
	var player_faction_ids: Array = player_faction_ids_any if player_faction_ids_any is Array else []
	var vision_ctx: Dictionary = _runtime_weather_visibility_context()
	var visibility_mul: float = clampf(float(vision_ctx.get("visibility_mul", 1.0)), 0.15, 2.0)
	var reveal_centers: Array = []
	for node_id_any in player_faction_ids:
		var node_id: String = str(node_id_any)
		var node: Dictionary = (nodes_by_id.get(node_id, {}) as Dictionary).duplicate(true)
		if not _is_player_vision_source_node(node):
			continue
		var pos: Vector2 = node_pos_by_id.get(node_id, Vector2.ZERO)
		var range_now: float = float(node_range_by_id.get(node_id, 0.0))
		reveal_centers.append({"x": pos.x, "z": pos.y, "range": maxf(120.0, range_now * visibility_mul)})

	var reveal_mul: float = maxf(0.1, float(rules.get("enemy_reveal_range_mul", 1.0)))
	var reveal_padding: float = maxf(0.0, float(rules.get("enemy_reveal_padding", 280.0)))
	var reveal_min_distance: float = maxf(0.0, float(rules.get("enemy_reveal_min_distance", 680.0)) * visibility_mul)
	var site_visible: Dictionary = {}
	for node_id in node_ids:
		var node: Dictionary = (nodes_by_id.get(node_id, {}) as Dictionary).duplicate(true)
		var faction_id: String = str(node.get("faction_id", ""))
		var enemy: bool = not faction_id.is_empty() and faction_id != player_faction_id
		var hidden_by_fog: bool = enemy and (_is_granary_site(node) or _is_convoy_site(node) or _is_troop_site(node))
		if not hidden_by_fog:
			site_visible[node_id] = true
			continue
		var pos: Vector2 = node_pos_by_id.get(node_id, Vector2.ZERO)
		site_visible[node_id] = _is_point_revealed_by_supply(pos, reveal_centers, reveal_mul, reveal_padding, reveal_min_distance)

	return {
		"enabled": true,
		"site_visible": site_visible,
		"site_ranges": node_range_by_id,
		"in_supply_site_ids": in_supply_site_ids,
		"in_supply_by_faction": in_supply_by_faction,
		"supply_edges": edges,
		"reveal_centers": reveal_centers,
		"vision_context": vision_ctx
	}

func _collect_supply_node_candidates() -> Array:
	var out: Array = _get_building_units()
	if _map_view != null and _map_view.has_method("get_all_site_snapshots"):
		var extra_any: Variant = _map_view.call("get_all_site_snapshots")
		if extra_any is Array:
			for site_any in (extra_any as Array):
				if site_any is Dictionary:
					out.append((site_any as Dictionary).duplicate(true))
	return out

func _normalize_supply_node(raw: Dictionary) -> Dictionary:
	if raw.is_empty():
		return {}
	var node: Dictionary = raw.duplicate(true)
	var node_id: String = str(node.get("id", node.get("city_id", ""))).strip_edges()
	if node_id.is_empty():
		return {}
	node["id"] = node_id
	node["name"] = str(node.get("name", node_id))
	node["type"] = str(node.get("type", "site")).to_lower()
	node["faction_id"] = str(node.get("faction_id", ""))
	var pos_any: Variant = node.get("position", {})
	var pos: Dictionary = (pos_any as Dictionary).duplicate(true) if pos_any is Dictionary else {}
	node["position"] = {
		"x": float(pos.get("x", 0.0)),
		"z": float(pos.get("z", 0.0))
	}
	return node

func _site_position_2d(node: Dictionary) -> Vector2:
	var pos_any: Variant = node.get("position", {})
	if not (pos_any is Dictionary):
		return Vector2.ZERO
	var pos: Dictionary = pos_any
	return Vector2(float(pos.get("x", 0.0)), float(pos.get("z", 0.0)))

func _supply_range_for_node(node: Dictionary) -> float:
	var rules: Dictionary = _supply_fog_rules if not _supply_fog_rules.is_empty() else _build_supply_fog_rules({})
	var by_type_any: Variant = rules.get("base_range_by_type", {})
	var by_type: Dictionary = by_type_any if by_type_any is Dictionary else {}
	var type_key: String = str(node.get("type", "site")).to_lower()
	var base_range: float = float(by_type.get(type_key, rules.get("base_range_default", 2200.0)))
	if _is_granary_site(node):
		base_range += float(rules.get("granary_range_bonus", 1300.0))
	if _is_convoy_site(node):
		base_range += float(rules.get("convoy_range_bonus", 1700.0))
	return maxf(120.0, base_range)

func _is_supply_source_node(node: Dictionary) -> bool:
	if bool(node.get("is_supply_source", false)):
		return true
	return str(node.get("type", "")).to_lower() == "city"

func _is_granary_site(node: Dictionary) -> bool:
	if bool(node.get("is_granary", false)):
		return true
	var text: String = _supply_identity_text(node)
	return _contains_any_keyword(text, SUPPLY_FOG_GRANARY_KEYWORDS)

func _is_convoy_site(node: Dictionary) -> bool:
	if bool(node.get("is_supply_convoy", false)):
		return true
	var text: String = _supply_identity_text(node)
	return _contains_any_keyword(text, SUPPLY_FOG_CONVOY_KEYWORDS)

func _is_troop_site(node: Dictionary) -> bool:
	if bool(node.get("is_field_troop", false)):
		return true
	var type_key: String = str(node.get("type", "")).to_lower()
	if type_key == "army" or type_key == "troop" or type_key == "field_unit":
		return true
	var text: String = _supply_identity_text(node)
	return _contains_any_keyword(text, SUPPLY_FOG_TROOP_KEYWORDS)

func _is_player_vision_source_node(node: Dictionary) -> bool:
	if node.is_empty():
		return false
	if _is_troop_site(node):
		return true
	var type_key: String = str(node.get("type", "")).to_lower().strip_edges()
	if type_key == "city" or type_key == "pass" or type_key == "fort" or type_key == "ferry" or type_key == "resource" or type_key == "site" or type_key == "stronghold" or type_key == "outpost":
		return true
	return false

func _supply_identity_text(node: Dictionary) -> String:
	var chunks: Array[String] = []
	chunks.append(str(node.get("id", "")))
	chunks.append(str(node.get("name", "")))
	chunks.append(str(node.get("type", "")))
	return "|".join(chunks).to_lower()

func _contains_any_keyword(source_text: String, keywords: Array) -> bool:
	if source_text.is_empty():
		return false
	for keyword_any in keywords:
		var keyword: String = str(keyword_any).to_lower().strip_edges()
		if keyword.is_empty():
			continue
		if source_text.find(keyword) != -1:
			return true
	return false

func _is_point_revealed_by_supply(point: Vector2, reveal_centers: Array, reveal_mul: float, reveal_padding: float, reveal_min_distance: float) -> bool:
	for center_any in reveal_centers:
		if not (center_any is Dictionary):
			continue
		var center: Dictionary = center_any
		var center_pos := Vector2(float(center.get("x", 0.0)), float(center.get("z", 0.0)))
		var reveal_radius: float = maxf(reveal_min_distance, float(center.get("range", 0.0)) * reveal_mul + reveal_padding)
		if point.distance_to(center_pos) <= reveal_radius:
			return true
	return false

func _find_building_unit(building_id: String) -> Dictionary:
	for unit_any in _get_building_units():
		if unit_any is Dictionary and str((unit_any as Dictionary).get("id", "")) == building_id:
			return (unit_any as Dictionary).duplicate(true)
	return {}

func _is_player_command_building(building_ref) -> bool:
	var building: Dictionary = {}
	if building_ref is Dictionary:
		building = (building_ref as Dictionary).duplicate(true)
	else:
		building = _find_building_any(str(building_ref))
	if building.is_empty():
		return false
	var faction_id: String = str(building.get("faction_id", ""))
	if faction_id.is_empty():
		return true
	return faction_id == _get_player_faction_id()
func _find_city(city_id: String) -> Dictionary:
	for city_any in _snapshot.get("cities", []):
		if city_any is Dictionary and str((city_any as Dictionary).get("id", "")) == city_id:
			return (city_any as Dictionary).duplicate(true)
	return {}

func _find_outpost_building(building_id: String) -> Dictionary:
	for unit_any in _snapshot.get("building_units", []):
		if unit_any is Dictionary and str((unit_any as Dictionary).get("id", "")) == building_id:
			return (unit_any as Dictionary).duplicate(true)
	var site_snapshot: Dictionary = _find_map_view_site_snapshot(building_id)
	if site_snapshot.is_empty() or str(site_snapshot.get("type", "")) == "city":
		return {}
	return _build_virtual_outpost_from_site(site_snapshot)
func _find_map_view_site_snapshot(building_id: String) -> Dictionary:
	if _map_view == null or not _map_view.has_method("get_building_snapshot"):
		return {}
	var snapshot_any: Variant = _map_view.call("get_building_snapshot", building_id)
	if not (snapshot_any is Dictionary):
		return {}
	return (snapshot_any as Dictionary).duplicate(true)

func _build_virtual_outpost_from_site(site: Dictionary) -> Dictionary:
	if site.is_empty():
		return {}
	var site_id: String = str(site.get("id", site.get("city_id", "")))
	if site_id.is_empty():
		return {}
	var faction_id: String = str(site.get("faction_id", ""))
	if faction_id.is_empty():
		faction_id = _get_player_faction_id()
	var position_any: Variant = site.get("position", {})
	var position: Dictionary = (position_any as Dictionary).duplicate(true) if position_any is Dictionary else {}
	var resources_any: Variant = site.get("resources", {})
	var resources: Dictionary = (resources_any as Dictionary).duplicate(true) if resources_any is Dictionary else {}
	if resources.is_empty():
		resources = {"money": 0.0, "food": 0.0, "iron": 0.0, "wood": 0.0, "horse": 0.0}
	var stats_any: Variant = site.get("stats", {})
	var stats: Dictionary = (stats_any as Dictionary).duplicate(true) if stats_any is Dictionary else {}
	if stats.is_empty():
		stats = {"reserve_troops": 0.0, "organized_troops": 0.0, "troops": 0.0}
	elif not stats.has("troops"):
		stats["troops"] = float(stats.get("reserve_troops", 0.0)) + float(stats.get("organized_troops", 0.0))
	var unit_comp_any: Variant = site.get("unit_composition", {})
	var unit_composition: Dictionary = _normalize_unit_composition(unit_comp_any)
	var personnel_any: Variant = site.get("personnel", {})
	var personnel: Dictionary = (personnel_any as Dictionary).duplicate(true) if personnel_any is Dictionary else {}
	if personnel.is_empty():
		personnel = {"governor_name": "-", "assignments": {}, "officer_count": 0}
	var roster_any: Variant = site.get("officer_roster", [])
	var roster: Array = (roster_any as Array).duplicate(true) if roster_any is Array else []
	return {
		"id": site_id,
		"city_id": str(site.get("city_id", site_id)),
		"name": str(site.get("name", site_id)),
		"type": str(site.get("type", "fort")),
		"faction_id": faction_id,
		"state": str(site.get("state", "")),
		"position": position,
		"resources": resources,
		"stats": stats,
		"unit_composition": unit_composition,
		"personnel": personnel,
		"officer_roster": roster
	}

func _find_building_any(building_id: String) -> Dictionary:
	var city: Dictionary = _find_city(building_id)
	if not city.is_empty():
		city["type"] = "city"
		return city
	return _find_outpost_building(building_id)

func _get_player_faction_id() -> String:
	return str(_snapshot.get("meta", {}).get("player_faction_id", ""))

func _open_regroup_panel(city_id: String) -> void:
	if _ui_layer == null:
		return
	var city: Dictionary = _find_city(city_id)
	if city.is_empty():
		return
	var dataset: Dictionary = _build_regroup_dataset(city)
	_ui_layer.show_command_panel("regroup", {
		"title": "regroup",
		"city_id": city_id,
		"city_name": str(city.get("name", city_id)),
		"categories": dataset.get("categories", []).duplicate(true),
		"units": dataset.get("units", {}).duplicate(true),
		"city_resources": city.get("resources", {}).duplicate(true),
		"reserve_troops": float(city.get("stats", {}).get("reserve_troops", 0.0)),
		"organized_troops": float(city.get("stats", {}).get("organized_troops", 0.0)),
		"siege_durability": city.get("siege_durability", {}).duplicate(true)
	})

func _open_expedition_panel(city_id: String) -> void:
	if _ui_layer == null:
		return
	var city: Dictionary = _find_city(city_id)
	if city.is_empty():
		return
	var roster: Array = _build_city_roster_with_master(city.get("officer_roster", []))
	var meta: Dictionary = _logic.get_meta_snapshot()
	var city_orders_any: Variant = meta.get("city_orders", {})
	var city_orders: Dictionary = city_orders_any as Dictionary if city_orders_any is Dictionary else {}
	var order_any: Variant = city_orders.get(city_id, {})
	var order_entry: Dictionary = (order_any as Dictionary).duplicate(true) if order_any is Dictionary else {}
	_ui_layer.show_command_panel("expedition_prepare", {
		"title": "出征编成",
		"city_id": city_id,
		"city_name": str(city.get("name", city_id)),
		"officers": roster,
		"selected_officer_ids": order_entry.get("officer_ids", []),
		"ship_options": [
			{"id": "zouge", "label": "走舸"},
			{"id": "lou_chuan", "label": "楼船"}
		],
		"selected_ship_type": str(order_entry.get("ship_type", "zouge")),
		"cancel_text": "返回",
		"decide_text": "确认出征"
	})

func _is_move_sub_action(action_id: String) -> bool:
	return action_id == "move_dispatch" or action_id == "move_recall" or action_id == "move_transport_resources" or action_id == "move_transport_troops"

func _open_move_panel(from_city_id: String, action_id: String) -> void:
	if _ui_layer == null:
		return
	var city: Dictionary = _find_city(from_city_id)
	var outpost: Dictionary = {}
	var source_is_city := not city.is_empty()
	if not source_is_city:
		outpost = _find_outpost_building(from_city_id)
	if not source_is_city and outpost.is_empty():
		return
	var source: Dictionary = city if source_is_city else _get_outpost_move_state(from_city_id)
	var title_map := {
		"move_dispatch": "dispatch",
		"move_recall": "recall",
		"move_transport_resources": "transport_resources",
		"move_transport_troops": "transport_troops"
	}
	var targets: Array = _collect_move_targets(from_city_id)
	var selected_target_city_id: String = ""
	if not targets.is_empty() and targets[0] is Dictionary:
		selected_target_city_id = str((targets[0] as Dictionary).get("city_id", ""))
	var source_siege_any: Variant = source.get("siege_durability", {})
	var source_siege_durability: Dictionary = (source_siege_any as Dictionary).duplicate(true) if source_siege_any is Dictionary else {}
	var regroup_city: Dictionary = city if source_is_city else {}
	var regroup_dataset: Dictionary = _build_regroup_dataset(regroup_city)
	var source_siege_durability_caps: Dictionary = _build_siege_durability_caps_from_dataset(regroup_dataset)
	_ui_layer.show_command_panel(action_id, {
		"title": str(title_map.get(action_id, "move")),
		"move_mode": action_id,
		"from_city_id": from_city_id,
		"from_city_name": str((city if source_is_city else outpost).get("name", from_city_id)),
		"targets": targets,
		"source_officers": source.get("officer_roster", []).duplicate(true),
		"source_resources": source.get("resources", {}).duplicate(true),
		"source_stats": source.get("stats", {}).duplicate(true),
		"source_unit_composition": _normalize_unit_composition(source.get("unit_composition", {})),
		"source_siege_durability": source_siege_durability,
		"source_siege_durability_caps": source_siege_durability_caps,
		"selected_target_city_id": selected_target_city_id
	})

func _build_siege_durability_caps_from_dataset(dataset: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	if dataset.is_empty():
		return out
	var units_any: Variant = dataset.get("units", {})
	if not (units_any is Dictionary):
		return out
	var units: Dictionary = units_any as Dictionary
	for unit_id_any in units.keys():
		var unit_id: String = str(unit_id_any)
		var unit_any: Variant = units.get(unit_id_any, {})
		if unit_id.is_empty() or not (unit_any is Dictionary):
			continue
		var unit: Dictionary = unit_any as Dictionary
		if not _is_regroup_siege_equipment_unit(unit):
			continue
		out[unit_id] = _regroup_siege_unit_durability_cap(unit)
	return out

func _unique_string_array(raw: Array) -> Array[String]:
	var out: Array[String] = []
	var seen: Dictionary = {}
	for value_any in raw:
		var value: String = str(value_any)
		if value.is_empty() or seen.has(value):
			continue
		seen[value] = true
		out.append(value)
	return out

func _set_master_officers(raw: Variant) -> void:
	_master_officers = []
	_master_officers_by_id.clear()
	if not (raw is Array):
		return
	for officer_any in (raw as Array):
		if not (officer_any is Dictionary):
			continue
		var officer: Dictionary = (officer_any as Dictionary).duplicate(true)
		var officer_id: String = str(officer.get("id", ""))
		if officer_id.is_empty():
			continue
		if _master_officers_by_id.has(officer_id):
			continue
		_master_officers.append(officer)
		_master_officers_by_id[officer_id] = officer

func _merge_city_officer_with_master(officer_raw: Dictionary) -> Dictionary:
	var out: Dictionary = officer_raw.duplicate(true)
	var officer_id: String = str(out.get("id", ""))
	if officer_id.is_empty():
		return out
	var master: Dictionary = _master_officers_by_id.get(officer_id, {}) if _master_officers_by_id.get(officer_id, {}) is Dictionary else {}
	if master.is_empty():
		return out
	if str(out.get("name", "")).is_empty() and not str(master.get("name", "")).is_empty():
		out["name"] = master.get("name", "")
	if not out.has("stats") and master.has("stats"):
		out["stats"] = master.get("stats", {}).duplicate(true)
	if not out.has("battle_personality") and master.has("battle_personality"):
		out["battle_personality"] = master.get("battle_personality", {}).duplicate(true)
	if not out.has("domestic_personality") and master.has("domestic_personality"):
		out["domestic_personality"] = master.get("domestic_personality", "")
	if not out.has("birth_year") and master.has("birth_year"):
		out["birth_year"] = master.get("birth_year", 0)
	if not out.has("birth_month") and master.has("birth_month"):
		out["birth_month"] = master.get("birth_month", 0)
	if not out.has("birth") and master.has("birth"):
		out["birth"] = master.get("birth", {}).duplicate(true)
	if not out.has("officer_skill") and master.has("officer_skill"):
		out["officer_skill"] = master.get("officer_skill", "")
	if not out.has("skills") and master.has("skills"):
		out["skills"] = master.get("skills", []).duplicate(true)
	if not out.has("aptitude") and master.has("aptitude"):
		out["aptitude"] = master.get("aptitude", {}).duplicate(true)
	if not out.has("relations") and master.has("relations"):
		out["relations"] = master.get("relations", {}).duplicate(true)
	return out

func _build_city_roster_with_master(raw_roster: Array) -> Array:
	var out: Array = []
	for officer_any in raw_roster:
		if not (officer_any is Dictionary):
			continue
		out.append(_merge_city_officer_with_master(officer_any as Dictionary))
	return out

func _find_officer_by_id(roster: Array, officer_id: String) -> Dictionary:
	for officer_any in roster:
		if officer_any is Dictionary and str((officer_any as Dictionary).get("id", "")) == officer_id:
			return (officer_any as Dictionary).duplicate(true)
	return {}

func _find_officer_by_name(officer_name: String) -> Dictionary:
	for city_any in _snapshot.get("cities", []):
		if not (city_any is Dictionary):
			continue
		for officer_any in (city_any as Dictionary).get("officer_roster", []):
			if officer_any is Dictionary and str((officer_any as Dictionary).get("name", "")) == officer_name:
				return (officer_any as Dictionary).duplicate(true)
	return {}

func _remove_officer_from_roster(roster: Array, officer_id: String) -> void:
	for i in range(roster.size() - 1, -1, -1):
		if roster[i] is Dictionary and str((roster[i] as Dictionary).get("id", "")) == officer_id:
			roster.remove_at(i)

func _transfer_unit_composition(source_comp: Dictionary, target_comp: Dictionary, organized_amount: float) -> Dictionary:
	var source_after: Dictionary = _normalize_unit_composition(source_comp)
	var target_after: Dictionary = _normalize_unit_composition(target_comp)
	var remaining: float = maxf(0.0, organized_amount)
	for unit_id_any in source_after.keys():
		if remaining <= 0.0:
			break
		var unit_id: String = str(unit_id_any)
		var current: float = float(source_after.get(unit_id, 0.0))
		if current <= 0.0:
			continue
		var moved: float = minf(current, remaining)
		source_after[unit_id] = current - moved
		target_after[unit_id] = float(target_after.get(unit_id, 0.0)) + moved
		remaining -= moved
	return {"source_after": source_after, "target_after": target_after}

func _sanitize_city_personnel_by_roster(city: Dictionary, roster: Array) -> Dictionary:
	return _sanitize_outpost_personnel(city.get("personnel", {}), roster)

func _sanitize_outpost_personnel(personnel_raw: Dictionary, roster: Array) -> Dictionary:
	var personnel: Dictionary = personnel_raw.duplicate(true)
	var roster_ids: Dictionary = {}
	for officer_any in roster:
		if officer_any is Dictionary:
			roster_ids[str((officer_any as Dictionary).get("id", ""))] = true
	var assignments: Dictionary = personnel.get("assignments", {}).duplicate(true)
	for key_any in assignments.keys():
		var key: String = str(key_any)
		var officer_id: String = str(assignments.get(key, ""))
		if officer_id.is_empty() or roster_ids.has(officer_id):
			continue
		assignments.erase(key)
	personnel["assignments"] = assignments
	personnel["officer_count"] = roster.size()
	var taishou_id: String = str(assignments.get("taishou", ""))
	if taishou_id.is_empty():
		personnel["governor_name"] = "-"
	else:
		var officer: Dictionary = _find_officer_by_id(roster, taishou_id)
		personnel["governor_name"] = str(officer.get("name", "-"))
	return personnel

func _rebuild_officer_scores_by_assignments(base_scores: Dictionary, assignments: Dictionary, roster: Array) -> Dictionary:
	var out: Dictionary = base_scores.duplicate(true)
	for role_any in AIDE_ROLES:
		if not (role_any is Dictionary):
			continue
		var role_id: String = str((role_any as Dictionary).get("id", ""))
		var officer_id: String = str(assignments.get(role_id, ""))
		if officer_id.is_empty():
			out[role_id] = 50.0
			continue
		out[role_id] = _officer_role_score(_find_officer_by_id(roster, officer_id), role_id)
	return out

func _set_outpost_move_state(outpost_id: String, patch: Dictionary) -> void:
	var move_points: Dictionary = _snapshot.get("move_points", {}).duplicate(true)
	var current: Dictionary = move_points.get(outpost_id, {}) if move_points.get(outpost_id, {}) is Dictionary else {}
	for key_any in patch.keys():
		var key: String = str(key_any)
		if key == "unit_composition":
			current[key] = _normalize_unit_composition(patch.get(key_any, {}))
		else:
			current[key] = patch[key_any]
	if current.has("unit_composition"):
		current["unit_composition"] = _normalize_unit_composition(current.get("unit_composition", {}))
	move_points[outpost_id] = current
	_snapshot["move_points"] = move_points

func _get_city_assignments(city: Dictionary, roster: Array) -> Dictionary:
	var personnel: Dictionary = city.get("personnel", {})
	var assignments: Dictionary = personnel.get("assignments", {}).duplicate(true)
	if assignments.is_empty():
		var governor_name: String = str(personnel.get("governor_name", ""))
		for officer_any in roster:
			if officer_any is Dictionary and str((officer_any as Dictionary).get("name", "")) == governor_name:
				assignments["taishou"] = str((officer_any as Dictionary).get("id", ""))
				break
	return assignments

func _is_valid_aide_role(role_id: String) -> bool:
	for role_any in AIDE_ROLES:
		if role_any is Dictionary and str((role_any as Dictionary).get("id", "")) == role_id:
			return true
	return false

func _officer_role_score(officer: Dictionary, role_id: String) -> float:
	if officer.has("role_scores"):
		return float(officer.get("role_scores", {}).get(role_id, 50.0))
	var stats: Dictionary = officer.get("stats", {})
	match role_id:
		"taishou":
			return (float(stats.get("lead", 50.0)) + float(stats.get("politics", 50.0)) + float(stats.get("charm", 50.0))) / 3.0
		"shicao":
			return (float(stats.get("politics", 50.0)) + float(stats.get("intellect", 50.0))) * 0.5
		"hucao":
			return (float(stats.get("lead", 50.0)) + float(stats.get("politics", 50.0)) + float(stats.get("charm", 50.0))) / 3.0
		"junxu":
			return (float(stats.get("lead", 50.0)) + float(stats.get("politics", 50.0)) + float(stats.get("might", 50.0))) / 3.0
		"bingcao":
			return (float(stats.get("lead", 50.0)) + float(stats.get("might", 50.0))) * 0.5
		"gongcao":
			return (float(stats.get("politics", 50.0)) + float(stats.get("intellect", 50.0))) * 0.5
		"shuicao":
			return (float(stats.get("lead", 50.0)) + float(stats.get("intellect", 50.0)) + float(stats.get("politics", 50.0))) / 3.0
		"duwei":
			return (float(stats.get("lead", 50.0)) + float(stats.get("might", 50.0))) * 0.5
		_:
			return 50.0

func _build_assignment_names(assignments: Dictionary, roster: Array) -> Dictionary:
	var names: Dictionary = {}
	for role_any in AIDE_ROLES:
		if not (role_any is Dictionary):
			continue
		var role_id: String = str((role_any as Dictionary).get("id", ""))
		if role_id.is_empty():
			continue
		var officer_id: String = str(assignments.get(role_id, ""))
		if officer_id.is_empty():
			names[role_id] = "Unassigned"
			continue
		var officer: Dictionary = _find_officer_by_id(roster, officer_id)
		names[role_id] = str(officer.get("name", "Unassigned"))
	return names

func _aide_preview_factor(score: float) -> float:
	return clampf((score - 50.0) / 10.0, -5.0, 5.0)

func _build_aide_role_preview(role_id: String, officer: Dictionary) -> Dictionary:
	var stats: Dictionary = officer.get("stats", {})
	var score: float = _officer_role_score(officer, role_id)
	var factor: float = _aide_preview_factor(score)
	var lead: float = float(stats.get("lead", 50.0))
	var might: float = float(stats.get("might", 50.0))
	var intellect: float = float(stats.get("intellect", 50.0))
	var politics: float = float(stats.get("politics", 50.0))
	var charm: float = float(stats.get("charm", 50.0))
	var out: Dictionary = {"score": score}
	match role_id:
		"taishou":
			out["governance_delta"] = factor * 0.75 + (charm - 50.0) * 0.01
			out["money"] = round((factor * 40.0) + (politics - 50.0) * 1.0)
			out["food"] = round((factor * 55.0) + (lead - 50.0) * 1.1)
			out["commerce"] = round((factor * 1.4) + (politics - 50.0) * 0.035)
			out["agriculture"] = round((factor * 1.35) + (lead - 50.0) * 0.03)
			out["industry"] = round((factor * 1.2) + (intellect - 50.0) * 0.028)
			out["barracks"] = round((factor * 1.1) + (lead - 50.0) * 0.025)
			out["security"] = factor * 0.45 + (charm - 50.0) * 0.01
		"shicao":
			out["money"] = round((factor * 65.0) + (politics - 50.0) * 1.35)
			out["tax_rate"] = factor * 0.015 + (politics - 50.0) * 0.0003
			out["commerce"] = round((factor * 1.8) + (politics - 50.0) * 0.042)
		"hucao":
			out["food"] = round((factor * 78.0) + (lead - 50.0) * 1.1)
			out["agriculture"] = round((factor * 1.9) + (lead - 50.0) * 0.034)
		"junxu":
			out["wood"] = round((factor * 68.0) + (politics - 50.0) * 1.2)
			out["food"] = round((factor * 34.0) + (lead - 50.0) * 0.65)
			out["barracks"] = round((factor * 1.3) + (lead - 50.0) * 0.024)
		"gongcao":
			out["iron"] = round((factor * 55.0) + (intellect - 50.0) * 1.1)
			out["tech"] = factor * 0.35 + (intellect - 50.0) * 0.01
			out["industry"] = round((factor * 1.85) + (intellect - 50.0) * 0.04)
		"bingcao":
			out["troops"] = round((factor * 90.0) + (lead - 50.0) * 1.35)
			out["morale"] = factor * 0.5 + (might - 50.0) * 0.01
			out["horse"] = round((factor * 42.0) + (might - 50.0) * 0.75)
			out["barracks"] = round((factor * 2.0) + (lead - 50.0) * 0.04)
			out["stables"] = round((factor * 1.7) + (might - 50.0) * 0.033)
		"shuicao":
			out["food"] = round((factor * 42.0) + (intellect - 50.0) * 0.7)
			out["horse"] = round((factor * 30.0) + (lead - 50.0) * 0.58)
			out["commerce"] = round((factor * 1.2) + (politics - 50.0) * 0.025)
		"duwei":
			out["security"] = factor * 0.55 + (lead - 50.0) * 0.01
			out["defense"] = round((factor * 90.0) + (might - 50.0) * 1.0)
		_:
			out["score"] = score
	return out

func _negate_aide_preview(preview: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for key_any in preview.keys():
		var key: String = str(key_any)
		if key == "score":
			out[key] = preview[key]
			continue
		var value = preview[key]
		if value is int or value is float:
			out[key] = -float(value)
	return out

func _build_aide_preview(city: Dictionary, roster: Array) -> Dictionary:
	var out: Dictionary = {}
	var assignments: Dictionary = _get_city_assignments(city, roster)
	for role_any in AIDE_ROLES:
		if not (role_any is Dictionary):
			continue
		var role_id: String = str((role_any as Dictionary).get("id", ""))
		if role_id.is_empty():
			continue
		var role_preview: Dictionary = {}
		for officer_any in roster:
			if not (officer_any is Dictionary):
				continue
			var officer: Dictionary = officer_any
			var officer_id: String = str(officer.get("id", ""))
			if officer_id.is_empty():
				continue
			role_preview[officer_id] = _build_aide_role_preview(role_id, officer)
		var assigned_id: String = str(assignments.get(role_id, ""))
		if assigned_id.is_empty():
			role_preview["__dismiss__"] = {}
		else:
			var assigned_officer: Dictionary = _find_officer_by_id(roster, assigned_id)
			role_preview["__dismiss__"] = _negate_aide_preview(_build_aide_role_preview(role_id, assigned_officer))
		out[role_id] = role_preview
	return out

func _open_aides_panel(city_id: String, selected_role_id: String = "", selected_officer_id: String = "") -> void:
	if _ui_layer == null:
		return
	var city: Dictionary = _find_city(city_id)
	if city.is_empty():
		return
	var roster: Array = _build_city_roster_with_master(city.get("officer_roster", []))
	var assignments: Dictionary = _get_city_assignments(city, roster)
	_ui_layer.show_command_panel("aides", {
		"title": "佐官任命",
		"city_id": city_id,
		"roles": AIDE_ROLES.duplicate(true),
		"officers": roster.duplicate(true),
		"all_officers": _master_officers.duplicate(true),
		"assignments": assignments,
		"assignment_names": _build_assignment_names(assignments, roster),
		"preview": _build_aide_preview(city, roster),
		"selected_role_id": selected_role_id,
		"selected_officer_id": selected_officer_id
	})

func _open_global_officer_book_panel(selected_officer_id: String = "") -> void:
	if _ui_layer == null:
		return
	_ui_layer.show_command_panel("aides", {
		"title": "武将总览",
		"city_id": "",
		"roles": [],
		"officers": [],
		"all_officers": _master_officers.duplicate(true),
		"assignments": {},
		"assignment_names": {},
		"preview": {},
		"selected_role_id": "",
		"selected_officer_id": selected_officer_id
	})

func _role_label(role_id: String) -> String:
	for role_any in AIDE_ROLES:
		if role_any is Dictionary and str((role_any as Dictionary).get("id", "")) == role_id:
			return str((role_any as Dictionary).get("label", role_id))
	return role_id

func _find_faction(faction_id: String) -> Dictionary:
	for faction_any in _snapshot.get("factions", []):
		if faction_any is Dictionary and str((faction_any as Dictionary).get("id", "")) == faction_id:
			return (faction_any as Dictionary).duplicate(true)
	return {}

func _faction_color_hex(faction_id: String) -> String:
	var faction: Dictionary = _find_faction(faction_id)
	var color_any: Variant = faction.get("color", [1.0, 1.0, 1.0])
	if color_any is Array:
		var arr: Array = color_any
		var c := Color(
			float(arr[0]) if arr.size() > 0 else 1.0,
			float(arr[1]) if arr.size() > 1 else 1.0,
			float(arr[2]) if arr.size() > 2 else 1.0,
			1.0
		)
		return c.to_html(false)
	return "FFFFFF"

func _estimate_income_by_month(type_key: String, city: Dictionary, building: Dictionary) -> Dictionary:
	var resources: Dictionary = building.get("resources", {})
	if type_key != "city":
		return {
			"money_month": maxf(50.0, float(resources.get("money", 0.0)) * 0.02),
			"food_quarter": maxf(90.0, float(resources.get("food", 0.0)) * 0.06),
			"iron_month": 0.0,
			"wood_month": 0.0,
			"horse_month": 0.0
		}
	var dev: Dictionary = city.get("development", {})
	return {
		"money_month": 120.0 * float(dev.get("commerce", 0)),
		"food_quarter": 180.0 * float(dev.get("agriculture", 0)),
		"iron_month": 70.0 * float(dev.get("industry", 0)),
		"wood_month": 70.0 * float(dev.get("agriculture", 0)),
		"horse_month": 30.0 * float(dev.get("stables", 0))
	}

func _fmt_income(value: float) -> String:
	if value > 0.0:
		return "[color=#4FA3FF]+%.0f[/color]" % value
	if value < 0.0:
		return "[color=#E25B5B]%.0f[/color]" % value
	return "0"

func _fmt_num(value: float) -> String:
	var integer_value: int = int(round(value))
	var negative: bool = integer_value < 0
	var digits: String = str(abs(integer_value))
	var out: String = ""
	while digits.length() > 3:
		out = "," + digits.substr(digits.length() - 3, 3) + out
		digits = digits.substr(0, digits.length() - 3)
	out = digits + out
	return ("-" if negative else "") + out

func _fmt_delta(value: float, period: String) -> String:
	var num_text: String = _fmt_num(value)
	if value > 0.0:
		num_text = "+" + num_text
	return "%s/%s" % [num_text, period]

func _fmt_pop(value: float) -> String:
	return "%.0f" % value

func _fmt_percent(value: float) -> String:
	return "%.0f" % value

func _update_cursor_terrain_hint() -> void:
	if _ui_layer == null or _map_view == null:
		return
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var terrain_info: Dictionary = _map_view.query_terrain_from_screen(mouse_pos)
	if terrain_info.is_empty():
		_ui_layer.set_terrain_hint("terrain: -")
		return
	var world_pos: Vector3 = terrain_info.get("position", Vector3.ZERO)
	var terrain_type: String = str(terrain_info.get("terrain_type", ""))
	var terrain_name: String = terrain_type if not terrain_type.is_empty() else "plain"
	var walkable: String = "walk"
	if _map_view.has_method("can_unit_walk_at_world") and not bool(_map_view.call("can_unit_walk_at_world", world_pos)):
		walkable = "block"
	_ui_layer.set_terrain_hint("%s | %s" % [terrain_name, walkable])

func _get_outpost_move_state(outpost_id: String) -> Dictionary:
	var building: Dictionary = _find_outpost_building(outpost_id)
	if building.is_empty():
		return {}
	var move_points: Dictionary = _snapshot.get("move_points", {})
	if move_points.get(outpost_id, null) is Dictionary:
		var state: Dictionary = (move_points.get(outpost_id, {}) as Dictionary).duplicate(true)
		state["unit_composition"] = _normalize_unit_composition(state.get("unit_composition", {}))
		var state_siege_any: Variant = state.get("siege_durability", {})
		state["siege_durability"] = (state_siege_any as Dictionary).duplicate(true) if state_siege_any is Dictionary else {}
		return state
	var building_siege_any: Variant = building.get("siege_durability", {})
	var building_siege: Dictionary = (building_siege_any as Dictionary).duplicate(true) if building_siege_any is Dictionary else {}
	return {
		"officer_roster": [],
		"resources": building.get("resources", {}).duplicate(true),
		"stats": building.get("stats", {}).duplicate(true),
		"unit_composition": _normalize_unit_composition(building.get("unit_composition", {})),
		"siege_durability": building_siege,
		"personnel": building.get("personnel", {}).duplicate(true)
	}

func _collect_move_targets(from_city_id: String) -> Array:
	var out: Array = []
	var source_faction: String = str(_find_building_any(from_city_id).get("faction_id", ""))
	for city_any in _snapshot.get("cities", []):
		if not (city_any is Dictionary):
			continue
		var city: Dictionary = city_any
		var city_id: String = str(city.get("id", ""))
		if city_id.is_empty() or city_id == from_city_id:
			continue
		if str(city.get("faction_id", "")) != source_faction:
			continue
		out.append({
			"city_id": city_id,
			"name": "%s (city)" % str(city.get("name", city_id)),
			"officer_roster": city.get("officer_roster", []).duplicate(true),
			"resources": city.get("resources", {}).duplicate(true),
			"stats": city.get("stats", {}).duplicate(true),
			"node_type": "city"
		})
	for unit_any in _snapshot.get("building_units", []):
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = unit_any
		var unit_id: String = str(unit.get("id", ""))
		if unit_id.is_empty() or unit_id == from_city_id:
			continue
		if str(unit.get("faction_id", "")) != source_faction:
			continue
		out.append({
			"city_id": unit_id,
			"name": "%s (%s)" % [str(unit.get("name", unit_id)), str(unit.get("type", "point"))],
			"officer_roster": _get_outpost_move_state(unit_id).get("officer_roster", []).duplicate(true),
			"resources": _get_outpost_move_state(unit_id).get("resources", {}).duplicate(true),
			"stats": _get_outpost_move_state(unit_id).get("stats", {}).duplicate(true),
			"node_type": "outpost"
		})
	return out

func _compose_building_hover_text(building_id: String) -> String:
	var building: Dictionary = _find_building_any(building_id)
	if building.is_empty():
		return ""
	var lines: Array[String] = []
	lines.append("[b]%s[/b]" % str(building.get("name", building_id)))
	lines.append("Faction: %s" % str(_find_faction(str(building.get("faction_id", ""))).get("name", "-")))
	lines.append("Type: %s" % str(building.get("type", "city")))
	if building.has("personnel"):
		lines.append("Governor: %s" % str(building.get("personnel", {}).get("governor_name", "-")))
	return "[font_size=20]%s[/font_size]" % "\n".join(lines)

func _build_city_info_text(building: Dictionary) -> String:
	var building_id: String = str(building.get("id", ""))
	var building_name: String = str(building.get("name", building_id))
	var building_type: String = str(building.get("type", "city"))
	var classification: Dictionary = building.get("classification", {})
	var scale_text: String = str(classification.get("scale", "-"))
	var faction_name: String = str(_find_faction(str(building.get("faction_id", ""))).get("name", "-"))
	var personnel: Dictionary = building.get("personnel", {})
	var resources: Dictionary = building.get("resources", {})
	var stats: Dictionary = building.get("stats", {})
	var defense: Dictionary = building.get("defense", {})
	var development: Dictionary = building.get("development", {})
	var income_est: Dictionary = _estimate_income_by_month(building_type, building, building)
	var officer_count: float = float(personnel.get("officer_count", 0.0))
	var roster_any: Variant = building.get("officer_roster", [])
	if officer_count <= 0.0 and roster_any is Array:
		officer_count = float((roster_any as Array).size())
	var reserve_troops: float = float(stats.get("reserve_troops", 0.0))
	var organized_troops: float = float(stats.get("organized_troops", maxf(0.0, float(stats.get("troops", 0.0)) - reserve_troops)))
	var total_troops: float = float(stats.get("troops", reserve_troops + organized_troops))

	var lines: Array[String] = []
	lines.append("[b]%s[/b]" % building_name)
	lines.append("Faction: %s" % faction_name)
	lines.append("Type: %s" % building_type)
	lines.append("Scale: %s" % scale_text)
	lines.append("Governor: %s" % str(personnel.get("governor_name", "-")))
	lines.append("Officers: %s" % _fmt_num(officer_count))
	if building_type == "city":
		lines.append("Expedition: %s" % ("Active" if _is_expedition_active(building_id) else "Idle"))

	lines.append("")
	lines.append("Money: %s (%s)" % [_fmt_num(float(resources.get("money", 0.0))), _fmt_delta(float(income_est.get("money_month", 0.0)), "month")])
	lines.append("Food: %s (%s)" % [_fmt_num(float(resources.get("food", 0.0))), _fmt_delta(float(income_est.get("food_quarter", 0.0)), "quarter")])
	lines.append("Iron: %s (%s)" % [_fmt_num(float(resources.get("iron", 0.0))), _fmt_delta(float(income_est.get("iron_month", 0.0)), "month")])
	lines.append("Wood: %s (%s)" % [_fmt_num(float(resources.get("wood", 0.0))), _fmt_delta(float(income_est.get("wood_month", 0.0)), "month")])
	lines.append("Horse: %s (%s)" % [_fmt_num(float(resources.get("horse", 0.0))), _fmt_delta(float(income_est.get("horse_month", 0.0)), "month")])

	lines.append("")
	lines.append("Security: %s" % _fmt_percent(float(stats.get("security", 0.0))))
	lines.append("Public Support: %s" % _fmt_percent(float(stats.get("public_support", 0.0))))
	lines.append("Population: %s" % _fmt_pop(float(stats.get("population", 0.0))))
	lines.append("Conscription Pop: %s" % _fmt_pop(float(stats.get("conscription_population", 0.0))))
	lines.append("Troops: %s (reserve %s / organized %s)" % [_fmt_num(total_troops), _fmt_num(reserve_troops), _fmt_num(organized_troops)])
	lines.append("Defense: %s / %s" % [_fmt_num(float(defense.get("current", 0.0))), _fmt_num(float(defense.get("max", 0.0)))])

	if not development.is_empty():
		lines.append("")
		lines.append("Development")
		lines.append("Commerce: %s" % _fmt_num(float(development.get("commerce", 0.0))))
		lines.append("Agriculture: %s" % _fmt_num(float(development.get("agriculture", 0.0))))
		lines.append("Industry: %s" % _fmt_num(float(development.get("industry", 0.0))))
		lines.append("Barracks: %s" % _fmt_num(float(development.get("barracks", 0.0))))
		lines.append("Stables: %s" % _fmt_num(float(development.get("stables", 0.0))))

	return "[font_size=20]%s[/font_size]" % "\n".join(lines)



