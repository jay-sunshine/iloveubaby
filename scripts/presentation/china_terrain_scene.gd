extends Node3D

const MapCameraController := preload("res://scripts/presentation/map_camera_controller.gd")
const JsonDataSource := preload("res://scripts/data/json_data_source.gd")
const StrategyUILayer := preload("res://scripts/presentation/strategy_ui_layer.gd")
const BattlefieldControllerScript := preload("res://scripts/battlefield_controller.gd")
const UnitControllerScene := preload("res://scenes/units/unit_controller.tscn")
const OVERVIEW_MODE_PROVINCE := "province"
const PRESENTATION_RULES_PATH := "res://data/config/presentation_rules.json"
const WORLD_STATE_PATH := "res://data/config/world_state.json"
const ENGINE_RULES_PATH := "res://data/config/engine_rules.json"
const REGROUP_RULES_PATH := "res://data/config/regroup_rules.json"
const SPECIAL_TROOP_RULES_PATH := "res://data/config/special_troop_rules.json"
const OFFICER_ROSTER_PATH := "res://data/config/officer_roster_san14_like_v1.json"
const BATTLE_PERSONALITY_BLUE_PATH := "res://data/config/battle_personalities_blue_v1.json"
const BATTLE_PERSONALITY_GOLD_PATH := "res://data/config/battle_personalities_gold_v1.json"
const WEATHER_SETTINGS_PATH := "res://data/config/weather_settings.json"
const FOG_OF_WAR_OVERLAY_SHADER_PATH := "res://scripts/presentation/fog_of_war_overlay.gdshader"
const FOG_OF_WAR_MAX_CENTERS := 96
const RUNTIME_PHASE_INTERNAL := "internal"
const RUNTIME_PHASE_BATTLE := "battle"
const REGROUP_DEFAULT_SIEGE_CLASS_IDS := ["siege", "engine"]
const RUNTIME_MAP_PLANE_SIZE := 42000.0
const MAP_WEATHER_RAIN_TEX := preload("res://素材/brackeys_vfx_bundle/particles/alpha/trace_06_a.png")
const MAP_WEATHER_FOG_TEX := preload("res://素材/brackeys_vfx_bundle/particles/alpha/smoke_06_a.png")
const BUILDING_COLLISION_LAYER := 2
const DEFAULT_ENABLE_RUNTIME_DYNAMIC_MARKERS := true
const DEFAULT_ENABLE_SUPPLY_FOG := true
const DEFAULT_SUPPLY_FOG_REFRESH_SECONDS := 0.8
const DEFAULT_SUPPLY_SETTLEMENT_MODE := "daily"
const DEFAULT_SUPPLY_SETTLEMENT_INTERVAL_DAYS := 1.0
const DEFAULT_SUPPLY_FOG_PERF_ENABLED := true
const DEFAULT_SUPPLY_FOG_SIGNATURE_GRID_METERS := 48.0
const DEFAULT_SUPPLY_FOG_UNIT_THRESHOLD_MID := 320
const DEFAULT_SUPPLY_FOG_UNIT_THRESHOLD_HEAVY := 760
const DEFAULT_SUPPLY_FOG_CAMERA_HEIGHT_FAR := 9800.0
const DEFAULT_SUPPLY_FOG_REFRESH_SCALE_MID := 1.35
const DEFAULT_SUPPLY_FOG_REFRESH_SCALE_HEAVY := 1.85
const DEFAULT_SUPPLY_FOG_REFRESH_SCALE_FAR := 1.55
const DEFAULT_SUPPLY_FOG_MARKER_STRIDE_MID := 2
const DEFAULT_SUPPLY_FOG_MARKER_STRIDE_HEAVY := 3
const DEFAULT_SUPPLY_FOG_MARKER_STRIDE_FAR := 4
const DEFAULT_SUPPLY_FOG_REVEAL_CENTER_CAP_MID := 180
const DEFAULT_SUPPLY_FOG_REVEAL_CENTER_CAP_HEAVY := 128
const DEFAULT_SUPPLY_FOG_REVEAL_CENTER_CAP_FAR := 96
const DEFAULT_SHOW_SUPPLY_ROUTE_OVERLAY := true
const DEFAULT_SUPPLY_REGION_MODE_ENABLED := true
const DEFAULT_RUNTIME_MOBILE_UNIT_SCALE := 2.0
const DEFAULT_ALLOW_CONTROL_ALL_UNITS_FOR_TESTING := false
const DEFAULT_SUPPLY_USE_SCENE_FACTION_FALLBACK := false
const DEFAULT_DYNAMIC_UNIT_TYPES := {
	"field_unit": true,
	"granary": true,
	"convoy": true,
	"supply_convoy": true,
	"transport": true,
	"muzhai": true,
	"chengzhai": true,
	"jianlou": true,
	"gaojijianlou": true,
	"zhalan": true,
	"taigutai": true,
	"junyuetai": true
}
const DEFAULT_RUNTIME_MODEL_PATHS := {
	"granary": "res://\u7d20\u6750/\u5efa\u6a21/\u519b\u4e8b\u8bbe\u65bd/liangcang.glb",
	"granary_advanced": "res://\u7d20\u6750/\u5efa\u6a21/\u519b\u4e8b\u8bbe\u65bd/junliangbao.glb",
	"convoy": "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/muniuliuima.glb",
	"supply_convoy": "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/muniuliuima.glb",
	"transport": "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/muniuliuima.glb",
	"muzhai": "res://\u7d20\u6750/\u5efa\u6a21/\u519b\u4e8b\u8bbe\u65bd/muzhai.glb",
	"chengzhai": "res://\u7d20\u6750/\u5efa\u6a21/\u519b\u4e8b\u8bbe\u65bd/chengzhai.glb",
	"jianlou": "res://\u7d20\u6750/\u5efa\u6a21/\u519b\u4e8b\u8bbe\u65bd/jianlou.glb",
	"gaojijianlou": "res://\u7d20\u6750/\u5efa\u6a21/\u519b\u4e8b\u8bbe\u65bd/gaojijianlou.glb",
	"zhalan": "res://\u7d20\u6750/\u5efa\u6a21/\u519b\u4e8b\u8bbe\u65bd/zhalan.glb",
	"taigutai": "res://\u7d20\u6750/\u5efa\u6a21/\u519b\u4e8b\u8bbe\u65bd/taigutai.glb",
	"junyuetai": "res://\u7d20\u6750/\u5efa\u6a21/\u519b\u4e8b\u8bbe\u65bd/junyuetai.glb"
}
const DEFAULT_RUNTIME_MODEL_SCALES := {
	"granary": 122.0,
	"granary_advanced": 126.0,
	"convoy": 116.0,
	"supply_convoy": 116.0,
	"transport": 116.0,
	"muzhai": 108.0,
	"chengzhai": 124.0,
	"jianlou": 106.0,
	"gaojijianlou": 118.0,
	"zhalan": 62.0,
	"taigutai": 104.0,
	"junyuetai": 114.0
}
const POLY_NATURE_PACK_SCENE_PATH := "res://绱犳潗/nature/poly_nature_pack_assets.blend"
const ZHALAN_POLY_LOG_NODE_CANDIDATES := [
	"tree-oak-english-part-log-a",
	"tree-beech-european-part-log-a",
	"tree-birch-silver-part-log-a",
	"tree-spruce-norway-part-log-a",
	"tree-pine-scots-part-log-a"
]
const ZHALAN_POLY_MODEL_CACHE_KEY := "@procedural:zhalan_poly_log_v1"
const ZHALAN_POST_BLOCK_RADIUS := 4.4
const ZHALAN_POST_COLLISION_HEIGHT := 24.0
const ZHALAN_POLY_STAKE_SCALE := 7.0
const ADVANCED_GRANARY_KEYWORDS := [
	"advanced",
	"elite",
	"junliangbao",
	"\u9ad8\u7ea7",
	"\u519b\u7cae\u5821"
]
const RUNTIME_MOBILE_UNIT_TYPES := {
	"field_unit": true,
	"convoy": true,
	"supply_convoy": true,
	"transport": true
}
const RUNTIME_CITY_AIDE_ROLES: Array[Dictionary] = [
	{"id": "taishou", "label": "Governor", "desc": "Oversees internal affairs and security for the whole city."},
	{"id": "shicao", "label": "Market Officer", "desc": "Handles taxes, trade, and market activity."},
	{"id": "hucao", "label": "Civil Officer", "desc": "Handles food policy and civilian supply."},
	{"id": "junxu", "label": "Quartermaster", "desc": "Handles wood, equipment, and military stockpiles."},
	{"id": "bingcao", "label": "Troop Officer", "desc": "Handles recruitment, training, and armament."},
	{"id": "gongcao", "label": "Works Officer", "desc": "Handles construction, ironworking, and technology."},
	{"id": "duwei", "label": "Commandant", "desc": "Handles garrison duty, wall repair, and public order."}
]
const RUNTIME_FERRY_AIDE_ROLES: Array[Dictionary] = [
	{"id": "shuicao", "label": "Water Transport", "desc": "Handles ferry shipbuilding, water transport, and route supply."}
]
const RUNTIME_COMMANDER_SLOT_WEIGHTS := [0.6, 0.2, 0.2]
const SUPPLY_FOG_GRANARY_KEYWORDS := ["granary", "grain_depot", "supply_depot", "ao_cang", "鏁栦粨", "绮粨", "鍐涚伯", "绮牎"]
const SUPPLY_FOG_CONVOY_KEYWORDS := ["convoy", "supply_cart", "wagon", "wood_ox", "mule", "transport", "杩愮伯", "绮溅", "鏈ㄧ墰", "娴侀┈"]
const SUPPLY_FOG_TROOP_KEYWORDS := ["field_unit", "expedition", "army", "troop", "warband", "閮ㄩ槦", "鍐涘洟", "閲庢垬", "琛屽啗", "鍏靛洟"]
const UNIT_BUILD_CREATE_ACTIONS := {
	"build_muzhai": {"type": "muzhai", "name": "木寨"},
	"build_granary": {"type": "granary", "name": "粮仓", "is_granary": true},
	"build_jianlou": {"type": "jianlou", "name": "箭楼"},
	"build_zhalan": {"type": "zhalan", "name": "栅栏"},
	"build_taigutai": {"type": "taigutai", "name": "太鼓台"}
}
const UNIT_BUILD_UPGRADE_ACTIONS := {
	"upgrade_chengzhai": {"from_type": "muzhai", "to_type": "chengzhai", "name": "城寨"},
	"upgrade_junliangbao": {"from_type": "granary", "to_type": "granary", "name": "军粮堡", "require_basic_granary": true, "to_advanced_granary": true},
	"upgrade_gaojijianlou": {"from_type": "jianlou", "to_type": "gaojijianlou", "name": "高级箭楼"},
	"upgrade_junyuetai": {"from_type": "taigutai", "to_type": "junyuetai", "name": "军乐台"}
}
const UNIT_BUILD_MIN_DISTANCE := 170.0
const UNIT_BUILD_MAX_DISTANCE := 440.0
const UNIT_BUILD_UPGRADE_RADIUS := 320.0
const UNIT_BUILD_PLACE_ANGLES := [0.0, 42.0, -42.0, 84.0, -84.0, 126.0, -126.0, 168.0, -168.0]
const FENCE_LINE_SEGMENT_SPACING := 9.0
const FACILITY_MODEL_SCALE_MUL := 0.75
const MOBILE_UNIT_SCALE_MUL := 1.5
const RUNTIME_FIELD_UNIT_MOVE_SPEED := 7.2
const RUNTIME_CONVOY_MOVE_SPEED := 5.8
const RUNTIME_FORMATION_WORLD_SPACING_MUL := 1.0
const UNIT_BUILD_ARRIVE_START_RADIUS := 46.0
const UNIT_BUILD_STAGING_ARRIVE_RADIUS := 20.0
const FACILITY_UPGRADE_DURATION_SEC := 14.0
const FACILITY_REPAIR_DURATION_SEC := 9.0
const FACILITY_EFFECT_TICK_INTERVAL_SEC := 0.25
const FACILITY_EFFECT_GRID_CELL_SIZE := 320.0
const FACILITY_JIANLOU_ATTACK_RANGE := 340.0
const FACILITY_GAOJIJIANLOU_ATTACK_RANGE := 460.0
const FACILITY_JIANLOU_ATTACK_DAMAGE := 22.0
const FACILITY_GAOJIJIANLOU_ATTACK_DAMAGE := 34.0
const FACILITY_JIANLOU_ATTACK_COOLDOWN := 1.15
const FACILITY_GAOJIJIANLOU_ATTACK_COOLDOWN := 0.88
const FACILITY_TAIGUTAI_AURA_RANGE := 300.0
const FACILITY_JUNYUETAI_AURA_RANGE := 420.0
const FACILITY_TAIGUTAI_MORALE_PER_SEC := 1.3
const FACILITY_TAIGUTAI_WILL_PER_SEC := 1.9
const FACILITY_JUNYUETAI_ATTACK_STATUS_HOLD_SEC := 0.45
const FACILITY_MUZHAI_DEFENSE_AURA_RANGE := 260.0
const FACILITY_CHENGZHAI_DEFENSE_AURA_RANGE := 360.0
const FACILITY_DEFENSE_STATUS_HOLD_SEC := 0.45
const RUNTIME_SIEGE_ENABLED := true
const RUNTIME_SIEGE_BASE_DPS_PER_TROOP := 0.026
const RUNTIME_SIEGE_MIN_DPS_PER_UNIT := 22.0
const RUNTIME_SIEGE_CAPTURE_RECOVERY_RATIO := 0.52
const RUNTIME_SIEGE_CITY_ATTACK_RADIUS := 460.0
const RUNTIME_SIEGE_SITE_ATTACK_RADIUS := 340.0
const RUNTIME_SIEGE_STRONGHOLD_ATTACK_RADIUS := 380.0
const RUNTIME_SIEGE_INFO_REFRESH_SEC := 0.25
const RUNTIME_SIEGE_INFO_HIDE_CAMERA_HEIGHT := 24000.0
const RUNTIME_SIEGE_INFO_CITY_Y_OFFSET := 220.0
const RUNTIME_SIEGE_INFO_SITE_Y_OFFSET := 170.0
const RUNTIME_SIEGE_RECENT_CAPTURE_HINT_MS := 6500
const RUNTIME_UI_REFRESH_INTERVAL_SEC := 0.33
const CAMERA_RULES := {
	"move_speed": 1400.0,
	"zoom_speed": 260.0,
	"rotate_speed_deg": 80.0,
	"min_height": 160.0,
	"max_height": 26000.0,
	"default_height": 1400.0,
	"yaw_deg": 0.0,
	"tilt_deg": 45.0,
	"lod_tilt_deg": [45.0, 45.0, 45.0, 45.0, 88.0, 88.0],
	"lod_distance_ratio": [0.72, 0.72, 0.72, 0.72, 0.02, 0.02],
	"overview_tilt_deg": 88.0,
	"overview_distance_ratio": 0.02,
	"distance_ratio": 0.72,
	"use_discrete_lod_zoom": true,
	"zoom_smooth_enabled": true,
	"lod_transition_seconds": 0.26,
	"lod_level_heights": [160.0, 420.0, 1400.0, 4200.0, 12000.0, 26000.0],
	"lod_move_speed_scale_max": 20.0,
	"far_clip": 120000.0
}
const DEFAULT_TIME_WEATHER_RULES := {
	"enabled": true,
	"days_per_turn": 10.0,
	"battle_phase_cycle": ["day", "night"],
	"battle_phase_day_ratio": 0.6,
	"turn_day_phase_cycle": ["day", "night"],
	"default_weather_state": "sunny",
	"default_wind_dir": [1.0, 0.0],
	"default_wind_strength": 0.0,
	"weather_cycle_by_turn": ["sunny", "cloudy", "sunny", "windy", "sunny", "fog", "rain", "cloudy"],
	"day_phase_visibility_mul": {"day": 1.0, "night": 0.9},
	"weather_visibility_mul": {
		"sunny": 1.0,
		"clear": 1.0,
		"cloudy": 0.98,
		"windy": 0.99,
		"rain": 0.95,
		"storm": 0.92,
		"fog": 0.98,
		"mist": 0.98
	},
	"sun_energy_by_phase": {"day": 1.6, "night": 0.75},
	"ambient_energy_by_phase": {"day": 1.4, "night": 1.05},
	"fog_density_by_weather": {
		"sunny": 0.0,
		"clear": 0.0,
		"cloudy": 0.0002,
		"windy": 0.0001,
		"rain": 0.00035,
		"storm": 0.00055,
		"fog": 0.0004,
		"mist": 0.00035
	},
	"map_weather_vfx": {
		"enabled": true,
		"follow_lerp": 0.24,
		"rain_ground_height_offset": 760.0,
		"fog_ground_height_offset": 95.0,
		"rain": {
			"amount": 1900,
			"lifetime": 1.28,
			"box_extents": [1900.0, 180.0, 1900.0],
			"velocity_min": 610.0,
			"velocity_max": 820.0,
			"scale_min": 0.9,
			"scale_max": 1.45,
			"quad_size": [3.4, 19.0],
			"color_day": [0.72, 0.8, 0.9, 0.34],
			"color_night": [0.52, 0.6, 0.74, 0.3]
		},
		"fog": {
			"amount": 90,
			"lifetime": 9.6,
			"box_extents": [2100.0, 80.0, 2100.0],
			"velocity_min": 8.0,
			"velocity_max": 18.0,
			"scale_min": 1.0,
			"scale_max": 1.65,
			"quad_size": [90.0, 54.0],
			"color_day": [0.9, 0.94, 0.97, 0.08],
			"color_night": [0.7, 0.76, 0.84, 0.1]
		}
	}
}

const TERRAIN_RAY_LENGTH := 200000.0
const TERRAIN_WALKABLE_SLOPE_DEG := 40.0
const TERRAIN_WATER_HEIGHT := -18.0
const CITY_SCALE_CAPS := {
	"small": {
		"commerce_max": 6,
		"agriculture_max": 6,
		"industry_max": 6,
		"barracks_max": 7,
		"stables_max": 5,
		"defense_max": 28000.0,
		"money_cap": 42000.0,
		"food_cap": 76000.0,
		"iron_cap": 24000.0,
		"wood_cap": 24000.0,
		"horse_cap": 16000.0
	},
	"medium": {
		"commerce_max": 8,
		"agriculture_max": 8,
		"industry_max": 8,
		"barracks_max": 9,
		"stables_max": 7,
		"defense_max": 42000.0,
		"money_cap": 70000.0,
		"food_cap": 130000.0,
		"iron_cap": 42000.0,
		"wood_cap": 42000.0,
		"horse_cap": 28000.0
	},
	"large": {
		"commerce_max": 10,
		"agriculture_max": 10,
		"industry_max": 10,
		"barracks_max": 11,
		"stables_max": 9,
		"defense_max": 60000.0,
		"money_cap": 110000.0,
		"food_cap": 210000.0,
		"iron_cap": 68000.0,
		"wood_cap": 68000.0,
		"horse_cap": 44000.0
	},
	"huge": {
		"commerce_max": 12,
		"agriculture_max": 12,
		"industry_max": 12,
		"barracks_max": 13,
		"stables_max": 11,
		"defense_max": 86000.0,
		"money_cap": 170000.0,
		"food_cap": 320000.0,
		"iron_cap": 105000.0,
		"wood_cap": 105000.0,
		"horse_cap": 68000.0
	}
}

var _camera: Camera3D
var _terrain: Node3D
var _political_overlay: ChinaPoliticalMaskOverlay
var _city_overlay: ChinaCityOverlay
var _strategic_site_manager: Node
var _world_env: WorldEnvironment
var _sun_light: DirectionalLight3D
var _runtime_weather_environment: Environment
var _runtime_ui_layer: StrategyUILayer
var _runtime_city_orders: Dictionary = {}
var _supply_corridor_ui_layer: CanvasLayer
var _supply_corridor_toggle_button: Button
var _selected_site_id: String = ""
var _json_source := JsonDataSource.new()
var _world_state_cache: Dictionary = {}
var _world_city_by_id: Dictionary = {}
var _world_city_by_name: Dictionary = {}
var _world_building_by_id: Dictionary = {}
var _world_building_by_name: Dictionary = {}
var _world_faction_name_by_id: Dictionary = {}
var _master_officers: Array = []
var _master_officers_by_id: Dictionary = {}
var _master_officers_by_name: Dictionary = {}
var _battle_personality_trait_by_id: Dictionary = {}
var _battle_personality_catalog_loaded: bool = false
var _battle_personality_regex_ready: bool = false
var _battle_personality_percent_regex: RegEx
var _battle_personality_plain_number_regex: RegEx
var _engine_rules_cache: Dictionary = {}
var _runtime_rules: Dictionary = {}
var _regroup_rules_cache: Dictionary = {}
var _regroup_base_dataset_cache: Dictionary = {}
var _special_troop_rules_cache: Dictionary = {}
var _runtime_unit_root: Node3D
var _runtime_unit_nodes: Dictionary = {}
var _runtime_unit_snapshots: Dictionary = {}
var _supply_fog_snapshot: Dictionary = {}
var _supply_refresh_timer: Timer
var _runtime_dynamic_markers_enabled: bool = DEFAULT_ENABLE_RUNTIME_DYNAMIC_MARKERS
var _runtime_supply_fog_enabled: bool = DEFAULT_ENABLE_SUPPLY_FOG
var _supply_fog_refresh_seconds: float = DEFAULT_SUPPLY_FOG_REFRESH_SECONDS
var _supply_settlement_mode: String = DEFAULT_SUPPLY_SETTLEMENT_MODE
var _supply_settlement_interval_days: float = DEFAULT_SUPPLY_SETTLEMENT_INTERVAL_DAYS
var _supply_last_full_settle_day: float = -999999.0
var _supply_pending_full_recalc: bool = true
var _supply_fog_perf_enabled: bool = DEFAULT_SUPPLY_FOG_PERF_ENABLED
var _supply_fog_signature_grid_meters: float = DEFAULT_SUPPLY_FOG_SIGNATURE_GRID_METERS
var _supply_fog_unit_threshold_mid: int = DEFAULT_SUPPLY_FOG_UNIT_THRESHOLD_MID
var _supply_fog_unit_threshold_heavy: int = DEFAULT_SUPPLY_FOG_UNIT_THRESHOLD_HEAVY
var _supply_fog_camera_height_far: float = DEFAULT_SUPPLY_FOG_CAMERA_HEIGHT_FAR
var _supply_fog_refresh_scale_mid: float = DEFAULT_SUPPLY_FOG_REFRESH_SCALE_MID
var _supply_fog_refresh_scale_heavy: float = DEFAULT_SUPPLY_FOG_REFRESH_SCALE_HEAVY
var _supply_fog_refresh_scale_far: float = DEFAULT_SUPPLY_FOG_REFRESH_SCALE_FAR
var _supply_fog_marker_stride_mid: int = DEFAULT_SUPPLY_FOG_MARKER_STRIDE_MID
var _supply_fog_marker_stride_heavy: int = DEFAULT_SUPPLY_FOG_MARKER_STRIDE_HEAVY
var _supply_fog_marker_stride_far: int = DEFAULT_SUPPLY_FOG_MARKER_STRIDE_FAR
var _supply_fog_reveal_center_cap_mid: int = DEFAULT_SUPPLY_FOG_REVEAL_CENTER_CAP_MID
var _supply_fog_reveal_center_cap_heavy: int = DEFAULT_SUPPLY_FOG_REVEAL_CENTER_CAP_HEAVY
var _supply_fog_reveal_center_cap_far: int = DEFAULT_SUPPLY_FOG_REVEAL_CENTER_CAP_FAR
var _supply_fog_cached_signature: int = 0
var _supply_fog_cached_context_signature: String = ""
var _supply_fog_cached_ready: bool = false
var _supply_fog_marker_cycle_index: int = 0
var _supply_fog_marker_stride_current: int = 1
var _supply_fog_reveal_center_cap_current: int = 0
var _supply_fog_effective_refresh_seconds: float = DEFAULT_SUPPLY_FOG_REFRESH_SECONDS
var _show_supply_route_overlay: bool = DEFAULT_SHOW_SUPPLY_ROUTE_OVERLAY
var _runtime_mobile_unit_scale: float = DEFAULT_RUNTIME_MOBILE_UNIT_SCALE
var _runtime_allow_control_all_units_for_testing: bool = DEFAULT_ALLOW_CONTROL_ALL_UNITS_FOR_TESTING
var _supply_use_scene_faction_fallback: bool = DEFAULT_SUPPLY_USE_SCENE_FACTION_FALLBACK
var _runtime_dynamic_type_allow: Dictionary = DEFAULT_DYNAMIC_UNIT_TYPES.duplicate(true)
var _runtime_model_paths: Dictionary = DEFAULT_RUNTIME_MODEL_PATHS.duplicate(true)
var _runtime_model_scales: Dictionary = DEFAULT_RUNTIME_MODEL_SCALES.duplicate(true)
var _runtime_model_scene_cache: Dictionary = {}
var _runtime_model_warned_missing: Dictionary = {}
var _runtime_zhalan_poly_template: Node3D
var _runtime_zhalan_poly_log_mesh_cache: Mesh
var _runtime_zhalan_poly_warned_missing: bool = false
var _runtime_mobile_root: Node3D
var _runtime_mobile_units: Dictionary = {}
var _runtime_mobile_snapshots: Dictionary = {}
var _runtime_mobile_registered: Dictionary = {}
var _runtime_supply_report_state: Dictionary = {}
var _battle_runtime: Node
var _facility_effect_tick_accum: float = 0.0
var _facility_tower_cooldowns: Dictionary = {}
var _runtime_siege_status_by_target_id: Dictionary = {}
var _runtime_siege_recent_capture_until: Dictionary = {}
var _runtime_siege_info_root: Node3D
var _runtime_siege_info_labels: Dictionary = {}
var _runtime_siege_info_refresh_accum: float = 0.0
var _supply_debug_enabled: bool = false
var _supply_debug_root: Node3D
var _supply_debug_labels: Dictionary = {}
var _supply_route_overlay_root: Node3D
var _supply_route_mesh_linked: MeshInstance3D
var _supply_route_mesh_unlinked: MeshInstance3D
var _supply_route_mesh_preview: MeshInstance3D
var _supply_route_focus_site_id: String = ""
var _supply_route_focus_faction_id: String = ""
var _supply_route_preview_action_id: String = ""
var _supply_route_preview_world: Vector3 = Vector3.INF
var _supply_route_preview_faction_id: String = ""
var _supply_region_mode_enabled: bool = DEFAULT_SUPPLY_REGION_MODE_ENABLED
var _supply_corridor_view_enabled: bool = false
var _runtime_time_weather: Dictionary = {}
var _runtime_time_weather_signature: String = ""
var _runtime_ui_refresh_accum: float = 0.0
var _runtime_weather_vfx_root: Node3D
var _runtime_weather_rain_emitter: GPUParticles3D
var _runtime_weather_fog_emitter: GPUParticles3D
var _runtime_weather_rain_process: ParticleProcessMaterial
var _runtime_weather_fog_process: ParticleProcessMaterial
var _runtime_weather_rain_material: StandardMaterial3D
var _runtime_weather_fog_material: StandardMaterial3D
var _runtime_weather_vfx_anchor: Vector3 = Vector3.ZERO
var _runtime_weather_vfx_anchor_initialized: bool = false
var _runtime_weather_rain_base_amount: int = 0
var _runtime_weather_fog_base_amount: int = 0
var _runtime_phase: String = RUNTIME_PHASE_INTERNAL
var _runtime_battle_elapsed_seconds: float = 0.0
var _runtime_battle_total_seconds: float = 60.0
var _runtime_battle_speed: float = 1.0
var _runtime_battle_paused: bool = false
var _runtime_status_message: String = ""
@export var site_hover_panel_show_delay_sec: float = 1.2
@export var runtime_low_perf_mode: bool = true
@export_range(0.1, 1.0, 0.05) var runtime_weather_vfx_density_scale: float = 0.45
@export_range(4, 10, 1) var runtime_unit_visual_square_dim_cap: int = 6
@export_range(0.1, 1.0, 0.05) var runtime_unit_effect_density_scale: float = 0.5
var _site_hover_candidate_id: String = ""
var _site_hover_candidate_elapsed: float = 0.0
var _runtime_last_battle_day_phase: String = "day"
var _runtime_seconds_per_day: float = 6.0
var _runtime_fog_overlay_mesh: MeshInstance3D
var _runtime_fog_overlay_material: ShaderMaterial
var _mountain_mist_root: Node3D


func _ready() -> void:
	_camera = get_node_or_null("EditorCamera") as Camera3D
	_terrain = get_node_or_null("Terrain3D") as Node3D
	_political_overlay = get_node_or_null("PoliticalOverview") as ChinaPoliticalMaskOverlay
	_city_overlay = get_node_or_null("CityOverlay") as ChinaCityOverlay
	_strategic_site_manager = get_node_or_null("StrategicSites")
	_world_env = get_node_or_null("WorldEnv") as WorldEnvironment
	_sun_light = get_node_or_null("SunLight") as DirectionalLight3D
	_mountain_mist_root = get_node_or_null("MountainMist") as Node3D
	if _camera == null or _terrain == null or _political_overlay == null:
		push_warning("China terrain scene missing camera, terrain or political overlay node.")
		return
	if _strategic_site_manager != null and not Engine.is_editor_hint():
		if _strategic_site_manager.has_method("set"):
			_strategic_site_manager.set("force_load_all", true)
	if _camera.get_script() != MapCameraController:
		_camera.set_script(MapCameraController)
	_camera.current = true
	_camera.fov = 58.0
	_camera.call("configure", CAMERA_RULES, {"x": 30000.0, "z": 30000.0})
	if _camera.has_signal("zoom_lod_changed"):
		var cb := Callable(self, "_on_camera_zoom_lod_changed")
		if not _camera.is_connected("zoom_lod_changed", cb):
			_camera.connect("zoom_lod_changed", cb)
	_political_overlay.visible = false
	_on_camera_zoom_lod_changed(int(_camera.call("get_current_lod_level")), int(_camera.call("get_total_lod_levels")), float(_camera.call("get_current_target_height")))
	if not Engine.is_editor_hint():
		_reload_world_state_cache()
		_setup_runtime_time_weather()
		_setup_runtime_battle_phase_rules()
		_setup_runtime_battle_controller()
		_setup_supply_fog_runtime()
		_setup_runtime_site_menu_ui()
		_ensure_supply_corridor_toggle_ui()
		_refresh_runtime_ui_hud(true)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_tick_runtime_battle_phase(delta)
	_sync_runtime_time_weather_state(false)
	_update_runtime_weather_vfx_anchor(delta)
	_refresh_runtime_ui_hud_periodic(delta)
	_update_hover_info(delta)
	_tick_runtime_facility_effects(delta)
	_refresh_runtime_siege_info_overlay_periodic(delta)

func _exit_tree() -> void:
	Engine.time_scale = 1.0

func _tick_runtime_facility_effects(delta: float) -> void:
	if delta <= 0.0:
		return
	if _runtime_mobile_units.is_empty():
		return
	_facility_effect_tick_accum += delta
	if _facility_effect_tick_accum < FACILITY_EFFECT_TICK_INTERVAL_SEC:
		return
	var step_sec: float = _facility_effect_tick_accum
	_facility_effect_tick_accum = 0.0
	_tick_facility_tower_cooldowns(step_sec)
	var effect_index: Dictionary = _build_runtime_mobile_effect_index()
	var facilities: Array = _collect_active_runtime_facilities_for_effects()
	var active_tower_ids: Dictionary = {}
	if not facilities.is_empty():
		var morale_rate_by_unit_id: Dictionary = {}
		var spirit_rate_by_unit_id: Dictionary = {}
		for fac_any in facilities:
			if not (fac_any is Dictionary):
				continue
			var facility: Dictionary = fac_any as Dictionary
			var type_key: String = String(facility.get("type", "")).to_lower().strip_edges()
			match type_key:
				"jianlou":
					var tower_id: String = String(facility.get("id", "")).strip_edges()
					if not tower_id.is_empty():
						active_tower_ids[tower_id] = true
					_tick_single_tower_attack(facility, FACILITY_JIANLOU_ATTACK_RANGE, FACILITY_JIANLOU_ATTACK_DAMAGE, FACILITY_JIANLOU_ATTACK_COOLDOWN, effect_index)
				"gaojijianlou":
					var tower_id_adv: String = String(facility.get("id", "")).strip_edges()
					if not tower_id_adv.is_empty():
						active_tower_ids[tower_id_adv] = true
					_tick_single_tower_attack(facility, FACILITY_GAOJIJIANLOU_ATTACK_RANGE, FACILITY_GAOJIJIANLOU_ATTACK_DAMAGE, FACILITY_GAOJIJIANLOU_ATTACK_COOLDOWN, effect_index)
				"muzhai":
					_apply_single_defense_aura(facility, FACILITY_MUZHAI_DEFENSE_AURA_RANGE, effect_index)
				"chengzhai":
					_apply_single_defense_aura(facility, FACILITY_CHENGZHAI_DEFENSE_AURA_RANGE, effect_index)
				"taigutai":
					_accumulate_single_morale_aura(facility, FACILITY_TAIGUTAI_AURA_RANGE, FACILITY_TAIGUTAI_MORALE_PER_SEC, FACILITY_TAIGUTAI_WILL_PER_SEC, morale_rate_by_unit_id, spirit_rate_by_unit_id, effect_index)
				"junyuetai":
					_apply_single_attack_aura(facility, FACILITY_JUNYUETAI_AURA_RANGE, effect_index)
				_:
					pass
		_apply_accumulated_morale_aura(step_sec, morale_rate_by_unit_id, spirit_rate_by_unit_id)
	_prune_facility_tower_cooldowns(active_tower_ids)
	if RUNTIME_SIEGE_ENABLED and _runtime_phase == RUNTIME_PHASE_BATTLE and not _runtime_battle_paused:
		_tick_runtime_siege(step_sec, effect_index)

func _collect_active_runtime_facilities_for_effects() -> Array:
	var out: Array = []
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return out
	for node_any in (units_any as Array):
		if not (node_any is Dictionary):
			continue
		var node: Dictionary = node_any as Dictionary
		var type_key: String = String(node.get("type", "")).to_lower().strip_edges()
		if type_key != "jianlou" and type_key != "gaojijianlou" and type_key != "muzhai" and type_key != "chengzhai" and type_key != "taigutai" and type_key != "junyuetai":
			continue
		if bool(node.get("awaiting_builder_arrival", false)) or bool(node.get("is_under_construction", false)):
			continue
		if bool(node.get("operation_active", false)):
			continue
		var faction_id: String = String(node.get("faction_id", "")).strip_edges()
		if faction_id.is_empty():
			continue
		var pos_any: Variant = node.get("position", {})
		if not (pos_any is Dictionary):
			continue
		out.append(node.duplicate(true))
	return out

func _build_runtime_mobile_effect_index() -> Dictionary:
	# Build a lightweight spatial index every effect tick to avoid facility_count * unit_count scans.
	var cell_size: float = maxf(64.0, FACILITY_EFFECT_GRID_CELL_SIZE)
	var mobile_grid_all: Dictionary = {}
	var field_grid_by_faction: Dictionary = {}
	var unit_pos2_by_id: Dictionary = {}
	var unit_faction_by_id: Dictionary = {}
	for unit_id_any in _runtime_mobile_units.keys():
		var unit_id: String = String(unit_id_any).strip_edges()
		if unit_id.is_empty():
			continue
		var unit_node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
		if unit_node == null or not is_instance_valid(unit_node):
			continue
		if _is_runtime_mobile_unit_dead(unit_node):
			continue
		var snap: Dictionary = _runtime_mobile_unit_snapshot(unit_id)
		if snap.is_empty():
			continue
		var faction_id: String = String(snap.get("faction_id", "")).strip_edges()
		if faction_id.is_empty():
			continue
		var unit_type: String = String(snap.get("type", "")).to_lower().strip_edges()
		var is_field_unit: bool = unit_type == "field_unit"
		var is_mobile_target: bool = is_field_unit or unit_type == "convoy" or unit_type == "supply_convoy" or unit_type == "transport"
		if not is_mobile_target:
			continue
		var p_any: Variant = snap.get("position", {})
		if not (p_any is Dictionary):
			continue
		var p: Dictionary = p_any as Dictionary
		var pos2 := Vector2(float(p.get("x", 0.0)), float(p.get("z", 0.0)))
		unit_pos2_by_id[unit_id] = pos2
		unit_faction_by_id[unit_id] = faction_id
		_effect_grid_insert_id(mobile_grid_all, pos2, unit_id, cell_size)
		if is_field_unit:
			var faction_grid_any: Variant = field_grid_by_faction.get(faction_id, {})
			var faction_grid: Dictionary = faction_grid_any as Dictionary if faction_grid_any is Dictionary else {}
			_effect_grid_insert_id(faction_grid, pos2, unit_id, cell_size)
			field_grid_by_faction[faction_id] = faction_grid
	return {
		"cell_size": cell_size,
		"mobile_grid_all": mobile_grid_all,
		"field_grid_by_faction": field_grid_by_faction,
		"unit_pos2_by_id": unit_pos2_by_id,
		"unit_faction_by_id": unit_faction_by_id
	}

func _effect_grid_insert_id(grid: Dictionary, pos2: Vector2, unit_id: String, cell_size: float) -> void:
	if unit_id.is_empty():
		return
	var safe_cell: float = maxf(1.0, cell_size)
	var cell := Vector2i(int(floor(pos2.x / safe_cell)), int(floor(pos2.y / safe_cell)))
	var bucket_any: Variant = grid.get(cell, [])
	var bucket: Array = bucket_any as Array if bucket_any is Array else []
	bucket.append(unit_id)
	grid[cell] = bucket

func _effect_grid_collect_ids_in_radius(grid: Dictionary, center: Vector2, radius: float, cell_size: float) -> Dictionary:
	var out: Dictionary = {}
	if grid.is_empty():
		return out
	var safe_cell: float = maxf(1.0, cell_size)
	var safe_radius: float = maxf(1.0, radius)
	var min_x: int = int(floor((center.x - safe_radius) / safe_cell))
	var max_x: int = int(floor((center.x + safe_radius) / safe_cell))
	var min_z: int = int(floor((center.y - safe_radius) / safe_cell))
	var max_z: int = int(floor((center.y + safe_radius) / safe_cell))
	for cx in range(min_x, max_x + 1):
		for cz in range(min_z, max_z + 1):
			var key := Vector2i(cx, cz)
			var bucket_any: Variant = grid.get(key, [])
			if not (bucket_any is Array):
				continue
			for id_any in (bucket_any as Array):
				var unit_id: String = String(id_any).strip_edges()
				if not unit_id.is_empty():
					out[unit_id] = true
	return out

func _tick_facility_tower_cooldowns(step_sec: float) -> void:
	if _facility_tower_cooldowns.is_empty():
		return
	for id_any in _facility_tower_cooldowns.keys():
		var tower_id: String = String(id_any)
		var left: float = maxf(0.0, float(_facility_tower_cooldowns.get(id_any, 0.0)) - step_sec)
		if left <= 0.001:
			_facility_tower_cooldowns.erase(tower_id)
		else:
			_facility_tower_cooldowns[tower_id] = left

func _prune_facility_tower_cooldowns(active_tower_ids: Dictionary) -> void:
	if _facility_tower_cooldowns.is_empty():
		return
	for id_any in _facility_tower_cooldowns.keys():
		var tower_id: String = String(id_any)
		if active_tower_ids.has(tower_id):
			continue
		_facility_tower_cooldowns.erase(tower_id)

func _is_runtime_mobile_unit_dead(unit_node: Node3D) -> bool:
	if unit_node == null or not is_instance_valid(unit_node):
		return true
	if unit_node.has_method("get_hp_ratio"):
		if float(unit_node.call("get_hp_ratio")) <= 0.001:
			return true
	var dead_any: Variant = unit_node.get("dead")
	return bool(dead_any) if dead_any is bool else false

func _tick_single_tower_attack(facility: Dictionary, attack_range: float, damage: float, cooldown_sec: float, effect_index: Dictionary) -> void:
	var tower_id: String = String(facility.get("id", "")).strip_edges()
	if tower_id.is_empty():
		return
	var cd_left: float = float(_facility_tower_cooldowns.get(tower_id, 0.0))
	if cd_left > 0.001:
		return
	var facility_faction_id: String = String(facility.get("faction_id", "")).strip_edges()
	if facility_faction_id.is_empty():
		return
	var pos_any: Variant = facility.get("position", {})
	if not (pos_any is Dictionary):
		return
	var pos: Dictionary = pos_any as Dictionary
	var center := Vector2(float(pos.get("x", 0.0)), float(pos.get("z", 0.0)))
	var cell_size: float = maxf(64.0, float(effect_index.get("cell_size", FACILITY_EFFECT_GRID_CELL_SIZE)))
	var mobile_grid_any: Variant = effect_index.get("mobile_grid_all", {})
	var mobile_grid: Dictionary = mobile_grid_any as Dictionary if mobile_grid_any is Dictionary else {}
	var pos_map_any: Variant = effect_index.get("unit_pos2_by_id", {})
	var unit_pos2_by_id: Dictionary = pos_map_any as Dictionary if pos_map_any is Dictionary else {}
	var faction_map_any: Variant = effect_index.get("unit_faction_by_id", {})
	var unit_faction_by_id: Dictionary = faction_map_any as Dictionary if faction_map_any is Dictionary else {}
	var candidate_flags: Dictionary = _effect_grid_collect_ids_in_radius(mobile_grid, center, attack_range, cell_size)
	if candidate_flags.is_empty():
		return
	var range_sq: float = attack_range * attack_range
	var best_dist_sq: float = range_sq
	var best_target_id: String = ""
	var best_target: Node3D = null
	for unit_id_any in candidate_flags.keys():
		var unit_id: String = String(unit_id_any)
		var unit_node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
		if unit_node == null or not is_instance_valid(unit_node):
			continue
		if _is_runtime_mobile_unit_dead(unit_node):
			continue
		var unit_faction_id: String = String(unit_faction_by_id.get(unit_id, "")).strip_edges()
		if unit_faction_id.is_empty() or unit_faction_id == facility_faction_id:
			continue
		var p_any: Variant = unit_pos2_by_id.get(unit_id, null)
		if not (p_any is Vector2):
			continue
		var p: Vector2 = p_any as Vector2
		var dx: float = p.x - center.x
		var dz: float = p.y - center.y
		var d2: float = dx * dx + dz * dz
		if d2 < best_dist_sq:
			best_dist_sq = d2
			best_target_id = unit_id
			best_target = unit_node
	if best_target == null or not is_instance_valid(best_target):
		return
	if best_target_id.is_empty():
		return
	if best_target.has_method("receive_damage"):
		best_target.call("receive_damage", maxf(0.0, damage), null, true)
	_facility_tower_cooldowns[tower_id] = maxf(0.15, cooldown_sec)

func _apply_single_defense_aura(facility: Dictionary, aura_range: float, effect_index: Dictionary) -> void:
	var facility_faction_id: String = String(facility.get("faction_id", "")).strip_edges()
	if facility_faction_id.is_empty():
		return
	var pos_any: Variant = facility.get("position", {})
	if not (pos_any is Dictionary):
		return
	var pos: Dictionary = pos_any as Dictionary
	var center := Vector2(float(pos.get("x", 0.0)), float(pos.get("z", 0.0)))
	var cell_size: float = maxf(64.0, float(effect_index.get("cell_size", FACILITY_EFFECT_GRID_CELL_SIZE)))
	var by_faction_any: Variant = effect_index.get("field_grid_by_faction", {})
	var field_grid_by_faction: Dictionary = by_faction_any as Dictionary if by_faction_any is Dictionary else {}
	var faction_grid_any: Variant = field_grid_by_faction.get(facility_faction_id, {})
	if not (faction_grid_any is Dictionary):
		return
	var faction_grid: Dictionary = faction_grid_any as Dictionary
	var candidate_flags: Dictionary = _effect_grid_collect_ids_in_radius(faction_grid, center, aura_range, cell_size)
	if candidate_flags.is_empty():
		return
	var pos_map_any: Variant = effect_index.get("unit_pos2_by_id", {})
	var unit_pos2_by_id: Dictionary = pos_map_any as Dictionary if pos_map_any is Dictionary else {}
	var range_sq: float = aura_range * aura_range
	for unit_id_any in candidate_flags.keys():
		var unit_id: String = String(unit_id_any)
		var unit_node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
		if unit_node == null or not is_instance_valid(unit_node):
			continue
		if _is_runtime_mobile_unit_dead(unit_node):
			continue
		var p_any: Variant = unit_pos2_by_id.get(unit_id, null)
		if not (p_any is Vector2):
			continue
		var p: Vector2 = p_any as Vector2
		var dx: float = p.x - center.x
		var dz: float = p.y - center.y
		if dx * dx + dz * dz > range_sq:
			continue
		if unit_node.has_method("apply_status"):
			unit_node.call("apply_status", int(UnitController.StatusId.TERRAIN_ADVANTAGE), FACILITY_DEFENSE_STATUS_HOLD_SEC)

func _apply_single_attack_aura(facility: Dictionary, aura_range: float, effect_index: Dictionary) -> void:
	var facility_faction_id: String = String(facility.get("faction_id", "")).strip_edges()
	if facility_faction_id.is_empty():
		return
	var pos_any: Variant = facility.get("position", {})
	if not (pos_any is Dictionary):
		return
	var pos: Dictionary = pos_any as Dictionary
	var center := Vector2(float(pos.get("x", 0.0)), float(pos.get("z", 0.0)))
	var cell_size: float = maxf(64.0, float(effect_index.get("cell_size", FACILITY_EFFECT_GRID_CELL_SIZE)))
	var by_faction_any: Variant = effect_index.get("field_grid_by_faction", {})
	var field_grid_by_faction: Dictionary = by_faction_any as Dictionary if by_faction_any is Dictionary else {}
	var faction_grid_any: Variant = field_grid_by_faction.get(facility_faction_id, {})
	if not (faction_grid_any is Dictionary):
		return
	var faction_grid: Dictionary = faction_grid_any as Dictionary
	var candidate_flags: Dictionary = _effect_grid_collect_ids_in_radius(faction_grid, center, aura_range, cell_size)
	if candidate_flags.is_empty():
		return
	var pos_map_any: Variant = effect_index.get("unit_pos2_by_id", {})
	var unit_pos2_by_id: Dictionary = pos_map_any as Dictionary if pos_map_any is Dictionary else {}
	var range_sq: float = aura_range * aura_range
	for unit_id_any in candidate_flags.keys():
		var unit_id: String = String(unit_id_any)
		var unit_node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
		if unit_node == null or not is_instance_valid(unit_node):
			continue
		if _is_runtime_mobile_unit_dead(unit_node):
			continue
		var p_any: Variant = unit_pos2_by_id.get(unit_id, null)
		if not (p_any is Vector2):
			continue
		var p: Vector2 = p_any as Vector2
		var dx: float = p.x - center.x
		var dz: float = p.y - center.y
		if dx * dx + dz * dz > range_sq:
			continue
		if unit_node.has_method("apply_status"):
			unit_node.call("apply_status", int(UnitController.StatusId.FACILITY_ATTACK_AURA), FACILITY_JUNYUETAI_ATTACK_STATUS_HOLD_SEC)

func _accumulate_single_morale_aura(facility: Dictionary, aura_range: float, morale_per_sec: float, spirit_per_sec: float, out_morale_rates: Dictionary, out_spirit_rates: Dictionary, effect_index: Dictionary) -> void:
	var facility_faction_id: String = String(facility.get("faction_id", "")).strip_edges()
	if facility_faction_id.is_empty():
		return
	var pos_any: Variant = facility.get("position", {})
	if not (pos_any is Dictionary):
		return
	var pos: Dictionary = pos_any as Dictionary
	var center := Vector2(float(pos.get("x", 0.0)), float(pos.get("z", 0.0)))
	var cell_size: float = maxf(64.0, float(effect_index.get("cell_size", FACILITY_EFFECT_GRID_CELL_SIZE)))
	var by_faction_any: Variant = effect_index.get("field_grid_by_faction", {})
	var field_grid_by_faction: Dictionary = by_faction_any as Dictionary if by_faction_any is Dictionary else {}
	var faction_grid_any: Variant = field_grid_by_faction.get(facility_faction_id, {})
	if not (faction_grid_any is Dictionary):
		return
	var faction_grid: Dictionary = faction_grid_any as Dictionary
	var candidate_flags: Dictionary = _effect_grid_collect_ids_in_radius(faction_grid, center, aura_range, cell_size)
	if candidate_flags.is_empty():
		return
	var pos_map_any: Variant = effect_index.get("unit_pos2_by_id", {})
	var unit_pos2_by_id: Dictionary = pos_map_any as Dictionary if pos_map_any is Dictionary else {}
	var range_sq: float = aura_range * aura_range
	for unit_id_any in candidate_flags.keys():
		var unit_id: String = String(unit_id_any)
		var unit_node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
		if unit_node == null or not is_instance_valid(unit_node):
			continue
		if _is_runtime_mobile_unit_dead(unit_node):
			continue
		var p_any: Variant = unit_pos2_by_id.get(unit_id, null)
		if not (p_any is Vector2):
			continue
		var p: Vector2 = p_any as Vector2
		var dx: float = p.x - center.x
		var dz: float = p.y - center.y
		if dx * dx + dz * dz > range_sq:
			continue
		var prev_morale: float = float(out_morale_rates.get(unit_id, 0.0))
		out_morale_rates[unit_id] = maxf(prev_morale, morale_per_sec)
		var prev_spirit: float = float(out_spirit_rates.get(unit_id, 0.0))
		out_spirit_rates[unit_id] = maxf(prev_spirit, spirit_per_sec)

func _apply_accumulated_morale_aura(step_sec: float, morale_rates: Dictionary, spirit_rates: Dictionary) -> void:
	if morale_rates.is_empty() and spirit_rates.is_empty():
		return
	var touched_ids: Dictionary = {}
	for unit_id_any in morale_rates.keys():
		touched_ids[String(unit_id_any)] = true
	for unit_id_any in spirit_rates.keys():
		touched_ids[String(unit_id_any)] = true
	for unit_id_any in touched_ids.keys():
		var unit_id: String = String(unit_id_any)
		var unit_node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
		if unit_node == null or not is_instance_valid(unit_node):
			continue
		if _is_runtime_mobile_unit_dead(unit_node):
			continue
		var morale_gain: float = maxf(0.0, float(morale_rates.get(unit_id_any, 0.0))) * maxf(0.0, step_sec)
		if morale_gain > 0.001 and unit_node.has_method("_apply_morale_delta"):
			unit_node.call("_apply_morale_delta", morale_gain, false)
		var spirit_gain: float = maxf(0.0, float(spirit_rates.get(unit_id_any, 0.0))) * maxf(0.0, step_sec)
		if spirit_gain > 0.001:
			var spirit_cap: float = maxf(1.0, float(unit_node.get("spirit_cap_current")))
			var spirit_now: float = float(unit_node.get("spirit_current"))
			unit_node.set("spirit_current", clampf(spirit_now + spirit_gain, 0.0, spirit_cap))

func _tick_runtime_siege(step_sec: float, effect_index: Dictionary) -> void:
	if step_sec <= 0.0:
		return
	var targets: Array = _collect_runtime_siege_targets()
	if targets.is_empty():
		_runtime_siege_status_by_target_id.clear()
		_cleanup_runtime_siege_capture_hints()
		return
	var cell_size: float = maxf(64.0, float(effect_index.get("cell_size", FACILITY_EFFECT_GRID_CELL_SIZE)))
	var mobile_grid_any: Variant = effect_index.get("mobile_grid_all", {})
	if not (mobile_grid_any is Dictionary):
		return
	var mobile_grid: Dictionary = mobile_grid_any as Dictionary
	var pos_map_any: Variant = effect_index.get("unit_pos2_by_id", {})
	var unit_pos2_by_id: Dictionary = pos_map_any as Dictionary if pos_map_any is Dictionary else {}
	var faction_map_any: Variant = effect_index.get("unit_faction_by_id", {})
	var unit_faction_by_id: Dictionary = faction_map_any as Dictionary if faction_map_any is Dictionary else {}
	var now_msec: int = Time.get_ticks_msec()
	_cleanup_runtime_siege_capture_hints(now_msec)
	var next_status: Dictionary = {}
	var captured_any: bool = false
	for target_any in targets:
		if not (target_any is Dictionary):
			continue
		var target: Dictionary = target_any as Dictionary
		var target_id: String = String(target.get("id", "")).strip_edges()
		if target_id.is_empty():
			continue
		var type_key: String = String(target.get("type", "site")).to_lower().strip_edges()
		var source_kind: String = String(target.get("source", "site")).to_lower().strip_edges()
		var target_faction: String = String(target.get("faction_id", "")).strip_edges()
		var pos_any: Variant = target.get("position", {})
		if not (pos_any is Dictionary):
			continue
		var pos: Dictionary = pos_any as Dictionary
		var center := Vector2(float(pos.get("x", 0.0)), float(pos.get("z", 0.0)))
		var attack_radius: float = _runtime_siege_target_radius(type_key)
		var candidate_flags: Dictionary = _effect_grid_collect_ids_in_radius(mobile_grid, center, attack_radius, cell_size)
		var range_sq: float = attack_radius * attack_radius
		var total_dps: float = 0.0
		var dps_by_faction: Dictionary = {}
		var best_snap_by_faction: Dictionary = {}
		var best_dps_by_faction: Dictionary = {}
		if not candidate_flags.is_empty():
			for unit_id_any in candidate_flags.keys():
				var unit_id: String = String(unit_id_any).strip_edges()
				if unit_id.is_empty():
					continue
				var unit_pos_any: Variant = unit_pos2_by_id.get(unit_id, null)
				if not (unit_pos_any is Vector2):
					continue
				var unit_pos: Vector2 = unit_pos_any as Vector2
				var dx: float = unit_pos.x - center.x
				var dz: float = unit_pos.y - center.y
				if dx * dx + dz * dz > range_sq:
					continue
				var unit_faction: String = String(unit_faction_by_id.get(unit_id, "")).strip_edges()
				if unit_faction.is_empty():
					continue
				if not target_faction.is_empty() and unit_faction == target_faction:
					continue
				var snap: Dictionary = _runtime_mobile_unit_snapshot(unit_id)
				if snap.is_empty():
					continue
				if String(snap.get("type", "")).to_lower().strip_edges() != "field_unit":
					continue
				var unit_node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
				if unit_node == null or not is_instance_valid(unit_node):
					continue
				if _is_runtime_mobile_unit_dead(unit_node):
					continue
				var dps: float = _runtime_siege_unit_dps(unit_node, snap, type_key)
				if dps <= 0.001:
					continue
				total_dps += dps
				dps_by_faction[unit_faction] = float(dps_by_faction.get(unit_faction, 0.0)) + dps
				if dps > float(best_dps_by_faction.get(unit_faction, -1.0)):
					best_dps_by_faction[unit_faction] = dps
					best_snap_by_faction[unit_faction] = snap
		var lead_attacker_faction: String = ""
		var lead_attack_dps: float = -1.0
		for faction_any in dps_by_faction.keys():
			var fid: String = String(faction_any).strip_edges()
			var score: float = float(dps_by_faction.get(faction_any, 0.0))
			if score > lead_attack_dps:
				lead_attack_dps = score
				lead_attacker_faction = fid
		next_status[target_id] = {
			"under_attack": total_dps > 0.001,
			"contested": dps_by_faction.size() >= 2,
			"attacker_count": dps_by_faction.size(),
			"lead_attacker_faction_id": lead_attacker_faction,
			"dps": total_dps,
			"timestamp_msec": now_msec
		}
		if total_dps <= 0.001:
			continue
		var record: Dictionary = {}
		if source_kind == "city":
			record = _runtime_siege_resolve_city_record(target)
		else:
			record = _runtime_siege_resolve_site_record(target)
		if record.is_empty():
			continue
		var prev_faction: String = String(record.get("faction_id", target_faction)).strip_edges()
		var max_hp: float = 0.0
		var current_hp: float = 0.0
		if source_kind == "city":
			var defense_any: Variant = record.get("defense", {})
			var defense: Dictionary = defense_any as Dictionary if defense_any is Dictionary else {}
			max_hp = maxf(1.0, float(defense.get("max", _runtime_siege_default_max_hp(type_key))))
			current_hp = clampf(float(defense.get("current", max_hp)), 0.0, max_hp)
		else:
			max_hp = maxf(1.0, float(record.get("max_hp", _runtime_siege_default_max_hp(type_key))))
			current_hp = clampf(float(record.get("hp", max_hp)), 0.0, max_hp)
			if current_hp <= 0.001:
				var defense_site_any: Variant = record.get("defense", {})
				if defense_site_any is Dictionary:
					current_hp = clampf(float((defense_site_any as Dictionary).get("current", max_hp)), 0.0, max_hp)
		if max_hp <= 0.001:
			continue
		current_hp = maxf(0.0, current_hp - total_dps * step_sec)
		var captured_now: bool = false
		var winner_faction: String = prev_faction
		var winner_snap: Dictionary = {}
		if current_hp <= 0.001 and not dps_by_faction.is_empty():
			captured_now = true
			winner_faction = lead_attacker_faction if not lead_attacker_faction.is_empty() else prev_faction
			var winner_any: Variant = best_snap_by_faction.get(winner_faction, {})
			if winner_any is Dictionary:
				winner_snap = (winner_any as Dictionary).duplicate(true)
			current_hp = maxf(1.0, max_hp * clampf(RUNTIME_SIEGE_CAPTURE_RECOVERY_RATIO, 0.05, 0.9))
			record["faction_id"] = winner_faction
		if source_kind == "city":
			_runtime_siege_update_city_defense(record, current_hp, max_hp)
			_upsert_world_city(record)
			_runtime_siege_sync_city_building_entry(record)
		else:
			_runtime_siege_update_site_defense(record, current_hp, max_hp)
			_upsert_world_building_unit(record)
		if captured_now and winner_faction != prev_faction:
			captured_any = true
			_runtime_siege_recent_capture_until[target_id] = now_msec + RUNTIME_SIEGE_RECENT_CAPTURE_HINT_MS
			if winner_snap.is_empty():
				winner_snap = {
					"id": "",
					"name": "军情室",
					"faction_id": winner_faction
				}
			var report_target: Dictionary = record.duplicate(true)
			report_target["faction_id"] = prev_faction
			report_target["type"] = type_key
			report_target["max_hp"] = max_hp
			_report_runtime_site_victory(winner_snap, report_target, winner_faction)
	_runtime_siege_status_by_target_id = next_status
	if captured_any:
		_supply_pending_full_recalc = true
		_refresh_supply_fog_runtime(true)
		_refresh_runtime_ui_hud(true)
	_runtime_siege_info_refresh_accum = RUNTIME_SIEGE_INFO_REFRESH_SEC

func _cleanup_runtime_siege_capture_hints(now_msec: int = -1) -> void:
	if _runtime_siege_recent_capture_until.is_empty():
		return
	var now_ticks: int = now_msec if now_msec >= 0 else Time.get_ticks_msec()
	for id_any in _runtime_siege_recent_capture_until.keys():
		var target_id: String = String(id_any).strip_edges()
		if target_id.is_empty():
			_runtime_siege_recent_capture_until.erase(id_any)
			continue
		var expire_msec: int = int(_runtime_siege_recent_capture_until.get(id_any, 0))
		if expire_msec <= now_ticks:
			_runtime_siege_recent_capture_until.erase(id_any)

func _collect_runtime_siege_targets() -> Array:
	var out: Array = []
	var index_by_key: Dictionary = {}
	if _city_overlay != null:
		var city_root: Node = _city_overlay.get_node_or_null("CityInstances")
		if city_root != null:
			for child in city_root.get_children():
				if not (child is Node3D):
					continue
				var city_node := child as Node3D
				var city_name: String = String(city_node.get_meta("city_name", city_node.name.trim_prefix("City_"))).strip_edges()
				if city_name.is_empty():
					continue
				var world_city: Dictionary = _resolve_world_city(city_name, city_name)
				var city_id: String = String(world_city.get("id", city_name)).strip_edges()
				if city_id.is_empty():
					city_id = city_name
				_merge_runtime_siege_target(out, index_by_key, {
					"id": city_id,
					"name": String(world_city.get("name", city_name)),
					"type": "city",
					"source": "city",
					"city_id": city_id,
					"faction_id": String(world_city.get("faction_id", "")).strip_edges(),
					"position": {
						"x": float(city_node.global_position.x),
						"z": float(city_node.global_position.z)
					}
				})
	if _strategic_site_manager != null:
		var site_lookup: Dictionary = {}
		if _strategic_site_manager.has_method("get_all_site_snapshots"):
			var defs_any: Variant = _strategic_site_manager.call("get_all_site_snapshots")
			if defs_any is Array:
				for def_any in (defs_any as Array):
					if not (def_any is Dictionary):
						continue
					var def: Dictionary = def_any as Dictionary
					var site_id_seed: String = String(def.get("id", "")).strip_edges()
					if not site_id_seed.is_empty():
						site_lookup[site_id_seed] = def
		var site_root: Node = _strategic_site_manager.get_node_or_null("SiteInstances")
		if site_root != null:
			for child in site_root.get_children():
				if not (child is Node3D):
					continue
				var site_node := child as Node3D
				var site_id: String = String(site_node.get_meta("building_id", "")).strip_edges()
				if site_id.is_empty():
					var node_name: String = String(site_node.name)
					if node_name.begins_with("Site_"):
						site_id = node_name.trim_prefix("Site_")
				if site_id.is_empty():
					continue
				var snapshot: Dictionary = site_lookup.get(site_id, {}) as Dictionary
				var site_type: String = String(site_node.get_meta("building_type", snapshot.get("type", "site"))).to_lower().strip_edges()
				if not _is_runtime_siege_target_type(site_type):
					continue
				var site_name: String = String(site_node.get_meta("site_name", snapshot.get("name", site_id))).strip_edges()
				var world_site: Dictionary = _resolve_world_building(site_id, site_name)
				var faction_id: String = String(world_site.get("faction_id", snapshot.get("faction_id", ""))).strip_edges()
				_merge_runtime_siege_target(out, index_by_key, {
					"id": site_id,
					"name": site_name if not site_name.is_empty() else site_id,
					"type": site_type,
					"source": "site",
					"city_id": String(snapshot.get("city_id", site_id)),
					"faction_id": faction_id,
					"position": {
						"x": float(site_node.global_position.x),
						"z": float(site_node.global_position.z)
					}
				})
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if units_any is Array:
		for unit_any in (units_any as Array):
			if not (unit_any is Dictionary):
				continue
			var unit: Dictionary = unit_any as Dictionary
			var type_key: String = String(unit.get("type", "site")).to_lower().strip_edges()
			if not _is_runtime_siege_target_type(type_key):
				continue
			if _is_runtime_constructed_facility_type(type_key):
				continue
			if _is_runtime_mobile_unit_type(type_key):
				continue
			var unit_id: String = String(unit.get("id", unit.get("city_id", ""))).strip_edges()
			if unit_id.is_empty():
				continue
			var pos_any: Variant = unit.get("position", {})
			if not (pos_any is Dictionary):
				continue
			var pos: Dictionary = pos_any as Dictionary
			_merge_runtime_siege_target(out, index_by_key, {
				"id": unit_id,
				"name": String(unit.get("name", unit_id)).strip_edges(),
				"type": type_key,
				"source": "city" if type_key == "city" else "site",
				"city_id": String(unit.get("city_id", unit_id)).strip_edges(),
				"faction_id": String(unit.get("faction_id", "")).strip_edges(),
				"position": {
					"x": float(pos.get("x", 0.0)),
					"z": float(pos.get("z", 0.0))
				}
			})
	return out

func _merge_runtime_siege_target(out: Array, index_by_key: Dictionary, target: Dictionary) -> void:
	var target_id: String = String(target.get("id", "")).strip_edges()
	var target_name: String = String(target.get("name", "")).strip_edges()
	var key: String = target_id.to_lower()
	if key.is_empty():
		key = target_name.to_lower()
	if key.is_empty():
		return
	if not index_by_key.has(key):
		index_by_key[key] = out.size()
		out.append(target.duplicate(true))
		return
	var idx: int = int(index_by_key.get(key, -1))
	if idx < 0 or idx >= out.size():
		return
	var existing_any: Variant = out[idx]
	var existing: Dictionary = existing_any as Dictionary if existing_any is Dictionary else {}
	if existing.is_empty():
		out[idx] = target.duplicate(true)
		return
	if String(existing.get("id", "")).strip_edges().is_empty() and not target_id.is_empty():
		existing["id"] = target_id
	if String(existing.get("name", "")).strip_edges().is_empty() and not target_name.is_empty():
		existing["name"] = target_name
	var existing_type: String = String(existing.get("type", "")).to_lower().strip_edges()
	var target_type: String = String(target.get("type", "")).to_lower().strip_edges()
	if existing_type.is_empty() and not target_type.is_empty():
		existing["type"] = target_type
	var existing_source: String = String(existing.get("source", "")).to_lower().strip_edges()
	var target_source: String = String(target.get("source", "")).to_lower().strip_edges()
	if existing_source.is_empty():
		existing["source"] = target_source
	elif existing_source != "city" and target_source == "city":
		existing["source"] = "city"
	var existing_faction: String = String(existing.get("faction_id", "")).strip_edges()
	var target_faction: String = String(target.get("faction_id", "")).strip_edges()
	if existing_faction.is_empty() and not target_faction.is_empty():
		existing["faction_id"] = target_faction
	var city_id_existing: String = String(existing.get("city_id", "")).strip_edges()
	var city_id_target: String = String(target.get("city_id", "")).strip_edges()
	if city_id_existing.is_empty() and not city_id_target.is_empty():
		existing["city_id"] = city_id_target
	var existing_pos_any: Variant = existing.get("position", null)
	var existing_has_pos: bool = false
	if existing_pos_any is Dictionary:
		var existing_pos: Dictionary = existing_pos_any as Dictionary
		existing_has_pos = existing_pos.has("x") and existing_pos.has("z")
	var pos_any: Variant = target.get("position", null)
	if not existing_has_pos and pos_any is Dictionary:
		existing["position"] = (pos_any as Dictionary).duplicate(true)
	out[idx] = existing

func _is_runtime_siege_target_type(type_key: String) -> bool:
	var key: String = type_key.to_lower().strip_edges()
	return key == "city" or key == "pass" or key == "fort" or key == "ferry" or key == "resource" or key == "site" or key == "stronghold" or key == "outpost"

func _runtime_siege_target_radius(type_key: String) -> float:
	var key: String = type_key.to_lower().strip_edges()
	match key:
		"city":
			return RUNTIME_SIEGE_CITY_ATTACK_RADIUS
		"stronghold":
			return RUNTIME_SIEGE_STRONGHOLD_ATTACK_RADIUS
		"pass", "fort":
			return maxf(RUNTIME_SIEGE_SITE_ATTACK_RADIUS, 360.0)
		_:
			return RUNTIME_SIEGE_SITE_ATTACK_RADIUS

func _runtime_siege_default_max_hp(type_key: String) -> float:
	match type_key.to_lower().strip_edges():
		"city":
			return 36000.0
		"stronghold":
			return 15000.0
		"pass":
			return 14000.0
		"fort":
			return 12500.0
		"outpost":
			return 11000.0
		"ferry":
			return 9000.0
		"resource":
			return 8200.0
		"site":
			return 9200.0
		_:
			return 10000.0

func _runtime_siege_resolve_city_record(target: Dictionary) -> Dictionary:
	var city_id: String = String(target.get("id", target.get("city_id", ""))).strip_edges()
	var city_name: String = String(target.get("name", city_id)).strip_edges()
	var city: Dictionary = _resolve_world_city(city_id, city_name)
	var changed: bool = false
	if city.is_empty():
		if city_id.is_empty():
			city_id = city_name
		if city_id.is_empty():
			return {}
		if city_name.is_empty():
			city_name = city_id
		city = {
			"id": city_id,
			"city_id": city_id,
			"name": city_name,
			"type": "city",
			"faction_id": String(target.get("faction_id", "")).strip_edges()
		}
		changed = true
	if String(city.get("id", "")).strip_edges().is_empty():
		city["id"] = city_id if not city_id.is_empty() else city_name
		changed = true
	if String(city.get("city_id", "")).strip_edges().is_empty():
		city["city_id"] = String(city.get("id", ""))
		changed = true
	if String(city.get("name", "")).strip_edges().is_empty():
		city["name"] = city_name if not city_name.is_empty() else String(city.get("id", "鍩庡競"))
		changed = true
	city["type"] = "city"
	var pos_any: Variant = city.get("position", null)
	if not (pos_any is Dictionary):
		var target_pos_any: Variant = target.get("position", {})
		if target_pos_any is Dictionary:
			city["position"] = (target_pos_any as Dictionary).duplicate(true)
			changed = true
	var defense_any: Variant = city.get("defense", {})
	var defense: Dictionary = defense_any as Dictionary if defense_any is Dictionary else {}
	var max_hp: float = float(defense.get("max", 0.0))
	if max_hp <= 1.0:
		var class_any: Variant = city.get("classification", {})
		var class_dict: Dictionary = class_any as Dictionary if class_any is Dictionary else {}
		var scale_key: String = _normalize_city_scale(String(class_dict.get("scale", city.get("scale", "medium"))))
		var caps: Dictionary = _city_caps_for_scale(scale_key)
		max_hp = maxf(_runtime_siege_default_max_hp("city"), float(caps.get("defense_max", _runtime_siege_default_max_hp("city"))))
		defense["max"] = max_hp
		changed = true
	var current_hp: float = clampf(float(defense.get("current", max_hp)), 0.0, max_hp)
	if not defense.has("current") or absf(float(defense.get("current", current_hp)) - current_hp) > 0.1:
		defense["current"] = current_hp
		changed = true
	city["defense"] = defense
	if changed:
		_upsert_world_city(city)
	return city

func _runtime_siege_resolve_site_record(target: Dictionary) -> Dictionary:
	var site_id: String = String(target.get("id", target.get("city_id", ""))).strip_edges()
	var site_name: String = String(target.get("name", site_id)).strip_edges()
	var type_key: String = String(target.get("type", "site")).to_lower().strip_edges()
	var site: Dictionary = _resolve_world_building(site_id, site_name)
	var changed: bool = false
	if site.is_empty():
		if site_id.is_empty():
			site_id = site_name
		if site_id.is_empty():
			return {}
		if site_name.is_empty():
			site_name = site_id
		site = {
			"id": site_id,
			"city_id": String(target.get("city_id", site_id)).strip_edges(),
			"name": site_name,
			"type": type_key,
			"faction_id": String(target.get("faction_id", "")).strip_edges()
		}
		changed = true
	if String(site.get("id", "")).strip_edges().is_empty():
		site["id"] = site_id
		changed = true
	if String(site.get("name", "")).strip_edges().is_empty():
		site["name"] = site_name if not site_name.is_empty() else site_id
		changed = true
	if String(site.get("city_id", "")).strip_edges().is_empty():
		site["city_id"] = String(target.get("city_id", site.get("id", ""))).strip_edges()
		changed = true
	if String(site.get("type", "")).to_lower().strip_edges().is_empty():
		site["type"] = type_key
		changed = true
	var pos_any: Variant = site.get("position", null)
	if not (pos_any is Dictionary):
		var target_pos_any: Variant = target.get("position", {})
		if target_pos_any is Dictionary:
			site["position"] = (target_pos_any as Dictionary).duplicate(true)
			changed = true
	var default_max: float = _runtime_siege_default_max_hp(String(site.get("type", type_key)))
	var max_hp: float = maxf(1.0, float(site.get("max_hp", default_max)))
	if max_hp <= 1.0:
		max_hp = default_max
		site["max_hp"] = max_hp
		changed = true
	var hp: float = clampf(float(site.get("hp", max_hp)), 0.0, max_hp)
	if not site.has("hp") or absf(float(site.get("hp", hp)) - hp) > 0.1:
		site["hp"] = hp
		changed = true
	var defense_any: Variant = site.get("defense", {})
	var defense: Dictionary = defense_any as Dictionary if defense_any is Dictionary else {}
	if absf(float(defense.get("max", max_hp)) - max_hp) > 0.1:
		defense["max"] = max_hp
		changed = true
	if absf(float(defense.get("current", hp)) - hp) > 0.1:
		defense["current"] = hp
		changed = true
	site["defense"] = defense
	if changed:
		_upsert_world_building_unit(site)
	return site

func _runtime_siege_role_multiplier(role_id: String) -> float:
	match role_id.strip_edges().to_lower():
		"siege":
			return 1.35
		"strategist":
			return 0.72
		"cavalry":
			return 0.9
		"archer", "crossbow":
			return 0.95
		_:
			return 1.0

func _runtime_siege_target_multiplier(type_key: String) -> float:
	match type_key.to_lower().strip_edges():
		"city":
			return 0.9
		"pass", "fort", "stronghold":
			return 1.0
		_:
			return 1.12

func _runtime_siege_unit_dps(unit_node: Node3D, unit_snap: Dictionary, target_type: String) -> float:
	var troops: float = float(_runtime_mobile_troops(unit_snap))
	if unit_node != null and is_instance_valid(unit_node):
		if unit_node.has_method("get_alive_troop_count"):
			troops = maxf(1.0, float(unit_node.call("get_alive_troop_count")))
		elif unit_node.has_method("get_hp_ratio"):
			troops = maxf(1.0, troops * clampf(float(unit_node.call("get_hp_ratio")), 0.05, 1.0))
	var role_id: String = ""
	if unit_node != null and is_instance_valid(unit_node):
		if unit_node.has_method("get_combat_role_id"):
			role_id = String(unit_node.call("get_combat_role_id")).strip_edges().to_lower()
		else:
			var role_any: Variant = unit_node.get("combat_role_id")
			if role_any != null:
				role_id = String(role_any).strip_edges().to_lower()
	if role_id.is_empty():
		role_id = String(unit_snap.get("combat_role_id", "infantry")).strip_edges().to_lower()
	var dps: float = maxf(RUNTIME_SIEGE_MIN_DPS_PER_UNIT, troops * RUNTIME_SIEGE_BASE_DPS_PER_TROOP)
	dps *= _runtime_siege_role_multiplier(role_id)
	dps *= _runtime_siege_target_multiplier(target_type)
	return maxf(0.0, dps)

func _runtime_siege_update_city_defense(city: Dictionary, current_hp: float, max_hp: float) -> void:
	var safe_max: float = maxf(1.0, max_hp)
	var defense_any: Variant = city.get("defense", {})
	var defense: Dictionary = defense_any as Dictionary if defense_any is Dictionary else {}
	defense["max"] = safe_max
	defense["current"] = clampf(current_hp, 0.0, safe_max)
	city["defense"] = defense

func _runtime_siege_update_site_defense(site: Dictionary, current_hp: float, max_hp: float) -> void:
	var safe_max: float = maxf(1.0, max_hp)
	var safe_hp: float = clampf(current_hp, 0.0, safe_max)
	site["max_hp"] = safe_max
	site["hp"] = safe_hp
	var defense_any: Variant = site.get("defense", {})
	var defense: Dictionary = defense_any as Dictionary if defense_any is Dictionary else {}
	defense["max"] = safe_max
	defense["current"] = safe_hp
	site["defense"] = defense

func _runtime_siege_sync_city_building_entry(city: Dictionary) -> void:
	var city_id: String = String(city.get("id", "")).strip_edges()
	if city_id.is_empty():
		return
	var city_name: String = String(city.get("name", city_id)).strip_edges()
	var existing: Dictionary = _resolve_world_building(city_id, city_name)
	if existing.is_empty():
		return
	existing["id"] = city_id
	existing["city_id"] = city_id
	existing["name"] = city_name if not city_name.is_empty() else city_id
	existing["type"] = "city"
	existing["faction_id"] = String(city.get("faction_id", existing.get("faction_id", ""))).strip_edges()
	var pos_any: Variant = city.get("position", {})
	if pos_any is Dictionary:
		existing["position"] = (pos_any as Dictionary).duplicate(true)
	_upsert_world_building_unit(existing)

func _setup_runtime_battle_controller() -> void:
	var node: Node = get_node_or_null("RuntimeBattleController")
	if node != null and is_instance_valid(node):
		_battle_runtime = node
	else:
		_battle_runtime = BattlefieldControllerScript.new()
		_battle_runtime.name = "RuntimeBattleController"
		if _battle_runtime.has_method("set"):
			_battle_runtime.set("embedded_on_strategy_map", true)
			_battle_runtime.set("auto_spawn_demo_units", false)
			_battle_runtime.set("show_unit_tags", true)
			_battle_runtime.set("debug_allow_control_all_units_for_testing", _runtime_allow_control_all_units_for_testing)
		add_child(_battle_runtime)
	if _battle_runtime == null or not is_instance_valid(_battle_runtime):
		return
	if _battle_runtime.has_method("set"):
		_battle_runtime.set("embedded_on_strategy_map", true)
		_battle_runtime.set("auto_spawn_demo_units", false)
		_battle_runtime.set("show_unit_tags", true)
		_battle_runtime.set("debug_allow_control_all_units_for_testing", _runtime_allow_control_all_units_for_testing)
	if _battle_runtime.has_method("set_strategy_map_view"):
		_battle_runtime.call("set_strategy_map_view", self)
	if _battle_runtime.has_signal("weather_state_changed"):
		var cb := Callable(self, "_on_battle_weather_state_changed")
		if not _battle_runtime.is_connected("weather_state_changed", cb):
			_battle_runtime.connect("weather_state_changed", cb)
	_push_weather_context_to_battle_runtime()
	_apply_runtime_battle_motion_state()

func _setup_runtime_time_weather() -> void:
	if _world_env != null and is_instance_valid(_world_env):
		var source_env: Environment = _world_env.environment
		if source_env != null:
			_runtime_weather_environment = source_env.duplicate(true) as Environment
			if _runtime_weather_environment != null:
				_world_env.environment = _runtime_weather_environment
	_sync_runtime_time_weather_state(true)

func _setup_runtime_battle_phase_rules() -> void:
	_runtime_seconds_per_day = maxf(0.2, float(_engine_rules_cache.get("seconds_per_day", 6.0)))
	var rules_any: Variant = _runtime_time_weather.get("rules", {})
	var rules: Dictionary = rules_any as Dictionary if rules_any is Dictionary else {}
	var days_per_turn: float = maxf(1.0, float(rules.get("days_per_turn", 10.0)))
	_runtime_battle_total_seconds = maxf(3.0, _runtime_seconds_per_day * days_per_turn)
	_runtime_phase = RUNTIME_PHASE_INTERNAL
	_runtime_battle_elapsed_seconds = 0.0
	_runtime_battle_speed = 1.0
	_runtime_battle_paused = false
	_runtime_status_message = ""
	_runtime_last_battle_day_phase = String(_runtime_time_weather.get("day_phase", "day"))
	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	meta["phase"] = RUNTIME_PHASE_INTERNAL
	_world_state_cache["meta"] = meta
	_apply_runtime_global_time_scale()
	_apply_runtime_battle_motion_state()

func _tick_runtime_battle_phase(delta: float) -> void:
	if _runtime_phase != RUNTIME_PHASE_BATTLE:
		return
	if _runtime_battle_paused:
		return
	if delta <= 0.0:
		return
	_runtime_battle_elapsed_seconds = minf(_runtime_battle_total_seconds, _runtime_battle_elapsed_seconds + delta)
	var left_seconds: float = maxf(0.0, _runtime_battle_total_seconds - _runtime_battle_elapsed_seconds)
	_runtime_status_message = "战斗阶段进行中：剩余 %.1f 秒" % left_seconds
	if _runtime_battle_elapsed_seconds >= _runtime_battle_total_seconds - 0.0001:
		_finish_runtime_battle_phase()

func _apply_runtime_global_time_scale() -> void:
	var scale: float = 1.0
	if _runtime_phase == RUNTIME_PHASE_BATTLE:
		if _runtime_battle_paused:
			scale = 0.0
		else:
			scale = clampf(_runtime_battle_speed, 0.5, 6.0)
	Engine.time_scale = scale

func _apply_runtime_battle_motion_state() -> void:
	if _battle_runtime == null or not is_instance_valid(_battle_runtime):
		return
	if not _battle_runtime.has_method("set_units_motion_enabled"):
		return
	var allow_motion: bool = _runtime_phase == RUNTIME_PHASE_BATTLE and not _runtime_battle_paused
	_battle_runtime.call("set_units_motion_enabled", allow_motion)

func _enter_runtime_battle_phase() -> void:
	if _runtime_phase == RUNTIME_PHASE_BATTLE:
		return
	_runtime_phase = RUNTIME_PHASE_BATTLE
	_runtime_battle_elapsed_seconds = 0.0
	_runtime_battle_paused = false
	_runtime_status_message = "战斗阶段开始。"
	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	meta["phase"] = RUNTIME_PHASE_BATTLE
	_world_state_cache["meta"] = meta
	_apply_runtime_global_time_scale()
	_apply_runtime_battle_motion_state()
	_sync_runtime_time_weather_state(true)
	_refresh_supply_fog_runtime(true)
	_refresh_runtime_ui_hud(true)

func _finish_runtime_battle_phase() -> void:
	if _runtime_phase != RUNTIME_PHASE_BATTLE:
		return
	_runtime_battle_elapsed_seconds = _runtime_battle_total_seconds
	var rules_any: Variant = _runtime_time_weather.get("rules", {})
	var rules: Dictionary = rules_any as Dictionary if rules_any is Dictionary else _build_time_weather_rules({})
	var days_per_turn: float = maxf(1.0, float(rules.get("days_per_turn", 10.0)))
	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	meta["calendar_day"] = maxf(1.0, float(meta.get("calendar_day", 1.0)) + days_per_turn)
	meta["phase"] = RUNTIME_PHASE_INTERNAL
	_world_state_cache["meta"] = meta
	_runtime_phase = RUNTIME_PHASE_INTERNAL
	_runtime_battle_paused = false
	_runtime_battle_elapsed_seconds = 0.0
	_runtime_status_message = "一日战斗结束，返回内政阶段。"
	_apply_runtime_global_time_scale()
	_apply_runtime_battle_motion_state()
	_sync_runtime_time_weather_state(true)
	_refresh_supply_fog_runtime(true)
	_refresh_runtime_ui_hud(true)

func _on_runtime_proceed_battle_requested() -> void:
	if _runtime_phase == RUNTIME_PHASE_BATTLE:
		return
	_enter_runtime_battle_phase()

func _on_runtime_battle_pause_toggled(paused: bool) -> void:
	if _runtime_phase != RUNTIME_PHASE_BATTLE:
		return
	_runtime_battle_paused = paused
	_runtime_status_message = "战斗已暂停。" if paused else "战斗继续。"
	_apply_runtime_global_time_scale()
	_apply_runtime_battle_motion_state()
	_refresh_runtime_ui_hud(true)

func _on_runtime_battle_speed_requested(speed: float) -> void:
	_runtime_battle_speed = clampf(speed, 1.0, 6.0)
	if _runtime_phase == RUNTIME_PHASE_BATTLE and not _runtime_battle_paused:
		_runtime_status_message = "鎴樻枟閫熷害 x%.1f" % _runtime_battle_speed
	_apply_runtime_global_time_scale()
	_refresh_runtime_ui_hud(true)

func _build_time_weather_rules(raw_rules: Dictionary) -> Dictionary:
	var out: Dictionary = DEFAULT_TIME_WEATHER_RULES.duplicate(true)
	if raw_rules.is_empty():
		return out
	out["enabled"] = bool(raw_rules.get("enabled", out.get("enabled", true)))
	out["days_per_turn"] = maxf(1.0, float(raw_rules.get("days_per_turn", out.get("days_per_turn", 10.0))))
	out["default_weather_state"] = _normalize_weather_state(String(raw_rules.get("default_weather_state", out.get("default_weather_state", "sunny"))))
	var default_wind_dir: Variant = raw_rules.get("default_wind_dir", out.get("default_wind_dir", [1.0, 0.0]))
	if default_wind_dir is Array and (default_wind_dir as Array).size() >= 2:
		out["default_wind_dir"] = [float((default_wind_dir as Array)[0]), float((default_wind_dir as Array)[1])]
	out["default_wind_strength"] = maxf(0.0, float(raw_rules.get("default_wind_strength", out.get("default_wind_strength", 0.0))))
	out["battle_phase_day_ratio"] = clampf(float(raw_rules.get("battle_phase_day_ratio", out.get("battle_phase_day_ratio", 0.6))), 0.05, 0.95)

	var battle_cycle_any: Variant = raw_rules.get("battle_phase_cycle", out.get("battle_phase_cycle", ["day", "night"]))
	if battle_cycle_any is Array:
		var battle_cycle: Array = []
		for phase_any in (battle_cycle_any as Array):
			var phase_battle: String = _normalize_day_phase(String(phase_any))
			if phase_battle.is_empty():
				continue
			battle_cycle.append(phase_battle)
		if not battle_cycle.is_empty():
			out["battle_phase_cycle"] = battle_cycle

	var phase_cycle_any: Variant = raw_rules.get("turn_day_phase_cycle", out.get("turn_day_phase_cycle", ["day", "night"]))
	if phase_cycle_any is Array:
		var phases: Array = []
		for phase_any in (phase_cycle_any as Array):
			var phase: String = _normalize_day_phase(String(phase_any))
			if phase.is_empty():
				continue
			phases.append(phase)
		if not phases.is_empty():
			out["turn_day_phase_cycle"] = phases

	var weather_cycle_any: Variant = raw_rules.get("weather_cycle_by_turn", out.get("weather_cycle_by_turn", []))
	if weather_cycle_any is Array:
		var weather_cycle: Array = []
		for state_any in (weather_cycle_any as Array):
			var state: String = _normalize_weather_state(String(state_any))
			if state.is_empty():
				continue
			weather_cycle.append(state)
		if not weather_cycle.is_empty():
			out["weather_cycle_by_turn"] = weather_cycle

	var phase_mul_any: Variant = raw_rules.get("day_phase_visibility_mul", {})
	if phase_mul_any is Dictionary:
		var phase_mul: Dictionary = out.get("day_phase_visibility_mul", {}).duplicate(true)
		for key_any in (phase_mul_any as Dictionary).keys():
			var key: String = _normalize_day_phase(String(key_any))
			phase_mul[key] = clampf(float((phase_mul_any as Dictionary).get(key_any, phase_mul.get(key, 1.0))), 0.15, 2.0)
		out["day_phase_visibility_mul"] = phase_mul

	var weather_mul_any: Variant = raw_rules.get("weather_visibility_mul", {})
	if weather_mul_any is Dictionary:
		var weather_mul: Dictionary = out.get("weather_visibility_mul", {}).duplicate(true)
		for key_any in (weather_mul_any as Dictionary).keys():
			var key: String = _normalize_weather_state(String(key_any))
			weather_mul[key] = clampf(float((weather_mul_any as Dictionary).get(key_any, weather_mul.get(key, 1.0))), 0.15, 2.0)
		out["weather_visibility_mul"] = weather_mul

	var sun_energy_any: Variant = raw_rules.get("sun_energy_by_phase", {})
	if sun_energy_any is Dictionary:
		var sun_energy: Dictionary = out.get("sun_energy_by_phase", {}).duplicate(true)
		for key_any in (sun_energy_any as Dictionary).keys():
			var key: String = _normalize_day_phase(String(key_any))
			sun_energy[key] = clampf(float((sun_energy_any as Dictionary).get(key_any, sun_energy.get(key, 1.0))), 0.02, 3.5)
		out["sun_energy_by_phase"] = sun_energy

	var ambient_energy_any: Variant = raw_rules.get("ambient_energy_by_phase", {})
	if ambient_energy_any is Dictionary:
		var ambient_energy: Dictionary = out.get("ambient_energy_by_phase", {}).duplicate(true)
		for key_any in (ambient_energy_any as Dictionary).keys():
			var key: String = _normalize_day_phase(String(key_any))
			ambient_energy[key] = clampf(float((ambient_energy_any as Dictionary).get(key_any, ambient_energy.get(key, 1.0))), 0.02, 3.5)
		out["ambient_energy_by_phase"] = ambient_energy

	var fog_density_any: Variant = raw_rules.get("fog_density_by_weather", {})
	if fog_density_any is Dictionary:
		var fog_density: Dictionary = out.get("fog_density_by_weather", {}).duplicate(true)
		for key_any in (fog_density_any as Dictionary).keys():
			var key: String = _normalize_weather_state(String(key_any))
			fog_density[key] = clampf(float((fog_density_any as Dictionary).get(key_any, fog_density.get(key, 0.0))), 0.0, 0.2)
		out["fog_density_by_weather"] = fog_density

	var map_weather_vfx_any: Variant = raw_rules.get("map_weather_vfx", {})
	if map_weather_vfx_any is Dictionary:
		var base_vfx_any: Variant = out.get("map_weather_vfx", {})
		var base_vfx: Dictionary = base_vfx_any as Dictionary if base_vfx_any is Dictionary else {}
		var merged_vfx: Dictionary = _merge_dictionary_recursive(base_vfx, map_weather_vfx_any as Dictionary)
		out["map_weather_vfx"] = merged_vfx
	return out

func _merge_dictionary_recursive(base: Dictionary, override_data: Dictionary) -> Dictionary:
	var out: Dictionary = base.duplicate(true)
	for key_any in override_data.keys():
		var next_any: Variant = override_data.get(key_any, null)
		if next_any is Dictionary:
			var current_any: Variant = out.get(key_any, {})
			if current_any is Dictionary:
				out[key_any] = _merge_dictionary_recursive(current_any as Dictionary, next_any as Dictionary)
				continue
		out[key_any] = next_any
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

func _day_phase_for_turn(turn_index: int, rules: Dictionary) -> String:
	var cycle_any: Variant = rules.get("turn_day_phase_cycle", ["day", "night"])
	if not (cycle_any is Array) or (cycle_any as Array).is_empty():
		return "day"
	var cycle: Array = cycle_any as Array
	return _normalize_day_phase(String(cycle[posmod(turn_index, cycle.size())]))

func _day_phase_for_battle_progress(rules: Dictionary) -> String:
	var cycle_any: Variant = rules.get("battle_phase_cycle", ["day", "night"])
	var cycle: Array = cycle_any as Array if cycle_any is Array else []
	if cycle.is_empty():
		cycle = ["day", "night"]
	if cycle.size() == 1:
		return _normalize_day_phase(String(cycle[0]))
	var progress: float = 0.0
	if _runtime_battle_total_seconds > 0.001:
		progress = clampf(_runtime_battle_elapsed_seconds / _runtime_battle_total_seconds, 0.0, 1.0)
	var day_ratio: float = clampf(float(rules.get("battle_phase_day_ratio", 0.5)), 0.05, 0.95)
	var first_phase: String = _normalize_day_phase(String(cycle[0]))
	var second_phase: String = _normalize_day_phase(String(cycle[1]))
	return first_phase if progress < day_ratio else second_phase

func _sync_runtime_time_weather_state(force_apply: bool = false) -> void:
	if _world_state_cache.is_empty():
		return
	var rules_raw_any: Variant = _engine_rules_cache.get("time_weather_rules", {})
	var rules_raw: Dictionary = rules_raw_any as Dictionary if rules_raw_any is Dictionary else {}
	var rules: Dictionary = _build_time_weather_rules(rules_raw)

	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	var day_value: float = maxf(1.0, float(meta.get("calendar_day", 1.0)))
	meta["calendar_day"] = day_value
	var days_per_turn: float = maxf(1.0, float(rules.get("days_per_turn", 10.0)))
	var turn_index: int = maxi(0, int(floor((day_value - 1.0) / days_per_turn)))
	var day_phase: String = _day_phase_for_turn(turn_index, rules)
	if _runtime_phase == RUNTIME_PHASE_BATTLE:
		day_phase = _day_phase_for_battle_progress(rules)

	var weather_any: Variant = meta.get("weather", {})
	var weather: Dictionary = weather_any as Dictionary if weather_any is Dictionary else {}
	if weather.is_empty():
		weather = {
			"state": String(rules.get("default_weather_state", "sunny")),
			"wind_dir": rules.get("default_wind_dir", [1.0, 0.0]),
			"wind_strength": float(rules.get("default_wind_strength", 0.0))
		}

	var weather_cycle_any: Variant = rules.get("weather_cycle_by_turn", [])
	var weather_cycle: Array = weather_cycle_any as Array if weather_cycle_any is Array else []
	var weather_turn_index: int = int(meta.get("weather_turn_index", -999999))
	if weather_turn_index != turn_index:
		if not weather_cycle.is_empty():
			var idx: int = posmod(turn_index, weather_cycle.size())
			weather["state"] = _normalize_weather_state(String(weather_cycle[idx]))
		meta["weather_turn_index"] = turn_index

	var weather_state: String = _normalize_weather_state(String(weather.get("state", rules.get("default_weather_state", "sunny"))))
	weather["state"] = weather_state
	if not weather.has("wind_dir"):
		weather["wind_dir"] = rules.get("default_wind_dir", [1.0, 0.0])
	if not weather.has("wind_strength"):
		weather["wind_strength"] = float(rules.get("default_wind_strength", 0.0))
	weather["day_phase"] = day_phase
	meta["weather"] = weather
	_world_state_cache["meta"] = meta

	var day_phase_mul_any: Variant = rules.get("day_phase_visibility_mul", {})
	var day_phase_mul: Dictionary = day_phase_mul_any as Dictionary if day_phase_mul_any is Dictionary else {}
	var weather_mul_any: Variant = rules.get("weather_visibility_mul", {})
	var weather_mul: Dictionary = weather_mul_any as Dictionary if weather_mul_any is Dictionary else {}
	var mul_day: float = clampf(float(day_phase_mul.get(day_phase, day_phase_mul.get("day", 1.0))), 0.15, 2.0)
	var mul_weather: float = clampf(float(weather_mul.get(weather_state, 1.0)), 0.15, 2.0)
	var visibility_mul: float = clampf(mul_day * mul_weather, 0.15, 2.0)
	_runtime_time_weather = {
		"calendar_day": day_value,
		"turn_index": turn_index,
		"days_per_turn": days_per_turn,
		"day_phase": day_phase,
		"weather_state": weather_state,
		"wind_dir": weather.get("wind_dir", [1.0, 0.0]),
		"wind_strength": float(weather.get("wind_strength", 0.0)),
		"visibility_mul": visibility_mul,
		"rules": rules
	}
	if _runtime_phase == RUNTIME_PHASE_BATTLE and day_phase != _runtime_last_battle_day_phase:
		_runtime_last_battle_day_phase = day_phase
		if not _runtime_battle_paused:
			_runtime_status_message = "进入%s。" % ("夜战阶段" if day_phase == "night" else "昼战阶段")
	var signature: String = "%d|%s|%s|%.3f" % [turn_index, day_phase, weather_state, visibility_mul]
	if force_apply or signature != _runtime_time_weather_signature:
		_runtime_time_weather_signature = signature
		_apply_runtime_time_weather_visuals()
		_push_weather_context_to_battle_runtime()

func _apply_runtime_time_weather_visuals() -> void:
	var context: Dictionary = _runtime_time_weather
	if context.is_empty():
		return
	var day_phase: String = _normalize_day_phase(String(context.get("day_phase", "day")))
	var weather_state: String = _normalize_weather_state(String(context.get("weather_state", "sunny")))
	var rules_any: Variant = context.get("rules", {})
	var rules: Dictionary = rules_any as Dictionary if rules_any is Dictionary else {}
	var env: Environment = _runtime_weather_environment
	if env == null and _world_env != null and is_instance_valid(_world_env):
		env = _world_env.environment
	var is_night: bool = day_phase == "night"
	if env != null:
		var ambient_energy_map_any: Variant = rules.get("ambient_energy_by_phase", {})
		var ambient_energy_map: Dictionary = ambient_energy_map_any as Dictionary if ambient_energy_map_any is Dictionary else {}
		var ambient_energy: float = clampf(float(ambient_energy_map.get(day_phase, ambient_energy_map.get("day", 1.2))), 0.05, 3.5)
		env.ambient_light_energy = ambient_energy
		var ambient_color: Color = Color(0.84, 0.86, 0.9) if not is_night else Color(0.62, 0.68, 0.78)
		match weather_state:
			"cloudy":
				ambient_color = ambient_color.lerp(Color(0.75, 0.78, 0.84), 0.38)
			"rain":
				ambient_color = ambient_color.lerp(Color(0.66, 0.73, 0.82), 0.55)
			"storm":
				ambient_color = ambient_color.lerp(Color(0.56, 0.64, 0.74), 0.65)
			"fog", "mist":
				ambient_color = ambient_color.lerp(Color(0.78, 0.82, 0.86), 0.58)
			_:
				pass
		env.ambient_light_color = ambient_color
		env.background_color = ambient_color.darkened(0.1 if not is_night else 0.08)
		var fog_density_map_any: Variant = rules.get("fog_density_by_weather", {})
		var fog_density_map: Dictionary = fog_density_map_any as Dictionary if fog_density_map_any is Dictionary else {}
		var fog_density: float = clampf(float(fog_density_map.get(weather_state, 0.0)), 0.0, 0.2)
		env.fog_enabled = (weather_state == "fog" or weather_state == "mist") and fog_density > 0.00001
		if env.fog_enabled:
			env.fog_density = fog_density
			env.fog_light_color = ambient_color.lightened(0.08)
			env.fog_light_energy = 0.92 if not is_night else 0.8
			env.fog_sun_scatter = 0.045 if not is_night else 0.035
			env.fog_sky_affect = 0.95
	if _sun_light != null and is_instance_valid(_sun_light):
		var sun_energy_map_any: Variant = rules.get("sun_energy_by_phase", {})
		var sun_energy_map: Dictionary = sun_energy_map_any as Dictionary if sun_energy_map_any is Dictionary else {}
		var sun_energy: float = clampf(float(sun_energy_map.get(day_phase, sun_energy_map.get("day", 1.3))), 0.02, 3.5)
		if weather_state == "cloudy":
			sun_energy *= 0.82
		elif weather_state == "rain":
			sun_energy *= 0.62
		elif weather_state == "storm":
			sun_energy *= 0.42
		elif weather_state == "fog" or weather_state == "mist":
			sun_energy *= 0.56
		_sun_light.light_energy = sun_energy
		_sun_light.light_color = Color(1.0, 0.97, 0.92) if not is_night else Color(0.7, 0.76, 0.86)
	_apply_runtime_map_weather_vfx(context)
	_apply_runtime_mountain_mist_visibility(weather_state)

func _apply_runtime_mountain_mist_visibility(weather_state: String) -> void:
	if _mountain_mist_root == null or not is_instance_valid(_mountain_mist_root):
		return
	if Engine.is_editor_hint():
		_mountain_mist_root.visible = true
		return
	_mountain_mist_root.visible = weather_state == "fog" or weather_state == "mist"
func _apply_runtime_map_weather_vfx(context: Dictionary) -> void:
	var rules_any: Variant = context.get("rules", {})
	var rules: Dictionary = rules_any as Dictionary if rules_any is Dictionary else {}
	var base_vfx_any: Variant = DEFAULT_TIME_WEATHER_RULES.get("map_weather_vfx", {})
	var base_vfx: Dictionary = base_vfx_any as Dictionary if base_vfx_any is Dictionary else {}
	var vfx_rules_any: Variant = rules.get("map_weather_vfx", {})
	var vfx_rules: Dictionary = base_vfx.duplicate(true)
	if vfx_rules_any is Dictionary:
		vfx_rules = _merge_dictionary_recursive(vfx_rules, vfx_rules_any as Dictionary)
	var vfx_enabled: bool = bool(vfx_rules.get("enabled", true))
	if not vfx_enabled:
		_runtime_weather_rain_base_amount = 0
		_runtime_weather_fog_base_amount = 0
		if _runtime_weather_rain_emitter != null and is_instance_valid(_runtime_weather_rain_emitter):
			_runtime_weather_rain_emitter.emitting = false
		if _runtime_weather_fog_emitter != null and is_instance_valid(_runtime_weather_fog_emitter):
			_runtime_weather_fog_emitter.emitting = false
		if _runtime_weather_vfx_root != null and is_instance_valid(_runtime_weather_vfx_root):
			_runtime_weather_vfx_root.visible = false
		return

	_ensure_runtime_map_weather_vfx()
	if _runtime_weather_vfx_root == null or not is_instance_valid(_runtime_weather_vfx_root):
		return
	_runtime_weather_vfx_root.visible = true
	_update_runtime_weather_vfx_anchor(0.0, true)

	var weather_state: String = _normalize_weather_state(String(context.get("weather_state", "sunny")))
	var day_phase: String = _normalize_day_phase(String(context.get("day_phase", "day")))
	var is_night: bool = day_phase == "night"
	var wind_dir: Vector2 = _weather_vec2_from_variant(context.get("wind_dir", [1.0, 0.0]), Vector2.RIGHT)
	var wind_strength: float = clampf(float(context.get("wind_strength", 0.0)), 0.0, 2.0)

	var rain_rules_any: Variant = vfx_rules.get("rain", {})
	var rain_rules: Dictionary = rain_rules_any as Dictionary if rain_rules_any is Dictionary else {}
	var fog_rules_any: Variant = vfx_rules.get("fog", {})
	var fog_rules: Dictionary = fog_rules_any as Dictionary if fog_rules_any is Dictionary else {}

	var rain_on: bool = weather_state == "rain" or weather_state == "storm"
	var fog_on: bool = weather_state == "fog" or weather_state == "mist"

	if _runtime_weather_rain_emitter != null and is_instance_valid(_runtime_weather_rain_emitter):
		var rain_min_amount: int = 12 if runtime_low_perf_mode else 32
		var rain_amount_base: int = maxi(rain_min_amount, int(round(float(rain_rules.get("amount", 1800.0)))))
		if runtime_low_perf_mode:
			rain_amount_base = maxi(rain_min_amount, int(round(float(rain_amount_base) * clampf(runtime_weather_vfx_density_scale, 0.1, 1.0))))
		var rain_amount_scale: float = 1.0
		if weather_state == "storm":
			rain_amount_scale = 1.35
		_runtime_weather_rain_base_amount = maxi(rain_min_amount, int(round(float(rain_amount_base) * rain_amount_scale)))
		_runtime_weather_rain_emitter.amount = _runtime_weather_rain_base_amount
		_runtime_weather_rain_emitter.lifetime = maxf(0.24, float(rain_rules.get("lifetime", 1.28)))
		_runtime_weather_rain_emitter.preprocess = clampf(float(_runtime_weather_rain_emitter.lifetime) * 0.36, 0.0, 2.0)
		_runtime_weather_rain_emitter.position.y = maxf(120.0, float(vfx_rules.get("rain_ground_height_offset", 760.0)))
		_runtime_weather_rain_emitter.emitting = rain_on
		var rain_extents: Vector3 = _weather_vec3_from_variant(rain_rules.get("box_extents", [1900.0, 180.0, 1900.0]), Vector3(1900.0, 180.0, 1900.0))
		var rain_quad_size: Vector2 = _weather_vec2_from_variant(rain_rules.get("quad_size", [3.4, 19.0]), Vector2(3.4, 19.0))
		if _runtime_weather_rain_process != null:
			_runtime_weather_rain_process.set("emission_box_extents", Vector3(maxf(10.0, rain_extents.x), maxf(2.0, rain_extents.y), maxf(10.0, rain_extents.z)))
			var rain_tilt: float = clampf(wind_strength * 0.42, 0.0, 0.62)
			var rain_dir := Vector3(wind_dir.normalized().x * rain_tilt, -1.0, wind_dir.normalized().y * rain_tilt).normalized()
			_runtime_weather_rain_process.set("direction", rain_dir)
			_runtime_weather_rain_process.set("spread", clampf(4.0 + wind_strength * 8.0, 0.0, 42.0))
			_runtime_weather_rain_process.set("initial_velocity_min", maxf(120.0, float(rain_rules.get("velocity_min", 610.0))))
			_runtime_weather_rain_process.set("initial_velocity_max", maxf(180.0, float(rain_rules.get("velocity_max", 820.0))))
			_runtime_weather_rain_process.set("scale_min", maxf(0.05, float(rain_rules.get("scale_min", 0.9))))
			_runtime_weather_rain_process.set("scale_max", maxf(0.05, float(rain_rules.get("scale_max", 1.45))))
		var rain_quad: QuadMesh = _runtime_weather_rain_emitter.draw_pass_1 as QuadMesh
		if rain_quad != null:
			rain_quad.size = Vector2(maxf(0.1, rain_quad_size.x), maxf(0.1, rain_quad_size.y))
		if _runtime_weather_rain_material != null:
			var rain_day_color: Color = _weather_color_from_variant(rain_rules.get("color_day", [0.72, 0.8, 0.9, 0.34]), Color(0.72, 0.8, 0.9, 0.34))
			var rain_night_color: Color = _weather_color_from_variant(rain_rules.get("color_night", [0.52, 0.6, 0.74, 0.3]), Color(0.52, 0.6, 0.74, 0.3))
			var rain_color: Color = rain_night_color if is_night else rain_day_color
			_runtime_weather_rain_material.albedo_color = rain_color
			_runtime_weather_rain_material.emission = Color(rain_color.r, rain_color.g, rain_color.b, 1.0)
			_runtime_weather_rain_material.emission_energy_multiplier = 0.22 if not is_night else 0.09

	if _runtime_weather_fog_emitter != null and is_instance_valid(_runtime_weather_fog_emitter):
		var fog_min_amount: int = 6 if runtime_low_perf_mode else 12
		var fog_amount_base: int = maxi(fog_min_amount, int(round(float(fog_rules.get("amount", 320.0)))))
		if runtime_low_perf_mode:
			fog_amount_base = maxi(fog_min_amount, int(round(float(fog_amount_base) * clampf(runtime_weather_vfx_density_scale, 0.1, 1.0))))
		var fog_amount_scale: float = 1.0
		if weather_state == "fog":
			fog_amount_scale = 1.18
		elif weather_state == "storm":
			fog_amount_scale = 1.1
		_runtime_weather_fog_base_amount = maxi(fog_min_amount, int(round(float(fog_amount_base) * fog_amount_scale)))
		_runtime_weather_fog_emitter.amount = _runtime_weather_fog_base_amount
		_runtime_weather_fog_emitter.lifetime = maxf(1.0, float(fog_rules.get("lifetime", 9.6)))
		_runtime_weather_fog_emitter.preprocess = clampf(float(_runtime_weather_fog_emitter.lifetime) * 0.36, 0.0, 4.0)
		_runtime_weather_fog_emitter.position.y = maxf(0.0, float(vfx_rules.get("fog_ground_height_offset", 95.0)))
		_runtime_weather_fog_emitter.emitting = fog_on
		var fog_extents: Vector3 = _weather_vec3_from_variant(fog_rules.get("box_extents", [2100.0, 80.0, 2100.0]), Vector3(2100.0, 80.0, 2100.0))
		var fog_quad_size: Vector2 = _weather_vec2_from_variant(fog_rules.get("quad_size", [90.0, 54.0]), Vector2(90.0, 54.0))
		if _runtime_weather_fog_process != null:
			_runtime_weather_fog_process.set("emission_box_extents", Vector3(maxf(10.0, fog_extents.x), maxf(2.0, fog_extents.y), maxf(10.0, fog_extents.z)))
			var fog_dir := Vector3(wind_dir.normalized().x, 0.04, wind_dir.normalized().y).normalized()
			_runtime_weather_fog_process.set("direction", fog_dir)
			_runtime_weather_fog_process.set("spread", 155.0)
			_runtime_weather_fog_process.set("initial_velocity_min", maxf(0.0, float(fog_rules.get("velocity_min", 8.0))) + wind_strength * 4.0)
			_runtime_weather_fog_process.set("initial_velocity_max", maxf(0.0, float(fog_rules.get("velocity_max", 18.0))) + wind_strength * 7.0)
			_runtime_weather_fog_process.set("scale_min", maxf(0.05, float(fog_rules.get("scale_min", 1.0))))
			_runtime_weather_fog_process.set("scale_max", maxf(0.05, float(fog_rules.get("scale_max", 1.65))))
		var fog_quad: QuadMesh = _runtime_weather_fog_emitter.draw_pass_1 as QuadMesh
		if fog_quad != null:
			fog_quad.size = Vector2(maxf(0.1, fog_quad_size.x), maxf(0.1, fog_quad_size.y))
		if _runtime_weather_fog_material != null:
			var fog_day_color: Color = _weather_color_from_variant(fog_rules.get("color_day", [0.84, 0.9, 0.95, 0.2]), Color(0.84, 0.9, 0.95, 0.2))
			var fog_night_color: Color = _weather_color_from_variant(fog_rules.get("color_night", [0.42, 0.5, 0.62, 0.24]), Color(0.42, 0.5, 0.62, 0.24))
			var fog_color: Color = fog_night_color if is_night else fog_day_color
			_runtime_weather_fog_material.albedo_color = fog_color
			_runtime_weather_fog_material.emission = Color(fog_color.r, fog_color.g, fog_color.b, 1.0)
			_runtime_weather_fog_material.emission_energy_multiplier = 0.16 if not is_night else 0.09

	_runtime_weather_vfx_root.visible = rain_on or fog_on
	if not rain_on:
		_runtime_weather_rain_base_amount = 0
	if not fog_on:
		_runtime_weather_fog_base_amount = 0

func _ensure_runtime_map_weather_vfx() -> void:
	if _runtime_weather_vfx_root != null and is_instance_valid(_runtime_weather_vfx_root):
		return
	_runtime_weather_vfx_root = Node3D.new()
	_runtime_weather_vfx_root.name = "RuntimeMapWeatherVfx"
	_runtime_weather_vfx_root.top_level = true
	add_child(_runtime_weather_vfx_root)

	var rain := GPUParticles3D.new()
	rain.name = "Rain"
	rain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	rain.local_coords = true
	rain.one_shot = false
	rain.amount = 860 if runtime_low_perf_mode else 1800
	rain.lifetime = 1.2
	rain.preprocess = 0.42
	rain.fixed_fps = 30
	rain.visibility_aabb = AABB(Vector3(-2400.0, -400.0, -2400.0), Vector3(4800.0, 3200.0, 4800.0))
	var rain_process := ParticleProcessMaterial.new()
	rain_process.set("emission_shape", int(ParticleProcessMaterial.EMISSION_SHAPE_BOX))
	rain_process.set("emission_box_extents", Vector3(1900.0, 180.0, 1900.0))
	rain_process.set("direction", Vector3.DOWN)
	rain_process.set("spread", 8.0)
	rain_process.set("gravity", Vector3(0.0, -340.0, 0.0))
	rain_process.set("initial_velocity_min", 610.0)
	rain_process.set("initial_velocity_max", 820.0)
	rain_process.set("scale_min", 0.9)
	rain_process.set("scale_max", 1.45)
	rain.process_material = rain_process
	var rain_quad := QuadMesh.new()
	rain_quad.size = Vector2(3.4, 19.0)
	_runtime_weather_rain_material = _build_runtime_weather_particle_material(MAP_WEATHER_RAIN_TEX, Color(0.72, 0.8, 0.9, 0.34))
	rain_quad.material = _runtime_weather_rain_material
	rain.draw_pass_1 = rain_quad
	rain.position.y = 760.0
	rain.emitting = false
	_runtime_weather_vfx_root.add_child(rain)
	_runtime_weather_rain_emitter = rain
	_runtime_weather_rain_process = rain_process

	var fog := GPUParticles3D.new()
	fog.name = "GroundFog"
	fog.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	fog.local_coords = true
	fog.one_shot = false
	fog.amount = 140 if runtime_low_perf_mode else 320
	fog.lifetime = 9.6
	fog.preprocess = 1.6
	fog.fixed_fps = 30
	fog.visibility_aabb = AABB(Vector3(-2600.0, -180.0, -2600.0), Vector3(5200.0, 780.0, 5200.0))
	var fog_process := ParticleProcessMaterial.new()
	fog_process.set("emission_shape", int(ParticleProcessMaterial.EMISSION_SHAPE_BOX))
	fog_process.set("emission_box_extents", Vector3(2100.0, 80.0, 2100.0))
	fog_process.set("direction", Vector3(1.0, 0.05, 0.0))
	fog_process.set("spread", 155.0)
	fog_process.set("gravity", Vector3.ZERO)
	fog_process.set("initial_velocity_min", 8.0)
	fog_process.set("initial_velocity_max", 18.0)
	fog_process.set("scale_min", 1.0)
	fog_process.set("scale_max", 1.65)
	fog.process_material = fog_process
	var fog_quad := QuadMesh.new()
	fog_quad.size = Vector2(90.0, 54.0)
	_runtime_weather_fog_material = _build_runtime_weather_particle_material(MAP_WEATHER_FOG_TEX, Color(0.84, 0.9, 0.95, 0.2))
	fog_quad.material = _runtime_weather_fog_material
	fog.draw_pass_1 = fog_quad
	fog.position.y = 95.0
	fog.emitting = false
	_runtime_weather_vfx_root.add_child(fog)
	_runtime_weather_fog_emitter = fog
	_runtime_weather_fog_process = fog_process

	_runtime_weather_vfx_anchor_initialized = false
	_update_runtime_weather_vfx_anchor(0.0, true)

func _update_runtime_weather_vfx_anchor(delta: float, force_snap: bool = false) -> void:
	if _runtime_weather_vfx_root == null or not is_instance_valid(_runtime_weather_vfx_root):
		return
	if _camera == null or not is_instance_valid(_camera):
		return
	var camera_pos: Vector3 = _camera.global_position
	var anchor_ground: float = terrain_height_at_world(Vector3(camera_pos.x, 0.0, camera_pos.z))
	if not _is_finite_number(anchor_ground):
		anchor_ground = 0.0
	var target: Vector3 = Vector3(camera_pos.x, anchor_ground, camera_pos.z)
	var rules_any: Variant = _runtime_time_weather.get("rules", {})
	var rules: Dictionary = rules_any as Dictionary if rules_any is Dictionary else {}
	var vfx_any: Variant = rules.get("map_weather_vfx", {})
	var vfx_rules: Dictionary = vfx_any as Dictionary if vfx_any is Dictionary else {}
	var follow_lerp: float = clampf(float(vfx_rules.get("follow_lerp", 0.24)), 0.02, 1.0)
	if force_snap or not _runtime_weather_vfx_anchor_initialized:
		_runtime_weather_vfx_anchor = target
		_runtime_weather_vfx_anchor_initialized = true
	else:
		var lerp_t: float = clampf(maxf(0.0, delta) * 60.0 * follow_lerp, 0.0, 1.0)
		_runtime_weather_vfx_anchor = _runtime_weather_vfx_anchor.lerp(target, lerp_t)
	_runtime_weather_vfx_root.global_position = _runtime_weather_vfx_anchor
	var height_above_ground: float = maxf(0.0, camera_pos.y - anchor_ground)
	var density_scale: float = _weather_vfx_density_scale_for_height(height_above_ground)
	if runtime_low_perf_mode:
		density_scale *= clampf(runtime_weather_vfx_density_scale, 0.1, 1.0)
	if _runtime_weather_rain_emitter != null and is_instance_valid(_runtime_weather_rain_emitter) and _runtime_weather_rain_base_amount > 0:
		var rain_min_amount: int = 12 if runtime_low_perf_mode else 32
		_runtime_weather_rain_emitter.amount = maxi(rain_min_amount, int(round(float(_runtime_weather_rain_base_amount) * density_scale)))
	if _runtime_weather_fog_emitter != null and is_instance_valid(_runtime_weather_fog_emitter) and _runtime_weather_fog_base_amount > 0:
		var fog_scale: float = clampf(density_scale * 0.92, 0.22, 1.0)
		var fog_min_amount: int = 6 if runtime_low_perf_mode else 12
		_runtime_weather_fog_emitter.amount = maxi(fog_min_amount, int(round(float(_runtime_weather_fog_base_amount) * fog_scale)))

func _weather_vfx_density_scale_for_height(height_above_ground: float) -> float:
	var start_fade_h: float = 2600.0
	var end_fade_h: float = 12000.0
	if height_above_ground <= start_fade_h:
		return 1.0
	var t: float = clampf((height_above_ground - start_fade_h) / maxf(1.0, end_fade_h - start_fade_h), 0.0, 1.0)
	return lerpf(1.0, 0.34, t)

func _build_runtime_weather_particle_material(tex: Texture2D, tint: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_texture = tex
	mat.albedo_color = tint
	mat.emission_enabled = true
	mat.emission = Color(tint.r, tint.g, tint.b, 1.0)
	mat.emission_energy_multiplier = 0.15
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.no_depth_test = false
	mat.disable_receive_shadows = true
	return mat

func _weather_vec2_from_variant(raw: Variant, fallback: Vector2) -> Vector2:
	if raw is Vector2:
		return raw as Vector2
	if raw is Array and (raw as Array).size() >= 2:
		var arr: Array = raw as Array
		return Vector2(float(arr[0]), float(arr[1]))
	return fallback

func _weather_vec3_from_variant(raw: Variant, fallback: Vector3) -> Vector3:
	if raw is Vector3:
		return raw as Vector3
	if raw is Array and (raw as Array).size() >= 3:
		var arr: Array = raw as Array
		return Vector3(float(arr[0]), float(arr[1]), float(arr[2]))
	return fallback

func _weather_color_from_variant(raw: Variant, fallback: Color) -> Color:
	if raw is Color:
		return raw as Color
	if raw is Array and (raw as Array).size() >= 3:
		var arr: Array = raw as Array
		var alpha: float = fallback.a
		if arr.size() >= 4:
			alpha = float(arr[3])
		return Color(float(arr[0]), float(arr[1]), float(arr[2]), alpha)
	return fallback

func _push_weather_context_to_battle_runtime() -> void:
	if _battle_runtime == null or not is_instance_valid(_battle_runtime):
		return
	if not _battle_runtime.has_method("setup_weather_context"):
		return
	var weather_state: String = String(_runtime_time_weather.get("weather_state", "sunny"))
	var wind_dir_any: Variant = _runtime_time_weather.get("wind_dir", [1.0, 0.0])
	var wind_dir: Array = [1.0, 0.0]
	if wind_dir_any is Array and (wind_dir_any as Array).size() >= 2:
		wind_dir = [float((wind_dir_any as Array)[0]), float((wind_dir_any as Array)[1])]
	var weather_ctx := {
		"state": weather_state,
		"wind_dir": wind_dir,
		"wind_strength": float(_runtime_time_weather.get("wind_strength", 0.0)),
		"day_phase": String(_runtime_time_weather.get("day_phase", "day"))
	}
	_battle_runtime.call("setup_weather_context", {"settings_path": WEATHER_SETTINGS_PATH, "weather": weather_ctx})
	if _battle_runtime.has_method("_apply_weather_context"):
		_battle_runtime.call("_apply_weather_context")

func _on_battle_weather_state_changed(weather_patch: Dictionary) -> void:
	if weather_patch.is_empty():
		return
	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	var weather_any: Variant = meta.get("weather", {})
	var weather: Dictionary = weather_any as Dictionary if weather_any is Dictionary else {}
	weather["state"] = _normalize_weather_state(String(weather_patch.get("state", weather.get("state", "sunny"))))
	if weather_patch.has("wind_dir"):
		weather["wind_dir"] = weather_patch.get("wind_dir")
	if weather_patch.has("wind_strength"):
		weather["wind_strength"] = float(weather_patch.get("wind_strength", weather.get("wind_strength", 0.0)))
	meta["weather"] = weather
	meta["weather_turn_index"] = int(_runtime_time_weather.get("turn_index", 0))
	_world_state_cache["meta"] = meta
	_sync_runtime_time_weather_state(true)
	_refresh_supply_fog_runtime(true)
	_refresh_runtime_ui_hud(true)

func _refresh_runtime_ui_hud_periodic(delta: float) -> void:
	if _runtime_ui_layer == null:
		return
	_runtime_ui_refresh_accum += maxf(0.0, delta)
	if _runtime_ui_refresh_accum < RUNTIME_UI_REFRESH_INTERVAL_SEC:
		return
	_runtime_ui_refresh_accum = 0.0
	_refresh_runtime_ui_hud(false)

func _refresh_runtime_ui_hud(_force: bool = false) -> void:
	if _runtime_ui_layer == null:
		return
	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	var player_faction_id: String = _get_player_faction_id()
	var calendar_day: float = float(meta.get("calendar_day", _runtime_time_weather.get("calendar_day", 1.0)))
	var weather_any: Variant = meta.get("weather", {})
	var weather: Dictionary = weather_any as Dictionary if weather_any is Dictionary else {}
	weather["day_phase"] = String(_runtime_time_weather.get("day_phase", weather.get("day_phase", "day")))
	weather["state"] = String(_runtime_time_weather.get("weather_state", weather.get("state", "sunny")))
	var battle_total: float = maxf(0.0, _runtime_battle_total_seconds)
	var battle_elapsed: float = clampf(_runtime_battle_elapsed_seconds, 0.0, battle_total)
	var battle_left: float = maxf(0.0, battle_total - battle_elapsed)
	var hud_state := {
		"phase": _runtime_phase,
		"calendar_day": calendar_day,
		"weather": weather,
		"command_points": float(meta.get("command_points", 12.0)),
		"max_command_points": float(meta.get("max_command_points", 12.0)),
		"military_orders": float(meta.get("military_orders", 6.0)),
		"max_military_orders": float(meta.get("max_military_orders", 6.0)),
		"command_cost_city_action": 1.0,
		"status_message": _runtime_status_message,
		"preload_progress": 1.0,
		"battle_seconds_elapsed": battle_elapsed,
		"battle_seconds_total": battle_total,
		"battle_seconds_left": battle_left,
		"battle_paused": _runtime_battle_paused,
		"battle_speed": _runtime_battle_speed
	}
	var cities_snapshot: Array = _snapshot_array_from_world_state("cities")
	var building_units_snapshot: Array = _snapshot_array_from_world_state("building_units")
	var snapshot := {
		"meta": {
			"player_faction_id": player_faction_id,
			"calendar_day": calendar_day,
			"weather": weather,
			"city_orders": _runtime_city_orders.duplicate(true)
		},
		"cities": cities_snapshot,
		"building_units": building_units_snapshot
	}
	_runtime_ui_layer.refresh(snapshot, _selected_site_id, hud_state)

func _ensure_runtime_mobile_root() -> void:
	var node: Node = get_node_or_null("RuntimeMobileUnits")
	if node is Node3D:
		_runtime_mobile_root = node as Node3D
		return
	_runtime_mobile_root = Node3D.new()
	_runtime_mobile_root.name = "RuntimeMobileUnits"
	add_child(_runtime_mobile_root)

func _clear_runtime_mobile_units() -> void:
	for id_any in _runtime_mobile_units.keys():
		var unit: Node = _runtime_mobile_units.get(id_any, null) as Node
		if unit != null and is_instance_valid(unit):
			if _battle_runtime != null and is_instance_valid(_battle_runtime) and bool(_runtime_mobile_registered.get(id_any, false)) and _battle_runtime.has_method("unregister_unit"):
				_battle_runtime.call("unregister_unit", unit)
			unit.queue_free()
	_runtime_mobile_units.clear()
	_runtime_mobile_snapshots.clear()
	_runtime_mobile_registered.clear()
	_runtime_supply_report_state.clear()

func _is_runtime_mobile_unit_type(unit_type: String) -> bool:
	var key: String = unit_type.to_lower().strip_edges()
	if key.is_empty():
		return false
	return RUNTIME_MOBILE_UNIT_TYPES.has(key)

func _sync_runtime_mobile_units() -> void:
	_ensure_runtime_mobile_root()
	if _runtime_mobile_root == null:
		return
	var keep_ids: Dictionary = {}
	for unit_any in _runtime_dynamic_units_from_world_state():
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = (unit_any as Dictionary).duplicate(true)
		var unit_id: String = String(unit.get("id", "")).strip_edges()
		var unit_type: String = String(unit.get("type", "")).to_lower().strip_edges()
		if unit_id.is_empty() or not _is_runtime_mobile_unit_type(unit_type):
			continue
		keep_ids[unit_id] = true
		var node: Node3D = null
		var node_any: Variant = _runtime_mobile_units.get(unit_id, null)
		if is_instance_valid(node_any) and node_any is Node3D:
			node = node_any as Node3D
		if node == null or not is_instance_valid(node):
			node = _spawn_runtime_mobile_unit(unit)
		if node == null or not is_instance_valid(node):
			continue
		_update_runtime_mobile_unit_runtime_state(node, unit)
		_runtime_mobile_snapshots[unit_id] = unit
	for id_any in _runtime_mobile_units.keys():
		var stale_id: String = String(id_any)
		if keep_ids.has(stale_id):
			continue
		var stale_unit: Node = null
		var stale_any: Variant = _runtime_mobile_units.get(stale_id, null)
		if is_instance_valid(stale_any) and stale_any is Node:
			stale_unit = stale_any as Node
		if stale_unit != null and is_instance_valid(stale_unit):
			if _battle_runtime != null and is_instance_valid(_battle_runtime) and bool(_runtime_mobile_registered.get(stale_id, false)) and _battle_runtime.has_method("unregister_unit"):
				_battle_runtime.call("unregister_unit", stale_unit)
			stale_unit.queue_free()
		_runtime_mobile_units.erase(stale_id)
		_runtime_mobile_snapshots.erase(stale_id)
		_runtime_mobile_registered.erase(stale_id)
		_runtime_supply_report_state.erase(stale_id)

func _spawn_runtime_mobile_unit(unit: Dictionary) -> Node3D:
	if UnitControllerScene == null:
		return null
	var inst: Node = UnitControllerScene.instantiate()
	if not (inst is Node3D):
		if inst != null and is_instance_valid(inst):
			inst.queue_free()
		return null
	var node := inst as Node3D
	var unit_id: String = String(unit.get("id", "")).strip_edges()
	var unit_type: String = String(unit.get("type", "")).to_lower().strip_edges()
	node.name = "RuntimeMobile_%s" % unit_id
	node.set_meta("building_id", unit_id)
	node.set_meta("building_type", unit_type)
	_runtime_mobile_root.add_child(node)
	_runtime_mobile_units[unit_id] = node
	_runtime_mobile_registered[unit_id] = false
	_update_runtime_mobile_unit_runtime_state(node, unit)
	return node

func _update_runtime_mobile_unit_runtime_state(node: Node3D, unit: Dictionary) -> void:
	if node == null or not is_instance_valid(node):
		return
	var unit_id: String = String(unit.get("id", ""))
	var unit_type: String = String(unit.get("type", "field_unit")).to_lower().strip_edges()
	var pos_any: Variant = unit.get("position", {})
	var world_x: float = 0.0
	var world_z: float = 0.0
	if pos_any is Dictionary:
		world_x = float((pos_any as Dictionary).get("x", 0.0))
		world_z = float((pos_any as Dictionary).get("z", 0.0))
	if not _is_finite_number(world_x) or not _is_finite_number(world_z):
		return
	var ground_y: float = terrain_height_at_world(Vector3(world_x, 0.0, world_z))
	if not _is_finite_number(ground_y):
		ground_y = 0.0
	var spawn_position := Vector3(world_x, ground_y, world_z)
	if not spawn_position.is_finite():
		spawn_position = Vector3.ZERO
	if not node.has_meta("runtime_pos_initialized") or not node.global_position.is_finite():
		node.global_position = spawn_position
		node.set_meta("runtime_pos_initialized", true)
	var node_scale: float = _runtime_mobile_unit_scale * MOBILE_UNIT_SCALE_MUL
	if not _is_finite_number(node_scale):
		node_scale = DEFAULT_RUNTIME_MOBILE_UNIT_SCALE * MOBILE_UNIT_SCALE_MUL
	node_scale = maxf(0.25, node_scale)
	node.scale = Vector3.ONE * node_scale
	var faction_id: String = String(unit.get("faction_id", "")).strip_edges()
	var team_id: int = _team_id_from_faction(faction_id)
	var troops: int = _runtime_mobile_troops(unit)
	var config_signature: String = "%d|%s|%d" % [team_id, unit_type, troops]
	var applied_signature: String = String(node.get_meta("runtime_config_signature", ""))
	if applied_signature != config_signature:
		if node.has_method("configure"):
			node.call("configure", _battle_runtime if _battle_runtime != null else self, team_id, _runtime_mobile_unit_kind(unit_type), troops, 0)
		if node.has_method("set_stance"):
			node.call("set_stance", 0)
		node.set_meta("runtime_config_signature", config_signature)
	var governor_name: String = unit_id
	var personnel_any: Variant = unit.get("personnel", {})
	if personnel_any is Dictionary:
		governor_name = String((personnel_any as Dictionary).get("governor_name", unit_id))
	var role_id: String = _runtime_mobile_combat_role(unit, unit_type)
	var commanders: Array[Dictionary] = _resolve_runtime_unit_officers(unit, governor_name)
	var aptitude_key: String = _runtime_unit_aptitude_key(unit_type, role_id)
	var personality_payload: Dictionary = _resolve_runtime_personality_payload(commanders)
	if node.has_method("set"):
		node.set("main_commander_name", _runtime_officer_name(commanders, 0, governor_name))
		node.set("vice_commander_1_name", _runtime_officer_name(commanders, 1, "-"))
		node.set("vice_commander_2_name", _runtime_officer_name(commanders, 2, "-"))
		node.set("unit_type_label_override", _runtime_mobile_label(unit_type, role_id))
		node.set("combat_role_id", role_id)
		node.set("performance_mode_low", runtime_low_perf_mode)
		node.set("visual_square_dim_cap", clampi(runtime_unit_visual_square_dim_cap, 4, 10))
		node.set("effect_particle_density_scale", clampf(runtime_unit_effect_density_scale, 0.1, 1.0))
		var commander_signature: String = "%s|%s" % [_runtime_officer_signature(commanders, aptitude_key), String(personality_payload.get("signature", "none"))]
		var prev_commander_signature: String = String(node.get_meta("runtime_commander_signature", ""))
		if commander_signature != prev_commander_signature:
			node.set("main_leadership", _runtime_officer_stat(commanders, 0, "lead", 70))
			node.set("main_might", _runtime_officer_stat(commanders, 0, "might", 70))
			node.set("main_intelligence", _runtime_officer_stat(commanders, 0, "intellect", 70))
			node.set("main_politics", _runtime_officer_stat(commanders, 0, "politics", 70))
			node.set("main_charm", _runtime_officer_stat(commanders, 0, "charm", 70))
			node.set("vice_1_leadership", _runtime_officer_stat(commanders, 1, "lead", 65))
			node.set("vice_1_might", _runtime_officer_stat(commanders, 1, "might", 65))
			node.set("vice_1_intelligence", _runtime_officer_stat(commanders, 1, "intellect", 65))
			node.set("vice_1_politics", _runtime_officer_stat(commanders, 1, "politics", 65))
			node.set("vice_1_charm", _runtime_officer_stat(commanders, 1, "charm", 65))
			node.set("vice_2_leadership", _runtime_officer_stat(commanders, 2, "lead", 65))
			node.set("vice_2_might", _runtime_officer_stat(commanders, 2, "might", 65))
			node.set("vice_2_intelligence", _runtime_officer_stat(commanders, 2, "intellect", 65))
			node.set("vice_2_politics", _runtime_officer_stat(commanders, 2, "politics", 65))
			node.set("vice_2_charm", _runtime_officer_stat(commanders, 2, "charm", 65))
			node.set("main_unit_aptitude", _runtime_officer_aptitude_grade(commanders, 0, aptitude_key, 2))
			node.set("vice_1_unit_aptitude", _runtime_officer_aptitude_grade(commanders, 1, aptitude_key, 1))
			node.set("vice_2_unit_aptitude", _runtime_officer_aptitude_grade(commanders, 2, aptitude_key, 1))
			node.set("main_battle_personality", String(personality_payload.get("main_text", "")))
			node.set("vice_1_battle_personality", String(personality_payload.get("vice_1_text", "")))
			node.set("vice_2_battle_personality", String(personality_payload.get("vice_2_text", "")))
			node.set("main_battle_personality_trait_id", String(personality_payload.get("main_trait_id", "")))
			node.set("vice_1_battle_personality_trait_id", String(personality_payload.get("vice_1_trait_id", "")))
			node.set("vice_2_battle_personality_trait_id", String(personality_payload.get("vice_2_trait_id", "")))
			node.set("main_battle_personality_level", int(personality_payload.get("main_trait_level", 0)))
			node.set("vice_1_battle_personality_level", int(personality_payload.get("vice_1_trait_level", 0)))
			node.set("vice_2_battle_personality_level", int(personality_payload.get("vice_2_trait_level", 0)))
			node.set("personality_attack_bonus_pct", float(personality_payload.get("attack_bonus_pct", 0.0)))
			node.set("personality_defense_bonus_pct", float(personality_payload.get("defense_bonus_pct", 0.0)))
			node.set("personality_speed_bonus_pct", float(personality_payload.get("speed_bonus_pct", 0.0)))
			node.set("personality_spirit_bonus_flat", float(personality_payload.get("spirit_bonus_flat", 0.0)))
			if node.has_method("_rebuild_unit_profile"):
				node.call("_rebuild_unit_profile")
			if node.has_method("_refresh_auto_statuses"):
				node.call("_refresh_auto_statuses")
			node.set_meta("runtime_commander_signature", commander_signature)
		var target_world_spacing: float = _runtime_target_formation_world_spacing()
		var local_spacing: float = clampf(target_world_spacing / maxf(0.1, node_scale), 0.18, 1.2)
		node.set("formation_spacing", local_spacing)
		node.set("queue_spacing", maxf(0.32, local_spacing * 1.35))
		node.set("infantry_melee_row_spacing", maxf(0.55, local_spacing * 1.3))
		node.set("infantry_melee_lateral_spacing", maxf(0.8, local_spacing * 1.95))
		node.set("cavalry_melee_row_spacing", maxf(0.72, local_spacing * 1.55))
		node.set("cavalry_melee_lateral_spacing", maxf(1.1, local_spacing * 2.25))
		node.set("melee_frontline_width_mul", 1.1)
		node.set("melee_frontline_depth_mul", 1.0)
		var prev_spacing: float = float(node.get_meta("runtime_local_formation_spacing", -1.0))
		if absf(prev_spacing - local_spacing) > 0.004:
			if node.has_method("_initialize_soldier_offsets"):
				node.call("_initialize_soldier_offsets")
			if node.has_method("_refresh_melee_offsets"):
				node.call("_refresh_melee_offsets")
			if node.has_method("_apply_offsets_immediate"):
				var home_any: Variant = node.get("home_offsets")
				if home_any is Array:
					node.call("_apply_offsets_immediate", home_any, false)
			if node.has_method("_restore_post_move_formation"):
				node.call("_restore_post_move_formation")
			node.set_meta("runtime_local_formation_spacing", local_spacing)
		var convoy_path: String = _runtime_model_path_for_unit(unit, unit_type)
		if _is_convoy_node(unit) and not convoy_path.is_empty():
			node.set("override_model_source_path", convoy_path)
			node.set("move_speed", RUNTIME_CONVOY_MOVE_SPEED)
			node.set("attack_range", 1.8)
			node.set("vision_radius", 24.0)
		elif unit_type == "field_unit":
			node.set("override_model_source_path", "")
			node.set("move_speed", RUNTIME_FIELD_UNIT_MOVE_SPEED)
			node.set("attack_range", 2.6)
			node.set("vision_radius", 42.0)
	node.set_meta("building_id", unit_id)
	node.set_meta("building_type", unit_type)
	var should_register: bool = _battle_runtime != null and is_instance_valid(_battle_runtime) and _battle_runtime.has_method("register_unit")
	if should_register and not bool(_runtime_mobile_registered.get(unit_id, false)):
		_battle_runtime.call("register_unit", node)
		_runtime_mobile_registered[unit_id] = true

func _runtime_mobile_troops(unit: Dictionary) -> int:
	var stats_any: Variant = unit.get("stats", {})
	if stats_any is Dictionary:
		var stats: Dictionary = stats_any as Dictionary
		if stats.has("troops"):
			return maxi(200, int(round(float(stats.get("troops", 0.0)))))
		var combined: float = float(stats.get("reserve_troops", 0.0)) + float(stats.get("organized_troops", 0.0))
		if combined > 0.0:
			return maxi(200, int(round(combined)))
	return 2000

func _runtime_target_formation_world_spacing() -> float:
	var ref_spacing: float = 1.05
	var ref_scale: float = 2.2
	if _battle_runtime != null and is_instance_valid(_battle_runtime):
		var spacing_any: Variant = _battle_runtime.get("soldier_formation_spacing")
		if spacing_any != null:
			ref_spacing = maxf(0.2, float(spacing_any))
		var scale_any: Variant = _battle_runtime.get("unit_node_scale")
		if scale_any != null:
			ref_scale = maxf(0.2, float(scale_any))
	return maxf(0.4, ref_spacing * ref_scale * RUNTIME_FORMATION_WORLD_SPACING_MUL)

func _runtime_mobile_unit_kind(unit_type: String) -> int:
	return 1 if _is_runtime_mobile_unit_type(unit_type) and (unit_type == "convoy" or unit_type == "supply_convoy" or unit_type == "transport") else 0

func _runtime_mobile_combat_role(unit: Dictionary, unit_type: String) -> String:
	if _is_convoy_node(unit):
		return "transport"
	var role_id: String = String(unit.get("combat_role_id", unit.get("role_id", unit.get("unit_role", "")))).strip_edges().to_lower()
	if role_id.is_empty():
		role_id = String(unit.get("unit_type", "")).strip_edges().to_lower()
	match role_id:
		"strategist_s", "strategist_a", "strategist_b", "strategist_c", "advisor", "tactician":
			return "strategist"
		"horse", "mounted":
			return "cavalry"
		"bow":
			return "archer"
		"xbow":
			return "crossbow"
		"shield", "spear", "cavalry", "archer", "crossbow", "strategist", "siege", "naval", "infantry":
			return role_id
		_:
			return "infantry" if unit_type == "field_unit" else "transport"

func _runtime_mobile_label(unit_type: String, role_id: String = "") -> String:
	match unit_type:
		"supply_convoy", "convoy", "transport":
			return "鏈ㄧ墰娴侀┈"
		"field_unit":
			return _runtime_mobile_role_label(role_id)
		_:
			return unit_type

func _runtime_mobile_role_label(role_id: String) -> String:
	match role_id.strip_edges().to_lower():
		"shield":
			return "Shield"
		"spear":
			return "Spear"
		"cavalry":
			return "Cavalry"
		"archer":
			return "Bow"
		"crossbow":
			return "Crossbow"
		"strategist":
			return "Strategist"
		"siege":
			return "攻城兵"
		"naval":
			return "姘村啗"
		_:
			return "野战部队"

func _team_id_from_faction(faction_id: String) -> int:
	var player_id: String = _get_player_faction_id()
	if faction_id.strip_edges().is_empty():
		return 1
	return 0 if faction_id == player_id else 1

func _runtime_mobile_unit_snapshot(site_id: String) -> Dictionary:
	if not _runtime_mobile_snapshots.has(site_id):
		return {}
	var snap_any: Variant = _runtime_mobile_snapshots.get(site_id, {})
	if not (snap_any is Dictionary):
		return {}
	var out: Dictionary = (snap_any as Dictionary).duplicate(true)
	var node: Node3D = _runtime_mobile_units.get(site_id, null) as Node3D
	if node != null and is_instance_valid(node):
		out["position"] = {
			"x": float(node.global_position.x),
			"z": float(node.global_position.z)
		}
	return out

func _apply_runtime_mobile_visibility() -> void:
	var vis_any: Variant = _supply_fog_snapshot.get("site_visible", {})
	var site_visible: Dictionary = vis_any as Dictionary if vis_any is Dictionary else {}
	var player_faction: String = _get_player_faction_id()
	for id_any in _runtime_mobile_units.keys():
		var unit_id: String = String(id_any)
		var node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var snap: Dictionary = _runtime_mobile_unit_snapshot(unit_id)
		var faction_id: String = String(snap.get("faction_id", "")).strip_edges()
		var default_visible: bool = true
		if _runtime_supply_fog_enabled and not faction_id.is_empty() and faction_id != player_faction:
			default_visible = false
		var visible_now: bool = bool(site_visible.get(unit_id, default_visible))
		node.visible = visible_now
		if _battle_runtime == null or not is_instance_valid(_battle_runtime):
			continue
		if not _battle_runtime.has_method("register_unit") or not _battle_runtime.has_method("unregister_unit"):
			continue
		var registered_now: bool = bool(_runtime_mobile_registered.get(unit_id, false))
		if visible_now and not registered_now:
			_battle_runtime.call("register_unit", node)
			_runtime_mobile_registered[unit_id] = true
		elif not visible_now and registered_now:
			_battle_runtime.call("unregister_unit", node)
			_runtime_mobile_registered[unit_id] = false

func _pointer_hits_runtime_mobile_unit(screen_pos: Vector2, radius_px: float = 72.0) -> bool:
	if _camera == null:
		return false
	var radius_sq: float = radius_px * radius_px
	for unit_any in _runtime_mobile_units.values():
		var node: Node3D = unit_any as Node3D
		if node == null or not is_instance_valid(node) or not node.visible:
			continue
		var world_anchor: Vector3 = node.global_position + Vector3(0.0, 4.0, 0.0)
		if _camera.is_position_behind(world_anchor):
			continue
		var screen_anchor: Vector2 = _camera.unproject_position(world_anchor)
		if screen_anchor.distance_squared_to(screen_pos) <= radius_sq:
			return true
	return false

func _reload_world_state_cache() -> void:
	_world_state_cache.clear()
	_world_city_by_id.clear()
	_world_city_by_name.clear()
	_world_building_by_id.clear()
	_world_building_by_name.clear()
	_world_faction_name_by_id.clear()
	_reload_master_officer_catalog()
	_facility_effect_tick_accum = 0.0
	_facility_tower_cooldowns.clear()
	_runtime_siege_status_by_target_id.clear()
	_runtime_siege_recent_capture_until.clear()
	_runtime_siege_info_refresh_accum = 0.0
	_clear_runtime_siege_info_overlay()
	var root: Dictionary = _json_source.load_dictionary(WORLD_STATE_PATH)
	if root.is_empty():
		_engine_rules_cache = _json_source.load_dictionary(ENGINE_RULES_PATH)
		_regroup_rules_cache = _json_source.load_dictionary(REGROUP_RULES_PATH)
		_special_troop_rules_cache = _json_source.load_dictionary(SPECIAL_TROOP_RULES_PATH)
		_regroup_base_dataset_cache.clear()
		_apply_runtime_rules()
		_supply_fog_snapshot = {
			"enabled": false,
			"site_visible": {},
			"reveal_centers": [],
			"in_supply_site_ids": [],
			"in_supply_by_faction": {},
			"supply_regions_by_faction": {},
			"supply_edges": [],
			"vision_context": {
				"day_phase": "day",
				"weather_state": "sunny",
				"visibility_mul": 1.0
			}
		}
		_clear_runtime_unit_markers()
		_clear_runtime_mobile_units()
		if _supply_route_mesh_linked != null and is_instance_valid(_supply_route_mesh_linked):
			_supply_route_mesh_linked.mesh = null
		if _supply_route_mesh_unlinked != null and is_instance_valid(_supply_route_mesh_unlinked):
			_supply_route_mesh_unlinked.mesh = null
		if _supply_route_mesh_preview != null and is_instance_valid(_supply_route_mesh_preview):
			_supply_route_mesh_preview.mesh = null
		_set_supply_route_overlay_visible(false)
		_refresh_supply_debug_overlay()
		return
	_world_state_cache = root
	_regroup_base_dataset_cache.clear()
	var factions_any: Variant = root.get("factions", [])
	if factions_any is Array:
		for faction_any in (factions_any as Array):
			if not (faction_any is Dictionary):
				continue
			var faction: Dictionary = (faction_any as Dictionary).duplicate(true)
			var faction_id: String = String(faction.get("id", "")).strip_edges()
			var faction_name: String = String(faction.get("name", faction_id)).strip_edges()
			if faction_id.is_empty():
				continue
			_put_dict_alias(_world_faction_name_by_id, faction_id, faction_name)
	var cities_any: Variant = root.get("cities", [])
	if cities_any is Array:
		for city_any in (cities_any as Array):
			if not (city_any is Dictionary):
				continue
			var city: Dictionary = (city_any as Dictionary).duplicate(true)
			var city_id: String = String(city.get("id", "")).strip_edges()
			var city_name: String = String(city.get("name", city_id)).strip_edges()
			if not city_id.is_empty():
				_put_dict_alias(_world_city_by_id, city_id, city)
			if not city_name.is_empty():
				_put_dict_alias(_world_city_by_name, city_name, city)
	var units_any: Variant = root.get("building_units", [])
	if units_any is Array:
		for unit_any in (units_any as Array):
			if not (unit_any is Dictionary):
				continue
			var unit: Dictionary = (unit_any as Dictionary).duplicate(true)
			var unit_id: String = String(unit.get("id", "")).strip_edges()
			var unit_name: String = String(unit.get("name", unit_id)).strip_edges()
			if not unit_id.is_empty():
				_put_dict_alias(_world_building_by_id, unit_id, unit)
			if not unit_name.is_empty():
				_put_dict_alias(_world_building_by_name, unit_name, unit)
	_engine_rules_cache = _json_source.load_dictionary(ENGINE_RULES_PATH)
	_regroup_rules_cache = _json_source.load_dictionary(REGROUP_RULES_PATH)
	_special_troop_rules_cache = _json_source.load_dictionary(SPECIAL_TROOP_RULES_PATH)
	_apply_runtime_rules()

func _reload_master_officer_catalog() -> void:
	_master_officers.clear()
	_master_officers_by_id.clear()
	_master_officers_by_name.clear()
	var raw: Dictionary = _json_source.load_dictionary(OFFICER_ROSTER_PATH)
	var officers_any: Variant = raw.get("officers", [])
	if not (officers_any is Array):
		return
	var seen: Dictionary = {}
	for officer_any in (officers_any as Array):
		if not (officer_any is Dictionary):
			continue
		var officer: Dictionary = (officer_any as Dictionary).duplicate(true)
		var officer_id: String = String(officer.get("id", "")).strip_edges()
		if officer_id.is_empty() or seen.has(officer_id):
			continue
		seen[officer_id] = true
		_master_officers.append(officer)
		_master_officers_by_id[officer_id] = officer
		var officer_name: String = String(officer.get("name", "")).strip_edges()
		if officer_name.is_empty():
			continue
		if _get_dict_alias(_master_officers_by_name, officer_name) == null:
			_put_dict_alias(_master_officers_by_name, officer_name, officer)

func _find_master_officer_by_id(officer_id: String) -> Dictionary:
	var clean: String = officer_id.strip_edges()
	if clean.is_empty():
		return {}
	var mapped_any: Variant = _master_officers_by_id.get(clean, null)
	if mapped_any is Dictionary:
		return (mapped_any as Dictionary).duplicate(true)
	for officer_any in _master_officers:
		if not (officer_any is Dictionary):
			continue
		var officer: Dictionary = officer_any as Dictionary
		if String(officer.get("id", "")).strip_edges() != clean:
			continue
		_master_officers_by_id[clean] = officer
		return officer.duplicate(true)
	return {}

func _find_master_officer_by_name(officer_name: String) -> Dictionary:
	var clean: String = officer_name.strip_edges()
	if clean.is_empty():
		return {}
	var mapped_any: Variant = _get_dict_alias(_master_officers_by_name, clean)
	if mapped_any is Dictionary:
		return (mapped_any as Dictionary).duplicate(true)
	for officer_any in _master_officers:
		if not (officer_any is Dictionary):
			continue
		var officer: Dictionary = officer_any as Dictionary
		if String(officer.get("name", "")).strip_edges() != clean:
			continue
		_put_dict_alias(_master_officers_by_name, clean, officer)
		return officer.duplicate(true)
	return {}

func _runtime_special_troop_rules() -> Array:
	var troops_any: Variant = _special_troop_rules_cache.get("special_troops", [])
	return (troops_any as Array).duplicate(true) if troops_any is Array else []

func _runtime_special_troop_unlock_key(officer_id: String, troop_id: String) -> String:
	var clean_officer_id: String = officer_id.strip_edges().to_lower()
	var clean_troop_id: String = troop_id.strip_edges().to_lower()
	if clean_officer_id.is_empty() or clean_troop_id.is_empty():
		return ""
	return "%s:%s" % [clean_officer_id, clean_troop_id]

func _runtime_special_troop_unlocks() -> Dictionary:
	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	var unlocks_any: Variant = meta.get("special_troop_unlocks", {})
	return (unlocks_any as Dictionary).duplicate(true) if unlocks_any is Dictionary else {}

func _runtime_is_special_troop_unlocked(officer_id: String, troop_id: String) -> bool:
	var unlock_key: String = _runtime_special_troop_unlock_key(officer_id, troop_id)
	if unlock_key.is_empty():
		return false
	var unlocks: Dictionary = _runtime_special_troop_unlocks()
	if unlocks.is_empty():
		return false
	if unlocks.has(unlock_key):
		return bool(unlocks.get(unlock_key, false))
	var clean_troop_id: String = troop_id.strip_edges().to_lower()
	if clean_troop_id.is_empty():
		return false
	return bool(unlocks.get(clean_troop_id, false))

func _runtime_special_troop_unlock_cost(rule: Dictionary) -> Dictionary:
	var cost_any: Variant = rule.get("unlock_cost", {})
	return (cost_any as Dictionary).duplicate(true) if cost_any is Dictionary else {}

func _runtime_resolve_officer_special_troop_rule(officer: Dictionary) -> Dictionary:
	if officer.is_empty():
		return {}
	var officer_id: String = String(officer.get("id", "")).strip_edges().to_lower()
	if officer_id.is_empty():
		return {}
	for rule_any in _runtime_special_troop_rules():
		if not (rule_any is Dictionary):
			continue
		var rule: Dictionary = rule_any as Dictionary
		var allowed_any: Variant = rule.get("allowed_officer_ids", [])
		if not (allowed_any is Array):
			continue
		for allowed_id_any in (allowed_any as Array):
			if String(allowed_id_any).strip_edges().to_lower() != officer_id:
				continue
			return rule.duplicate(true)
	return {}

func _runtime_annotate_officer_special_troop(officer: Dictionary) -> Dictionary:
	if officer.is_empty():
		return {}
	var annotated: Dictionary = officer.duplicate(true)
	var rule: Dictionary = _runtime_resolve_officer_special_troop_rule(annotated)
	if rule.is_empty():
		return annotated
	var troop_id: String = String(rule.get("id", "")).strip_edges()
	if troop_id.is_empty():
		return annotated
	var base_class_id: String = String(rule.get("base_class_id", "")).strip_edges().to_lower()
	var stat_modifiers_any: Variant = rule.get("stat_modifiers", {})
	annotated["special_troop_id"] = troop_id
	annotated["special_troop_name"] = String(rule.get("name", troop_id)).strip_edges()
	annotated["special_troop_base_class"] = base_class_id
	annotated["special_troop_base_class_label"] = _runtime_default_regroup_category_label(base_class_id)
	annotated["special_troop_trait_desc"] = String(rule.get("trait_desc", "")).strip_edges()
	annotated["special_troop_unlock_cost"] = _runtime_special_troop_unlock_cost(rule)
	annotated["special_troop_unlocked"] = _runtime_is_special_troop_unlocked(String(annotated.get("id", "")), troop_id)
	annotated["special_troop_upkeep_mul"] = float(rule.get("upkeep_mul", 1.0))
	annotated["special_troop_stat_modifiers"] = (stat_modifiers_any as Dictionary).duplicate(true) if stat_modifiers_any is Dictionary else {}
	return annotated

func _load_dictionary_allow_bom(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var raw_text: String = FileAccess.get_file_as_string(path)
	if raw_text.begins_with("\ufeff"):
		raw_text = raw_text.substr(1)
	var parser := JSON.new()
	var code: int = parser.parse(raw_text)
	if code != OK:
		push_error("JSON parse failed after BOM fallback: %s (line %d)" % [path, parser.get_error_line()])
		return {}
	if not (parser.data is Dictionary):
		return {}
	return (parser.data as Dictionary).duplicate(true)

func _ensure_battle_personality_catalog_loaded() -> void:
	if _battle_personality_catalog_loaded:
		return
	_battle_personality_trait_by_id.clear()
	_append_battle_personality_catalog(_load_dictionary_allow_bom(BATTLE_PERSONALITY_BLUE_PATH))
	_append_battle_personality_catalog(_load_dictionary_allow_bom(BATTLE_PERSONALITY_GOLD_PATH))
	_battle_personality_catalog_loaded = true

func _append_battle_personality_catalog(raw: Dictionary) -> void:
	var traits_any: Variant = raw.get("traits", [])
	if not (traits_any is Array):
		return
	for trait_any in (traits_any as Array):
		if not (trait_any is Dictionary):
			continue
		var trait_data: Dictionary = (trait_any as Dictionary).duplicate(true)
		var trait_id: String = String(trait_data.get("id", "")).strip_edges().to_lower()
		if trait_id.is_empty():
			continue
		_battle_personality_trait_by_id[trait_id] = trait_data

func _resolve_runtime_unit_officers(unit: Dictionary, governor_name: String) -> Array[Dictionary]:
	if _master_officers.is_empty():
		_reload_master_officer_catalog()
	var personnel_any: Variant = unit.get("personnel", {})
	var officer_count: int = 3
	if personnel_any is Dictionary:
		officer_count = clampi(int((personnel_any as Dictionary).get("officer_count", 3)), 1, 3)
	var main_officer: Dictionary = _find_master_officer_by_name(governor_name)
	if main_officer.is_empty():
		main_officer = {"name": governor_name}
	var commanders: Array[Dictionary] = [main_officer]
	var seen_names: Dictionary = {}
	var main_name: String = String(main_officer.get("name", governor_name)).strip_edges()
	if not main_name.is_empty():
		seen_names[main_name.to_lower()] = true
	var city_id: String = String(unit.get("city_id", "")).strip_edges()
	var city: Dictionary = _resolve_world_city(city_id, "")
	var roster_any: Variant = city.get("officer_roster", city.get("officers", []))
	var candidates: Array[Dictionary] = []
	if roster_any is Array:
		for officer_any in (roster_any as Array):
			if not (officer_any is Dictionary):
				continue
			var merged: Dictionary = _resolve_runtime_world_officer_entry(officer_any as Dictionary)
			var name_text: String = String(merged.get("name", "")).strip_edges()
			if name_text.is_empty():
				continue
			var key: String = name_text.to_lower()
			if seen_names.has(key):
				continue
			seen_names[key] = true
			candidates.append(merged)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var score_a: float = _runtime_officer_pick_score(a)
		var score_b: float = _runtime_officer_pick_score(b)
		if absf(score_a - score_b) > 0.001:
			return score_a > score_b
		return String(a.get("name", "")) < String(b.get("name", ""))
	)
	var pick_index: int = 0
	while commanders.size() < officer_count and pick_index < candidates.size():
		commanders.append(candidates[pick_index])
		pick_index += 1
	while commanders.size() < 3:
		commanders.append({})
	return commanders

func _resolve_runtime_world_officer_entry(officer_raw: Dictionary) -> Dictionary:
	var source: Dictionary = officer_raw.duplicate(true)
	var officer_id: String = String(source.get("id", "")).strip_edges()
	var officer_name: String = String(source.get("name", "")).strip_edges()
	var merged: Dictionary = {}
	if not officer_id.is_empty():
		merged = _find_master_officer_by_id(officer_id)
	if merged.is_empty() and not officer_name.is_empty():
		merged = _find_master_officer_by_name(officer_name)
	if merged.is_empty():
		return source
	if not merged.has("stats") and source.get("stats", null) is Dictionary:
		merged["stats"] = (source.get("stats", {}) as Dictionary).duplicate(true)
	if not merged.has("battle_personality") and source.get("battle_personality", null) is Dictionary:
		merged["battle_personality"] = (source.get("battle_personality", {}) as Dictionary).duplicate(true)
	if String(merged.get("name", "")).strip_edges().is_empty() and not officer_name.is_empty():
		merged["name"] = officer_name
	return merged

func _runtime_officer_pick_score(officer: Dictionary) -> float:
	var stats_any: Variant = officer.get("stats", {})
	if not (stats_any is Dictionary):
		return 0.0
	var stats: Dictionary = stats_any as Dictionary
	var lead: float = float(stats.get("lead", stats.get("leadership", 0.0)))
	var might: float = float(stats.get("might", stats.get("force", 0.0)))
	var intellect: float = float(stats.get("intellect", stats.get("intelligence", 0.0)))
	var politics: float = float(stats.get("politics", 0.0))
	var charm: float = float(stats.get("charm", 0.0))
	return lead * 0.35 + might * 0.3 + intellect * 0.2 + politics * 0.05 + charm * 0.1

func _runtime_officer_at(officers: Array[Dictionary], index: int) -> Dictionary:
	if index < 0 or index >= officers.size():
		return {}
	return officers[index]

func _runtime_officer_name(officers: Array[Dictionary], index: int, fallback: String) -> String:
	var officer: Dictionary = _runtime_officer_at(officers, index)
	var name_text: String = String(officer.get("name", "")).strip_edges()
	return fallback if name_text.is_empty() else name_text

func _runtime_officer_stat(officers: Array[Dictionary], index: int, stat_key: String, fallback: int) -> int:
	var officer: Dictionary = _runtime_officer_at(officers, index)
	var stats_any: Variant = officer.get("stats", {})
	if not (stats_any is Dictionary):
		return fallback
	var stats: Dictionary = stats_any as Dictionary
	var value: int = fallback
	match stat_key:
		"lead":
			value = int(round(float(stats.get("lead", stats.get("leadership", fallback)))))
		"might":
			value = int(round(float(stats.get("might", stats.get("force", fallback)))))
		"intellect":
			value = int(round(float(stats.get("intellect", stats.get("intelligence", fallback)))))
		"politics":
			value = int(round(float(stats.get("politics", fallback))))
		"charm":
			value = int(round(float(stats.get("charm", fallback))))
		_:
			value = int(round(float(stats.get(stat_key, fallback))))
	return clampi(value, 1, 100)

func _runtime_unit_aptitude_key(unit_type: String, role_id: String) -> String:
	var role_key: String = role_id.strip_edges().to_lower()
	match role_key:
		"shield", "spear", "cavalry", "archer", "crossbow", "strategist", "siege", "naval":
			return role_key
		"infantry":
			return "shield"
		_:
			if unit_type == "convoy" or unit_type == "supply_convoy" or unit_type == "transport":
				return "siege"
			return "shield"

func _runtime_officer_aptitude_grade(officers: Array[Dictionary], index: int, aptitude_key: String, fallback: int) -> int:
	var officer: Dictionary = _runtime_officer_at(officers, index)
	var apt_any: Variant = officer.get("aptitude", {})
	if not (apt_any is Dictionary):
		return fallback
	var aptitude: Dictionary = apt_any as Dictionary
	var text: String = String(aptitude.get(aptitude_key, "")).strip_edges().to_upper()
	if text.is_empty() and aptitude_key == "shield":
		text = String(aptitude.get("spear", "")).strip_edges().to_upper()
	if text.is_empty() and aptitude_key == "spear":
		text = String(aptitude.get("shield", "")).strip_edges().to_upper()
	if text.is_empty():
		for key_any in aptitude.keys():
			var value_text: String = String(aptitude.get(key_any, "")).strip_edges().to_upper()
			if value_text.is_empty():
				continue
			var grade_any: int = _runtime_aptitude_grade_from_text(value_text, -1)
			if grade_any >= 0:
				fallback = maxi(fallback, grade_any)
		return fallback
	return _runtime_aptitude_grade_from_text(text, fallback)

func _runtime_aptitude_grade_from_text(aptitude_text: String, fallback: int) -> int:
	match aptitude_text:
		"S":
			return 3
		"A":
			return 2
		"B":
			return 1
		"C":
			return 0
		_:
			return fallback

func _runtime_officer_signature(officers: Array[Dictionary], aptitude_key: String) -> String:
	var parts: Array[String] = []
	for idx in range(3):
		var officer: Dictionary = _runtime_officer_at(officers, idx)
		if officer.is_empty():
			parts.append("-")
			continue
		var name_text: String = String(officer.get("name", "")).strip_edges()
		var id_text: String = String(officer.get("id", "")).strip_edges()
		var lead: int = _runtime_officer_stat(officers, idx, "lead", 0)
		var might: int = _runtime_officer_stat(officers, idx, "might", 0)
		var intellect: int = _runtime_officer_stat(officers, idx, "intellect", 0)
		var politics: int = _runtime_officer_stat(officers, idx, "politics", 0)
		var charm: int = _runtime_officer_stat(officers, idx, "charm", 0)
		var aptitude_grade: int = _runtime_officer_aptitude_grade(officers, idx, aptitude_key, 1)
		parts.append("%s:%s:%d:%d:%d:%d:%d:%d" % [name_text, id_text, lead, might, intellect, politics, charm, aptitude_grade])
	return "|".join(PackedStringArray(parts))

func _resolve_runtime_personality_payload(officers: Array[Dictionary]) -> Dictionary:
	var payload := {
		"main_text": "",
		"vice_1_text": "",
		"vice_2_text": "",
		"main_trait_id": "",
		"vice_1_trait_id": "",
		"vice_2_trait_id": "",
		"main_trait_level": 0,
		"vice_1_trait_level": 0,
		"vice_2_trait_level": 0,
		"attack_bonus_pct": 0.0,
		"defense_bonus_pct": 0.0,
		"speed_bonus_pct": 0.0,
		"spirit_bonus_flat": 0.0,
		"signature": "none"
	}
	var signature_parts: Array[String] = []
	for idx in range(3):
		var officer: Dictionary = _runtime_officer_at(officers, idx)
		if officer.is_empty():
			signature_parts.append("-")
			continue
		var resolved: Dictionary = _resolve_officer_battle_personality(officer)
		if resolved.is_empty():
			signature_parts.append("none:%s" % _runtime_officer_name(officers, idx, ""))
			continue
		var display_text: String = String(resolved.get("display_text", "")).strip_edges()
		var trait_id: String = String(resolved.get("trait_id", "")).strip_edges().to_lower()
		var trait_level: int = int(resolved.get("level", 0))
		if idx == 0:
			payload["main_text"] = display_text
			payload["main_trait_id"] = trait_id
			payload["main_trait_level"] = trait_level
		elif idx == 1:
			payload["vice_1_text"] = display_text
			payload["vice_1_trait_id"] = trait_id
			payload["vice_1_trait_level"] = trait_level
		else:
			payload["vice_2_text"] = display_text
			payload["vice_2_trait_id"] = trait_id
			payload["vice_2_trait_level"] = trait_level
		var weight: float = float(RUNTIME_COMMANDER_SLOT_WEIGHTS[idx]) if idx < RUNTIME_COMMANDER_SLOT_WEIGHTS.size() else 0.0
		payload["attack_bonus_pct"] = float(payload.get("attack_bonus_pct", 0.0)) + float(resolved.get("attack_bonus_pct", 0.0)) * weight
		payload["defense_bonus_pct"] = float(payload.get("defense_bonus_pct", 0.0)) + float(resolved.get("defense_bonus_pct", 0.0)) * weight
		payload["speed_bonus_pct"] = float(payload.get("speed_bonus_pct", 0.0)) + float(resolved.get("speed_bonus_pct", 0.0)) * weight
		payload["spirit_bonus_flat"] = float(payload.get("spirit_bonus_flat", 0.0)) + float(resolved.get("spirit_bonus_flat", 0.0)) * weight
		signature_parts.append("%s:%d" % [String(resolved.get("trait_id", "")), int(resolved.get("level", 0))])
	_clamp_runtime_personality_bonus(payload)
	payload["signature"] = "none" if signature_parts.is_empty() else "|".join(PackedStringArray(signature_parts))
	return payload

func _resolve_officer_battle_personality(officer: Dictionary) -> Dictionary:
	_ensure_battle_personality_catalog_loaded()
	var battle_any: Variant = officer.get("battle_personality", {})
	var trait_id: String = ""
	var rarity: String = ""
	var source_name: String = ""
	if battle_any is Dictionary:
		var battle: Dictionary = battle_any as Dictionary
		trait_id = String(battle.get("id", "")).strip_edges().to_lower()
		rarity = String(battle.get("rarity", "")).strip_edges().to_lower()
		source_name = String(battle.get("name", "")).strip_edges()
	else:
		trait_id = String(battle_any).strip_edges().to_lower()
	if trait_id.is_empty():
		return {}
	var trait_any: Variant = _battle_personality_trait_by_id.get(trait_id, null)
	var trait_data: Dictionary = trait_any as Dictionary if trait_any is Dictionary else {}
	var levels: Dictionary = trait_data.get("levels", {}) if trait_data.get("levels", {}) is Dictionary else {}
	var level: int = _resolve_battle_personality_level(officer, rarity, levels)
	var out := {
		"trait_id": trait_id,
		"rarity": rarity,
		"level": level,
		"attack_bonus_pct": 0.0,
		"defense_bonus_pct": 0.0,
		"speed_bonus_pct": 0.0,
		"spirit_bonus_flat": 0.0
	}
	if not levels.is_empty():
		var level_any: Variant = levels.get(str(level), null)
		if level_any is Dictionary:
			var level_data: Dictionary = level_any as Dictionary
			if level_data.has("effects"):
				_accumulate_gold_personality_level(level_data, out)
			else:
				_accumulate_blue_personality_level(level_data, out)
	_clamp_runtime_personality_bonus(out)
	var trait_name: String = String(trait_data.get("name", source_name)).strip_edges()
	if trait_name.is_empty():
		trait_name = source_name if not source_name.is_empty() else trait_id
	out["display_text"] = "%s Lv%d" % [trait_name, level] if level > 0 else trait_name
	return out

func _resolve_battle_personality_level(officer: Dictionary, rarity: String, levels: Dictionary) -> int:
	if levels.is_empty():
		return 0
	var available: Array[int] = _personality_level_keys(levels)
	if available.is_empty():
		return 1
	var score: float = _officer_personality_score(officer)
	var target: int = 1
	if rarity == "gold":
		target = 2 if score >= 82.0 else 1
	elif rarity == "blue":
		if score >= 95.0:
			target = 4
		elif score >= 84.0:
			target = 3
		elif score >= 70.0:
			target = 2
		else:
			target = 1
	else:
		target = 2 if score >= 82.0 else 1
	var chosen: int = available[0]
	for one in available:
		if one <= target:
			chosen = one
	return chosen

func _personality_level_keys(levels: Dictionary) -> Array[int]:
	var out: Array[int] = []
	for key_any in levels.keys():
		var lv: int = String(key_any).to_int()
		if lv <= 0:
			continue
		out.append(lv)
	out.sort()
	return out

func _officer_personality_score(officer: Dictionary) -> float:
	var stats_any: Variant = officer.get("stats", {})
	if stats_any is Dictionary:
		var stats: Dictionary = stats_any as Dictionary
		var lead: float = float(stats.get("lead", stats.get("leadership", 0.0)))
		var might: float = float(stats.get("might", stats.get("force", 0.0)))
		var intellect: float = float(stats.get("intellect", stats.get("intelligence", 0.0)))
		var politics: float = float(stats.get("politics", 0.0))
		var charm: float = float(stats.get("charm", 0.0))
		return maxf(lead, maxf(might, maxf(intellect, maxf(politics, charm))))
	var top_power: float = float(officer.get("power", 0.0))
	var top_int: float = float(officer.get("intelligence", 0.0))
	return maxf(top_power, top_int)

func _accumulate_blue_personality_level(level_data: Dictionary, out: Dictionary) -> void:
	for slot in ["main", "extra"]:
		var effect_any: Variant = level_data.get(slot, null)
		if not (effect_any is Dictionary):
			continue
		var effect_data: Dictionary = effect_any as Dictionary
		var effect_id: String = String(effect_data.get("effect", "")).strip_edges().to_lower()
		var effect_value: float = float(effect_data.get("value", 0.0))
		_apply_blue_effect_bonus(effect_id, effect_value, out)

func _accumulate_gold_personality_level(level_data: Dictionary, out: Dictionary) -> void:
	var effects_any: Variant = level_data.get("effects", [])
	if not (effects_any is Array):
		return
	for line_any in (effects_any as Array):
		var line: String = String(line_any).strip_edges()
		if line.is_empty() or line.begins_with("淇濈暀"):
			continue
		_apply_gold_effect_line_bonus(line, out)

func _apply_blue_effect_bonus(effect_id: String, raw_value: float, out: Dictionary) -> void:
	var clean_id: String = effect_id.strip_edges().to_lower()
	if clean_id.is_empty():
		return
	var value: float = absf(raw_value)
	if value <= 0.0001:
		return
	var pct_value: float = value if value <= 1.0 else value * 0.01
	if _effect_is_speed(clean_id):
		var speed_scale: float = 0.72
		if clean_id.find("penalty_reduction") >= 0:
			speed_scale = 0.56
		out["speed_bonus_pct"] = float(out.get("speed_bonus_pct", 0.0)) + pct_value * speed_scale
		return
	if _effect_is_defense(clean_id):
		var defense_scale: float = 0.58
		if clean_id.find("control_duration_reduction") >= 0 or clean_id.find("control_resist") >= 0:
			defense_scale = 0.46
		out["defense_bonus_pct"] = float(out.get("defense_bonus_pct", 0.0)) + pct_value * defense_scale
		return
	if _effect_is_spirit(clean_id):
		var spirit_flat: float = value
		if value <= 1.0:
			spirit_flat = value * 20.0
		var spirit_scale: float = 0.62
		if clean_id.find("morale_loss") >= 0:
			spirit_scale = 0.48
		out["spirit_bonus_flat"] = float(out.get("spirit_bonus_flat", 0.0)) + spirit_flat * spirit_scale
		return
	if _effect_is_attack(clean_id):
		var attack_scale: float = 0.5
		if clean_id.find("damage") >= 0 and clean_id.find("reduction") < 0:
			attack_scale = 0.66
		elif clean_id.find("hit_rate") >= 0 or clean_id.find("crit_rate") >= 0 or clean_id.find("follow_up") >= 0:
			attack_scale = 0.42
		elif clean_id.find("cooldown_reduction") >= 0:
			attack_scale = 0.36
		out["attack_bonus_pct"] = float(out.get("attack_bonus_pct", 0.0)) + pct_value * attack_scale

func _effect_is_speed(effect_id: String) -> bool:
	return effect_id.find("move_speed") >= 0 or effect_id.find("disengage_speed") >= 0 or effect_id.find("move_penalty_reduction") >= 0

func _effect_is_defense(effect_id: String) -> bool:
	return effect_id.find("damage_reduction") >= 0 or effect_id.find("resist") >= 0 or effect_id.find("shield") >= 0 or effect_id.find("block_rate") >= 0 or effect_id.find("casualty_reduction") >= 0 or effect_id.find("guard_intercept") >= 0

func _effect_is_spirit(effect_id: String) -> bool:
	return effect_id.find("morale") >= 0 or effect_id.find("will") >= 0 or effect_id.find("low_will") >= 0

func _effect_is_attack(effect_id: String) -> bool:
	return effect_id.find("damage") >= 0 or effect_id.find("hit_rate") >= 0 or effect_id.find("crit_rate") >= 0 or effect_id.find("armor_pen") >= 0 or effect_id.find("follow_up") >= 0 or effect_id.find("range_mul") >= 0 or effect_id.find("cooldown_reduction") >= 0 or effect_id.find("capture_chance") >= 0 or effect_id.find("debuff_apply_chance") >= 0

func _apply_gold_effect_line_bonus(line: String, out: Dictionary) -> void:
	var pct_values: Array[float] = _extract_percent_values(line)
	var pct_total: float = 0.0
	for one in pct_values:
		pct_total += absf(one)
	var has_speed: bool = _text_has_any(line, ["移动", "机动", "撤退", "封锁"])
	var has_defense: bool = _text_has_any(line, ["减伤", "控抗", "抗性", "霸体", "防御", "被控", "解控", "受击"])
	var has_attack: bool = _text_has_any(line, ["伤害", "增伤", "暴击", "命中", "破甲", "追加", "冲锋", "战法", "计策", "冷却", "异常", "点燃", "策击", "混乱", "震慑", "无视", "普攻", "概率", "智力"])
	var has_spirit: bool = _text_has_any(line, ["士气", "战意", "斗志"])
	if line.find("防御-") >= 0 or line.find("抗性") >= 0:
		has_attack = true
		has_defense = false
	if pct_total > 0.0:
		if has_speed:
			out["speed_bonus_pct"] = float(out.get("speed_bonus_pct", 0.0)) + pct_total * 0.72
		if has_defense:
			out["defense_bonus_pct"] = float(out.get("defense_bonus_pct", 0.0)) + pct_total * 0.62
		if has_attack and (not has_defense or line.find("闃插尽-") >= 0 or line.find("鎶楁€?") >= 0):
			out["attack_bonus_pct"] = float(out.get("attack_bonus_pct", 0.0)) + pct_total * 0.58
		if not has_speed and not has_defense and not has_attack:
			out["attack_bonus_pct"] = float(out.get("attack_bonus_pct", 0.0)) + pct_total * 0.45
	if has_spirit:
		var spirit_numbers: Array[float] = _extract_plain_numbers(line)
		var spirit_flat: float = 0.0
		for num in spirit_numbers:
			spirit_flat += absf(num)
		if spirit_flat > 0.0:
			out["spirit_bonus_flat"] = float(out.get("spirit_bonus_flat", 0.0)) + spirit_flat * 0.58
	if pct_total <= 0.0001:
		if has_attack:
			out["attack_bonus_pct"] = float(out.get("attack_bonus_pct", 0.0)) + 0.045
		if has_defense:
			out["defense_bonus_pct"] = float(out.get("defense_bonus_pct", 0.0)) + 0.04
		if has_speed:
			out["speed_bonus_pct"] = float(out.get("speed_bonus_pct", 0.0)) + 0.05

func _text_has_any(text: String, keywords: Array[String]) -> bool:
	for one in keywords:
		if text.find(one) >= 0:
			return true
	return false

func _ensure_battle_personality_regex_ready() -> void:
	if _battle_personality_regex_ready:
		return
	_battle_personality_percent_regex = RegEx.new()
	_battle_personality_plain_number_regex = RegEx.new()
	_battle_personality_percent_regex.compile("([+-]?\\d+(?:\\.\\d+)?)%")
	_battle_personality_plain_number_regex.compile("([+-]?\\d+(?:\\.\\d+)?)(?!\\s*%)")
	_battle_personality_regex_ready = true

func _extract_percent_values(text: String) -> Array[float]:
	_ensure_battle_personality_regex_ready()
	var out: Array[float] = []
	var matches: Array = _battle_personality_percent_regex.search_all(text)
	for match_any in matches:
		if not (match_any is RegExMatch):
			continue
		var match: RegExMatch = match_any as RegExMatch
		var num_text: String = match.get_string(1).strip_edges()
		if num_text.is_empty():
			continue
		out.append(float(num_text) * 0.01)
	return out

func _extract_plain_numbers(text: String) -> Array[float]:
	_ensure_battle_personality_regex_ready()
	var out: Array[float] = []
	var matches: Array = _battle_personality_plain_number_regex.search_all(text)
	for match_any in matches:
		if not (match_any is RegExMatch):
			continue
		var match: RegExMatch = match_any as RegExMatch
		var num_text: String = match.get_string(1).strip_edges()
		if num_text.is_empty():
			continue
		out.append(float(num_text))
	return out

func _clamp_runtime_personality_bonus(out: Dictionary) -> void:
	out["attack_bonus_pct"] = clampf(float(out.get("attack_bonus_pct", 0.0)), -0.12, 0.32)
	out["defense_bonus_pct"] = clampf(float(out.get("defense_bonus_pct", 0.0)), -0.12, 0.34)
	out["speed_bonus_pct"] = clampf(float(out.get("speed_bonus_pct", 0.0)), -0.1, 0.28)
	out["spirit_bonus_flat"] = clampf(float(out.get("spirit_bonus_flat", 0.0)), -20.0, 40.0)

func _put_dict_alias(target: Dictionary, key: String, value: Variant) -> void:
	var clean: String = key.strip_edges()
	if clean.is_empty():
		return
	target[clean] = value
	target[clean.to_lower()] = value

func _get_dict_alias(target: Dictionary, key: String) -> Variant:
	var clean: String = key.strip_edges()
	if clean.is_empty():
		return null
	if target.has(clean):
		return target[clean]
	var lower: String = clean.to_lower()
	if target.has(lower):
		return target[lower]
	return null

func _resolve_world_city(site_id: String, site_name: String = "") -> Dictionary:
	var by_id: Variant = _get_dict_alias(_world_city_by_id, site_id)
	if by_id is Dictionary:
		return (by_id as Dictionary).duplicate(true)
	if not site_name.is_empty():
		var by_name: Variant = _get_dict_alias(_world_city_by_name, site_name)
		if by_name is Dictionary:
			return (by_name as Dictionary).duplicate(true)
	return {}

func _resolve_world_building(site_id: String, site_name: String = "") -> Dictionary:
	var by_id: Variant = _get_dict_alias(_world_building_by_id, site_id)
	if by_id is Dictionary:
		return (by_id as Dictionary).duplicate(true)
	if not site_name.is_empty():
		var by_name: Variant = _get_dict_alias(_world_building_by_name, site_name)
		if by_name is Dictionary:
			return (by_name as Dictionary).duplicate(true)
	return {}

func _resolve_faction_name(faction_id: String) -> String:
	var mapped: Variant = _get_dict_alias(_world_faction_name_by_id, faction_id)
	if mapped != null:
		var text: String = String(mapped).strip_edges()
		if not text.is_empty():
			return text
	return "-" if faction_id.strip_edges().is_empty() else faction_id

func _apply_runtime_rules() -> void:
	_runtime_rules.clear()
	_runtime_dynamic_markers_enabled = DEFAULT_ENABLE_RUNTIME_DYNAMIC_MARKERS
	_runtime_supply_fog_enabled = DEFAULT_ENABLE_SUPPLY_FOG
	_supply_fog_refresh_seconds = DEFAULT_SUPPLY_FOG_REFRESH_SECONDS
	_supply_settlement_mode = DEFAULT_SUPPLY_SETTLEMENT_MODE
	_supply_settlement_interval_days = DEFAULT_SUPPLY_SETTLEMENT_INTERVAL_DAYS
	_supply_last_full_settle_day = -999999.0
	_supply_pending_full_recalc = true
	_supply_fog_perf_enabled = DEFAULT_SUPPLY_FOG_PERF_ENABLED
	_supply_fog_signature_grid_meters = DEFAULT_SUPPLY_FOG_SIGNATURE_GRID_METERS
	_supply_fog_unit_threshold_mid = DEFAULT_SUPPLY_FOG_UNIT_THRESHOLD_MID
	_supply_fog_unit_threshold_heavy = DEFAULT_SUPPLY_FOG_UNIT_THRESHOLD_HEAVY
	_supply_fog_camera_height_far = DEFAULT_SUPPLY_FOG_CAMERA_HEIGHT_FAR
	_supply_fog_refresh_scale_mid = DEFAULT_SUPPLY_FOG_REFRESH_SCALE_MID
	_supply_fog_refresh_scale_heavy = DEFAULT_SUPPLY_FOG_REFRESH_SCALE_HEAVY
	_supply_fog_refresh_scale_far = DEFAULT_SUPPLY_FOG_REFRESH_SCALE_FAR
	_supply_fog_marker_stride_mid = DEFAULT_SUPPLY_FOG_MARKER_STRIDE_MID
	_supply_fog_marker_stride_heavy = DEFAULT_SUPPLY_FOG_MARKER_STRIDE_HEAVY
	_supply_fog_marker_stride_far = DEFAULT_SUPPLY_FOG_MARKER_STRIDE_FAR
	_supply_fog_reveal_center_cap_mid = DEFAULT_SUPPLY_FOG_REVEAL_CENTER_CAP_MID
	_supply_fog_reveal_center_cap_heavy = DEFAULT_SUPPLY_FOG_REVEAL_CENTER_CAP_HEAVY
	_supply_fog_reveal_center_cap_far = DEFAULT_SUPPLY_FOG_REVEAL_CENTER_CAP_FAR
	_supply_fog_cached_signature = 0
	_supply_fog_cached_context_signature = ""
	_supply_fog_cached_ready = false
	_supply_fog_marker_cycle_index = 0
	_supply_fog_marker_stride_current = 1
	_supply_fog_reveal_center_cap_current = 0
	_supply_fog_effective_refresh_seconds = _supply_fog_refresh_seconds
	_show_supply_route_overlay = DEFAULT_SHOW_SUPPLY_ROUTE_OVERLAY
	_supply_region_mode_enabled = DEFAULT_SUPPLY_REGION_MODE_ENABLED
	_supply_route_focus_site_id = ""
	_supply_route_focus_faction_id = ""
	_supply_route_preview_action_id = ""
	_supply_route_preview_world = Vector3.INF
	_supply_route_preview_faction_id = ""
	_supply_corridor_view_enabled = false
	_runtime_mobile_unit_scale = DEFAULT_RUNTIME_MOBILE_UNIT_SCALE
	_runtime_allow_control_all_units_for_testing = DEFAULT_ALLOW_CONTROL_ALL_UNITS_FOR_TESTING
	_supply_use_scene_faction_fallback = DEFAULT_SUPPLY_USE_SCENE_FACTION_FALLBACK
	_runtime_dynamic_type_allow = DEFAULT_DYNAMIC_UNIT_TYPES.duplicate(true)
	_runtime_model_paths = DEFAULT_RUNTIME_MODEL_PATHS.duplicate(true)
	_runtime_model_scales = DEFAULT_RUNTIME_MODEL_SCALES.duplicate(true)
	var runtime_any: Variant = _engine_rules_cache.get("china_terrain_runtime_rules", {})
	if runtime_any is Dictionary:
		var raw: Dictionary = runtime_any as Dictionary
		_runtime_rules = raw.duplicate(true)
		_runtime_dynamic_markers_enabled = bool(raw.get("enable_dynamic_markers", _runtime_dynamic_markers_enabled))
		_runtime_supply_fog_enabled = bool(raw.get("enable_supply_fog", _runtime_supply_fog_enabled))
		_supply_fog_refresh_seconds = maxf(0.15, float(raw.get("refresh_interval_seconds", _supply_fog_refresh_seconds)))
		_show_supply_route_overlay = bool(raw.get("show_supply_route_overlay", _show_supply_route_overlay))
		_supply_region_mode_enabled = bool(raw.get("supply_region_mode_enabled", _supply_region_mode_enabled))
		_runtime_mobile_unit_scale = maxf(0.2, float(raw.get("mobile_unit_scale", _runtime_mobile_unit_scale)))
		_runtime_allow_control_all_units_for_testing = bool(raw.get("allow_control_all_units_for_testing", _runtime_allow_control_all_units_for_testing))
		_supply_use_scene_faction_fallback = bool(raw.get("supply_use_scene_faction_fallback", _supply_use_scene_faction_fallback))
		var supply_settlement_any: Variant = raw.get("supply_settlement", {})
		if supply_settlement_any is Dictionary:
			var settlement: Dictionary = supply_settlement_any as Dictionary
			var mode: String = String(settlement.get("mode", _supply_settlement_mode)).to_lower().strip_edges()
			if mode == "realtime" or mode == "daily" or mode == "turn":
				_supply_settlement_mode = mode
			_supply_settlement_interval_days = maxf(0.25, float(settlement.get("interval_days", _supply_settlement_interval_days)))
		var dynamic_types_any: Variant = raw.get("dynamic_unit_types", [])
		if dynamic_types_any is Array and not (dynamic_types_any as Array).is_empty():
			_runtime_dynamic_type_allow.clear()
			for type_any in (dynamic_types_any as Array):
				var type_key: String = String(type_any).to_lower().strip_edges()
				if not type_key.is_empty():
					_runtime_dynamic_type_allow[type_key] = true
		var model_paths_any: Variant = raw.get("dynamic_model_paths", {})
		if model_paths_any is Dictionary:
			for key_any in (model_paths_any as Dictionary).keys():
				var key: String = String(key_any).to_lower().strip_edges()
				var path: String = String((model_paths_any as Dictionary).get(key_any, "")).strip_edges()
				if not key.is_empty() and not path.is_empty():
					_runtime_model_paths[key] = path
		var model_scales_any: Variant = raw.get("dynamic_model_scales", {})
		if model_scales_any is Dictionary:
			for key_any in (model_scales_any as Dictionary).keys():
				var key: String = String(key_any).to_lower().strip_edges()
				if key.is_empty():
					continue
				_runtime_model_scales[key] = maxf(0.001, float((model_scales_any as Dictionary).get(key_any, _runtime_model_scales.get(key, 1.0))))
		var supply_perf_any: Variant = raw.get("supply_fog_perf", {})
		if supply_perf_any is Dictionary:
			var supply_perf: Dictionary = supply_perf_any as Dictionary
			_supply_fog_perf_enabled = bool(supply_perf.get("enabled", _supply_fog_perf_enabled))
			_supply_fog_signature_grid_meters = maxf(8.0, float(supply_perf.get("signature_grid_meters", _supply_fog_signature_grid_meters)))
			_supply_fog_unit_threshold_mid = maxi(60, int(supply_perf.get("unit_threshold_mid", _supply_fog_unit_threshold_mid)))
			_supply_fog_unit_threshold_heavy = maxi(_supply_fog_unit_threshold_mid, int(supply_perf.get("unit_threshold_heavy", _supply_fog_unit_threshold_heavy)))
			_supply_fog_camera_height_far = maxf(1200.0, float(supply_perf.get("camera_height_far", _supply_fog_camera_height_far)))
			_supply_fog_refresh_scale_mid = clampf(float(supply_perf.get("refresh_scale_mid", _supply_fog_refresh_scale_mid)), 1.0, 4.0)
			_supply_fog_refresh_scale_heavy = clampf(float(supply_perf.get("refresh_scale_heavy", _supply_fog_refresh_scale_heavy)), _supply_fog_refresh_scale_mid, 5.0)
			_supply_fog_refresh_scale_far = clampf(float(supply_perf.get("refresh_scale_far", _supply_fog_refresh_scale_far)), 1.0, 4.0)
			_supply_fog_marker_stride_mid = clampi(int(supply_perf.get("marker_stride_mid", _supply_fog_marker_stride_mid)), 1, 12)
			_supply_fog_marker_stride_heavy = clampi(int(supply_perf.get("marker_stride_heavy", _supply_fog_marker_stride_heavy)), _supply_fog_marker_stride_mid, 12)
			_supply_fog_marker_stride_far = clampi(int(supply_perf.get("marker_stride_far", _supply_fog_marker_stride_far)), _supply_fog_marker_stride_mid, 16)
			_supply_fog_reveal_center_cap_mid = maxi(0, int(supply_perf.get("reveal_center_cap_mid", _supply_fog_reveal_center_cap_mid)))
			_supply_fog_reveal_center_cap_heavy = maxi(0, int(supply_perf.get("reveal_center_cap_heavy", _supply_fog_reveal_center_cap_heavy)))
			_supply_fog_reveal_center_cap_far = maxi(0, int(supply_perf.get("reveal_center_cap_far", _supply_fog_reveal_center_cap_far)))
	if _battle_runtime != null and is_instance_valid(_battle_runtime) and _battle_runtime.has_method("set"):
		_battle_runtime.set("debug_allow_control_all_units_for_testing", _runtime_allow_control_all_units_for_testing)
	_ensure_supply_refresh_timer()

func _setup_supply_fog_runtime() -> void:
	_ensure_supply_refresh_timer()
	_refresh_supply_fog_runtime(true)

func _ensure_supply_refresh_timer() -> void:
	var existing: Node = get_node_or_null("SupplyFogRefreshTimer")
	if existing is Timer:
		_supply_refresh_timer = existing as Timer
	else:
		_supply_refresh_timer = Timer.new()
		_supply_refresh_timer.name = "SupplyFogRefreshTimer"
		_supply_refresh_timer.one_shot = false
		add_child(_supply_refresh_timer)
	_supply_fog_effective_refresh_seconds = maxf(0.15, _supply_fog_refresh_seconds)
	_supply_refresh_timer.wait_time = _supply_fog_effective_refresh_seconds
	if not _supply_refresh_timer.timeout.is_connected(_on_supply_refresh_timer_timeout):
		_supply_refresh_timer.timeout.connect(_on_supply_refresh_timer_timeout)
	_update_supply_fog_performance_budget()
	var should_run: bool = _runtime_dynamic_markers_enabled or _runtime_supply_fog_enabled
	if should_run:
		_supply_refresh_timer.start()
	else:
		_supply_refresh_timer.stop()

func _on_supply_refresh_timer_timeout() -> void:
	if Engine.is_editor_hint():
		return
	_refresh_supply_fog_runtime(true, false)

func _estimate_supply_fog_dynamic_count() -> int:
	var units_any: Variant = _world_state_cache.get("building_units", [])
	var count: int = 0
	if units_any is Array:
		count = (units_any as Array).size()
	count = maxi(count, _runtime_mobile_units.size())
	count = maxi(count, _runtime_unit_nodes.size())
	return count

func _runtime_camera_height() -> float:
	if _camera == null:
		return 0.0
	if _camera.has_method("get_current_target_height"):
		return maxf(0.0, float(_camera.call("get_current_target_height")))
	return maxf(0.0, float(_camera.global_position.y))

func _runtime_calendar_day() -> float:
	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	var base_day: float = maxf(1.0, float(meta.get("calendar_day", _runtime_time_weather.get("calendar_day", 1.0))))
	if _runtime_phase != RUNTIME_PHASE_BATTLE:
		return base_day
	var seconds_per_day: float = maxf(0.2, _runtime_seconds_per_day)
	var elapsed: float = clampf(_runtime_battle_elapsed_seconds, 0.0, maxf(0.0, _runtime_battle_total_seconds))
	return base_day + maxf(0.0, elapsed / seconds_per_day)

func _days_per_turn_now() -> float:
	var rules_any: Variant = _runtime_time_weather.get("rules", {})
	var rules: Dictionary = rules_any as Dictionary if rules_any is Dictionary else {}
	return maxf(1.0, float(rules.get("days_per_turn", 10.0)))

func _should_run_full_supply_settlement(force_full: bool) -> bool:
	if force_full:
		return true
	if _supply_pending_full_recalc:
		return true
	if not _supply_fog_cached_ready:
		return true
	if _supply_settlement_mode == "realtime":
		return true
	var day_now: float = _runtime_calendar_day()
	if _supply_last_full_settle_day < 0.0:
		return true
	if _supply_settlement_mode == "turn":
		var turn_days: float = _days_per_turn_now()
		return day_now - _supply_last_full_settle_day >= turn_days - 0.0001
	var interval_days: float = maxf(0.25, _supply_settlement_interval_days)
	return day_now - _supply_last_full_settle_day >= interval_days - 0.0001

func _update_supply_fog_performance_budget() -> void:
	var base_wait: float = maxf(0.15, _supply_fog_refresh_seconds)
	var wait_scale: float = 1.0
	var marker_stride: int = 1
	var reveal_cap: int = 0
	if _supply_fog_perf_enabled:
		var dynamic_count: int = _estimate_supply_fog_dynamic_count()
		if dynamic_count >= _supply_fog_unit_threshold_heavy:
			wait_scale *= _supply_fog_refresh_scale_heavy
			marker_stride = maxi(marker_stride, _supply_fog_marker_stride_heavy)
			reveal_cap = _supply_fog_reveal_center_cap_heavy
		elif dynamic_count >= _supply_fog_unit_threshold_mid:
			wait_scale *= _supply_fog_refresh_scale_mid
			marker_stride = maxi(marker_stride, _supply_fog_marker_stride_mid)
			reveal_cap = _supply_fog_reveal_center_cap_mid
		var cam_height: float = _runtime_camera_height()
		if cam_height >= _supply_fog_camera_height_far:
			wait_scale *= _supply_fog_refresh_scale_far
			marker_stride = maxi(marker_stride, _supply_fog_marker_stride_far)
			if reveal_cap <= 0:
				reveal_cap = _supply_fog_reveal_center_cap_far
			elif _supply_fog_reveal_center_cap_far > 0:
				reveal_cap = mini(reveal_cap, _supply_fog_reveal_center_cap_far)
	_supply_fog_marker_stride_current = maxi(1, marker_stride)
	_supply_fog_reveal_center_cap_current = maxi(0, reveal_cap)
	_supply_fog_effective_refresh_seconds = clampf(base_wait * wait_scale, 0.15, 4.0)
	if _supply_refresh_timer != null and is_instance_valid(_supply_refresh_timer):
		if absf(_supply_refresh_timer.wait_time - _supply_fog_effective_refresh_seconds) > 0.02:
			_supply_refresh_timer.wait_time = _supply_fog_effective_refresh_seconds
			if not _supply_refresh_timer.is_stopped():
				_supply_refresh_timer.start()

func _combine_supply_fog_signature(seed: int, value: int) -> int:
	return int((seed * 16777619) ^ value)

func _quantize_supply_fog_position(value: float) -> int:
	var grid: float = maxf(8.0, _supply_fog_signature_grid_meters)
	return int(round(value / grid))

func _build_supply_fog_runtime_signature() -> int:
	var signature: int = 216613626
	signature = _combine_supply_fog_signature(signature, _get_player_faction_id().hash())
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if units_any is Array:
		for unit_any in (units_any as Array):
			if not (unit_any is Dictionary):
				continue
			var unit: Dictionary = unit_any as Dictionary
			if not _is_runtime_dynamic_unit(unit):
				continue
			var unit_id: String = String(unit.get("id", "")).strip_edges()
			if unit_id.is_empty():
				continue
			var unit_type: String = String(unit.get("type", "site")).to_lower().strip_edges()
			var faction_id: String = String(unit.get("faction_id", "")).strip_edges()
			signature = _combine_supply_fog_signature(signature, unit_id.hash())
			signature = _combine_supply_fog_signature(signature, unit_type.hash())
			signature = _combine_supply_fog_signature(signature, faction_id.hash())
			signature = _combine_supply_fog_signature(signature, 1 if bool(unit.get("is_under_construction", false)) else 0)
			signature = _combine_supply_fog_signature(signature, 1 if bool(unit.get("awaiting_builder_arrival", false)) else 0)
			var px: float = 0.0
			var pz: float = 0.0
			if _is_runtime_mobile_unit_type(unit_type):
				var node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
				if node != null and is_instance_valid(node):
					px = float(node.global_position.x)
					pz = float(node.global_position.z)
				else:
					var pos_mobile_any: Variant = unit.get("position", {})
					if pos_mobile_any is Dictionary:
						var pos_mobile: Dictionary = pos_mobile_any as Dictionary
						px = float(pos_mobile.get("x", 0.0))
						pz = float(pos_mobile.get("z", 0.0))
			else:
				var pos_any: Variant = unit.get("position", {})
				if pos_any is Dictionary:
					var pos: Dictionary = pos_any as Dictionary
					px = float(pos.get("x", 0.0))
					pz = float(pos.get("z", 0.0))
			signature = _combine_supply_fog_signature(signature, _quantize_supply_fog_position(px))
			signature = _combine_supply_fog_signature(signature, _quantize_supply_fog_position(pz))
	var cities_any: Variant = _world_state_cache.get("cities", [])
	if cities_any is Array:
		for city_any in (cities_any as Array):
			if not (city_any is Dictionary):
				continue
			var city: Dictionary = city_any as Dictionary
			var city_id: String = String(city.get("id", "")).strip_edges()
			if city_id.is_empty():
				continue
			signature = _combine_supply_fog_signature(signature, city_id.hash())
			signature = _combine_supply_fog_signature(signature, String(city.get("faction_id", "")).strip_edges().hash())
	return signature

func _supply_fog_context_signature() -> String:
	return "%s|%s|%s|%.3f|%s" % [
		_get_player_faction_id(),
		String(_runtime_time_weather.get("day_phase", "day")),
		String(_runtime_time_weather.get("weather_state", "sunny")),
		float(_runtime_time_weather.get("visibility_mul", 1.0)),
		_runtime_phase
	]

func _refresh_runtime_marker_visibility_only() -> void:
	if _runtime_unit_nodes.is_empty():
		return
	var visibility_any: Variant = _supply_fog_snapshot.get("site_visible", {})
	var site_visible: Dictionary = visibility_any as Dictionary if visibility_any is Dictionary else {}
	for id_any in _runtime_unit_nodes.keys():
		var unit_id: String = String(id_any)
		var node: Node3D = _runtime_unit_nodes.get(unit_id, null) as Node3D
		if node == null or not is_instance_valid(node):
			continue
		_apply_runtime_unit_visibility(node, bool(site_visible.get(unit_id, true)))

func _build_supply_fog_visibility_patch(rules: Dictionary) -> Dictionary:
	var out_visible: Dictionary = {}
	var reveal_centers_static: Array = []
	var reveal_centers_mobile: Array = []
	var nodes_by_id: Dictionary = {}
	for node_any in _collect_supply_nodes():
		if not (node_any is Dictionary):
			continue
		var node: Dictionary = _normalize_supply_node(node_any as Dictionary)
		if node.is_empty():
			continue
		nodes_by_id[String(node.get("id", ""))] = node
	var node_ids: Array[String] = []
	var node_pos: Dictionary = {}
	var node_range: Dictionary = {}
	var faction_nodes: Dictionary = {}
	for node_id_any in nodes_by_id.keys():
		var node_id: String = String(node_id_any)
		var node: Dictionary = nodes_by_id[node_id] as Dictionary
		var pos := _node_pos2(node)
		node_ids.append(node_id)
		node_pos[node_id] = pos
		node_range[node_id] = _supply_range_for_node(node, rules)
		var faction_id: String = String(node.get("faction_id", "")).strip_edges()
		if faction_id.is_empty():
			continue
		var list_any: Variant = faction_nodes.get(faction_id, [])
		var list: Array = list_any as Array if list_any is Array else []
		list.append(node_id)
		faction_nodes[faction_id] = list
	var player_faction: String = _get_player_faction_id()
	var player_ids: Array = faction_nodes.get(player_faction, [])
	var visibility_mul: float = clampf(float(_runtime_time_weather.get("visibility_mul", 1.0)), 0.15, 2.0)
	for node_id_any in player_ids:
		var node_id: String = String(node_id_any)
		var node: Dictionary = nodes_by_id.get(node_id, {}) as Dictionary
		if not _is_player_vision_source_node(node):
			continue
		var pos: Vector2 = node_pos.get(node_id, Vector2.ZERO)
		var center := {
			"x": pos.x,
			"z": pos.y,
			"range": maxf(120.0, float(node_range.get(node_id, 0.0)) * visibility_mul)
		}
		if _is_troop_node(node) or _is_convoy_node(node):
			reveal_centers_mobile.append(center)
		else:
			reveal_centers_static.append(center)
	var reveal_centers: Array = reveal_centers_static.duplicate(true)
	reveal_centers.append_array(_budgeted_mobile_reveal_centers(reveal_centers_mobile))
	var reveal_mul: float = maxf(0.1, float(rules.get("enemy_reveal_range_mul", 1.0)))
	var reveal_padding: float = maxf(0.0, float(rules.get("enemy_reveal_padding", 280.0)))
	var reveal_min: float = maxf(0.0, float(rules.get("enemy_reveal_min_distance", 680.0)) * visibility_mul)
	for node_id_any in node_ids:
		var node_id: String = String(node_id_any)
		var node: Dictionary = nodes_by_id.get(node_id, {}) as Dictionary
		var faction_id: String = String(node.get("faction_id", ""))
		var enemy: bool = not faction_id.is_empty() and faction_id != player_faction
		var hidden_by_fog: bool = enemy and (_is_granary_node(node) or _is_convoy_node(node) or _is_troop_node(node))
		if not hidden_by_fog:
			out_visible[node_id] = true
			continue
		var p: Vector2 = node_pos.get(node_id, Vector2.ZERO)
		out_visible[node_id] = _is_revealed_point(p, reveal_centers, reveal_mul, reveal_padding, reveal_min)
	return {
		"site_visible": out_visible,
		"reveal_centers": reveal_centers,
		"vision_context": {
			"day_phase": String(_runtime_time_weather.get("day_phase", "day")),
			"weather_state": String(_runtime_time_weather.get("weather_state", "sunny")),
			"visibility_mul": visibility_mul
		}
	}

func _apply_runtime_supply_status_effects() -> void:
	if _runtime_mobile_units.is_empty():
		return
	var supply_enabled: bool = _runtime_supply_fog_enabled and bool(_supply_fog_snapshot.get("enabled", false))
	var in_supply_global: Dictionary = {}
	var in_supply_any: Variant = _supply_fog_snapshot.get("in_supply_site_ids", [])
	if in_supply_any is Array:
		for id_any in (in_supply_any as Array):
			in_supply_global[String(id_any)] = true
	var in_supply_by_faction_flags: Dictionary = {}
	var by_faction_any: Variant = _supply_fog_snapshot.get("in_supply_by_faction", {})
	if by_faction_any is Dictionary:
		for faction_any in (by_faction_any as Dictionary).keys():
			var faction_id: String = String(faction_any).strip_edges()
			if faction_id.is_empty():
				continue
			var ids_any: Variant = (by_faction_any as Dictionary).get(faction_any, [])
			if not (ids_any is Array):
				continue
			var flags: Dictionary = {}
			for site_id_any in (ids_any as Array):
				flags[String(site_id_any)] = true
			in_supply_by_faction_flags[faction_id] = flags
	var hold_sec: float = maxf(4.0, _supply_fog_effective_refresh_seconds * 3.0)
	for id_any in _runtime_mobile_units.keys():
		var unit_id: String = String(id_any).strip_edges()
		if unit_id.is_empty():
			continue
		var node: Node3D = _runtime_mobile_units.get(id_any, null) as Node3D
		if node == null or not is_instance_valid(node):
			_runtime_supply_report_state.erase(unit_id)
			continue
		if not node.has_method("apply_status") or not node.has_method("clear_status"):
			_runtime_supply_report_state.erase(unit_id)
			continue
		var snap_any: Variant = _runtime_mobile_snapshots.get(unit_id, {})
		if not (snap_any is Dictionary):
			_runtime_supply_report_state.erase(unit_id)
			node.call("clear_status", int(UnitController.StatusId.OUT_OF_SUPPLY))
			continue
		var snap: Dictionary = snap_any as Dictionary
		var unit_type: String = String(snap.get("type", "")).to_lower().strip_edges()
		if not _is_runtime_mobile_unit_type(unit_type):
			_runtime_supply_report_state.erase(unit_id)
			node.call("clear_status", int(UnitController.StatusId.OUT_OF_SUPPLY))
			continue
		var faction_id: String = String(snap.get("faction_id", "")).strip_edges()
		var in_supply: bool = true
		if supply_enabled:
			if not faction_id.is_empty():
				var faction_flags_any: Variant = in_supply_by_faction_flags.get(faction_id, {})
				if faction_flags_any is Dictionary:
					in_supply = bool((faction_flags_any as Dictionary).get(unit_id, false))
				else:
					in_supply = bool(in_supply_global.get(unit_id, false))
			else:
				in_supply = bool(in_supply_global.get(unit_id, true))
		if in_supply:
			node.call("clear_status", int(UnitController.StatusId.OUT_OF_SUPPLY))
		else:
			node.call("apply_status", int(UnitController.StatusId.OUT_OF_SUPPLY), hold_sec)
		var had_prev: bool = _runtime_supply_report_state.has(unit_id)
		var prev_in_supply: bool = bool(_runtime_supply_report_state.get(unit_id, in_supply))
		_runtime_supply_report_state[unit_id] = in_supply
		if supply_enabled and had_prev and prev_in_supply != in_supply:
			_report_runtime_supply_event(node, snap, in_supply)

func _refresh_supply_fog_runtime(rebuild_markers: bool = true, force_full: bool = true) -> void:
	_sync_runtime_time_weather_state(false)
	var construction_changed: bool = _tick_runtime_construction()
	if construction_changed:
		_supply_pending_full_recalc = true
	_sync_runtime_mobile_units()
	_update_supply_fog_performance_budget()
	_ensure_runtime_fog_overlay()
	var should_full_settle: bool = _should_run_full_supply_settlement(force_full)
	var fog_signature: int = _build_supply_fog_runtime_signature()
	var context_signature: String = _supply_fog_context_signature()
	var should_rebuild_snapshot: bool = true
	if _supply_fog_perf_enabled and _runtime_supply_fog_enabled and _supply_fog_cached_ready:
		should_rebuild_snapshot = construction_changed or _supply_pending_full_recalc
		if not should_rebuild_snapshot and fog_signature != _supply_fog_cached_signature:
			should_rebuild_snapshot = true
		if not should_rebuild_snapshot and context_signature != _supply_fog_cached_context_signature:
			should_rebuild_snapshot = true
	if _runtime_supply_fog_enabled:
		if should_full_settle:
			if should_rebuild_snapshot:
				_supply_fog_snapshot = _build_supply_fog_snapshot()
				_supply_fog_cached_signature = fog_signature
				_supply_fog_cached_context_signature = context_signature
				_supply_fog_cached_ready = true
			_supply_last_full_settle_day = _runtime_calendar_day()
			_supply_pending_full_recalc = false
		else:
			var rules_raw: Dictionary = _engine_rules_cache.get("supply_fog_rules", {})
			var rules: Dictionary = _build_supply_fog_rules(rules_raw)
			var patch: Dictionary = _build_supply_fog_visibility_patch(rules)
			_supply_fog_snapshot["enabled"] = true
			_supply_fog_snapshot["site_visible"] = patch.get("site_visible", {})
			_supply_fog_snapshot["reveal_centers"] = patch.get("reveal_centers", [])
			_supply_fog_snapshot["vision_context"] = patch.get("vision_context", {})
	else:
		_supply_fog_snapshot = {
			"enabled": false,
			"site_visible": {},
			"reveal_centers": [],
			"in_supply_site_ids": [],
			"in_supply_by_faction": {},
			"supply_regions_by_faction": {},
			"supply_edges": [],
			"vision_context": {
				"day_phase": String(_runtime_time_weather.get("day_phase", "day")),
				"weather_state": String(_runtime_time_weather.get("weather_state", "sunny")),
				"visibility_mul": float(_runtime_time_weather.get("visibility_mul", 1.0))
			}
		}
		_supply_fog_cached_ready = false
		_supply_pending_full_recalc = true
	_apply_runtime_supply_status_effects()
	_apply_runtime_mobile_visibility()
	var allow_rebuild_markers: bool = rebuild_markers
	if allow_rebuild_markers and _supply_fog_perf_enabled and _supply_fog_marker_stride_current > 1:
		_supply_fog_marker_cycle_index = (_supply_fog_marker_cycle_index + 1) % _supply_fog_marker_stride_current
		allow_rebuild_markers = _supply_fog_marker_cycle_index == 0
	if allow_rebuild_markers:
		_rebuild_runtime_unit_markers()
	elif rebuild_markers:
		_refresh_runtime_marker_visibility_only()
	_refresh_runtime_fog_overlay()
	_refresh_supply_corridor_region_overlay()
	_rebuild_supply_route_overlay()
	_refresh_supply_debug_overlay()

func _tick_runtime_construction() -> bool:
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return false
	var units: Array = units_any as Array
	var now_msec: int = Time.get_ticks_msec()
	var changed: bool = false
	for i in range(units.size()):
		var unit_any: Variant = units[i]
		if not (unit_any is Dictionary):
			continue
		var node: Dictionary = (unit_any as Dictionary).duplicate(true)
		if bool(node.get("awaiting_builder_arrival", false)):
			var builder_id: String = String(node.get("builder_unit_id", "")).strip_edges()
			var builder: Node3D = _runtime_mobile_units.get(builder_id, null) as Node3D
			if builder != null and is_instance_valid(builder):
				var target := Vector3.ZERO
				var arrive_radius: float = UNIT_BUILD_ARRIVE_START_RADIUS
				var staging_any: Variant = node.get("builder_staging_position", {})
				if staging_any is Dictionary:
					var staging: Dictionary = staging_any as Dictionary
					target = Vector3(float(staging.get("x", 0.0)), 0.0, float(staging.get("z", 0.0)))
					arrive_radius = UNIT_BUILD_STAGING_ARRIVE_RADIUS
				else:
					var pos_any: Variant = node.get("position", {})
					if pos_any is Dictionary:
						var p: Dictionary = pos_any as Dictionary
						target = Vector3(float(p.get("x", 0.0)), 0.0, float(p.get("z", 0.0)))
				var delta := builder.global_position - target
				delta.y = 0.0
				if delta.length() <= arrive_radius:
					node["awaiting_builder_arrival"] = false
					node["is_under_construction"] = true
					node["construction_started_msec"] = now_msec
					node.erase("builder_staging_position")
					changed = true
			units[i] = node
			_sync_world_building_alias(node)
			continue
		if bool(node.get("operation_active", false)):
			var op_start_msec: int = int(node.get("operation_started_msec", now_msec))
			var op_duration_sec: float = maxf(0.8, float(node.get("operation_duration_sec", 1.0)))
			var op_elapsed_sec: float = maxf(0.0, float(now_msec - op_start_msec) / 1000.0)
			var op_progress: float = clampf(op_elapsed_sec / op_duration_sec, 0.0, 1.0)
			node["operation_progress"] = op_progress
			node["construction_progress"] = op_progress
			var op_kind: String = String(node.get("operation_kind", "")).strip_edges().to_lower()
			if op_kind == "repair":
				var repair_from: float = float(node.get("operation_repair_from_hp", node.get("hp", 1.0)))
				var repair_to: float = float(node.get("operation_repair_to_hp", node.get("max_hp", 1.0)))
				node["hp"] = lerpf(repair_from, repair_to, op_progress)
			if op_progress >= 0.999:
				var op_builder_id: String = String(node.get("operation_builder_unit_id", node.get("builder_unit_id", ""))).strip_edges()
				var completed_kind: String = op_kind
				node = _complete_facility_operation(node)
				match completed_kind:
					"upgrade":
						_report_runtime_facility_event_by_builder_id(op_builder_id, node, "facility_upgrade_complete")
					"repair":
						_report_runtime_facility_event_by_builder_id(op_builder_id, node, "facility_repair_complete")
					_:
						pass
			units[i] = node
			_sync_world_building_alias(node)
			changed = true
			continue
		if not bool(node.get("is_under_construction", false)):
			continue
		var start_msec: int = int(node.get("construction_started_msec", now_msec))
		var duration_sec: float = maxf(1.0, float(node.get("construction_duration_sec", 10.0)))
		var elapsed_sec: float = maxf(0.0, float(now_msec - start_msec) / 1000.0)
		var progress: float = clampf(elapsed_sec / duration_sec, 0.0, 1.0)
		node["construction_progress"] = progress
		var type_key: String = String(node.get("type", "")).to_lower().strip_edges()
		var max_hp: float = maxf(1.0, float(node.get("max_hp", _facility_default_max_hp(type_key))))
		node["max_hp"] = max_hp
		node["hp"] = maxf(1.0, max_hp * progress)
		if progress >= 0.999:
			node["is_under_construction"] = false
			node["construction_progress"] = 1.0
			node["hp"] = max_hp
			var builder_id: String = String(node.get("builder_unit_id", "")).strip_edges()
			_report_runtime_facility_event_by_builder_id(builder_id, node, "build_complete")
		units[i] = node
		_sync_world_building_alias(node)
		changed = true
	if changed:
		_world_state_cache["building_units"] = units
	return changed

func _complete_facility_operation(node: Dictionary) -> Dictionary:
	if not bool(node.get("operation_active", false)):
		return node
	var op_kind: String = String(node.get("operation_kind", "")).strip_edges().to_lower()
	match op_kind:
		"upgrade":
			var action_id: String = String(node.get("operation_upgrade_action_id", "")).strip_edges()
			var spec: Dictionary = UNIT_BUILD_UPGRADE_ACTIONS.get(action_id, {}) as Dictionary
			if not spec.is_empty():
				var old_max: float = maxf(1.0, float(node.get("max_hp", _facility_default_max_hp(String(node.get("type", "")).to_lower().strip_edges()))))
				var old_hp: float = clampf(float(node.get("hp", old_max)), 1.0, old_max)
				var hp_ratio: float = clampf(old_hp / old_max, 0.05, 1.0)
				var faction_id: String = String(node.get("faction_id", "")).strip_edges()
				var to_type: String = String(spec.get("to_type", String(node.get("type", "")))).to_lower().strip_edges()
				node["type"] = to_type
				node["name"] = "%s%s" % [_resolve_faction_name(faction_id), String(spec.get("name", to_type))]
				if bool(spec.get("to_advanced_granary", false)):
					node["is_granary"] = true
					node["is_advanced_granary"] = true
					node["level"] = 2
					var stats_any: Variant = node.get("stats", {})
					var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
					stats["security"] = maxf(60.0, float(stats.get("security", 56.0)))
					node["stats"] = stats
					var resources_any: Variant = node.get("resources", {})
					var resources: Dictionary = resources_any as Dictionary if resources_any is Dictionary else {}
					resources["food"] = maxf(22000.0, float(resources.get("food", 0.0)))
					node["resources"] = resources
				var new_max: float = maxf(1.0, _facility_default_max_hp(to_type))
				node["max_hp"] = new_max
				node["hp"] = maxf(1.0, new_max * hp_ratio)
		"repair":
			var repair_to: float = maxf(1.0, float(node.get("operation_repair_to_hp", node.get("max_hp", 1.0))))
			node["hp"] = repair_to
		_:
			pass
	node.erase("operation_active")
	node.erase("operation_kind")
	node.erase("operation_started_msec")
	node.erase("operation_duration_sec")
	node.erase("operation_progress")
	node.erase("operation_upgrade_action_id")
	node.erase("operation_builder_unit_id")
	node.erase("operation_repair_from_hp")
	node.erase("operation_repair_to_hp")
	node["construction_progress"] = 1.0
	return node

func _ensure_runtime_unit_root() -> void:
	var node: Node = get_node_or_null("RuntimeUnitMarkers")
	if node is Node3D:
		_runtime_unit_root = node as Node3D
		return
	_runtime_unit_root = Node3D.new()
	_runtime_unit_root.name = "RuntimeUnitMarkers"
	add_child(_runtime_unit_root)

func _clear_runtime_unit_markers() -> void:
	_runtime_unit_nodes.clear()
	_runtime_unit_snapshots.clear()
	for id_any in _supply_debug_labels.keys():
		var label: Label3D = _supply_debug_labels.get(id_any, null) as Label3D
		if label != null and is_instance_valid(label):
			label.queue_free()
	_supply_debug_labels.clear()
	if _runtime_unit_root == null:
		return
	for child in _runtime_unit_root.get_children():
		if child is Node:
			(child as Node).queue_free()

func _runtime_dynamic_units_from_world_state() -> Array:
	var out: Array = []
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return out
	for unit_any in (units_any as Array):
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = (unit_any as Dictionary).duplicate(true)
		if _is_runtime_dynamic_unit(unit):
			out.append(unit)
	return out

func _rebuild_runtime_unit_markers() -> void:
	if not _runtime_dynamic_markers_enabled:
		_clear_runtime_unit_markers()
		return
	_ensure_runtime_unit_root()
	var dynamic_units: Array = _runtime_dynamic_units_from_world_state()
	var visibility_any: Variant = _supply_fog_snapshot.get("site_visible", {})
	var site_visible: Dictionary = visibility_any as Dictionary if visibility_any is Dictionary else {}
	var keep_ids: Dictionary = {}
	for unit_any in dynamic_units:
		var unit: Dictionary = unit_any as Dictionary
		var unit_id: String = String(unit.get("id", "")).strip_edges()
		if unit_id.is_empty():
			continue
		var unit_type: String = String(unit.get("type", "site")).to_lower()
		if _is_runtime_mobile_unit_type(unit_type):
			continue
		var pos_any: Variant = unit.get("position", {})
		if not (pos_any is Dictionary):
			continue
		keep_ids[unit_id] = true
		var pos: Dictionary = pos_any as Dictionary
		var world_x: float = float(pos.get("x", 0.0))
		var world_z: float = float(pos.get("z", 0.0))
		if not _is_finite_number(world_x) or not _is_finite_number(world_z):
			continue
		var ground_y: float = terrain_height_at_world(Vector3(world_x, 0.0, world_z))
		if not _is_finite_number(ground_y):
			ground_y = 0.0
		var marker_h: float = _runtime_unit_marker_height(unit_type)
		var marker_r: float = _runtime_unit_marker_radius(unit_type)
		var node: Node3D = _runtime_unit_nodes.get(unit_id, null) as Node3D
		if node == null or not is_instance_valid(node):
			node = Node3D.new()
			node.name = "Runtime_%s" % unit_id
			node.set_meta("building_id", unit_id)
			node.set_meta("building_type", unit_type)
			_runtime_unit_root.add_child(node)

		node.position = Vector3(world_x, ground_y + marker_h * 0.5, world_z)
		node.rotation = Vector3.ZERO
		node.rotation.y = deg_to_rad(float(unit.get("rotation_y_deg", 0.0)))
		node.set_meta("building_type", unit_type)

		var mesh: MeshInstance3D = node.get_node_or_null("Marker") as MeshInstance3D
		if mesh == null:
			mesh = MeshInstance3D.new()
			mesh.name = "Marker"
			node.add_child(mesh)
		mesh.mesh = _runtime_unit_marker_mesh(unit_type, marker_r, marker_h)
		mesh.material_override = _runtime_unit_marker_material(unit)
		var has_runtime_model: bool = _apply_runtime_unit_model(node, unit, unit_type, marker_h)
		_apply_pending_construction_outline(node, unit)
		mesh.visible = not has_runtime_model

		var body: StaticBody3D = node.get_node_or_null("StaticBody3D") as StaticBody3D
		if body == null:
			body = StaticBody3D.new()
			body.name = "StaticBody3D"
			body.collision_mask = 0
			node.add_child(body)
		body.set_meta("building_id", unit_id)
		body.set_meta("building_type", unit_type)
		var shape: CollisionShape3D = body.get_node_or_null("BodyShape") as CollisionShape3D
		if shape == null:
			shape = CollisionShape3D.new()
			shape.name = "BodyShape"
			body.add_child(shape)
		shape.shape = _runtime_unit_collision_shape(unit_type, marker_r, marker_h)
		_apply_runtime_unit_visibility(node, bool(site_visible.get(unit_id, true)))
		_update_runtime_construction_bar(node, unit, marker_h, marker_r)

		_runtime_unit_nodes[unit_id] = node
		_runtime_unit_snapshots[unit_id] = unit
	for id_any in _runtime_unit_nodes.keys():
		var stale_id: String = String(id_any)
		if keep_ids.has(stale_id):
			continue
		var stale_node: Node3D = _runtime_unit_nodes.get(stale_id, null) as Node3D
		if stale_node != null and is_instance_valid(stale_node):
			stale_node.queue_free()
		_runtime_unit_nodes.erase(stale_id)
		_runtime_unit_snapshots.erase(stale_id)

func _is_runtime_dynamic_unit_type(unit_type: String) -> bool:
	var key: String = unit_type.to_lower().strip_edges()
	if key.is_empty():
		return false
	return _runtime_dynamic_type_allow.has(key)

func _is_runtime_dynamic_unit(unit: Dictionary) -> bool:
	if unit.is_empty():
		return false
	var type_key: String = String(unit.get("type", "site")).to_lower().strip_edges()
	if not type_key.is_empty() and _runtime_dynamic_type_allow.has(type_key):
		return true
	if bool(unit.get("is_field_troop", false)):
		return true
	if bool(unit.get("is_granary", false)):
		return true
	if bool(unit.get("is_supply_convoy", false)):
		return true
	return false

func _update_runtime_construction_bar(node: Node3D, unit: Dictionary, marker_h: float, marker_r: float) -> void:
	if node == null or not is_instance_valid(node):
		return
	var under_construction: bool = bool(unit.get("is_under_construction", false))
	var op_active: bool = bool(unit.get("operation_active", false))
	var root: Node3D = node.get_node_or_null("BuildBarRoot") as Node3D
	if not under_construction and not op_active:
		if root != null and is_instance_valid(root):
			root.visible = false
		return
	var progress: float = clampf(float(unit.get("construction_progress", 0.0)), 0.0, 1.0)
	if op_active:
		progress = clampf(float(unit.get("operation_progress", progress)), 0.0, 1.0)
	var fill_color: Color = Color(0.92, 0.72, 0.3, 0.96)
	if op_active:
		var op_kind: String = String(unit.get("operation_kind", "")).strip_edges().to_lower()
		if op_kind == "repair":
			fill_color = Color(0.4, 0.9, 0.45, 0.96)
		elif op_kind == "upgrade":
			fill_color = Color(0.46, 0.84, 0.94, 0.96)
	if root == null:
		root = Node3D.new()
		root.name = "BuildBarRoot"
		node.add_child(root)
		var bg := MeshInstance3D.new()
		bg.name = "BG"
		var bg_box := BoxMesh.new()
		bg_box.size = Vector3(1.6, 0.08, 0.08)
		bg.mesh = bg_box
		var bg_mat := StandardMaterial3D.new()
		bg_mat.albedo_color = Color(0.16, 0.16, 0.16, 0.9)
		bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bg.material_override = bg_mat
		root.add_child(bg)
		var fill := MeshInstance3D.new()
		fill.name = "Fill"
		var fill_box := BoxMesh.new()
		fill_box.size = Vector3(1.58, 0.06, 0.06)
		fill.mesh = fill_box
		var fill_mat := StandardMaterial3D.new()
		fill_mat.albedo_color = fill_color
		fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fill.material_override = fill_mat
		root.add_child(fill)
	root.visible = true
	root.position = Vector3(0.0, marker_h * 0.56 + marker_r * 0.16, 0.0)
	root.look_at(_camera.global_position if _camera != null and is_instance_valid(_camera) else node.global_position + Vector3.FORWARD, Vector3.UP)
	var cached_color_any: Variant = root.get_meta("fill_color_cached", Color(-1, -1, -1, -1))
	var cached_color: Color = cached_color_any if cached_color_any is Color else Color(-1, -1, -1, -1)
	if cached_color != fill_color:
		root.set_meta("fill_color_cached", fill_color)
		var fill_mat_setter: MeshInstance3D = root.get_node_or_null("Fill") as MeshInstance3D
		if fill_mat_setter != null:
			var fill_override: StandardMaterial3D = fill_mat_setter.material_override as StandardMaterial3D
			if fill_override != null:
				fill_override.albedo_color = fill_color
	var cached_progress: float = float(root.get_meta("progress_cached", -1.0))
	if absf(cached_progress - progress) < 0.01:
		return
	root.set_meta("progress_cached", progress)
	var fill_mesh: MeshInstance3D = root.get_node_or_null("Fill") as MeshInstance3D
	if fill_mesh == null:
		return
	fill_mesh.scale = Vector3(maxf(0.02, progress), 1.0, 1.0)
	fill_mesh.position = Vector3((progress - 1.0) * 0.79, 0.0, 0.0)

func _apply_pending_construction_outline(node: Node3D, unit: Dictionary) -> void:
	if node == null or not is_instance_valid(node):
		return
	var pending: bool = bool(unit.get("awaiting_builder_arrival", false))
	var model_root: Node3D = node.get_node_or_null("ModelRoot") as Node3D
	if model_root == null:
		return
	_apply_outline_to_tree(model_root, pending)

func _apply_outline_to_tree(root: Node, pending: bool) -> void:
	if root == null:
		return
	if root is GeometryInstance3D:
		var geo: GeometryInstance3D = root as GeometryInstance3D
		geo.transparency = 0.6 if pending else 0.0
	for child in root.get_children():
		_apply_outline_to_tree(child, pending)

func _apply_runtime_unit_visibility(node: Node3D, visible_now: bool) -> void:
	if node == null or not is_instance_valid(node):
		return
	node.visible = visible_now
	var body: StaticBody3D = node.get_node_or_null("StaticBody3D") as StaticBody3D
	if body != null:
		body.input_ray_pickable = visible_now
		body.collision_layer = BUILDING_COLLISION_LAYER if visible_now else 0

func _apply_runtime_unit_model(node: Node3D, unit: Dictionary, unit_type: String, marker_height: float) -> bool:
	if node == null or not is_instance_valid(node):
		return false
	var model_root: Node3D = node.get_node_or_null("ModelRoot") as Node3D
	if model_root == null:
		model_root = Node3D.new()
		model_root.name = "ModelRoot"
		node.add_child(model_root)
	var model_y_offset: float = -marker_height * 0.5
	if _is_granary_node(unit):
		model_y_offset = 0.0
	elif _is_convoy_node(unit):
		model_y_offset = -marker_height * 0.3
	model_root.position = Vector3(0.0, model_y_offset, 0.0)
	if unit_type == "zhalan":
		return _apply_runtime_zhalan_poly_model(node, model_root)
	var model_path: String = _runtime_model_path_for_unit(unit, unit_type)
	if model_path.is_empty():
		_clear_runtime_model_root(model_root)
		node.set_meta("runtime_model_path", "")
		return false
	var packed: PackedScene = _load_runtime_model_scene(model_path)
	if packed == null:
		_clear_runtime_model_root(model_root)
		node.set_meta("runtime_model_path", "")
		return false
	var current_path: String = String(node.get_meta("runtime_model_path", ""))
	if current_path != model_path or model_root.get_child_count() == 0:
		_clear_runtime_model_root(model_root)
		var inst: Node = packed.instantiate()
		if inst == null:
			node.set_meta("runtime_model_path", "")
			return false
		model_root.add_child(inst)
		node.set_meta("runtime_model_path", model_path)
	var model_scale: float = _runtime_model_scale_for_unit(unit, unit_type)
	model_root.scale = Vector3.ONE * model_scale
	model_root.visible = true
	return true

func _apply_runtime_zhalan_poly_model(node: Node3D, model_root: Node3D) -> bool:
	if node == null or not is_instance_valid(node) or model_root == null:
		return false
	var current_key: String = String(node.get_meta("runtime_model_path", ""))
	if current_key != ZHALAN_POLY_MODEL_CACHE_KEY or model_root.get_child_count() == 0:
		_clear_runtime_model_root(model_root)
		var inst: Node3D = _instantiate_runtime_zhalan_poly_model()
		if inst == null:
			var fallback_path: String = String(DEFAULT_RUNTIME_MODEL_PATHS.get("zhalan", "")).strip_edges()
			var fallback_scene: PackedScene = _load_runtime_model_scene(fallback_path)
			if fallback_scene == null:
				node.set_meta("runtime_model_path", "")
				return false
			var fallback_inst: Node = fallback_scene.instantiate()
			if fallback_inst == null:
				node.set_meta("runtime_model_path", "")
				return false
			model_root.add_child(fallback_inst)
			node.set_meta("runtime_model_path", fallback_path)
			model_root.scale = Vector3.ONE * _model_scale_by_key(["zhalan"], 1.0) * FACILITY_MODEL_SCALE_MUL
			model_root.visible = true
			return true
		model_root.add_child(inst)
		node.set_meta("runtime_model_path", ZHALAN_POLY_MODEL_CACHE_KEY)
	model_root.scale = Vector3.ONE
	model_root.visible = true
	return true

func _instantiate_runtime_zhalan_poly_model() -> Node3D:
	var template: Node3D = _load_runtime_zhalan_poly_template()
	if template == null or not is_instance_valid(template):
		return null
	var inst: Node = template.duplicate()
	if inst is Node3D:
		return inst as Node3D
	return null

func _load_runtime_zhalan_poly_template() -> Node3D:
	if _runtime_zhalan_poly_template != null and is_instance_valid(_runtime_zhalan_poly_template):
		return _runtime_zhalan_poly_template
	var root: Node3D = _create_runtime_zhalan_poly_root()
	if root == null:
		return null
	_runtime_zhalan_poly_template = root
	return _runtime_zhalan_poly_template

func _create_runtime_zhalan_poly_root() -> Node3D:
	var log_mesh: Mesh = _load_runtime_zhalan_poly_log_mesh()
	if log_mesh == null:
		return null
	var root := Node3D.new()
	root.name = "ZhalanPolyLog"
	var mesh := MeshInstance3D.new()
	mesh.name = "Stake"
	mesh.mesh = log_mesh
	var basis := Basis.IDENTITY
	basis = basis.rotated(Vector3.FORWARD, deg_to_rad(90.0))
	basis = basis.scaled(Vector3.ONE * ZHALAN_POLY_STAKE_SCALE)
	var y_range: Vector2 = _mesh_y_range_with_basis(log_mesh.get_aabb(), basis)
	mesh.transform = Transform3D(basis, Vector3(0.0, -y_range.x, 0.0))
	root.add_child(mesh)
	return root

func _load_runtime_zhalan_poly_log_mesh() -> Mesh:
	if _runtime_zhalan_poly_log_mesh_cache != null:
		return _runtime_zhalan_poly_log_mesh_cache
	var packed: PackedScene = load(POLY_NATURE_PACK_SCENE_PATH) as PackedScene
	if packed == null:
		if not _runtime_zhalan_poly_warned_missing:
			_runtime_zhalan_poly_warned_missing = true
			push_warning("ChinaTerrain30km missing poly nature scene for zhalan: %s" % POLY_NATURE_PACK_SCENE_PATH)
		return null
	var root: Node = packed.instantiate()
	if root == null:
		if not _runtime_zhalan_poly_warned_missing:
			_runtime_zhalan_poly_warned_missing = true
			push_warning("ChinaTerrain30km failed to instantiate poly nature scene for zhalan.")
		return null
	for name_any in ZHALAN_POLY_LOG_NODE_CANDIDATES:
		var name: String = String(name_any)
		var candidate: MeshInstance3D = root.find_child(name, true, false) as MeshInstance3D
		if candidate == null:
			continue
		if candidate.mesh == null:
			continue
		_runtime_zhalan_poly_log_mesh_cache = candidate.mesh
		root.free()
		return _runtime_zhalan_poly_log_mesh_cache
	root.free()
	if not _runtime_zhalan_poly_warned_missing:
		_runtime_zhalan_poly_warned_missing = true
		push_warning("ChinaTerrain30km could not find log mesh nodes in poly nature scene for zhalan.")
	return null

func _mesh_y_range_with_basis(aabb: AABB, basis: Basis) -> Vector2:
	var min_y: float = INF
	var max_y: float = -INF
	for xi in [0.0, 1.0]:
		for yi in [0.0, 1.0]:
			for zi in [0.0, 1.0]:
				var corner := Vector3(
					aabb.position.x + aabb.size.x * xi,
					aabb.position.y + aabb.size.y * yi,
					aabb.position.z + aabb.size.z * zi
				)
				var transformed: Vector3 = basis * corner
				min_y = minf(min_y, transformed.y)
				max_y = maxf(max_y, transformed.y)
	if min_y == INF or max_y == -INF:
		return Vector2.ZERO
	return Vector2(min_y, max_y)

func _runtime_model_path_for_unit(unit: Dictionary, unit_type: String) -> String:
	var explicit_path: String = String(unit.get("model_path", "")).strip_edges()
	if not explicit_path.is_empty():
		return explicit_path
	if _is_convoy_node(unit):
		return _model_path_by_key(["supply_convoy", "convoy", unit_type])
	if _is_granary_node(unit):
		if _is_advanced_granary_unit(unit):
			return _model_path_by_key(["granary_advanced", "junliangbao", "granary"])
		return _model_path_by_key(["granary"])
	return _model_path_by_key([unit_type])

func _runtime_model_scale_for_unit(unit: Dictionary, unit_type: String) -> float:
	if _is_convoy_node(unit):
		return _model_scale_by_key(["supply_convoy", "convoy", unit_type], 116.0)
	if _is_granary_node(unit):
		if _is_advanced_granary_unit(unit):
			return _model_scale_by_key(["granary_advanced", "granary"], 126.0) * FACILITY_MODEL_SCALE_MUL
		return _model_scale_by_key(["granary"], 122.0) * FACILITY_MODEL_SCALE_MUL
	var base_scale: float = _model_scale_by_key([unit_type], 1.0)
	if _is_runtime_constructed_facility_type(unit_type):
		return base_scale * FACILITY_MODEL_SCALE_MUL
	return base_scale

func _is_advanced_granary_unit(unit: Dictionary) -> bool:
	if bool(unit.get("is_advanced_granary", false)) or bool(unit.get("is_advanced", false)):
		return true
	var level_value: int = int(unit.get("level", unit.get("tier", 0)))
	if level_value >= 2:
		return true
	var identity: String = _supply_identity_text(unit).to_lower()
	for keyword_any in ADVANCED_GRANARY_KEYWORDS:
		var keyword: String = String(keyword_any).to_lower().strip_edges()
		if not keyword.is_empty() and identity.find(keyword) != -1:
			return true
	return false

func _model_path_by_key(keys: Array, fallback: String = "") -> String:
	for key_any in keys:
		var key: String = String(key_any).to_lower().strip_edges()
		if key.is_empty():
			continue
		var value: String = String(_runtime_model_paths.get(key, "")).strip_edges()
		if not value.is_empty():
			return value
	return fallback

func _model_scale_by_key(keys: Array, fallback: float) -> float:
	for key_any in keys:
		var key: String = String(key_any).to_lower().strip_edges()
		if key.is_empty():
			continue
		if _runtime_model_scales.has(key):
			return maxf(0.001, float(_runtime_model_scales.get(key, fallback)))
	return maxf(0.001, fallback)

func _load_runtime_model_scene(model_path: String) -> PackedScene:
	var clean_path: String = model_path.strip_edges()
	if clean_path.is_empty():
		return null
	if _runtime_model_scene_cache.has(clean_path):
		var cached: Variant = _runtime_model_scene_cache.get(clean_path)
		return cached as PackedScene if cached is PackedScene else null
	var loaded: PackedScene = load(clean_path) as PackedScene
	_runtime_model_scene_cache[clean_path] = loaded
	if loaded == null and not _runtime_model_warned_missing.has(clean_path):
		_runtime_model_warned_missing[clean_path] = true
		push_warning("ChinaTerrain30km dynamic model load failed: %s" % clean_path)
	return loaded

func _clear_runtime_model_root(model_root: Node3D) -> void:
	if model_root == null:
		return
	for child in model_root.get_children():
		if child is Node:
			(child as Node).queue_free()

func _runtime_unit_marker_height(unit_type: String) -> float:
	match unit_type:
		"field_unit":
			return 120.0
		"granary":
			return 95.0
		"convoy", "supply_convoy", "transport":
			return 100.0
		"chengzhai":
			return 112.0
		"zhalan":
			return 26.0
		"muzhai", "jianlou", "gaojijianlou", "taigutai", "junyuetai":
			return 92.0
		_:
			return 88.0

func _runtime_unit_marker_radius(unit_type: String) -> float:
	match unit_type:
		"field_unit":
			return 75.0
		"granary":
			return 70.0
		"convoy", "supply_convoy", "transport":
			return 72.0
		"chengzhai":
			return 82.0
		"zhalan":
			return ZHALAN_POST_BLOCK_RADIUS
		"muzhai", "jianlou", "gaojijianlou", "taigutai", "junyuetai":
			return 68.0
		_:
			return 64.0

func _runtime_unit_marker_mesh(unit_type: String, radius: float, height: float) -> Mesh:
	match unit_type:
		"granary":
			var box := BoxMesh.new()
			box.size = Vector3(radius * 2.0, height, radius * 1.7)
			return box
		"convoy", "supply_convoy", "transport":
			var capsule := CapsuleMesh.new()
			capsule.radius = radius
			capsule.height = height
			return capsule
		_:
			var cyl := CylinderMesh.new()
			cyl.top_radius = radius
			cyl.bottom_radius = radius
			cyl.height = height
			return cyl

func _runtime_unit_collision_shape(unit_type: String, radius: float, height: float) -> Shape3D:
	match unit_type:
		"zhalan":
			var post := CylinderShape3D.new()
			post.radius = maxf(1.8, radius)
			post.height = maxf(ZHALAN_POST_COLLISION_HEIGHT, height)
			return post
		"chengzhai":
			var fort := BoxShape3D.new()
			fort.size = Vector3(radius * 2.6, maxf(40.0, height), radius * 2.2)
			return fort
		_:
			var sphere := SphereShape3D.new()
			sphere.radius = radius
			return sphere

func _runtime_unit_marker_material(unit: Dictionary) -> StandardMaterial3D:
	var faction_id: String = String(unit.get("faction_id", "")).strip_edges()
	var player_faction: String = _get_player_faction_id()
	var unit_type: String = String(unit.get("type", "")).to_lower()
	var mat := StandardMaterial3D.new()
	if unit_type == "granary":
		mat.albedo_color = Color(0.89, 0.73, 0.28, 0.96)
	elif faction_id.is_empty():
		mat.albedo_color = Color(0.78, 0.78, 0.78, 0.96)
	elif faction_id == player_faction:
		mat.albedo_color = Color(0.92, 0.34, 0.23, 0.96)
	else:
		mat.albedo_color = Color(0.25, 0.58, 0.93, 0.96)
	mat.roughness = 0.45
	mat.metallic = 0.08
	return mat

func _get_runtime_unit_snapshot(site_id: String) -> Dictionary:
	if not _runtime_unit_snapshots.has(site_id):
		return {}
	var snap_any: Variant = _runtime_unit_snapshots.get(site_id, {})
	return (snap_any as Dictionary).duplicate(true) if snap_any is Dictionary else {}

func _get_player_faction_id() -> String:
	return String(_world_state_cache.get("meta", {}).get("player_faction_id", "")).strip_edges()

func _build_supply_fog_rules(raw_rules: Dictionary) -> Dictionary:
	var out: Dictionary = {
		"enabled": true,
		"base_range_default": 1600.0,
		"base_range_by_type": {
			"city": 1000.0,
			"pass": 2100.0,
			"fort": 2000.0,
			"ferry": 2400.0,
			"resource": 1800.0,
			"field_unit": 500.0,
			"granary": 1800.0,
			"convoy": 900.0,
			"supply_convoy": 900.0,
			"transport": 900.0,
			"site": 1400.0,
			"muzhai": 1300.0,
			"chengzhai": 1600.0,
			"jianlou": 1550.0,
			"gaojijianlou": 1850.0,
			"zhalan": 560.0,
			"taigutai": 1100.0,
			"junyuetai": 1300.0
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
	out["base_range_default"] = maxf(120.0, float(raw_rules.get("base_range_default", out.get("base_range_default", 1600.0))))
	out["granary_range_bonus"] = maxf(0.0, float(raw_rules.get("granary_range_bonus", out.get("granary_range_bonus", 1300.0))))
	out["convoy_range_bonus"] = maxf(0.0, float(raw_rules.get("convoy_range_bonus", out.get("convoy_range_bonus", 1700.0))))
	out["link_distance_mul"] = maxf(0.1, float(raw_rules.get("link_distance_mul", out.get("link_distance_mul", 1.0))))
	out["link_distance_max"] = maxf(120.0, float(raw_rules.get("link_distance_max", out.get("link_distance_max", 7000.0))))
	out["enemy_reveal_range_mul"] = maxf(0.1, float(raw_rules.get("enemy_reveal_range_mul", out.get("enemy_reveal_range_mul", 1.0))))
	out["enemy_reveal_padding"] = maxf(0.0, float(raw_rules.get("enemy_reveal_padding", out.get("enemy_reveal_padding", 280.0))))
	out["enemy_reveal_min_distance"] = maxf(0.0, float(raw_rules.get("enemy_reveal_min_distance", out.get("enemy_reveal_min_distance", 680.0))))
	var by_type_any: Variant = out.get("base_range_by_type", {})
	var by_type: Dictionary = by_type_any as Dictionary if by_type_any is Dictionary else {}
	var raw_by_type: Variant = raw_rules.get("base_range_by_type", {})
	if raw_by_type is Dictionary:
		for key_any in (raw_by_type as Dictionary).keys():
			var key: String = String(key_any).to_lower().strip_edges()
			by_type[key] = maxf(120.0, float((raw_by_type as Dictionary).get(key_any, by_type.get(key, out.get("base_range_default", 1600.0)))))
	out["base_range_by_type"] = by_type
	return out

func _build_supply_fog_snapshot() -> Dictionary:
	var out: Dictionary = {
		"enabled": false,
		"site_visible": {},
		"reveal_centers": [],
		"in_supply_site_ids": [],
		"in_supply_by_faction": {},
		"supply_regions_by_faction": {},
		"supply_edges": []
	}
	if not _runtime_supply_fog_enabled:
		return out
	var rules_raw: Dictionary = _engine_rules_cache.get("supply_fog_rules", {})
	var rules: Dictionary = _build_supply_fog_rules(rules_raw)
	if not bool(rules.get("enabled", true)):
		return out
	var nodes_by_id: Dictionary = {}
	for node_any in _collect_supply_nodes():
		if not (node_any is Dictionary):
			continue
		var node: Dictionary = _normalize_supply_node(node_any as Dictionary)
		if node.is_empty():
			continue
		nodes_by_id[String(node.get("id", ""))] = node
	if nodes_by_id.is_empty():
		return out

	var node_ids: Array[String] = []
	var node_pos: Dictionary = {}
	var node_faction: Dictionary = {}
	var node_range: Dictionary = {}
	var node_region: Dictionary = {}
	var faction_nodes: Dictionary = {}
	var owned_regions_by_faction: Dictionary = {}
	var edges: Array = []
	for node_id_any in nodes_by_id.keys():
		var node_id: String = String(node_id_any)
		var node: Dictionary = nodes_by_id[node_id] as Dictionary
		var pos := _node_pos2(node)
		var faction_id: String = String(node.get("faction_id", ""))
		var region_id: String = get_region_id_at_world(Vector3(pos.x, 0.0, pos.y)).strip_edges()
		node_ids.append(node_id)
		node_pos[node_id] = pos
		node_faction[node_id] = faction_id
		node_range[node_id] = _supply_range_for_node(node, rules)
		node_region[node_id] = region_id
		if not faction_id.is_empty():
			var items: Array = faction_nodes.get(faction_id, [])
			items.append(node_id)
			faction_nodes[faction_id] = items
			if not region_id.is_empty() and not _is_troop_node(node) and not _is_convoy_node(node):
				var region_flags_any: Variant = owned_regions_by_faction.get(faction_id, {})
				var region_flags: Dictionary = region_flags_any as Dictionary if region_flags_any is Dictionary else {}
				region_flags[region_id] = true
				owned_regions_by_faction[faction_id] = region_flags

	var adjacency: Dictionary = {}
	for node_id in node_ids:
		adjacency[node_id] = []
	var link_mul: float = maxf(0.1, float(rules.get("link_distance_mul", 1.0)))
	var link_max: float = maxf(120.0, float(rules.get("link_distance_max", 7000.0)))
	var cell_size: float = maxf(380.0, minf(link_max, link_max * 0.58))
	var cell_span: int = maxi(1, int(ceil(link_max / cell_size)))
	for faction_any in faction_nodes.keys():
		var faction_id: String = String(faction_any)
		var faction_ids_any: Variant = faction_nodes.get(faction_id, [])
		if not (faction_ids_any is Array):
			continue
		var faction_ids: Array = faction_ids_any as Array
		if faction_ids.size() <= 1:
			continue
		var id_index: Dictionary = {}
		var cell_lookup: Dictionary = {}
		var cell_members: Dictionary = {}
		for idx in range(faction_ids.size()):
			var sid: String = String(faction_ids[idx])
			id_index[sid] = idx
			var pos_seed: Vector2 = node_pos.get(sid, Vector2.ZERO)
			var cx: int = int(floor(pos_seed.x / cell_size))
			var cz: int = int(floor(pos_seed.y / cell_size))
			var key: String = "%d:%d" % [cx, cz]
			cell_lookup[sid] = key
			var list_any: Variant = cell_members.get(key, [])
			var list: Array = list_any as Array if list_any is Array else []
			list.append(sid)
			cell_members[key] = list
		for sid_any in faction_ids:
			var id_a: String = String(sid_any)
			var pos_a: Vector2 = node_pos.get(id_a, Vector2.ZERO)
			var range_a: float = float(node_range.get(id_a, 0.0))
			var key_a: String = String(cell_lookup.get(id_a, ""))
			if key_a.is_empty():
				continue
			var key_parts: PackedStringArray = key_a.split(":")
			if key_parts.size() < 2:
				continue
			var cell_x: int = int(key_parts[0])
			var cell_z: int = int(key_parts[1])
			var idx_a: int = int(id_index.get(id_a, -1))
			if idx_a < 0:
				continue
			for ox in range(-cell_span, cell_span + 1):
				for oz in range(-cell_span, cell_span + 1):
					var key_n: String = "%d:%d" % [cell_x + ox, cell_z + oz]
					var bucket_any: Variant = cell_members.get(key_n, [])
					if not (bucket_any is Array):
						continue
					for bid_any in (bucket_any as Array):
						var id_b: String = String(bid_any)
						var idx_b: int = int(id_index.get(id_b, -1))
						if idx_b <= idx_a:
							continue
						var node_a: Dictionary = nodes_by_id.get(id_a, {}) as Dictionary
						var node_b: Dictionary = nodes_by_id.get(id_b, {}) as Dictionary
						if not _can_supply_nodes_link(node_a, node_b):
							continue
						var pos_b: Vector2 = node_pos.get(id_b, Vector2.ZERO)
						var range_b: float = float(node_range.get(id_b, 0.0))
						var link_distance: float = minf(link_max, (range_a + range_b) * link_mul)
						if pos_a.distance_to(pos_b) > link_distance:
							continue
						var aa: Array = adjacency.get(id_a, [])
						aa.append(id_b)
						adjacency[id_a] = aa
						var bb: Array = adjacency.get(id_b, [])
						bb.append(id_a)
						adjacency[id_b] = bb
						edges.append({"a": id_a, "b": id_b, "faction_id": faction_id})

	var in_supply_flags: Dictionary = {}
	var in_supply_by_faction: Dictionary = {}
	var supply_regions_by_faction: Dictionary = {}
	for faction_any in faction_nodes.keys():
		var faction_id: String = String(faction_any)
		var ids: Array = faction_nodes.get(faction_id, [])
		var sources: Array = []
		for id_any in ids:
			var node_id: String = String(id_any)
			var node: Dictionary = nodes_by_id.get(node_id, {}) as Dictionary
			if _is_supply_source_node(node):
				sources.append(node_id)
		var has_valid_source: bool = not sources.is_empty()
		if sources.is_empty() and not ids.is_empty():
			sources.append(String(ids[0]))
		var visited: Dictionary = {}
		var stack: Array = sources.duplicate(true)
		while not stack.is_empty():
			var current: String = String(stack.pop_back())
			if current.is_empty() or visited.has(current):
				continue
			visited[current] = true
			in_supply_flags[current] = true
			var next_ids: Array = adjacency.get(current, [])
			for next_any in next_ids:
				var next_id: String = String(next_any)
				if not visited.has(next_id):
					stack.append(next_id)
		var owned_regions_any: Variant = owned_regions_by_faction.get(faction_id, {})
		var owned_regions: Dictionary = owned_regions_any as Dictionary if owned_regions_any is Dictionary else {}
		var region_ids: Array = owned_regions.keys()
		supply_regions_by_faction[faction_id] = region_ids
		if _supply_region_mode_enabled and has_valid_source and not owned_regions.is_empty():
			for id_any in ids:
				var node_id: String = String(id_any)
				var region_id: String = String(node_region.get(node_id, "")).strip_edges()
				if region_id.is_empty() or not owned_regions.has(region_id):
					continue
				visited[node_id] = true
				in_supply_flags[node_id] = true
		in_supply_by_faction[faction_id] = visited.keys()
	var in_supply_site_ids: Array = []
	for node_id_any in in_supply_flags.keys():
		in_supply_site_ids.append(String(node_id_any))

	var player_faction: String = _get_player_faction_id()
	var reveal_centers_static: Array = []
	var reveal_centers_mobile: Array = []
	var player_ids: Array = faction_nodes.get(player_faction, [])
	var visibility_mul: float = clampf(float(_runtime_time_weather.get("visibility_mul", 1.0)), 0.15, 2.0)
	for node_id_any in player_ids:
		var node_id: String = String(node_id_any)
		var node: Dictionary = nodes_by_id.get(node_id, {}) as Dictionary
		if not _is_player_vision_source_node(node):
			continue
		var pos: Vector2 = node_pos.get(node_id, Vector2.ZERO)
		var center := {
			"x": pos.x,
			"z": pos.y,
			"range": maxf(120.0, float(node_range.get(node_id, 0.0)) * visibility_mul)
		}
		if _is_troop_node(node) or _is_convoy_node(node):
			reveal_centers_mobile.append(center)
		else:
			reveal_centers_static.append(center)
	var reveal_centers: Array = reveal_centers_static.duplicate(true)
	reveal_centers.append_array(_budgeted_mobile_reveal_centers(reveal_centers_mobile))
	var reveal_mul: float = maxf(0.1, float(rules.get("enemy_reveal_range_mul", 1.0)))
	var reveal_padding: float = maxf(0.0, float(rules.get("enemy_reveal_padding", 280.0)))
	var reveal_min: float = maxf(0.0, float(rules.get("enemy_reveal_min_distance", 680.0)) * visibility_mul)
	var out_visible: Dictionary = {}
	for node_id_any in node_ids:
		var node_id: String = String(node_id_any)
		var node: Dictionary = nodes_by_id.get(node_id, {}) as Dictionary
		var faction_id: String = String(node.get("faction_id", ""))
		var enemy: bool = not faction_id.is_empty() and faction_id != player_faction
		var hidden_by_fog: bool = enemy and (_is_granary_node(node) or _is_convoy_node(node) or _is_troop_node(node))
		if not hidden_by_fog:
			out_visible[node_id] = true
			continue
		var p: Vector2 = node_pos.get(node_id, Vector2.ZERO)
		out_visible[node_id] = _is_revealed_point(p, reveal_centers, reveal_mul, reveal_padding, reveal_min)
	out["enabled"] = true
	out["site_visible"] = out_visible
	out["reveal_centers"] = reveal_centers
	out["in_supply_site_ids"] = in_supply_site_ids
	out["in_supply_by_faction"] = in_supply_by_faction
	out["supply_regions_by_faction"] = supply_regions_by_faction
	out["supply_edges"] = edges
	out["vision_context"] = {
		"day_phase": String(_runtime_time_weather.get("day_phase", "day")),
		"weather_state": String(_runtime_time_weather.get("weather_state", "sunny")),
		"visibility_mul": visibility_mul
	}
	return out

func _collect_supply_nodes() -> Array:
	var out: Array = []
	for unit_any in _runtime_dynamic_units_from_world_state():
		var unit: Dictionary = (unit_any as Dictionary).duplicate(true)
		if bool(unit.get("is_under_construction", false)) or bool(unit.get("awaiting_builder_arrival", false)):
			continue
		var unit_id: String = String(unit.get("id", "")).strip_edges()
		var unit_type: String = String(unit.get("type", "")).to_lower().strip_edges()
		if not unit_id.is_empty() and _is_runtime_mobile_unit_type(unit_type):
			var mobile: Dictionary = _runtime_mobile_unit_snapshot(unit_id)
			if not mobile.is_empty():
				out.append(mobile)
				continue
		out.append(unit)
	for city_any in _collect_city_supply_nodes():
		out.append((city_any as Dictionary).duplicate(true))
	for site_any in _collect_scene_site_supply_nodes():
		out.append((site_any as Dictionary).duplicate(true))
	return out

func _collect_city_supply_nodes() -> Array:
	var out: Array = []
	if _city_overlay == null:
		return out
	var city_root: Node = _city_overlay.get_node_or_null("CityInstances")
	if city_root == null:
		return out
	for child in city_root.get_children():
		if not (child is Node3D):
			continue
		var city_node := child as Node3D
		var city_name: String = String(city_node.get_meta("city_name", city_node.name.trim_prefix("City_"))).strip_edges()
		if city_name.is_empty():
			continue
		var world_city: Dictionary = _resolve_world_city(city_name, city_name)
		var city_resources_any: Variant = world_city.get("resources", {})
		var city_resources: Dictionary = city_resources_any as Dictionary if city_resources_any is Dictionary else {}
		var city_id: String = String(world_city.get("id", city_name)).strip_edges()
		if city_id.is_empty():
			city_id = city_name
		var faction_id: String = String(world_city.get("faction_id", "")).strip_edges()
		# Unassigned cities remain visible as map objects, but should not affect supply/fog.
		if faction_id.is_empty():
			continue
		out.append({
			"id": city_id,
			"city_id": city_id,
			"name": String(world_city.get("name", city_name)),
			"type": "city",
			"faction_id": faction_id,
			"is_supply_source": true,
			"resources": city_resources.duplicate(true),
			"position": {
				"x": float(city_node.global_position.x),
				"z": float(city_node.global_position.z)
			}
		})
	return out

func _collect_scene_site_supply_nodes() -> Array:
	var out: Array = []
	if _strategic_site_manager == null:
		return out
	var site_lookup: Dictionary = {}
	if _strategic_site_manager.has_method("get_all_site_snapshots"):
		var defs_any: Variant = _strategic_site_manager.call("get_all_site_snapshots")
		if defs_any is Array:
			for def_any in (defs_any as Array):
				if not (def_any is Dictionary):
					continue
				var def: Dictionary = (def_any as Dictionary)
				var site_id: String = String(def.get("id", "")).strip_edges()
				if not site_id.is_empty():
					site_lookup[site_id] = def
	var root: Node = _strategic_site_manager.get_node_or_null("SiteInstances")
	if root == null:
		return out
	for child in root.get_children():
		if not (child is Node3D):
			continue
		var node := child as Node3D
		var site_id: String = String(node.get_meta("building_id", "")).strip_edges()
		if site_id.is_empty():
			var node_name: String = String(node.name)
			if node_name.begins_with("Site_"):
				site_id = node_name.trim_prefix("Site_")
		if site_id.is_empty():
			continue
		var snapshot: Dictionary = site_lookup.get(site_id, {}) as Dictionary
		var site_type: String = String(node.get_meta("building_type", snapshot.get("type", "site"))).to_lower().strip_edges()
		var site_name: String = String(node.get_meta("site_name", snapshot.get("name", site_id))).strip_edges()
		var world_site: Dictionary = _resolve_world_building(site_id, site_name)
		var site_resources_any: Variant = world_site.get("resources", snapshot.get("resources", {}))
		var site_resources: Dictionary = site_resources_any as Dictionary if site_resources_any is Dictionary else {}
		var faction_id: String = String(world_site.get("faction_id", "")).strip_edges()
		if faction_id.is_empty() and _supply_use_scene_faction_fallback:
			faction_id = String(snapshot.get("faction_id", "")).strip_edges()
		# Keep neutral scene sites visible in scene, but exclude from supply graph.
		if faction_id.is_empty():
			continue
		out.append({
			"id": site_id,
			"city_id": String(snapshot.get("city_id", site_id)),
			"name": site_name if not site_name.is_empty() else site_id,
			"type": site_type if not site_type.is_empty() else "site",
			"faction_id": faction_id,
			"resources": site_resources.duplicate(true),
			"position": {
				"x": float(node.global_position.x),
				"z": float(node.global_position.z)
			}
		})
	return out

func _normalize_supply_node(raw: Dictionary) -> Dictionary:
	if raw.is_empty():
		return {}
	var node: Dictionary = raw.duplicate(true)
	var node_id: String = String(node.get("id", node.get("city_id", ""))).strip_edges()
	if node_id.is_empty():
		return {}
	var pos_any: Variant = node.get("position", {})
	var pos: Dictionary = pos_any as Dictionary if pos_any is Dictionary else {}
	node["id"] = node_id
	node["name"] = String(node.get("name", node_id))
	node["type"] = String(node.get("type", "site")).to_lower()
	node["faction_id"] = String(node.get("faction_id", ""))
	node["position"] = {"x": float(pos.get("x", 0.0)), "z": float(pos.get("z", 0.0))}
	return node

func _node_pos2(node: Dictionary) -> Vector2:
	var pos_any: Variant = node.get("position", {})
	if not (pos_any is Dictionary):
		return Vector2.ZERO
	var pos: Dictionary = pos_any as Dictionary
	return Vector2(float(pos.get("x", 0.0)), float(pos.get("z", 0.0)))

func _supply_range_for_node(node: Dictionary, rules: Dictionary) -> float:
	var by_type_any: Variant = rules.get("base_range_by_type", {})
	var by_type: Dictionary = by_type_any as Dictionary if by_type_any is Dictionary else {}
	var type_key: String = String(node.get("type", "site")).to_lower()
	var base_range: float = float(by_type.get(type_key, rules.get("base_range_default", 2200.0)))
	if _is_granary_node(node):
		base_range += float(rules.get("granary_range_bonus", 1300.0))
	if _is_convoy_node(node):
		base_range += float(rules.get("convoy_range_bonus", 1700.0))
	return maxf(120.0, base_range)

func _node_food_amount(node: Dictionary) -> float:
	if node.is_empty():
		return -1.0
	var resources_any: Variant = node.get("resources", {})
	if resources_any is Dictionary:
		var resources: Dictionary = resources_any as Dictionary
		if resources.has("food"):
			return float(resources.get("food", 0.0))
		if resources.has("grain"):
			return float(resources.get("grain", 0.0))
		if resources.has("supply_food"):
			return float(resources.get("supply_food", 0.0))
	var stats_any: Variant = node.get("stats", {})
	if stats_any is Dictionary:
		var stats: Dictionary = stats_any as Dictionary
		if stats.has("food"):
			return float(stats.get("food", 0.0))
	return -1.0

func _supply_source_has_food(node: Dictionary) -> bool:
	var food: float = _node_food_amount(node)
	if food < 0.0:
		return true
	return food > 0.5

func _is_supply_source_node(node: Dictionary) -> bool:
	var source_flag: bool = bool(node.get("is_supply_source", false))
	if not source_flag:
		source_flag = String(node.get("type", "")).to_lower() == "city"
	if not source_flag:
		return false
	return _supply_source_has_food(node)

func _supply_identity_text(node: Dictionary) -> String:
	return "%s|%s|%s" % [
		String(node.get("id", "")),
		String(node.get("name", "")),
		String(node.get("type", ""))
	]

func _contains_keyword(source: String, keywords: Array) -> bool:
	var text: String = source.to_lower()
	for keyword_any in keywords:
		var keyword: String = String(keyword_any).to_lower().strip_edges()
		if not keyword.is_empty() and text.find(keyword) != -1:
			return true
	return false

func _is_granary_node(node: Dictionary) -> bool:
	if bool(node.get("is_granary", false)):
		return true
	var type_key: String = String(node.get("type", "")).to_lower()
	if type_key == "granary" or type_key == "grain_depot" or type_key == "supply_depot":
		return true
	return _contains_keyword(_supply_identity_text(node), SUPPLY_FOG_GRANARY_KEYWORDS)

func _is_convoy_node(node: Dictionary) -> bool:
	if bool(node.get("is_supply_convoy", false)):
		return true
	var type_key: String = String(node.get("type", "")).to_lower()
	if type_key == "convoy" or type_key == "supply_convoy" or type_key == "transport":
		return true
	return _contains_keyword(_supply_identity_text(node), SUPPLY_FOG_CONVOY_KEYWORDS)

func _is_troop_node(node: Dictionary) -> bool:
	if bool(node.get("is_field_troop", false)):
		return true
	var type_key: String = String(node.get("type", "")).to_lower()
	if type_key == "army" or type_key == "troop" or type_key == "field_unit":
		return true
	return _contains_keyword(_supply_identity_text(node), SUPPLY_FOG_TROOP_KEYWORDS)

func _is_supply_backbone_node(node: Dictionary) -> bool:
	if node.is_empty():
		return false
	if _is_supply_source_node(node):
		return true
	if _is_granary_node(node):
		return true
	if _is_convoy_node(node):
		return true
	return false

func _can_supply_nodes_link(node_a: Dictionary, node_b: Dictionary) -> bool:
	if node_a.is_empty() or node_b.is_empty():
		return false
	var convoy_a: bool = _is_convoy_node(node_a)
	var convoy_b: bool = _is_convoy_node(node_b)
	var troop_a: bool = _is_troop_node(node_a)
	var troop_b: bool = _is_troop_node(node_b)
	if troop_a and troop_b:
		return false
	if troop_a or troop_b:
		return convoy_a or convoy_b
	if not _is_supply_backbone_node(node_a):
		return false
	if not _is_supply_backbone_node(node_b):
		return false
	return true

func _is_player_vision_source_node(node: Dictionary) -> bool:
	if node.is_empty():
		return false
	if _is_troop_node(node):
		return true
	var type_key: String = String(node.get("type", "")).to_lower().strip_edges()
	if type_key == "city" or type_key == "pass" or type_key == "fort" or type_key == "ferry" or type_key == "resource" or type_key == "site" or type_key == "stronghold" or type_key == "outpost":
		return true
	return false

func _is_revealed_point(point: Vector2, reveal_centers: Array, reveal_mul: float, reveal_padding: float, reveal_min: float) -> bool:
	for center_any in reveal_centers:
		if not (center_any is Dictionary):
			continue
		var center: Dictionary = center_any as Dictionary
		var center_pos := Vector2(float(center.get("x", 0.0)), float(center.get("z", 0.0)))
		var radius: float = maxf(reveal_min, float(center.get("range", 0.0)) * reveal_mul + reveal_padding)
		if point.distance_to(center_pos) <= radius:
			return true
	return false

func _sort_reveal_center_distance(a: Dictionary, b: Dictionary) -> bool:
	return float(a.get("d2", INF)) < float(b.get("d2", INF))

func _budgeted_mobile_reveal_centers(mobile_centers: Array) -> Array:
	if mobile_centers.is_empty():
		return []
	var cap: int = _supply_fog_reveal_center_cap_current
	if cap <= 0 or mobile_centers.size() <= cap:
		return mobile_centers.duplicate(true)
	var camera_pos := Vector2.ZERO
	if _camera != null and is_instance_valid(_camera):
		camera_pos = Vector2(_camera.global_position.x, _camera.global_position.z)
	var scored: Array = []
	for center_any in mobile_centers:
		if not (center_any is Dictionary):
			continue
		var center: Dictionary = center_any as Dictionary
		var cx: float = float(center.get("x", 0.0))
		var cz: float = float(center.get("z", 0.0))
		var d2: float = camera_pos.distance_squared_to(Vector2(cx, cz))
		scored.append({"center": center, "d2": d2})
	if scored.size() <= cap:
		return mobile_centers.duplicate(true)
	scored.sort_custom(Callable(self, "_sort_reveal_center_distance"))
	var out: Array = []
	for i in range(mini(cap, scored.size())):
		var row_any: Variant = scored[i]
		if not (row_any is Dictionary):
			continue
		var row: Dictionary = row_any as Dictionary
		var center_out_any: Variant = row.get("center", {})
		if center_out_any is Dictionary:
			out.append((center_out_any as Dictionary).duplicate(true))
	return out

func _ensure_runtime_fog_overlay() -> void:
	if _runtime_fog_overlay_mesh != null and is_instance_valid(_runtime_fog_overlay_mesh):
		return
	var parent: Node = _terrain if _terrain != null and is_instance_valid(_terrain) else self
	if parent == null:
		return
	var existing: Node = parent.get_node_or_null("RuntimeFogOfWarOverlay")
	if existing is MeshInstance3D:
		_runtime_fog_overlay_mesh = existing as MeshInstance3D
	else:
		_runtime_fog_overlay_mesh = MeshInstance3D.new()
		_runtime_fog_overlay_mesh.name = "RuntimeFogOfWarOverlay"
		parent.add_child(_runtime_fog_overlay_mesh)
	var plane := PlaneMesh.new()
	plane.size = Vector2(RUNTIME_MAP_PLANE_SIZE, RUNTIME_MAP_PLANE_SIZE)
	_runtime_fog_overlay_mesh.mesh = plane
	_runtime_fog_overlay_mesh.position = Vector3.ZERO
	_runtime_fog_overlay_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var shader: Shader = load(FOG_OF_WAR_OVERLAY_SHADER_PATH)
	if shader != null:
		if _runtime_fog_overlay_material == null:
			_runtime_fog_overlay_material = ShaderMaterial.new()
		_runtime_fog_overlay_material.shader = shader
		_runtime_fog_overlay_material.set_shader_parameter("u_map_size_x", RUNTIME_MAP_PLANE_SIZE)
		_runtime_fog_overlay_material.set_shader_parameter("u_map_size_z", RUNTIME_MAP_PLANE_SIZE)
		_runtime_fog_overlay_material.set_shader_parameter("u_center_count", 0)
		_runtime_fog_overlay_material.set_shader_parameter("u_dark_alpha", 0.42)
		_runtime_fog_overlay_material.set_shader_parameter("u_dark_color", Color(0.04, 0.06, 0.08, 1.0))
		_runtime_fog_overlay_mesh.material_override = _runtime_fog_overlay_material
	else:
		var fallback := StandardMaterial3D.new()
		fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fallback.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fallback.no_depth_test = true
		fallback.albedo_color = Color(0.02, 0.02, 0.02, 0.42)
		_runtime_fog_overlay_mesh.material_override = fallback
		_runtime_fog_overlay_material = null
	_runtime_fog_overlay_mesh.visible = false

func _refresh_runtime_fog_overlay() -> void:
	if _runtime_fog_overlay_mesh == null or not is_instance_valid(_runtime_fog_overlay_mesh):
		return
	var enabled: bool = _runtime_supply_fog_enabled and bool(_supply_fog_snapshot.get("enabled", false))
	var hide_for_overview: bool = false
	if _camera != null and _camera.has_method("get_current_lod_level") and _camera.has_method("get_total_lod_levels"):
		var level: int = int(_camera.call("get_current_lod_level"))
		var total_levels: int = int(_camera.call("get_total_lod_levels"))
		hide_for_overview = total_levels > 0 and level >= total_levels
	_runtime_fog_overlay_mesh.visible = enabled and not hide_for_overview
	if not _runtime_fog_overlay_mesh.visible:
		return
	if _runtime_fog_overlay_material == null:
		return
	var reveal_any: Variant = _supply_fog_snapshot.get("reveal_centers", [])
	var reveal_centers: Array = reveal_any as Array if reveal_any is Array else []
	var packed := PackedVector4Array()
	var center_count: int = mini(FOG_OF_WAR_MAX_CENTERS, reveal_centers.size())
	for i in range(center_count):
		var center_any: Variant = reveal_centers[i]
		if center_any is Dictionary:
			var center: Dictionary = center_any as Dictionary
			packed.append(Vector4(float(center.get("x", 0.0)), float(center.get("z", 0.0)), maxf(1.0, float(center.get("range", 1.0))), 0.0))
		else:
			packed.append(Vector4(0.0, 0.0, -1.0, 0.0))
	for _i in range(center_count, FOG_OF_WAR_MAX_CENTERS):
		packed.append(Vector4(0.0, 0.0, -1.0, 0.0))
	_runtime_fog_overlay_material.set_shader_parameter("u_center_count", center_count)
	_runtime_fog_overlay_material.set_shader_parameter("u_centers", packed)
	var vision_ctx_any: Variant = _supply_fog_snapshot.get("vision_context", {})
	var vision_ctx: Dictionary = vision_ctx_any as Dictionary if vision_ctx_any is Dictionary else {}
	var day_phase: String = String(vision_ctx.get("day_phase", "day")).to_lower()
	var is_night: bool = day_phase == "night"
	_runtime_fog_overlay_material.set_shader_parameter("u_dark_alpha", 0.42 if not is_night else 0.5)
	_runtime_fog_overlay_material.set_shader_parameter("u_ring_strength", 0.14 if not is_night else 0.18)
	_runtime_fog_overlay_material.set_shader_parameter("u_ring_width", 14.0 if not is_night else 18.0)

func _ensure_supply_route_overlay_root() -> void:
	var node: Node = get_node_or_null("SupplyRouteOverlay")
	if node is Node3D:
		_supply_route_overlay_root = node as Node3D
	else:
		_supply_route_overlay_root = Node3D.new()
		_supply_route_overlay_root.name = "SupplyRouteOverlay"
		add_child(_supply_route_overlay_root)
	var linked_node: Node = _supply_route_overlay_root.get_node_or_null("LinkedEdges")
	if linked_node is MeshInstance3D:
		_supply_route_mesh_linked = linked_node as MeshInstance3D
	else:
		_supply_route_mesh_linked = MeshInstance3D.new()
		_supply_route_mesh_linked.name = "LinkedEdges"
		_supply_route_overlay_root.add_child(_supply_route_mesh_linked)
	var unlinked_node: Node = _supply_route_overlay_root.get_node_or_null("UnlinkedEdges")
	if unlinked_node is MeshInstance3D:
		_supply_route_mesh_unlinked = unlinked_node as MeshInstance3D
	else:
		_supply_route_mesh_unlinked = MeshInstance3D.new()
		_supply_route_mesh_unlinked.name = "UnlinkedEdges"
		_supply_route_overlay_root.add_child(_supply_route_mesh_unlinked)
	var preview_node: Node = _supply_route_overlay_root.get_node_or_null("PreviewLinks")
	if preview_node is MeshInstance3D:
		_supply_route_mesh_preview = preview_node as MeshInstance3D
	else:
		_supply_route_mesh_preview = MeshInstance3D.new()
		_supply_route_mesh_preview.name = "PreviewLinks"
		_supply_route_overlay_root.add_child(_supply_route_mesh_preview)
	if _supply_route_mesh_linked != null and is_instance_valid(_supply_route_mesh_linked):
		var linked_mat := StandardMaterial3D.new()
		linked_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		linked_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		linked_mat.no_depth_test = false
		linked_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		linked_mat.albedo_color = Color(0.22, 0.95, 0.36, 0.9)
		linked_mat.emission_enabled = true
		linked_mat.emission = Color(0.1, 0.5, 0.18)
		linked_mat.emission_energy_multiplier = 1.3
		_supply_route_mesh_linked.material_override = linked_mat
		_supply_route_mesh_linked.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if _supply_route_mesh_unlinked != null and is_instance_valid(_supply_route_mesh_unlinked):
		var unlinked_mat := StandardMaterial3D.new()
		unlinked_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		unlinked_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		unlinked_mat.no_depth_test = false
		unlinked_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		unlinked_mat.albedo_color = Color(0.95, 0.35, 0.3, 0.88)
		unlinked_mat.emission_enabled = true
		unlinked_mat.emission = Color(0.5, 0.14, 0.1)
		unlinked_mat.emission_energy_multiplier = 1.25
		_supply_route_mesh_unlinked.material_override = unlinked_mat
		_supply_route_mesh_unlinked.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if _supply_route_mesh_preview != null and is_instance_valid(_supply_route_mesh_preview):
		var preview_mat := StandardMaterial3D.new()
		preview_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		preview_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		preview_mat.no_depth_test = false
		preview_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		preview_mat.albedo_color = Color(0.92, 0.8, 0.28, 0.92)
		preview_mat.emission_enabled = true
		preview_mat.emission = Color(0.46, 0.36, 0.08)
		preview_mat.emission_energy_multiplier = 1.15
		_supply_route_mesh_preview.material_override = preview_mat
		_supply_route_mesh_preview.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _supply_route_overlay_should_show() -> bool:
	if not _show_supply_route_overlay:
		return false
	if not _runtime_supply_fog_enabled:
		return false
	if not bool(_supply_fog_snapshot.get("enabled", false)):
		return false
	if _camera != null and _camera.has_method("get_current_lod_level") and _camera.has_method("get_total_lod_levels"):
		var level: int = int(_camera.call("get_current_lod_level"))
		var total_levels: int = int(_camera.call("get_total_lod_levels"))
		if total_levels > 0 and level >= total_levels:
			return false
	if _is_supply_route_preview_active():
		return true
	return not _supply_route_focus_site_id.is_empty()

func _is_supply_route_preview_active() -> bool:
	return not _supply_route_preview_action_id.is_empty() and _supply_route_preview_world != Vector3.INF

func _set_supply_route_overlay_visible(visible: bool) -> void:
	if _supply_route_overlay_root == null or not is_instance_valid(_supply_route_overlay_root):
		return
	_supply_route_overlay_root.visible = visible

func _build_supply_node_anchor_map() -> Dictionary:
	var anchors: Dictionary = {}
	for node_any in _collect_supply_nodes():
		if not (node_any is Dictionary):
			continue
		var node: Dictionary = _normalize_supply_node(node_any as Dictionary)
		if node.is_empty():
			continue
		var node_id: String = String(node.get("id", "")).strip_edges()
		if node_id.is_empty():
			continue
		var p2: Vector2 = _node_pos2(node)
		var y: float = terrain_height_at_world(Vector3(p2.x, 0.0, p2.y))
		anchors[node_id] = Vector3(p2.x, y + 18.0, p2.y)
	return anchors

func _build_supply_route_runtime_node_data(rules: Dictionary) -> Dictionary:
	var out_nodes: Dictionary = {}
	var out_ranges: Dictionary = {}
	var out_anchors: Dictionary = {}
	for node_any in _collect_supply_nodes():
		if not (node_any is Dictionary):
			continue
		var node: Dictionary = _normalize_supply_node(node_any as Dictionary)
		if node.is_empty():
			continue
		var node_id: String = String(node.get("id", "")).strip_edges()
		if node_id.is_empty():
			continue
		out_nodes[node_id] = node
		out_ranges[node_id] = _supply_range_for_node(node, rules)
		var p2: Vector2 = _node_pos2(node)
		var y: float = terrain_height_at_world(Vector3(p2.x, 0.0, p2.y))
		out_anchors[node_id] = Vector3(p2.x, y + 18.0, p2.y)
	return {
		"nodes": out_nodes,
		"ranges": out_ranges,
		"anchors": out_anchors
	}

func _collect_supply_edge_component(edges: Array, seed_id: String, faction_id: String) -> Dictionary:
	var out: Dictionary = {}
	if seed_id.is_empty():
		return out
	var adjacency: Dictionary = {}
	for edge_any in edges:
		if not (edge_any is Dictionary):
			continue
		var edge: Dictionary = edge_any as Dictionary
		if not faction_id.is_empty() and String(edge.get("faction_id", "")).strip_edges() != faction_id:
			continue
		var id_a: String = String(edge.get("a", "")).strip_edges()
		var id_b: String = String(edge.get("b", "")).strip_edges()
		if id_a.is_empty() or id_b.is_empty():
			continue
		var list_a_any: Variant = adjacency.get(id_a, [])
		var list_a: Array = list_a_any as Array if list_a_any is Array else []
		list_a.append(id_b)
		adjacency[id_a] = list_a
		var list_b_any: Variant = adjacency.get(id_b, [])
		var list_b: Array = list_b_any as Array if list_b_any is Array else []
		list_b.append(id_a)
		adjacency[id_b] = list_b
	if not adjacency.has(seed_id):
		return out
	var stack: Array = [seed_id]
	while not stack.is_empty():
		var current: String = String(stack.pop_back())
		if current.is_empty() or out.has(current):
			continue
		out[current] = true
		var next_any: Variant = adjacency.get(current, [])
		if not (next_any is Array):
			continue
		for next_id_any in (next_any as Array):
			var next_id: String = String(next_id_any).strip_edges()
			if not next_id.is_empty() and not out.has(next_id):
				stack.append(next_id)
	return out

func _build_supply_ribbon_mesh(segment_points: PackedVector3Array, half_width: float, y_lift: float) -> ArrayMesh:
	if segment_points.size() < 2:
		return null
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var up := Vector3.UP
	var safe_half_width: float = maxf(1.2, half_width)
	var safe_lift: float = maxf(0.0, y_lift)
	for i in range(0, segment_points.size() - 1, 2):
		var p0: Vector3 = segment_points[i]
		var p1: Vector3 = segment_points[i + 1]
		var a := Vector3(p0.x, p0.y + safe_lift, p0.z)
		var b := Vector3(p1.x, p1.y + safe_lift, p1.z)
		var dir: Vector3 = b - a
		dir.y = 0.0
		if dir.length_squared() <= 0.08:
			continue
		dir = dir.normalized()
		var side: Vector3 = up.cross(dir)
		if side.length_squared() <= 0.00001:
			side = Vector3.RIGHT
		side = side.normalized() * safe_half_width
		var v0: Vector3 = a - side
		var v1: Vector3 = a + side
		var v2: Vector3 = b + side
		var v3: Vector3 = b - side
		st.add_vertex(v0)
		st.add_vertex(v1)
		st.add_vertex(v2)
		st.add_vertex(v0)
		st.add_vertex(v2)
		st.add_vertex(v3)
	var mesh: ArrayMesh = st.commit() as ArrayMesh
	return mesh

func _rebuild_supply_route_overlay() -> void:
	_ensure_supply_route_overlay_root()
	if _supply_route_overlay_root == null or not is_instance_valid(_supply_route_overlay_root):
		return
	var show_overlay: bool = _supply_route_overlay_should_show()
	_set_supply_route_overlay_visible(show_overlay)
	if not show_overlay:
		if _supply_route_mesh_linked != null and is_instance_valid(_supply_route_mesh_linked):
			_supply_route_mesh_linked.mesh = null
		if _supply_route_mesh_unlinked != null and is_instance_valid(_supply_route_mesh_unlinked):
			_supply_route_mesh_unlinked.mesh = null
		if _supply_route_mesh_preview != null and is_instance_valid(_supply_route_mesh_preview):
			_supply_route_mesh_preview.mesh = null
		return
	var rules_raw: Dictionary = _engine_rules_cache.get("supply_fog_rules", {})
	var rules: Dictionary = _build_supply_fog_rules(rules_raw)
	var route_data: Dictionary = _build_supply_route_runtime_node_data(rules)
	var anchors_any: Variant = route_data.get("anchors", {})
	var nodes_any: Variant = route_data.get("nodes", {})
	var ranges_any: Variant = route_data.get("ranges", {})
	var anchors: Dictionary = anchors_any as Dictionary if anchors_any is Dictionary else {}
	var nodes_by_id: Dictionary = nodes_any as Dictionary if nodes_any is Dictionary else {}
	var node_ranges: Dictionary = ranges_any as Dictionary if ranges_any is Dictionary else {}
	if anchors.is_empty() or nodes_by_id.is_empty():
		if _supply_route_mesh_linked != null and is_instance_valid(_supply_route_mesh_linked):
			_supply_route_mesh_linked.mesh = null
		if _supply_route_mesh_unlinked != null and is_instance_valid(_supply_route_mesh_unlinked):
			_supply_route_mesh_unlinked.mesh = null
		if _supply_route_mesh_preview != null and is_instance_valid(_supply_route_mesh_preview):
			_supply_route_mesh_preview.mesh = null
		return

	var player_faction: String = _get_player_faction_id()
	var focus_site_id: String = _supply_route_focus_site_id.strip_edges()
	if not focus_site_id.is_empty():
		if not nodes_by_id.has(focus_site_id):
			focus_site_id = ""
		elif not player_faction.is_empty():
			var focus_node: Dictionary = nodes_by_id.get(focus_site_id, {}) as Dictionary
			var focus_faction: String = String(focus_node.get("faction_id", _supply_route_focus_faction_id)).strip_edges()
			if focus_faction != player_faction:
				focus_site_id = ""
	if focus_site_id.is_empty():
		_supply_route_focus_site_id = ""
		_supply_route_focus_faction_id = ""

	var edges_any: Variant = _supply_fog_snapshot.get("supply_edges", [])
	var edges: Array = edges_any as Array if edges_any is Array else []
	var focus_component: Dictionary = {}
	if not focus_site_id.is_empty() and not edges.is_empty():
		focus_component = _collect_supply_edge_component(edges, focus_site_id, player_faction)

	var in_supply_flags: Dictionary = {}
	var by_faction_any: Variant = _supply_fog_snapshot.get("in_supply_by_faction", {})
	if by_faction_any is Dictionary and not player_faction.is_empty():
		var player_supply_any: Variant = (by_faction_any as Dictionary).get(player_faction, [])
		if player_supply_any is Array:
			for id_any in (player_supply_any as Array):
				in_supply_flags[String(id_any)] = true
	if in_supply_flags.is_empty():
		var in_supply_any: Variant = _supply_fog_snapshot.get("in_supply_site_ids", [])
		if in_supply_any is Array:
			for id_any in (in_supply_any as Array):
				in_supply_flags[String(id_any)] = true

	var linked_points := PackedVector3Array()
	var unlinked_points := PackedVector3Array()
	if not focus_site_id.is_empty() and not edges.is_empty():
		for edge_any in edges:
			if not (edge_any is Dictionary):
				continue
			var edge: Dictionary = edge_any as Dictionary
			var edge_faction: String = String(edge.get("faction_id", "")).strip_edges()
			if not player_faction.is_empty() and edge_faction != player_faction:
				continue
			var id_a: String = String(edge.get("a", "")).strip_edges()
			var id_b: String = String(edge.get("b", "")).strip_edges()
			if id_a.is_empty() or id_b.is_empty():
				continue
			if not focus_component.is_empty() and (not focus_component.has(id_a) or not focus_component.has(id_b)):
				continue
			var pa_any: Variant = anchors.get(id_a, null)
			var pb_any: Variant = anchors.get(id_b, null)
			if not (pa_any is Vector3) or not (pb_any is Vector3):
				continue
			var pa: Vector3 = pa_any as Vector3
			var pb: Vector3 = pb_any as Vector3
			if pa.distance_to(pb) < 0.5:
				continue
			var linked: bool = in_supply_flags.has(id_a) and in_supply_flags.has(id_b)
			if linked:
				linked_points.append(pa)
				linked_points.append(pb)
			else:
				unlinked_points.append(pa)
				unlinked_points.append(pb)

	var preview_points := PackedVector3Array()
	if _is_supply_route_preview_active() and _supply_route_preview_action_id == "build_granary":
		var preview_faction: String = _supply_route_preview_faction_id.strip_edges()
		if preview_faction.is_empty():
			preview_faction = player_faction
		if not preview_faction.is_empty():
			var link_mul: float = maxf(0.1, float(rules.get("link_distance_mul", 1.0)))
			var link_max: float = maxf(120.0, float(rules.get("link_distance_max", 7000.0)))
			var preview_pos := Vector2(_supply_route_preview_world.x, _supply_route_preview_world.z)
			var preview_node := {
				"id": "@preview_granary",
				"type": "granary",
				"is_granary": true,
				"faction_id": preview_faction,
				"position": {"x": preview_pos.x, "z": preview_pos.y}
			}
			var preview_range: float = _supply_range_for_node(preview_node, rules)
			var preview_y: float = terrain_height_at_world(Vector3(preview_pos.x, 0.0, preview_pos.y))
			var preview_anchor := Vector3(preview_pos.x, preview_y + 18.0, preview_pos.y)
			for node_id_any in nodes_by_id.keys():
				var node_id: String = String(node_id_any).strip_edges()
				if node_id.is_empty():
					continue
				var node: Dictionary = nodes_by_id.get(node_id, {}) as Dictionary
				if node.is_empty():
					continue
				var faction_id: String = String(node.get("faction_id", "")).strip_edges()
				if faction_id != preview_faction:
					continue
				if not _can_supply_nodes_link(preview_node, node):
					continue
				var anchor_any: Variant = anchors.get(node_id, null)
				if not (anchor_any is Vector3):
					continue
				var node_pos: Vector2 = _node_pos2(node)
				var node_range: float = float(node_ranges.get(node_id, 0.0))
				var link_distance: float = minf(link_max, (preview_range + node_range) * link_mul)
				if preview_pos.distance_to(node_pos) > link_distance:
					continue
				var anchor: Vector3 = anchor_any as Vector3
				if preview_anchor.distance_to(anchor) < 0.5:
					continue
				preview_points.append(preview_anchor)
				preview_points.append(anchor)
	if _supply_route_mesh_linked != null and is_instance_valid(_supply_route_mesh_linked):
		if linked_points.size() >= 2:
			var linked_mesh: ArrayMesh = _build_supply_ribbon_mesh(linked_points, 10.0, 4.5)
			_supply_route_mesh_linked.mesh = linked_mesh
		else:
			_supply_route_mesh_linked.mesh = null
	if _supply_route_mesh_unlinked != null and is_instance_valid(_supply_route_mesh_unlinked):
		if unlinked_points.size() >= 2:
			var unlinked_mesh: ArrayMesh = _build_supply_ribbon_mesh(unlinked_points, 8.0, 4.3)
			_supply_route_mesh_unlinked.mesh = unlinked_mesh
		else:
			_supply_route_mesh_unlinked.mesh = null
	if _supply_route_mesh_preview != null and is_instance_valid(_supply_route_mesh_preview):
		if preview_points.size() >= 2:
			var preview_mesh: ArrayMesh = _build_supply_ribbon_mesh(preview_points, 12.0, 4.8)
			_supply_route_mesh_preview.mesh = preview_mesh
		else:
			_supply_route_mesh_preview.mesh = null

func _ensure_supply_debug_root() -> void:
	var node: Node = get_node_or_null("SupplyDebugLabels")
	if node is Node3D:
		_supply_debug_root = node as Node3D
		return
	_supply_debug_root = Node3D.new()
	_supply_debug_root.name = "SupplyDebugLabels"
	add_child(_supply_debug_root)

func _refresh_supply_debug_overlay() -> void:
	_ensure_supply_debug_root()
	if _supply_debug_root == null:
		return
	var marker_visible: bool = _runtime_unit_root == null or not is_instance_valid(_runtime_unit_root) or _runtime_unit_root.visible
	var mobile_visible: bool = _runtime_mobile_root == null or not is_instance_valid(_runtime_mobile_root) or _runtime_mobile_root.visible
	var allow_world: bool = marker_visible or mobile_visible
	_supply_debug_root.visible = _supply_debug_enabled and allow_world
	if not _supply_debug_enabled:
		return
	var visible_any: Variant = _supply_fog_snapshot.get("site_visible", {})
	var site_visible: Dictionary = visible_any as Dictionary if visible_any is Dictionary else {}
	var vision_ctx_any: Variant = _supply_fog_snapshot.get("vision_context", {})
	var vision_ctx: Dictionary = vision_ctx_any as Dictionary if vision_ctx_any is Dictionary else {}
	var vis_mul_dbg: float = float(vision_ctx.get("visibility_mul", 1.0))
	var day_phase_dbg: String = String(vision_ctx.get("day_phase", "day"))
	var weather_dbg: String = String(vision_ctx.get("weather_state", "sunny"))
	var in_supply_flags: Dictionary = {}
	var in_supply_any: Variant = _supply_fog_snapshot.get("in_supply_site_ids", [])
	if in_supply_any is Array:
		for id_any in (in_supply_any as Array):
			in_supply_flags[String(id_any)] = true
	var keep_labels: Dictionary = {}
	var player_faction: String = _get_player_faction_id()
	var render_nodes: Dictionary = {}
	for id_any in _runtime_unit_nodes.keys():
		render_nodes[String(id_any)] = _runtime_unit_nodes.get(id_any, null)
	for id_any in _runtime_mobile_units.keys():
		render_nodes[String(id_any)] = _runtime_mobile_units.get(id_any, null)
	for site_id_any in render_nodes.keys():
		var site_id: String = String(site_id_any)
		var node: Node3D = render_nodes.get(site_id, null) as Node3D
		if node == null or not is_instance_valid(node) or not node.visible:
			continue
		var unit: Dictionary = _runtime_mobile_snapshots.get(site_id, _runtime_unit_snapshots.get(site_id, {})) as Dictionary
		keep_labels[site_id] = true
		var label: Label3D = _supply_debug_labels.get(site_id, null) as Label3D
		if label == null or not is_instance_valid(label):
			label = Label3D.new()
			label.name = "Debug_%s" % site_id
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.no_depth_test = true
			label.outline_size = 6
			label.font_size = 26
			_supply_debug_root.add_child(label)
			_supply_debug_labels[site_id] = label
		label.global_position = node.global_position + Vector3(0.0, 150.0, 0.0)
		var faction_id: String = String(unit.get("faction_id", ""))
		var faction_flag: String = "-"
		if not faction_id.is_empty():
			faction_flag = "P" if faction_id == player_faction else "E"
		var visible_now: bool = bool(site_visible.get(site_id, true))
		var in_supply: bool = in_supply_flags.has(site_id)
		label.text = "%s [%s]\nline:%s fog:%s vis:%.2f %s/%s" % [
			site_id,
			faction_flag,
			"on" if in_supply else "off",
			"show" if visible_now else "hide",
			vis_mul_dbg,
			day_phase_dbg,
			weather_dbg
		]
		label.modulate = Color(0.26, 1.0, 0.42, 1.0) if visible_now else Color(1.0, 0.38, 0.32, 1.0)
	for id_any in _supply_debug_labels.keys():
		var stale_id: String = String(id_any)
		if keep_labels.has(stale_id):
			continue
		var stale: Label3D = _supply_debug_labels.get(stale_id, null) as Label3D
		if stale != null and is_instance_valid(stale):
			stale.queue_free()
		_supply_debug_labels.erase(stale_id)

func _refresh_runtime_siege_info_overlay_periodic(delta: float) -> void:
	_runtime_siege_info_refresh_accum += maxf(0.0, delta)
	if _runtime_siege_info_refresh_accum + 0.0001 < RUNTIME_SIEGE_INFO_REFRESH_SEC:
		return
	_runtime_siege_info_refresh_accum = 0.0
	_refresh_runtime_siege_info_overlay()

func _ensure_runtime_siege_info_root() -> void:
	var node: Node = get_node_or_null("SiegeInfoOverlay")
	if node is Node3D:
		_runtime_siege_info_root = node as Node3D
		return
	_runtime_siege_info_root = Node3D.new()
	_runtime_siege_info_root.name = "SiegeInfoOverlay"
	add_child(_runtime_siege_info_root)

func _clear_runtime_siege_info_overlay() -> void:
	for id_any in _runtime_siege_info_labels.keys():
		var label: Label3D = _runtime_siege_info_labels.get(id_any, null) as Label3D
		if label != null and is_instance_valid(label):
			label.queue_free()
	_runtime_siege_info_labels.clear()
	if _runtime_siege_info_root == null or not is_instance_valid(_runtime_siege_info_root):
		return
	for child in _runtime_siege_info_root.get_children():
		if child is Node:
			(child as Node).queue_free()

func _refresh_runtime_siege_info_overlay() -> void:
	_ensure_runtime_siege_info_root()
	if _runtime_siege_info_root == null:
		return
	var marker_visible: bool = _runtime_unit_root == null or not is_instance_valid(_runtime_unit_root) or _runtime_unit_root.visible
	var mobile_visible: bool = _runtime_mobile_root == null or not is_instance_valid(_runtime_mobile_root) or _runtime_mobile_root.visible
	var allow_world: bool = marker_visible or mobile_visible
	var allow_phase: bool = _runtime_phase == RUNTIME_PHASE_BATTLE or _runtime_phase == RUNTIME_PHASE_INTERNAL
	var allow_camera: bool = _camera == null or _runtime_camera_height() <= RUNTIME_SIEGE_INFO_HIDE_CAMERA_HEIGHT
	_runtime_siege_info_root.visible = allow_world and allow_phase and allow_camera
	if not _runtime_siege_info_root.visible:
		return
	var targets: Array = _collect_runtime_siege_targets()
	if targets.is_empty():
		_clear_runtime_siege_info_overlay()
		return
	_cleanup_runtime_siege_capture_hints()
	var keep_labels: Dictionary = {}
	for target_any in targets:
		if not (target_any is Dictionary):
			continue
		var target: Dictionary = target_any as Dictionary
		var target_id: String = String(target.get("id", "")).strip_edges()
		if target_id.is_empty():
			continue
		var pos_any: Variant = target.get("position", {})
		if not (pos_any is Dictionary):
			continue
		var pos: Dictionary = pos_any as Dictionary
		var world_pos := Vector3(float(pos.get("x", 0.0)), 0.0, float(pos.get("z", 0.0)))
		world_pos.y = terrain_height_at_world(world_pos)
		var target_type: String = String(target.get("type", "site")).to_lower().strip_edges()
		var y_offset: float = RUNTIME_SIEGE_INFO_CITY_Y_OFFSET if target_type == "city" else RUNTIME_SIEGE_INFO_SITE_Y_OFFSET
		var record: Dictionary = _runtime_siege_resolve_display_record(target)
		var site_name: String = String(record.get("name", target.get("name", target_id))).strip_edges()
		if site_name.is_empty():
			site_name = target_id
		var faction_id: String = String(record.get("faction_id", target.get("faction_id", ""))).strip_edges()
		var faction_name: String = _resolve_faction_name(faction_id)
		if faction_name.strip_edges().is_empty() or faction_name == "-":
			faction_name = "无所属"
		var defense_payload: Dictionary = _runtime_siege_display_defense(record, target_type)
		var def_current: float = maxf(0.0, float(defense_payload.get("current", 0.0)))
		var def_max: float = maxf(1.0, float(defense_payload.get("max", 1.0)))
		var troops: int = _runtime_siege_display_troops(record)
		var status_tags: String = _runtime_siege_status_tags(target_id, faction_id, record)
		keep_labels[target_id] = true
		var label: Label3D = _runtime_siege_info_labels.get(target_id, null) as Label3D
		if label == null or not is_instance_valid(label):
			label = Label3D.new()
			label.name = "SiegeInfo_%s" % target_id
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.no_depth_test = true
			label.outline_size = 8
			label.font_size = 25
			label.modulate = Color(0.9, 0.95, 1.0, 1.0)
			_runtime_siege_info_root.add_child(label)
			_runtime_siege_info_labels[target_id] = label
		label.global_position = world_pos + Vector3(0.0, y_offset, 0.0)
		label.text = "%s·%s\n耐久 %s/%s  兵力 %s\n%s" % [
			faction_name,
			site_name,
			_fmt_num(def_current),
			_fmt_num(def_max),
			_fmt_num(float(troops)),
			status_tags
		]
		label.modulate = _runtime_siege_label_color(status_tags, faction_id)
	for id_any in _runtime_siege_info_labels.keys():
		var stale_id: String = String(id_any)
		if keep_labels.has(stale_id):
			continue
		var stale_label: Label3D = _runtime_siege_info_labels.get(stale_id, null) as Label3D
		if stale_label != null and is_instance_valid(stale_label):
			stale_label.queue_free()
		_runtime_siege_info_labels.erase(stale_id)

func _runtime_siege_resolve_display_record(target: Dictionary) -> Dictionary:
	var source_kind: String = String(target.get("source", "site")).to_lower().strip_edges()
	var target_id: String = String(target.get("id", target.get("city_id", ""))).strip_edges()
	var target_name: String = String(target.get("name", target_id)).strip_edges()
	if source_kind == "city":
		var city: Dictionary = _resolve_world_city(target_id, target_name)
		if city.is_empty():
			return {
				"id": target_id,
				"city_id": target_id,
				"name": target_name if not target_name.is_empty() else target_id,
				"type": "city",
				"faction_id": String(target.get("faction_id", "")).strip_edges()
			}
		return city
	var site: Dictionary = _resolve_world_building(target_id, target_name)
	if site.is_empty():
		return {
			"id": target_id,
			"city_id": String(target.get("city_id", target_id)).strip_edges(),
			"name": target_name if not target_name.is_empty() else target_id,
			"type": String(target.get("type", "site")).to_lower().strip_edges(),
			"faction_id": String(target.get("faction_id", "")).strip_edges()
		}
	return site

func _runtime_siege_display_troops(record: Dictionary) -> int:
	var garrison_any: Variant = record.get("garrison", {})
	var garrison: Dictionary = garrison_any as Dictionary if garrison_any is Dictionary else {}
	var stats_any: Variant = record.get("stats", {})
	var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
	if garrison.has("troops"):
		return maxi(0, int(round(float(garrison.get("troops", 0.0)))))
	if stats.has("troops"):
		return maxi(0, int(round(float(stats.get("troops", 0.0)))))
	var reserve: float = float(garrison.get("reserve_troops", stats.get("reserve_troops", 0.0)))
	var organized: float = float(garrison.get("organized_troops", stats.get("organized_troops", 0.0)))
	return maxi(0, int(round(maxf(0.0, reserve + organized))))

func _runtime_siege_display_defense(record: Dictionary, target_type: String) -> Dictionary:
	var type_key: String = target_type.to_lower().strip_edges()
	var defense_any: Variant = record.get("defense", {})
	var defense: Dictionary = defense_any as Dictionary if defense_any is Dictionary else {}
	var max_value: float = 0.0
	var current_value: float = 0.0
	if type_key == "city":
		max_value = maxf(1.0, float(defense.get("max", 0.0)))
		if max_value <= 1.001:
			var class_any: Variant = record.get("classification", {})
			var class_dict: Dictionary = class_any as Dictionary if class_any is Dictionary else {}
			var scale_key: String = _normalize_city_scale(String(class_dict.get("scale", record.get("scale", "medium"))))
			var caps: Dictionary = _city_caps_for_scale(scale_key)
			max_value = maxf(1.0, float(caps.get("defense_max", _runtime_siege_default_max_hp("city"))))
		if defense.has("current"):
			current_value = clampf(float(defense.get("current", max_value)), 0.0, max_value)
		else:
			current_value = max_value
	else:
		max_value = maxf(1.0, float(record.get("max_hp", defense.get("max", _runtime_siege_default_max_hp(type_key)))))
		if record.has("hp"):
			current_value = clampf(float(record.get("hp", max_value)), 0.0, max_value)
		elif defense.has("current"):
			current_value = clampf(float(defense.get("current", max_value)), 0.0, max_value)
		else:
			current_value = max_value
	return {
		"current": current_value,
		"max": max_value,
		"ratio": clampf(current_value / maxf(1.0, max_value), 0.0, 1.0)
	}

func _runtime_siege_status_tags(target_id: String, faction_id: String, record: Dictionary) -> String:
	var tags: Array[String] = []
	var fid: String = faction_id.strip_edges()
	if not fid.is_empty() and not _runtime_site_is_in_supply(target_id, fid):
		tags.append("[缂虹伯]")
	var burning: bool = _runtime_record_has_any_status_flag(record, ["on_fire", "is_on_fire", "is_burning", "burning", "fire_active", "fire_debuff"]) or _runtime_record_has_status_keywords(record, ["burn", "burning", "fire", "ignite", "燃烧", "着火", "火"])
	if burning:
		tags.append("[被点燃]")
	var confused: bool = _runtime_record_has_any_status_flag(record, ["confused", "is_confused", "confusion", "chaos", "misinformed"]) or _runtime_record_has_status_keywords(record, ["confuse", "confusion", "chaos", "panic", "娣蜂贡", "鎵颁贡", "杩锋儜"])
	if confused:
		tags.append("[娣蜂贡]")
	if tags.is_empty():
		tags.append("[鏃犵姸鎬乚")
	return " ".join(tags)

func _runtime_siege_label_color(status_tags: String, faction_id: String) -> Color:
	if status_tags.find("[被点燃]") >= 0:
		return Color(1.0, 0.58, 0.44, 1.0)
	if status_tags.find("[混乱]") >= 0:
		return Color(0.93, 0.68, 1.0, 1.0)
	if status_tags.find("缂虹伯") >= 0:
		return Color(1.0, 0.82, 0.46, 1.0)
	if faction_id.strip_edges().is_empty():
		return Color(0.82, 0.84, 0.88, 1.0)
	return Color(0.84, 0.95, 1.0, 1.0)

func _runtime_site_is_in_supply(site_id: String, faction_id: String) -> bool:
	var target_id: String = site_id.strip_edges()
	var fid: String = faction_id.strip_edges()
	if target_id.is_empty() or fid.is_empty():
		return true
	if not bool(_supply_fog_snapshot.get("enabled", false)):
		return true
	var by_faction_any: Variant = _supply_fog_snapshot.get("in_supply_by_faction", {})
	if by_faction_any is Dictionary:
		var mapped_any: Variant = (by_faction_any as Dictionary).get(fid, [])
		if mapped_any is Array:
			var mapped: Array = mapped_any as Array
			if not mapped.is_empty():
				for id_any in mapped:
					if String(id_any).strip_edges() == target_id:
						return true
				return false
	var all_any: Variant = _supply_fog_snapshot.get("in_supply_site_ids", [])
	if all_any is Array:
		for id_any in (all_any as Array):
			if String(id_any).strip_edges() == target_id:
				return true
		return false
	return true

func _runtime_record_has_any_status_flag(record: Dictionary, keys: Array) -> bool:
	if record.is_empty():
		return false
	for key_any in keys:
		var key: String = String(key_any).strip_edges()
		if key.is_empty() or not record.has(key):
			continue
		var value: Variant = record.get(key, null)
		if value is bool and bool(value):
			return true
		if value is int or value is float:
			if float(value) > 0.001:
				return true
		if value is String and not String(value).strip_edges().is_empty() and String(value).to_lower() != "false":
			return true
	return false

func _runtime_record_has_status_keywords(record: Dictionary, keywords: Array) -> bool:
	if record.is_empty():
		return false
	var direct_text_keys: Array = [
		"status",
		"status_text",
		"state",
		"state_text",
		"condition",
		"condition_text",
		"debuff",
		"debuff_text"
	]
	for key_any in direct_text_keys:
		var key: String = String(key_any).strip_edges()
		if key.is_empty() or not record.has(key):
			continue
		if _runtime_variant_has_any_keyword(record.get(key, null), keywords):
			return true
	var container_keys: Array = [
		"statuses",
		"status_effects",
		"debuffs",
		"effects",
		"conditions",
		"flags",
		"runtime_statuses"
	]
	for key_any in container_keys:
		var key: String = String(key_any).strip_edges()
		if key.is_empty() or not record.has(key):
			continue
		if _runtime_variant_has_any_keyword(record.get(key, null), keywords):
			return true
	return false

func _runtime_variant_has_any_keyword(value: Variant, keywords: Array) -> bool:
	if value == null:
		return false
	if value is String:
		return _runtime_text_has_any_keyword(String(value), keywords)
	if value is Array:
		for item in (value as Array):
			if _runtime_variant_has_any_keyword(item, keywords):
				return true
		return false
	if value is Dictionary:
		var dict: Dictionary = value as Dictionary
		for key_any in dict.keys():
			var key_text: String = String(key_any)
			var item: Variant = dict.get(key_any, null)
			if item is bool and bool(item) and _runtime_text_has_any_keyword(key_text, keywords):
				return true
			if _runtime_variant_has_any_keyword(item, keywords):
				return true
		return false
	return false

func _runtime_text_has_any_keyword(text: String, keywords: Array) -> bool:
	var low: String = text.to_lower()
	if low.is_empty():
		return false
	for keyword_any in keywords:
		var keyword: String = String(keyword_any).to_lower().strip_edges()
		if keyword.is_empty():
			continue
		if low.find(keyword) != -1:
			return true
	return false

func set_supply_debug_enabled(enabled: bool) -> void:
	_supply_debug_enabled = enabled
	_refresh_supply_debug_overlay()

func get_supply_fog_snapshot() -> Dictionary:
	return _supply_fog_snapshot.duplicate(true)

func refresh_supply_fog_now() -> void:
	_reload_world_state_cache()
	_refresh_supply_fog_runtime(true)

func _toggle_supply_corridor_view() -> void:
	_supply_corridor_view_enabled = not _supply_corridor_view_enabled
	_refresh_supply_corridor_region_overlay()
	_refresh_supply_corridor_toggle_button_visual()
	if _camera != null and _camera.has_method("get_current_lod_level") and _camera.has_method("get_total_lod_levels") and _camera.has_method("get_current_target_height"):
		_on_camera_zoom_lod_changed(
			int(_camera.call("get_current_lod_level")),
			int(_camera.call("get_total_lod_levels")),
			float(_camera.call("get_current_target_height"))
		)
	_runtime_status_message = "粮道范围视图：%s（L键）" % ("开启" if _supply_corridor_view_enabled else "关闭")
	_refresh_runtime_ui_hud(true)

func _refresh_supply_corridor_region_overlay() -> void:
	if _political_overlay == null or not is_instance_valid(_political_overlay):
		return
	if not _supply_corridor_view_enabled:
		_political_overlay.set_region_color_overrides({})
		if _political_overlay.has_method("set_overlay_opacity"):
			_political_overlay.call("set_overlay_opacity", 1.0)
		return
	if _political_overlay.has_method("set_overlay_opacity"):
		_political_overlay.call("set_overlay_opacity", 1.0)
	var player_faction: String = _get_player_faction_id()
	var player_region_flags: Dictionary = {}
	var by_faction_any: Variant = _supply_fog_snapshot.get("supply_regions_by_faction", {})
	if by_faction_any is Dictionary and not player_faction.is_empty():
		var player_regions_any: Variant = (by_faction_any as Dictionary).get(player_faction, [])
		if player_regions_any is Array:
			for region_any in (player_regions_any as Array):
				var region_id: String = String(region_any).strip_edges()
				if not region_id.is_empty():
					player_region_flags[region_id] = true
	if player_region_flags.is_empty() and not player_faction.is_empty():
		for node_any in _collect_supply_nodes():
			if not (node_any is Dictionary):
				continue
			var node: Dictionary = _normalize_supply_node(node_any as Dictionary)
			if node.is_empty():
				continue
			if String(node.get("faction_id", "")).strip_edges() != player_faction:
				continue
			var p2: Vector2 = _node_pos2(node)
			var rid: String = get_region_id_at_world(Vector3(p2.x, 0.0, p2.y)).strip_edges()
			if not rid.is_empty():
				player_region_flags[rid] = true
	var overrides: Dictionary = {}
	if _political_overlay.has_method("get_region_ids"):
		var region_ids_any: Variant = _political_overlay.call("get_region_ids")
		if region_ids_any is Array:
			for id_any in (region_ids_any as Array):
				var region_id: String = String(id_any).strip_edges()
				if not region_id.is_empty():
					# Hide all non-player regions first, then paint player's supply corridor.
					overrides[region_id] = Color(0.0, 0.0, 0.0, 0.0)
	for rid_any in player_region_flags.keys():
		var rid: String = String(rid_any)
		overrides[rid] = Color(0.20, 0.78, 0.34, 0.80)
	if _political_overlay.has_method("set_region_color_overrides_with_fallback"):
		_political_overlay.call("set_region_color_overrides_with_fallback", overrides, Color(0.0, 0.0, 0.0, 0.0))
	else:
		_political_overlay.set_region_color_overrides(overrides)


func set_political_mode_province() -> void:
	if _political_overlay != null:
		_political_overlay.set_region_color_overrides({})
		if _political_overlay.has_method("set_overlay_opacity"):
			_political_overlay.call("set_overlay_opacity", 1.0)


func set_political_mode_faction(region_colors: Dictionary) -> void:
	if _political_overlay != null:
		_political_overlay.set_region_color_overrides(region_colors)
		if _political_overlay.has_method("set_overlay_opacity"):
			_political_overlay.call("set_overlay_opacity", 1.0)


func get_region_id_at_world(world_pos: Vector3) -> String:
	if _political_overlay == null:
		return ""
	return _political_overlay.region_id_at_world(world_pos)


func _terrain_data():
	if _terrain == null or not is_instance_valid(_terrain):
		return null
	if _terrain.has_method("get_data"):
		return _terrain.call("get_data")
	return _terrain.get("data")

func terrain_height_at_world(world_pos: Vector3) -> float:
	if not world_pos.is_finite():
		return 0.0
	var data = _terrain_data()
	if data != null and data.has_method("get_height"):
		var height: float = float(data.call("get_height", world_pos))
		if _is_finite_number(height):
			return height
	return 0.0

func _is_finite_number(value: float) -> bool:
	return not is_nan(value) and not is_inf(value)

func _snapshot_array_from_world_state(key: String) -> Array:
	var raw_any: Variant = _world_state_cache.get(key, [])
	if raw_any is Array:
		return (raw_any as Array).duplicate(true)
	return []

func terrain_slope_deg_at_world(world_pos: Vector3) -> float:
	var data = _terrain_data()
	if data != null and data.has_method("get_normal"):
		var normal: Vector3 = data.call("get_normal", world_pos)
		if normal.length_squared() > 0.000001:
			return rad_to_deg(normal.normalized().angle_to(Vector3.UP))
	return 0.0

func can_unit_walk_at_world(world_pos: Vector3) -> bool:
	var data = _terrain_data()
	if data == null:
		return not _is_world_blocked_by_runtime_obstacle(world_pos)
	if data.has_method("has_regionp") and not bool(data.call("has_regionp", world_pos)):
		return false
	if data.has_method("get_control_hole") and bool(data.call("get_control_hole", world_pos)):
		return false
	if terrain_height_at_world(world_pos) <= TERRAIN_WATER_HEIGHT:
		return false
	if terrain_slope_deg_at_world(world_pos) > TERRAIN_WALKABLE_SLOPE_DEG:
		return false
	return not _is_world_blocked_by_runtime_obstacle(world_pos)

func _is_world_blocked_by_runtime_obstacle(world_pos: Vector3) -> bool:
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return false
	for unit_any in (units_any as Array):
		if not (unit_any is Dictionary):
			continue
		var node: Dictionary = unit_any as Dictionary
		if bool(node.get("awaiting_builder_arrival", false)) or bool(node.get("is_under_construction", false)):
			continue
		var type_key: String = String(node.get("type", "")).to_lower().strip_edges()
		if type_key != "zhalan":
			continue
		var pos_any: Variant = node.get("position", {})
		if not (pos_any is Dictionary):
			continue
		var pos: Dictionary = pos_any as Dictionary
		var center_x: float = float(pos.get("x", 0.0))
		var center_z: float = float(pos.get("z", 0.0))
		var dx: float = world_pos.x - center_x
		var dz: float = world_pos.z - center_z
		var block_radius: float = ZHALAN_POST_BLOCK_RADIUS + 1.2
		if dx * dx + dz * dz > block_radius * block_radius:
			continue
		return true
	return false

func terrain_type_at_world(world_pos: Vector3) -> String:
	var data = _terrain_data()
	if data != null and data.has_method("get_control_hole") and bool(data.call("get_control_hole", world_pos)):
		return "water"
	var h: float = terrain_height_at_world(world_pos)
	var slope: float = terrain_slope_deg_at_world(world_pos)
	if h <= TERRAIN_WATER_HEIGHT:
		return "water"
	if slope > TERRAIN_WALKABLE_SLOPE_DEG:
		return "mountain"
	if slope > 20.0:
		return "hill"
	return "plain"

func get_unit_build_menu_options(_unit: Node) -> Array:
	return [
		{"id": "build_muzhai", "label": "建木寨", "hint": "基础防御工事"},
		{"id": "build_granary", "label": "建粮仓", "hint": "基础补给节点"},
		{"id": "build_jianlou", "label": "建箭楼", "hint": "远程防御点"},
		{"id": "build_zhalan", "label": "建栅栏", "hint": "阻滞地形"},
		{"id": "build_taigutai", "label": "寤哄お榧撳彴", "hint": "澹皵杈呭姪"}
	]

func get_unit_build_preview(action_id: String) -> Dictionary:
	var spec: Dictionary = UNIT_BUILD_CREATE_ACTIONS.get(action_id, {}) as Dictionary
	if spec.is_empty():
		return {}
	var type_key: String = String(spec.get("type", "")).to_lower().strip_edges()
	if type_key.is_empty():
		return {}
	var model_path: String = _model_path_by_key([type_key])
	if type_key == "zhalan" and model_path.is_empty():
		model_path = String(DEFAULT_RUNTIME_MODEL_PATHS.get("zhalan", "")).strip_edges()
	var preview := {
		"type": type_key,
		"name": String(spec.get("name", type_key)),
		"model_path": model_path,
		"model_scale": _model_scale_by_key([type_key], 1.0) * FACILITY_MODEL_SCALE_MUL
	}
	if type_key == "zhalan":
		preview["procedural_id"] = "zhalan_poly_log"
	return preview

func create_unit_build_preview_instance(action_id: String) -> Node3D:
	if action_id != "build_zhalan":
		return null
	return _instantiate_runtime_zhalan_poly_model()

func set_supply_route_focus_unit(unit: Node) -> void:
	var focus_site_id: String = ""
	var focus_faction_id: String = ""
	if unit != null and is_instance_valid(unit):
		focus_site_id = String(unit.get_meta("building_id", "")).strip_edges()
		if focus_site_id.is_empty():
			focus_site_id = String(unit.get_meta("unit_id", "")).strip_edges()
		if unit.has_meta("faction_id"):
			focus_faction_id = String(unit.get_meta("faction_id", "")).strip_edges()
		if focus_faction_id.is_empty() and not focus_site_id.is_empty():
			var unit_snap: Dictionary = _runtime_mobile_snapshots.get(focus_site_id, {}) as Dictionary
			if not unit_snap.is_empty():
				focus_faction_id = String(unit_snap.get("faction_id", "")).strip_edges()
		if focus_faction_id.is_empty():
			var player_faction: String = _get_player_faction_id()
			if not player_faction.is_empty():
				focus_faction_id = player_faction
	_supply_route_focus_site_id = focus_site_id
	_supply_route_focus_faction_id = focus_faction_id
	_rebuild_supply_route_overlay()

func set_supply_route_build_preview(action_id: String, world_pos: Vector3, unit: Node = null) -> void:
	var action_key: String = action_id.to_lower().strip_edges()
	if action_key != "build_granary":
		clear_supply_route_build_preview()
		return
	var faction_id: String = ""
	if unit != null and is_instance_valid(unit):
		var unit_id: String = String(unit.get_meta("building_id", "")).strip_edges()
		if not unit_id.is_empty():
			var unit_snap: Dictionary = _runtime_mobile_snapshots.get(unit_id, {}) as Dictionary
			if not unit_snap.is_empty():
				faction_id = String(unit_snap.get("faction_id", "")).strip_edges()
	if faction_id.is_empty():
		faction_id = _get_player_faction_id()
	_supply_route_preview_action_id = action_key
	_supply_route_preview_world = world_pos
	_supply_route_preview_faction_id = faction_id
	_rebuild_supply_route_overlay()

func clear_supply_route_build_preview() -> void:
	if _supply_route_preview_action_id.is_empty() and _supply_route_preview_world == Vector3.INF and _supply_route_preview_faction_id.is_empty():
		return
	_supply_route_preview_action_id = ""
	_supply_route_preview_world = Vector3.INF
	_supply_route_preview_faction_id = ""
	_rebuild_supply_route_overlay()

func request_unit_build_action(unit: Node, action_id: String, target_world: Vector3 = Vector3.INF, rotation_y_deg: float = 0.0) -> Dictionary:
	if unit == null or not is_instance_valid(unit):
		return {"ok": false, "message": "No valid unit selected."}
	var unit_id: String = String(unit.get_meta("building_id", "")).strip_edges()
	if unit_id.is_empty():
		return {"ok": false, "message": "Selected unit has no runtime id."}
	var unit_snap: Dictionary = _runtime_mobile_snapshots.get(unit_id, {}) as Dictionary
	if unit_snap.is_empty():
		return {"ok": false, "message": "Selected unit is not a build-capable field unit."}
	var unit_type: String = String(unit_snap.get("type", "")).to_lower().strip_edges()
	if unit_type != "field_unit":
		return {"ok": false, "message": "Only field units can build military facilities."}
	var faction_id: String = String(unit_snap.get("faction_id", "")).strip_edges()
	if faction_id.is_empty():
		return {"ok": false, "message": "No faction assigned on selected unit."}
	if UNIT_BUILD_UPGRADE_ACTIONS.has(action_id):
		return _upgrade_unit_built_facility(unit_snap, faction_id, action_id)
	if action_id == "facility_repair":
		return _repair_nearby_facility(unit_snap, faction_id)
	if action_id == "facility_destroy":
		return _destroy_nearby_facility(unit_snap, faction_id)
	if UNIT_BUILD_CREATE_ACTIONS.has(action_id):
		return _create_unit_built_facility(unit, unit_snap, faction_id, action_id, target_world, rotation_y_deg)
	return {"ok": false, "message": "Unknown build action: %s" % action_id}

func request_unit_build_line_action(unit: Node, action_id: String, start_world: Vector3, end_world: Vector3) -> Dictionary:
	if action_id != "build_zhalan":
		return {"ok": false, "message": "Only palisade supports line placement."}
	if unit == null or not is_instance_valid(unit):
		return {"ok": false, "message": "No valid unit selected."}
	var unit_id: String = String(unit.get_meta("building_id", "")).strip_edges()
	if unit_id.is_empty():
		return {"ok": false, "message": "Selected unit has no runtime id."}
	var unit_snap: Dictionary = _runtime_mobile_snapshots.get(unit_id, {}) as Dictionary
	if unit_snap.is_empty():
		return {"ok": false, "message": "Selected unit is not a build-capable field unit."}
	var faction_id: String = String(unit_snap.get("faction_id", "")).strip_edges()
	if faction_id.is_empty():
		return {"ok": false, "message": "No faction assigned on selected unit."}
	var start := start_world
	var finish := end_world
	start.y = terrain_height_at_world(start)
	finish.y = terrain_height_at_world(finish)
	var delta: Vector3 = finish - start
	delta.y = 0.0
	var line_len: float = delta.length()
	if line_len < 24.0:
		return {"ok": false, "message": "终点离起点太近，无法生成栅栏线。"}
	var yaw_deg: float = rad_to_deg(atan2(delta.x, delta.z))
	var steps: int = maxi(1, int(floor(line_len / FENCE_LINE_SEGMENT_SPACING)) + 1)
	var created: int = 0
	for i in range(steps):
		var t: float = 0.0 if steps <= 1 else float(i) / float(steps - 1)
		var p: Vector3 = start.lerp(finish, t)
		p.y = terrain_height_at_world(p)
		if not can_unit_walk_at_world(p):
			continue
		if _is_position_too_close_to_runtime_building(p):
			continue
		var create_result: Dictionary = _create_unit_built_facility(unit, unit_snap, faction_id, action_id, p, yaw_deg, true, false, true)
		if bool(create_result.get("ok", false)):
			created += 1
	if created <= 0:
		return {"ok": false, "message": "没有可放置的有效栅栏线段。"}
	_refresh_supply_fog_runtime(true)
	return {"ok": true, "message": "已生成栅栏线段 %d 个。" % created}

func _create_unit_built_facility(unit: Node, unit_snap: Dictionary, faction_id: String, action_id: String, target_world: Vector3 = Vector3.INF, rotation_y_deg: float = 0.0, start_construction_now: bool = false, issue_move_order_now: bool = true, ignore_distance_limit: bool = false) -> Dictionary:
	var spec: Dictionary = UNIT_BUILD_CREATE_ACTIONS.get(action_id, {}) as Dictionary
	if spec.is_empty():
		return {"ok": false, "message": "Create action not found."}
	var build_pos: Vector3 = Vector3.INF
	if ignore_distance_limit and target_world != Vector3.INF:
		build_pos = target_world
		build_pos.y = terrain_height_at_world(build_pos)
		if _is_position_too_close_to_runtime_building(build_pos):
			return {"ok": false, "message": "目标位置附近已有建筑，无法放置。"}
	else:
		var world_pos: Vector3 = unit.global_position
		build_pos = _find_runtime_build_position(world_pos, target_world)
	if build_pos == Vector3.INF:
		return {"ok": false, "message": "目标位置附近已有建筑，无法放置。"}
	if not can_unit_walk_at_world(build_pos):
		return {"ok": false, "message": "Build position is blocked."}
	var type_key: String = String(spec.get("type", "site")).strip_edges().to_lower()
	var unit_id: String = _next_runtime_facility_id(type_key, faction_id)
	var display_name: String = "%s%s" % [_resolve_faction_name(faction_id), String(spec.get("name", type_key))]
	var city_id: String = String(unit_snap.get("city_id", "")).strip_edges()
	if city_id.is_empty():
		city_id = String(unit_snap.get("id", "")).strip_edges()
	var node: Dictionary = {
		"id": unit_id,
		"name": display_name,
		"faction_id": faction_id,
		"type": type_key,
		"city_id": city_id,
		"position": {"x": float(build_pos.x), "z": float(build_pos.z)},
		"rotation_y_deg": wrapf(rotation_y_deg, -180.0, 180.0)
	}
	var max_hp: float = _facility_default_max_hp(type_key)
	node["max_hp"] = max_hp
	node["hp"] = 1.0
	node["is_under_construction"] = start_construction_now
	node["awaiting_builder_arrival"] = not start_construction_now
	node["builder_unit_id"] = String(unit.get_meta("building_id", ""))
	node["construction_progress"] = 0.0
	node["construction_duration_sec"] = _facility_default_build_duration(type_key)
	node["construction_started_msec"] = Time.get_ticks_msec() if start_construction_now else 0
	if bool(spec.get("is_granary", false)):
		node["is_granary"] = true
		node["level"] = 1
		node["resources"] = {"food": 12000.0, "wood": 500.0, "horse": 0.0, "money": 0.0, "iron": 0.0}
		node["stats"] = {"troops": 900.0, "reserve_troops": 340.0, "organized_troops": 560.0, "security": 50.0}
	var move_target := Vector3.INF
	if not start_construction_now:
		move_target = _find_builder_staging_point(build_pos)
		node["builder_staging_position"] = {"x": float(move_target.x), "z": float(move_target.z)}
	_append_world_building_unit(node)
	if issue_move_order_now and unit != null and is_instance_valid(unit) and unit.has_method("issue_move_order"):
		if move_target == Vector3.INF:
			move_target = _find_builder_staging_point(build_pos)
		unit.call("issue_move_order", move_target)
	if not start_construction_now:
		_refresh_supply_fog_runtime(true)
	return {"ok": true, "message": "%s 已完成设施布置。" % display_name, "site_id": unit_id}

func _find_builder_staging_point(build_pos: Vector3) -> Vector3:
	var ring: Array = [62.0, 86.0, 112.0, 138.0]
	var angles: Array = [0.0, 45.0, -45.0, 90.0, -90.0, 135.0, -135.0, 180.0]
	for r_any in ring:
		var r: float = float(r_any)
		for a_any in angles:
			var a: float = deg_to_rad(float(a_any))
			var p := build_pos + Vector3(cos(a) * r, 0.0, sin(a) * r)
			p.y = terrain_height_at_world(p)
			if can_unit_walk_at_world(p):
				return p
	return build_pos

func _upgrade_unit_built_facility(unit_snap: Dictionary, faction_id: String, action_id: String, preferred_site_id: String = "") -> Dictionary:
	var spec: Dictionary = UNIT_BUILD_UPGRADE_ACTIONS.get(action_id, {}) as Dictionary
	if spec.is_empty():
		return {"ok": false, "message": "Upgrade action not found."}
	var unit_pos_any: Variant = unit_snap.get("position", {})
	var unit_pos: Dictionary = unit_pos_any as Dictionary if unit_pos_any is Dictionary else {}
	var center := Vector2(float(unit_pos.get("x", 0.0)), float(unit_pos.get("z", 0.0)))
	var from_type: String = String(spec.get("from_type", "")).to_lower().strip_edges()
	var target_index: int = -1
	if not preferred_site_id.strip_edges().is_empty():
		target_index = _find_owned_runtime_facility_index_by_id(preferred_site_id.strip_edges(), faction_id)
	if target_index < 0:
		target_index = _find_nearest_owned_building_index(center, faction_id, from_type, UNIT_BUILD_UPGRADE_RADIUS, bool(spec.get("require_basic_granary", false)))
	if target_index < 0:
		return {"ok": false, "message": "No upgradable %s in range." % from_type}
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return {"ok": false, "message": "World building list missing."}
	var units: Array = units_any as Array
	var target: Dictionary = (units[target_index] as Dictionary).duplicate(true)
	if bool(target.get("awaiting_builder_arrival", false)) or bool(target.get("is_under_construction", false)):
		return {"ok": false, "message": "目标设施正在建设中。"}
	if bool(target.get("operation_active", false)):
		return {"ok": false, "message": "目标设施已有进行中的操作。"}
	var target_type: String = String(target.get("type", "")).to_lower().strip_edges()
	if target_type != from_type:
		return {"ok": false, "message": "只能升级同类设施。"}
	if bool(spec.get("require_basic_granary", false)) and bool(target.get("is_advanced_granary", false)):
		return {"ok": false, "message": "高级粮仓不能重复升级。"}
	target["operation_active"] = true
	target["operation_kind"] = "upgrade"
	target["operation_started_msec"] = Time.get_ticks_msec()
	target["operation_duration_sec"] = FACILITY_UPGRADE_DURATION_SEC
	target["operation_progress"] = 0.0
	target["operation_upgrade_action_id"] = action_id
	target["operation_builder_unit_id"] = String(unit_snap.get("id", "")).strip_edges()
	target["construction_progress"] = 0.0
	units[target_index] = target
	_world_state_cache["building_units"] = units
	_sync_world_building_alias(target)
	_refresh_supply_fog_runtime(true)
	return {"ok": true, "message": "%s 已开始升级，预计 %.0f 秒完成。" % [String(target.get("name", target.get("id", "facility"))), FACILITY_UPGRADE_DURATION_SEC], "site_id": String(target.get("id", ""))}

func _repair_nearby_facility(unit_snap: Dictionary, faction_id: String, preferred_site_id: String = "") -> Dictionary:
	var idx: int = -1
	if not preferred_site_id.strip_edges().is_empty():
		idx = _find_owned_runtime_facility_index_by_id(preferred_site_id.strip_edges(), faction_id)
	if idx < 0:
		idx = _find_nearest_owned_runtime_facility_index(unit_snap, faction_id)
	if idx < 0:
		return {"ok": false, "message": "No repairable facility in range."}
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return {"ok": false, "message": "World building list missing."}
	var units: Array = units_any as Array
	var node: Dictionary = (units[idx] as Dictionary).duplicate(true)
	if bool(node.get("is_under_construction", false)) or bool(node.get("awaiting_builder_arrival", false)):
		return {"ok": false, "message": "Cannot repair while under construction."}
	if bool(node.get("operation_active", false)):
		return {"ok": false, "message": "This facility already has an active operation."}
	var type_key: String = String(node.get("type", "")).to_lower().strip_edges()
	var max_hp: float = maxf(1.0, float(node.get("max_hp", _facility_default_max_hp(type_key))))
	var hp: float = float(node.get("hp", max_hp))
	if hp >= max_hp - 1.0:
		return {"ok": false, "message": "Facility HP is already full."}
	node["max_hp"] = max_hp
	node["operation_active"] = true
	node["operation_kind"] = "repair"
	node["operation_started_msec"] = Time.get_ticks_msec()
	node["operation_duration_sec"] = FACILITY_REPAIR_DURATION_SEC
	node["operation_progress"] = 0.0
	node["operation_builder_unit_id"] = String(unit_snap.get("id", "")).strip_edges()
	node["operation_repair_from_hp"] = hp
	node["operation_repair_to_hp"] = max_hp
	node["construction_progress"] = 0.0
	node["hp"] = hp
	units[idx] = node
	_world_state_cache["building_units"] = units
	_sync_world_building_alias(node)
	_refresh_supply_fog_runtime(true)
	return {"ok": true, "message": "%s repair started, ETA %.0f sec." % [String(node.get("name", node.get("id", "facility"))), FACILITY_REPAIR_DURATION_SEC], "site_id": String(node.get("id", ""))}

func _resolve_runtime_commander_node(unit_snap: Dictionary) -> Node3D:
	var unit_id: String = String(unit_snap.get("id", "")).strip_edges()
	if unit_id.is_empty():
		return null
	var node: Node3D = _runtime_mobile_units.get(unit_id, null) as Node3D
	if node == null or not is_instance_valid(node):
		return null
	return node

func _runtime_mobile_snap_by_id(unit_id: String) -> Dictionary:
	var key: String = unit_id.strip_edges()
	if key.is_empty():
		return {}
	var snap_any: Variant = _runtime_mobile_snapshots.get(key, {})
	if snap_any is Dictionary:
		return (snap_any as Dictionary).duplicate(true)
	return {}

func _report_runtime_supply_event(unit_node: Node3D, unit_snap: Dictionary, in_supply: bool) -> void:
	if _battle_runtime == null or not is_instance_valid(_battle_runtime):
		return
	if not _battle_runtime.has_method("report_commander_runtime_event"):
		return
	var faction_id: String = String(unit_snap.get("faction_id", "")).strip_edges()
	if faction_id.is_empty() or faction_id != _get_player_faction_id():
		return
	var unit_id: String = String(unit_snap.get("id", "")).strip_edges()
	var target_label: String = String(unit_snap.get("name", unit_id)).strip_edges()
	if target_label.is_empty():
		target_label = "鍓嶇嚎閮ㄩ槦"
	var event_key: String = "supply_recovered" if in_supply else "supply_lost"
	var ctx := {
		"cooldown_key": "supply:%s:%s" % [unit_id, event_key],
		"cooldown_sec": 8.0,
		"duration_sec": 3.8
	}
	_battle_runtime.call("report_commander_runtime_event", unit_node, event_key, target_label, {}, ctx)

func _report_runtime_facility_event(unit_snap: Dictionary, site_node: Dictionary, event_key: String) -> void:
	if _battle_runtime == null or not is_instance_valid(_battle_runtime):
		return
	if not _battle_runtime.has_method("report_commander_runtime_event"):
		return
	var faction_id: String = String(unit_snap.get("faction_id", "")).strip_edges()
	if faction_id.is_empty() or faction_id != _get_player_faction_id():
		return
	var commander_node: Node3D = _resolve_runtime_commander_node(unit_snap)
	var site_id: String = String(site_node.get("id", "")).strip_edges()
	var site_name: String = String(site_node.get("name", site_id)).strip_edges()
	if site_name.is_empty():
		site_name = "鍐涗簨璁炬柦"
	var reward_override: Dictionary = {}
	match event_key:
		"build_complete":
			reward_override = {"merit": 1}
		"facility_upgrade_complete":
			reward_override = {"merit": 2, "tech": 1}
		"facility_repair_complete":
			reward_override = {"merit": 1}
		_:
			reward_override = {}
	var ctx := {
		"cooldown_key": "facility:%s:%s" % [site_id, event_key],
		"cooldown_sec": 1.2,
		"duration_sec": 4.2
	}
	_battle_runtime.call("report_commander_runtime_event", commander_node, event_key, site_name, reward_override, ctx)

func _report_runtime_facility_event_by_builder_id(builder_unit_id: String, site_node: Dictionary, event_key: String) -> void:
	var builder_id: String = builder_unit_id.strip_edges()
	var snap: Dictionary = _runtime_mobile_snap_by_id(builder_id)
	if snap.is_empty():
		snap = {
			"id": builder_id,
			"name": "Builder",
			"faction_id": String(site_node.get("faction_id", "")).strip_edges()
		}
	_report_runtime_facility_event(snap, site_node, event_key)

func _report_runtime_site_victory(unit_snap: Dictionary, site_node: Dictionary, attacker_faction_id: String) -> void:
	if _battle_runtime == null or not is_instance_valid(_battle_runtime):
		return
	if not _battle_runtime.has_method("report_commander_site_victory"):
		return
	var site_faction_id: String = String(site_node.get("faction_id", "")).strip_edges()
	if not site_faction_id.is_empty() and site_faction_id == attacker_faction_id:
		return
	var commander_node: Node3D = _resolve_runtime_commander_node(unit_snap)
	var site_name: String = String(site_node.get("name", site_node.get("id", "鎹偣"))).strip_edges()
	if site_name.is_empty():
		site_name = "鎹偣"
	var site_type: String = String(site_node.get("type", "")).strip_edges().to_lower()
	var hp_scale: float = maxf(300.0, float(site_node.get("max_hp", 1200.0)))
	var reward_override := {
		"food": int(round(100.0 + hp_scale * 0.08)),
		"materials": int(round(70.0 + hp_scale * 0.05)),
		"merit": int(round(10.0 + hp_scale * 0.012)),
		"tech": int(round(4.0 + hp_scale * 0.005)),
		"record": 1
	}
	_battle_runtime.call("report_commander_site_victory", commander_node, site_name, site_type, reward_override)

func _destroy_nearby_facility(unit_snap: Dictionary, faction_id: String, preferred_site_id: String = "") -> Dictionary:
	var idx: int = -1
	if not preferred_site_id.strip_edges().is_empty():
		idx = _find_owned_runtime_facility_index_by_id(preferred_site_id.strip_edges(), faction_id)
	if idx < 0:
		idx = _find_nearest_owned_runtime_facility_index(unit_snap, faction_id)
	if idx < 0:
		return {"ok": false, "message": "No destroyable facility in range."}
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return {"ok": false, "message": "World building list missing."}
	var units: Array = units_any as Array
	var node: Dictionary = (units[idx] as Dictionary).duplicate(true)
	units.remove_at(idx)
	_world_state_cache["building_units"] = units
	var node_id: String = String(node.get("id", "")).strip_edges()
	if not node_id.is_empty():
		_world_building_by_id.erase(node_id)
		_world_building_by_id.erase(node_id.to_lower())
	var node_name: String = String(node.get("name", node_id)).strip_edges()
	if not node_name.is_empty():
		_world_building_by_name.erase(node_name)
		_world_building_by_name.erase(node_name.to_lower())
	_refresh_supply_fog_runtime(true)
	return {"ok": true, "message": "%s destroyed." % String(node.get("name", node_id)), "site_id": node_id}

func _find_owned_runtime_facility_index_by_id(site_id: String, faction_id: String) -> int:
	var query_id: String = site_id.strip_edges()
	if query_id.is_empty():
		return -1
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return -1
	for i in range((units_any as Array).size()):
		var node_any: Variant = (units_any as Array)[i]
		if not (node_any is Dictionary):
			continue
		var node: Dictionary = node_any as Dictionary
		if String(node.get("id", "")).strip_edges() != query_id:
			continue
		if String(node.get("faction_id", "")).strip_edges() != faction_id:
			return -1
		var node_type: String = String(node.get("type", "")).to_lower().strip_edges()
		if not _is_runtime_constructed_facility_type(node_type):
			return -1
		return i
	return -1

func _find_nearest_owned_runtime_facility_index(unit_snap: Dictionary, faction_id: String) -> int:
	var pos_any: Variant = unit_snap.get("position", {})
	if not (pos_any is Dictionary):
		return -1
	var pos: Dictionary = pos_any as Dictionary
	var center := Vector2(float(pos.get("x", 0.0)), float(pos.get("z", 0.0))
	)
	return _find_nearest_owned_building_index(center, faction_id, "", UNIT_BUILD_UPGRADE_RADIUS, false, true)

func _facility_default_max_hp(type_key: String) -> float:
	match type_key:
		"chengzhai":
			return 2600.0
		"muzhai":
			return 1700.0
		"gaojijianlou":
			return 1900.0
		"jianlou":
			return 1300.0
		"granary":
			return 1800.0
		"zhalan":
			return 900.0
		"junyuetai":
			return 1300.0
		"taigutai":
			return 900.0
		_:
			return 1200.0

func _facility_default_build_duration(type_key: String) -> float:
	match type_key:
		"chengzhai":
			return 22.0
		"muzhai":
			return 14.0
		"gaojijianlou":
			return 16.0
		"jianlou":
			return 11.0
		"granary":
			return 15.0
		"zhalan":
			return 8.0
		"junyuetai":
			return 13.0
		"taigutai":
			return 9.0
		_:
			return 12.0

func _find_runtime_build_position(center: Vector3, requested_world: Vector3 = Vector3.INF) -> Vector3:
	if requested_world != Vector3.INF:
		var requested: Vector3 = requested_world
		requested.y = terrain_height_at_world(requested)
		var delta := requested - center
		delta.y = 0.0
		var dist: float = delta.length()
		if dist >= UNIT_BUILD_MIN_DISTANCE and dist <= UNIT_BUILD_MAX_DISTANCE and can_unit_walk_at_world(requested) and not _is_position_too_close_to_runtime_building(requested):
			return requested
		return Vector3.INF
	var base_dir := Vector3.FORWARD
	if _camera != null and is_instance_valid(_camera):
		base_dir = -_camera.global_transform.basis.z
	base_dir.y = 0.0
	if base_dir.length_squared() < 0.0001:
		base_dir = Vector3.FORWARD
	base_dir = base_dir.normalized()
	for radius in [UNIT_BUILD_MIN_DISTANCE, (UNIT_BUILD_MIN_DISTANCE + UNIT_BUILD_MAX_DISTANCE) * 0.5, UNIT_BUILD_MAX_DISTANCE]:
		for angle_any in UNIT_BUILD_PLACE_ANGLES:
			var angle_deg: float = float(angle_any)
			var dir: Vector3 = base_dir.rotated(Vector3.UP, deg_to_rad(angle_deg)).normalized()
			var candidate: Vector3 = center + dir * radius
			candidate.y = terrain_height_at_world(candidate)
			if not can_unit_walk_at_world(candidate):
				continue
			if _is_position_too_close_to_runtime_building(candidate):
				continue
			return candidate
	var fallback: Vector3 = center + base_dir * UNIT_BUILD_MIN_DISTANCE
	fallback.y = terrain_height_at_world(fallback)
	return fallback

func _is_position_too_close_to_runtime_building(pos: Vector3) -> bool:
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return false
	for unit_any in (units_any as Array):
		if not (unit_any is Dictionary):
			continue
		var node: Dictionary = unit_any as Dictionary
		var type_key: String = String(node.get("type", "")).to_lower().strip_edges()
		var p_any: Variant = node.get("position", {})
		if not (p_any is Dictionary):
			continue
		var p: Dictionary = p_any as Dictionary
		var dx: float = float(p.get("x", 0.0)) - pos.x
		var dz: float = float(p.get("z", 0.0)) - pos.z
		var threshold: float = 140.0
		if type_key == "zhalan":
			threshold = ZHALAN_POST_BLOCK_RADIUS + 1.6
		var threshold_sq: float = threshold * threshold
		if dx * dx + dz * dz < threshold_sq:
			return true
	return false

func _find_nearest_owned_building_index(center: Vector2, faction_id: String, type_key: String, max_dist: float, require_basic_granary: bool, require_runtime_facility: bool = false) -> int:
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if not (units_any is Array):
		return -1
	var best_idx: int = -1
	var best_dist_sq: float = INF
	var max_sq: float = max_dist * max_dist
	for i in range((units_any as Array).size()):
		var unit_any: Variant = (units_any as Array)[i]
		if not (unit_any is Dictionary):
			continue
		var node: Dictionary = unit_any as Dictionary
		if String(node.get("faction_id", "")).strip_edges() != faction_id:
			continue
		var node_type: String = String(node.get("type", "")).to_lower().strip_edges()
		if not type_key.is_empty() and node_type != type_key:
			continue
		if require_runtime_facility and not _is_runtime_constructed_facility_type(node_type):
			continue
		if require_basic_granary and bool(node.get("is_advanced_granary", false)):
			continue
		var p_any: Variant = node.get("position", {})
		if not (p_any is Dictionary):
			continue
		var p: Dictionary = p_any as Dictionary
		var dx: float = float(p.get("x", 0.0)) - center.x
		var dz: float = float(p.get("z", 0.0)) - center.y
		var d2: float = dx * dx + dz * dz
		if d2 > max_sq:
			continue
		if d2 < best_dist_sq:
			best_dist_sq = d2
			best_idx = i
	return best_idx

func _is_runtime_constructed_facility_type(type_key: String) -> bool:
	return type_key == "muzhai" or type_key == "chengzhai" or type_key == "granary" or type_key == "jianlou" or type_key == "gaojijianlou" or type_key == "zhalan" or type_key == "taigutai" or type_key == "junyuetai"

func _next_runtime_facility_id(type_key: String, faction_id: String) -> String:
	var prefix: String = "%s_%s_" % [faction_id.to_lower(), type_key.to_lower()]
	var used: Dictionary = {}
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if units_any is Array:
		for unit_any in (units_any as Array):
			if not (unit_any is Dictionary):
				continue
			var id_text: String = String((unit_any as Dictionary).get("id", "")).strip_edges().to_lower()
			if not id_text.is_empty():
				used[id_text] = true
	for n in range(1, 1000):
		var candidate: String = "%s%03d" % [prefix, n]
		if not used.has(candidate):
			return candidate
	return "%s%d" % [prefix, Time.get_ticks_msec() % 100000]

func _upsert_world_city(city: Dictionary) -> void:
	var city_id: String = String(city.get("id", city.get("city_id", ""))).strip_edges()
	if city_id.is_empty():
		return
	var city_name: String = String(city.get("name", city_id)).strip_edges()
	var cities_any: Variant = _world_state_cache.get("cities", [])
	var cities: Array = cities_any as Array if cities_any is Array else []
	var found_idx: int = -1
	for i in range(cities.size()):
		var row_any: Variant = cities[i]
		if not (row_any is Dictionary):
			continue
		var row: Dictionary = row_any as Dictionary
		var row_id: String = String(row.get("id", row.get("city_id", ""))).strip_edges()
		var row_name: String = String(row.get("name", row_id)).strip_edges()
		if (not row_id.is_empty() and row_id == city_id) or (row_id.is_empty() and not city_name.is_empty() and row_name == city_name):
			found_idx = i
			break
	var payload: Dictionary = city.duplicate(true)
	payload["id"] = city_id
	if String(payload.get("city_id", "")).strip_edges().is_empty():
		payload["city_id"] = city_id
	if String(payload.get("name", "")).strip_edges().is_empty():
		payload["name"] = city_name if not city_name.is_empty() else city_id
	if found_idx >= 0:
		cities[found_idx] = payload
	else:
		cities.append(payload)
	_world_state_cache["cities"] = cities
	_sync_world_city_alias(payload)

func _sync_world_city_alias(city: Dictionary) -> void:
	var city_id: String = String(city.get("id", city.get("city_id", ""))).strip_edges()
	if not city_id.is_empty():
		_put_dict_alias(_world_city_by_id, city_id, city.duplicate(true))
	var city_name: String = String(city.get("name", city_id)).strip_edges()
	if not city_name.is_empty():
		_put_dict_alias(_world_city_by_name, city_name, city.duplicate(true))

func _upsert_world_building_unit(node: Dictionary) -> void:
	var node_id: String = String(node.get("id", node.get("city_id", ""))).strip_edges()
	if node_id.is_empty():
		return
	var node_name: String = String(node.get("name", node_id)).strip_edges()
	var units_any: Variant = _world_state_cache.get("building_units", [])
	var units: Array = units_any as Array if units_any is Array else []
	var found_idx: int = -1
	for i in range(units.size()):
		var row_any: Variant = units[i]
		if not (row_any is Dictionary):
			continue
		var row: Dictionary = row_any as Dictionary
		var row_id: String = String(row.get("id", row.get("city_id", ""))).strip_edges()
		var row_name: String = String(row.get("name", row_id)).strip_edges()
		if (not row_id.is_empty() and row_id == node_id) or (row_id.is_empty() and not node_name.is_empty() and row_name == node_name):
			found_idx = i
			break
	var payload: Dictionary = node.duplicate(true)
	payload["id"] = node_id
	if String(payload.get("name", "")).strip_edges().is_empty():
		payload["name"] = node_name if not node_name.is_empty() else node_id
	if found_idx >= 0:
		units[found_idx] = payload
	else:
		units.append(payload)
	_world_state_cache["building_units"] = units
	_sync_world_building_alias(payload)

func _append_world_building_unit(node: Dictionary) -> void:
	var units_any: Variant = _world_state_cache.get("building_units", [])
	var units: Array = units_any as Array if units_any is Array else []
	units.append(node.duplicate(true))
	_world_state_cache["building_units"] = units
	_sync_world_building_alias(node)

func _sync_world_building_alias(node: Dictionary) -> void:
	var node_id: String = String(node.get("id", "")).strip_edges()
	if not node_id.is_empty():
		_put_dict_alias(_world_building_by_id, node_id, node.duplicate(true))
	var node_name: String = String(node.get("name", node_id)).strip_edges()
	if not node_name.is_empty():
		_put_dict_alias(_world_building_by_name, node_name, node.duplicate(true))

func query_terrain_from_screen(screen_pos: Vector2) -> Dictionary:
	if _camera == null:
		return {}
	var from: Vector3 = _camera.project_ray_origin(screen_pos)
	var dir: Vector3 = _camera.project_ray_normal(screen_pos)
	var to: Vector3 = from + dir * TERRAIN_RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	var world_pos: Vector3 = hit.get("position", Vector3.INF)
	if world_pos == Vector3.INF:
		var plane_hit = Plane(Vector3.UP, 0.0).intersects_ray(from, dir)
		if plane_hit == null:
			return {}
		world_pos = plane_hit
	world_pos.y = terrain_height_at_world(world_pos)
	return {
		"position": world_pos,
		"terrain_type": terrain_type_at_world(world_pos)
	}

func get_player_faction_id() -> String:
	return _get_player_faction_id()

func get_attack_target_from_screen(screen_pos: Vector2, attacker_faction_id: String = "") -> Dictionary:
	var picked_id: String = _pick_building_from_screen(screen_pos).strip_edges()
	if picked_id.is_empty():
		return {}
	var site: Dictionary = _get_site_snapshot(picked_id)
	if site.is_empty():
		return {}
	var type_key: String = String(site.get("type", "")).to_lower().strip_edges()
	if type_key.is_empty():
		if _resolve_world_city(picked_id, String(site.get("name", picked_id))).is_empty():
			type_key = String(_resolve_world_building(picked_id, String(site.get("name", picked_id))).get("type", "site")).to_lower().strip_edges()
		else:
			type_key = "city"
	if not _is_runtime_siege_target_type(type_key):
		return {}
	var target_faction: String = String(site.get("faction_id", "")).strip_edges()
	if target_faction.is_empty():
		target_faction = String(_resolve_world_building(picked_id, String(site.get("name", picked_id))).get("faction_id", "")).strip_edges()
	if not attacker_faction_id.strip_edges().is_empty() and not target_faction.is_empty() and target_faction == attacker_faction_id.strip_edges():
		return {}
	var world_pos: Vector3 = _resolve_site_world_position(picked_id, site)
	if world_pos == Vector3.INF:
		var site_id: String = String(site.get("id", "")).strip_edges()
		if not site_id.is_empty() and site_id != picked_id:
			world_pos = _resolve_site_world_position(site_id, site)
	if world_pos == Vector3.INF:
		return {}
	var site_id_out: String = String(site.get("id", picked_id)).strip_edges()
	if site_id_out.is_empty():
		site_id_out = picked_id
	var display_name: String = String(site.get("name", site_id_out)).strip_edges()
	if display_name.is_empty():
		display_name = site_id_out
	return {
		"id": site_id_out,
		"name": display_name,
		"type": type_key,
		"faction_id": target_faction,
		"engage_radius": _runtime_siege_target_radius(type_key),
		"position": {
			"x": float(world_pos.x),
			"z": float(world_pos.z)
		}
	}

func _resolve_site_world_position(site_id: String, site: Dictionary = {}) -> Vector3:
	var mobile_node: Node3D = _runtime_mobile_units.get(site_id, null) as Node3D
	if mobile_node != null and is_instance_valid(mobile_node):
		return mobile_node.global_position
	var runtime_node: Node3D = _runtime_unit_nodes.get(site_id, null) as Node3D
	if runtime_node != null and is_instance_valid(runtime_node):
		return runtime_node.global_position
	var city_snap: Dictionary = _get_city_snapshot(site_id)
	if not city_snap.is_empty():
		var city_pos_any: Variant = city_snap.get("position", {})
		if city_pos_any is Dictionary:
			var city_pos: Dictionary = city_pos_any as Dictionary
			var city_world := Vector3(float(city_pos.get("x", 0.0)), 0.0, float(city_pos.get("z", 0.0)))
			city_world.y = terrain_height_at_world(city_world)
			return city_world
	if _strategic_site_manager != null:
		var site_root: Node = _strategic_site_manager.get_node_or_null("SiteInstances")
		if site_root != null:
			for child in site_root.get_children():
				if not (child is Node3D):
					continue
				var site_node := child as Node3D
				var node_id: String = String(site_node.get_meta("building_id", "")).strip_edges()
				if node_id.is_empty():
					var node_name: String = String(site_node.name)
					if node_name.begins_with("Site_"):
						node_id = node_name.trim_prefix("Site_")
				if node_id == site_id:
					return site_node.global_position
	var pos_any: Variant = site.get("position", {})
	if pos_any is Dictionary:
		var pos: Dictionary = pos_any as Dictionary
		var world := Vector3(float(pos.get("x", 0.0)), 0.0, float(pos.get("z", 0.0)))
		world.y = terrain_height_at_world(world)
		return world
	return Vector3.INF

func _is_runtime_build_placement_active() -> bool:
	if _battle_runtime == null or not is_instance_valid(_battle_runtime):
		return false
	if _battle_runtime.has_method("is_build_placement_active"):
		return bool(_battle_runtime.call("is_build_placement_active"))
	if _battle_runtime.has_method("_is_build_placement_active"):
		return bool(_battle_runtime.call("_is_build_placement_active"))
	return false

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.is_echo():
			if key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER:
				if _runtime_phase == RUNTIME_PHASE_INTERNAL:
					_on_runtime_proceed_battle_requested()
				else:
					_on_runtime_battle_pause_toggled(not _runtime_battle_paused)
				return
			if key_event.keycode == KEY_F10:
				_supply_debug_enabled = not _supply_debug_enabled
				_refresh_supply_debug_overlay()
				return
			if key_event.keycode == KEY_F9:
				refresh_supply_fog_now()
				return
			if key_event.keycode == KEY_G:
				_debug_advance_xun_turn()
				return
			if key_event.keycode == KEY_L:
				_toggle_supply_corridor_view()
				return
			if key_event.keycode == KEY_U:
				_try_runtime_facility_action_from_selection("upgrade")
				return
			if key_event.keycode == KEY_H:
				_try_runtime_facility_action_from_selection("repair")
				return
			if key_event.keycode == KEY_DELETE:
				_try_runtime_facility_action_from_selection("destroy")
				return
	if _camera == null:
		return
	if not (event is InputEventMouseButton):
		return
	var mb: InputEventMouseButton = event
	if not mb.pressed or mb.is_echo():
		return
	if _is_runtime_build_placement_active():
		return
	if mb.button_index == MOUSE_BUTTON_RIGHT:
		try_open_facility_context_menu(mb.position)
		return
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return
	if _pointer_hits_runtime_mobile_unit(mb.position):
		return
	if _runtime_ui_layer != null:
		var hovered: Control = get_viewport().gui_get_hovered_control()
		if hovered != null and _runtime_ui_layer.is_pointer_over_interactive_ui(hovered):
			return
	var building_id: String = _pick_building_from_screen(mb.position)
	if building_id.is_empty():
		if _runtime_ui_layer != null:
			_runtime_ui_layer.hide_city_command_menu()
		return
	_show_site_management_menu(building_id, mb.position)

func _debug_advance_xun_turn() -> void:
	var rules_any: Variant = _runtime_time_weather.get("rules", {})
	var rules: Dictionary = rules_any as Dictionary if rules_any is Dictionary else _build_time_weather_rules({})
	var days_per_turn: float = maxf(1.0, float(rules.get("days_per_turn", 10.0)))
	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	meta["calendar_day"] = maxf(1.0, float(meta.get("calendar_day", 1.0)) + days_per_turn)
	_world_state_cache["meta"] = meta
	_sync_runtime_time_weather_state(true)
	_refresh_supply_fog_runtime(true)
	_refresh_runtime_ui_hud(true)
	if _runtime_ui_layer != null:
		var day_phase: String = String(_runtime_time_weather.get("day_phase", "day"))
		var weather_state: String = String(_runtime_time_weather.get("weather_state", "sunny"))
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "璋冭瘯鎺ㄨ繘涓€鏃細%s | %s" % [day_phase, weather_state])

func _pick_building_from_screen(screen_pos: Vector2) -> String:
	var from: Vector3 = _camera.project_ray_origin(screen_pos)
	var to: Vector3 = from + _camera.project_ray_normal(screen_pos) * TERRAIN_RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = BUILDING_COLLISION_LAYER
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return _pick_city_from_screen(screen_pos)
	var collider: Object = hit.get("collider") as Object
	if collider == null:
		return _pick_city_from_screen(screen_pos)
	if collider.has_meta("building_id"):
		return String(collider.get_meta("building_id"))
	var parent: Node = (collider as Node).get_parent() if collider is Node else null
	if parent != null and parent.has_meta("building_id"):
		return String(parent.get_meta("building_id"))
	return _pick_city_from_screen(screen_pos)

func _pick_city_from_screen(screen_pos: Vector2) -> String:
	if _city_overlay == null or _camera == null:
		return ""
	var city_root: Node = _city_overlay.get_node_or_null("CityInstances")
	if city_root == null:
		return ""
	var best_name: String = ""
	var best_dist_sq: float = INF
	var capture_px: float = clampf(52.0 - _camera.fov * 0.18, 24.0, 48.0)
	var capture_px_sq: float = capture_px * capture_px
	for child in city_root.get_children():
		if not (child is Node3D):
			continue
		var city_node := child as Node3D
		var city_name: String = String(city_node.get_meta("city_name", city_node.name.trim_prefix("City_"))).strip_edges()
		if city_name.is_empty():
			continue
		var world_anchor: Vector3 = city_node.global_position + Vector3(0.0, 12.0, 0.0)
		if _camera.is_position_behind(world_anchor):
			continue
		var screen_anchor: Vector2 = _camera.unproject_position(world_anchor)
		var d2: float = screen_anchor.distance_squared_to(screen_pos)
		if d2 > capture_px_sq:
			continue
		if d2 < best_dist_sq:
			best_dist_sq = d2
			best_name = city_name
	return best_name

func _show_site_management_menu(site_id: String, screen_pos: Vector2) -> void:
	var site: Dictionary = _get_site_snapshot(site_id)
	var menu_site_id: String = site_id
	var site_type: String = String(site.get("type", "")).to_lower().strip_edges()
	if site_type == "city":
		var resolved_city_id: String = String(site.get("city_id", site.get("id", site_id))).strip_edges()
		if not resolved_city_id.is_empty():
			menu_site_id = resolved_city_id
	_selected_site_id = menu_site_id
	if _strategic_site_manager != null and _strategic_site_manager.has_method("set_selected_site"):
		_strategic_site_manager.call("set_selected_site", menu_site_id)
	if _runtime_ui_layer == null:
		return
	var site_name: String = str(site.get("name", site_id))
	if site_type == "ferry":
		var ferry_actions: Array = [
			{
				"id": "aides",
				"label": "Aides",
				"desc": "Manage ferry aides and support staff here."
			}
		]
		_runtime_ui_layer.show_site_action_menu(menu_site_id, site_name, screen_pos, ferry_actions)
		return
	if _is_player_owned_runtime_facility(site):
		var upgrade_ready: bool = _runtime_facility_has_upgrade(site)
		var actions: Array = [
			{
				"id": "facility_upgrade",
				"label": "Upgrade",
				"desc": "Upgrade this facility. %s" % ("Upgrade available now." if upgrade_ready else "No upgrade available.")
			},
			{
				"id": "facility_repair",
				"label": "Repair",
				"desc": "Repair this facility and restore its HP over time."
			},
			{
				"id": "facility_destroy",
				"label": "Destroy",
				"desc": "Order nearby troops to dismantle this facility."
			}
		]
		_runtime_ui_layer.show_site_action_menu(menu_site_id, site_name, screen_pos, actions)
		return
	_runtime_ui_layer.show_city_command_menu(menu_site_id, site_name, screen_pos)

func try_open_facility_context_menu(screen_pos: Vector2) -> bool:
	if _camera == null:
		return false
	if _runtime_ui_layer != null:
		var hovered: Control = get_viewport().gui_get_hovered_control()
		if hovered != null and _runtime_ui_layer.is_pointer_over_interactive_ui(hovered):
			return false
	var site_id: String = _pick_building_from_screen(screen_pos)
	if site_id.is_empty():
		return false
	var site: Dictionary = _get_site_snapshot(site_id)
	if not _is_player_owned_runtime_facility(site):
		return false
	_show_site_management_menu(site_id, screen_pos)
	return true

func _is_player_owned_runtime_facility(site: Dictionary) -> bool:
	if site.is_empty():
		return false
	var type_key: String = String(site.get("type", "")).to_lower().strip_edges()
	if not _is_runtime_constructed_facility_type(type_key):
		return false
	var faction_id: String = String(site.get("faction_id", "")).strip_edges()
	return not faction_id.is_empty() and faction_id == _get_player_faction_id()

func _runtime_facility_has_upgrade(site: Dictionary) -> bool:
	var type_key: String = String(site.get("type", "")).to_lower().strip_edges()
	if bool(site.get("awaiting_builder_arrival", false)) or bool(site.get("is_under_construction", false)):
		return false
	if bool(site.get("operation_active", false)):
		return false
	if type_key == "muzhai":
		return true
	if type_key == "granary":
		return not bool(site.get("is_advanced_granary", false))
	if type_key == "jianlou":
		return true
	if type_key == "taigutai":
		return true
	return false

func _try_runtime_facility_action_from_selection(action_kind: String) -> void:
	if _selected_site_id.is_empty():
		return
	var site: Dictionary = _get_site_snapshot(_selected_site_id)
	if not _is_player_owned_runtime_facility(site):
		return
	var fake_unit: Dictionary = {
		"id": "_facility_action_proxy",
		"type": "field_unit",
		"faction_id": String(site.get("faction_id", "")),
		"position": (site.get("position", {}) as Dictionary).duplicate(true),
		"city_id": String(site.get("city_id", site.get("id", "")))
	}
	var result: Dictionary = {}
	match action_kind:
		"upgrade":
			var t: String = String(site.get("type", "")).to_lower().strip_edges()
			var action_id: String = ""
			if t == "muzhai":
				action_id = "upgrade_chengzhai"
			elif t == "granary" and not bool(site.get("is_advanced_granary", false)):
				action_id = "upgrade_junliangbao"
			elif t == "jianlou":
				action_id = "upgrade_gaojijianlou"
			elif t == "taigutai":
				action_id = "upgrade_junyuetai"
			if action_id.is_empty():
				result = {"ok": false, "message": "No valid upgrade available for this facility."}
			else:
				result = _upgrade_unit_built_facility(fake_unit, String(site.get("faction_id", "")), action_id, String(site.get("id", _selected_site_id)))
		"repair":
			result = _repair_nearby_facility(fake_unit, String(site.get("faction_id", "")), String(site.get("id", _selected_site_id)))
		"destroy":
			result = _destroy_nearby_facility(fake_unit, String(site.get("faction_id", "")), String(site.get("id", _selected_site_id)))
		_:
			return
	if _runtime_ui_layer != null:
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), String(result.get("message", "")))

func _get_site_snapshot(site_id: String) -> Dictionary:
	var mobile_unit: Dictionary = _runtime_mobile_unit_snapshot(site_id)
	if not mobile_unit.is_empty():
		return mobile_unit
	var runtime_unit: Dictionary = _get_runtime_unit_snapshot(site_id)
	if not runtime_unit.is_empty():
		return runtime_unit
	var city_snap: Dictionary = _get_city_snapshot(site_id)
	if not city_snap.is_empty():
		return city_snap
	if _strategic_site_manager == null or not _strategic_site_manager.has_method("get_site_snapshot"):
		return {}
	var snap_any: Variant = _strategic_site_manager.call("get_site_snapshot", site_id)
	if not (snap_any is Dictionary):
		return {}
	var snap: Dictionary = (snap_any as Dictionary).duplicate(true)
	if snap.is_empty():
		return {}
	if String(snap.get("id", "")).is_empty():
		snap["id"] = site_id
	if String(snap.get("city_id", "")).is_empty():
		snap["city_id"] = site_id
	if String(snap.get("name", "")).is_empty():
		snap["name"] = site_id
	return snap

func _get_city_snapshot(site_id: String) -> Dictionary:
	var target_id: String = site_id.strip_edges()
	if target_id.is_empty():
		return {}
	if _city_overlay == null:
		return {}
	var city_root: Node = _city_overlay.get_node_or_null("CityInstances")
	if city_root == null:
		return {}
	for child in city_root.get_children():
		if not (child is Node3D):
			continue
		var city_node := child as Node3D
		var city_name: String = String(city_node.get_meta("city_name", city_node.name.trim_prefix("City_"))).strip_edges()
		if city_name.is_empty():
			continue
		var world_city: Dictionary = _resolve_world_city(city_name, city_name)
		var world_city_id: String = String(world_city.get("id", city_name)).strip_edges()
		var world_city_alias: String = String(world_city.get("city_id", world_city_id)).strip_edges()
		if city_name != target_id and world_city_id != target_id and world_city_alias != target_id:
			continue
		var state_name: String = String(city_node.get_meta("state", "")).strip_edges()
		if not world_city.is_empty():
			if String(world_city.get("id", "")).is_empty():
				world_city["id"] = city_name
			world_city["city_id"] = String(world_city.get("id", city_name))
			world_city["type"] = "city"
			if String(world_city.get("name", "")).is_empty():
				world_city["name"] = city_name
			if String(world_city.get("state", "")).is_empty() and not state_name.is_empty():
				world_city["state"] = state_name
			var pos_any: Variant = world_city.get("position", null)
			if not (pos_any is Dictionary):
				world_city["position"] = {
					"x": int(round(city_node.global_position.x)),
					"z": int(round(city_node.global_position.z))
				}
			return world_city
		return {
			"id": city_name,
			"city_id": city_name,
			"name": city_name,
			"type": "city",
			"state": state_name,
			"position": {
				"x": int(round(city_node.global_position.x)),
				"z": int(round(city_node.global_position.z))
			}
		}
	return {}

func _reset_site_hover_tracking() -> void:
	_site_hover_candidate_id = ""
	_site_hover_candidate_elapsed = 0.0

func _update_hover_info(delta: float = 0.0) -> void:
	if _runtime_ui_layer == null:
		return
	var hover_delay: float = maxf(0.0, site_hover_panel_show_delay_sec)
	var hovered: Control = get_viewport().gui_get_hovered_control()
	if hovered != null and _runtime_ui_layer.is_pointer_over_interactive_ui(hovered):
		_reset_site_hover_tracking()
		_runtime_ui_layer.hide_hover_info()
		return
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var site_id: String = _pick_building_from_screen(mouse_pos)
	if site_id.is_empty():
		_reset_site_hover_tracking()
		_runtime_ui_layer.hide_hover_info()
		return
	if site_id != _site_hover_candidate_id:
		_site_hover_candidate_id = site_id
		_site_hover_candidate_elapsed = 0.0
		if hover_delay > 0.001:
			_runtime_ui_layer.hide_hover_info()
			return
	else:
		_site_hover_candidate_elapsed += maxf(0.0, delta)
	if _site_hover_candidate_elapsed + 0.0001 < hover_delay:
		_runtime_ui_layer.hide_hover_info()
		return
	var hover_text: String = _compose_site_hover_text(site_id)
	if hover_text.strip_edges().is_empty():
		_reset_site_hover_tracking()
		_runtime_ui_layer.hide_hover_info()
		return
	_runtime_ui_layer.show_hover_info(mouse_pos, hover_text)

func _compose_site_hover_text(site_id: String) -> String:
	var site: Dictionary = _get_site_snapshot(site_id)
	if site.is_empty():
		return ""
	var site_name: String = str(site.get("name", site_id))
	var world_city: Dictionary = _resolve_world_city(String(site.get("city_id", site.get("id", site_id))), site_name)
	if world_city.is_empty():
		world_city = _resolve_world_city(String(site.get("id", "")), site_name)
	if not world_city.is_empty():
		return _compose_city_hover_text(site, world_city)
	var world_building: Dictionary = _resolve_world_building(String(site.get("id", site_id)), site_name)
	if world_building.is_empty():
		world_building = _resolve_world_building(site_id, site_name)
	if not world_building.is_empty():
		return _compose_outpost_hover_text(site, world_building)
	return _compose_generic_site_hover_text(site, site_id)

func _site_type_label(site_type: String) -> String:
	match site_type:
		"city":
			return "City"
		"pass":
			return "Pass"
		"ferry":
			return "Ferry"
		"fort":
			return "Fort"
		"field_unit":
			return "Field Unit"
		"granary":
			return "Granary"
		"convoy":
			return "Supply Convoy"
		"muzhai":
			return "Wood Stockade"
		"chengzhai":
			return "Fortified Stockade"
		"jianlou":
			return "Arrow Tower"
		"gaojijianlou":
			return "Advanced Arrow Tower"
		"zhalan":
			return "Palisade"
		"taigutai":
			return "Drum Platform"
		"junyuetai":
			return "Military Bandstand"
		_:
			return site_type

func _compose_city_hover_text(site: Dictionary, city: Dictionary) -> String:
	var city_name: String = String(city.get("name", site.get("name", site.get("id", "City"))))
	var faction_id: String = String(city.get("faction_id", site.get("faction_id", "")))
	var faction_name: String = _resolve_faction_name(faction_id)
	if faction_name.strip_edges().is_empty() or faction_name == "-":
		faction_name = "N/A"
	var size_key: String = _normalize_city_scale(String((city.get("classification", {}) as Dictionary).get("scale", city.get("scale", "medium"))))
	var caps: Dictionary = _city_caps_for_scale(size_key)
	var size_label: String = _city_scale_label(size_key)
	var personnel: Dictionary = city.get("personnel", {})
	var governor_name: String = String(personnel.get("governor_name", "-"))
	if governor_name.strip_edges().is_empty() or governor_name == "-":
		governor_name = "N/A"
	var dev: Dictionary = city.get("development", {})
	var resources: Dictionary = city.get("resources", {})
	var stats: Dictionary = city.get("stats", {})
	var defense: Dictionary = city.get("defense", {})
	var income: Dictionary = _estimate_city_periodic_income(city)
	var tax_info: Dictionary = _resolve_tax_info(city, dev)
	var tech_info: Dictionary = _resolve_tech_info(city, dev)
	var money_now: Dictionary = _optional_number(resources, "money")
	var food_now: Dictionary = _optional_number(resources, "food")
	var iron_now: Dictionary = _optional_number(resources, "iron")
	var wood_now: Dictionary = _optional_number(resources, "wood")
	var horse_now: Dictionary = _optional_number(resources, "horse")
	var money_income: Dictionary = _optional_number(income, "money_month")
	var food_income: Dictionary = _optional_number(income, "food_quarter")
	var iron_income: Dictionary = _optional_number(income, "iron_month")
	var wood_income: Dictionary = _optional_number(income, "wood_month")
	var horse_income: Dictionary = _optional_number(income, "horse_month")
	var support_now: Dictionary = _optional_number(stats, "public_support")
	var security_now: Dictionary = _optional_number(stats, "security")
	var tech_now: Dictionary = {"has": tech_info.has("value"), "value": float(tech_info.get("value", 0.0))}
	var population_now: Dictionary = _optional_number(stats, "population")
	var conscription_now: Dictionary = _optional_number(stats, "conscription_population")
	var reserve_now: Dictionary = _optional_number(stats, "reserve_troops")
	var organized_now: Dictionary = _optional_number(stats, "organized_troops")
	var troops_now: Dictionary = _optional_number(stats, "troops")
	var defense_now: Dictionary = _optional_number(defense, "current")
	var defense_max_now: Dictionary = _optional_number(defense, "max")
	var lines: Array[String] = []
	lines.append("[b]%s[/b]" % city_name)
	lines.append("Faction: %s" % faction_name)
	lines.append("Type: %s" % _site_type_label("city"))
	lines.append("City Size: %s" % size_label)
	lines.append("City Caps: Commerce<=%d  Agriculture<=%d  Industry<=%d  Barracks<=%d  Stables<=%d" % [
		int(caps.get("commerce_max", 0)),
		int(caps.get("agriculture_max", 0)),
		int(caps.get("industry_max", 0)),
		int(caps.get("barracks_max", 0)),
		int(caps.get("stables_max", 0))
	])
	lines.append("Defense Cap: %s  |  Resource Caps M/F/I/W/H: %s / %s / %s / %s / %s" % [
		_fmt_num(float(caps.get("defense_max", 0.0))),
		_fmt_num(float(caps.get("money_cap", 0.0))),
		_fmt_num(float(caps.get("food_cap", 0.0))),
		_fmt_num(float(caps.get("iron_cap", 0.0))),
		_fmt_num(float(caps.get("wood_cap", 0.0))),
		_fmt_num(float(caps.get("horse_cap", 0.0)))
	])
	lines.append("Governor: %s" % governor_name)
	lines.append("%s: %.1f%%" % [String(tax_info.get("label", "Tax Rate")), float(tax_info.get("value", 0.0)) * 100.0])
	lines.append("Money: %s (%s)" % [
		_fmt_optional_num(money_now),
		_fmt_optional_delta(money_income, "mo")
	])
	lines.append("Food: %s (%s)" % [
		_fmt_optional_num(food_now),
		_fmt_optional_delta(food_income, "season")
	])
	lines.append("Iron: %s (%s)" % [
		_fmt_optional_num(iron_now),
		_fmt_optional_delta(iron_income, "mo")
	])
	lines.append("Wood: %s (%s)" % [
		_fmt_optional_num(wood_now),
		_fmt_optional_delta(wood_income, "mo")
	])
	lines.append("Horses: %s (%s)" % [
		_fmt_optional_num(horse_now),
		_fmt_optional_delta(horse_income, "mo")
	])
	lines.append("Public Support / Security / %s: %s / %s / %s" % [
		String(tech_info.get("label", "Tech")),
		_fmt_optional_rounded(support_now),
		_fmt_optional_rounded(security_now),
		_fmt_optional_rounded(tech_now)
	])
	lines.append("Population / Conscription Pool: %s / %s" % [
		_fmt_optional_num(population_now),
		_fmt_optional_num(conscription_now)
	])
	lines.append("Troops (Reserve / Organized / Total): %s / %s / %s" % [
		_fmt_optional_num(reserve_now),
		_fmt_optional_num(organized_now),
		_fmt_optional_num(troops_now)
	])
	lines.append("Defense (Current / Max): %s / %s" % [
		_fmt_optional_num(defense_now),
		_fmt_optional_num(defense_max_now if bool(defense_max_now.get("has", false)) else {"has": true, "value": float(caps.get("defense_max", 0.0))})
	])
	return "[font_size=20]%s[/font_size]" % "\n".join(lines)

func _compose_outpost_hover_text(site: Dictionary, outpost: Dictionary) -> String:
	var site_name: String = String(outpost.get("name", site.get("name", site.get("id", "Site"))))
	var site_type: String = String(outpost.get("type", site.get("type", "site")))
	var faction_id: String = String(outpost.get("faction_id", site.get("faction_id", "")))
	var faction_name: String = _resolve_faction_name(faction_id)
	if faction_name.strip_edges().is_empty() or faction_name == "-":
		faction_name = "N/A"
	var personnel: Dictionary = outpost.get("personnel", site.get("personnel", {}))
	var governor_name: String = String(personnel.get("governor_name", "-"))
	if governor_name.strip_edges().is_empty() or governor_name == "-":
		governor_name = "N/A"
	var resources: Dictionary = outpost.get("resources", site.get("resources", {}))
	var stats: Dictionary = outpost.get("stats", site.get("stats", {}))
	var defense: Dictionary = outpost.get("defense", site.get("defense", {}))
	var garrison: Dictionary = outpost.get("garrison", site.get("garrison", {}))
	var periodic: Dictionary = outpost.get("periodic_income", {})
	var tax_info: Dictionary = _resolve_tax_info(outpost, {})
	var tech_info: Dictionary = _resolve_tech_info(outpost, {})
	var money_now: Dictionary = _optional_number(resources, "money")
	var food_now: Dictionary = _optional_number(resources, "food")
	var iron_now: Dictionary = _optional_number(resources, "iron")
	var wood_now: Dictionary = _optional_number(resources, "wood")
	var horse_now: Dictionary = _optional_number(resources, "horse")
	var money_income: Dictionary = _optional_number(periodic, "money_monthly")
	var food_income: Dictionary = _optional_number(periodic, "food_quarterly", ["food_monthly"])
	if bool(food_income.get("has", false)) and periodic.has("food_monthly") and not periodic.has("food_quarterly"):
		food_income["value"] = float(food_income.get("value", 0.0)) * 3.0
	var iron_income: Dictionary = _optional_number(periodic, "iron_monthly")
	var wood_income: Dictionary = _optional_number(periodic, "wood_monthly")
	var horse_income: Dictionary = _optional_number(periodic, "horse_monthly")
	var support_now: Dictionary = _optional_number(stats, "public_support")
	var security_now: Dictionary = _optional_number(stats, "security")
	var tech_now: Dictionary = {"has": tech_info.has("value"), "value": float(tech_info.get("value", 0.0))}
	var reserve_now: Dictionary = _optional_number(garrison, "reserve_troops")
	var organized_now: Dictionary = _optional_number(garrison, "organized_troops")
	var defense_now: Dictionary = _optional_number(defense, "current")
	var defense_max_now: Dictionary = _optional_number(defense, "max")
	var lines: Array[String] = []
	lines.append("[b]%s[/b]" % site_name)
	lines.append("Faction: %s" % faction_name)
	lines.append("Type: %s" % _site_type_label(site_type))
	lines.append("Governor: %s" % governor_name)
	lines.append("%s: %.1f%%" % [String(tax_info.get("label", "Tax Rate")), float(tax_info.get("value", 0.0)) * 100.0])
	lines.append("Money: %s (%s)" % [
		_fmt_optional_num(money_now),
		_fmt_optional_delta(money_income, "mo")
	])
	lines.append("Food: %s (%s)" % [
		_fmt_optional_num(food_now),
		_fmt_optional_delta(food_income, "season")
	])
	lines.append("Iron: %s (%s)" % [
		_fmt_optional_num(iron_now),
		_fmt_optional_delta(iron_income, "mo")
	])
	lines.append("Wood: %s (%s)" % [
		_fmt_optional_num(wood_now),
		_fmt_optional_delta(wood_income, "mo")
	])
	lines.append("Horses: %s (%s)" % [
		_fmt_optional_num(horse_now),
		_fmt_optional_delta(horse_income, "mo")
	])
	lines.append("Public Support / Security / %s: %s / %s / %s" % [
		String(tech_info.get("label", "Tech")),
		_fmt_optional_rounded(support_now),
		_fmt_optional_rounded(security_now),
		_fmt_optional_rounded(tech_now)
	])
	lines.append("Troops (Reserve / Organized): %s / %s" % [
		_fmt_optional_num(reserve_now),
		_fmt_optional_num(organized_now)
	])
	lines.append("Defense (Current / Max): %s / %s" % [
		_fmt_optional_num(defense_now),
		_fmt_optional_num(defense_max_now)
	])
	return "[font_size=20]%s[/font_size]" % "\n".join(lines)

func _compose_generic_site_hover_text(site: Dictionary, site_id: String) -> String:
	var lines: Array[String] = []
	var site_name: String = str(site.get("name", site_id))
	var site_type: String = str(site.get("type", "site"))
	var faction_name: String = _resolve_faction_name(str(site.get("faction_id", "")))
	if faction_name.strip_edges().is_empty() or faction_name == "-":
		faction_name = "N/A"
	var personnel: Dictionary = site.get("personnel", {})
	var governor_name: String = String(personnel.get("governor_name", "N/A"))
	if governor_name.strip_edges().is_empty() or governor_name == "-":
		governor_name = "N/A"
	var resources: Dictionary = site.get("resources", {})
	var stats: Dictionary = site.get("stats", {})
	var defense: Dictionary = site.get("defense", {})
	var garrison: Dictionary = site.get("garrison", {})
	var periodic: Dictionary = site.get("periodic_income", {})
	var tax_info: Dictionary = _resolve_tax_info(site, {})
	var tech_info: Dictionary = _resolve_tech_info(site, {})
	var money_now: Dictionary = _optional_number(resources, "money")
	var food_now: Dictionary = _optional_number(resources, "food")
	var iron_now: Dictionary = _optional_number(resources, "iron")
	var wood_now: Dictionary = _optional_number(resources, "wood")
	var horse_now: Dictionary = _optional_number(resources, "horse")
	var money_income: Dictionary = _optional_number(periodic, "money_monthly")
	var food_income: Dictionary = _optional_number(periodic, "food_quarterly", ["food_monthly"])
	if bool(food_income.get("has", false)) and periodic.has("food_monthly") and not periodic.has("food_quarterly"):
		food_income["value"] = float(food_income.get("value", 0.0)) * 3.0
	var iron_income: Dictionary = _optional_number(periodic, "iron_monthly")
	var wood_income: Dictionary = _optional_number(periodic, "wood_monthly")
	var horse_income: Dictionary = _optional_number(periodic, "horse_monthly")
	var support_now: Dictionary = _optional_number(stats, "public_support")
	var security_now: Dictionary = _optional_number(stats, "security")
	var tech_now: Dictionary = {"has": tech_info.has("value"), "value": float(tech_info.get("value", 0.0))}
	var reserve_now: Dictionary = _optional_number(garrison, "reserve_troops")
	var organized_now: Dictionary = _optional_number(garrison, "organized_troops")
	var defense_now: Dictionary = _optional_number(defense, "current")
	var defense_max_now: Dictionary = _optional_number(defense, "max")
	lines.append("[b]%s[/b]" % site_name)
	lines.append("Faction: %s" % faction_name)
	lines.append("Type: %s" % _site_type_label(site_type))
	lines.append("Governor: %s" % governor_name)
	lines.append("%s: %.1f%%" % [String(tax_info.get("label", "Tax Rate")), float(tax_info.get("value", 0.0)) * 100.0])
	lines.append("Money: %s (%s)" % [
		_fmt_optional_num(money_now),
		_fmt_optional_delta(money_income, "mo")
	])
	lines.append("Food: %s (%s)" % [
		_fmt_optional_num(food_now),
		_fmt_optional_delta(food_income, "season")
	])
	lines.append("Iron: %s (%s)" % [
		_fmt_optional_num(iron_now),
		_fmt_optional_delta(iron_income, "mo")
	])
	lines.append("Wood: %s (%s)" % [
		_fmt_optional_num(wood_now),
		_fmt_optional_delta(wood_income, "mo")
	])
	lines.append("Horses: %s (%s)" % [
		_fmt_optional_num(horse_now),
		_fmt_optional_delta(horse_income, "mo")
	])
	lines.append("Public Support / Security / %s: %s / %s / %s" % [
		String(tech_info.get("label", "Tech")),
		_fmt_optional_rounded(support_now),
		_fmt_optional_rounded(security_now),
		_fmt_optional_rounded(tech_now)
	])
	lines.append("Troops (Reserve / Organized): %s / %s" % [
		_fmt_optional_num(reserve_now),
		_fmt_optional_num(organized_now)
	])
	lines.append("Defense (Current / Max): %s / %s" % [
		_fmt_optional_num(defense_now),
		_fmt_optional_num(defense_max_now)
	])
	var state_name: String = str(site.get("state", "")).strip_edges()
	var belong_city: String = str(site.get("belong_city", "")).strip_edges()
	if not state_name.is_empty() and not belong_city.is_empty():
		lines.append("Region: %s - %s" % [state_name, belong_city])
	elif not state_name.is_empty():
		lines.append("Region: %s" % state_name)
	var history_event: String = str(site.get("history_event", "")).strip_edges()
	if not history_event.is_empty():
		lines.append("Historical Event: %s" % history_event)
	var source: String = str(site.get("history_source", "")).strip_edges()
	if not source.is_empty():
		lines.append("Source: %s" % source)
	return "[font_size=20]%s[/font_size]" % "\n".join(lines)

func _normalize_city_scale(scale_key: String) -> String:
	var raw: String = scale_key.strip_edges().to_lower()
	match raw:
		"tiny":
			return "small"
		"small":
			return "small"
		"medium":
			return "medium"
		"big":
			return "large"
		"large":
			return "large"
		"giant":
			return "huge"
		"mega":
			return "huge"
		"huge":
			return "huge"
		_:
			return "medium"

func _city_scale_label(scale_key: String) -> String:
	match _normalize_city_scale(scale_key):
		"small":
			return "Small"
		"medium":
			return "Medium"
		"large":
			return "Large"
		"huge":
			return "Huge"
		_:
			return "Medium"

func _city_caps_for_scale(scale_key: String) -> Dictionary:
	var normalized: String = _normalize_city_scale(scale_key)
	var caps_any: Variant = CITY_SCALE_CAPS.get(normalized, CITY_SCALE_CAPS.get("medium", {}))
	return (caps_any as Dictionary).duplicate(true) if caps_any is Dictionary else {}

func _estimate_city_periodic_income(city: Dictionary) -> Dictionary:
	var dev: Dictionary = city.get("development", {})
	var commerce: float = float(dev.get("commerce", 0.0))
	var agriculture: float = float(dev.get("agriculture", 0.0))
	var industry: float = float(dev.get("industry", 0.0))
	var stables: float = float(dev.get("stables", 0.0))
	return {
		"money_month": 120.0 * commerce,
		"food_quarter": 180.0 * agriculture,
		"iron_month": 70.0 * industry,
		"wood_month": 70.0 * agriculture,
		"horse_month": 30.0 * stables
	}

func _resolve_tax_info(building: Dictionary, development: Dictionary) -> Dictionary:
	if building.has("tax_rate"):
		return {"label": "Tax Rate", "value": clampf(float(building.get("tax_rate", 0.0)), 0.0, 1.0)}
	var commerce: float = float(development.get("commerce", 0.0))
	var estimated: float = clampf(0.05 + commerce * 0.006, 0.05, 0.18)
	return {"label": "Tax Rate (est.)", "value": estimated}

func _resolve_tech_info(building: Dictionary, development: Dictionary) -> Dictionary:
	var stats_any: Variant = building.get("stats", {})
	var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
	if stats.has("tech"):
		return {"label": "Tech", "value": clampf(float(stats.get("tech", 0.0)), 0.0, 100.0)}
	if stats.has("technology"):
		return {"label": "Tech", "value": clampf(float(stats.get("technology", 0.0)), 0.0, 100.0)}
	var estimated: float = clampf(18.0 + float(development.get("industry", 0.0)) * 7.0, 0.0, 100.0)
	return {"label": "Tech (est.)", "value": estimated}

func _optional_number(source: Dictionary, key: String, fallback_keys: Array = []) -> Dictionary:
	if source.has(key):
		return {"has": true, "value": float(source.get(key, 0.0))}
	for fallback_any in fallback_keys:
		var fallback_key: String = String(fallback_any)
		if fallback_key.is_empty():
			continue
		if source.has(fallback_key):
			return {"has": true, "value": float(source.get(fallback_key, 0.0))}
	return {"has": false, "value": 0.0}

func _fmt_optional_num(optional: Dictionary) -> String:
	if bool(optional.get("has", false)):
		return _fmt_num(float(optional.get("value", 0.0)))
	return "N/A"

func _fmt_optional_delta(optional: Dictionary, period: String) -> String:
	if bool(optional.get("has", false)):
		return _fmt_delta(float(optional.get("value", 0.0)), period)
	return "N/A"

func _fmt_optional_rounded(optional: Dictionary) -> String:
	if bool(optional.get("has", false)):
		return str(int(round(float(optional.get("value", 0.0)))))
	return "N/A"

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

func _setup_runtime_site_menu_ui() -> void:
	if _runtime_ui_layer != null:
		_ensure_supply_corridor_toggle_ui()
		return
	var presentation_rules: Dictionary = _json_source.load_dictionary(PRESENTATION_RULES_PATH)
	var ui_rules: Dictionary = presentation_rules.get("ui", {})
	var font_path: String = str(presentation_rules.get("font_path", ""))
	var font: FontFile = null
	if not font_path.is_empty():
		font = load(font_path) as FontFile
	var meta: Dictionary = _world_state_cache.get("meta", {})
	var player_faction_id: String = _get_player_faction_id()
	var command_points: float = float(meta.get("command_points", 12.0))
	var max_command_points: float = float(meta.get("max_command_points", command_points))
	var military_orders: float = float(meta.get("military_orders", 6.0))
	var max_military_orders: float = float(meta.get("max_military_orders", military_orders))
	var calendar_day: float = float(meta.get("calendar_day", 1.0))
	var weather_any: Variant = meta.get("weather", {})
	var weather: Dictionary = weather_any as Dictionary if weather_any is Dictionary else {}
	if weather.is_empty():
		weather = {
			"state": String(_runtime_time_weather.get("weather_state", "sunny")),
			"day_phase": String(_runtime_time_weather.get("day_phase", "day"))
		}
	var cities_snapshot: Array = _snapshot_array_from_world_state("cities")
	var building_units_snapshot: Array = _snapshot_array_from_world_state("building_units")
	_runtime_ui_layer = StrategyUILayer.new()
	_runtime_ui_layer.name = "RuntimeUILayer"
	add_child(_runtime_ui_layer)
	_runtime_ui_layer.setup(
		{
			"meta": {"player_faction_id": player_faction_id, "calendar_day": calendar_day, "weather": weather, "city_orders": _runtime_city_orders.duplicate(true)},
			"cities": cities_snapshot,
			"building_units": building_units_snapshot
		},
		ui_rules,
		font,
		{
			"phase": _runtime_phase,
			"calendar_day": calendar_day,
			"weather": weather,
			"command_points": command_points,
			"max_command_points": max_command_points,
			"command_cost_city_action": 1.0,
			"status_message": _runtime_status_message,
			"preload_progress": 1.0,
			"military_orders": military_orders,
			"max_military_orders": max_military_orders,
			"battle_seconds_elapsed": _runtime_battle_elapsed_seconds,
			"battle_seconds_total": _runtime_battle_total_seconds,
			"battle_seconds_left": maxf(0.0, _runtime_battle_total_seconds - _runtime_battle_elapsed_seconds),
			"battle_paused": _runtime_battle_paused,
			"battle_speed": _runtime_battle_speed
		}
	)
	if not _runtime_ui_layer.city_command_requested.is_connected(_on_runtime_site_command_requested):
		_runtime_ui_layer.city_command_requested.connect(_on_runtime_site_command_requested)
	if not _runtime_ui_layer.aide_change_requested.is_connected(_on_runtime_aide_change_requested):
		_runtime_ui_layer.aide_change_requested.connect(_on_runtime_aide_change_requested)
	if not _runtime_ui_layer.aide_batch_change_requested.is_connected(_on_runtime_aide_batch_change_requested):
		_runtime_ui_layer.aide_batch_change_requested.connect(_on_runtime_aide_batch_change_requested)
	if not _runtime_ui_layer.regroup_plan_confirmed.is_connected(_on_runtime_regroup_plan_confirmed):
		_runtime_ui_layer.regroup_plan_confirmed.connect(_on_runtime_regroup_plan_confirmed)
	if not _runtime_ui_layer.city_move_requested.is_connected(_on_runtime_city_move_requested):
		_runtime_ui_layer.city_move_requested.connect(_on_runtime_city_move_requested)
	if not _runtime_ui_layer.expedition_plan_confirmed.is_connected(_on_runtime_expedition_plan_confirmed):
		_runtime_ui_layer.expedition_plan_confirmed.connect(_on_runtime_expedition_plan_confirmed)
	if not _runtime_ui_layer.global_officer_book_requested.is_connected(_on_runtime_global_officer_book_requested):
		_runtime_ui_layer.global_officer_book_requested.connect(_on_runtime_global_officer_book_requested)
	if not _runtime_ui_layer.proceed_battle_requested.is_connected(_on_runtime_proceed_battle_requested):
		_runtime_ui_layer.proceed_battle_requested.connect(_on_runtime_proceed_battle_requested)
	if not _runtime_ui_layer.battle_pause_toggled.is_connected(_on_runtime_battle_pause_toggled):
		_runtime_ui_layer.battle_pause_toggled.connect(_on_runtime_battle_pause_toggled)
	if not _runtime_ui_layer.battle_speed_requested.is_connected(_on_runtime_battle_speed_requested):
		_runtime_ui_layer.battle_speed_requested.connect(_on_runtime_battle_speed_requested)
	_ensure_supply_corridor_toggle_ui()

func _ensure_supply_corridor_toggle_ui() -> void:
	if _supply_corridor_toggle_button != null and is_instance_valid(_supply_corridor_toggle_button):
		_refresh_supply_corridor_toggle_button_visual()
		return
	if _supply_corridor_ui_layer == null or not is_instance_valid(_supply_corridor_ui_layer):
		_supply_corridor_ui_layer = CanvasLayer.new()
		_supply_corridor_ui_layer.name = "SupplyCorridorUILayer"
		_supply_corridor_ui_layer.layer = 160
		add_child(_supply_corridor_ui_layer)
	var wrap := MarginContainer.new()
	wrap.name = "TopRightWrap"
	wrap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	wrap.offset_left = -196.0
	wrap.offset_top = 18.0
	wrap.offset_right = -18.0
	wrap.offset_bottom = 56.0
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_supply_corridor_ui_layer.add_child(wrap)
	var btn := Button.new()
	btn.name = "SupplyCorridorButton"
	btn.custom_minimum_size = Vector2(178.0, 38.0)
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.tooltip_text = "Toggle supply corridor overlay."
	btn.pressed.connect(func() -> void:
		_toggle_supply_corridor_view()
	)
	wrap.add_child(btn)
	_supply_corridor_toggle_button = btn
	_refresh_supply_corridor_toggle_button_visual()

func _refresh_supply_corridor_toggle_button_visual() -> void:
	if _supply_corridor_toggle_button == null or not is_instance_valid(_supply_corridor_toggle_button):
		return
	var enabled: bool = _supply_corridor_view_enabled
	_supply_corridor_toggle_button.text = "Supply Corridor: ON" if enabled else "Supply Corridor: OFF"
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.15, 0.45, 0.2, 0.9) if enabled else Color(0.14, 0.16, 0.2, 0.88)
	normal.border_color = Color(0.76, 0.94, 0.62, 0.98) if enabled else Color(0.56, 0.62, 0.74, 0.92)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(8)
	var hover := normal.duplicate() as StyleBoxFlat
	if hover != null:
		hover.bg_color = hover.bg_color.lightened(0.08)
	_supply_corridor_toggle_button.add_theme_stylebox_override("normal", normal)
	if hover != null:
		_supply_corridor_toggle_button.add_theme_stylebox_override("hover", hover)
	_supply_corridor_toggle_button.add_theme_stylebox_override("pressed", normal)
	_supply_corridor_toggle_button.add_theme_color_override("font_color", Color(0.96, 0.98, 0.92, 1.0))
	_supply_corridor_toggle_button.add_theme_font_size_override("font_size", 15)

func _on_runtime_site_command_requested(site_id: String, action_id: String) -> void:
	if _runtime_ui_layer == null:
		return
	var site: Dictionary = _get_site_snapshot(site_id)
	if _is_player_owned_runtime_facility(site):
		if _handle_runtime_facility_menu_action(site, action_id):
			return
	if action_id == "expedition_start":
		_runtime_ui_layer.show_command_panel("expedition_prepare", _build_runtime_expedition_panel_data(site_id))
		return
	if action_id == "expedition_cancel":
		_clear_runtime_expedition_order(site_id)
		return
	_runtime_ui_layer.show_command_panel(action_id, _build_site_panel_data(site_id, action_id))

func _on_runtime_global_officer_book_requested() -> void:
	if _runtime_ui_layer == null:
		return
	_runtime_ui_layer.show_command_panel("aides", _build_runtime_global_officer_book_panel_data(""))

func _on_runtime_expedition_plan_confirmed(city_id: String, payload: Dictionary) -> void:
	if _runtime_ui_layer == null:
		return
	var panel_data: Dictionary = _build_runtime_expedition_panel_data(city_id)
	var resolved_city_id: String = String(panel_data.get("city_id", city_id)).strip_edges()
	var resolved_city_name: String = String(panel_data.get("city_name", resolved_city_id)).strip_edges()
	var officer_ids: Array = payload.get("officer_ids", []) as Array
	if officer_ids.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Select at least 1 officer before confirming.")
		return
	var city: Dictionary = _resolve_world_city(resolved_city_id, resolved_city_name)
	if city.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No city data available for expedition.")
		return
	var troop_result: Dictionary = _runtime_validate_expedition_troop_payload(city, payload)
	if not bool(troop_result.get("ok", false)):
		var reason: String = String(troop_result.get("reason", "")).strip_edges()
		var reason_text: String = "Current expedition troop setup is invalid."
		match reason:
			"empty_troops":
				reason_text = "Assign expedition troops from organized forces first."
			"insufficient_organized":
				reason_text = "Total expedition troops exceed current organized forces."
			"insufficient_unit_amount":
				var over_unit_id: String = String(troop_result.get("unit_id", "")).strip_edges()
				reason_text = "Allocated amount for %s exceeds available organized troops." % over_unit_id
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), reason_text)
		return
	var order_entry: Dictionary = payload.duplicate(true)
	order_entry["troop_allocation"] = (troop_result.get("allocation", {}) as Dictionary).duplicate(true) if troop_result.get("allocation", {}) is Dictionary else {}
	order_entry["troop_total"] = float(troop_result.get("total", payload.get("troop_total", 0.0)))
	order_entry["lead_unit_id"] = String(troop_result.get("lead_unit_id", payload.get("effective_main_base_class", ""))).strip_edges()
	order_entry["lead_unit_name"] = String(troop_result.get("lead_unit_name", order_entry.get("lead_unit_id", ""))).strip_edges()
	order_entry["effective_main_troop_id"] = String(troop_result.get("effective_troop_id", payload.get("effective_main_troop_id", ""))).strip_edges()
	order_entry["effective_main_troop_name"] = String(troop_result.get("effective_troop_name", payload.get("effective_main_troop_name", ""))).strip_edges()
	order_entry["main_special_troop_active"] = bool(troop_result.get("main_special_troop_active", payload.get("main_special_troop_active", false)))
	order_entry["expedition_active"] = true
	order_entry["updated_day"] = float((_world_state_cache.get("meta", {}) as Dictionary).get("calendar_day", 1.0))
	_runtime_city_orders[resolved_city_id] = order_entry
	var troop_total_text: String = "%.0f" % float(order_entry.get("troop_total", 0.0))
	var effective_troop_name: String = String(order_entry.get("effective_main_troop_name", order_entry.get("lead_unit_name", "Unit"))).strip_edges()
	_runtime_status_message = "Expedition set for %s: %s | Ship: %s | Troops: %s | Lead Troop: %s" % [
		resolved_city_name,
		String(", ".join(payload.get("officer_names", []))),
		String(payload.get("ship_label", payload.get("ship_type", "Light Skiff"))),
		troop_total_text,
		effective_troop_name
	]
	_runtime_ui_layer.hide_command_panel()
	_runtime_ui_layer.hide_city_command_menu()
	_refresh_runtime_ui_hud(true)
func _on_runtime_city_move_requested(from_city_id: String, payload: Dictionary) -> void:
	if _runtime_ui_layer == null:
		return
	if _runtime_phase != RUNTIME_PHASE_INTERNAL:
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Move can only be confirmed during the internal phase.")
		return
	var source_site: Dictionary = _get_site_snapshot(from_city_id)
	if source_site.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No source site data available for move.")
		return
	var source_name: String = String(source_site.get("name", from_city_id)).strip_edges()
	var source_city_id: String = String(source_site.get("city_id", source_site.get("id", from_city_id))).strip_edges()
	if source_city_id.is_empty():
		source_city_id = from_city_id
	var source_city: Dictionary = _resolve_world_city(source_city_id, source_name)
	var source_building: Dictionary = _resolve_world_building(String(source_site.get("id", from_city_id)).strip_edges(), source_name)
	var source_is_city: bool = String(source_site.get("type", "")).strip_edges().to_lower() == "city" or (not source_city.is_empty() and (String(source_city.get("id", "")).strip_edges() == from_city_id or String(source_city.get("id", "")).strip_edges() == source_city_id or String(source_city.get("city_id", "")).strip_edges() == source_city_id))
	var source: Dictionary = source_city.duplicate(true) if source_is_city and not source_city.is_empty() else (source_building.duplicate(true) if not source_building.is_empty() else source_site.duplicate(true))
	var source_faction_id: String = String(source.get("faction_id", source_site.get("faction_id", ""))).strip_edges()
	if source_faction_id != _get_player_faction_id():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "You can only move assets from your own city or site.")
		return
	var target_city_id: String = String(payload.get("target_city_id", "")).strip_edges()
	if target_city_id.is_empty() or target_city_id == from_city_id or target_city_id == source_city_id:
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Pick a different target before confirming move.")
		return
	var target_site: Dictionary = _get_site_snapshot(target_city_id)
	if target_site.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No target site data available for move.")
		return
	var target_name: String = String(target_site.get("name", target_city_id)).strip_edges()
	var target_linked_city_id: String = String(target_site.get("city_id", target_site.get("id", target_city_id))).strip_edges()
	if target_linked_city_id.is_empty():
		target_linked_city_id = target_city_id
	var target_city: Dictionary = _resolve_world_city(target_linked_city_id, target_name)
	var target_building: Dictionary = _resolve_world_building(String(target_site.get("id", target_city_id)).strip_edges(), target_name)
	var target_is_city: bool = String(target_site.get("type", "")).strip_edges().to_lower() == "city" or (not target_city.is_empty() and (String(target_city.get("id", "")).strip_edges() == target_city_id or String(target_city.get("id", "")).strip_edges() == target_linked_city_id or String(target_city.get("city_id", "")).strip_edges() == target_linked_city_id))
	var target: Dictionary = target_city.duplicate(true) if target_is_city and not target_city.is_empty() else (target_building.duplicate(true) if not target_building.is_empty() else target_site.duplicate(true))
	if String(target.get("faction_id", target_site.get("faction_id", ""))).strip_edges() != source_faction_id:
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Move target must belong to the same faction.")
		return
	var mode: String = String(payload.get("mode", "move_dispatch")).strip_edges()
	if not _is_runtime_move_action(mode):
		mode = "move_dispatch"
	var dispatch_ids: Array[String] = _runtime_unique_string_array(payload.get("dispatch_officer_ids", []))
	var recall_ids: Array[String] = _runtime_unique_string_array(payload.get("recall_officer_ids", []))
	var transfer_any: Variant = payload.get("transfer", {})
	var transfer: Dictionary = transfer_any as Dictionary if transfer_any is Dictionary else {}
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
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No move selection to confirm.")
		return
	var command_cost: float = _runtime_command_cost_city_action()
	if not _runtime_consume_command_points(command_cost):
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Not enough command points to confirm move.")
		_refresh_runtime_ui_hud(true)
		return
	var source_roster: Array = _runtime_build_city_roster_with_master(source) if source_is_city else _runtime_build_site_roster_with_master(source)
	var target_roster: Array = _runtime_build_city_roster_with_master(target) if target_is_city else _runtime_build_site_roster_with_master(target)
	var moved_dispatch: Array = []
	if not dispatch_ids.is_empty():
		var remaining_source: Array = []
		for officer_any in source_roster:
			if not (officer_any is Dictionary):
				continue
			var officer: Dictionary = officer_any as Dictionary
			var officer_id: String = String(officer.get("id", "")).strip_edges()
			if dispatch_ids.has(officer_id):
				moved_dispatch.append(officer.duplicate(true))
			else:
				remaining_source.append(officer)
		source_roster = remaining_source
		for officer_any in moved_dispatch:
			if not (officer_any is Dictionary):
				continue
			var officer: Dictionary = officer_any as Dictionary
			if _runtime_find_officer_by_id(target_roster, String(officer.get("id", ""))).is_empty():
				target_roster.append(officer.duplicate(true))
	if not recall_ids.is_empty():
		var moved_recall: Array = []
		var remaining_target: Array = []
		for officer_any in target_roster:
			if not (officer_any is Dictionary):
				continue
			var officer: Dictionary = officer_any as Dictionary
			var officer_id: String = String(officer.get("id", "")).strip_edges()
			if recall_ids.has(officer_id):
				moved_recall.append(officer.duplicate(true))
			else:
				remaining_target.append(officer)
		target_roster = remaining_target
		for officer_any in moved_recall:
			if not (officer_any is Dictionary):
				continue
			var officer: Dictionary = officer_any as Dictionary
			if _runtime_find_officer_by_id(source_roster, String(officer.get("id", ""))).is_empty():
				source_roster.append(officer.duplicate(true))
	var source_resources_any: Variant = source.get("resources", {})
	var source_resources: Dictionary = source_resources_any as Dictionary if source_resources_any is Dictionary else {}
	var target_resources_any: Variant = target.get("resources", {})
	var target_resources: Dictionary = target_resources_any as Dictionary if target_resources_any is Dictionary else {}
	var source_stats_any: Variant = source.get("stats", {})
	var source_stats: Dictionary = source_stats_any as Dictionary if source_stats_any is Dictionary else {}
	var target_stats_any: Variant = target.get("stats", {})
	var target_stats: Dictionary = target_stats_any as Dictionary if target_stats_any is Dictionary else {}
	if money_amount > float(source_resources.get("money", 0.0)) or food_amount > float(source_resources.get("food", 0.0)) or iron_amount > float(source_resources.get("iron", 0.0)) or wood_amount > float(source_resources.get("wood", 0.0)) or horse_amount > float(source_resources.get("horse", 0.0)) or reserve_amount > float(source_stats.get("reserve_troops", 0.0)) or organized_amount > float(source_stats.get("organized_troops", 0.0)):
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Source city/site does not have enough officers or resources for this move.")
		_refresh_runtime_ui_hud(true)
		return
	var source_resources_after: Dictionary = source_resources.duplicate(true)
	var target_resources_after: Dictionary = target_resources.duplicate(true)
	source_resources_after["money"] = float(source_resources_after.get("money", 0.0)) - money_amount
	source_resources_after["food"] = float(source_resources_after.get("food", 0.0)) - food_amount
	source_resources_after["iron"] = float(source_resources_after.get("iron", 0.0)) - iron_amount
	source_resources_after["wood"] = float(source_resources_after.get("wood", 0.0)) - wood_amount
	source_resources_after["horse"] = float(source_resources_after.get("horse", 0.0)) - horse_amount
	target_resources_after["money"] = float(target_resources_after.get("money", 0.0)) + money_amount
	target_resources_after["food"] = float(target_resources_after.get("food", 0.0)) + food_amount
	target_resources_after["iron"] = float(target_resources_after.get("iron", 0.0)) + iron_amount
	target_resources_after["wood"] = float(target_resources_after.get("wood", 0.0)) + wood_amount
	target_resources_after["horse"] = float(target_resources_after.get("horse", 0.0)) + horse_amount
	var source_stats_after: Dictionary = source_stats.duplicate(true)
	var target_stats_after: Dictionary = target_stats.duplicate(true)
	source_stats_after["reserve_troops"] = float(source_stats_after.get("reserve_troops", 0.0)) - reserve_amount
	source_stats_after["organized_troops"] = float(source_stats_after.get("organized_troops", 0.0)) - organized_amount
	target_stats_after["reserve_troops"] = float(target_stats_after.get("reserve_troops", 0.0)) + reserve_amount
	target_stats_after["organized_troops"] = float(target_stats_after.get("organized_troops", 0.0)) + organized_amount
	source_stats_after["troops"] = float(source_stats_after.get("reserve_troops", 0.0)) + float(source_stats_after.get("organized_troops", 0.0))
	target_stats_after["troops"] = float(target_stats_after.get("reserve_troops", 0.0)) + float(target_stats_after.get("organized_troops", 0.0))
	var comp_result: Dictionary = _runtime_transfer_unit_composition(source.get("unit_composition", {}), target.get("unit_composition", {}), organized_amount)
	var source_personnel: Dictionary = _runtime_sanitize_move_personnel(source.get("personnel", {}) as Dictionary if source.get("personnel", {}) is Dictionary else {}, source_roster)
	var target_personnel: Dictionary = _runtime_sanitize_move_personnel(target.get("personnel", {}) as Dictionary if target.get("personnel", {}) is Dictionary else {}, target_roster)
	var updated_source: Dictionary = source.duplicate(true)
	updated_source["officer_roster"] = source_roster
	updated_source["resources"] = source_resources_after
	updated_source["stats"] = source_stats_after
	updated_source["unit_composition"] = comp_result.get("source_after", {})
	updated_source["personnel"] = source_personnel
	if source_is_city:
		updated_source["officers"] = _runtime_rebuild_move_officer_scores(source.get("officers", {}) as Dictionary if source.get("officers", {}) is Dictionary else {}, source_personnel.get("assignments", {}) as Dictionary if source_personnel.get("assignments", {}) is Dictionary else {}, source_roster)
		_upsert_world_city(updated_source)
	else:
		_upsert_world_building_unit(updated_source)
	var updated_target: Dictionary = target.duplicate(true)
	updated_target["officer_roster"] = target_roster
	updated_target["resources"] = target_resources_after
	updated_target["stats"] = target_stats_after
	updated_target["unit_composition"] = comp_result.get("target_after", {})
	updated_target["personnel"] = target_personnel
	if target_is_city:
		updated_target["officers"] = _runtime_rebuild_move_officer_scores(target.get("officers", {}) as Dictionary if target.get("officers", {}) is Dictionary else {}, target_personnel.get("assignments", {}) as Dictionary if target_personnel.get("assignments", {}) is Dictionary else {}, target_roster)
		_upsert_world_city(updated_target)
	else:
		_upsert_world_building_unit(updated_target)
	_selected_site_id = from_city_id
	_runtime_ui_layer.hide_command_panel()
	_runtime_ui_layer.hide_city_command_menu()
	_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Move order completed.")
	_refresh_runtime_ui_hud(true)
func _on_runtime_regroup_plan_confirmed(city_id: String, plans: Array) -> void:
	if _runtime_ui_layer == null:
		return
	if _runtime_phase != RUNTIME_PHASE_INTERNAL:
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Regroup can only be confirmed during the internal phase.")
		return
	if plans.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No troop changes were selected.")
		return
	var city: Dictionary = _resolve_world_city(city_id, city_id)
	if city.is_empty():
		var site: Dictionary = _get_site_snapshot(city_id)
		var fallback_city_id: String = String(site.get("city_id", site.get("id", city_id))).strip_edges()
		var fallback_city_name: String = String(site.get("name", city_id)).strip_edges()
		city = _resolve_world_city(fallback_city_id, fallback_city_name)
	if city.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No city data available for regroup.")
		return
	if String(city.get("faction_id", "")).strip_edges() != _get_player_faction_id():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "You can only regroup troops in your own city.")
		return
	var result: Dictionary = _runtime_evaluate_regroup_plan(city, plans)
	if not bool(result.get("ok", false)):
		var reason: String = String(result.get("reason", "")).strip_edges()
		var reason_text: String = "Regroup failed."
		match reason:
			"insufficient_resources":
				reason_text = "Not enough resources to complete regroup."
			"insufficient_reserve":
				reason_text = "Not enough reserve troops for this regroup."
			"siege_durability_cap":
				reason_text = "Siege durability would exceed the cap."
			"invalid_amount":
				reason_text = "Invalid regroup amount for the selected troop type."
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), reason_text)
		return
	var total_cost: float = _runtime_command_cost_city_action()
	if not _runtime_consume_command_points(total_cost):
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Not enough command points to execute regroup.")
		_refresh_runtime_ui_hud(true)
		return
	var updated_city: Dictionary = city.duplicate(true)
	var resources_after_any: Variant = result.get("resources_after", {})
	var resources_after: Dictionary = resources_after_any as Dictionary if resources_after_any is Dictionary else {}
	var stats_any: Variant = updated_city.get("stats", {})
	var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
	stats["reserve_troops"] = float(result.get("reserve_after", stats.get("reserve_troops", 0.0)))
	stats["organized_troops"] = float(result.get("organized_after", stats.get("organized_troops", 0.0)))
	stats["troops"] = float(stats.get("reserve_troops", 0.0)) + float(stats.get("organized_troops", 0.0))
	updated_city["stats"] = stats
	updated_city["resources"] = resources_after.duplicate(true)
	var siege_after_any: Variant = result.get("siege_durability_after", {})
	if siege_after_any is Dictionary:
		updated_city["siege_durability"] = (siege_after_any as Dictionary).duplicate(true)
	var composition_after_any: Variant = result.get("unit_composition_after", {})
	if composition_after_any is Dictionary:
		updated_city["unit_composition"] = (composition_after_any as Dictionary).duplicate(true)
	_upsert_world_city(updated_city)
	_selected_site_id = String(updated_city.get("id", city_id)).strip_edges()
	_runtime_ui_layer.hide_command_panel()
	_runtime_ui_layer.hide_city_command_menu()
	_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Regroup completed.")
	_refresh_runtime_ui_hud(true)

func _clear_runtime_expedition_order(city_id: String) -> void:
	if _runtime_ui_layer == null:
		return
	var panel_data: Dictionary = _build_runtime_expedition_panel_data(city_id)
	var resolved_city_id: String = String(panel_data.get("city_id", city_id)).strip_edges()
	var resolved_city_name: String = String(panel_data.get("city_name", resolved_city_id)).strip_edges()
	if resolved_city_id.is_empty() or not _runtime_city_orders.has(resolved_city_id):
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No active expedition order to cancel.")
		return
	var order_any: Variant = _runtime_city_orders.get(resolved_city_id, {})
	var order_entry: Dictionary = (order_any as Dictionary).duplicate(true) if order_any is Dictionary else {}
	order_entry["expedition_active"] = false
	_runtime_city_orders[resolved_city_id] = order_entry
	_runtime_status_message = "Expedition canceled for %s." % resolved_city_name
	_runtime_ui_layer.hide_command_panel()
	_runtime_ui_layer.hide_city_command_menu()
	_refresh_runtime_ui_hud(true)

func _handle_runtime_facility_menu_action(site: Dictionary, action_id: String) -> bool:
	var faction_id: String = String(site.get("faction_id", "")).strip_edges()
	var unit_proxy: Dictionary = {
		"id": "_facility_action_proxy",
		"type": "field_unit",
		"faction_id": faction_id,
		"position": (site.get("position", {}) as Dictionary).duplicate(true),
		"city_id": String(site.get("city_id", site.get("id", "")))
	}
	var target_site_id: String = String(site.get("id", ""))
	var result: Dictionary = {}
	match action_id:
		"facility_upgrade", "expedition_start":
			var t: String = String(site.get("type", "")).to_lower().strip_edges()
			var upgrade_action: String = ""
			if t == "muzhai":
				upgrade_action = "upgrade_chengzhai"
			elif t == "granary" and not bool(site.get("is_advanced_granary", false)):
				upgrade_action = "upgrade_junliangbao"
			elif t == "jianlou":
				upgrade_action = "upgrade_gaojijianlou"
			elif t == "taigutai":
				upgrade_action = "upgrade_junyuetai"
			if upgrade_action.is_empty():
				result = {"ok": false, "message": "No valid upgrade available for this facility."}
			else:
				result = _upgrade_unit_built_facility(unit_proxy, faction_id, upgrade_action, target_site_id)
		"facility_repair", "regroup":
			result = _repair_nearby_facility(unit_proxy, faction_id, target_site_id)
		"facility_destroy", "expedition_cancel":
			result = _destroy_nearby_facility(unit_proxy, faction_id, target_site_id)
		_:
			return false
	var result_text: String = String(result.get("message", ""))
	if not result_text.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), result_text)
	_runtime_ui_layer.hide_city_command_menu()
	return true

func _build_site_panel_data(site_id: String, action_id: String) -> Dictionary:
	if action_id == "aides":
		return _build_runtime_aides_panel_data(site_id)
	if action_id == "regroup":
		return _build_runtime_regroup_panel_data(site_id)
	if _is_runtime_move_action(action_id):
		return _build_runtime_move_panel_data(site_id, action_id)
	var site: Dictionary = _get_site_snapshot(site_id)
	var site_name: String = str(site.get("name", site_id))
	if _master_officers.is_empty():
		_reload_master_officer_catalog()
	return {
		"title": "%s - %s" % [site_name, action_id],
		"city_id": site_id,
		"from_city_id": site_id,
		"from_city_name": site_name,
		"targets": [],
		"source_officers": [],
		"source_resources": {},
		"source_stats": {},
		"source_unit_composition": {},
		"selected_target_city_id": "",
		"roles": [],
		"officers": [],
		"all_officers": _master_officers.duplicate(true),
		"assignments": {},
		"assignment_names": {},
		"preview": {},
		"categories": [],
		"units": {},
		"city_resources": {},
		"reserve_troops": 0.0,
		"organized_troops": 0.0
	}

func _is_runtime_move_action(action_id: String) -> bool:
	return action_id == "move_dispatch" or action_id == "move_recall" or action_id == "move_transport_resources" or action_id == "move_transport_troops"

func _build_runtime_move_panel_data(site_id: String, action_id: String) -> Dictionary:
	if _master_officers.is_empty():
		_reload_master_officer_catalog()
	var site: Dictionary = _get_site_snapshot(site_id)
	var site_name: String = String(site.get("name", site_id)).strip_edges()
	var site_type: String = String(site.get("type", "")).strip_edges().to_lower()
	var resolved_city_id: String = String(site.get("city_id", site.get("id", site_id))).strip_edges()
	if resolved_city_id.is_empty():
		resolved_city_id = site_id
	var city: Dictionary = _resolve_world_city(resolved_city_id, site_name)
	var building: Dictionary = _resolve_world_building(String(site.get("id", site_id)).strip_edges(), site_name)
	var use_city_source: bool = site_type == "city" or (not city.is_empty() and (String(city.get("id", "")).strip_edges() == site_id or String(city.get("id", "")).strip_edges() == resolved_city_id or String(city.get("city_id", "")).strip_edges() == resolved_city_id))
	var source: Dictionary = city.duplicate(true) if use_city_source and not city.is_empty() else (building.duplicate(true) if not building.is_empty() else site.duplicate(true))
	var source_officers: Array = _runtime_build_city_roster_with_master(source) if use_city_source else _runtime_build_site_roster_with_master(source)
	var source_resources_any: Variant = source.get("resources", {})
	var source_resources: Dictionary = source_resources_any as Dictionary if source_resources_any is Dictionary else {}
	var source_stats_any: Variant = source.get("stats", {})
	var source_stats: Dictionary = source_stats_any as Dictionary if source_stats_any is Dictionary else {}
	var targets: Array = _runtime_collect_move_targets(site_id, resolved_city_id, String(source.get("faction_id", site.get("faction_id", ""))).strip_edges())
	var selected_target_city_id: String = ""
	if not targets.is_empty() and targets[0] is Dictionary:
		selected_target_city_id = String((targets[0] as Dictionary).get("city_id", "")).strip_edges()
	return {
		"title": String(action_id.trim_prefix("move_")),
		"move_mode": action_id,
		"city_id": site_id,
		"from_city_id": site_id,
		"from_city_name": String(source.get("name", site_name)),
		"targets": targets,
		"source_officers": source_officers,
		"source_resources": source_resources.duplicate(true),
		"source_stats": source_stats.duplicate(true),
		"source_unit_composition": _runtime_normalize_unit_composition(source.get("unit_composition", {})),
		"selected_target_city_id": selected_target_city_id
	}

func _runtime_collect_move_targets(from_site_id: String, source_city_id: String, source_faction_id: String) -> Array:
	var out: Array = []
	if source_faction_id.is_empty():
		return out
	var seen_target_ids: Dictionary = {}
	var cities_any: Variant = _world_state_cache.get("cities", [])
	if cities_any is Array:
		for city_any in (cities_any as Array):
			if not (city_any is Dictionary):
				continue
			var city: Dictionary = (city_any as Dictionary).duplicate(true)
			var city_id: String = String(city.get("id", "")).strip_edges()
			if city_id.is_empty() or city_id == from_site_id or city_id == source_city_id or seen_target_ids.has(city_id):
				continue
			if String(city.get("faction_id", "")).strip_edges() != source_faction_id:
				continue
			seen_target_ids[city_id] = true
			out.append({
				"city_id": city_id,
				"name": "%s (city)" % String(city.get("name", city_id)),
				"officer_roster": _runtime_build_city_roster_with_master(city),
				"resources": (city.get("resources", {}) as Dictionary).duplicate(true) if city.get("resources", {}) is Dictionary else {},
				"stats": (city.get("stats", {}) as Dictionary).duplicate(true) if city.get("stats", {}) is Dictionary else {},
				"node_type": "city"
			})
	var units_any: Variant = _world_state_cache.get("building_units", [])
	if units_any is Array:
		for unit_any in (units_any as Array):
			if not (unit_any is Dictionary):
				continue
			var unit: Dictionary = (unit_any as Dictionary).duplicate(true)
			var unit_id: String = String(unit.get("id", "")).strip_edges()
			var unit_type: String = String(unit.get("type", "")).strip_edges().to_lower()
			if unit_id.is_empty() or unit_id == from_site_id or unit_id == source_city_id or seen_target_ids.has(unit_id):
				continue
			if String(unit.get("faction_id", "")).strip_edges() != source_faction_id:
				continue
			if unit_type == "field_unit" or unit_type == "convoy":
				continue
			seen_target_ids[unit_id] = true
			out.append({
				"city_id": unit_id,
				"name": "%s (%s)" % [String(unit.get("name", unit_id)), unit_type if not unit_type.is_empty() else "site"],
				"officer_roster": _runtime_build_site_roster_with_master(unit),
				"resources": (unit.get("resources", {}) as Dictionary).duplicate(true) if unit.get("resources", {}) is Dictionary else {},
				"stats": (unit.get("stats", {}) as Dictionary).duplicate(true) if unit.get("stats", {}) is Dictionary else {},
				"node_type": "outpost"
			})
	return out

func _build_runtime_regroup_panel_data(city_id: String) -> Dictionary:
	var city: Dictionary = _resolve_world_city(city_id, city_id)
	if city.is_empty():
		var site: Dictionary = _get_site_snapshot(city_id)
		var fallback_city_id: String = String(site.get("city_id", site.get("id", city_id))).strip_edges()
		var fallback_city_name: String = String(site.get("name", city_id)).strip_edges()
		city = _resolve_world_city(fallback_city_id, fallback_city_name)
	if city.is_empty():
		return {
			"title": "Regroup",
			"city_id": city_id,
			"city_name": city_id,
			"categories": [],
			"units": {},
			"city_resources": {},
			"reserve_troops": 0.0,
			"organized_troops": 0.0,
			"siege_durability": {}
		}
	var resolved_city_id: String = String(city.get("id", city_id)).strip_edges()
	if resolved_city_id.is_empty():
		resolved_city_id = city_id
	var dataset: Dictionary = _build_runtime_regroup_dataset(city)
	var stats_any: Variant = city.get("stats", {})
	var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
	var resources_any: Variant = city.get("resources", {})
	var resources: Dictionary = resources_any as Dictionary if resources_any is Dictionary else {}
	var siege_any: Variant = city.get("siege_durability", {})
	var siege_durability: Dictionary = (siege_any as Dictionary).duplicate(true) if siege_any is Dictionary else {}
	return {
		"title": "Regroup",
		"city_id": resolved_city_id,
		"city_name": String(city.get("name", resolved_city_id)),
		"categories": (dataset.get("categories", []) as Array).duplicate(true) if dataset.get("categories", []) is Array else [],
		"units": (dataset.get("units", {}) as Dictionary).duplicate(true) if dataset.get("units", {}) is Dictionary else {},
		"city_resources": resources.duplicate(true),
		"unit_composition": _runtime_normalize_unit_composition(city.get("unit_composition", {}), dataset),
		"reserve_troops": float(stats.get("reserve_troops", 0.0)),
		"organized_troops": float(stats.get("organized_troops", 0.0)),
		"siege_durability": siege_durability
	}

func _build_runtime_regroup_dataset(city: Dictionary = {}) -> Dictionary:
	var base_dataset: Dictionary = _get_runtime_regroup_base_dataset()
	return _apply_runtime_regroup_tech_traits(base_dataset, city, _regroup_rules_cache)

func _get_runtime_regroup_base_dataset() -> Dictionary:
	if not _regroup_base_dataset_cache.is_empty():
		return _regroup_base_dataset_cache.duplicate(true)
	var rules: Dictionary = _regroup_rules_cache.duplicate(true)
	var dataset: Dictionary = {}
	if bool(rules.get("use_external_source", false)):
		var source_candidates: Array = rules.get("external_source_candidates", [])
		for path_any in source_candidates:
			var path: String = String(path_any).strip_edges()
			if path.is_empty():
				continue
			var external_data: Dictionary = _json_source.load_dictionary(path)
			if external_data.is_empty():
				continue
			var normalized: Dictionary = _normalize_runtime_external_regroup_source(external_data, rules)
			if not normalized.is_empty():
				dataset = normalized
				break
	if dataset.is_empty():
		dataset = {
			"categories": (rules.get("categories", []) as Array).duplicate(true) if rules.get("categories", []) is Array else [],
			"units": (rules.get("units", {}) as Dictionary).duplicate(true) if rules.get("units", {}) is Dictionary else {},
			"unit_aliases": (rules.get("unit_aliases", {}) as Dictionary).duplicate(true) if rules.get("unit_aliases", {}) is Dictionary else {}
		}
	dataset = _merge_runtime_regroup_inline_rules(dataset, rules)
	_regroup_base_dataset_cache = dataset.duplicate(true)
	return _regroup_base_dataset_cache.duplicate(true)

func _merge_runtime_regroup_inline_rules(dataset: Dictionary, rules: Dictionary) -> Dictionary:
	var out: Dictionary = dataset.duplicate(true)
	var categories: Array = (out.get("categories", []) as Array).duplicate(true) if out.get("categories", []) is Array else []
	var units: Dictionary = (out.get("units", {}) as Dictionary).duplicate(true) if out.get("units", {}) is Dictionary else {}
	var unit_aliases: Dictionary = (out.get("unit_aliases", {}) as Dictionary).duplicate(true) if out.get("unit_aliases", {}) is Dictionary else {}
	var default_batch_size: int = maxi(1, int(rules.get("default_batch_size", 100)))

	var inline_units_any: Variant = rules.get("units", {})
	if inline_units_any is Dictionary:
		var inline_units: Dictionary = inline_units_any
		for unit_id_any in inline_units.keys():
			var unit_id: String = String(unit_id_any).strip_edges().to_lower()
			if unit_id.is_empty():
				continue
			var raw_unit_any: Variant = inline_units.get(unit_id_any, {})
			if not (raw_unit_any is Dictionary):
				continue
			var raw_unit: Dictionary = (raw_unit_any as Dictionary).duplicate(true)
			var class_id: String = String(raw_unit.get("class_id", unit_id)).strip_edges().to_lower()
			if class_id.is_empty():
				class_id = unit_id
			var normalized: Dictionary = raw_unit.duplicate(true)
			normalized["id"] = unit_id
			normalized["class_id"] = class_id
			normalized["name"] = String(raw_unit.get("name", unit_id))
			normalized["tier"] = int(raw_unit.get("tier", 1))
			normalized["batch_size"] = maxi(1, int(raw_unit.get("batch_size", default_batch_size)))
			normalized["reserve_per_soldier"] = float(raw_unit.get("reserve_per_soldier", 1.0))
			normalized["time_sec_per_100"] = float(raw_unit.get("time_sec_per_100", 100.0))
			normalized["is_siege_equipment"] = bool(raw_unit.get("is_siege_equipment", _runtime_is_regroup_siege_class_id(class_id, rules)))
			if raw_unit.get("cost_per_soldier", {}) is Dictionary:
				normalized["cost_per_soldier"] = (raw_unit.get("cost_per_soldier", {}) as Dictionary).duplicate(true)
			units[unit_id] = normalized
			unit_aliases[unit_id] = unit_id

	var inline_aliases_any: Variant = rules.get("unit_aliases", {})
	if inline_aliases_any is Dictionary:
		var inline_aliases: Dictionary = inline_aliases_any
		for alias_key_any in inline_aliases.keys():
			var alias_key: String = String(alias_key_any).strip_edges().to_lower()
			var alias_target: String = String(inline_aliases.get(alias_key_any, "")).strip_edges().to_lower()
			if alias_key.is_empty() or alias_target.is_empty():
				continue
			unit_aliases[alias_key] = alias_target

	var category_index: Dictionary = {}
	for i in range(categories.size()):
		if not (categories[i] is Dictionary):
			continue
		var cat_id: String = String((categories[i] as Dictionary).get("id", "")).strip_edges().to_lower()
		if cat_id.is_empty():
			continue
		category_index[cat_id] = i

	var inline_categories_any: Variant = rules.get("categories", [])
	if inline_categories_any is Array:
		for cat_any in (inline_categories_any as Array):
			if not (cat_any is Dictionary):
				continue
			var cat: Dictionary = (cat_any as Dictionary).duplicate(true)
			var cat_id: String = String(cat.get("id", "")).strip_edges().to_lower()
			if cat_id.is_empty():
				continue
			var label: String = String(cat.get("label", _runtime_default_regroup_category_label(cat_id)))
			var cat_units: Array = []
			var raw_cat_units_any: Variant = cat.get("units", [])
			if raw_cat_units_any is Array:
				for unit_key_any in (raw_cat_units_any as Array):
					var unit_key: String = String(unit_key_any).strip_edges().to_lower()
					if unit_key.is_empty():
						continue
					var mapped_id: String = String(unit_aliases.get(unit_key, unit_key)).strip_edges().to_lower()
					if mapped_id.is_empty() or not units.has(mapped_id):
						continue
					if not cat_units.has(mapped_id):
						cat_units.append(mapped_id)
			var merged_cat := {"id": cat_id, "label": label, "units": cat_units}
			if category_index.has(cat_id):
				categories[int(category_index.get(cat_id, 0))] = merged_cat
			else:
				categories.append(merged_cat)
				category_index[cat_id] = categories.size() - 1

	out["categories"] = categories
	out["units"] = units
	out["unit_aliases"] = unit_aliases
	return out

func _normalize_runtime_external_regroup_source(source: Dictionary, rules: Dictionary) -> Dictionary:
	var source_units_any: Variant = source.get("units", {})
	if not (source_units_any is Dictionary):
		return {}
	var source_units: Dictionary = source_units_any as Dictionary
	var class_order: Array = rules.get("class_order", [])
	if class_order.is_empty():
		class_order = source_units.keys()
	var label_overrides: Dictionary = rules.get("class_label_overrides", {})
	var unit_name_overrides: Dictionary = rules.get("unit_name_overrides", {})
	var resource_alias: Dictionary = rules.get("resource_alias", {})
	var class_extra_cost_per_soldier: Dictionary = rules.get("class_extra_cost_per_soldier", {})
	var default_batch_size: int = maxi(1, int(rules.get("default_batch_size", 100)))

	var categories: Array = []
	var units: Dictionary = {}
	var unit_aliases: Dictionary = {}
	for class_id_any in class_order:
		var class_id: String = String(class_id_any).strip_edges().to_lower()
		if class_id.is_empty():
			continue
		var entries: Array = _as_runtime_regroup_entry_array(source_units.get(class_id, []))
		if entries.is_empty():
			continue
		var base_entry: Dictionary = _pick_runtime_regroup_base_entry(entries)
		if base_entry.is_empty():
			continue
		unit_aliases[class_id] = class_id
		for entry_any in entries:
			if not (entry_any is Dictionary):
				continue
			var entry_id: String = String((entry_any as Dictionary).get("id", "")).strip_edges().to_lower()
			if not entry_id.is_empty():
				unit_aliases[entry_id] = class_id
		var stats_any: Variant = base_entry.get("stats", {})
		var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
		var passive_any: Variant = base_entry.get("passive", {})
		var passive: Dictionary = passive_any as Dictionary if passive_any is Dictionary else {}
		var reorganization_any: Variant = base_entry.get("reorganization", {})
		var reorganization: Dictionary = reorganization_any as Dictionary if reorganization_any is Dictionary else {}
		var mapped_cost: Dictionary = _map_runtime_regroup_cost_per_soldier(
			reorganization.get("per_soldier_cost", {}),
			resource_alias,
			class_extra_cost_per_soldier.get(class_id, {})
		)
		var base_stats := {
			"physical_attack": int(stats.get("physical_attack", 0)),
			"magic_attack": int(stats.get("magic_attack", 0)),
			"physical_defense": int(stats.get("physical_defense", 0)),
			"magic_defense": int(stats.get("magic_defense", 0)),
			"move_speed": float(stats.get("move_speed", 0.0)),
			"attack_range": float(stats.get("attack_range", 0.0)),
			"attack_speed": float(stats.get("attack_speed", 0.0))
		}
		var passive_name: String = String(passive.get("name", "")).strip_edges()
		var passive_effect: String = String(passive.get("effect", "")).strip_edges()
		var base_desc: String = passive_effect
		if not passive_name.is_empty():
			base_desc = "%s - %s" % [passive_name, passive_effect]
		var unit_name: String = _runtime_default_regroup_category_label(class_id)
		if unit_name_overrides.has(class_id) and unit_name.strip_edges().is_empty():
			unit_name = String(unit_name_overrides.get(class_id, unit_name)).strip_edges()
		if unit_name.is_empty():
			unit_name = _runtime_default_regroup_category_label(class_id)
		units[class_id] = {
			"id": class_id,
			"class_id": class_id,
			"is_siege_equipment": _runtime_is_regroup_siege_class_id(class_id, rules),
			"name": unit_name,
			"tier": 1,
			"batch_size": default_batch_size,
			"description": base_desc,
			"base_description": base_desc,
			"reserve_per_soldier": float(reorganization.get("reserve_per_soldier", 1.0)),
			"time_sec_per_100": float(reorganization.get("time_sec_per_100", 100.0)),
			"base_time_sec_per_100": float(reorganization.get("time_sec_per_100", 100.0)),
			"cost_per_soldier": mapped_cost.duplicate(true),
			"base_cost_per_soldier": mapped_cost.duplicate(true),
			"stats": base_stats.duplicate(true),
			"base_stats": base_stats.duplicate(true)
		}
		categories.append({
			"id": class_id,
			"label": _runtime_default_regroup_category_label(class_id),
			"units": [class_id]
		})
	return {
		"categories": categories,
		"units": units,
		"unit_aliases": unit_aliases
	}

func _pick_runtime_regroup_base_entry(entries: Array) -> Dictionary:
	var best: Dictionary = {}
	var best_tier: int = 1 << 20
	for entry_any in entries:
		if not (entry_any is Dictionary):
			continue
		var entry: Dictionary = (entry_any as Dictionary).duplicate(true)
		var tier: int = int(entry.get("tier", 1))
		if best.is_empty() or tier < best_tier:
			best = entry
			best_tier = tier
	return best

func _apply_runtime_regroup_tech_traits(dataset: Dictionary, city: Dictionary, rules: Dictionary) -> Dictionary:
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
	var traits_by_class: Dictionary = traits_by_class_any as Dictionary if traits_by_class_any is Dictionary else {}
	var int_stat_keys := {
		"physical_attack": true,
		"magic_attack": true,
		"physical_defense": true,
		"magic_defense": true
	}
	for unit_id_any in units.keys():
		var unit_id: String = String(unit_id_any).strip_edges().to_lower()
		if unit_id.is_empty():
			continue
		var unit_any: Variant = units.get(unit_id_any, {})
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = (unit_any as Dictionary).duplicate(true)
		var class_id: String = String(unit.get("class_id", unit_id)).strip_edges().to_lower()
		var class_traits_any: Variant = traits_by_class.get(class_id, [])
		var class_traits: Array = class_traits_any as Array if class_traits_any is Array else []
		var active_traits: Array = []
		var stats: Dictionary = (unit.get("base_stats", unit.get("stats", {})) as Dictionary).duplicate(true) if unit.get("base_stats", unit.get("stats", {})) is Dictionary else {}
		var cost_per_soldier: Dictionary = (unit.get("base_cost_per_soldier", unit.get("cost_per_soldier", {})) as Dictionary).duplicate(true) if unit.get("base_cost_per_soldier", unit.get("cost_per_soldier", {})) is Dictionary else {}
		var time_sec_per_100: float = float(unit.get("base_time_sec_per_100", unit.get("time_sec_per_100", 100.0)))
		for trait_any in class_traits:
			if not (trait_any is Dictionary):
				continue
			var trait_data: Dictionary = trait_any as Dictionary
			var min_tech_points: float = float(trait_data.get("min_tech_points", 0.0))
			if tech_points + 0.0001 < min_tech_points:
				continue
			active_traits.append(trait_data.duplicate(true))
			var stats_add_any: Variant = trait_data.get("stats_add", {})
			if stats_add_any is Dictionary:
				for stat_key_any in (stats_add_any as Dictionary).keys():
					var stat_key: String = String(stat_key_any)
					var merged: float = float(stats.get(stat_key, 0.0)) + float((stats_add_any as Dictionary).get(stat_key_any, 0.0))
					stats[stat_key] = int(round(merged)) if int_stat_keys.has(stat_key) else merged
			var cost_mul_any: Variant = trait_data.get("cost_per_soldier_mul", {})
			if cost_mul_any is Dictionary:
				for cost_key_any in (cost_mul_any as Dictionary).keys():
					var cost_key: String = String(cost_key_any)
					var mul: float = float((cost_mul_any as Dictionary).get(cost_key_any, 1.0))
					if mul > 0.0:
						cost_per_soldier[cost_key] = float(cost_per_soldier.get(cost_key, 0.0)) * mul
			var time_mul: float = float(trait_data.get("time_sec_per_100_mul", 1.0))
			if time_mul > 0.0:
				time_sec_per_100 *= time_mul
		unit["stats"] = stats
		unit["cost_per_soldier"] = cost_per_soldier
		unit["time_sec_per_100"] = maxf(1.0, time_sec_per_100)
		unit["tech_points"] = tech_points
		unit["tech_traits_active"] = active_traits
		unit["tech_tier_active"] = active_traits.size()
		unit["tech_tier_total"] = class_traits.size()
		unit["description"] = _build_runtime_regroup_description_with_traits(String(unit.get("base_description", unit.get("description", ""))), active_traits)
		units[unit_id] = unit
	out["units"] = units
	return out

func _build_runtime_regroup_description_with_traits(base_desc: String, active_traits: Array) -> String:
	var lines: Array[String] = []
	if not base_desc.strip_edges().is_empty():
		lines.append(base_desc.strip_edges())
	if active_traits.is_empty():
		lines.append("Current tech effects: none")
		return "\n".join(lines)
	var names: Array[String] = []
	for trait_any in active_traits:
		if not (trait_any is Dictionary):
			continue
		var trait_name: String = String((trait_any as Dictionary).get("name", "")).strip_edges()
		if not trait_name.is_empty():
			names.append(trait_name)
	if not names.is_empty():
		lines.append("Traits: %s" % ", ".join(names))
	return "\n".join(lines)

func _build_runtime_regroup_unit_description(entry: Dictionary) -> String:
	var parts: Array[String] = []
	var passive_any: Variant = entry.get("passive", {})
	if passive_any is Dictionary:
		var passive: Dictionary = passive_any as Dictionary
		var passive_name: String = String(passive.get("name", "")).strip_edges()
		var passive_effect: String = String(passive.get("effect", "")).strip_edges()
		if not passive_name.is_empty() and not passive_effect.is_empty():
			parts.append("Trait: %s - %s" % [passive_name, passive_effect])
		elif not passive_effect.is_empty():
			parts.append("Trait: %s" % passive_effect)
	var unlock_any: Variant = entry.get("unlock", {})
	if unlock_any is Dictionary:
		var unlock: Dictionary = unlock_any as Dictionary
		var unlock_tech: String = String(unlock.get("tech", "")).strip_edges()
		if not unlock_tech.is_empty():
			parts.append("Unlock: %s" % unlock_tech)
	return "\n".join(parts)

func _as_runtime_regroup_entry_array(raw: Variant) -> Array:
	if raw is Array:
		return (raw as Array).duplicate(true)
	if raw is Dictionary:
		return [(raw as Dictionary).duplicate(true)]
	return []

func _map_runtime_regroup_cost_per_soldier(source_cost_raw: Variant, resource_alias: Dictionary, extra_raw: Variant) -> Dictionary:
	var out: Dictionary = {}
	if source_cost_raw is Dictionary:
		for key_any in (source_cost_raw as Dictionary).keys():
			var key: String = String(key_any).strip_edges().to_lower()
			if key.is_empty():
				continue
			var mapped_key: String = String(resource_alias.get(key, key)).strip_edges().to_lower()
			if mapped_key.is_empty():
				continue
			out[mapped_key] = float(out.get(mapped_key, 0.0)) + float((source_cost_raw as Dictionary).get(key_any, 0.0))
	if extra_raw is Dictionary:
		for key_any in (extra_raw as Dictionary).keys():
			var key: String = String(key_any).strip_edges().to_lower()
			if key.is_empty():
				continue
			var mapped_key: String = String(resource_alias.get(key, key)).strip_edges().to_lower()
			if mapped_key.is_empty():
				continue
			out[mapped_key] = float(out.get(mapped_key, 0.0)) + float((extra_raw as Dictionary).get(key_any, 0.0))
	return out

func _runtime_default_regroup_category_label(class_id: String) -> String:
	match class_id:
		"cavalry":
			return "Cavalry"
		"spear":
			return "Spear"
		"shield":
			return "Shield"
		"bow":
			return "Bow"
		"crossbow":
			return "Crossbow"
		"siege":
			return "Siege"
		"strategist":
			return "Strategist"
		_:
			return class_id.capitalize()

func _runtime_canonical_regroup_unit_id(unit_id: String, dataset: Dictionary = {}) -> String:
	var normalized: String = unit_id.strip_edges().to_lower()
	if normalized.is_empty():
		return ""
	var lookup_dataset: Dictionary = dataset if not dataset.is_empty() else _get_runtime_regroup_base_dataset()
	var units: Dictionary = lookup_dataset.get("units", {})
	if units.has(normalized):
		return normalized
	var unit_aliases: Dictionary = lookup_dataset.get("unit_aliases", {})
	var mapped: String = String(unit_aliases.get(normalized, "")).strip_edges().to_lower()
	if not mapped.is_empty() and units.has(mapped):
		return mapped
	return normalized if units.has(normalized) else ""

func _runtime_normalize_unit_composition(raw: Variant, dataset: Dictionary = {}) -> Dictionary:
	var out: Dictionary = {}
	if not (raw is Dictionary):
		return out
	var source: Dictionary = raw as Dictionary
	var lookup_dataset: Dictionary = dataset if not dataset.is_empty() else _get_runtime_regroup_base_dataset()
	for unit_id_any in source.keys():
		var canonical_id: String = _runtime_canonical_regroup_unit_id(String(unit_id_any), lookup_dataset)
		if canonical_id.is_empty():
			continue
		out[canonical_id] = float(out.get(canonical_id, 0.0)) + float(source.get(unit_id_any, 0.0))
	return out

func _runtime_is_regroup_siege_class_id(class_id: String, rules: Dictionary = {}) -> bool:
	var clean_class_id: String = class_id.strip_edges().to_lower()
	if clean_class_id.is_empty():
		return false
	var ref_rules: Dictionary = rules if not rules.is_empty() else _regroup_rules_cache
	var configured_any: Variant = ref_rules.get("siege_equipment_class_ids", REGROUP_DEFAULT_SIEGE_CLASS_IDS)
	if configured_any is Array:
		for key_any in (configured_any as Array):
			if clean_class_id == String(key_any).strip_edges().to_lower():
				return true
	for default_id in REGROUP_DEFAULT_SIEGE_CLASS_IDS:
		if clean_class_id == String(default_id).strip_edges().to_lower():
			return true
	return false

func _runtime_regroup_siege_unit_durability_cap(unit: Dictionary) -> float:
	if unit.is_empty():
		return 0.0
	if unit.has("durability_max"):
		return maxf(0.0, float(unit.get("durability_max", 0.0)))
	return 0.0

func _runtime_calc_regroup_unit_cost_for_amount(unit: Dictionary, amount: int) -> Dictionary:
	var out: Dictionary = {}
	if amount <= 0:
		return out
	if unit.has("cost_per_soldier"):
		var cps: Dictionary = unit.get("cost_per_soldier", {})
		for key_any in cps.keys():
			var key: String = String(key_any)
			out[key] = float(cps.get(key, 0.0)) * float(amount)
		return out
	var batch_size: int = maxi(1, int(unit.get("batch_size", 100)))
	var batches: float = float(amount) / float(batch_size)
	var cpb: Dictionary = unit.get("cost_per_batch", {})
	for key_any in cpb.keys():
		var key: String = String(key_any)
		out[key] = float(cpb.get(key, 0.0)) * batches
	return out

func _runtime_evaluate_regroup_plan(city: Dictionary, plans: Array) -> Dictionary:
	var dataset: Dictionary = _build_runtime_regroup_dataset(city)
	var units: Dictionary = dataset.get("units", {})
	var resources_any: Variant = city.get("resources", {})
	var resources: Dictionary = resources_any as Dictionary if resources_any is Dictionary else {}
	var stats_any: Variant = city.get("stats", {})
	var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
	var composition_after: Dictionary = _runtime_normalize_unit_composition(city.get("unit_composition", {}), dataset)
	var siege_any: Variant = city.get("siege_durability", {})
	var siege_durability_after: Dictionary = (siege_any as Dictionary).duplicate(true) if siege_any is Dictionary else {}
	var resources_after: Dictionary = resources.duplicate(true)
	var reserve_before: float = float(stats.get("reserve_troops", 0.0))
	var organized_before: float = float(stats.get("organized_troops", 0.0))
	var total_troop_amount: float = 0.0
	var total_siege_repair_amount: float = 0.0
	var type_count: int = 0

	for plan_any in plans:
		if not (plan_any is Dictionary):
			continue
		var plan: Dictionary = plan_any as Dictionary
		var unit_id: String = _runtime_canonical_regroup_unit_id(String(plan.get("unit_id", "")), dataset)
		var amount: int = int(plan.get("amount", 0))
		if unit_id.is_empty() or amount <= 0:
			continue
		var unit_any: Variant = units.get(unit_id, {})
		if not (unit_any is Dictionary):
			return {"ok": false, "reason": "unit_missing"}
		var unit: Dictionary = unit_any as Dictionary
		var batch_size: int = maxi(1, int(unit.get("batch_size", 100)))
		if amount % batch_size != 0:
			return {"ok": false, "reason": "invalid_amount"}
		var cost_for_amount: Dictionary = _runtime_calc_regroup_unit_cost_for_amount(unit, amount)
		if bool(unit.get("is_siege_equipment", false)):
			var durability_cap: float = _runtime_regroup_siege_unit_durability_cap(unit)
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
			var res_key: String = String(res_key_any)
			resources_after[res_key] = float(resources_after.get(res_key, 0.0)) - float(cost_for_amount.get(res_key, 0.0))
		type_count += 1

	if total_troop_amount <= 0.0 and total_siege_repair_amount <= 0.0:
		return {"ok": false, "reason": "empty_plan"}
	for res_key_any in resources_after.keys():
		if float(resources_after.get(res_key_any, 0.0)) < -0.0001:
			return {"ok": false, "reason": "insufficient_resources"}
	var reserve_after: float = reserve_before - total_troop_amount
	if reserve_after < -0.0001:
		return {"ok": false, "reason": "insufficient_reserve"}
	var organized_after: float = organized_before + total_troop_amount
	return {
		"ok": true,
		"type_count": type_count,
		"total_troop_amount": total_troop_amount,
		"total_siege_repair_amount": total_siege_repair_amount,
		"reserve_after": reserve_after,
		"organized_after": organized_after,
		"resources_after": resources_after,
		"siege_durability_after": siege_durability_after,
		"unit_composition_after": composition_after
	}

func _build_runtime_global_officer_book_panel_data(selected_officer_id: String = "") -> Dictionary:
	if _master_officers.is_empty():
		_reload_master_officer_catalog()
	return {
		"title": "Officer Book",
		"city_id": "",
		"roles": [],
		"officers": [],
		"all_officers": _master_officers.duplicate(true),
		"assignments": {},
		"assignment_names": {},
		"preview": {},
		"selected_role_id": "",
		"selected_officer_id": selected_officer_id
	}

func _build_runtime_expedition_panel_data(city_id: String) -> Dictionary:
	var city: Dictionary = _resolve_world_city(city_id, city_id)
	if city.is_empty():
		var site: Dictionary = _get_site_snapshot(city_id)
		var fallback_city_id: String = String(site.get("city_id", site.get("id", city_id))).strip_edges()
		var fallback_city_name: String = String(site.get("name", city_id)).strip_edges()
		city = _resolve_world_city(fallback_city_id, fallback_city_name)
	if city.is_empty():
		return {
			"title": "Expedition Setup",
			"city_id": city_id,
			"city_name": city_id,
			"officers": [],
			"units": {},
			"unit_composition": {},
			"selected_unit_allocation": {},
			"organized_troops": 0.0,
			"selected_officer_ids": [],
			"ship_options": [
				{"id": "zouge", "label": "Light Skiff"},
				{"id": "lou_chuan", "label": "Tower Ship"}
			],
			"selected_ship_type": "zouge",
			"cancel_text": "Back",
			"decide_text": "Confirm Expedition"
		}
	var resolved_city_id: String = String(city.get("id", city_id)).strip_edges()
	if resolved_city_id.is_empty():
		resolved_city_id = city_id
	var roster: Array = _runtime_build_city_roster_with_master(city)
	var order_any: Variant = _runtime_city_orders.get(resolved_city_id, {})
	var order_entry: Dictionary = (order_any as Dictionary).duplicate(true) if order_any is Dictionary else {}
	var dataset: Dictionary = _build_runtime_regroup_dataset(city)
	var stats_any: Variant = city.get("stats", {})
	var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
	return {
		"title": "Expedition Setup",
		"city_id": resolved_city_id,
		"city_name": String(city.get("name", resolved_city_id)),
		"officers": roster,
		"units": (dataset.get("units", {}) as Dictionary).duplicate(true) if dataset.get("units", {}) is Dictionary else {},
		"unit_composition": _runtime_normalize_unit_composition(city.get("unit_composition", {}), dataset),
		"selected_unit_allocation": _runtime_normalize_unit_composition(order_entry.get("troop_allocation", {}), dataset),
		"organized_troops": float(stats.get("organized_troops", 0.0)),
		"selected_officer_ids": order_entry.get("officer_ids", []),
		"ship_options": [
			{"id": "zouge", "label": "Light Skiff"},
			{"id": "lou_chuan", "label": "Tower Ship"}
		],
		"selected_ship_type": String(order_entry.get("ship_type", "zouge")),
		"cancel_text": "Back",
		"decide_text": "Confirm Expedition"
	}

func _runtime_validate_expedition_troop_payload(city: Dictionary, payload: Dictionary) -> Dictionary:
	if city.is_empty():
		return {"ok": false, "reason": "city_missing"}
	var dataset: Dictionary = _build_runtime_regroup_dataset(city)
	var units: Dictionary = dataset.get("units", {}) as Dictionary if dataset.get("units", {}) is Dictionary else {}
	var available: Dictionary = _runtime_normalize_unit_composition(city.get("unit_composition", {}), dataset)
	var allocation: Dictionary = _runtime_normalize_unit_composition(payload.get("troop_allocation", {}), dataset)
	var stats_any: Variant = city.get("stats", {})
	var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
	var organized_limit: float = maxf(0.0, float(stats.get("organized_troops", 0.0)))
	var normalized: Dictionary = {}
	var total: float = 0.0
	var lead_unit_id: String = ""
	var lead_amount: float = -1.0
	for unit_id_any in allocation.keys():
		var unit_id: String = String(unit_id_any).strip_edges().to_lower()
		if unit_id.is_empty():
			continue
		var amount: float = maxf(0.0, float(allocation.get(unit_id_any, 0.0)))
		if amount <= 0.0:
			continue
		var available_amount: float = maxf(0.0, float(available.get(unit_id, 0.0)))
		if amount > available_amount + 0.001:
			return {"ok": false, "reason": "insufficient_unit_amount", "unit_id": unit_id}
		normalized[unit_id] = amount
		total += amount
		if amount > lead_amount:
			lead_amount = amount
			lead_unit_id = unit_id
	if total <= 0.0:
		return {"ok": false, "reason": "empty_troops"}
	if total > organized_limit + 0.001:
		return {"ok": false, "reason": "insufficient_organized"}
	var lead_unit_name: String = lead_unit_id
	if units.has(lead_unit_id):
		lead_unit_name = String((units.get(lead_unit_id, {}) as Dictionary).get("name", lead_unit_id)).strip_edges()
	var special_active: bool = false
	var effective_troop_id: String = lead_unit_id
	var effective_troop_name: String = lead_unit_name
	var special_base_class: String = String(payload.get("main_special_troop_base_class", "")).strip_edges().to_lower()
	if bool(payload.get("main_special_troop_unlocked", false)) and not special_base_class.is_empty():
		if float(normalized.get(special_base_class, 0.0)) > 0.0:
			special_active = true
			effective_troop_id = String(payload.get("main_special_troop_id", special_base_class)).strip_edges()
			effective_troop_name = String(payload.get("main_special_troop_name", effective_troop_id)).strip_edges()
	return {
		"ok": true,
		"allocation": normalized,
		"total": total,
		"lead_unit_id": lead_unit_id,
		"lead_unit_name": lead_unit_name,
		"effective_troop_id": effective_troop_id,
		"effective_troop_name": effective_troop_name,
		"main_special_troop_active": special_active
	}
func _build_runtime_aides_panel_data(city_id: String, selected_role_id: String = "", selected_officer_id: String = "") -> Dictionary:
	var city: Dictionary = _resolve_world_city(city_id, city_id)
	if city.is_empty():
		var site: Dictionary = _get_site_snapshot(city_id)
		if _runtime_is_ferry_site(site):
			var resolved_site_id: String = String(site.get("id", city_id)).strip_edges()
			if resolved_site_id.is_empty():
				resolved_site_id = city_id
			var site_roster: Array = _runtime_build_site_roster_with_master(site)
			var site_assignments: Dictionary = _runtime_get_city_assignments(site, site_roster, RUNTIME_FERRY_AIDE_ROLES, "")
			return {
				"title": "Ferry Logistics Assignment",
				"city_id": resolved_site_id,
				"roles": RUNTIME_FERRY_AIDE_ROLES.duplicate(true),
				"officers": site_roster.duplicate(true),
				"all_officers": _master_officers.duplicate(true),
				"assignments": site_assignments,
				"assignment_names": _runtime_build_assignment_names(site_assignments, site_roster, RUNTIME_FERRY_AIDE_ROLES),
				"preview": _runtime_build_aide_preview(site, site_roster, RUNTIME_FERRY_AIDE_ROLES, ""),
				"selected_role_id": selected_role_id,
				"selected_officer_id": selected_officer_id
			}
		var fallback_city_id: String = String(site.get("city_id", site.get("id", city_id))).strip_edges()
		var fallback_city_name: String = String(site.get("name", city_id)).strip_edges()
		city = _resolve_world_city(fallback_city_id, fallback_city_name)
	if city.is_empty():
		return _build_runtime_global_officer_book_panel_data(selected_officer_id)
	var resolved_city_id: String = String(city.get("id", city_id)).strip_edges()
	if resolved_city_id.is_empty():
		resolved_city_id = city_id
	var roster: Array = _runtime_build_city_roster_with_master(city)
	var assignments: Dictionary = _runtime_get_city_assignments(city, roster, RUNTIME_CITY_AIDE_ROLES, "taishou")
	return {
		"title": "Aide Assignment",
		"city_id": resolved_city_id,
		"roles": RUNTIME_CITY_AIDE_ROLES.duplicate(true),
		"officers": roster.duplicate(true),
		"all_officers": _master_officers.duplicate(true),
		"assignments": assignments,
		"assignment_names": _runtime_build_assignment_names(assignments, roster, RUNTIME_CITY_AIDE_ROLES),
		"preview": _runtime_build_aide_preview(city, roster, RUNTIME_CITY_AIDE_ROLES, "taishou"),
		"selected_role_id": selected_role_id,
		"selected_officer_id": selected_officer_id
	}

func _runtime_is_ferry_site(site: Dictionary) -> bool:
	if site.is_empty():
		return false
	return String(site.get("type", "")).to_lower().strip_edges() == "ferry"

func _runtime_build_city_roster_with_master(city: Dictionary) -> Array:
	if _master_officers.is_empty():
		_reload_master_officer_catalog()
	var roster_any: Variant = city.get("officer_roster", [])
	var raw_roster: Array = roster_any as Array if roster_any is Array else []
	var out: Array = []
	var seen: Dictionary = {}
	for officer_any in raw_roster:
		if not (officer_any is Dictionary):
			continue
		var source: Dictionary = (officer_any as Dictionary).duplicate(true)
		var merged: Dictionary = _resolve_runtime_world_officer_entry(source)
		if merged.is_empty():
			merged = source.duplicate(true)
		var officer_id: String = String(merged.get("id", source.get("id", ""))).strip_edges()
		if officer_id.is_empty():
			var source_name: String = String(source.get("name", merged.get("name", ""))).strip_edges()
			if not source_name.is_empty():
				var by_name: Dictionary = _find_master_officer_by_name(source_name)
				if not by_name.is_empty():
					for key_any in by_name.keys():
						if not merged.has(key_any):
							merged[key_any] = by_name[key_any]
					officer_id = String(by_name.get("id", "")).strip_edges()
		if officer_id.is_empty() or seen.has(officer_id):
			continue
		seen[officer_id] = true
		merged["id"] = officer_id
		if String(merged.get("name", "")).strip_edges().is_empty():
			merged["name"] = String(source.get("name", officer_id))
		var source_stats_any: Variant = source.get("stats", {})
		if source_stats_any is Dictionary:
			var merged_stats_any: Variant = merged.get("stats", {})
			var merged_stats: Dictionary = merged_stats_any as Dictionary if merged_stats_any is Dictionary else {}
			for stat_key_any in (source_stats_any as Dictionary).keys():
				merged_stats[str(stat_key_any)] = (source_stats_any as Dictionary).get(stat_key_any, 0)
			merged["stats"] = merged_stats
		var source_role_scores_any: Variant = source.get("role_scores", {})
		if source_role_scores_any is Dictionary:
			var merged_role_scores_any: Variant = merged.get("role_scores", {})
			var merged_role_scores: Dictionary = merged_role_scores_any as Dictionary if merged_role_scores_any is Dictionary else {}
			for role_key_any in (source_role_scores_any as Dictionary).keys():
				merged_role_scores[str(role_key_any)] = (source_role_scores_any as Dictionary).get(role_key_any, 0)
			merged["role_scores"] = merged_role_scores
		merged = _runtime_annotate_officer_special_troop(merged)
		out.append(merged)
	if out.is_empty():
		var personnel_any: Variant = city.get("personnel", {})
		if personnel_any is Dictionary:
			var governor_name: String = String((personnel_any as Dictionary).get("governor_name", "")).strip_edges()
			if not governor_name.is_empty():
				var governor: Dictionary = _find_master_officer_by_name(governor_name)
				if not governor.is_empty():
					out.append(_runtime_annotate_officer_special_troop(governor))
	return out

func _runtime_build_site_roster_with_master(site: Dictionary) -> Array:
	if site.is_empty():
		return []
	var site_roster_any: Variant = site.get("officer_roster", [])
	if site_roster_any is Array and not (site_roster_any as Array).is_empty():
		var site_proxy: Dictionary = site.duplicate(true)
		site_proxy["officer_roster"] = (site_roster_any as Array).duplicate(true)
		return _runtime_build_city_roster_with_master(site_proxy)
	var linked_city_id: String = String(site.get("city_id", site.get("id", ""))).strip_edges()
	if linked_city_id.is_empty():
		return _runtime_build_player_faction_roster_with_master()
	var linked_city: Dictionary = _resolve_world_city(linked_city_id, linked_city_id)
	if linked_city.is_empty():
		return _runtime_build_player_faction_roster_with_master()
	return _runtime_build_city_roster_with_master(linked_city)

func _runtime_build_player_faction_roster_with_master() -> Array:
	if _master_officers.is_empty():
		_reload_master_officer_catalog()
	var out: Array = []
	var seen: Dictionary = {}
	var player_faction_id: String = _get_player_faction_id()
	var cities_any: Variant = _world_state_cache.get("cities", [])
	if not (cities_any is Array):
		return out
	for city_any in (cities_any as Array):
		if not (city_any is Dictionary):
			continue
		var city: Dictionary = city_any as Dictionary
		if String(city.get("faction_id", "")).strip_edges() != player_faction_id:
			continue
		var city_roster: Array = _runtime_build_city_roster_with_master(city)
		for officer_any in city_roster:
			if not (officer_any is Dictionary):
				continue
			var officer: Dictionary = (officer_any as Dictionary).duplicate(true)
			var officer_id: String = String(officer.get("id", "")).strip_edges()
			if officer_id.is_empty() or seen.has(officer_id):
				continue
			seen[officer_id] = true
			out.append(officer)
	return out

func _runtime_unique_string_array(raw: Array) -> Array[String]:
	var out: Array[String] = []
	var seen: Dictionary = {}
	for value_any in raw:
		var value: String = String(value_any).strip_edges()
		if value.is_empty() or seen.has(value):
			continue
		seen[value] = true
		out.append(value)
	return out

func _runtime_transfer_unit_composition(source_comp: Variant, target_comp: Variant, organized_amount: float) -> Dictionary:
	var source_after: Dictionary = _runtime_normalize_unit_composition(source_comp)
	var target_after: Dictionary = _runtime_normalize_unit_composition(target_comp)
	var remaining: float = maxf(0.0, organized_amount)
	for unit_id_any in source_after.keys():
		if remaining <= 0.0:
			break
		var unit_id: String = String(unit_id_any).strip_edges()
		if unit_id.is_empty():
			continue
		var current: float = float(source_after.get(unit_id, 0.0))
		if current <= 0.0:
			continue
		var moved: float = minf(current, remaining)
		source_after[unit_id] = current - moved
		target_after[unit_id] = float(target_after.get(unit_id, 0.0)) + moved
		remaining -= moved
	return {"source_after": source_after, "target_after": target_after}

func _runtime_sanitize_move_personnel(personnel_raw: Dictionary, roster: Array) -> Dictionary:
	var personnel: Dictionary = personnel_raw.duplicate(true)
	var roster_ids: Dictionary = {}
	for officer_any in roster:
		if not (officer_any is Dictionary):
			continue
		var officer_id: String = String((officer_any as Dictionary).get("id", "")).strip_edges()
		if officer_id.is_empty():
			continue
		roster_ids[officer_id] = true
	var assignments_any: Variant = personnel.get("assignments", {})
	var assignments: Dictionary = assignments_any as Dictionary if assignments_any is Dictionary else {}
	assignments = assignments.duplicate(true)
	for role_key_any in assignments.keys().duplicate():
		var role_key: String = String(role_key_any).strip_edges()
		var officer_id: String = String(assignments.get(role_key_any, "")).strip_edges()
		if officer_id.is_empty() or roster_ids.has(officer_id):
			continue
		assignments.erase(role_key)
	personnel["assignments"] = assignments
	personnel["officer_count"] = roster.size()
	var taishou_id: String = String(assignments.get("taishou", "")).strip_edges()
	if taishou_id.is_empty():
		personnel["governor_name"] = "-"
	else:
		var officer: Dictionary = _runtime_find_officer_by_id(roster, taishou_id)
		personnel["governor_name"] = String(officer.get("name", "-"))
	return personnel

func _runtime_rebuild_move_officer_scores(base_scores: Dictionary, assignments: Dictionary, roster: Array) -> Dictionary:
	var out: Dictionary = base_scores.duplicate(true)
	for role_any in RUNTIME_CITY_AIDE_ROLES:
		if not (role_any is Dictionary):
			continue
		var role_id: String = String((role_any as Dictionary).get("id", "")).strip_edges()
		if role_id.is_empty():
			continue
		var officer_id: String = String(assignments.get(role_id, "")).strip_edges()
		if officer_id.is_empty():
			out[role_id] = 50.0
			continue
		out[role_id] = _runtime_officer_role_score(_runtime_find_officer_by_id(roster, officer_id), role_id)
	return out
func _runtime_find_officer_by_id(roster: Array, officer_id: String) -> Dictionary:
	var target_id: String = officer_id.strip_edges()
	if target_id.is_empty():
		return {}
	for officer_any in roster:
		if not (officer_any is Dictionary):
			continue
		var officer: Dictionary = officer_any as Dictionary
		if String(officer.get("id", "")).strip_edges() == target_id:
			return officer
	return {}

func _runtime_get_city_assignments(city: Dictionary, roster: Array, roles: Array = RUNTIME_CITY_AIDE_ROLES, fallback_governor_role: String = "taishou") -> Dictionary:
	var personnel_any: Variant = city.get("personnel", {})
	var personnel: Dictionary = personnel_any as Dictionary if personnel_any is Dictionary else {}
	var assignments_any: Variant = personnel.get("assignments", {})
	var assignments: Dictionary = assignments_any as Dictionary if assignments_any is Dictionary else {}
	assignments = assignments.duplicate(true)
	if assignments.is_empty() and not fallback_governor_role.is_empty():
		var governor_name: String = String(personnel.get("governor_name", "")).strip_edges()
		if not governor_name.is_empty():
			for officer_any in roster:
				if not (officer_any is Dictionary):
					continue
				var officer: Dictionary = officer_any as Dictionary
				if String(officer.get("name", "")).strip_edges() == governor_name:
					assignments[fallback_governor_role] = String(officer.get("id", "")).strip_edges()
					break
	var cleanup_keys: Array = assignments.keys().duplicate()
	for key_any in cleanup_keys:
		var role_id: String = str(key_any)
		if not _runtime_is_valid_aide_role(role_id, roles):
			assignments.erase(key_any)
			continue
		var officer_id: String = String(assignments.get(key_any, "")).strip_edges()
		if officer_id.is_empty() or _runtime_find_officer_by_id(roster, officer_id).is_empty():
			assignments.erase(key_any)
	return assignments

func _runtime_build_assignment_names(assignments: Dictionary, roster: Array, roles: Array = RUNTIME_CITY_AIDE_ROLES) -> Dictionary:
	var names: Dictionary = {}
	for role_any in roles:
		if not (role_any is Dictionary):
			continue
		var role_id: String = String((role_any as Dictionary).get("id", "")).strip_edges()
		if role_id.is_empty():
			continue
		var officer_id: String = String(assignments.get(role_id, "")).strip_edges()
		if officer_id.is_empty():
			names[role_id] = "Unassigned"
			continue
		var officer: Dictionary = _runtime_find_officer_by_id(roster, officer_id)
		names[role_id] = String(officer.get("name", "Unassigned"))
	return names

func _runtime_is_valid_aide_role(role_id: String, roles: Array = RUNTIME_CITY_AIDE_ROLES) -> bool:
	var normalized: String = role_id.strip_edges()
	if normalized.is_empty():
		return false
	for role_any in roles:
		if not (role_any is Dictionary):
			continue
		if String((role_any as Dictionary).get("id", "")).strip_edges() == normalized:
			return true
	return false

func _runtime_officer_role_score(officer: Dictionary, role_id: String) -> float:
	if officer.has("role_scores"):
		var role_scores_any: Variant = officer.get("role_scores", {})
		if role_scores_any is Dictionary:
			return float((role_scores_any as Dictionary).get(role_id, 50.0))
	var stats_any: Variant = officer.get("stats", {})
	var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
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

func _runtime_aide_preview_factor(score: float) -> float:
	return clampf((score - 50.0) / 10.0, -5.0, 5.0)

func _runtime_build_aide_role_preview(role_id: String, officer: Dictionary) -> Dictionary:
	var stats_any: Variant = officer.get("stats", {})
	var stats: Dictionary = stats_any as Dictionary if stats_any is Dictionary else {}
	var score: float = _runtime_officer_role_score(officer, role_id)
	var factor: float = _runtime_aide_preview_factor(score)
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
			out["ships"] = round((factor * 1.8) + (intellect - 50.0) * 0.035)
		"duwei":
			out["security"] = factor * 0.55 + (lead - 50.0) * 0.01
			out["defense"] = round((factor * 90.0) + (might - 50.0) * 1.0)
		_:
			out["score"] = score
	return out

func _runtime_negate_aide_preview(preview: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for key_any in preview.keys():
		var key: String = str(key_any)
		if key == "score":
			out[key] = preview[key]
			continue
		var value: Variant = preview[key]
		if value is int or value is float:
			out[key] = -float(value)
	return out

func _runtime_build_aide_preview(city: Dictionary, roster: Array, roles: Array = RUNTIME_CITY_AIDE_ROLES, fallback_governor_role: String = "taishou") -> Dictionary:
	var out: Dictionary = {}
	var assignments: Dictionary = _runtime_get_city_assignments(city, roster, roles, fallback_governor_role)
	for role_any in roles:
		if not (role_any is Dictionary):
			continue
		var role_id: String = String((role_any as Dictionary).get("id", "")).strip_edges()
		if role_id.is_empty():
			continue
		var role_preview: Dictionary = {}
		for officer_any in roster:
			if not (officer_any is Dictionary):
				continue
			var officer: Dictionary = officer_any as Dictionary
			var officer_id: String = String(officer.get("id", "")).strip_edges()
			if officer_id.is_empty():
				continue
			role_preview[officer_id] = _runtime_build_aide_role_preview(role_id, officer)
		var assigned_id: String = String(assignments.get(role_id, "")).strip_edges()
		if assigned_id.is_empty():
			role_preview["__dismiss__"] = {}
		else:
			var assigned_officer: Dictionary = _runtime_find_officer_by_id(roster, assigned_id)
			role_preview["__dismiss__"] = _runtime_negate_aide_preview(_runtime_build_aide_role_preview(role_id, assigned_officer))
		out[role_id] = role_preview
	return out

func _runtime_command_cost_city_action() -> float:
	return 1.0

func _runtime_consume_command_points(cost: float) -> bool:
	var needed: float = maxf(0.0, cost)
	if needed <= 0.0:
		return true
	var meta_any: Variant = _world_state_cache.get("meta", {})
	var meta: Dictionary = meta_any as Dictionary if meta_any is Dictionary else {}
	var available: float = float(meta.get("command_points", 0.0))
	if available + 0.0001 < needed:
		return false
	meta["command_points"] = maxf(0.0, available - needed)
	_world_state_cache["meta"] = meta
	return true

func _on_runtime_aide_change_requested(city_id: String, role_id: String, officer_id: String) -> void:
	_on_runtime_aide_batch_change_requested(city_id, [{"role_id": role_id, "officer_id": officer_id}])

func _on_runtime_aide_batch_change_requested(city_id: String, changes: Array) -> void:
	if _runtime_ui_layer == null:
		return
	if _runtime_phase != RUNTIME_PHASE_INTERNAL:
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Aide changes can only be submitted during the internal phase.")
		return
	if changes.is_empty():
		return
	var target: Dictionary = {}
	var target_kind: String = ""
	var roles: Array = RUNTIME_CITY_AIDE_ROLES
	var fallback_governor_role: String = "taishou"
	var resolved_target_id: String = city_id.strip_edges()
	if resolved_target_id.is_empty():
		resolved_target_id = city_id
	var target_faction: String = ""
	var roster: Array = []

	var city: Dictionary = _resolve_world_city(city_id, city_id)
	if not city.is_empty():
		target_kind = "city"
		target = city.duplicate(true)
		resolved_target_id = String(city.get("id", city_id)).strip_edges()
		if resolved_target_id.is_empty():
			resolved_target_id = city_id
		target_faction = String(city.get("faction_id", "")).strip_edges()
		roster = _runtime_build_city_roster_with_master(city)
	else:
		var site: Dictionary = _resolve_world_building(city_id, city_id)
		if site.is_empty():
			site = _get_site_snapshot(city_id)
		if _runtime_is_ferry_site(site):
			target_kind = "ferry"
			target = site.duplicate(true)
			roles = RUNTIME_FERRY_AIDE_ROLES
			fallback_governor_role = ""
			resolved_target_id = String(site.get("id", city_id)).strip_edges()
			if resolved_target_id.is_empty():
				resolved_target_id = city_id
			target_faction = String(site.get("faction_id", "")).strip_edges()
			if target_faction.is_empty():
				target_faction = _get_player_faction_id()
				if not target_faction.is_empty():
					target["faction_id"] = target_faction
			roster = _runtime_build_site_roster_with_master(site)
		else:
			var fallback_city_id: String = String(site.get("city_id", site.get("id", city_id))).strip_edges()
			var fallback_city_name: String = String(site.get("name", city_id)).strip_edges()
			city = _resolve_world_city(fallback_city_id, fallback_city_name)
			if not city.is_empty():
				target_kind = "city"
				target = city.duplicate(true)
				resolved_target_id = String(city.get("id", fallback_city_id)).strip_edges()
				if resolved_target_id.is_empty():
					resolved_target_id = fallback_city_id
				target_faction = String(city.get("faction_id", "")).strip_edges()
				roster = _runtime_build_city_roster_with_master(city)

	if target_kind.is_empty() or target.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No valid city or ferry target found for aide changes.")
		return
	if target_faction != _get_player_faction_id():
		var deny_text: String = "You can only assign aides in your own city."
		if target_kind == "ferry":
			deny_text = "You can only assign ferry aides for your own ferry."
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), deny_text)
		return
	if roster.is_empty():
		var no_officer_text: String = "No available officers in this city."
		if target_kind == "ferry":
			no_officer_text = "No available officers at this ferry."
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), no_officer_text)
		return

	var assignments: Dictionary = _runtime_get_city_assignments(target, roster, roles, fallback_governor_role)
	var valid_changes: Array = []
	for change_any in changes:
		if not (change_any is Dictionary):
			continue
		var change: Dictionary = change_any as Dictionary
		var role_id: String = String(change.get("role_id", "")).strip_edges()
		var officer_id: String = String(change.get("officer_id", "")).strip_edges()
		if not _runtime_is_valid_aide_role(role_id, roles):
			continue
		var before_id: String = String(assignments.get(role_id, "")).strip_edges()
		if before_id == officer_id:
			continue
		if not officer_id.is_empty() and _runtime_find_officer_by_id(roster, officer_id).is_empty():
			continue
		valid_changes.append({"role_id": role_id, "officer_id": officer_id})
	if valid_changes.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No valid aide changes to submit.")
		return
	var resolved_assignments: Dictionary = assignments.duplicate(true)
	for entry_any in valid_changes:
		var entry: Dictionary = entry_any as Dictionary
		var role_id: String = String(entry.get("role_id", "")).strip_edges()
		var officer_id: String = String(entry.get("officer_id", "")).strip_edges()
		if role_id.is_empty():
			continue
		if officer_id.is_empty():
			resolved_assignments.erase(role_id)
			continue
		for role_any in roles:
			if not (role_any is Dictionary):
				continue
			var other_role_id: String = String((role_any as Dictionary).get("id", "")).strip_edges()
			if other_role_id.is_empty() or other_role_id == role_id:
				continue
			if String(resolved_assignments.get(other_role_id, "")).strip_edges() != officer_id:
				continue
			resolved_assignments.erase(other_role_id)
		resolved_assignments[role_id] = officer_id
	var final_changes: Array = []
	for role_any in roles:
		if not (role_any is Dictionary):
			continue
		var role_id: String = String((role_any as Dictionary).get("id", "")).strip_edges()
		if role_id.is_empty():
			continue
		var before_id: String = String(assignments.get(role_id, "")).strip_edges()
		var after_id: String = String(resolved_assignments.get(role_id, "")).strip_edges()
		if before_id == after_id:
			continue
		final_changes.append({"role_id": role_id, "officer_id": after_id})
	if final_changes.is_empty():
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "No valid aide changes to submit.")
		return
	var total_cost: float = _runtime_command_cost_city_action() * float(final_changes.size())
	if not _runtime_consume_command_points(total_cost):
		_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), "Not enough command points to assign aides.")
		_refresh_runtime_ui_hud(true)
		return
	var personnel_any: Variant = target.get("personnel", {})
	var personnel: Dictionary = personnel_any as Dictionary if personnel_any is Dictionary else {}
	var officers_score_any: Variant = target.get("officers", {})
	var officers_score: Dictionary = officers_score_any as Dictionary if officers_score_any is Dictionary else {}
	for entry_any in final_changes:
		var entry: Dictionary = entry_any as Dictionary
		var role_id: String = String(entry.get("role_id", "")).strip_edges()
		var officer_id: String = String(entry.get("officer_id", "")).strip_edges()
		if officer_id.is_empty():
			assignments.erase(role_id)
			officers_score[role_id] = 50.0
			if role_id == "taishou":
				personnel["governor_name"] = "-"
			continue
		var officer: Dictionary = _runtime_find_officer_by_id(roster, officer_id)
		assignments[role_id] = officer_id
		officers_score[role_id] = _runtime_officer_role_score(officer, role_id)
		if role_id == "taishou":
			personnel["governor_name"] = String(officer.get("name", "-"))
	if target_kind == "ferry":
		personnel["governor_name"] = "-"
	personnel["assignments"] = assignments
	personnel["officer_count"] = roster.size()
	target["personnel"] = personnel
	target["officers"] = officers_score
	target["officer_roster"] = roster
	if target_kind == "city":
		_upsert_world_city(target)
	else:
		_upsert_world_building_unit(target)
	_selected_site_id = resolved_target_id
	_runtime_ui_layer.hide_command_panel()
	var success_text: String = "Aide changes submitted successfully."
	if target_kind == "ferry":
		success_text = "Ferry aide changes submitted successfully."
	_runtime_ui_layer.show_hover_info(get_viewport().get_mouse_position(), success_text)
	_refresh_runtime_ui_hud(true)

func _on_camera_zoom_lod_changed(level: int, total_levels: int, _height: float) -> void:
	var overview_enabled: bool = total_levels > 0 and level >= total_levels
	if _camera != null and _camera.has_method("set_overview_mode"):
		_camera.call("set_overview_mode", overview_enabled, overview_enabled)
	if _terrain != null:
		_terrain.visible = not overview_enabled
	if _political_overlay != null:
		_political_overlay.visible = overview_enabled or _supply_corridor_view_enabled
		_refresh_supply_corridor_region_overlay()
	if _city_overlay != null:
		_city_overlay.apply_camera_lod(level, total_levels, _height)
	if _runtime_unit_root != null and is_instance_valid(_runtime_unit_root):
		_runtime_unit_root.visible = not overview_enabled
	if _runtime_mobile_root != null and is_instance_valid(_runtime_mobile_root):
		_runtime_mobile_root.visible = not overview_enabled
	_refresh_runtime_fog_overlay()
	if _supply_route_overlay_root != null and is_instance_valid(_supply_route_overlay_root):
		_set_supply_route_overlay_visible(_supply_route_overlay_should_show())
	if _supply_debug_root != null and is_instance_valid(_supply_debug_root):
		_supply_debug_root.visible = _supply_debug_enabled and not overview_enabled
	if _runtime_siege_info_root != null and is_instance_valid(_runtime_siege_info_root):
		_runtime_siege_info_root.visible = (not overview_enabled) and (_runtime_phase == RUNTIME_PHASE_BATTLE or _runtime_phase == RUNTIME_PHASE_INTERNAL)
	if _strategic_site_manager != null and _strategic_site_manager.has_method("apply_camera_lod"):
		_strategic_site_manager.call("apply_camera_lod", level, total_levels, _height)
