extends Node3D
class_name BattlefieldController
signal weather_state_changed(weather_patch: Dictionary)

const UnitController := preload("res://scripts/unit_controller.gd")
const BattleCameraController := preload("res://scripts/battle_camera_controller.gd")
const UNIT_CONTROLLER_SCENE := preload("res://scenes/units/unit_controller.tscn")
const GROUND_LAYER_MASK := 1
const RTS_PANEL_SCENE := preload("res://scenes/ui/rts_unit_command_panel.tscn")
const RTS_HOVER_PANEL_SCENE := preload("res://scenes/ui/rts_unit_hover_panel.tscn")
const TACTIC_CAST_VFX_SCENE := preload("res://scenes/vfx/tactic_cast_vfx.tscn")
const TACTIC_SUCCESS_VFX_SCENE := preload("res://scenes/vfx/tactic_success_vfx.tscn")
const TACTIC_TEX_STAR_03 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/star_03_a.png")
const TACTIC_TEX_FLARE_01 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/flare_01_a.png")
const TACTIC_TEX_TWIRL_02 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/twirl_02_a.png")
const TACTIC_TEX_TWIRL_03 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/twirl_03_a.png")
const TACTIC_TEX_TWIRL_04 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/twirl_04_a.png")
const TACTIC_TEX_CIRCLE_02 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/circle_02_a.png")
const TACTIC_TEX_TRACE_05 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/trace_05_a.png")
const TACTIC_TEX_TRACE_06 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/trace_06_a.png")
const TACTIC_TEX_SPOTLIGHT_03 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/spotlight_03_a.png")
const TACTIC_TEX_SPOTLIGHT_06 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/spotlight_06_a.png")
const TACTIC_TEX_LIGHT_03 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/light_03_a.png")
const TACTIC_TEX_FIRE_02 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/fire_02_a.png")
const TACTIC_TEX_FLAME_04 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/flame_04_a.png")
const TACTIC_TEX_FLAME_05 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/flame_05_a.png")
const TACTIC_TEX_FLAME_06 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/flame_06_a.png")
const TACTIC_TEX_SMOKE_06 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/smoke_06_a.png")
const TACTIC_TEX_SPARK_02 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/spark_02_a.png")
const TACTIC_TEX_SPARK_05 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/spark_05_a.png")
const TACTIC_TEX_SPARK_06 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/spark_06_a.png")
const TACTIC_TEX_SYMBOL_01 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/symbol_01_a.png")
const TACTIC_TEX_SYMBOL_02 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/symbol_02_a.png")
const TACTIC_TEX_DIRT_02 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/dirt_02_a.png")
const TACTIC_TEX_SCRATCH_01 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/scratch_01_a.png")
const TACTIC_TEX_MAGIC_02 := preload("res://素材/brackeys_vfx_bundle/particles/alpha/magic_02_a.png")
const TACTIC_TEX_STAR_EXPLOSION := preload("res://素材/brackeys_vfx_bundle/predrawn/star_explosion_6x5.png")
const TACTIC_TEX_WAVY_BLUE := preload("res://素材/brackeys_vfx_bundle/predrawn/wavy_blue_6x5.png")
const TACTIC_TEX_WAVY_PURPLE := preload("res://素材/brackeys_vfx_bundle/predrawn/wavy_purple_6x5.png")
const TACTIC_TEX_LIGHTSTREAKS := preload("res://素材/brackeys_vfx_bundle/predrawn/lightstreaks_6x5.png")
const TACTIC_TEX_FIRE_RING := preload("res://素材/brackeys_vfx_bundle/predrawn/fire_ring_6x5.png")
const TACTIC_TEX_FIRE_POINT := preload("res://素材/brackeys_vfx_bundle/predrawn/fire_point_6x5.png")
const TACTIC_TEX_ELECTRIC_RING := preload("res://素材/brackeys_vfx_bundle/predrawn/electric_ring_6x5.png")
const TACTIC_TEX_BIG_HIT := preload("res://素材/brackeys_vfx_bundle/predrawn/big_hit_6x5.png")
const TACTIC_TEX_VORTEX := preload("res://素材/brackeys_vfx_bundle/predrawn/vortex_6x5.png")
const TACTIC_TEX_FIRE_FLIPBOOK_03 := preload("res://素材/brackeys_vfx_bundle/flipbooks/fire_03_8x8.tga")
const WEATHER_SETTINGS_PATH := "res://data/config/weather_settings.json"
const BATTLE_RULES_PATH := "res://data/config/battle_rules.json"
const UNIQUE_SKILLS_PATH := "res://data/config/unique_skills_v1.json"
const UNIT_BUILD_MENU_ACTIONS := [
	{"id": "build_muzhai", "label": "建木寨"},
	{"id": "build_granary", "label": "建粮仓"},
	{"id": "build_jianlou", "label": "建箭楼"},
	{"id": "build_zhalan", "label": "建栅栏"},
	{"id": "build_taigutai", "label": "建太鼓台"}
]
const TACTIC_FIRE_FLAME_SHADER := preload("res://scripts/shaders/tactic_fire_flame.gdshader")
const TAG_FONT_PATH := "res://\u7d20\u6750/\u6c47\u6587\u660e\u671d\u4f53\u6c47\u6587\u660e\u671d\u4f53.ttf"
const TAG_SIZE := Vector2(136.0, 56.0)
const TAG_TEXT_BRONZE := Color(0.71, 0.58, 0.34)
const TAG_BAR_GREEN := Color(0.12, 0.62, 0.39)
const TAG_BAR_EMPTY := Color(0.43, 0.33, 0.18)
const TAG_LINE_BRONZE := Color(0.49, 0.39, 0.23)
const TAG_FRAME_GOLD := Color(0.76, 0.62, 0.34, 0.96)
const DEMO_UNITS_ROOT_NAME := "UnitsRoot"
const DEMO_TEAM_A_NAME := "TeamA"
const DEMO_TEAM_B_NAME := "TeamB"
const DEMO_FACILITY_ROOT_NAME := "DemoFacilities"
const SIEGE_VARIANT_ORDER: Array[String] = ["ram", "ladder", "catapult"]
const SIEGE_VARIANT_ALIAS_TO_ID := {
	"ram": "ram",
	"siege_ram": "ram",
	"siege-ram": "ram",
	"siege:ram": "ram",
	"wood_beast": "ram",
	"woodbeast": "ram",
	"chongche": "ram",
	"冲车": "ram",
	"木兽": "ram",
	"ladder": "ladder",
	"siege_ladder": "ladder",
	"siege-ladder": "ladder",
	"siege:ladder": "ladder",
	"jinglan": "ladder",
	"yunti": "ladder",
	"云梯": "ladder",
	"井阑": "ladder",
	"catapult": "catapult",
	"siege_catapult": "catapult",
	"siege-catapult": "catapult",
	"siege:catapult": "catapult",
	"toushiche": "catapult",
	"投石车": "catapult"
}
const MOVE_REPAIR_RADII := [16.0, 36.0, 64.0, 96.0, 140.0, 200.0, 280.0]
const MOVE_REPAIR_DIRECTIONS := 12
const WATER_TERRAIN_ID := "water"
const TAG_BOARD_SIZE := Vector2(6.20, 3.10)
const TAG_FRAME_SIZE := Vector2(6.52, 3.42)
const TAG_BOARD_Z := 0.0
const TAG_TEXT_Z := 0.016
const TAG_NAME_POS := Vector3(-1.88, 0.86, TAG_TEXT_Z + 0.001)
const TAG_TYPE_POS := Vector3(0.18, 0.86, TAG_TEXT_Z + 0.001)
const TAG_COUNT_POS := Vector3(2.38, 0.86, TAG_TEXT_Z + 0.001)
const TAG_PORTRAIT_SIZE := Vector2(1.56, 1.56)
const TAG_PORTRAIT_POS := Vector3(-2.26, -0.08, TAG_TEXT_Z + 0.001)
const TAG_PORTRAIT_PATH := "res://素材/立绘/关羽.png"
const TAG_PORTRAIT_DIR_PATH := "res://素材/立绘"
const TAG_BAR_SIZE := Vector2(4.30, 0.30)
const TAG_BAR_CENTER_X := 0.58
const TAG_MORALE_BAR_Y := -0.22
const TAG_WILL_BAR_Y := -0.72
const UNIT_TAG_FLAG_SHADER := preload("res://scripts/presentation/unit_tag_flag.gdshader")
const UNIT_TAG_DIALOGUE_PAPER_SHADER := preload("res://scripts/presentation/unit_tag_dialogue_paper.gdshader")
const TACTIC_THUNDER_BOLT_SHADER := preload("res://scripts/shaders/tactic_thunder_bolt.gdshader")
const REPORT_REWARD_UNIT_DEFEAT := {"war_merit": 14, "gongji": 9, "tech_points": 2, "grain": 28, "wood": 16, "iron": 10}
const REPORT_REWARD_FACILITY_DESTROY := {"war_merit": 20, "gongji": 13, "tech_points": 3, "grain": 40, "wood": 24, "iron": 14}
const REPORT_REWARD_CITY_CAPTURE := {"war_merit": 48, "gongji": 30, "tech_points": 6, "grain": 120, "wood": 78, "iron": 52}
const COMMANDER_PORTRAIT_FILE_OVERRIDES := {
	"关羽": ["关羽.png"],
	"张飞": ["张飞.png"],
	"诸葛亮": ["诸葛亮.png"],
	"刘备": ["刘备.png", "jimeng-2026-02-17-9474-刘备，东汉末年正统古风，三国人物官方立绘，统一半身像（头部到腰胯），柔和侧光，明....png"],
	"曹操": ["曹操.png", "jimeng-2026-02-17-7682-曹操，手持佩剑，中年英武威仪面容，蓄三国正统雅致胡须，身着魏国玄黑鎏金制式朝服配....png"],
	"赵云": ["赵云.png", "jimeng-2026-02-17-8183-赵云，手持银色长枪，俊朗英武的青年猛将面容，眼神锐利明亮，，高束马尾配亮银云纹战....png"],
	"司马懿": ["司马懿.png"],
	"夏侯惇": ["夏侯惇.png", "jimeng-2026-02-17-3038-夏侯惇，手持长枪，左目佩戴玄黑镶金边眼罩，刚毅凌厉的中年猛将面容，眼神果决沉稳，....png"],
	"甘宁": ["甘宁.png", "jimeng-2026-02-17-8074-甘宁，手持双戟，腰间点缀铜铃配饰，桀骜凌厉的青年猛将面容，眼神锐利带悍气，身着东....png"],
	"黄忠": ["黄忠.png", "jimeng-2026-02-17-4697-黄忠，身穿布衣，哑光质感金甲，张弓搭箭。东汉末年正统古风，三国人物官方立绘，统一....png"]
}
const DEMO_TEAM0_COMMANDER_POOL: Array[String] = ["关羽", "张飞", "赵云", "马超", "黄忠", "刘备", "甘宁", "太史慈", "吕布", "诸葛亮"]
const DEMO_TEAM1_COMMANDER_POOL: Array[String] = ["曹操", "司马懿", "夏侯惇", "张辽", "典韦", "孙权", "陆逊", "甘宁", "太史慈", "吕布"]
const DEMO_TEAM0_STRATEGIST_POOL: Array[String] = ["诸葛亮", "庞统", "法正", "徐庶", "郭嘉", "荀彧"]
const DEMO_TEAM1_STRATEGIST_POOL: Array[String] = ["司马懿", "贾诩", "荀攸", "郭嘉", "陆逊", "周瑜"]

@export var units_per_team: int = 6
@export var soldiers_per_unit: int = 20
@export var embedded_on_strategy_map: bool = false
@export var auto_spawn_demo_units: bool = true
@export var spawn_center: Vector3 = Vector3.ZERO
@export var team_spacing_x: float = 8.0
@export var team_front_offset_z: float = 26.0
@export var raycast_length: float = 5000.0
@export var unit_node_scale: float = 1.0
@export var infantry_model_scale_mul: float = 1.6
@export var cavalry_model_scale_mul: float = 2.6
@export_range(1.0, 4.0, 0.1) var spear_model_scale_mul: float = 2.0
@export_range(1.0, 4.0, 0.1) var archer_model_scale_mul: float = 2.0
@export var archer_role_attack_range: float = 60.0
@export var archer_role_attack_interval: float = 1.05
@export var unit_base_max_hp: float = 5000.0
@export var unit_base_attack_damage: float = 3.4
@export var unit_skill_cd_charge: float = 10.0
@export var unit_skill_cd_breakthrough: float = 14.0
@export var unit_skill_cd_sweep: float = 12.0
@export var unit_skill_spirit_cost_charge: float = 10.0
@export var unit_skill_spirit_cost_breakthrough: float = 14.0
@export var unit_skill_spirit_cost_sweep: float = 20.0
@export var unit_skill_will_cost_charge: float = 10.0
@export var unit_skill_will_cost_breakthrough: float = 14.0
@export var unit_skill_will_cost_sweep: float = 20.0
@export var right_click_enemy_pick_radius_px: float = 95.0
@export var command_marker_move_duration: float = 0.55
@export var command_marker_attack_duration: float = 0.65
@export var command_marker_move_radius: float = 1.15
@export var command_marker_attack_radius: float = 1.28
@export var command_marker_show_attack: bool = false
@export var unit_player_force_chase_sec: float = 18.0
@export var unit_player_force_chase_max_distance: float = 320.0
@export var unit_player_force_chase_never_timeout: bool = true
@export var unit_player_force_chase_ignore_distance: bool = true
@export var unit_nav_goal_retry_max_attempts: int = 3
@export var unit_nav_goal_retry_radius_step: float = 3.0
@export var unit_nav_goal_retry_directions: int = 12
@export var unit_nav_goal_retry_snap_distance_mul: float = 1.35
@export var unit_morale_loss_per_10pct_troop: float = 10.0
@export var unit_morale_stat_penalty_per_10: float = 0.05
@export var unit_morale_zero_hp_loss_per_sec: float = 0.02
@export var unit_rout_troop_ratio_normal: float = 0.2
@export var unit_rout_troop_ratio_garrison: float = 0.1
@export var unit_garrison_morale_loss_mul: float = 0.5
@export var unit_morale_loss_countered_bonus: float = 3.0
@export var unit_morale_loss_flanked_bonus: float = 4.0
@export var unit_morale_loss_out_of_supply_per_sec: float = 2.2
@export var unit_morale_loss_special_terrain_per_sec: float = 1.2
@export var unit_morale_loss_burning_per_sec: float = 1.0
@export var terrain_adaptation_enabled: bool = true
@export var terrain_adaptation_interval_sec: float = 0.35
@export var terrain_status_hold_sec: float = 0.8
@export var role_counter_damage_matrix: Dictionary = {}
@export var role_terrain_profiles: Dictionary = {}
@export var height_advantage_enabled: bool = true
@export var height_advantage_rules: Dictionary = {}
@export var role_height_modifiers: Dictionary = {}
@export var soldier_formation_spacing: float = 0.6
@export var soldier_use_model_albedo_texture: bool = true
@export var soldier_team_tint_strength: float = 0.35
@export var show_unit_tags: bool = true
@export var team_a_unit_roles: PackedStringArray = PackedStringArray(["infantry", "infantry"])
@export var team_b_unit_roles: PackedStringArray = PackedStringArray(["spear", "archer", "strategist_s", "strategist_a", "strategist_b", "strategist_c"])
var team_a_deployment: Array[Dictionary] = []
@export var demo_facility_test_setup_enabled: bool = true
@export var demo_facility_effect_tick_interval: float = 0.25
@export var demo_jianlou_range: float = 32.0
@export var demo_jianlou_damage: float = 20.0
@export var demo_jianlou_cooldown: float = 1.2
@export var demo_gaojijianlou_range: float = 42.0
@export var demo_gaojijianlou_damage: float = 32.0
@export var demo_gaojijianlou_cooldown: float = 0.9
@export var demo_taigutai_recover_range: float = 26.0
@export var demo_taigutai_morale_recover_per_sec: float = 1.8
@export var demo_taigutai_will_recover_per_sec: float = 2.4
@export var demo_junyuetai_attack_buff_range: float = 30.0
@export var demo_junyuetai_attack_buff_hold_sec: float = 0.45
@export var demo_muzhai_defense_range: float = 24.0
@export var demo_chengzhai_defense_range: float = 34.0
@export var demo_defense_buff_hold_sec: float = 0.45
@export var demo_siege_vs_facility_enabled: bool = true
@export var demo_siege_vs_facility_dps_scale: float = 1.8
@export var demo_siege_facility_destroy_log_enabled: bool = true
@export var demo_siege_ai_priority_enabled: bool = true
@export var demo_siege_ai_apply_to_player_team: bool = false
@export_range(0.1, 5.0, 0.1) var demo_siege_ai_order_interval: float = 0.9
@export_range(1.0, 80.0, 0.5) var demo_siege_ai_retarget_tolerance: float = 8.0
@export var demo_siege_ai_only_facility_mode: bool = true
@export var demo_siege_objective_enabled: bool = true
@export var demo_siege_objective_require_all_city_falls: bool = true
@export var demo_siege_objective_report_enabled: bool = true
@export_range(0.5, 12.0, 0.1) var demo_siege_objective_status_hold_sec: float = 4.2
@export var demo_siege_objective_panel_enabled: bool = true
@export_range(0.1, 5.0, 0.1) var demo_siege_objective_panel_refresh_sec: float = 0.35
@export var demo_siege_objective_panel_show_prediction: bool = true
@export var demo_siege_variant_skill_enabled: bool = true
@export_range(2.0, 40.0, 0.5) var demo_siege_skill_cd_ram: float = 14.0
@export_range(2.0, 40.0, 0.5) var demo_siege_skill_cd_ladder: float = 12.0
@export_range(2.0, 40.0, 0.5) var demo_siege_skill_cd_catapult: float = 16.0
@export_range(0.1, 12.0, 0.1) var demo_siege_skill_ram_bonus_sec: float = 2.0
@export_range(0.1, 12.0, 0.1) var demo_siege_skill_ladder_bonus_sec: float = 1.6
@export_range(0.1, 12.0, 0.1) var demo_siege_skill_catapult_bonus_sec: float = 2.4
@export var demo_siege_debug_overlay_enabled: bool = true
@export_range(0.1, 5.0, 0.1) var demo_siege_debug_overlay_refresh_sec: float = 0.35
@export var demo_siege_facility_hp_by_type: Dictionary = {
	"default": 360.0,
	"jianlou": 260.0,
	"gaojijianlou": 360.0,
	"muzhai": 520.0,
	"chengzhai": 880.0,
	"zhalan": 220.0,
	"taigutai": 300.0,
	"junyuetai": 340.0,
	"granary": 420.0
}
@export var demo_siege_facility_attack_radius_by_type: Dictionary = {
	"default": 12.0,
	"jianlou": 15.0,
	"gaojijianlou": 17.0,
	"muzhai": 12.0,
	"chengzhai": 14.0,
	"zhalan": 11.0,
	"taigutai": 12.0,
	"junyuetai": 12.0,
	"granary": 12.0
}
@export var demo_siege_role_damage_mul: Dictionary = {
	"default": 0.38,
	"siege": 1.35,
	"shield": 0.48,
	"spear": 0.42,
	"archer": 0.3,
	"crossbow": 0.55,
	"cavalry": 0.26,
	"scout": 0.18,
	"strategist": 0.22,
	"naval": 0.5
}
@export var demo_siege_target_damage_mul: Dictionary = {
	"default": 1.0,
	"jianlou": 1.15,
	"gaojijianlou": 1.22,
	"muzhai": 1.0,
	"chengzhai": 1.08,
	"zhalan": 1.35,
	"taigutai": 0.95,
	"junyuetai": 0.95,
	"granary": 1.05
}
@export var demo_siege_variant_effects: Dictionary = {
	"ram": {
		"unit_damage_mul": 1.04,
		"target_role_mul": {"shield": 1.18, "infantry": 1.08, "default": 1.0},
		"facility_damage_mul": 1.26,
		"facility_target_mul": {"zhalan": 1.2, "muzhai": 1.16, "chengzhai": 1.2, "default": 1.0},
		"on_hit_burn_chance": 0.26,
		"on_hit_burn_duration_sec": 4.8,
		"on_hit_burn_dps": 5.8,
		"on_hit_proc_cooldown_sec": 2.4,
		"facility_burn_radius": 6.2,
		"facility_burn_chance": 0.34,
		"facility_burn_duration_sec": 4.8,
		"facility_burn_dps": 4.4,
		"facility_proc_cooldown_sec": 2.8
	},
	"ladder": {
		"unit_damage_mul": 1.08,
		"target_role_mul": {"shield": 1.12, "spear": 1.1, "archer": 1.16, "crossbow": 1.16, "strategist": 1.2, "default": 1.0},
		"facility_damage_mul": 0.94,
		"on_hit_morale_damage": 5.0,
		"on_hit_proc_cooldown_sec": 1.8,
		"facility_morale_per_sec": 1.4,
		"facility_effect_radius": 8.0
	},
	"catapult": {
		"unit_damage_mul": 0.96,
		"ranged_damage_mul": 1.12,
		"target_role_mul": {"archer": 1.12, "crossbow": 1.12, "shield": 0.92, "default": 1.0},
		"facility_damage_mul": 1.34,
		"facility_target_mul": {"chengzhai": 1.22, "gaojijianlou": 1.18, "default": 1.0},
		"on_hit_splash_ratio": 0.22,
		"on_hit_splash_radius": 5.8,
		"on_hit_morale_damage": 2.4,
		"on_hit_proc_cooldown_sec": 2.8,
		"facility_splash_ratio": 0.18,
		"facility_splash_radius": 6.4,
		"facility_proc_cooldown_sec": 2.8
	}
}
@export var demo_recon_enabled: bool = true
@export var demo_recon_tick_interval: float = 0.25
@export var demo_recon_spot_duration_sec: float = 12.0
@export_range(1.0, 3.0, 0.05) var demo_recon_scout_vision_mul: float = 1.35
@export var demo_recon_player_team_id: int = 0
@export var demo_recon_lost_log_enabled: bool = true
@export var demo_recon_day_phase_vision_mul: Dictionary = {
	"day": 1.0,
	"night": 0.88
}
@export var demo_recon_weather_vision_mul: Dictionary = {
	"sunny": 1.0,
	"cloudy": 0.96,
	"windy": 0.94,
	"rain": 0.9,
	"storm": 0.86,
	"fog": 0.82
}
@export var demo_recon_day_phase_spot_duration_mul: Dictionary = {
	"day": 1.0,
	"night": 0.92
}
@export var demo_recon_weather_spot_duration_mul: Dictionary = {
	"sunny": 1.0,
	"cloudy": 0.98,
	"windy": 0.95,
	"rain": 0.9,
	"storm": 0.86,
	"fog": 0.88
}
@export_range(0.5, 3.0, 0.05) var melee_frontline_width_mul: float = 1.3
@export_range(0.4, 2.5, 0.05) var melee_frontline_depth_mul: float = 0.85
@export_range(0.7, 2.5, 0.05) var melee_contact_distance_mul: float = 1.18
@export_range(0.0, 8.0, 0.1) var melee_contact_distance_bias: float = 0.8
@export_range(0.5, 3.0, 0.05) var melee_activity_radius_mul: float = 1.25
@export_range(0.0, 1.0, 0.05) var melee_activity_radius_visual_weight: float = 0.8
@export_file("*.glb", "*.gltf", "*.scn", "*.tscn") var spear_override_model_path: String = "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/qingqiangbing.glb"
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp", "*.exr") var spear_override_albedo_path: String = "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/qingqiangbing_texture_pbr_20250901.png"
@export_file("*.glb", "*.gltf", "*.scn", "*.tscn") var archer_override_model_path: String = "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/gongbing.glb"
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp", "*.exr") var archer_override_albedo_path: String = "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/gongbing_texture_pbr_20250901.png"
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp", "*.exr") var infantry_override_albedo_path: String = ""
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp", "*.exr") var cavalry_override_albedo_path: String = ""
@export var soft_repulsion_step: float = 0.3
@export var soft_repulsion_interval: float = 0.12
@export var soft_repulsion_include_same_team: bool = true
@export var soft_repulsion_apply_enemy_pairs: bool = false
@export var soft_repulsion_same_team_strength: float = 2.6
@export var soft_repulsion_enemy_strength: float = 4.6
@export var soft_repulsion_base_padding: float = 0.55
@export var soft_repulsion_radius_mul: float = 0.9
@export var soft_repulsion_enemy_front_gap: float = 0.8
@export var soft_repulsion_melee_extra_gap: float = 0.45
@export var soft_repulsion_dead_zone: float = 0.22
@export var soft_repulsion_min_penetration: float = 0.05
@export var soft_repulsion_max_push_per_tick: float = 0.65
@export var soft_repulsion_melee_strength_mul: float = 0.78
@export var soft_repulsion_separating_speed_threshold: float = 0.35
@export var unit_collision_blocking_enabled: bool = true
@export var unit_collision_solve_passes: int = 4
@export var unit_collision_contact_epsilon: float = 0.03
@export var unit_collision_step_sample: float = 0.7
@export var unit_collision_detour_dirs: int = 14
@export var unit_collision_detour_rings: int = 8
@export var unit_collision_detour_radius_mul: float = 1.0
@export var unit_collision_detour_max_per_step: float = 1.0
@export var same_team_angle_offset_enabled: bool = false
@export var same_team_angle_offset_trigger_center_dist: float = 4.0
@export var same_team_angle_offset_deg: float = 15.0
@export var non_attack_sidepass_enabled: bool = true
@export var non_attack_sidepass_angle_deg: float = 26.0
@export var non_attack_sidepass_angle_alt_deg: float = 42.0
@export var non_attack_sidepass_clearance: float = 0.4
@export var unit_logic_radius_padding: float = 0.15
@export var unit_detour_forward_push: float = 4.2
@export var auto_engage_enabled: bool = true
@export var enemy_auto_engage_enabled: bool = false
@export var auto_engage_interval: float = 0.55
@export var auto_engage_max_distance: float = 52.0
@export var auto_release_enabled: bool = true
@export var auto_release_eval_interval: float = 0.42
@export_range(0.0, 0.8, 0.01) var auto_release_skill_will_reserve_ratio: float = 0.12
@export_range(0.0, 1.0, 0.01) var auto_release_shield_damage_ratio_light: float = 0.09
@export_range(0.0, 1.0, 0.01) var auto_release_shield_damage_ratio_heavy: float = 0.2
@export_range(0.0, 1.0, 0.01) var auto_release_shield_hp_ratio_light: float = 0.86
@export_range(0.0, 1.0, 0.01) var auto_release_shield_hp_ratio_heavy: float = 0.62
@export var auto_release_shield_close_enemy_count_light: int = 2
@export var auto_release_shield_close_enemy_count_heavy: int = 3
@export var auto_release_famous_cooldown_sec: float = 18.0
@export var famous_auto_default_enabled: bool = false
@export_range(0.1, 6.0, 0.1) var auto_release_famous_retry_sec: float = 1.2
@export_range(0.0, 1.0, 0.01) var auto_release_famous_min_will_ratio: float = 0.62
@export var lod_enabled: bool = true
@export var lod_update_interval: float = 0.2
@export var lod_soldier_visible_depth: float = 320.0
@export var lod_soldier_hysteresis_depth: float = 24.0
@export var lod_force_show_soldiers_in_melee: bool = true
@export var lod_force_show_soldiers_when_engaged: bool = true
@export var lod_engaged_hold_sec: float = 0.9
@export var lod_tag_visible_max_depth: float = 1200.0
@export var lod_show_tag_when_near: bool = true
@export var unit_tag_near_distance: float = 12.0
@export var unit_tag_far_distance: float = 380.0
@export var unit_tag_near_scale: float = 0.84
@export var unit_tag_far_scale: float = 0.34
@export var unit_tag_height_offset: float = 4.1
@export var unit_tag_near_ops_depth: float = 220.0
@export var unit_tag_lod0_size: Vector2 = Vector2(136.0, 64.0)
@export var unit_tag_lod1_size: Vector2 = Vector2(106.0, 52.0)
@export var unit_tag_lod2_size: Vector2 = Vector2(90.0, 34.0)
@export var unit_tag_lod0_world_lift: float = 0.9
@export var unit_tag_lod1_world_lift: float = 1.3
@export var unit_tag_lod2_world_lift: float = 1.7
@export var unit_tag_lod0_screen_gap: float = 10.0
@export var unit_tag_lod1_screen_gap: float = 8.0
@export var unit_tag_lod2_screen_gap: float = 6.0
@export var unit_tag_text_refresh_interval: float = 0.2
@export var unit_tag_position_refresh_interval: float = 0.05
@export var lod_preserve_player_ops_depth: float = 260.0
@export var unit_tag_far_perf_enabled: bool = true
@export var unit_tag_far_depth: float = 900.0
@export var unit_tag_very_far_depth: float = 1800.0
@export var unit_tag_far_position_stride: int = 2
@export var unit_tag_very_far_position_stride: int = 4
@export var unit_tag_far_text_stride: int = 2
@export var unit_tag_very_far_text_stride: int = 4
@export_range(1.0, 20.0, 0.1) var unit_tag_world_scale_mul: float = 9.4
@export_range(0.5, 12.0, 0.1) var unit_tag_world_scale_min: float = 4.8
@export_range(0.5, 12.0, 0.1) var unit_tag_world_scale_max: float = 7.2
@export_range(1.0, 4.0, 0.1) var unit_tag_board_scale_mul: float = 2.6
@export_range(0.2, 1.0, 0.05) var unit_tag_board_opacity: float = 0.92
@export var unit_tag_click_radius_px: float = 110.0
@export var commander_report_enabled: bool = true
@export_range(1.0, 20.0, 0.1) var commander_report_duration: float = 4.4
@export_range(1, 8, 1) var commander_report_keep_lines: int = 6
@export var commander_report_supply_events_enabled: bool = true
@export var commander_report_facility_events_enabled: bool = true
@export_range(0.5, 30.0, 0.1) var commander_report_supply_cooldown_sec: float = 8.0
@export var hover_panel_enabled: bool = true
@export var hover_panel_update_interval: float = 0.12
@export var hover_panel_content_refresh_interval: float = 0.24
@export var hover_panel_show_delay_sec: float = 1.2
@export var hover_panel_pick_radius_px: float = 68.0
@export var hover_panel_world_pick_radius: float = 4.8
@export var hover_panel_screen_offset: Vector2 = Vector2(20.0, 20.0)
@export var tactic_vfx_enabled: bool = true
@export_range(0.4, 2.5, 0.05) var tactic_vfx_intensity_mul: float = 1.0
@export_range(0.4, 2.0, 0.05) var tactic_vfx_radius_mul: float = 1.0
@export var demo_naval_enabled: bool = true
@export var demo_naval_auto_embark: bool = true
@export_range(1.0, 80.0, 0.5) var demo_naval_ferry_radius: float = 9.0
@export_range(0.5, 32.0, 0.5) var demo_naval_shoal_radius: float = 5.0
@export var demo_naval_default_ship_type: String = "zouge"
@export var demo_naval_default_ship_type_by_role: Dictionary = {
	"siege": "lou_chuan",
	"naval": "lou_chuan"
}
@export var debug_allow_control_all_units_for_testing: bool = true

var units: Array = []
var selected_unit = null
var selected_units: Array = []
var inspected_unit = null
var unit_tag_layer: CanvasLayer
var unit_tag_root: Control
var unit_tag_buttons: Dictionary = {}
var unit_tag_units: Dictionary = {}
var unit_tag_widgets: Dictionary = {}
var rts_panel_root: Control
var rts_panel_widgets: Dictionary = {}
var rts_hover_panel_root: Control
var rts_hover_panel_widgets: Dictionary = {}
var _build_menu_panel: PanelContainer
var _build_menu_buttons: Dictionary = {}
var _build_menu_visible: bool = false
var _pending_build_action_id: String = ""
var _pending_build_action_label: String = ""
var _build_preview_node: Node3D = null
var _build_line_start_world: Vector3 = Vector3.INF
var _build_line_start_marker: Node3D = null
var pending_ground_command: String = ""
var battle_camera_ref: BattleCameraController = null
var unit_tag_text_refresh_timer: float = 0.0
var unit_tag_position_refresh_timer: float = 0.0
var unit_tag_text_refresh_cycle: int = 0
var unit_tag_position_refresh_cycle: int = 0
var unit_tag_force_refresh: bool = true
var soft_repulsion_dirty: bool = true
var soft_repulsion_timer: float = 0.0
var auto_engage_timer: float = 0.0
var auto_release_timer: float = 0.0
var lod_timer: float = 0.0
var lod_soldier_visible_cache: Dictionary = {}
var lod_soldier_force_until: Dictionary = {}
var unit_skill_auto_mode: Dictionary = {}
var unit_famous_auto_mode: Dictionary = {}
var famous_auto_cooldowns: Dictionary = {}
var famous_skill_cooldowns: Dictionary = {}
var unique_skill_catalog: Dictionary = {}
var unique_skill_by_officer_id: Dictionary = {}
var unique_skill_by_owner_key: Dictionary = {}
var weather_settings: Dictionary = {}
var weather_state: String = "sunny"
var weather_day_phase: String = "day"
var weather_wind_dir: Vector2 = Vector2.RIGHT
var weather_wind_strength: float = 0.0
var burn_wind_timer: float = 0.0
var tactic_cooldowns: Dictionary = {}
var _weather_context_pending: Dictionary = {}
var _strategy_map_view: Node = null
var _demo_facility_root: Node3D = null
var _demo_facilities: Array[Dictionary] = []
var _demo_tower_cooldowns: Dictionary = {}
var _siege_variant_proc_cooldowns: Dictionary = {}
var _demo_siege_variant_skill_cooldowns: Dictionary = {}
var _demo_facility_effect_tick_accum: float = 0.0
var _demo_siege_ai_tick_accum: float = 0.0
var _demo_siege_debug_tick_accum: float = 0.0
var _demo_siege_objective_panel_tick_accum: float = 0.0
var _demo_siege_variant_facility_damage: Dictionary = {}
var _demo_siege_variant_proc_counts: Dictionary = {}
var _demo_siege_objective_winner_team: int = -1
var _demo_siege_objective_message: String = ""
var _recon_spotted_until_by_team: Dictionary = {}
var _recon_discovered_enemy_ids_by_team: Dictionary = {}
var _recon_tick_accum: float = 0.0
var _demo_naval_ferry_points: Array[Vector3] = []
var _demo_naval_ferry_cache_ready: bool = false
var _units_motion_enabled: bool = true
var _tag_font: FontFile = null
var _tag_portrait: Texture2D = null
var _tag_portrait_head: Texture2D = null
var _tag_portrait_catalog: Array[Dictionary] = []
var _tag_portrait_texture_cache: Dictionary = {}
var _tag_portrait_head_cache: Dictionary = {}
var _tag_portrait_head_by_commander: Dictionary = {}
var _unit_tag_flag_shader: Shader = null
var _unit_tag_dialogue_shader: Shader = null
var battle_tip_message: String = ""
var battle_tip_timer: float = 0.0
var commander_report_panel: PanelContainer
var commander_report_list: VBoxContainer
var commander_report_entries: Array[Dictionary] = []
var commander_report_supply_cooldowns: Dictionary = {}
var siege_debug_panel: PanelContainer
var siege_debug_text: Label
var siege_objective_panel: PanelContainer
var siege_objective_text: Label
var commander_report_team_stats: Dictionary = {}
var commander_dialogue_hud_panel: PanelContainer
var commander_dialogue_hud_portrait_rect: TextureRect
var commander_dialogue_hud_name_label: Label
var commander_dialogue_hud_line_label: Label
var commander_dialogue_hud_last_text: String = ""
var commander_dialogue_hud_time_left: float = 0.0
var commander_dialogue_hud_queue: Array[Dictionary] = []
var command_marker_move: MeshInstance3D = null
var command_marker_attack: MeshInstance3D = null
var command_marker_move_timer: float = 0.0
var command_marker_attack_timer: float = 0.0
var terrain_adaptation_timer: float = 0.0
var selection_overlay_layer: CanvasLayer
var selection_overlay_root: Control
var selection_rect_node: ColorRect
var is_left_drag_selecting: bool = false
var drag_start_screen: Vector2 = Vector2.ZERO
var drag_current_screen: Vector2 = Vector2.ZERO
var _hovered_unit = null
var _hover_panel_timer: float = 0.0
var _hover_content_refresh_timer: float = 0.0
var _hover_candidate_unit = null
var _hover_candidate_elapsed: float = 0.0
var tactic_vfx_root: Node3D = null
var tactic_temp_vfx_nodes: Array[Dictionary] = []
var tactic_field_vfx_items: Array[Dictionary] = []
var tactic_link_vfx_items: Array[Dictionary] = []
var tactic_sprite_vfx_items: Array[Dictionary] = []

func setup_weather_context(context: Dictionary) -> void:
	_weather_context_pending = context.duplicate(true)

func set_strategy_map_view(map_view: Node) -> void:
	_strategy_map_view = map_view
	_demo_naval_ferry_cache_ready = false
	_demo_naval_ferry_points.clear()
	_sync_strategy_map_supply_route_focus()

func set_units_motion_enabled(enabled: bool) -> void:
	_units_motion_enabled = enabled
	_apply_units_motion_state()

func _auto_bind_embedded_map_view() -> void:
	if _strategy_map_view != null and is_instance_valid(_strategy_map_view):
		return
	for child in get_children():
		if child == null or not is_instance_valid(child):
			continue
		if child.has_method("terrain_height_at_world") and child.has_method("can_unit_walk_at_world"):
			_strategy_map_view = child
			_demo_naval_ferry_cache_ready = false
			_demo_naval_ferry_points.clear()
			embedded_on_strategy_map = true
			return

func _ready() -> void:
	randomize()
	_clear_recon_runtime_state()
	_auto_bind_embedded_map_view()
	_load_tag_assets()
	_load_weather_settings()
	_load_battle_rules()
	_load_unique_skills()
	_ensure_role_balance_defaults()
	_ensure_height_advantage_defaults()
	_apply_weather_context()
	if not embedded_on_strategy_map:
		_setup_environment()
	_setup_unit_tags()
	_setup_command_markers()
	_setup_rts_panel()
	_setup_rts_hover_panel()
	_setup_selection_overlay()
	if auto_spawn_demo_units:
		_spawn_demo_units()

func _load_tag_assets() -> void:
	_tag_font = null
	if not FileAccess.file_exists(TAG_FONT_PATH):
		pass
	else:
		var res: Resource = load(TAG_FONT_PATH)
		if res is FontFile:
			_tag_font = res as FontFile
	_tag_portrait = null
	_tag_portrait_head = null
	_tag_portrait_catalog.clear()
	_tag_portrait_texture_cache.clear()
	_tag_portrait_head_cache.clear()
	_tag_portrait_head_by_commander.clear()
	var portrait_candidates: Array[String] = _collect_tag_portrait_candidates()
	for portrait_path in portrait_candidates:
		_tag_portrait_catalog.append({
			"path": portrait_path,
			"name": portrait_path.get_file().get_basename().to_lower(),
			"score": _score_tag_portrait_filename(portrait_path.get_file().get_basename().to_lower())
		})
	for portrait_path in portrait_candidates:
		var tex_res: Resource = load(portrait_path)
		if tex_res is Texture2D:
			_tag_portrait = tex_res as Texture2D
			break
	if _tag_portrait == null:
		_tag_portrait = _create_tag_portrait_placeholder()
	_tag_portrait_head = _build_tag_portrait_head_texture(_tag_portrait)
	_unit_tag_flag_shader = UNIT_TAG_FLAG_SHADER
	_unit_tag_dialogue_shader = UNIT_TAG_DIALOGUE_PAPER_SHADER

func _score_tag_portrait_filename(lower_name: String) -> int:
	var score: int = 0
	if lower_name.find("bg") != -1:
		score -= 220
	if lower_name.find("frame") != -1 or lower_name.find("border") != -1 or lower_name.find("ui") != -1:
		score -= 120
	if lower_name.find("地图") != -1 or lower_name.find("面板") != -1 or lower_name.find("边框") != -1:
		score -= 160
	if lower_name.find("人物") != -1 or lower_name.find("武将") != -1 or lower_name.find("立绘") != -1 or lower_name.find("三国") != -1:
		score += 100
	if lower_name.find("半身") != -1:
		score += 50
	if lower_name.find("jimeng") != -1:
		score += 36
	if lower_name.find("dreamina") != -1:
		score += 18
	if lower_name.find("兵") != -1:
		score -= 34
	return score

func _collect_tag_portrait_candidates() -> Array[String]:
	var out: Array[String] = []
	if FileAccess.file_exists(TAG_PORTRAIT_PATH):
		out.append(TAG_PORTRAIT_PATH)
	var dir: DirAccess = DirAccess.open(TAG_PORTRAIT_DIR_PATH)
	if dir == null:
		return out
	var ranked: Array[Dictionary] = []
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir():
			var lower_name: String = file_name.to_lower()
			var is_image: bool = lower_name.ends_with(".png") or lower_name.ends_with(".jpg") or lower_name.ends_with(".jpeg") or lower_name.ends_with(".webp")
			if is_image:
				var candidate_path: String = "%s/%s" % [TAG_PORTRAIT_DIR_PATH, file_name]
				var score: int = _score_tag_portrait_filename(lower_name)
				ranked.append({
					"path": candidate_path,
					"score": score
				})
		file_name = dir.get_next()
	dir.list_dir_end()
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	for item_any in ranked:
		var item: Dictionary = item_any as Dictionary
		var p: String = String(item.get("path", "")).strip_edges()
		if p.is_empty() or out.has(p):
			continue
		out.append(p)
	return out

func _normalize_commander_portrait_key(text: String) -> String:
	var key: String = text.strip_edges().to_lower()
	var replacements: Array[String] = [
		"我军", "敌军", "前线", "【", "】", "“", "”", "\"", "'", "·", " ", "\t", "\r", "\n", "-", "_",
		",", ".", "，", "。", "：", ":", "（", "）", "(", ")", "[", "]", "{", "}", "strategist", "deputy", "main"
	]
	for token in replacements:
		key = key.replace(token, "")
	return key

func _commander_portrait_aliases(commander_name: String) -> Array[String]:
	var key: String = _normalize_commander_portrait_key(commander_name)
	var out: Array[String] = []
	if not key.is_empty():
		out.append(key)
	var alias_map: Dictionary = {
		"关羽": ["guanyu", "云长", "羽", "关"],
		"guanyu": ["关羽", "云长", "羽", "关"],
		"刘备": ["liubei", "玄德", "备", "刘"],
		"liubei": ["刘备", "玄德", "备", "刘"],
		"张飞": ["zhangfei", "翼德", "飞", "张"],
		"zhangfei": ["张飞", "翼德", "飞", "张"],
		"赵云": ["zhaoyun", "子龙", "云", "赵"],
		"zhaoyun": ["赵云", "子龙", "云", "赵"],
		"诸葛亮": ["zhugeliang", "孔明", "亮", "诸葛"],
		"zhugeliang": ["诸葛亮", "孔明", "亮", "诸葛"],
		"司马懿": ["simayi", "仲达", "懿", "司马"],
		"simayi": ["司马懿", "仲达", "懿", "司马"],
		"曹操": ["caocao", "孟德", "操", "曹"],
		"caocao": ["曹操", "孟德", "操", "曹"],
		"吕布": ["lvbu", "奉先", "布", "吕"],
		"lvbu": ["吕布", "奉先", "布", "吕"],
		"马超": ["machao", "孟起", "超", "马"],
		"machao": ["马超", "孟起", "超", "马"],
		"甘宁": ["ganning", "兴霸", "宁", "甘"],
		"ganning": ["甘宁", "兴霸", "宁", "甘"],
		"黄忠": ["huangzhong", "汉升", "忠", "黄"],
		"huangzhong": ["黄忠", "汉升", "忠", "黄"],
		"曹仁": ["caoren", "子孝", "仁"],
		"caoren": ["曹仁", "子孝", "仁"],
		"夏侯惇": ["xiahoudu", "元让", "惇"],
		"xiahoudu": ["夏侯惇", "元让", "惇"]
	}
	if alias_map.has(key):
		for alias_any in (alias_map.get(key, []) as Array):
			var alias: String = _normalize_commander_portrait_key(String(alias_any))
			if not alias.is_empty() and not out.has(alias):
				out.append(alias)
	return out

func _resolve_commander_portrait_path(commander_name: String) -> String:
	if _tag_portrait_catalog.is_empty():
		return ""
	var aliases: Array[String] = _commander_portrait_aliases(commander_name)
	for canon_any in COMMANDER_PORTRAIT_FILE_OVERRIDES.keys():
		var canon_name: String = String(canon_any)
		var canon_key: String = _normalize_commander_portrait_key(canon_name)
		if not aliases.has(canon_key):
			continue
		var files_any: Variant = COMMANDER_PORTRAIT_FILE_OVERRIDES.get(canon_any, [])
		if not (files_any is Array):
			continue
		for fn_any in (files_any as Array):
			var fn: String = String(fn_any).strip_edges()
			if fn.is_empty():
				continue
			var direct_path: String = "%s/%s" % [TAG_PORTRAIT_DIR_PATH, fn]
			if FileAccess.file_exists(direct_path):
				return direct_path
	var best_path: String = ""
	var best_score: int = -2147483647
	for item_any in _tag_portrait_catalog:
		if not (item_any is Dictionary):
			continue
		var item: Dictionary = item_any as Dictionary
		var path: String = String(item.get("path", "")).strip_edges()
		if path.is_empty():
			continue
		var file_name_key: String = _normalize_commander_portrait_key(String(item.get("name", "")))
		var score: int = int(item.get("score", 0))
		for alias_any in aliases:
			var alias: String = String(alias_any).strip_edges()
			if alias.is_empty():
				continue
			if file_name_key.find(alias) != -1:
				score += 600 + alias.length()
			elif alias.find(file_name_key) != -1:
				score += 160
		if score > best_score:
			best_score = score
			best_path = path
	return best_path

func _load_tag_portrait_by_path(path: String) -> Texture2D:
	var p: String = path.strip_edges()
	if p.is_empty():
		return null
	if _tag_portrait_texture_cache.has(p):
		var cached_any: Variant = _tag_portrait_texture_cache.get(p)
		return cached_any as Texture2D if cached_any is Texture2D else null
	var tex_res: Resource = load(p)
	if tex_res is Texture2D:
		var tex: Texture2D = tex_res as Texture2D
		_tag_portrait_texture_cache[p] = tex
		return tex
	return null

func _get_tag_head_portrait_for_commander(commander_name: String) -> Texture2D:
	var key: String = _normalize_commander_portrait_key(commander_name)
	if key.is_empty():
		return _tag_portrait_head if _tag_portrait_head != null else _tag_portrait
	if _tag_portrait_head_by_commander.has(key):
		var cached_any: Variant = _tag_portrait_head_by_commander.get(key)
		if cached_any is Texture2D:
			return cached_any as Texture2D
	var path: String = _resolve_commander_portrait_path(commander_name)
	var tex: Texture2D = _load_tag_portrait_by_path(path)
	if tex == null:
		var fallback: Texture2D = _tag_portrait_head if _tag_portrait_head != null else _tag_portrait
		_tag_portrait_head_by_commander[key] = fallback
		return fallback
	var path_key: String = path.strip_edges()
	var head: Texture2D = null
	if _tag_portrait_head_cache.has(path_key):
		var head_any: Variant = _tag_portrait_head_cache.get(path_key)
		if head_any is Texture2D:
			head = head_any as Texture2D
	if head == null:
		head = _build_tag_portrait_head_texture(tex)
		_tag_portrait_head_cache[path_key] = head
	_tag_portrait_head_by_commander[key] = head
	return head

func _create_tag_portrait_placeholder() -> Texture2D:
	var img := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.17, 0.11, 0.08, 0.96))
	img.fill_rect(Rect2i(2, 2, 92, 92), Color(0.24, 0.15, 0.10, 0.98))
	img.fill_rect(Rect2i(6, 6, 84, 84), Color(0.36, 0.22, 0.14, 1.0))
	return ImageTexture.create_from_image(img)

func _build_tag_portrait_head_texture(base_tex: Texture2D) -> Texture2D:
	if base_tex == null:
		return null
	var w: float = float(base_tex.get_width())
	var h: float = float(base_tex.get_height())
	if w < 2.0 or h < 2.0:
		return base_tex
	var crop_size: float = maxf(2.0, minf(w * 0.58, h * 0.58))
	var crop_x: float = (w - crop_size) * 0.5
	var crop_y: float = h * 0.06
	var img: Image = base_tex.get_image()
	if img != null and not img.is_empty():
		var iw: int = img.get_width()
		var ih: int = img.get_height()
		if iw > 1 and ih > 1:
			var min_x: int = iw
			var min_y: int = ih
			var max_x: int = -1
			var max_y: int = -1
			var step: int = max(1, int(min(iw, ih) / 96))
			for y in range(0, ih, step):
				for x in range(0, iw, step):
					var a: float = img.get_pixel(x, y).a
					if a <= 0.08:
						continue
					if x < min_x:
						min_x = x
					if y < min_y:
						min_y = y
					if x > max_x:
						max_x = x
					if y > max_y:
						max_y = y
			if max_x >= min_x and max_y >= min_y:
				var body_w: float = float(max_x - min_x + 1)
				var body_h: float = float(max_y - min_y + 1)
				var head_size: float = clampf(minf(body_w * 1.05, body_h * 0.55), 16.0, minf(w, h))
				var center_x: float = float(min_x) + body_w * 0.5
				crop_size = maxf(2.0, minf(head_size, minf(w, h)))
				crop_x = clampf(center_x - crop_size * 0.5, 0.0, w - crop_size)
				crop_y = clampf(float(min_y), 0.0, h - crop_size)
	if crop_y + crop_size > h:
		crop_y = maxf(0.0, h - crop_size)
	var atlas := AtlasTexture.new()
	atlas.atlas = base_tex
	atlas.region = Rect2(crop_x, crop_y, crop_size, crop_size)
	return atlas

func _physics_process(delta: float) -> void:
	if not _units_motion_enabled:
		return
	_cleanup_dead_units()
	_tick_recon_spotting(delta)
	_tick_tactic_cooldowns(delta)
	_tick_siege_variant_proc_cooldowns(delta)
	_tick_auto_release(delta)
	# Hard collision only: soft repulsion is intentionally disabled.

	if auto_engage_enabled:
		auto_engage_timer -= delta
		if auto_engage_timer <= 0.0:
			auto_engage_timer = maxf(0.2, auto_engage_interval)
			_update_auto_engage_orders()

	if lod_enabled:
		lod_timer -= delta
		if lod_timer <= 0.0:
			lod_timer = maxf(0.06, lod_update_interval)
			_update_unit_lod_visibility()
	_tick_unit_terrain_adaptation(delta)
	_update_wind_fire_spread(delta)
	if not embedded_on_strategy_map and demo_facility_test_setup_enabled:
		_tick_demo_facility_effects(delta)

func mark_soft_repulsion_dirty() -> void:
	pass

func _process(delta: float) -> void:
	if battle_tip_timer > 0.0:
		battle_tip_timer = maxf(0.0, battle_tip_timer - delta)
		if battle_tip_timer <= 0.0:
			battle_tip_message = ""
	_update_command_markers(delta)
	_update_tactic_vfx(delta)
	_tick_demo_siege_debug_overlay(delta)
	_tick_demo_siege_objective_panel(delta)
	var refresh_tag_text: bool = false
	var refresh_tag_positions: bool = false
	var force_near_tag_positions: bool = unit_tag_near_ops_depth > 0.0
	if unit_tag_force_refresh:
		unit_tag_force_refresh = false
		refresh_tag_text = true
		refresh_tag_positions = true
		unit_tag_text_refresh_timer = maxf(0.05, unit_tag_text_refresh_interval)
		unit_tag_position_refresh_timer = maxf(0.02, unit_tag_position_refresh_interval)
	else:
		unit_tag_text_refresh_timer -= maxf(0.0, delta)
		if unit_tag_text_refresh_timer <= 0.0:
			refresh_tag_text = true
			unit_tag_text_refresh_timer = maxf(0.05, unit_tag_text_refresh_interval)
		if unit_tag_position_refresh_interval <= 0.0:
			refresh_tag_positions = true
		else:
			unit_tag_position_refresh_timer -= maxf(0.0, delta)
			if unit_tag_position_refresh_timer <= 0.0:
				refresh_tag_positions = true
				unit_tag_position_refresh_timer = maxf(0.02, unit_tag_position_refresh_interval)
	if refresh_tag_text or refresh_tag_positions:
		if refresh_tag_text:
			unit_tag_text_refresh_cycle += 1
		if refresh_tag_positions:
			unit_tag_position_refresh_cycle += 1
		_update_unit_tags(refresh_tag_text, force_near_tag_positions, true)
	elif force_near_tag_positions:
		_update_unit_tags(false, true, false)
	_update_rts_hover_panel(delta)
	_update_rts_panel()
	_tick_commander_reports(delta)
	_tick_commander_dialogue_hud(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		var key_event: InputEventKey = event as InputEventKey
		if key_event.keycode == KEY_ESCAPE and _is_build_placement_active():
			_cancel_build_placement("Build placement canceled.")
			get_viewport().set_input_as_handled()
			return
	if _is_build_placement_active():
		if event is InputEventMouseMotion:
			var mm: InputEventMouseMotion = event as InputEventMouseMotion
			_update_build_preview_at_screen(mm.position)
			get_viewport().set_input_as_handled()
			return
		if event is InputEventMouseButton and not event.is_echo():
			var build_mb: InputEventMouseButton = event as InputEventMouseButton
			if build_mb.button_index == MOUSE_BUTTON_LEFT and build_mb.pressed:
				if _pending_build_action_id == "build_zhalan":
					_confirm_build_fence_line_click(build_mb.position)
				else:
					_confirm_build_placement(build_mb.position)
				get_viewport().set_input_as_handled()
				return
			if build_mb.button_index == MOUSE_BUTTON_RIGHT and build_mb.pressed:
				_cancel_build_placement("Build placement canceled.")
				get_viewport().set_input_as_handled()
				return
	if event is InputEventMouseButton and not event.is_echo():
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_begin_selection_drag(mb.position)
			else:
				_end_selection_drag(mb.position, mb.shift_pressed)
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_on_right_click(mb.position, pending_ground_command == "attack_move")

	if event is InputEventMouseMotion and is_left_drag_selecting:
		var mm: InputEventMouseMotion = event
		_update_selection_drag(mm.position)

	if event is InputEventKey and event.pressed and not event.is_echo():
		var key: InputEventKey = event
		var cmd_unit = _get_selected_command_unit()
		if cmd_unit == null:
			return
		match key.keycode:
			KEY_A:
				pending_ground_command = "attack_move"
				_set_battle_status("Attack-move ready. Right-click ground or enemy.")
				_update_rts_panel_buttons()
				return
			KEY_S:
				pending_ground_command = ""
				_issue_selected_stop()
				_update_rts_panel_buttons()
				return
			KEY_D:
				pending_ground_command = ""
				_issue_selected_hold_position()
				_update_rts_panel_buttons()
				return
			KEY_V:
				pending_ground_command = ""
				_issue_selected_retreat()
				_update_rts_panel_buttons()
				return
			KEY_R:
				pending_ground_command = ""
				_try_cast_famous_skill(cmd_unit)
				_update_rts_panel_buttons()
				return
			KEY_1:
				pending_ground_command = ""
				_try_cast_slot_action(cmd_unit, 0)
				_update_rts_panel_buttons()
				return
			KEY_2:
				pending_ground_command = ""
				_try_cast_slot_action(cmd_unit, 1)
				_update_rts_panel_buttons()
				return
			KEY_3:
				pending_ground_command = ""
				_try_cast_slot_action(cmd_unit, 2)
				_update_rts_panel_buttons()
				return
			KEY_B:
				pending_ground_command = ""
				if _is_build_placement_active():
					_cancel_build_placement("Build placement canceled.")
				else:
					_toggle_build_menu()
				_update_rts_panel_buttons()
				return

func register_unit(unit) -> void:
	if unit == null:
		return
	if units.has(unit):
		return
	units.append(unit)
	_relocate_unit_to_walkable_spawn(unit)
	if show_unit_tags:
		_make_unit_tag(unit)
	else:
		var anchor: Node3D = unit.get_node_or_null("TagAnchor") as Node3D
		if anchor != null and is_instance_valid(anchor):
			anchor.visible = false
	unit.process_mode = Node.PROCESS_MODE_INHERIT if _units_motion_enabled else Node.PROCESS_MODE_DISABLED
	unit_tag_force_refresh = true

func unregister_unit(unit) -> void:
	units.erase(unit)
	_remove_unit_tag(unit)
	unit_tag_force_refresh = true
	if unit != null and is_instance_valid(unit):
		var uid: int = unit.get_instance_id()
		_remove_unit_from_recon_cache(uid)
		lod_soldier_visible_cache.erase(uid)
		lod_soldier_force_until.erase(uid)
		_clear_siege_variant_proc_cooldowns_for_unit(uid)
		_clear_demo_siege_variant_skill_cooldowns_for_unit(uid)
		_clear_unit_auto_mode(uid)
	selected_units.erase(unit)
	if selected_unit == unit:
		selected_unit = selected_units[0] if not selected_units.is_empty() else null

func _clear_unit_auto_mode(unit_id: int) -> void:
	unit_skill_auto_mode.erase(unit_id)
	unit_famous_auto_mode.erase(unit_id)
	famous_auto_cooldowns.erase(unit_id)
	famous_skill_cooldowns.erase(unit_id)

func _is_skill_auto_enabled(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	return bool(unit_skill_auto_mode.get(unit.get_instance_id(), false))

func _is_famous_auto_enabled(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	return bool(unit_famous_auto_mode.get(unit.get_instance_id(), famous_auto_default_enabled))

func get_enemy_units(team_id: int) -> Array:
	var result: Array = []
	for unit in units:
		if unit == null or not is_instance_valid(unit):
			continue
		if unit.dead:
			continue
		if unit.team_id != team_id:
			result.append(unit)
	return result

func get_enemies_in_radius(center: Vector3, radius: float, team_id: int) -> Array:
	var result: Array = []
	var radius_sq: float = radius * radius
	for unit in units:
		if unit == null or not is_instance_valid(unit):
			continue
		if unit.dead or unit.team_id == team_id:
			continue
		var d: Vector3 = unit.global_position - center
		d.y = 0.0
		if d.length_squared() <= radius_sq:
			result.append(unit)
	return result

func _units_ignore_each_other(a, b) -> bool:
	if a == null or b == null:
		return false
	if a.has_method("can_ignore_collision_with") and bool(a.call("can_ignore_collision_with", b)):
		return true
	if b.has_method("can_ignore_collision_with") and bool(b.call("can_ignore_collision_with", a)):
		return true
	return false

func _get_unit_obb_at(unit, world_pos: Vector3, forward_hint: Vector3 = Vector3.ZERO) -> Dictionary:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return {}
	if not unit.has_method("get_collision_obb_at"):
		return {}
	var obb: Dictionary = unit.call("get_collision_obb_at", world_pos, forward_hint)
	return obb

func _obb_overlap_mtv_2d(a: Dictionary, b: Dictionary) -> Dictionary:
	if a.is_empty() or b.is_empty():
		return {"overlap": false}
	var ac: Vector2 = a.get("center", Vector2.ZERO)
	var bc: Vector2 = b.get("center", Vector2.ZERO)
	var a_right: Vector2 = (a.get("right", Vector2.RIGHT) as Vector2).normalized()
	var a_forward: Vector2 = (a.get("forward", Vector2.UP) as Vector2).normalized()
	var b_right: Vector2 = (b.get("right", Vector2.RIGHT) as Vector2).normalized()
	var b_forward: Vector2 = (b.get("forward", Vector2.UP) as Vector2).normalized()
	var a_hx: float = maxf(0.01, float(a.get("half_x", 0.5)))
	var a_hz: float = maxf(0.01, float(a.get("half_z", 0.5)))
	var b_hx: float = maxf(0.01, float(b.get("half_x", 0.5)))
	var b_hz: float = maxf(0.01, float(b.get("half_z", 0.5)))
	var axes: Array[Vector2] = [a_right, a_forward, b_right, b_forward]
	var center_delta: Vector2 = bc - ac
	var min_overlap: float = INF
	var best_axis: Vector2 = Vector2.ZERO
	for axis_any in axes:
		var axis: Vector2 = axis_any
		if axis.length_squared() <= 0.000001:
			continue
		axis = axis.normalized()
		var ra: float = absf(a_right.dot(axis)) * a_hx + absf(a_forward.dot(axis)) * a_hz
		var rb: float = absf(b_right.dot(axis)) * b_hx + absf(b_forward.dot(axis)) * b_hz
		var dist: float = absf(center_delta.dot(axis))
		var overlap: float = (ra + rb) - dist
		if overlap <= 0.0:
			return {"overlap": false}
		if overlap < min_overlap:
			min_overlap = overlap
			var sign: float = -1.0 if center_delta.dot(axis) >= 0.0 else 1.0
			best_axis = axis * sign
	if min_overlap == INF or best_axis.length_squared() <= 0.000001:
		return {"overlap": false}
	return {
		"overlap": true,
		"mtv": best_axis * (min_overlap + maxf(0.0, unit_collision_contact_epsilon)),
		"depth": min_overlap
	}

func are_units_rect_overlapping(a, b) -> bool:
	if a == null or b == null or not is_instance_valid(a) or not is_instance_valid(b):
		return false
	if a.dead or b.dead:
		return false
	if _units_ignore_each_other(a, b):
		return false
	var a_obb: Dictionary = _get_unit_obb_at(a, a.global_position, Vector3.ZERO)
	var b_obb: Dictionary = _get_unit_obb_at(b, b.global_position, Vector3.ZERO)
	var sat: Dictionary = _obb_overlap_mtv_2d(a_obb, b_obb)
	return bool(sat.get("overlap", false))

func is_unit_path_sample_blocked(unit, world_pos: Vector3, forward_hint: Vector3 = Vector3.ZERO) -> bool:
	return _find_blocking_unit_for_sample(unit, world_pos, forward_hint) != null

func _find_blocking_unit_for_sample(unit, world_pos: Vector3, forward_hint: Vector3 = Vector3.ZERO):
	if not unit_collision_blocking_enabled:
		return null
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return null
	var origin_2d: Vector2 = Vector2(unit.global_position.x, unit.global_position.z)
	var sample_2d: Vector2 = Vector2(world_pos.x, world_pos.z)
	var startup_free_radius: float = 0.45
	if unit.has_method("get_collision_half_extents"):
		var hh: Vector2 = unit.call("get_collision_half_extents")
		startup_free_radius = maxf(0.35, minf(hh.x, hh.y) * 0.45)
	if origin_2d.distance_to(sample_2d) <= startup_free_radius:
		return null
	var mover_obb: Dictionary = _get_unit_obb_at(unit, world_pos, forward_hint)
	if mover_obb.is_empty():
		return null
	var best_blocker = null
	var best_dist_sq: float = INF
	for other in units:
		if other == null or not is_instance_valid(other) or other.dead or other == unit:
			continue
		if _units_ignore_each_other(unit, other):
			continue
		var other_obb: Dictionary = _get_unit_obb_at(other, other.global_position, Vector3.ZERO)
		if other_obb.is_empty():
			continue
		var sat: Dictionary = _obb_overlap_mtv_2d(mover_obb, other_obb)
		if bool(sat.get("overlap", false)):
			var d2: float = Vector2(other.global_position.x - world_pos.x, other.global_position.z - world_pos.z).length_squared()
			if d2 < best_dist_sq:
				best_dist_sq = d2
				best_blocker = other
	return best_blocker

func resolve_unit_motion(unit, goal: Vector3, move_dir: Vector3, step_len: float, mode: String = "move", target = null) -> Dictionary:
	var dir: Vector3 = move_dir
	dir.y = 0.0
	if dir.length_squared() <= 0.000001:
		if unit != null and unit.has_method("get_collision_forward_flat"):
			dir = unit.call("get_collision_forward_flat")
		else:
			dir = Vector3.FORWARD
	else:
		dir = dir.normalized()
	var result := {
		"position": unit.global_position if unit != null else Vector3.ZERO,
		"forward": dir,
		"note": "blocked"
	}
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return result
	if not unit_collision_blocking_enabled:
		result.position = unit.global_position + dir * maxf(0.0, step_len)
		result.note = "advance"
		return result
	var actual_step: float = maxf(0.0, step_len)
	if actual_step <= 0.0001:
		result.note = "zoc_stop"
		return result
	var from_pos: Vector3 = unit.global_position
	var desired_pos: Vector3 = from_pos + dir * actual_step
	if has_method("can_unit_walk_at_world") and not bool(can_unit_walk_at_world(desired_pos, unit)):
		result.note = "map_block"
		return result
	var blocker = _find_blocking_unit_circle(unit, desired_pos, mode, target)
	if blocker == null:
		_finalize_unit_naval_state_after_move(unit, from_pos, desired_pos)
		result.position = desired_pos
		result.note = "advance"
		return result
	if mode == "charge":
		if blocker == target:
			_finalize_unit_naval_state_after_move(unit, from_pos, desired_pos)
			result.position = desired_pos
			result.note = "charge_pierce"
			return result
		result.note = "charge_blocked"
		return result
	if (mode == "chase" or mode == "reengage") and blocker == target:
		var engage_stop_dist: float = 0.0
		if unit.has_method("get_ranged_engage_center_distance") and bool(unit.call("_is_archer_role")):
			engage_stop_dist = float(unit.call("get_ranged_engage_center_distance", target))
		elif unit.has_method("_get_ranged_fixed_center_attack_distance") and bool(unit.call("_is_archer_role")):
			engage_stop_dist = float(unit.call("_get_ranged_fixed_center_attack_distance"))
		elif unit.has_method("get_melee_engage_center_distance"):
			engage_stop_dist = float(unit.call("get_melee_engage_center_distance", target))
		elif unit.has_method("_get_melee_fixed_center_attack_distance"):
			engage_stop_dist = float(unit.call("_get_melee_fixed_center_attack_distance"))
		var to_target: Vector3 = target.global_position - unit.global_position
		to_target.y = 0.0
		var target_dist: float = to_target.length()
		var allowed_step: float = maxf(0.0, target_dist - maxf(0.0, engage_stop_dist))
		if allowed_step > 0.001:
			var engage_step: float = minf(actual_step, allowed_step)
			var engage_pos: Vector3 = from_pos + dir * engage_step
			if not has_method("can_unit_walk_at_world") or bool(can_unit_walk_at_world(engage_pos, unit)):
				_finalize_unit_naval_state_after_move(unit, from_pos, engage_pos)
				result.position = engage_pos
				result.note = "engage_advance"
				return result
		result.note = "engage_front"
		return result
	var sidepass: Dictionary = _try_circle_sidepass(unit, blocker, dir, actual_step, goal)
	if bool(sidepass.get("ok", false)):
		var sidepass_pos: Vector3 = sidepass.get("position", desired_pos)
		_finalize_unit_naval_state_after_move(unit, from_pos, sidepass_pos)
		result.position = sidepass_pos
		result.forward = sidepass.forward
		result.detour_goal = sidepass.get("detour_goal", sidepass.position)
		result.detour_sec = float(sidepass.get("detour_sec", 0.95))
		result.note = String(sidepass.get("note", "sidepass"))
		return result
	result.note = "blocked"
	return result

func resolve_unit_step(unit, from_pos: Vector3, desired_pos: Vector3, forward_hint: Vector3 = Vector3.ZERO) -> Vector3:
	if not unit_collision_blocking_enabled:
		return desired_pos
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return desired_pos
	var move_dir: Vector3 = desired_pos - from_pos
	move_dir.y = 0.0
	var dist: float = move_dir.length()
	if dist <= 0.0001:
		return desired_pos
	var dir: Vector3 = move_dir / dist
	var motion: Dictionary = resolve_unit_motion(unit, desired_pos, dir, dist, "move", null)
	return motion.get("position", from_pos)

func _resolve_unit_position_blocking(unit, prev_pos: Vector3, desired_pos: Vector3, forward_hint: Vector3) -> Vector3:
	var blocker = _find_blocking_unit_for_sample(unit, desired_pos, forward_hint)
	if blocker == null:
		return desired_pos
	return prev_pos

func _is_unit_explicitly_attacking(unit, blocker) -> bool:
	if unit == null or blocker == null or not is_instance_valid(unit) or not is_instance_valid(blocker):
		return false
	var command_mode: int = int(unit.get("command_mode"))
	var nav_mode: int = int(unit.get("nav_mode"))
	if command_mode == int(UnitController.CommandMode.FORCE_ATTACK) or nav_mode == int(UnitController.NavMode.CHASE_TARGET):
		return true
	var target = unit.get("target_unit")
	if target != null and target == blocker:
		return true
	var chase_target = unit.get("chase_target_unit")
	if chase_target != null and chase_target == blocker:
		return true
	var skill_target = unit.get("skill_target")
	var skill_type: int = int(unit.get("skill_type"))
	if skill_target != null and skill_target == blocker and skill_type != int(UnitController.SkillType.NONE):
		return true
	return false

func _can_unit_sidepass_blocker(unit, blocker) -> bool:
	if not non_attack_sidepass_enabled:
		return false
	if unit == null or blocker == null or not is_instance_valid(unit) or not is_instance_valid(blocker):
		return false
	if int(unit.get("team_id")) == int(blocker.get("team_id")):
		return true
	return not _is_unit_explicitly_attacking(unit, blocker)

func _try_non_attack_sidepass(unit, blocker, prev_pos: Vector3, desired_pos: Vector3, forward_hint: Vector3) -> Vector3:
	if not _can_unit_sidepass_blocker(unit, blocker):
		return Vector3.INF
	var step_vec: Vector3 = desired_pos - prev_pos
	step_vec.y = 0.0
	var step_len: float = step_vec.length()
	if step_len <= 0.0001:
		return Vector3.INF
	var base_dir: Vector3 = step_vec / step_len
	if base_dir.length_squared() <= 0.000001:
		base_dir = forward_hint
		base_dir.y = 0.0
		if base_dir.length_squared() <= 0.000001:
			return Vector3.INF
		base_dir = base_dir.normalized()
	var own_half: Vector2 = Vector2(0.6, 0.6)
	var blocker_half: Vector2 = Vector2(0.6, 0.6)
	if unit.has_method("get_collision_half_extents"):
		own_half = unit.call("get_collision_half_extents")
	if blocker.has_method("get_collision_half_extents"):
		blocker_half = blocker.call("get_collision_half_extents")
	var clearance: float = maxf(0.35, own_half.x + blocker_half.x + maxf(0.0, non_attack_sidepass_clearance))
	var first_sign: int = 1 if int(unit.get_instance_id()) % 2 == 0 else -1
	var signs: Array[int] = [first_sign, -first_sign]
	var angle_list: Array[float] = [non_attack_sidepass_angle_deg, non_attack_sidepass_angle_alt_deg]
	for angle_deg_any in angle_list:
		var angle_deg: float = float(angle_deg_any)
		var angle_rad: float = deg_to_rad(clampf(angle_deg, 5.0, 80.0))
		for sign in signs:
			var cand_dir: Vector3 = base_dir.rotated(Vector3.UP, angle_rad * float(sign)).normalized()
			if cand_dir.dot(base_dir) <= 0.15:
				continue
			var cand_pos: Vector3 = prev_pos + cand_dir * step_len
			var side_vec: Vector3 = cand_dir - base_dir * cand_dir.dot(base_dir)
			side_vec.y = 0.0
			if side_vec.length_squared() > 0.000001:
				cand_pos += side_vec.normalized() * minf(clearance * 0.35, maxf(0.2, step_len * 0.75))
			if has_method("can_unit_walk_at_world") and not bool(can_unit_walk_at_world(cand_pos, unit)):
				continue
			if _find_blocking_unit_for_sample(unit, cand_pos, cand_dir) == null:
				return cand_pos
	return Vector3.INF

func _unit_logic_radius(unit) -> float:
	if unit == null or not is_instance_valid(unit):
		return 0.5
	if unit.has_method("get_logic_radius"):
		return maxf(0.5, float(unit.call("get_logic_radius")) + unit_logic_radius_padding)
	if unit.has_method("get_collision_half_extents"):
		var hh: Vector2 = unit.call("get_collision_half_extents")
		return maxf(0.5, maxf(hh.x, hh.y) + unit_logic_radius_padding)
	return 0.5 + unit_logic_radius_padding

func _flat_distance_3d(a: Vector3, b: Vector3) -> float:
	var d: Vector3 = a - b
	d.y = 0.0
	return d.length()

func _find_blocking_unit_circle(unit, sample_pos: Vector3, mode: String = "move", target = null):
	if not unit_collision_blocking_enabled:
		return null
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return null
	var own_radius: float = _unit_logic_radius(unit)
	for other in units:
		if other == null or not is_instance_valid(other) or other.dead or other == unit:
			continue
		if _units_ignore_each_other(unit, other):
			continue
		var limit: float = own_radius + _unit_logic_radius(other)
		if _flat_distance_3d(sample_pos, other.global_position) <= limit:
			return other
	return null

func _try_circle_sidepass(unit, blocker, move_dir: Vector3, actual_step: float, goal: Vector3) -> Dictionary:
	if not _can_unit_sidepass_blocker(unit, blocker):
		return {"ok": false}
	var best: Dictionary = {"ok": false}
	var best_score: float = INF
	for sign in [1, -1]:
		var blocker_to_unit: Vector3 = unit.global_position - blocker.global_position
		blocker_to_unit.y = 0.0
		if blocker_to_unit.length_squared() <= 0.000001:
			blocker_to_unit = Vector3(-move_dir.z, 0.0, move_dir.x) * float(sign)
		var away_dir: Vector3 = blocker_to_unit.normalized()
		var tangent_dir: Vector3 = Vector3(-away_dir.z, 0.0, away_dir.x) * float(sign)
		if tangent_dir.dot(move_dir) < 0.0:
			tangent_dir = -tangent_dir
		var clearance: float = _unit_logic_radius(blocker) + _unit_logic_radius(unit) + maxf(0.0, non_attack_sidepass_clearance)
		var side_anchor: Vector3 = blocker.global_position + away_dir * clearance
		var candidate_pos: Vector3 = side_anchor + tangent_dir.normalized() * maxf(actual_step, clearance * 0.55)
		candidate_pos.y = unit.global_position.y
		if has_method("can_unit_walk_at_world") and not bool(can_unit_walk_at_world(candidate_pos, unit)):
			continue
		if _find_blocking_unit_circle(unit, candidate_pos, "move", null) != null:
			continue
		var detour_goal: Vector3 = candidate_pos + tangent_dir.normalized() * maxf(unit_detour_forward_push, clearance * 1.8)
		detour_goal.y = unit.global_position.y
		if has_method("can_unit_walk_at_world") and not bool(can_unit_walk_at_world(detour_goal, unit)):
			detour_goal = candidate_pos
		var score: float = candidate_pos.distance_to(goal) + detour_goal.distance_to(goal) * 0.35
		var goal_dir: Vector3 = goal - unit.global_position
		goal_dir.y = 0.0
		if goal_dir.length_squared() > 0.000001:
			score -= tangent_dir.normalized().dot(goal_dir.normalized()) * 1.4
		if score < best_score:
			best_score = score
			best = {
				"ok": true,
				"position": candidate_pos,
				"forward": tangent_dir.normalized(),
				"detour_goal": detour_goal,
				"detour_sec": 0.95,
				"note": "sidepass_left" if sign > 0 else "sidepass_right"
			}
	return best

func _try_same_team_angle_offset(_unit, _blocker, _prev_pos: Vector3, _desired_pos: Vector3, _forward_hint: Vector3) -> Vector3:
	return Vector3.INF

func is_pierce_path_clear(caster, target, start_pos: Vector3, end_pos: Vector3, forward_hint: Vector3 = Vector3.ZERO, sample_step: float = 0.8) -> bool:
	if caster == null or target == null:
		return false
	var step_len: float = maxf(0.25, sample_step)
	var path_len: float = Vector2(end_pos.x - start_pos.x, end_pos.z - start_pos.z).length()
	var steps: int = maxi(1, int(ceil(path_len / step_len)))
	var hint: Vector3 = forward_hint
	hint.y = 0.0
	if hint.length_squared() <= 0.000001:
		hint = end_pos - start_pos
		hint.y = 0.0
	for i in range(1, steps + 1):
		var t: float = float(i) / float(steps)
		var sample: Vector3 = start_pos.lerp(end_pos, t)
		if has_method("can_unit_walk_at_world"):
			if not bool(can_unit_walk_at_world(sample, caster)):
				return false
		for other in units:
			if other == null or not is_instance_valid(other) or other.dead or other == caster:
				continue
			if other == target:
				continue
			var mover_obb: Dictionary = _get_unit_obb_at(caster, sample, hint)
			var other_obb: Dictionary = _get_unit_obb_at(other, other.global_position, Vector3.ZERO)
			if mover_obb.is_empty() or other_obb.is_empty():
				continue
			if bool(_obb_overlap_mtv_2d(mover_obb, other_obb).get("overlap", false)):
				return false
	return true

func get_closest_enemy_in_front(source, min_forward_dot: float = 0.1):
	if source == null or not is_instance_valid(source):
		return null
	var source_team: int = int(source.team_id)
	var facing: Vector3 = -source.global_basis.z
	facing.y = 0.0
	if facing.length_squared() <= 0.000001:
		facing = Vector3.FORWARD
	else:
		facing = facing.normalized()
	var best = null
	var best_dist: float = INF
	for enemy in units:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.dead or enemy.team_id == source_team:
			continue
		if not is_enemy_targetable_for_team(source_team, enemy):
			continue
		var d: Vector3 = enemy.global_position - source.global_position
		d.y = 0.0
		if d.length_squared() <= 0.000001:
			continue
		var dir: Vector3 = d.normalized()
		if dir.dot(facing) < clampf(min_forward_dot, -1.0, 1.0):
			continue
		var dist_sq: float = d.length_squared()
		if dist_sq < best_dist:
			best_dist = dist_sq
			best = enemy
	return best

func get_closest_enemy(source):
	if source == null or not is_instance_valid(source):
		return null
	var source_team: int = int(source.team_id)
	var best = null
	var best_dist: float = INF
	for enemy in units:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.dead or enemy.team_id == source_team:
			continue
		if not is_enemy_targetable_for_team(source_team, enemy):
			continue
		var d: Vector3 = enemy.global_position - source.global_position
		d.y = 0.0
		var dist_sq: float = d.length_squared()
		if dist_sq < best_dist:
			best_dist = dist_sq
			best = enemy
	return best

func _cleanup_dead_units() -> void:
	for i in range(units.size() - 1, -1, -1):
		var unit = units[i]
		if unit == null or not is_instance_valid(unit):
			units.remove_at(i)
			continue
		if unit.dead:
			_remove_unit_from_recon_cache(unit.get_instance_id())
			_clear_unit_auto_mode(unit.get_instance_id())
			units.remove_at(i)

func _clear_recon_runtime_state() -> void:
	_recon_tick_accum = 0.0
	_recon_spotted_until_by_team.clear()
	_recon_discovered_enemy_ids_by_team.clear()

func _recon_team_spot_table(team_id: int) -> Dictionary:
	var cached: Variant = _recon_spotted_until_by_team.get(team_id, null)
	if cached is Dictionary:
		return cached as Dictionary
	var created: Dictionary = {}
	_recon_spotted_until_by_team[team_id] = created
	return created

func _recon_team_discovered_table(team_id: int) -> Dictionary:
	var cached: Variant = _recon_discovered_enemy_ids_by_team.get(team_id, null)
	if cached is Dictionary:
		return cached as Dictionary
	var created: Dictionary = {}
	_recon_discovered_enemy_ids_by_team[team_id] = created
	return created

func _remove_unit_from_recon_cache(unit_id: int) -> void:
	if unit_id <= 0:
		return
	for team_any in _recon_spotted_until_by_team.keys():
		var table_any: Variant = _recon_spotted_until_by_team.get(team_any, null)
		if table_any is Dictionary:
			(table_any as Dictionary).erase(unit_id)
	for team_any in _recon_discovered_enemy_ids_by_team.keys():
		var table_any: Variant = _recon_discovered_enemy_ids_by_team.get(team_any, null)
		if table_any is Dictionary:
			(table_any as Dictionary).erase(unit_id)

func _find_unit_by_instance_id(unit_id: int) -> UnitController:
	if unit_id <= 0:
		return null
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		if unit.get_instance_id() == unit_id:
			return unit
	return null

func _recon_unit_brief_label(enemy: UnitController, enemy_id: int = -1) -> String:
	if enemy == null or not is_instance_valid(enemy):
		return "敌军#%d" % enemy_id if enemy_id > 0 else "敌军"
	var panel_data: Dictionary = enemy.call("get_rts_panel_data") if enemy.has_method("get_rts_panel_data") else {}
	var name_text: String = String(panel_data.get("main_name", enemy.name)).strip_edges()
	if name_text.is_empty():
		name_text = "敌军"
	var role_text: String = String(panel_data.get("unit_type_label", "")).strip_edges()
	if role_text.is_empty():
		role_text = _hover_role_text(_unit_role_id(enemy))
	return "%s(%s)" % [name_text, role_text]

func _notify_recon_spot_discovered(observer_team: int, enemy: UnitController, spotter: UnitController, now_sec: float) -> void:
	var discovered: Dictionary = _recon_team_discovered_table(observer_team)
	var enemy_id: int = enemy.get_instance_id()
	if discovered.has(enemy_id):
		return
	discovered[enemy_id] = now_sec
	if observer_team != demo_recon_player_team_id:
		return
	var enemy_label: String = _recon_unit_brief_label(enemy, enemy_id)
	var role_id: String = _unit_role_id(spotter)
	var source_text: String = "由斥候侦得" if role_id == "scout" else "由%s发现" % _hover_role_text(role_id)
	_set_battle_status("敌情：[侦察] 发现敌军%s（%s）" % [enemy_label, source_text], 1.8)

func _notify_recon_spot_lost(observer_team: int, enemy_id: int) -> void:
	if not demo_recon_lost_log_enabled:
		return
	if observer_team != demo_recon_player_team_id:
		return
	var enemy: UnitController = _find_unit_by_instance_id(enemy_id)
	var enemy_label: String = _recon_unit_brief_label(enemy, enemy_id)
	_set_battle_status("敌情：[侦察] 已丢失敌军%s视野，需重新侦察。" % enemy_label, 1.8)

func _prune_recon_cache(now_sec: float) -> void:
	var alive_ids: Dictionary = {}
	var expired_alive_ids_by_team: Dictionary = {}
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		alive_ids[unit.get_instance_id()] = true
	for team_any in _recon_spotted_until_by_team.keys():
		var team_key: int = int(team_any)
		var table_any: Variant = _recon_spotted_until_by_team.get(team_any, null)
		if not (table_any is Dictionary):
			continue
		var table: Dictionary = table_any as Dictionary
		for enemy_id_any in table.keys():
			var enemy_id: int = int(enemy_id_any)
			var expire_sec: float = float(table.get(enemy_id_any, 0.0))
			var is_alive: bool = alive_ids.has(enemy_id)
			var is_expired: bool = expire_sec <= now_sec
			if is_expired or not is_alive:
				table.erase(enemy_id)
				if is_expired and is_alive:
					var expired_any: Variant = expired_alive_ids_by_team.get(team_key, null)
					var expired_ids: Array = expired_any as Array if expired_any is Array else []
					expired_ids.append(enemy_id)
					expired_alive_ids_by_team[team_key] = expired_ids
		if table.is_empty():
			_recon_spotted_until_by_team.erase(team_key)
	for team_any in expired_alive_ids_by_team.keys():
		var team_key: int = int(team_any)
		var expired_any: Variant = expired_alive_ids_by_team.get(team_any, null)
		var expired_ids: Array = expired_any as Array if expired_any is Array else []
		if expired_ids.is_empty():
			continue
		var discovered_any: Variant = _recon_discovered_enemy_ids_by_team.get(team_key, null)
		if discovered_any is Dictionary:
			var discovered_table: Dictionary = discovered_any as Dictionary
			for enemy_id_any in expired_ids:
				var enemy_id: int = int(enemy_id_any)
				discovered_table.erase(enemy_id)
				_notify_recon_spot_lost(team_key, enemy_id)
			if discovered_table.is_empty():
				_recon_discovered_enemy_ids_by_team.erase(team_key)
		else:
			for enemy_id_any in expired_ids:
				_notify_recon_spot_lost(team_key, int(enemy_id_any))
	for team_any in _recon_discovered_enemy_ids_by_team.keys():
		var team_key: int = int(team_any)
		var table_any: Variant = _recon_discovered_enemy_ids_by_team.get(team_any, null)
		if not (table_any is Dictionary):
			continue
		var table: Dictionary = table_any as Dictionary
		for enemy_id_any in table.keys():
			var enemy_id: int = int(enemy_id_any)
			if not alive_ids.has(enemy_id):
				table.erase(enemy_id)
		if table.is_empty():
			_recon_discovered_enemy_ids_by_team.erase(team_key)

func _recon_mul_from_table(table: Dictionary, key: String, fallback: float = 1.0) -> float:
	var mul: float = fallback
	if table.has(key):
		mul = float(table.get(key, fallback))
	elif table.has("default"):
		mul = float(table.get("default", fallback))
	return clampf(mul, 0.15, 3.0)

func _normalize_recon_day_phase(raw: String) -> String:
	var phase: String = raw.strip_edges().to_lower()
	if phase == "night" or phase == "evening" or phase == "pm" or phase == "dark":
		return "night"
	return "day"

func _normalize_recon_weather_state(raw: String) -> String:
	var state: String = raw.strip_edges().to_lower()
	if state.is_empty():
		return "sunny"
	if state == "thunder" or state == "thunderstorm":
		return "storm"
	return state

func _current_recon_vision_env_mul() -> float:
	var phase_key: String = _normalize_recon_day_phase(weather_day_phase)
	var weather_key: String = _normalize_recon_weather_state(weather_state)
	var day_mul: float = _recon_mul_from_table(demo_recon_day_phase_vision_mul, phase_key, 1.0)
	var weather_mul: float = _recon_mul_from_table(demo_recon_weather_vision_mul, weather_key, 1.0)
	return clampf(day_mul * weather_mul, 0.15, 3.0)

func _current_recon_spot_duration_env_mul() -> float:
	var phase_key: String = _normalize_recon_day_phase(weather_day_phase)
	var weather_key: String = _normalize_recon_weather_state(weather_state)
	var day_mul: float = _recon_mul_from_table(demo_recon_day_phase_spot_duration_mul, phase_key, 1.0)
	var weather_mul: float = _recon_mul_from_table(demo_recon_weather_spot_duration_mul, weather_key, 1.0)
	return clampf(day_mul * weather_mul, 0.15, 3.0)

func _tick_recon_spotting(delta: float) -> void:
	if not demo_recon_enabled:
		if not _recon_spotted_until_by_team.is_empty() or not _recon_discovered_enemy_ids_by_team.is_empty():
			_clear_recon_runtime_state()
		return
	if delta <= 0.0 or units.size() < 2:
		return
	_recon_tick_accum += maxf(0.0, delta)
	var tick_interval: float = maxf(0.05, demo_recon_tick_interval)
	if _recon_tick_accum < tick_interval:
		return
	_recon_tick_accum = fmod(_recon_tick_accum, tick_interval)
	var now_sec: float = Time.get_ticks_msec() / 1000.0
	_prune_recon_cache(now_sec)
	var vision_env_mul: float = _current_recon_vision_env_mul()
	for observer_any in units:
		var observer: UnitController = observer_any as UnitController
		if observer == null or not is_instance_valid(observer) or observer.dead:
			continue
		var observer_team: int = int(observer.team_id)
		var detect_radius: float = maxf(1.0, float(observer.vision_radius)) * vision_env_mul
		if _unit_role_id(observer) == "scout":
			detect_radius *= clampf(demo_recon_scout_vision_mul, 0.1, 6.0)
		var detect_sq: float = detect_radius * detect_radius
		var observer_pos: Vector3 = observer.global_position
		for enemy_any in units:
			var enemy: UnitController = enemy_any as UnitController
			if enemy == null or not is_instance_valid(enemy) or enemy.dead:
				continue
			if enemy == observer or int(enemy.team_id) == observer_team:
				continue
			var offset: Vector3 = enemy.global_position - observer_pos
			offset.y = 0.0
			if offset.length_squared() > detect_sq:
				continue
			_mark_enemy_spotted_for_team(observer_team, enemy, observer, now_sec)

func _mark_enemy_spotted_for_team(observer_team: int, enemy: UnitController, spotter: UnitController, now_sec: float) -> void:
	if enemy == null or not is_instance_valid(enemy) or enemy.dead:
		return
	var enemy_id: int = enemy.get_instance_id()
	if enemy_id <= 0:
		return
	var env_mul: float = _current_recon_spot_duration_env_mul()
	var spot_duration_sec: float = maxf(0.5, demo_recon_spot_duration_sec * env_mul)
	var team_spots: Dictionary = _recon_team_spot_table(observer_team)
	var prev_expire_sec: float = float(team_spots.get(enemy_id, -1.0))
	team_spots[enemy_id] = maxf(prev_expire_sec, now_sec + spot_duration_sec)
	if prev_expire_sec > now_sec:
		return
	_notify_recon_spot_discovered(observer_team, enemy, spotter, now_sec)

func is_enemy_targetable_for_team(team_id: int, enemy) -> bool:
	if enemy == null or not is_instance_valid(enemy) or enemy.dead:
		return false
	if team_id < 0:
		return true
	if int(enemy.team_id) == team_id:
		return false
	if not demo_recon_enabled:
		return true
	return is_enemy_spotted_for_team(team_id, enemy)

func is_enemy_spotted_for_team(team_id: int, enemy) -> bool:
	if not demo_recon_enabled:
		return true
	if enemy == null or not is_instance_valid(enemy):
		return false
	var enemy_id: int = enemy.get_instance_id()
	if enemy_id <= 0:
		return false
	var team_any: Variant = _recon_spotted_until_by_team.get(team_id, null)
	if not (team_any is Dictionary):
		return false
	var expire_sec: float = float((team_any as Dictionary).get(enemy_id, -1.0))
	return expire_sec > (Time.get_ticks_msec() / 1000.0)

func get_enemy_spotted_time_left(team_id: int, enemy) -> float:
	if not demo_recon_enabled:
		return 9999.0
	if enemy == null or not is_instance_valid(enemy):
		return 0.0
	var enemy_id: int = enemy.get_instance_id()
	if enemy_id <= 0:
		return 0.0
	var team_any: Variant = _recon_spotted_until_by_team.get(team_id, null)
	if not (team_any is Dictionary):
		return 0.0
	var now_sec: float = Time.get_ticks_msec() / 1000.0
	var expire_sec: float = float((team_any as Dictionary).get(enemy_id, -1.0))
	return maxf(0.0, expire_sec - now_sec)

func _is_unit_visible_to_team_ui(unit, viewer_team_id: int) -> bool:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return false
	if viewer_team_id < 0:
		return true
	if int(unit.team_id) == viewer_team_id:
		return true
	return is_enemy_targetable_for_team(viewer_team_id, unit)

func _is_unit_visible_for_player_ui(unit) -> bool:
	return _is_unit_visible_to_team_ui(unit, demo_recon_player_team_id)

func _apply_enemy_soft_repulsion(_delta: float) -> void:
	pass

func _is_pair_separating(a, b, pair_dir: Vector3) -> bool:
	if a == null or b == null:
		return false
	var va_any: Variant = a.get("move_velocity")
	var vb_any: Variant = b.get("move_velocity")
	if not (va_any is Vector3) or not (vb_any is Vector3):
		return false
	var va: Vector3 = va_any
	var vb: Vector3 = vb_any
	var rel: Vector3 = va - vb
	rel.y = 0.0
	var along: float = rel.dot(pair_dir)
	return along >= maxf(0.0, soft_repulsion_separating_speed_threshold)

func _compute_pair_separation_distance(a, b, same_team: bool) -> float:
	var radius_a: float = _compute_unit_repel_radius(a)
	var radius_b: float = _compute_unit_repel_radius(b)
	var pair_dist: float = radius_a + radius_b
	if same_team:
		return maxf(0.8, pair_dist * 0.92)
	var front_a: float = _compute_unit_front_radius(a)
	var front_b: float = _compute_unit_front_radius(b)
	var enemy_gap: float = maxf(0.0, soft_repulsion_enemy_front_gap)
	if a.state == UnitController.UnitState.MELEE or b.state == UnitController.UnitState.MELEE:
		enemy_gap += maxf(0.0, soft_repulsion_melee_extra_gap)
	var contact_dist: float = front_a + front_b + enemy_gap
	return maxf(0.9, maxf(pair_dist * 1.02, contact_dist))

func _compute_unit_repel_radius(unit) -> float:
	if unit == null or not is_instance_valid(unit):
		return 1.0
	var safety: float = maxf(0.6, float(unit.get("safety_distance")))
	var activity: float = safety * 1.35
	if unit.has_method("get_activity_radius"):
		activity = maxf(activity, float(unit.call("get_activity_radius")))
	var attack_range: float = maxf(0.6, float(unit.get("attack_range")))
	var unit_scale: float = 1.0
	if unit is Node3D:
		var unit_3d: Node3D = unit as Node3D
		unit_scale = maxf(0.5, maxf(unit_3d.scale.x, unit_3d.scale.z))
	var radius: float = maxf(safety, maxf(activity * 0.34, attack_range * 0.4))
	radius = radius * maxf(0.25, soft_repulsion_radius_mul)
	radius += maxf(0.0, soft_repulsion_base_padding) * unit_scale
	return maxf(0.6, radius)

func _compute_unit_front_radius(unit) -> float:
	if unit == null or not is_instance_valid(unit):
		return 1.0
	var activity: float = 1.0
	if unit.has_method("get_activity_radius"):
		activity = maxf(activity, float(unit.call("get_activity_radius")))
	var form_radius: float = 0.0
	if unit.has_method("_get_non_melee_formation_radius"):
		form_radius = maxf(0.0, float(unit.call("_get_non_melee_formation_radius")))
	return maxf(activity * 0.58, form_radius * 0.42)

func _is_unit_soft_repel_active(unit) -> bool:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return false
	return unit.state == UnitController.UnitState.MOVE or unit.state == UnitController.UnitState.MELEE

func _setup_selection_overlay() -> void:
	selection_overlay_layer = CanvasLayer.new()
	selection_overlay_layer.name = "SelectionOverlay"
	add_child(selection_overlay_layer)
	selection_overlay_root = Control.new()
	selection_overlay_root.name = "SelectionRoot"
	selection_overlay_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	selection_overlay_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_overlay_layer.add_child(selection_overlay_root)
	selection_rect_node = ColorRect.new()
	selection_rect_node.name = "SelectionRect"
	selection_rect_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_rect_node.color = Color(0.16, 0.82, 0.46, 0.18)
	selection_rect_node.visible = false
	selection_overlay_root.add_child(selection_rect_node)

func _begin_selection_drag(screen_pos: Vector2) -> void:
	is_left_drag_selecting = true
	drag_start_screen = screen_pos
	drag_current_screen = screen_pos
	_update_selection_rect_visual()

func _update_selection_drag(screen_pos: Vector2) -> void:
	if not is_left_drag_selecting:
		return
	drag_current_screen = screen_pos
	_update_selection_rect_visual()

func _end_selection_drag(screen_pos: Vector2, additive: bool) -> void:
	if not is_left_drag_selecting:
		return
	is_left_drag_selecting = false
	drag_current_screen = screen_pos
	var rect: Rect2 = _selection_rect_from_points(drag_start_screen, drag_current_screen)
	var is_drag_select: bool = rect.size.x >= 12.0 and rect.size.y >= 12.0
	if is_drag_select:
		_select_friendly_units_in_rect(rect, additive)
	else:
		_on_left_click(screen_pos)
	_update_selection_rect_visual()

func _selection_rect_from_points(a: Vector2, b: Vector2) -> Rect2:
	var x1: float = minf(a.x, b.x)
	var y1: float = minf(a.y, b.y)
	var x2: float = maxf(a.x, b.x)
	var y2: float = maxf(a.y, b.y)
	return Rect2(Vector2(x1, y1), Vector2(x2 - x1, y2 - y1))

func _update_selection_rect_visual() -> void:
	if selection_rect_node == null or not is_instance_valid(selection_rect_node):
		return
	if not is_left_drag_selecting:
		selection_rect_node.visible = false
		return
	var rect: Rect2 = _selection_rect_from_points(drag_start_screen, drag_current_screen)
	selection_rect_node.position = rect.position
	selection_rect_node.size = rect.size
	selection_rect_node.visible = rect.size.x >= 2.0 and rect.size.y >= 2.0

func _select_friendly_units_in_rect(rect: Rect2, additive: bool) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return
	var picks: Array = selected_units.duplicate() if additive else []
	for unit in units:
		if not _can_player_direct_unit(unit):
			continue
		var world_pos: Vector3 = unit.global_position + Vector3(0.0, unit_tag_height_offset, 0.0)
		if camera.is_position_behind(world_pos):
			continue
		var screen_pos: Vector2 = camera.unproject_position(world_pos)
		if rect.has_point(screen_pos) and not picks.has(unit):
			picks.append(unit)
	_set_selected_units(picks)

func _can_player_direct_unit(unit) -> bool:
	return unit != null and is_instance_valid(unit) and not unit.dead and (int(unit.team_id) == 0 or debug_allow_control_all_units_for_testing)

func _find_controllable_unit_near_point(world_point: Vector3, radius: float):
	var best = null
	var best_dist_sq: float = radius * radius
	for unit in units:
		if not _can_player_direct_unit(unit):
			continue
		var d: Vector3 = unit.global_position - world_point
		d.y = 0.0
		var dist_sq: float = d.length_squared()
		if dist_sq <= best_dist_sq:
			best_dist_sq = dist_sq
			best = unit
	return best

func _get_selected_player_units() -> Array:
	var out: Array = []
	for unit in selected_units:
		if not _can_player_direct_unit(unit):
			continue
		out.append(unit)
	if out.is_empty() and _can_player_direct_unit(selected_unit):
		out.append(selected_unit)
	return out

func _on_left_click(screen_pos: Vector2) -> void:
	if show_unit_tags:
		var tag_pick = _pick_friendly_unit_by_tag_screen(screen_pos)
		if tag_pick != null:
			_set_selected_units([tag_pick])
			return
	var hit: Dictionary = _raycast_screen(screen_pos)
	if hit.is_empty() or not hit.has("position"):
		_set_selected_units([])
		return
	var hit_pos: Vector3 = hit["position"]
	var near_unit = _find_controllable_unit_near_point(hit_pos, 5.2)
	if near_unit != null:
		_set_selected_units([near_unit])
	else:
		_set_selected_units([])

func _pick_friendly_unit_by_tag_screen(screen_pos: Vector2):
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return null
	var best_unit = null
	var best_dist: float = INF
	for unit in units:
		if not _can_player_direct_unit(unit):
			continue
		var world_pos: Vector3 = unit.global_position + Vector3(0.0, unit_tag_height_offset, 0.0)
		if camera.is_position_behind(world_pos):
			continue
		var screen_tag: Vector2 = camera.unproject_position(world_pos)
		var scale_factor: float = _compute_tag_scale(camera, world_pos)
		var pick_radius: float = maxf(40.0, unit_tag_click_radius_px * maxf(0.45, scale_factor))
		var dist: float = screen_tag.distance_to(screen_pos)
		if dist > pick_radius:
			continue
		if dist < best_dist:
			best_dist = dist
			best_unit = unit
	return best_unit
func _on_right_click(screen_pos: Vector2, use_attack_move: bool = false) -> void:
	if _strategy_map_view != null and is_instance_valid(_strategy_map_view) and _strategy_map_view.has_method("try_open_facility_context_menu"):
		var opened_any: Variant = _strategy_map_view.call("try_open_facility_context_menu", screen_pos)
		if bool(opened_any):
			pending_ground_command = ""
			_update_rts_panel_buttons()
			return
	var squad: Array = _get_selected_player_units()
	if squad.is_empty():
		return
	var lead = squad[0]
	var observer_team: int = int(lead.team_id)
	var screen_enemy = _pick_enemy_unit_by_tag_screen(screen_pos, 1 - observer_team, observer_team)
	if screen_enemy == null:
		screen_enemy = _pick_enemy_unit_by_screen(screen_pos, 1 - observer_team, observer_team)
	if use_attack_move:
		_issue_selected_attack_move_at_screen(screen_pos)
		pending_ground_command = ""
		_update_rts_panel_buttons()
		return
	if screen_enemy != null:
		_issue_selected_force_attack_on_unit(screen_enemy, observer_team)
		return
	var hit: Dictionary = _raycast_screen(screen_pos)
	if hit.is_empty():
		return
	var hit_pos: Vector3 = hit["position"]
	var near_enemy = _find_unit_near_point(hit_pos, 1 - observer_team, 4.8, observer_team)
	if near_enemy != null:
		var fallback: Vector3 = _resolve_walkable_command_point(hit_pos, lead)
		if fallback == Vector3.INF:
			_set_battle_status("Blocked destination.")
			return
		var attack_offsets2: Array[Vector3] = _build_group_attack_front_offsets(squad, fallback, 3.6)
		for j in range(squad.size()):
			var unit2 = squad[j]
			if unit2 == null or not is_instance_valid(unit2) or unit2.dead:
				continue
			var fallback2: Vector3 = _resolve_walkable_command_point(fallback + attack_offsets2[j], unit2)
			if fallback2 == Vector3.INF:
				fallback2 = fallback
			unit2.issue_attack_order(near_enemy, fallback2, false, true, true, true)
		_show_command_marker(near_enemy.global_position, true)
		_set_battle_status("Attack order issued.")
		return
	var move_pos: Vector3 = hit_pos
	var offsets: Array[Vector3] = _build_group_offsets(squad.size(), 5.2)
	var issued_any: bool = false
	for k in range(squad.size()):
		var unit3 = squad[k]
		if unit3 == null or not is_instance_valid(unit3) or unit3.dead:
			continue
		var target_pos: Vector3 = move_pos + offsets[k]
		var issued: bool = bool(unit3.issue_move_order(target_pos))
		issued_any = issued_any or issued
	if not issued_any:
		_set_battle_status("Blocked destination.")
		return
	_show_command_marker(move_pos, false)
	_set_battle_status("Move order issued.")

func _pick_enemy_unit_by_screen(screen_pos: Vector2, team_id: int, observer_team_id: int = demo_recon_player_team_id):
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return null
	var best = null
	var best_dist: float = right_click_enemy_pick_radius_px * right_click_enemy_pick_radius_px
	for unit in units:
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		if unit.team_id != team_id:
			continue
		if not is_enemy_targetable_for_team(observer_team_id, unit):
			continue
		var world_pos: Vector3 = unit.global_position + Vector3(0.0, maxf(0.6, unit_tag_height_offset * 0.35), 0.0)
		if camera.is_position_behind(world_pos):
			continue
		var sp: Vector2 = camera.unproject_position(world_pos)
		var d2: float = sp.distance_squared_to(screen_pos)
		if d2 < best_dist:
			best_dist = d2
			best = unit
	return best

func _pick_enemy_unit_by_tag_screen(screen_pos: Vector2, team_id: int, observer_team_id: int = demo_recon_player_team_id):
	var best = null
	var best_dist: float = INF
	for id_any in unit_tag_buttons.keys():
		var unit = unit_tag_units.get(id_any)
		var card: Control = unit_tag_buttons.get(id_any)
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		if card == null or not is_instance_valid(card) or not card.visible:
			continue
		if int(unit.team_id) != team_id:
			continue
		if not is_enemy_targetable_for_team(observer_team_id, unit):
			continue
		var rect := Rect2(card.global_position, card.size)
		if not rect.has_point(screen_pos):
			continue
		var dist: float = rect.get_center().distance_to(screen_pos)
		if dist < best_dist:
			best_dist = dist
			best = unit
	return best




func _build_group_offsets(count: int, spacing: float) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var c: int = maxi(1, count)
	if c == 1:
		out.append(Vector3.ZERO)
		return out
	var cols: int = maxi(2, int(ceil(sqrt(float(c)))))
	var rows: int = int(ceil(float(c) / float(cols)))
	var half_w: float = (float(cols - 1) * spacing) * 0.5
	var half_h: float = (float(rows - 1) * spacing) * 0.5
	for i in range(c):
		var r: int = i / cols
		var col: int = i % cols
		var x: float = float(col) * spacing - half_w
		var z: float = float(r) * spacing - half_h
		out.append(Vector3(x, 0.0, z))
	return out

func _issue_selected_force_attack_on_unit(enemy, observer_team_id: int = demo_recon_player_team_id) -> void:
	if enemy == null or not is_instance_valid(enemy) or enemy.dead:
		return
	if not is_enemy_targetable_for_team(observer_team_id, enemy):
		_set_battle_status("目标未暴露，需先侦察。")
		return
	var squad: Array = _get_selected_player_units()
	if squad.is_empty():
		return
	var fallback_from_enemy: Vector3 = _resolve_walkable_command_point(enemy.global_position, squad[0])
	if fallback_from_enemy == Vector3.INF:
		fallback_from_enemy = enemy.global_position
	var attack_offsets: Array[Vector3] = _build_group_attack_front_offsets(squad, fallback_from_enemy, 3.6)
	for i in range(squad.size()):
		var unit = squad[i]
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		var fallback: Vector3 = _resolve_walkable_command_point(fallback_from_enemy + attack_offsets[i], unit)
		if fallback == Vector3.INF:
			fallback = fallback_from_enemy
		unit.issue_attack_order(enemy, fallback, false, true, true, true)
	_show_command_marker(enemy.global_position, true)
	_set_battle_status("Attack order issued.")

func _build_group_attack_front_offsets(squad: Array, target_world: Vector3, spacing: float) -> Array[Vector3]:
	var c: int = maxi(1, squad.size())
	if c == 1:
		return [Vector3.ZERO]
	var center: Vector3 = Vector3.ZERO
	var valid_count: int = 0
	for unit in squad:
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		center += unit.global_position
		valid_count += 1
	if valid_count > 0:
		center /= float(valid_count)
	else:
		center = target_world
	var to_target: Vector3 = target_world - center
	to_target.y = 0.0
	var forward: Vector3 = to_target.normalized() if to_target.length_squared() > 0.0001 else Vector3.FORWARD
	var right: Vector3 = Vector3(forward.z, 0.0, -forward.x)
	if right.length_squared() <= 0.0001:
		right = Vector3.RIGHT
	else:
		right = right.normalized()
	var cols: int = clampi(int(ceil(sqrt(float(c)) * 1.35)), 2, c)
	var rows: int = int(ceil(float(c) / float(cols)))
	var half_cols: float = float(cols - 1) * 0.5
	var row_step: float = spacing * 0.9
	var out: Array[Vector3] = []
	out.resize(c)
	for i in range(c):
		var r: int = i / cols
		var col: int = i % cols
		var lateral: float = (float(col) - half_cols) * spacing
		var depth: float = -float(r) * row_step
		out[i] = right * lateral + forward * depth
	return out

func _issue_selected_attack_move_at_screen(screen_pos: Vector2) -> void:
	var squad: Array = _get_selected_player_units()
	if squad.is_empty():
		return
	var hit: Dictionary = _raycast_screen(screen_pos)
	if hit.is_empty() or not hit.has("position"):
		return
	var center: Vector3 = hit["position"]
	var offsets: Array[Vector3] = _build_group_offsets(squad.size(), 5.2)
	var issued_any: bool = false
	for i in range(squad.size()):
		var unit = squad[i]
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		var pos: Vector3 = center + offsets[i]
		var issued: bool = bool(unit.issue_attack_move_order(pos))
		issued_any = issued_any or issued
	if not issued_any:
		_set_battle_status("Blocked destination.")
		return
	_show_command_marker(center, true)
	_set_battle_status("Attack-move order issued.")

func _issue_selected_attack_move_to_cursor() -> void:
	_issue_selected_attack_move_at_screen(get_viewport().get_mouse_position())

func _issue_selected_stop() -> void:
	var squad: Array = _get_selected_player_units()
	if squad.is_empty():
		return
	var marker_pos: Vector3 = Vector3.ZERO
	var has_marker_pos: bool = false
	for unit in squad:
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		if not has_marker_pos and unit is Node3D:
			marker_pos = (unit as Node3D).global_position
			has_marker_pos = true
		if unit.has_method("issue_stop_order"):
			unit.issue_stop_order()
	if has_marker_pos:
		_show_command_marker(marker_pos, false)
	_set_battle_status("Stop order issued.")

func _issue_selected_hold_position() -> void:
	var squad: Array = _get_selected_player_units()
	if squad.is_empty():
		return
	for unit in squad:
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		if unit.has_method("issue_hold_position_order"):
			unit.issue_hold_position_order(unit.global_position)
	_set_battle_status("Hold-position order issued.")

func _set_selected_stance(stance_id: int) -> void:
	var squad: Array = _get_selected_player_units()
	if squad.is_empty():
		return
	for unit in squad:
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		if unit.has_method("set_stance"):
			unit.set_stance(stance_id)
	match stance_id:
		int(UnitController.StanceType.ACTIVE):
			_set_battle_status("Stance set: active.")
		int(UnitController.StanceType.HOLD):
			_set_battle_status("Stance set: hold.")
		_:
			_set_battle_status("Stance set: passive.")

func _issue_selected_retreat() -> void:
	var squad: Array = _get_selected_player_units()
	if squad.is_empty():
		return
	var lead = squad[0]
	var retreat_center: Vector3 = _find_nearest_retreat_point_for_unit(lead)
	if retreat_center == Vector3.INF:
		_set_battle_status("No valid retreat point found.")
		return
	var offsets: Array[Vector3] = _build_group_offsets(squad.size(), 5.4)
	for i in range(squad.size()):
		var unit = squad[i]
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		var pos: Vector3 = _resolve_walkable_command_point(retreat_center + offsets[i], unit)
		if pos == Vector3.INF:
			pos = retreat_center
		if unit.has_method("issue_retreat_order"):
			unit.issue_retreat_order(pos)
	_show_command_marker(retreat_center, false)
	_set_battle_status("Retreat order issued.")

func _find_nearest_retreat_point_for_unit(unit) -> Vector3:
	if unit == null or not is_instance_valid(unit):
		return Vector3.INF
	var candidates: Array = []
	if _strategy_map_view != null and is_instance_valid(_strategy_map_view) and _strategy_map_view.has_method("get_team_retreat_points"):
		var is_player_team: bool = int(unit.team_id) == 0
		candidates = _strategy_map_view.call("get_team_retreat_points", is_player_team)
	var best: Vector3 = Vector3.INF
	var best_dist: float = INF
	for p_any in candidates:
		if not (p_any is Vector3):
			continue
		var p: Vector3 = _resolve_walkable_command_point(p_any, unit)
		if p == Vector3.INF:
			continue
		var d: float = unit.global_position.distance_squared_to(p)
		if d < best_dist:
			best_dist = d
			best = p
	if best != Vector3.INF:
		return best
	var fallback: Vector3 = spawn_center + Vector3(0.0, 0.0, team_front_offset_z * 2.2 * (-1.0 if int(unit.team_id) == 0 else 1.0))
	return _resolve_walkable_command_point(fallback, unit)

func _setup_command_markers() -> void:
	command_marker_move = _create_command_marker(Color(0.2, 0.95, 0.35, 0.92), maxf(0.4, command_marker_move_radius))
	command_marker_attack = _create_command_marker(Color(1.0, 0.22, 0.2, 0.94), maxf(0.4, command_marker_attack_radius))

func _create_command_marker(color: Color, radius: float) -> MeshInstance3D:
	var marker := MeshInstance3D.new()
	marker.name = "CommandMarker"
	marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.045
	mesh.radial_segments = 36
	marker.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = Color(color.r, color.g, color.b, 1.0)
	mat.emission_energy_multiplier = 1.3
	marker.material_override = mat
	marker.visible = false
	add_child(marker)
	return marker

func _show_command_marker(world_pos: Vector3, is_attack: bool) -> void:
	if is_attack and not command_marker_show_attack:
		return
	var marker: MeshInstance3D = command_marker_attack if is_attack else command_marker_move
	if marker == null or not is_instance_valid(marker):
		return
	marker.visible = true
	marker.global_position = Vector3(world_pos.x, world_pos.y + 0.06, world_pos.z)
	if is_attack:
		command_marker_attack_timer = maxf(0.05, command_marker_attack_duration)
	else:
		command_marker_move_timer = maxf(0.05, command_marker_move_duration)

func _update_command_markers(delta: float) -> void:
	if command_marker_move != null and is_instance_valid(command_marker_move):
		if command_marker_move_timer > 0.0:
			command_marker_move_timer = maxf(0.0, command_marker_move_timer - delta)
			var t: float = command_marker_move_timer / maxf(0.05, command_marker_move_duration)
			command_marker_move.scale = Vector3.ONE * (0.85 + (1.0 - t) * 0.22)
		else:
			command_marker_move.visible = false
	if command_marker_attack != null and is_instance_valid(command_marker_attack):
		if command_marker_attack_timer > 0.0:
			command_marker_attack_timer = maxf(0.0, command_marker_attack_timer - delta)
			var t2: float = command_marker_attack_timer / maxf(0.05, command_marker_attack_duration)
			command_marker_attack.scale = Vector3.ONE * (0.88 + (1.0 - t2) * 0.28)
		else:
			command_marker_attack.visible = false

func _project_to_nav_surface(world_pos: Vector3) -> Vector3:
	var map_rid: RID = get_world_3d().navigation_map
	if map_rid.is_valid():
		var iter_id: int = NavigationServer3D.map_get_iteration_id(map_rid)
		if iter_id > 0:
			return NavigationServer3D.map_get_closest_point(map_rid, world_pos)
	return world_pos

func _resolve_walkable_command_point(world_pos: Vector3, unit = null) -> Vector3:
	# Keep click direction intuitive: use clicked point first, only repair if blocked.
	if _is_walkable_point(world_pos, unit):
		return world_pos
	var repaired: Vector3 = _find_nearest_walkable_point(world_pos, unit)
	if repaired != Vector3.INF:
		return repaired
	var projected: Vector3 = _project_to_nav_surface(world_pos)
	if _is_walkable_point(projected, unit):
		return projected
	return Vector3.INF

func _is_walkable_point(world_pos: Vector3, unit = null) -> bool:
	if _strategy_map_view == null or not is_instance_valid(_strategy_map_view):
		return true
	if unit != null and demo_naval_enabled:
		return _can_unit_walk_with_naval_rules(unit, world_pos)
	if _strategy_map_view.has_method("can_unit_walk_at_world"):
		return bool(_strategy_map_view.call("can_unit_walk_at_world", world_pos))
	return true

func _find_nearest_walkable_point(center: Vector3, unit = null) -> Vector3:
	if _is_walkable_point(center, unit):
		return center
	var best: Vector3 = Vector3.INF
	var best_dist_sq: float = INF
	for radius in MOVE_REPAIR_RADII:
		for i in range(MOVE_REPAIR_DIRECTIONS):
			var angle: float = TAU * (float(i) / float(MOVE_REPAIR_DIRECTIONS))
			var probe := center + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
			probe = _project_to_nav_surface(probe)
			if not _is_walkable_point(probe, unit):
				continue
			var dist_sq: float = center.distance_squared_to(probe)
			if dist_sq < best_dist_sq:
				best_dist_sq = dist_sq
				best = probe
		if best != Vector3.INF:
			return best
	return Vector3.INF

func _relocate_unit_to_walkable_spawn(unit) -> void:
	if unit == null or not is_instance_valid(unit) or _strategy_map_view == null or not is_instance_valid(_strategy_map_view):
		return
	var origin: Vector3 = unit.global_position
	if _is_walkable_point(origin, unit):
		return
	var fixed: Vector3 = resolve_walkable_point_near(origin, 96.0, unit)
	if fixed == Vector3.INF:
		fixed = _resolve_walkable_command_point(origin, unit)
	if fixed == Vector3.INF:
		return
	unit.global_position = Vector3(fixed.x, _terrain_height_at_world(fixed), fixed.z)
	if unit.has_method("_update_ground_alignment"):
		unit.call("_update_ground_alignment", 0.0, true)

func can_unit_walk_at_world(world_pos: Vector3, unit = null) -> bool:
	return _is_walkable_point(world_pos, unit)

func terrain_height_at_world(world_pos: Vector3) -> float:
	return _terrain_height_at_world(world_pos)

func terrain_slope_deg_at_world(world_pos: Vector3) -> float:
	if _strategy_map_view != null and is_instance_valid(_strategy_map_view) and _strategy_map_view.has_method("terrain_slope_deg_at_world"):
		return float(_strategy_map_view.call("terrain_slope_deg_at_world", world_pos))
	return 0.0

func resolve_walkable_point(world_pos: Vector3, unit = null) -> Vector3:
	return _resolve_walkable_command_point(world_pos, unit)

func resolve_walkable_point_near(world_pos: Vector3, max_radius: float = 3.0, unit = null) -> Vector3:
	if _is_walkable_point(world_pos, unit):
		return world_pos
	var max_r: float = maxf(0.5, max_radius)
	var probe_step: float = 0.8
	var r: float = probe_step
	while r <= max_r + 0.001:
		for i in range(MOVE_REPAIR_DIRECTIONS):
			var angle: float = TAU * (float(i) / float(MOVE_REPAIR_DIRECTIONS))
			var probe := world_pos + Vector3(cos(angle) * r, 0.0, sin(angle) * r)
			probe = _project_to_nav_surface(probe)
			if _is_walkable_point(probe, unit):
				return probe
		r += probe_step
	return Vector3.INF

func _normalize_ship_type_id(raw_type: String) -> String:
	var ship_type: String = raw_type.strip_edges().to_lower()
	match ship_type:
		"", "default":
			return ""
		"zouge", "small", "light", "walkboat", "zoug":
			return "zouge"
		"lou", "louchuan", "lou_chuan", "tower", "tower_ship", "advanced", "doujian", "mengchong":
			return "lou_chuan"
		_:
			return ship_type

func _is_advanced_ship_type(ship_type: String) -> bool:
	var normalized: String = _normalize_ship_type_id(ship_type)
	return not normalized.is_empty() and normalized != "zouge"

func _is_water_terrain_type(terrain_type: String) -> bool:
	return terrain_type.strip_edges().to_lower() == WATER_TERRAIN_ID

func _unit_is_embarked(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	if unit.has_method("is_embarked"):
		return bool(unit.call("is_embarked"))
	return false

func _unit_preferred_ship_type(unit) -> String:
	if unit == null or not is_instance_valid(unit):
		return ""
	if unit.has_method("get_preferred_ship_type"):
		return _normalize_ship_type_id(String(unit.call("get_preferred_ship_type")))
	return ""

func _unit_embarked_ship_type(unit) -> String:
	if unit == null or not is_instance_valid(unit):
		return ""
	if unit.has_method("get_embarked_ship_type"):
		return _normalize_ship_type_id(String(unit.call("get_embarked_ship_type")))
	return ""

func _resolve_unit_default_ship_type(unit) -> String:
	var role_id: String = _unit_role_id(unit)
	if demo_naval_default_ship_type_by_role.has(role_id):
		return _normalize_ship_type_id(String(demo_naval_default_ship_type_by_role.get(role_id, demo_naval_default_ship_type)))
	return _normalize_ship_type_id(demo_naval_default_ship_type)

func _unit_effective_ship_type(unit) -> String:
	var embarked_ship: String = _unit_embarked_ship_type(unit)
	if not embarked_ship.is_empty():
		return embarked_ship
	var preferred_ship: String = _unit_preferred_ship_type(unit)
	if not preferred_ship.is_empty():
		return preferred_ship
	var default_ship: String = _resolve_unit_default_ship_type(unit)
	if unit != null and is_instance_valid(unit) and unit.has_method("set_preferred_ship_type"):
		unit.call("set_preferred_ship_type", default_ship)
	return default_ship

func _set_unit_embarked_state(unit, active: bool, ship_type: String = "") -> void:
	if unit == null or not is_instance_valid(unit):
		return
	if not unit.has_method("set_embarked_state"):
		return
	unit.call("set_embarked_state", active, _normalize_ship_type_id(ship_type))

func _is_ferry_site_snapshot(site: Dictionary) -> bool:
	var site_type: String = String(site.get("type", "")).strip_edges().to_lower()
	if site_type == "ferry":
		return true
	var site_id: String = String(site.get("id", "")).strip_edges().to_lower()
	if site_id.begins_with("ferry_"):
		return true
	return site_id.find("_jin") >= 0 or site_id.find("_gang") >= 0

func _site_world_pos(site: Dictionary) -> Vector3:
	var pos_any: Variant = site.get("position", {})
	var x: float = 0.0
	var z: float = 0.0
	if pos_any is Dictionary:
		var pos: Dictionary = pos_any as Dictionary
		x = float(pos.get("x", site.get("x", 0.0)))
		z = float(pos.get("z", site.get("z", pos.get("y", 0.0))))
	else:
		x = float(site.get("x", 0.0))
		z = float(site.get("z", site.get("y", 0.0)))
	return Vector3(x, _terrain_height_at_world(Vector3(x, 0.0, z)), z)

func _ensure_naval_ferry_cache() -> void:
	if _demo_naval_ferry_cache_ready and not _demo_naval_ferry_points.is_empty():
		return
	_demo_naval_ferry_points.clear()
	if _strategy_map_view != null and is_instance_valid(_strategy_map_view) and _strategy_map_view.has_method("get_all_site_snapshots"):
		var all_sites_any: Variant = _strategy_map_view.call("get_all_site_snapshots")
		if all_sites_any is Array:
			for site_any in all_sites_any:
				if not (site_any is Dictionary):
					continue
				var site: Dictionary = site_any
				if not _is_ferry_site_snapshot(site):
					continue
				_demo_naval_ferry_points.append(_site_world_pos(site))
	_demo_naval_ferry_cache_ready = true

func _is_ferry_at_world(world_pos: Vector3) -> bool:
	_ensure_naval_ferry_cache()
	if _demo_naval_ferry_points.is_empty():
		return false
	var max_dist_sq: float = maxf(1.0, demo_naval_ferry_radius) * maxf(1.0, demo_naval_ferry_radius)
	for ferry_pos in _demo_naval_ferry_points:
		var d: Vector3 = ferry_pos - world_pos
		d.y = 0.0
		if d.length_squared() <= max_dist_sq:
			return true
	return false

func _is_shoal_at_world(world_pos: Vector3) -> bool:
	if _is_water_terrain_type(_terrain_type_at_world(world_pos)):
		return false
	var probe_radius: float = maxf(0.5, demo_naval_shoal_radius)
	for ring_mul in [0.5, 1.0]:
		var ring_radius: float = probe_radius * float(ring_mul)
		for i in range(12):
			var angle: float = TAU * (float(i) / 12.0)
			var sample: Vector3 = world_pos + Vector3(cos(angle) * ring_radius, 0.0, sin(angle) * ring_radius)
			if _is_water_terrain_type(_terrain_type_at_world(sample)):
				return true
	return false

func _unit_can_embark_at_world(unit, world_pos: Vector3, ship_type: String) -> bool:
	var normalized: String = _normalize_ship_type_id(ship_type)
	if normalized.is_empty():
		normalized = _unit_effective_ship_type(unit)
	if _is_water_terrain_type(_terrain_type_at_world(world_pos)):
		return true
	if _is_ferry_at_world(world_pos):
		return true
	if _is_advanced_ship_type(normalized):
		return false
	return _is_shoal_at_world(world_pos)

func _unit_can_disembark_at_world(unit, world_pos: Vector3, ship_type: String) -> bool:
	var normalized: String = _normalize_ship_type_id(ship_type)
	if normalized.is_empty():
		normalized = _unit_effective_ship_type(unit)
	if _is_water_terrain_type(_terrain_type_at_world(world_pos)):
		return false
	if _is_ferry_at_world(world_pos):
		return true
	if _is_advanced_ship_type(normalized):
		return false
	return _is_shoal_at_world(world_pos)

func _can_unit_walk_with_naval_rules(unit, world_pos: Vector3) -> bool:
	var base_walkable: bool = true
	if _strategy_map_view != null and is_instance_valid(_strategy_map_view) and _strategy_map_view.has_method("can_unit_walk_at_world"):
		base_walkable = bool(_strategy_map_view.call("can_unit_walk_at_world", world_pos))
	if not demo_naval_enabled or unit == null or not is_instance_valid(unit):
		return base_walkable
	var target_terrain: String = _terrain_type_at_world(world_pos)
	var is_water_target: bool = _is_water_terrain_type(target_terrain)
	var embarked: bool = _unit_is_embarked(unit)
	if embarked:
		if is_water_target:
			return true
		return base_walkable and _unit_can_disembark_at_world(unit, world_pos, _unit_effective_ship_type(unit))
	if is_water_target:
		if not demo_naval_auto_embark:
			return false
		return _unit_can_embark_at_world(unit, unit.global_position, _unit_effective_ship_type(unit))
	return base_walkable

func _line_crosses_water(start_pos: Vector3, end_pos: Vector3) -> bool:
	var delta: Vector3 = end_pos - start_pos
	delta.y = 0.0
	var dist: float = delta.length()
	if dist <= 0.001:
		return false
	var step: float = maxf(1.0, demo_naval_shoal_radius)
	var steps: int = maxi(1, int(ceil(dist / step)))
	for i in range(1, steps):
		var t: float = float(i) / float(steps)
		var sample: Vector3 = start_pos.lerp(end_pos, t)
		if _is_water_terrain_type(_terrain_type_at_world(sample)):
			return true
	return false

func is_unit_naval_direct_path_required(unit, goal_world: Vector3) -> bool:
	if not demo_naval_enabled or unit == null or not is_instance_valid(unit):
		return false
	if _unit_is_embarked(unit):
		return true
	var start_pos: Vector3 = unit.global_position
	if _is_water_terrain_type(_terrain_type_at_world(start_pos)):
		return true
	if _is_water_terrain_type(_terrain_type_at_world(goal_world)):
		return true
	return _line_crosses_water(start_pos, goal_world)

func sync_unit_naval_state(unit) -> void:
	if not demo_naval_enabled or unit == null or not is_instance_valid(unit):
		return
	var is_water_now: bool = _is_water_terrain_type(_terrain_type_at_world(unit.global_position))
	var embarked: bool = _unit_is_embarked(unit)
	var ship_type: String = _unit_effective_ship_type(unit)
	if is_water_now and not embarked and demo_naval_auto_embark:
		_set_unit_embarked_state(unit, true, ship_type)
	elif (not is_water_now) and embarked:
		_set_unit_embarked_state(unit, false, ship_type)

func _finalize_unit_naval_state_after_move(unit, from_pos: Vector3, to_pos: Vector3) -> void:
	if not demo_naval_enabled or unit == null or not is_instance_valid(unit):
		return
	var from_water: bool = _is_water_terrain_type(_terrain_type_at_world(from_pos))
	var to_water: bool = _is_water_terrain_type(_terrain_type_at_world(to_pos))
	if from_water == to_water:
		return
	var ship_type: String = _unit_effective_ship_type(unit)
	var embarked: bool = _unit_is_embarked(unit)
	if to_water and not embarked:
		if demo_naval_auto_embark and _unit_can_embark_at_world(unit, from_pos, ship_type):
			_set_unit_embarked_state(unit, true, ship_type)
	elif from_water and (not to_water) and embarked:
		if _unit_can_disembark_at_world(unit, to_pos, ship_type):
			_set_unit_embarked_state(unit, false, ship_type)

func _nearest_ferry_point_to(world_pos: Vector3) -> Vector3:
	_ensure_naval_ferry_cache()
	if _demo_naval_ferry_points.is_empty():
		return Vector3.INF
	var best: Vector3 = Vector3.INF
	var best_dist_sq: float = INF
	for ferry_pos in _demo_naval_ferry_points:
		var d: Vector3 = ferry_pos - world_pos
		d.y = 0.0
		var dist_sq: float = d.length_squared()
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best = ferry_pos
	return best

func _move_plan_result(ok: bool, first_target: Vector3, next_targets: Array[Vector3], reason: String = "") -> Dictionary:
	return {
		"ok": ok,
		"first_target": first_target,
		"next_targets": next_targets.duplicate(),
		"reason": reason
	}

func plan_unit_move_targets(unit, requested_world_pos: Vector3) -> Dictionary:
	var desired: Vector3 = requested_world_pos
	if unit != null and is_instance_valid(unit):
		desired = Vector3(desired.x, unit.global_position.y, desired.z)
	var direct_target: Vector3 = _resolve_walkable_command_point(desired, unit)
	if unit == null or not is_instance_valid(unit) or not demo_naval_enabled:
		return _move_plan_result(direct_target != Vector3.INF, direct_target, [], "blocked")
	var ship_type: String = _unit_effective_ship_type(unit)
	var advanced_ship: bool = _is_advanced_ship_type(ship_type)
	if not advanced_ship:
		return _move_plan_result(direct_target != Vector3.INF, direct_target, [], "blocked")
	var start_pos: Vector3 = unit.global_position
	var embarked: bool = _unit_is_embarked(unit)
	var target_is_water: bool = _is_water_terrain_type(_terrain_type_at_world(desired))
	var path_crosses_water: bool = _line_crosses_water(start_pos, desired)
	var first_stage: Vector3 = Vector3.INF
	var staged_targets: Array[Vector3] = []
	if embarked:
		if target_is_water or _unit_can_disembark_at_world(unit, desired, ship_type):
			return _move_plan_result(direct_target != Vector3.INF, direct_target, [], "blocked")
		first_stage = _nearest_ferry_point_to(desired)
		if first_stage == Vector3.INF:
			return _move_plan_result(false, Vector3.INF, [], "no_ferry_for_disembark")
		staged_targets.append(desired)
	else:
		if not target_is_water and not path_crosses_water:
			return _move_plan_result(direct_target != Vector3.INF, direct_target, [], "blocked")
		first_stage = _nearest_ferry_point_to(start_pos)
		if first_stage == Vector3.INF:
			return _move_plan_result(false, Vector3.INF, [], "no_ferry_for_embark")
		if target_is_water:
			staged_targets.append(desired)
		else:
			var disembark_ferry: Vector3 = _nearest_ferry_point_to(desired)
			if disembark_ferry == Vector3.INF:
				return _move_plan_result(false, Vector3.INF, [], "no_ferry_for_disembark")
			staged_targets.append(disembark_ferry)
			staged_targets.append(desired)
	var resolved_first: Vector3 = _resolve_walkable_command_point(first_stage, unit)
	if resolved_first == Vector3.INF:
		return _move_plan_result(false, Vector3.INF, [], "no_land_path_to_ferry")
	return _move_plan_result(true, resolved_first, staged_targets, "")

func _find_unit_near_point(world_point: Vector3, team_id: int, radius: float, observer_team_id: int = -1):
	var best = null
	var best_dist_sq: float = radius * radius
	for unit in units:
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		if team_id >= 0 and unit.team_id != team_id:
			continue
		if observer_team_id >= 0 and int(unit.team_id) != observer_team_id and not is_enemy_targetable_for_team(observer_team_id, unit):
			continue
		var d: Vector3 = unit.global_position - world_point
		d.y = 0.0
		var dist_sq: float = d.length_squared()
		if dist_sq <= best_dist_sq:
			best_dist_sq = dist_sq
			best = unit
	return best

func _set_selected_unit(unit) -> void:
	selected_units.clear()
	if _can_player_direct_unit(unit):
		selected_units.append(unit)
	selected_unit = unit if _can_player_direct_unit(unit) else null
	inspected_unit = selected_unit
	_cancel_build_placement()
	_set_build_menu_visible(false)
	unit_tag_force_refresh = true
	_refresh_selection_ui_state()

func _set_selected_units(new_units: Array) -> void:
	selected_units.clear()
	for unit in new_units:
		if not _can_player_direct_unit(unit):
			continue
		if selected_units.has(unit):
			continue
		selected_units.append(unit)
	selected_unit = selected_units[0] if not selected_units.is_empty() else null
	inspected_unit = selected_unit
	_cancel_build_placement()
	_set_build_menu_visible(false)
	unit_tag_force_refresh = true
	_refresh_selection_ui_state()

func _set_inspected_enemy_unit(unit) -> void:
	selected_units.clear()
	selected_unit = null
	inspected_unit = unit if unit != null and is_instance_valid(unit) and not unit.dead else null
	pending_ground_command = ""
	_cancel_build_placement()
	_set_build_menu_visible(false)
	unit_tag_force_refresh = true
	_refresh_selection_ui_state()

func _get_selected_command_unit():
	if _can_player_direct_unit(selected_unit):
		return selected_unit
	return null

func _refresh_battle_camera_input_lock() -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam is BattleCameraController:
		battle_camera_ref = cam as BattleCameraController
	if battle_camera_ref != null and is_instance_valid(battle_camera_ref):
		battle_camera_ref.set_movement_input_enabled(_get_selected_command_unit() == null)

func _refresh_selection_ui_state() -> void:
	if _get_selected_command_unit() == null:
		pending_ground_command = ""
		_set_build_menu_visible(false)
	_refresh_battle_camera_input_lock()
	if rts_panel_root != null and is_instance_valid(rts_panel_root):
		rts_panel_root.visible = _get_selected_command_unit() != null
	_update_build_menu_availability()
	_update_rts_panel_buttons()
	_sync_strategy_map_supply_route_focus()

func _sync_strategy_map_supply_route_focus() -> void:
	if _strategy_map_view == null or not is_instance_valid(_strategy_map_view):
		return
	if not _strategy_map_view.has_method("set_supply_route_focus_unit"):
		return
	_strategy_map_view.call("set_supply_route_focus_unit", _get_selected_command_unit())

func _sync_strategy_map_build_preview(world_pos: Vector3) -> void:
	if _strategy_map_view == null or not is_instance_valid(_strategy_map_view):
		return
	if _pending_build_action_id.is_empty():
		if _strategy_map_view.has_method("clear_supply_route_build_preview"):
			_strategy_map_view.call("clear_supply_route_build_preview")
		return
	if not _strategy_map_view.has_method("set_supply_route_build_preview"):
		return
	_strategy_map_view.call("set_supply_route_build_preview", _pending_build_action_id, world_pos, _get_selected_command_unit())

func _clear_strategy_map_build_preview() -> void:
	if _strategy_map_view == null or not is_instance_valid(_strategy_map_view):
		return
	if _strategy_map_view.has_method("clear_supply_route_build_preview"):
		_strategy_map_view.call("clear_supply_route_build_preview")

func _update_auto_engage_orders() -> void:
	if not enemy_auto_engage_enabled:
		return
	for unit in units:
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		if unit.team_id == 0:
			continue
		if unit.target_unit != null and is_instance_valid(unit.target_unit) and not unit.target_unit.dead:
			continue
		if unit.state == UnitController.UnitState.SKILL_FORM or unit.state == UnitController.UnitState.SKILL_EXEC:
			continue
		if unit.has_method("can_auto_engage") and not bool(unit.call("can_auto_engage")):
			continue
		if unit.has_move_target:
			continue
		if _should_force_demo_siege_ai_only_facility(unit):
			continue
		var enemy = _get_closest_enemy_in_range(unit, auto_engage_max_distance)
		if enemy == null:
			continue
		unit.issue_attack_order(enemy)

func _tick_auto_release(delta: float) -> void:
	if delta <= 0.0:
		return
	_tick_famous_auto_cooldowns(delta)
	_tick_famous_skill_cooldowns(delta)
	if not auto_release_enabled:
		return
	auto_release_timer -= delta
	if auto_release_timer > 0.0:
		return
	auto_release_timer = maxf(0.18, auto_release_eval_interval)
	for unit_any in units:
		if unit_any == null or not is_instance_valid(unit_any) or unit_any.dead:
			continue
		if not _can_player_direct_unit(unit_any):
			continue
		if _is_skill_auto_enabled(unit_any):
			_try_auto_cast_skill_for_unit(unit_any)
		if _is_famous_auto_enabled(unit_any):
			_try_auto_cast_famous_for_unit(unit_any)

func _tick_famous_auto_cooldowns(delta: float) -> void:
	if famous_auto_cooldowns.is_empty():
		return
	var remove_keys: Array[int] = []
	for key_any in famous_auto_cooldowns.keys():
		var key: int = int(key_any)
		var left: float = maxf(0.0, float(famous_auto_cooldowns.get(key, 0.0)) - maxf(0.0, delta))
		if left <= 0.001:
			remove_keys.append(key)
		else:
			famous_auto_cooldowns[key] = left
	for key in remove_keys:
		famous_auto_cooldowns.erase(key)

func _tick_famous_skill_cooldowns(delta: float) -> void:
	if famous_skill_cooldowns.is_empty():
		return
	var remove_keys: Array[int] = []
	for key_any in famous_skill_cooldowns.keys():
		var key: int = int(key_any)
		var left: float = maxf(0.0, float(famous_skill_cooldowns.get(key, 0.0)) - maxf(0.0, delta))
		if left <= 0.001:
			remove_keys.append(key)
		else:
			famous_skill_cooldowns[key] = left
	for key in remove_keys:
		famous_skill_cooldowns.erase(key)

func _is_unit_busy_casting(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	return int(unit.get("skill_type")) != int(UnitController.SkillType.NONE)

func _read_unit_will(unit) -> float:
	if unit == null or not is_instance_valid(unit):
		return 0.0
	if unit.has_method("get_current_will"):
		return float(unit.call("get_current_will"))
	if unit.has_method("get_current_spirit"):
		return float(unit.call("get_current_spirit"))
	return 0.0

func _read_unit_will_cap(unit) -> float:
	if unit == null or not is_instance_valid(unit):
		return 100.0
	return maxf(1.0, float(unit.get("spirit_cap_current")))

func _read_unit_hp_ratio(unit) -> float:
	if unit == null or not is_instance_valid(unit):
		return 1.0
	if unit.has_method("get_hp_ratio"):
		return float(unit.call("get_hp_ratio"))
	var hp: float = float(unit.get("hp"))
	var max_hp: float = maxf(1.0, float(unit.get("max_hp")))
	return clampf(hp / max_hp, 0.0, 1.0)

func _read_unit_recent_damage_ratio(unit) -> float:
	if unit == null or not is_instance_valid(unit):
		return 0.0
	if unit.has_method("get_recent_damage_ratio"):
		return float(unit.call("get_recent_damage_ratio"))
	return 0.0

func _is_target_in_cast_window(caster, target, dist_mul: float = 1.3) -> bool:
	if caster == null or not is_instance_valid(caster) or target == null or not is_instance_valid(target):
		return false
	var desired_dist: float = 8.0
	var role_id: String = _unit_role_id(caster)
	if (role_id == "archer" or role_id == "crossbow" or role_id == "siege") and caster.has_method("get_ranged_engage_center_distance"):
		desired_dist = float(caster.call("get_ranged_engage_center_distance", target))
	elif caster.has_method("get_melee_engage_center_distance"):
		desired_dist = float(caster.call("get_melee_engage_center_distance", target))
	var to_target: Vector3 = target.global_position - caster.global_position
	to_target.y = 0.0
	return to_target.length() <= maxf(2.0, desired_dist * maxf(0.8, dist_mul))

func _count_enemy_units_near(center: Vector3, radius: float, team_id: int) -> int:
	return get_enemies_in_radius(center, radius, team_id).size()

func _can_auto_cast_skill(unit, skill_id: int, require_target: bool) -> bool:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return false
	if unit.has_method("get_skill_cd_left"):
		if float(unit.call("get_skill_cd_left", skill_id)) > 0.001:
			return false
	var will_now: float = _read_unit_will(unit)
	var will_cap: float = _read_unit_will_cap(unit)
	var reserve: float = maxf(4.0, will_cap * clampf(auto_release_skill_will_reserve_ratio, 0.0, 0.8))
	var cost: float = float(unit.call("get_skill_will_cost_value", skill_id)) if unit.has_method("get_skill_will_cost_value") else 0.0
	if will_now + 0.001 < cost + reserve:
		return false
	if require_target and _resolve_locked_skill_target(unit) == null:
		return false
	return true

func _try_auto_cast_skill_for_unit(unit) -> void:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return
	if _is_unit_busy_casting(unit):
		return
	if int(unit.get("command_mode")) == int(UnitController.CommandMode.RETREAT):
		return
	if _unit_is_tactician(unit):
		_try_auto_cast_tactic_for_unit(unit)
		return
	var role_id: String = _unit_role_id(unit)
	var target = _resolve_locked_skill_target(unit)
	var hp_ratio: float = _read_unit_hp_ratio(unit)
	var recent_damage_ratio: float = _read_unit_recent_damage_ratio(unit)
	var close_enemy_count: int = _count_enemy_units_near(unit.global_position, 10.5, int(unit.team_id))
	if role_id == "shield":
		var guard_active: bool = bool(unit.call("has_shield_guard_active")) if unit.has_method("has_shield_guard_active") else false
		var heavy_pressure: bool = recent_damage_ratio >= auto_release_shield_damage_ratio_heavy or hp_ratio <= auto_release_shield_hp_ratio_heavy or close_enemy_count >= maxi(2, auto_release_shield_close_enemy_count_heavy)
		var light_pressure: bool = recent_damage_ratio >= auto_release_shield_damage_ratio_light or hp_ratio <= auto_release_shield_hp_ratio_light or close_enemy_count >= maxi(1, auto_release_shield_close_enemy_count_light)
		if heavy_pressure and _can_auto_cast_skill(unit, int(UnitController.SkillType.SWEEP), false):
			_try_cast_unit_skill(unit, int(UnitController.SkillType.SWEEP))
			return
		if light_pressure and not guard_active and _can_auto_cast_skill(unit, int(UnitController.SkillType.CHARGE), false):
			_try_cast_unit_skill(unit, int(UnitController.SkillType.CHARGE))
			return
		if target != null and _is_target_in_cast_window(unit, target, 1.35) and _can_auto_cast_skill(unit, int(UnitController.SkillType.BREAKTHROUGH), true):
			_try_cast_unit_skill(unit, int(UnitController.SkillType.BREAKTHROUGH))
			return
		return
	if target == null:
		return
	if role_id == "crossbow":
		var crossbow_cluster: int = _count_enemy_units_near(target.global_position, 5.8, int(unit.team_id))
		if _is_target_in_cast_window(unit, target, 1.52) and _can_auto_cast_skill(unit, int(UnitController.SkillType.BREAKTHROUGH), true):
			_try_cast_unit_skill(unit, int(UnitController.SkillType.BREAKTHROUGH))
			return
		if crossbow_cluster >= 2 and _can_auto_cast_skill(unit, int(UnitController.SkillType.SWEEP), true):
			_try_cast_unit_skill(unit, int(UnitController.SkillType.SWEEP))
			return
		if (recent_damage_ratio >= 0.03 or hp_ratio <= 0.82) and _can_auto_cast_skill(unit, int(UnitController.SkillType.CHARGE), true):
			_try_cast_unit_skill(unit, int(UnitController.SkillType.CHARGE))
			return
		return
	if role_id == "archer":
		var target_cluster: int = _count_enemy_units_near(target.global_position, 6.8, int(unit.team_id))
		if target_cluster >= 3 and _can_auto_cast_skill(unit, int(UnitController.SkillType.SWEEP), true):
			_try_cast_unit_skill(unit, int(UnitController.SkillType.SWEEP))
			return
		if _is_target_in_cast_window(unit, target, 1.45) and _can_auto_cast_skill(unit, int(UnitController.SkillType.BREAKTHROUGH), true):
			_try_cast_unit_skill(unit, int(UnitController.SkillType.BREAKTHROUGH))
			return
		if hp_ratio <= 0.9 and _can_auto_cast_skill(unit, int(UnitController.SkillType.CHARGE), true):
			_try_cast_unit_skill(unit, int(UnitController.SkillType.CHARGE))
			return
		return
	if hp_ratio <= 0.56 and _can_auto_cast_skill(unit, int(UnitController.SkillType.SWEEP), true):
		_try_cast_unit_skill(unit, int(UnitController.SkillType.SWEEP))
		return
	if _is_target_in_cast_window(unit, target, 1.32) and _can_auto_cast_skill(unit, int(UnitController.SkillType.BREAKTHROUGH), true):
		_try_cast_unit_skill(unit, int(UnitController.SkillType.BREAKTHROUGH))
		return
	if recent_damage_ratio >= 0.06 and _is_target_in_cast_window(unit, target, 1.22) and _can_auto_cast_skill(unit, int(UnitController.SkillType.CHARGE), true):
		_try_cast_unit_skill(unit, int(UnitController.SkillType.CHARGE))

func _can_auto_cast_tactic(unit, tactic_id: String) -> bool:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return false
	var id: String = _canonical_tactic_id(tactic_id)
	if id.is_empty():
		return false
	if _get_tactic_cd_left(unit, id) > 0.001:
		return false
	var cfg: Dictionary = _get_tactic_cfg(id)
	var will_now: float = _read_unit_will(unit)
	var will_cap: float = _read_unit_will_cap(unit)
	var reserve: float = maxf(4.0, will_cap * clampf(auto_release_skill_will_reserve_ratio, 0.0, 0.8))
	var cost: float = float(cfg.get("will_cost", cfg.get("spirit_cost", 0.0)))
	return will_now + 0.001 >= cost + reserve

func _try_auto_cast_tactic_priority(unit, owned_ids: Array[String], priority_ids: Array[String]) -> bool:
	for id in priority_ids:
		var tactic_id: String = _canonical_tactic_id(id)
		if not owned_ids.has(tactic_id):
			continue
		if not _can_auto_cast_tactic(unit, tactic_id):
			continue
		if _try_cast_tactic_by_id(unit, tactic_id):
			return true
	return false

func _try_auto_cast_tactic_for_unit(unit) -> void:
	var tactic_ids: Array[String] = _get_unit_tactic_ids(unit)
	if tactic_ids.is_empty():
		return
	var center_target = _resolve_locked_skill_target(unit)
	if center_target == null or not is_instance_valid(center_target) or center_target.dead:
		center_target = get_closest_enemy(unit)
	var target_cluster: int = 0
	if center_target != null and is_instance_valid(center_target) and not center_target.dead:
		target_cluster = _count_enemy_units_near(center_target.global_position, 8.2, int(unit.team_id))
	var close_enemy_count: int = _count_enemy_units_near(unit.global_position, 10.8, int(unit.team_id))
	var hp_ratio: float = _read_unit_hp_ratio(unit)
	var recent_damage_ratio: float = _read_unit_recent_damage_ratio(unit)
	var fire_blocked: bool = is_fire_blocked_by_weather()
	var thunder_weather_ok: bool = _is_thunder_cast_weather()
	var has_fire_tactic: bool = tactic_ids.has("strat_fire_attack") or tactic_ids.has("strat_skyfire")
	var has_thunder_tactic: bool = tactic_ids.has("strat_thunder") or tactic_ids.has("strat_thunder_lock")

	if tactic_ids.has("strat_weather_change") and _can_auto_cast_tactic(unit, "strat_weather_change"):
		if (fire_blocked and has_fire_tactic) or (not thunder_weather_ok and has_thunder_tactic):
			if _try_cast_tactic_by_id(unit, "strat_weather_change"):
				return
	if tactic_ids.has("strat_borrow_wind") and _can_auto_cast_tactic(unit, "strat_borrow_wind"):
		if not _is_wind_spread_weather() and has_fire_tactic and not fire_blocked:
			if _try_cast_tactic_by_id(unit, "strat_borrow_wind"):
				return

	if thunder_weather_ok and target_cluster >= 2:
		if _try_auto_cast_tactic_priority(unit, tactic_ids, ["strat_thunder_lock", "strat_thunder"]):
			return
	if not fire_blocked and target_cluster >= 2:
		if _try_auto_cast_tactic_priority(unit, tactic_ids, ["strat_skyfire", "strat_fire_attack"]):
			return
	if target_cluster >= 2 or close_enemy_count >= 3:
		if _try_auto_cast_tactic_priority(unit, tactic_ids, ["strat_dragon_bind", "strat_chain", "strat_trap", "strat_sow_discord", "strat_delay"]):
			return
	if hp_ratio <= 0.82 or recent_damage_ratio >= 0.05 or close_enemy_count >= 2:
		_try_auto_cast_tactic_priority(unit, tactic_ids, ["strat_cheer"])

func _try_auto_cast_famous_for_unit(unit) -> void:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return
	if _is_unit_busy_casting(unit):
		return
	if not _can_cast_famous_skill(unit):
		return
	var unit_id: int = unit.get_instance_id()
	if float(famous_auto_cooldowns.get(unit_id, 0.0)) > 0.001:
		return
	var will_now: float = _read_unit_will(unit)
	var will_cap: float = _read_unit_will_cap(unit)
	if will_now / maxf(1.0, will_cap) < clampf(auto_release_famous_min_will_ratio, 0.0, 1.0):
		return
	var cfg: Dictionary = _get_unique_skill_cfg_for_unit(unit)
	if cfg.is_empty() or not _should_auto_cast_unique_skill(unit, cfg):
		return
	if not _roll_auto_unique_skill_proc(unit, cfg):
		famous_auto_cooldowns[unit_id] = maxf(0.3, auto_release_famous_retry_sec)
		return
	_try_cast_famous_skill(unit)

func _roll_auto_unique_skill_proc(unit, cfg: Dictionary) -> bool:
	if unit == null or not is_instance_valid(unit) or cfg.is_empty():
		return false
	var template_id: String = str(cfg.get("effect_template", "")).strip_edges().to_lower()
	var rules: Dictionary = cfg.get("auto_cast_rules", {}) if cfg.get("auto_cast_rules", {}) is Dictionary else {}
	var chance: float = float(rules.get("auto_proc_chance", -1.0))
	if chance < 0.0:
		match template_id:
			"charge_break_line", "flank_dash_assault":
				chance = 0.52
			"frontal_cleave_pressure", "cone_roar_disrupt":
				chance = 0.42
			"area_fire_burst", "chain_fire_spread", "area_control_zone":
				chance = 0.36
			"team_aura_buff", "team_cdr_support", "morale_recover_cleanse":
				chance = 0.34
			_:
				chance = 0.38
	chance = clampf(chance, 0.0, 1.0)
	if chance >= 0.999:
		return true
	return randf() <= chance
func _get_closest_enemy_in_range(source, max_dist: float):
	if source == null or not is_instance_valid(source):
		return null
	var source_team: int = int(source.team_id)
	var max_dist_sq: float = max_dist * max_dist
	var best = null
	var best_dist_sq: float = max_dist_sq
	for enemy in units:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.dead or enemy.team_id == source_team:
			continue
		if not is_enemy_targetable_for_team(source_team, enemy):
			continue
		var d: Vector3 = enemy.global_position - source.global_position
		d.y = 0.0
		var dist_sq: float = d.length_squared()
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best = enemy
	return best

func _setup_unit_tags() -> void:
	unit_tag_layer = CanvasLayer.new()
	unit_tag_layer.name = "UnitTagLayer"
	add_child(unit_tag_layer)

	unit_tag_root = Control.new()
	unit_tag_root.name = "UnitTags"
	unit_tag_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	unit_tag_root.mouse_filter = Control.MOUSE_FILTER_PASS
	unit_tag_layer.add_child(unit_tag_root)
	_setup_commander_report_panel()
	_setup_siege_debug_panel()
	_setup_siege_objective_panel()
	_setup_commander_dialogue_hud()

func _apply_rts_panel_button_theme(btn: Button, min_width: float = 88.0) -> void:
	if btn == null or not is_instance_valid(btn):
		return
	btn.custom_minimum_size = Vector2(min_width, 38.0)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.focus_mode = Control.FOCUS_NONE
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_color_override("font_color", Color(0.86, 0.72, 0.42))
	btn.add_theme_color_override("font_hover_color", Color(0.98, 0.88, 0.64))
	btn.add_theme_color_override("font_pressed_color", Color(0.24, 0.19, 0.12))
	btn.add_theme_color_override("font_disabled_color", Color(0.44, 0.37, 0.28))
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_constant_override("h_separation", 8)
	if _tag_font != null:
		btn.add_theme_font_override("font", _tag_font)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.16, 0.19, 0.93)
	normal.border_color = Color(0.80, 0.65, 0.34, 0.96)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(10)
	normal.corner_detail = 12
	normal.shadow_color = Color(0.0, 0.0, 0.0, 0.34)
	normal.shadow_size = 3
	normal.shadow_offset = Vector2(0.0, 2.0)
	normal.anti_aliasing = true
	normal.anti_aliasing_size = 1.0
	var hover := normal.duplicate()
	hover.bg_color = Color(0.12, 0.25, 0.30, 0.95)
	hover.border_color = Color(0.93, 0.79, 0.46, 0.99)
	hover.set_border_width_all(3)
	hover.shadow_size = 4
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.07, 0.13, 0.16, 0.96)
	pressed.border_color = Color(0.95, 0.82, 0.52, 1.0)
	pressed.shadow_size = 1
	pressed.shadow_offset = Vector2(0.0, 1.0)
	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.06, 0.08, 0.08, 0.62)
	disabled.border_color = Color(0.33, 0.28, 0.20, 0.72)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", hover)
	btn.add_theme_stylebox_override("disabled", disabled)

func _apply_rts_panel_label_theme(label: Label, font_size: int, font_color: Color) -> void:
	if label == null or not is_instance_valid(label):
		return
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_font_size_override("font_size", font_size)
	if _tag_font != null:
		label.add_theme_font_override("font", _tag_font)

func _set_label_text_if_changed(label: Label, value: String) -> void:
	if label == null or not is_instance_valid(label):
		return
	if label.text == value:
		return
	label.text = value

func _setup_rts_panel() -> void:
	if unit_tag_layer == null:
		return
	var panel_instance: Node = RTS_PANEL_SCENE.instantiate()
	if not (panel_instance is Control):
		push_error("RTS command panel scene root must be Control.")
		return
	rts_panel_root = panel_instance as Control
	rts_panel_root.visible = false
	unit_tag_layer.add_child(rts_panel_root)

	var background_panel := rts_panel_root.get_node_or_null("Background") as Panel
	if background_panel != null:
		var frame := StyleBoxFlat.new()
		frame.bg_color = Color(0.06, 0.14, 0.16, 0.94)
		frame.border_color = Color(0.86, 0.72, 0.42, 0.98)
		frame.set_border_width_all(2)
		frame.set_corner_radius_all(10)
		frame.corner_detail = 14
		frame.shadow_color = Color(0.0, 0.0, 0.0, 0.40)
		frame.shadow_size = 8
		frame.shadow_offset = Vector2(0.0, 3.0)
		frame.anti_aliasing = true
		frame.anti_aliasing_size = 1.0
		background_panel.add_theme_stylebox_override("panel", frame)
	else:
		var background := rts_panel_root.get_node_or_null("Background") as TextureRect
		if background != null:
			background.texture = null
			background.modulate = Color(1.0, 1.0, 1.0, 0.0)

	var status_label := rts_panel_root.get_node_or_null("Content/Body/StatusLabel") as Label
	var unit_name_label := rts_panel_root.get_node_or_null("Content/Body/UnitNameLabel") as Label
	var slot_title := rts_panel_root.get_node_or_null("Content/Body/SlotTitleLabel") as Label
	var command_row := rts_panel_root.get_node_or_null("Content/Body/CommandRow") as HBoxContainer
	_apply_rts_panel_label_theme(status_label, 20, Color(0.86, 0.72, 0.42))
	_apply_rts_panel_label_theme(unit_name_label, 26, Color(0.94, 0.84, 0.62))
	_apply_rts_panel_label_theme(slot_title, 18, Color(0.86, 0.72, 0.42))

	var attack_move_btn := rts_panel_root.get_node_or_null("Content/Body/CommandRow/AttackMoveButton") as Button
	var stop_btn := rts_panel_root.get_node_or_null("Content/Body/CommandRow/StopButton") as Button
	var hold_btn := rts_panel_root.get_node_or_null("Content/Body/CommandRow/HoldButton") as Button
	var retreat_btn := rts_panel_root.get_node_or_null("Content/Body/CommandRow/RetreatButton") as Button
	var famous_btn := rts_panel_root.get_node_or_null("Content/Body/CommandRow/FamousSkillButton") as Button
	var slot_btn_1 := rts_panel_root.get_node_or_null("Content/Body/SlotRow/Slot1Button") as Button
	var slot_btn_2 := rts_panel_root.get_node_or_null("Content/Body/SlotRow/Slot2Button") as Button
	var slot_btn_3 := rts_panel_root.get_node_or_null("Content/Body/SlotRow/Slot3Button") as Button
	var build_btn: Button = null
	var skill_auto_btn: Button = null
	var famous_auto_btn: Button = null
	if command_row != null:
		build_btn = Button.new()
		build_btn.name = "BuildButton"
		build_btn.custom_minimum_size = Vector2(96.0, 34.0)
		build_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		command_row.add_child(build_btn)
		skill_auto_btn = Button.new()
		skill_auto_btn.name = "SkillAutoButton"
		skill_auto_btn.custom_minimum_size = Vector2(88.0, 34.0)
		skill_auto_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		command_row.add_child(skill_auto_btn)
		famous_auto_btn = Button.new()
		famous_auto_btn.name = "FamousAutoButton"
		famous_auto_btn.custom_minimum_size = Vector2(92.0, 34.0)
		famous_auto_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		command_row.add_child(famous_auto_btn)

	_apply_rts_panel_button_theme(attack_move_btn, 118.0)
	_apply_rts_panel_button_theme(stop_btn, 82.0)
	_apply_rts_panel_button_theme(hold_btn, 82.0)
	_apply_rts_panel_button_theme(retreat_btn, 82.0)
	_apply_rts_panel_button_theme(famous_btn, 92.0)
	_apply_rts_panel_button_theme(build_btn, 96.0)
	_apply_rts_panel_button_theme(skill_auto_btn, 88.0)
	_apply_rts_panel_button_theme(famous_auto_btn, 92.0)
	_apply_rts_panel_button_theme(slot_btn_1, 160.0)
	_apply_rts_panel_button_theme(slot_btn_2, 160.0)
	_apply_rts_panel_button_theme(slot_btn_3, 160.0)

	if attack_move_btn != null:
		attack_move_btn.pressed.connect(func() -> void:
			if _get_selected_command_unit() == null:
				return
			pending_ground_command = "attack_move"
			_set_battle_status("Attack-move ready. Right-click ground or enemy.")
			_update_rts_panel_buttons()
		)
	if stop_btn != null:
		stop_btn.pressed.connect(func() -> void:
			pending_ground_command = ""
			_issue_selected_stop()
			_update_rts_panel_buttons()
		)
	if hold_btn != null:
		hold_btn.pressed.connect(func() -> void:
			pending_ground_command = ""
			_issue_selected_hold_position()
			_update_rts_panel_buttons()
		)
	if retreat_btn != null:
		retreat_btn.pressed.connect(func() -> void:
			pending_ground_command = ""
			_issue_selected_retreat()
			_update_rts_panel_buttons()
		)
	if famous_btn != null:
		famous_btn.pressed.connect(func() -> void:
			var cmd_unit = _get_selected_command_unit()
			if cmd_unit == null:
				return
			pending_ground_command = ""
			_try_cast_famous_skill(cmd_unit)
			_update_rts_panel_buttons()
		)
	if build_btn != null:
		build_btn.pressed.connect(func() -> void:
			_toggle_build_menu()
			_update_rts_panel_buttons()
		)
	if skill_auto_btn != null:
		skill_auto_btn.pressed.connect(func() -> void:
			var cmd_unit = _get_selected_command_unit()
			if cmd_unit == null or not _unit_has_combat_skills(cmd_unit):
				return
			var unit_id: int = cmd_unit.get_instance_id()
			var enabled: bool = not bool(unit_skill_auto_mode.get(unit_id, false))
			unit_skill_auto_mode[unit_id] = enabled
			var mode_name: String = "Tactics" if _unit_is_tactician(cmd_unit) else "Combat Skills"
			_set_battle_status("%s Mode: %s" % [mode_name, ("Auto" if enabled else "Manual")])
			_update_rts_panel_buttons()
		)
	if famous_auto_btn != null:
		famous_auto_btn.pressed.connect(func() -> void:
			var cmd_unit = _get_selected_command_unit()
			if cmd_unit == null or not _unit_has_famous_skill(cmd_unit):
				return
			var unit_id: int = cmd_unit.get_instance_id()
			var enabled: bool = not bool(unit_famous_auto_mode.get(unit_id, false))
			unit_famous_auto_mode[unit_id] = enabled
			if not enabled:
				famous_auto_cooldowns.erase(unit_id)
			_set_battle_status("Unique Skill Mode: %s" % ("Auto" if enabled else "Manual"))
			_update_rts_panel_buttons()
		)

	var slot_buttons: Array = [slot_btn_1, slot_btn_2, slot_btn_3]
	for i in range(slot_buttons.size()):
		var slot_btn: Button = slot_buttons[i]
		if slot_btn == null:
			continue
		var slot_index: int = i
		slot_btn.pressed.connect(func() -> void:
			var cmd_unit = _get_selected_command_unit()
			if cmd_unit == null:
				return
			pending_ground_command = ""
			_try_cast_slot_action(cmd_unit, slot_index)
			_update_rts_panel_buttons()
		)

	rts_panel_widgets = {
		"status": status_label,
		"unit_name": unit_name_label,
		"slot_title": slot_title,
		"attack_move_btn": attack_move_btn,
		"stop_btn": stop_btn,
		"hold_btn": hold_btn,
		"retreat_btn": retreat_btn,
		"famous_btn": famous_btn,
		"build_btn": build_btn,
		"skill_auto_btn": skill_auto_btn,
		"famous_auto_btn": famous_auto_btn,
		"slot_buttons": slot_buttons
	}
	_setup_build_menu_panel()

func _setup_rts_hover_panel() -> void:
	if unit_tag_layer == null:
		return
	if rts_hover_panel_root != null and is_instance_valid(rts_hover_panel_root):
		rts_hover_panel_root.queue_free()
	rts_hover_panel_widgets.clear()
	_hovered_unit = null
	_hover_candidate_unit = null
	_hover_candidate_elapsed = 0.0
	_hover_panel_timer = 0.0
	_hover_content_refresh_timer = 0.0
	var panel_instance: Node = RTS_HOVER_PANEL_SCENE.instantiate()
	if not (panel_instance is Control):
		push_error("RTS hover panel scene root must be Control.")
		return
	rts_hover_panel_root = panel_instance as Control
	rts_hover_panel_root.visible = false
	rts_hover_panel_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	unit_tag_layer.add_child(rts_hover_panel_root)

	var background_panel := rts_hover_panel_root.get_node_or_null("Background") as Panel
	if background_panel != null:
		var frame := StyleBoxFlat.new()
		frame.bg_color = Color(0.20, 0.24, 0.26, 0.72)
		frame.border_color = Color(0.86, 0.78, 0.62, 0.78)
		frame.set_border_width_all(2)
		frame.set_corner_radius_all(10)
		frame.corner_detail = 14
		frame.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
		frame.shadow_size = 4
		frame.shadow_offset = Vector2(0.0, 2.0)
		frame.anti_aliasing = true
		frame.anti_aliasing_size = 1.0
		background_panel.add_theme_stylebox_override("panel", frame)

	var unit_name_label := rts_hover_panel_root.get_node_or_null("Content/Body/HeaderRow/UnitNameLabel") as Label
	var role_label := rts_hover_panel_root.get_node_or_null("Content/Body/HeaderRow/RoleLabel") as Label
	var sub_info_label := rts_hover_panel_root.get_node_or_null("Content/Body/SubInfoLabel") as Label
	var type_apt_label := rts_hover_panel_root.get_node_or_null("Content/Body/TypeAptLabel") as Label
	var officer_title_label := rts_hover_panel_root.get_node_or_null("Content/Body/SplitRow/LeftCol/OfficerTitleLabel") as Label
	var officer_label := rts_hover_panel_root.get_node_or_null("Content/Body/SplitRow/LeftCol/OfficerLabel") as Label
	var stat_title_label := rts_hover_panel_root.get_node_or_null("Content/Body/SplitRow/LeftCol/StatTitleLabel") as Label
	var stat_label := rts_hover_panel_root.get_node_or_null("Content/Body/SplitRow/LeftCol/StatLabel") as Label
	var total_five_title_label := rts_hover_panel_root.get_node_or_null("Content/Body/SplitRow/RightCol/TotalFiveTitleLabel") as Label
	var total_five_label := rts_hover_panel_root.get_node_or_null("Content/Body/SplitRow/RightCol/TotalFiveLabel") as Label
	var trait_label := rts_hover_panel_root.get_node_or_null("Content/Body/TraitLabel") as Label
	var status_label := rts_hover_panel_root.get_node_or_null("Content/Body/StatusLabel") as Label
	_apply_rts_panel_label_theme(unit_name_label, 21, Color(0.97, 0.94, 0.90))
	_apply_rts_panel_label_theme(role_label, 14, Color(0.89, 0.86, 0.78))
	_apply_rts_panel_label_theme(sub_info_label, 12, Color(0.90, 0.93, 0.94))
	_apply_rts_panel_label_theme(type_apt_label, 12, Color(0.90, 0.91, 0.86))
	_apply_rts_panel_label_theme(officer_title_label, 12, Color(0.93, 0.90, 0.82))
	_apply_rts_panel_label_theme(stat_title_label, 12, Color(0.93, 0.90, 0.82))
	_apply_rts_panel_label_theme(total_five_title_label, 12, Color(0.93, 0.90, 0.82))
	_apply_rts_panel_label_theme(stat_label, 12, Color(0.93, 0.93, 0.90))
	_apply_rts_panel_label_theme(officer_label, 12, Color(0.92, 0.95, 0.95))
	_apply_rts_panel_label_theme(total_five_label, 12, Color(0.93, 0.93, 0.90))
	_apply_rts_panel_label_theme(trait_label, 12, Color(0.92, 0.95, 0.95))
	_apply_rts_panel_label_theme(status_label, 12, Color(0.92, 0.95, 0.95))
	if unit_name_label != null:
		unit_name_label.size_flags_horizontal = Control.SIZE_FILL
	if role_label != null:
		role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	if officer_title_label != null:
		officer_title_label.text = "武将"
	if stat_title_label != null:
		stat_title_label.text = "部队五维"
	if total_five_title_label != null:
		total_five_title_label.text = "部队属性"
	if type_apt_label != null:
		type_apt_label.visible = false
	if trait_label != null:
		trait_label.visible = false

	rts_hover_panel_widgets = {
		"name_label": unit_name_label,
		"role_label": role_label,
		"sub_info_label": sub_info_label,
		"type_apt_label": type_apt_label,
		"stat_label": stat_label,
		"officer_label": officer_label,
		"total_five_label": total_five_label,
		"trait_label": trait_label,
		"status_label": status_label
	}

func _update_rts_hover_panel(delta: float) -> void:
	if rts_hover_panel_root == null or not is_instance_valid(rts_hover_panel_root):
		return
	if not hover_panel_enabled:
		_reset_rts_hover_tracking(true)
		return
	var viewport := get_viewport()
	if viewport == null:
		_reset_rts_hover_tracking(true)
		return
	var mouse_pos: Vector2 = viewport.get_mouse_position()
	if is_left_drag_selecting or _is_build_placement_active() or _is_hover_pick_blocked(mouse_pos):
		_reset_rts_hover_tracking(true)
		return
	_hover_panel_timer -= maxf(0.0, delta)
	_hover_content_refresh_timer -= maxf(0.0, delta)
	if _hover_panel_timer > 0.0:
		if _is_hover_unit_valid(_hovered_unit):
			if _hover_content_refresh_timer <= 0.0:
				_refresh_rts_hover_panel(_hovered_unit)
				_hover_content_refresh_timer = maxf(0.08, hover_panel_content_refresh_interval)
			rts_hover_panel_root.visible = true
			_position_rts_hover_panel(mouse_pos)
		elif rts_hover_panel_root.visible:
			_reset_rts_hover_tracking(true)
		return
	var sample_step: float = maxf(0.04, hover_panel_update_interval)
	_hover_panel_timer = sample_step
	var hover_delay: float = maxf(0.0, hover_panel_show_delay_sec)
	var picked = _pick_unit_for_hover(mouse_pos)
	if not _is_hover_unit_valid(picked):
		_reset_rts_hover_tracking(true)
		return
	if picked != _hover_candidate_unit:
		_hover_candidate_unit = picked
		_hover_candidate_elapsed = 0.0
		if hover_delay <= 0.001:
			_hovered_unit = picked
			_refresh_rts_hover_panel(picked)
			_hover_content_refresh_timer = maxf(0.08, hover_panel_content_refresh_interval)
			rts_hover_panel_root.visible = true
			_position_rts_hover_panel(mouse_pos)
			return
		_hovered_unit = null
		rts_hover_panel_root.visible = false
		return
	_hover_candidate_elapsed += sample_step
	if _hover_candidate_elapsed + 0.0001 < hover_delay:
		rts_hover_panel_root.visible = false
		return
	var need_refresh: bool = _hovered_unit != picked or _hover_content_refresh_timer <= 0.0 or not rts_hover_panel_root.visible
	_hovered_unit = picked
	if need_refresh:
		_refresh_rts_hover_panel(picked)
		_hover_content_refresh_timer = maxf(0.08, hover_panel_content_refresh_interval)
	rts_hover_panel_root.visible = true
	_position_rts_hover_panel(mouse_pos)

func _reset_rts_hover_tracking(hide_panel: bool = true) -> void:
	_hovered_unit = null
	_hover_candidate_unit = null
	_hover_candidate_elapsed = 0.0
	_hover_content_refresh_timer = 0.0
	if hide_panel and rts_hover_panel_root != null and is_instance_valid(rts_hover_panel_root):
		rts_hover_panel_root.visible = false

func _is_hover_unit_valid(unit) -> bool:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return false
	if _can_player_direct_unit(unit):
		return true
	return _is_unit_visible_for_player_ui(unit)

func _is_hover_pick_blocked(screen_pos: Vector2) -> bool:
	if _is_screen_pos_over_control(rts_panel_root, screen_pos):
		return true
	if _is_screen_pos_over_control(_build_menu_panel, screen_pos):
		return true
	return false

func _is_screen_pos_over_control(node: Control, screen_pos: Vector2) -> bool:
	if node == null or not is_instance_valid(node) or not node.visible:
		return false
	var rect := Rect2(node.global_position, node.size)
	return rect.has_point(screen_pos)

func _pick_unit_for_hover(screen_pos: Vector2):
	var cached_pick = _pick_existing_hovered_unit(screen_pos)
	if _is_hover_unit_valid(cached_pick):
		return cached_pick
	var tag_pick = _pick_any_unit_by_tag_screen(screen_pos)
	if _is_hover_unit_valid(tag_pick):
		return tag_pick
	var screen_pick = _pick_any_unit_by_screen(screen_pos, hover_panel_pick_radius_px)
	if _is_hover_unit_valid(screen_pick):
		return screen_pick
	var hit: Dictionary = _raycast_screen(screen_pos)
	if hit.has("position"):
		var world_pick = _find_unit_near_point(hit["position"], -1, maxf(1.0, hover_panel_world_pick_radius), demo_recon_player_team_id)
		if _is_hover_unit_valid(world_pick):
			return world_pick
	return null

func _pick_existing_hovered_unit(screen_pos: Vector2):
	if not _is_hover_unit_valid(_hovered_unit):
		return null
	var hover_id: int = _hovered_unit.get_instance_id()
	var hover_card: Control = unit_tag_buttons.get(hover_id)
	if hover_card != null and is_instance_valid(hover_card) and hover_card.visible:
		var hover_rect := Rect2(hover_card.global_position, hover_card.size)
		if hover_rect.has_point(screen_pos):
			return _hovered_unit
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return null
	var world_pos: Vector3 = _hovered_unit.global_position + Vector3(0.0, maxf(0.6, unit_tag_height_offset * 0.35), 0.0)
	if camera.is_position_behind(world_pos):
		return null
	var screen_unit: Vector2 = camera.unproject_position(world_pos)
	var radius: float = maxf(8.0, hover_panel_pick_radius_px)
	if screen_unit.distance_squared_to(screen_pos) <= radius * radius:
		return _hovered_unit
	return null

func _pick_any_unit_by_tag_screen(screen_pos: Vector2):
	var best = null
	var best_dist: float = INF
	for id_any in unit_tag_buttons.keys():
		var unit = unit_tag_units.get(id_any)
		var card: Control = unit_tag_buttons.get(id_any)
		if not _is_hover_unit_valid(unit):
			continue
		if card == null or not is_instance_valid(card) or not card.visible:
			continue
		var rect := Rect2(card.global_position, card.size)
		if not rect.has_point(screen_pos):
			continue
		var dist: float = rect.get_center().distance_to(screen_pos)
		if dist < best_dist:
			best_dist = dist
			best = unit
	return best

func _pick_any_unit_by_screen(screen_pos: Vector2, radius_px: float):
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return null
	var best = null
	var best_dist_sq: float = maxf(8.0, radius_px) * maxf(8.0, radius_px)
	for unit in units:
		if not _is_hover_unit_valid(unit):
			continue
		var world_pos: Vector3 = unit.global_position + Vector3(0.0, maxf(0.6, unit_tag_height_offset * 0.35), 0.0)
		if camera.is_position_behind(world_pos):
			continue
		var screen_unit: Vector2 = camera.unproject_position(world_pos)
		var dist_sq: float = screen_unit.distance_squared_to(screen_pos)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best = unit
	return best

func _position_rts_hover_panel(screen_pos: Vector2) -> void:
	if rts_hover_panel_root == null or not is_instance_valid(rts_hover_panel_root):
		return
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var panel_size: Vector2 = rts_hover_panel_root.size
	if panel_size.x < 2.0 or panel_size.y < 2.0:
		panel_size = rts_hover_panel_root.custom_minimum_size
	var pos: Vector2 = screen_pos + hover_panel_screen_offset
	if pos.x + panel_size.x > viewport_rect.size.x - 8.0:
		pos.x = screen_pos.x - panel_size.x - 12.0
	if pos.y + panel_size.y > viewport_rect.size.y - 8.0:
		pos.y = viewport_rect.size.y - panel_size.y - 8.0
	pos.x = clampf(pos.x, 6.0, maxf(6.0, viewport_rect.size.x - panel_size.x - 6.0))
	pos.y = clampf(pos.y, 6.0, maxf(6.0, viewport_rect.size.y - panel_size.y - 6.0))
	rts_hover_panel_root.position = pos.round()

func _refresh_rts_hover_panel(unit) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	if rts_hover_panel_widgets.is_empty():
		return
	var panel_data: Dictionary = unit.call("get_rts_panel_data") if unit.has_method("get_rts_panel_data") else {}
	var name_label: Label = rts_hover_panel_widgets.get("name_label")
	var role_label: Label = rts_hover_panel_widgets.get("role_label")
	var sub_info_label: Label = rts_hover_panel_widgets.get("sub_info_label")
	var stat_label: Label = rts_hover_panel_widgets.get("stat_label")
	var total_five_label: Label = rts_hover_panel_widgets.get("total_five_label")
	var officer_label: Label = rts_hover_panel_widgets.get("officer_label")
	var status_label: Label = rts_hover_panel_widgets.get("status_label")
	var commander_name: String = String(panel_data.get("main_name", unit.name))
	var role_id: String = String(panel_data.get("combat_role_id", _unit_role_id(unit)))
	var alive_troops: int = int(panel_data.get("alive_troops", unit.soldier_count))
	var morale_value: float = float(panel_data.get("morale", 0.0))
	var will_value: float = float(panel_data.get("spirit", 0.0))
	var physical_attack: float = float(panel_data.get("physical_attack", panel_data.get("might_mix", 0.0)))
	var physical_defense: float = float(panel_data.get("physical_defense", panel_data.get("leadership_mix", 0.0)))
	var magic_attack: float = float(panel_data.get("magic_attack", panel_data.get("intelligence_mix", 0.0)))
	var magic_defense: float = float(panel_data.get("magic_defense", panel_data.get("intelligence_mix", 0.0)))
	var siege_power: float = float(panel_data.get("siege_power", physical_attack))
	var move_speed: float = float(panel_data.get("move_speed", 0.0))
	var attack_speed: float = float(panel_data.get("attack_speed", 0.0))
	var lead_mix: float = float(panel_data.get("leadership_mix", 0.0))
	var might_mix: float = float(panel_data.get("might_mix", 0.0))
	var int_mix: float = float(panel_data.get("intelligence_mix", 0.0))
	var pol_mix: float = float(panel_data.get("politics_mix", 0.0))
	var charm_mix: float = float(panel_data.get("charm_mix", 0.0))
	var aptitude_text: String = String(panel_data.get("aptitude", "C")).strip_edges().to_upper()
	var type_text: String = String(panel_data.get("unit_type_label", "")).strip_edges()
	if type_text.is_empty():
		type_text = _hover_role_text(role_id)

	_set_label_text_if_changed(name_label, commander_name)
	_set_label_text_if_changed(role_label, "%s %s适性" % [type_text, aptitude_text])
	_set_label_text_if_changed(sub_info_label, "兵力 %d   士气 %.0f   战意 %.0f" % [maxi(0, alive_troops), morale_value, will_value])
	_set_label_text_if_changed(stat_label, "统率 %.1f\n武力 %.1f\n智力 %.1f\n政治 %.1f\n魅力 %.1f" % [lead_mix, might_mix, int_mix, pol_mix, charm_mix])
	_set_label_text_if_changed(total_five_label, "物攻 %.1f\n物防 %.1f\n法攻 %.1f\n法防 %.1f\n攻城 %.1f\n移速 %.2f\n攻速 %.2f" % [physical_attack, physical_defense, magic_attack, magic_defense, siege_power, move_speed, attack_speed])

	if officer_label != null:
		var officer_lines: Array[String] = _build_hover_officer_lines(panel_data)
		_set_label_text_if_changed(officer_label, "无" if officer_lines.is_empty() else "\n".join(PackedStringArray(officer_lines)))
	if status_label != null:
		var status_lines: Array[String] = _build_hover_status_lines(unit, panel_data)
		_set_label_text_if_changed(status_label, "状态效果：无" if status_lines.is_empty() else "状态效果：" + "、".join(PackedStringArray(status_lines)))

func _build_hover_officer_lines(panel_data: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var seen_names: Dictionary = {}
	var default_personality: String = String(panel_data.get("personality_summary", "无")).strip_edges()
	if default_personality.is_empty():
		default_personality = "无"
	var officers_any: Variant = panel_data.get("officers", [])
	if officers_any is Array:
		for officer_any in officers_any:
			if lines.size() >= 3:
				break
			if not (officer_any is Dictionary):
				continue
			var officer: Dictionary = officer_any as Dictionary
			var name_text: String = String(officer.get("name", "")).strip_edges()
			if name_text.is_empty() or seen_names.has(name_text):
				continue
			seen_names[name_text] = true
			var aptitude_text: String = String(officer.get("aptitude", panel_data.get("aptitude", "C"))).strip_edges().to_upper()
			var personality_text: String = String(officer.get("personality", default_personality)).strip_edges()
			if personality_text.is_empty():
				personality_text = default_personality
			lines.append("%s(%s,%s)" % [name_text, aptitude_text, personality_text])
	if not lines.is_empty():
		return lines
	var fallback_items: Array[Dictionary] = [
		{"name": String(panel_data.get("main_name", "")), "apt": String(panel_data.get("main_aptitude", panel_data.get("aptitude", "C"))), "person": String(panel_data.get("main_personality", default_personality))},
		{"name": String(panel_data.get("vice_1_name", "")), "apt": String(panel_data.get("vice_1_aptitude", panel_data.get("aptitude", "C"))), "person": String(panel_data.get("vice_1_personality", default_personality))},
		{"name": String(panel_data.get("vice_2_name", "")), "apt": String(panel_data.get("vice_2_aptitude", panel_data.get("aptitude", "C"))), "person": String(panel_data.get("vice_2_personality", default_personality))}
	]
	for entry in fallback_items:
		var fallback_name: String = String(entry.get("name", "")).strip_edges()
		if fallback_name.is_empty() or seen_names.has(fallback_name):
			continue
		seen_names[fallback_name] = true
		var fallback_apt: String = String(entry.get("apt", "C")).strip_edges().to_upper()
		var fallback_personality: String = String(entry.get("person", default_personality)).strip_edges()
		if fallback_personality.is_empty():
			fallback_personality = default_personality
		lines.append("%s(%s,%s)" % [fallback_name, fallback_apt, fallback_personality])
		if lines.size() >= 3:
			break
	return lines

func _unit_is_out_of_supply(unit, panel_data: Dictionary = {}) -> bool:
	if unit != null and is_instance_valid(unit) and unit.has_method("has_status"):
		if bool(unit.call("has_status", int(UnitController.StatusId.OUT_OF_SUPPLY))):
			return true
	var statuses_any: Variant = panel_data.get("active_statuses", [])
	if statuses_any is Array:
		for status_any in statuses_any:
			var text: String = String(status_any).strip_edges()
			if text.find("断粮") != -1:
				return true
	return false

func _build_hover_status_lines(unit, panel_data: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	var seen: Dictionary = {}
	var statuses_any: Variant = panel_data.get("active_statuses", [])
	if statuses_any is Array:
		for status_any in statuses_any:
			var text: String = String(status_any).strip_edges()
			if text.is_empty():
				continue
			if seen.has(text):
				continue
			seen[text] = true
			lines.append(text)
	if _unit_is_out_of_supply(unit, panel_data) and not seen.has("断粮"):
		lines.append("断粮")
	if demo_recon_enabled and unit != null and is_instance_valid(unit) and int(unit.team_id) != demo_recon_player_team_id:
		var spotted_left: float = get_enemy_spotted_time_left(demo_recon_player_team_id, unit)
		if spotted_left > 0.01:
			lines.append("侦察暴露 %.1f秒" % spotted_left)
		else:
			lines.append("侦察未暴露")
	return lines

func _hover_command_text(command_mode: int) -> String:
	match command_mode:
		int(UnitController.CommandMode.STOP):
			return "停止"
		int(UnitController.CommandMode.MOVE):
			return "移动"
		int(UnitController.CommandMode.FORCE_ATTACK):
			return "强攻"
		int(UnitController.CommandMode.ATTACK_MOVE):
			return "A地攻击"
		int(UnitController.CommandMode.HOLD_POSITION):
			return "固守"
		int(UnitController.CommandMode.RETREAT):
			return "撤退"
		_:
			return "无"

func _build_hover_bonus_lines(unit, panel_data: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	if unit == null or not is_instance_valid(unit):
		return lines
	var atk_bonus: float = float(unit.get("personality_attack_bonus_pct"))
	var def_bonus: float = float(unit.get("personality_defense_bonus_pct"))
	var speed_bonus: float = float(unit.get("personality_speed_bonus_pct"))
	var spirit_bonus: float = float(unit.get("personality_spirit_bonus_flat"))
	if absf(atk_bonus) >= 0.001:
		lines.append("物攻 %s%.0f%%" % ["+" if atk_bonus >= 0.0 else "", atk_bonus * 100.0])
	if absf(def_bonus) >= 0.001:
		lines.append("物防 %s%.0f%%" % ["+" if def_bonus >= 0.0 else "", def_bonus * 100.0])
	if absf(speed_bonus) >= 0.001:
		lines.append("移速 %s%.0f%%" % ["+" if speed_bonus >= 0.0 else "", speed_bonus * 100.0])
	if absf(spirit_bonus) >= 0.01:
		lines.append("斗志 %s%.0f" % ["+" if spirit_bonus >= 0.0 else "", spirit_bonus])
	var famous_name: String = String(panel_data.get("famous_skill_name", "")).strip_edges()
	if not famous_name.is_empty():
		lines.append("专属特技：%s" % famous_name)
	return lines

func _hover_role_text(role_id: String) -> String:
	var normalized: String = role_id.strip_edges().to_lower()
	if normalized.is_empty():
		return "部队"
	if normalized.begins_with("strategist"):
		return "策士"
	match normalized:
		"shield":
			return "盾兵"
		"spear":
			return "枪兵"
		"archer":
			return "弓兵"
		"crossbow":
			return "弩兵"
		"cavalry":
			return "骑兵"
		"scout":
			return "斥候"
		"siege":
			return "器械"
		"naval":
			return "水军"
		"transport":
			return "辎重"
		"infantry":
			return "步兵"
		_:
			return normalized

func _setup_build_menu_panel() -> void:
	if rts_panel_root == null or not is_instance_valid(rts_panel_root):
		return
	if _build_menu_panel != null and is_instance_valid(_build_menu_panel):
		_build_menu_panel.queue_free()
	_build_menu_buttons.clear()
	_build_menu_visible = false
	_build_menu_panel = PanelContainer.new()
	_build_menu_panel.name = "BuildMenuPanel"
	_build_menu_panel.visible = false
	_build_menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_build_menu_panel.custom_minimum_size = Vector2(210.0, 0.0)
	_build_menu_panel.anchor_left = 0.0
	_build_menu_panel.anchor_right = 0.0
	_build_menu_panel.anchor_top = 1.0
	_build_menu_panel.anchor_bottom = 1.0
	_build_menu_panel.offset_left = 8.0
	_build_menu_panel.offset_top = -384.0
	_build_menu_panel.offset_right = 238.0
	_build_menu_panel.offset_bottom = -128.0
	rts_panel_root.add_child(_build_menu_panel)

	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(0.08, 0.09, 0.08, 0.92)
	frame.border_color = Color(0.76, 0.62, 0.34, 0.95)
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(4)
	_build_menu_panel.add_theme_stylebox_override("panel", frame)

	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 8)
	pad.add_theme_constant_override("margin_top", 8)
	pad.add_theme_constant_override("margin_right", 8)
	pad.add_theme_constant_override("margin_bottom", 8)
	_build_menu_panel.add_child(pad)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	pad.add_child(col)

	var title := Label.new()
	title.text = "军建菜单 [B]"
	_apply_rts_panel_label_theme(title, 18, TAG_TEXT_BRONZE)
	col.add_child(title)

	for action_any in UNIT_BUILD_MENU_ACTIONS:
		var action: Dictionary = action_any as Dictionary
		var action_id: String = String(action.get("id", "")).strip_edges()
		if action_id.is_empty():
			continue
		var btn := Button.new()
		btn.name = "Build_%s" % action_id
		btn.text = String(action.get("label", action_id))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0.0, 30.0)
		_apply_rts_panel_button_theme(btn, 180.0)
		btn.pressed.connect(func() -> void:
			_try_issue_build_action(action_id)
		)
		col.add_child(btn)
		_build_menu_buttons[action_id] = btn
func _panel_skill_display_name_for_unit(unit, skill_id: int) -> String:
	var role_id: String = ""
	if unit != null and unit.has_method("get_combat_role_id"):
		role_id = String(unit.call("get_combat_role_id")).strip_edges().to_lower()
	var is_archer: bool = role_id == "archer"
	var is_crossbow: bool = role_id == "crossbow"
	var is_shield: bool = role_id == "shield"
	match skill_id:
		int(UnitController.SkillType.CHARGE):
			if role_id == "spear":
				return "\u62d2\u9635\u523a"
			if is_shield:
				return "\u94c1\u58c1\u9635"
			if is_crossbow:
				return "\u673a\u5f29\u9f50\u53d1"
			if is_archer:
				return "\u71ce\u539f\u706b\u77e2"
			return "\u51b2\u950b"
		int(UnitController.SkillType.BREAKTHROUGH):
			if role_id == "spear":
				return "\u7a81\u67aa\u6311\u9635"
			if is_shield:
				return "\u9707\u76fe\u51fb"
			if is_crossbow:
				return "\u7834\u7532\u900f\u9635"
			if is_archer:
				return "\u7a7f\u4e91\u8d2f\u8679"
			return "\u8d2f\u7a81"
		int(UnitController.SkillType.SWEEP):
			if role_id == "spear":
				return "\u98de\u67aa\u9aa4\u96e8"
			if is_shield:
				return "\u7384\u7532\u9f9f\u9635"
			if is_crossbow:
				return "\u8fde\u5f29\u538b\u9635"
			if is_archer:
				return "\u6d41\u706b\u8fde\u77e2"
			return "\u56f4\u6b7c\u7a81\u88ad"
		_:
			return "\u6218\u6cd5"

func _panel_skill_tooltip(unit, skill_id: int, name_text: String) -> String:
	var cost: float = 0.0
	if unit != null and unit.has_method("get_skill_will_cost_value"):
		cost = float(unit.call("get_skill_will_cost_value", skill_id))
	var cd_left: float = 0.0
	if unit != null and unit.has_method("get_skill_cd_left"):
		cd_left = float(unit.call("get_skill_cd_left", skill_id))
	var role_id: String = ""
	if unit != null and unit.has_method("get_combat_role_id"):
		role_id = String(unit.call("get_combat_role_id")).strip_edges().to_lower()
	var is_archer: bool = role_id == "archer"
	var is_crossbow: bool = role_id == "crossbow"
	var is_shield: bool = role_id == "shield"
	var desc: String = "\u9a91\u5175\u6218\u6cd5"
	match skill_id:
		int(UnitController.SkillType.CHARGE):
			if role_id == "spear":
				desc = "\u524d\u6392\u538b\u4f4e\u67aa\u9635\u540e\u76f4\u51b2\u76ee\u6807\uff0c\u547d\u4e2d\u65f6\u4ee5\u6311\u51fb\u6253\u4e71\u654c\u519b\u524d\u7ebf\u3002"
			elif is_shield:
				desc = "\u4e3e\u76fe\u7ed3\u6210\u94c1\u58c1\uff0c\u9632\u5fa1\u59ff\u6001\u6301\u7eed\u751f\u6548\uff0c\u76f4\u5230\u5438\u6536\u4f24\u5bb3\u8fbe\u5230\u9608\u503c\u624d\u4f1a\u89e3\u9664\u3002"
			elif is_crossbow:
				desc = "\u673a\u5f29\u77ed\u65f6\u4e09\u8f6e\u9f50\u53d1\uff0c\u901a\u8fc7\u9ad8\u5f3a\u5ea6\u5bc6\u96c6\u538b\u5236\u9020\u6210\u7206\u53d1\u4f24\u5bb3\u5e76\u77ed\u6682\u9ebb\u75f9\u3002"
			elif is_archer:
				desc = "\u9501\u5b9a\u5355\u4e2a\u76ee\u6807\u540e\u5206\u4e09\u6ce2\u706b\u77e2\uff0c\u96c6\u4e2d\u538b\u4f4e\u58eb\u6c14\u5e76\u70b9\u71c3\u654c\u519b\u9020\u6210\u6301\u7eed\u707c\u70e7\u4f24\u5bb3\u3002"
			else:
				desc = "\u6954\u5f62\u84c4\u529b\u540e\u6b63\u9762\u51b2\u9635\uff0c\u91cd\u521b\u9996\u6392\u5e76\u5f3a\u884c\u6495\u5f00\u654c\u9635\u3002"
		int(UnitController.SkillType.BREAKTHROUGH):
			if role_id == "spear":
				desc = "\u679a\u7eb5\u6210\u5c16\u9500\u9635\u76f4\u523a\u654c\u519b\u4e2d\u7ebf\uff0c\u5c06\u547d\u4e2d\u5355\u4f4d\u6311\u8d77\u5e76\u5f3a\u884c\u6495\u5f00\u7f3a\u53e3\u3002"
			elif is_shield:
				desc = "\u8fd1\u8ddd\u79bb\u8e0f\u6b65\u7a81\u8fdb\u53d1\u8d77\u76fe\u51fb\uff0c\u9020\u6210\u7838\u51fb\u4f24\u5bb3\u5e76\u6670\u6655\u76ee\u6807\u3002"
			elif is_crossbow:
				desc = "\u6cbf\u76ee\u6807\u6b63\u9762\u6253\u51fa\u91cd\u5f29\u7a84\u7ebf\u8d2f\u7a7f\uff0c\u4f18\u5148\u6253\u900f\u524d\u6392\u5e76\u5bf9\u540e\u6392\u5f62\u6210\u7a7f\u900f\u538b\u5236\u3002"
			elif is_archer:
				desc = "\u6cbf\u76ee\u6807\u6b63\u9762\u6253\u51fa\u72ed\u957f\u8d2f\u5c04\uff0c\u53ef\u987a\u7ebf\u538b\u5236\u76ee\u6807\u540e\u6392\u3002"
			else:
				desc = "\u72ed\u9525\u8d2f\u5165\u76f4\u53d6\u4e2d\u519b\uff0c\u901f\u5ea6\u6700\u5feb\uff0c\u7a81\u7834\u6df1\u5ea6\u6700\u5927\u3002"
		int(UnitController.SkillType.SWEEP):
			if role_id == "spear":
				desc = "\u9501\u5b9a\u76ee\u6807\u540e\u5206\u4e24\u6ce2\u629b\u51fa\u98de\u67aa\u9aa4\u96e8\uff0c\u4ee5\u4e2d\u8ddd\u79bb\u9020\u6210\u660e\u786e\u6740\u4f24\u4e0e\u53d7\u51fb\u53cd\u9988\u3002"
			elif is_shield:
				desc = "\u6536\u62e2\u4e3a\u7384\u7532\u5706\u9635\uff0c\u5927\u5e45\u63d0\u9ad8\u6297\u51fb\u80fd\u529b\uff0c\u5bf9\u8303\u56f4\u654c\u519b\u65bd\u52a0\u51cf\u901f\u5e76\u5f3a\u5236\u5632\u8bbd\u3002"
			elif is_crossbow:
				desc = "\u8fde\u7eed\u629b\u6d12\u5f29\u77e2\u5bf9\u76ee\u6807\u533a\u57df\u8986\u538b\uff0c\u8303\u56f4\u51cf\u901f\uff0c\u533a\u57df\u4e2d\u5fc3\u53ef\u89e6\u53d1\u77ed\u6682\u9ebb\u75f9\u3002"
			elif is_archer:
				desc = "\u5bf9\u76ee\u6807\u533a\u57df\u964d\u4e0b\u591a\u6ce2\u7bad\u96e8\uff0c\u8303\u56f4\u6740\u4f24\u5e76\u62d6\u6162\u654c\u9635\u3002"
			else:
				desc = "\u4e09\u8def\u5305\u5939\u76f4\u63d2\u654c\u9635\u4e2d\u5fc3\uff0c\u5f62\u6210\u4e09\u9762\u56f4\u653b\uff0c\u547d\u4e2d\u540e\u9644\u5e26\u7737\u6655\u3002"
	var free_cast: bool = is_shield and (skill_id == int(UnitController.SkillType.CHARGE) or skill_id == int(UnitController.SkillType.SWEEP))
	var target_hint: String = ""
	if free_cast:
		target_hint = "\u53ef\u4e0d\u9501\u5b9a\u76ee\u6807\u76f4\u63a5\u65bd\u653e"
	else:
		target_hint = "\u5df2\u9501\u5b9a\u653b\u51fb\u76ee\u6807" if _unit_has_locked_skill_target(unit) else "\u9700\u5148\u53f3\u51fb\u654c\u519b\u9501\u5b9a\u76ee\u6807"
	return "%s\n%s\n%s\n\u6218\u610f %.0f\n\u51b7\u5374 %.1f\u79d2" % [name_text, desc, target_hint, cost, cd_left]

func _canonical_tactic_id(raw_tactic_id: String) -> String:
	var tactic_id: String = String(raw_tactic_id).strip_edges().to_lower()
	match tactic_id:
		"fire_attack", "strat_fire":
			return "strat_fire_attack"
		"thunder", "strat_falling_thunder":
			return "strat_thunder"
		"weather_change", "strat_weather":
			return "strat_weather_change"
		_:
			return tactic_id

func _panel_tactic_display_name(tactic_id: String) -> String:
	match _canonical_tactic_id(tactic_id):
		"strat_cheer":
			return "\u9f13\u821e"
		"strat_delay":
			return "\u7f13\u5175"
		"strat_borrow_wind":
			return "\u501f\u98ce"
		"strat_fire_attack":
			return "\u706b\u653b"
		"strat_sow_discord":
			return "\u79bb\u95f4"
		"strat_weather_change":
			return "\u5929\u53d8"
		"strat_chain":
			return "\u8fde\u73af"
		"strat_thunder":
			return "\u843d\u96f7"
		"strat_trap":
			return "\u56f0\u9635"
		"strat_skyfire":
			return "\u5929\u706b"
		"strat_dragon_bind":
			return "\u9f99\u7f1a"
		"strat_thunder_lock":
			return "\u96f7\u9501"
		_:
			return tactic_id

func _panel_tactic_tooltip(unit, tactic_id: String) -> String:
	var id: String = _canonical_tactic_id(tactic_id)
	var cfg: Dictionary = _get_tactic_cfg(id)
	var cost: float = float(cfg.get("will_cost", cfg.get("spirit_cost", 0.0)))
	var cd_left: float = _get_tactic_cd_left(unit, id)
	var desc: String = "Battle tactic."
	match id:
		"strat_cheer":
			desc = "\u53cb\u519b\u58eb\u6c14/\u6218\u610f\u56de\u590d\uff0c\u7a33\u4f4f\u9635\u7ebf\u3002"
		"strat_delay":
			desc = "\u533a\u57df\u7f13\u901f\u5e76\u5c0f\u5e45\u6740\u4f24\uff0c\u62d6\u4f4f\u654c\u9635\u3002"
		"strat_borrow_wind":
			desc = "\u4e3b\u52a8\u8f6c\u4e3a\u98ce\u5929\uff0c\u6fc0\u6d3b\u98ce\u52bf\u76f8\u5173\u6548\u679c\u3002"
		"strat_fire_attack":
			desc = "\u975e\u96e8\u5929\u53ef\u653e\uff0c\u8303\u56f4\u70e7\u4f24\u3002"
		"strat_sow_discord":
			desc = "\u8303\u56f4\u79bb\u95f4\uff0c\u5e72\u6270\u654c\u519b\u6307\u6325\u3002"
		"strat_weather_change":
			desc = "\u6674\u96e8\u4e92\u6362\uff0c\u786e\u4fdd\u706b\u96f7\u53ef\u627f\u63a5\u3002"
		"strat_chain":
			desc = "\u8303\u56f4\u8054\u9501\uff0c\u9650\u5236\u673a\u52a8\u5e76\u7edf\u4e00\u53d7\u51fb\u3002"
		"strat_thunder":
			desc = "\u53ea\u80fd\u5728\u96e8/\u9634\u5929\u65bd\u653e\u7684\u8303\u56f4\u843d\u96f7\u3002"
		"strat_trap":
			desc = "\u964d\u4f4e\u533a\u57df\u8fdb\u51fb\u4e0e\u79fb\u901f\uff0c\u5c01\u9501\u63a8\u8fdb\u3002"
		"strat_skyfire":
			desc = "\u5927\u8303\u56f4\u9ad8\u5f3a\u5ea6\u706b\u653b\uff0c\u96e8\u5929\u4f9d\u65e7\u7981\u7528\u3002"
		"strat_dragon_bind":
			desc = "\u5f3a\u63a7\u578b\u8ba1\u7b56\uff0c\u7f13\u901f+\u77ed\u6682\u5b9a\u8eab\u5e76\u5632\u8bbd\u3002"
		"strat_thunder_lock":
			desc = "\u96e8/\u9634\u5929\u9ad8\u5f3a\u5ea6\u96f7\u51fb\uff0c\u9644\u5e26\u9ebb\u75f9\u3002"
		_:
			desc = "Battle tactic."
	return "%s\n%s\nWill %.0f\nCooldown %.1fs" % [_panel_tactic_display_name(id), desc, cost, cd_left]

func _get_unit_tactic_ids(unit) -> Array[String]:
	var out: Array[String] = []
	if unit == null or not is_instance_valid(unit):
		return out
	if not unit.has_method("get_rts_panel_data"):
		return out
	var p: Dictionary = unit.call("get_rts_panel_data")
	var tactics_any: Variant = p.get("unlocked_tactics", [])
	if not (tactics_any is Array):
		return out
	var raw_tactics: Array = tactics_any as Array
	var slots: int = maxi(0, int(p.get("tactic_slots", raw_tactics.size())))
	var count: int = mini(raw_tactics.size(), slots)
	for i in range(count):
		var tactic_id: String = _canonical_tactic_id(String(raw_tactics[i]))
		if tactic_id.is_empty():
			continue
		out.append(tactic_id)
	return out

func _unit_is_tactician(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	return _unit_role_id(unit) == "strategist"

func _unit_has_combat_skills(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	if _unit_is_tactician(unit):
		return not _get_unit_tactic_ids(unit).is_empty()
	if not unit.has_method("get_rts_panel_data"):
		return false
	var p: Dictionary = unit.call("get_rts_panel_data")
	var skills_any: Variant = p.get("unit_skills", [])
	return skills_any is Array and not (skills_any as Array).is_empty()

func _get_unit_slot_actions(unit) -> Array:
	var out: Array = []
	if unit == null or not is_instance_valid(unit):
		return out
	if _unit_is_tactician(unit):
		var tactic_ids: Array[String] = _get_unit_tactic_ids(unit)
		for tactic_id in tactic_ids:
			out.append({
				"kind": "tactic",
				"id": tactic_id,
				"name": _panel_tactic_display_name(tactic_id),
				"tooltip": _panel_tactic_tooltip(unit, tactic_id)
			})
		return out
	var p: Dictionary = unit.call("get_rts_panel_data") if unit.has_method("get_rts_panel_data") else {}
	var unit_skills: Array = p.get("unit_skills", [])
	for skill_any in unit_skills:
		if not (skill_any is Dictionary):
			continue
		var skill_data: Dictionary = skill_any
		var skill_id: int = int(skill_data.get("id", 0))
		out.append({
			"kind": "skill",
			"id": skill_id,
			"name": _panel_skill_display_name_for_unit(unit, skill_id),
			"tooltip": _panel_skill_tooltip(unit, skill_id, _panel_skill_display_name_for_unit(unit, skill_id))
		})
	return out

func _try_cast_slot_action(unit, slot_index: int) -> void:
	var actions: Array = _get_unit_slot_actions(unit)
	if slot_index < 0 or slot_index >= actions.size():
		return
	var action: Dictionary = actions[slot_index]
	var kind: String = String(action.get("kind", ""))
	if kind == "tactic":
		_try_cast_tactic_by_id(unit, String(action.get("id", "")))
	else:
		_try_cast_unit_skill(unit, int(action.get("id", 0)))

func _unit_has_famous_skill(unit) -> bool:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return false
	return not _get_unique_skill_cfg_for_unit(unit).is_empty()

func _can_cast_famous_skill(unit) -> bool:
	if not _unit_has_famous_skill(unit):
		return false
	return _get_famous_skill_cd_left(unit) <= 0.001

func _try_cast_famous_skill(unit) -> void:
	var cfg: Dictionary = _get_unique_skill_cfg_for_unit(unit)
	if cfg.is_empty():
		_set_battle_status("Unique skill unavailable.")
		return
	var skill_name: String = str(cfg.get("name", "Unique Skill"))
	var cd_left: float = _get_famous_skill_cd_left(unit)
	if cd_left > 0.001:
		_set_battle_status("%s cooling down %.1fs." % [skill_name, cd_left])
		return
	if not _execute_unique_skill(unit, cfg):
		_set_battle_status("%s has no valid target." % skill_name)
		return
	var unit_id: int = unit.get_instance_id()
	var cooldown_sec: float = maxf(1.0, float(cfg.get("cooldown_sec", 55.0)))
	famous_skill_cooldowns[unit_id] = cooldown_sec
	famous_auto_cooldowns[unit_id] = maxf(6.0, minf(cooldown_sec, auto_release_famous_cooldown_sec))
	_set_battle_status("%s activated." % skill_name)

func _update_rts_panel_buttons() -> void:
	if rts_panel_root == null or not is_instance_valid(rts_panel_root):
		return
	var cmd_unit = _get_selected_command_unit()
	var attack_move_btn: Button = rts_panel_widgets.get("attack_move_btn")
	var stop_btn: Button = rts_panel_widgets.get("stop_btn")
	var hold_btn: Button = rts_panel_widgets.get("hold_btn")
	var retreat_btn: Button = rts_panel_widgets.get("retreat_btn")
	var famous_btn: Button = rts_panel_widgets.get("famous_btn")
	var build_btn: Button = rts_panel_widgets.get("build_btn")
	var skill_auto_btn: Button = rts_panel_widgets.get("skill_auto_btn")
	var famous_auto_btn: Button = rts_panel_widgets.get("famous_auto_btn")
	var slot_title: Label = rts_panel_widgets.get("slot_title")
	var slot_buttons: Array = rts_panel_widgets.get("slot_buttons", [])
	var active: bool = cmd_unit != null
	for btn_any in [attack_move_btn, stop_btn, hold_btn, retreat_btn, famous_btn, build_btn, skill_auto_btn, famous_auto_btn]:
		if btn_any is Button:
			(btn_any as Button).disabled = not active
	if attack_move_btn != null:
		attack_move_btn.tooltip_text = "Attack-move. Press A, then right-click ground or an enemy."
		attack_move_btn.text = "Attack Move [A]" if pending_ground_command != "attack_move" else "Attack Move: Ready"
	if stop_btn != null:
		stop_btn.tooltip_text = "Stop the selected unit immediately."
		stop_btn.text = "Stop [S]"
	if hold_btn != null:
		hold_btn.tooltip_text = "Hold ground and only attack within range."
		hold_btn.text = "Hold [D]"
	if retreat_btn != null:
		retreat_btn.tooltip_text = "Retreat to the nearest friendly fallback point."
		retreat_btn.text = "Retreat [F]"
	if famous_btn != null:
		var p: Dictionary = cmd_unit.call("get_rts_panel_data") if active and cmd_unit.has_method("get_rts_panel_data") else {}
		var famous_name: String = String(p.get("famous_skill_name", "Unique Skill"))
		var famous_desc: String = String(p.get("famous_skill_desc", "Only available to the commanding officer when conditions are met."))
		famous_btn.text = "%s [R]" % famous_name
		famous_btn.disabled = not _can_cast_famous_skill(cmd_unit)
		famous_btn.tooltip_text = "%s\n%s" % [famous_name, famous_desc]
	if build_btn != null:
		build_btn.text = "军建 [B]" if not _build_menu_visible else "关闭军建 [B]"
		build_btn.tooltip_text = "由选中野战部队建造军事设施。"
		build_btn.disabled = not active or not _can_unit_open_build_menu(cmd_unit)
	if skill_auto_btn != null:
		var has_combat_skills: bool = _unit_has_combat_skills(cmd_unit)
		var skill_auto_enabled: bool = _is_skill_auto_enabled(cmd_unit)
		var mode_name: String = "Tactics" if _unit_is_tactician(cmd_unit) else "Combat Skills"
		skill_auto_btn.text = "%s: Auto" % mode_name if skill_auto_enabled else "%s: Manual" % mode_name
		skill_auto_btn.tooltip_text = "Toggle %s cast mode.\nAuto mode triggers by battlefield pressure and reduces waste." % mode_name
		skill_auto_btn.disabled = not active or not has_combat_skills
	if famous_auto_btn != null:
		var famous_auto_enabled: bool = _is_famous_auto_enabled(cmd_unit)
		famous_auto_btn.text = "Unique Skill: Auto" if famous_auto_enabled else "Unique Skill: Manual"
		famous_auto_btn.tooltip_text = "Toggle unique skill cast mode.\nAuto mode only triggers under suitable combat pressure."
		famous_auto_btn.disabled = not active or not _unit_has_famous_skill(cmd_unit)
	var actions: Array = _get_unit_slot_actions(cmd_unit)
	var skill_target_ready: bool = _unit_has_locked_skill_target(cmd_unit)
	var role_id: String = _unit_role_id(cmd_unit)
	if slot_title != null:
		slot_title.text = "Tactics" if _unit_is_tactician(cmd_unit) else "Combat Skills"
	for i in range(slot_buttons.size()):
		var btn: Button = slot_buttons[i]
		if btn == null or not is_instance_valid(btn):
			continue
		if i < actions.size():
			var action: Dictionary = actions[i]
			var kind: String = String(action.get("kind", ""))
			var skill_id: int = int(action.get("id", 0))
			var free_cast: bool = kind == "skill" and role_id == "shield" and (skill_id == int(UnitController.SkillType.CHARGE) or skill_id == int(UnitController.SkillType.SWEEP))
			var slot_enabled: bool = active and (kind != "skill" or skill_target_ready or free_cast)
			btn.visible = true
			btn.disabled = not slot_enabled
			btn.text = "%d %s" % [i + 1, String(action.get("name", "Action"))]
			btn.tooltip_text = String(action.get("tooltip", ""))
			if kind == "skill" and not skill_target_ready and not free_cast:
				if not btn.tooltip_text.is_empty():
					btn.tooltip_text += "\n"
				btn.tooltip_text += "Lock an attack target first."
		else:
			btn.visible = false
func _update_rts_panel() -> void:
	if rts_panel_root == null or not is_instance_valid(rts_panel_root):
		return
	var cmd_unit = _get_selected_command_unit()
	var active: bool = cmd_unit != null
	rts_panel_root.visible = active
	if not active:
		_set_build_menu_visible(false)
		return
	var status_label: Label = rts_panel_widgets.get("status")
	var unit_name_label: Label = rts_panel_widgets.get("unit_name")
	var panel_data: Dictionary = cmd_unit.call("get_rts_panel_data") if cmd_unit.has_method("get_rts_panel_data") else {}
	var main_name: String = String(panel_data.get("commander_name", panel_data.get("name", cmd_unit.name)))
	var selected_count: int = selected_units.size()
	if unit_name_label != null:
		if selected_count > 1:
			unit_name_label.text = "%s + %d" % [main_name, selected_count - 1]
		else:
			unit_name_label.text = main_name
	if status_label != null:
		var weather_text: String = _current_weather_text()
		if battle_tip_timer > 0.0 and not battle_tip_message.is_empty():
			status_label.text = "%s | %s" % [battle_tip_message, weather_text]
		else:
			status_label.text = weather_text
	_update_build_menu_availability()
	_update_rts_panel_buttons()

func _toggle_build_menu() -> void:
	var cmd_unit = _get_selected_command_unit()
	if cmd_unit == null or not _can_unit_open_build_menu(cmd_unit):
		_set_build_menu_visible(false)
		return
	_set_build_menu_visible(not _build_menu_visible)

func _set_build_menu_visible(visible_now: bool) -> void:
	_build_menu_visible = visible_now
	if _build_menu_panel != null and is_instance_valid(_build_menu_panel):
		_build_menu_panel.visible = visible_now

func _can_unit_open_build_menu(unit) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	if not unit.has_meta("building_type"):
		return false
	var type_key: String = String(unit.get_meta("building_type", "")).strip_edges().to_lower()
	return type_key == "field_unit"

func _update_build_menu_availability() -> void:
	if _build_menu_panel == null or not is_instance_valid(_build_menu_panel):
		return
	var cmd_unit = _get_selected_command_unit()
	var can_open: bool = _can_unit_open_build_menu(cmd_unit)
	if not can_open:
		_set_build_menu_visible(false)
	for action_any in UNIT_BUILD_MENU_ACTIONS:
		var action: Dictionary = action_any as Dictionary
		var action_id: String = String(action.get("id", "")).strip_edges()
		var btn: Button = _build_menu_buttons.get(action_id, null) as Button
		if btn == null or not is_instance_valid(btn):
			continue
		btn.disabled = not can_open

func _try_issue_build_action(action_id: String) -> void:
	var cmd_unit = _get_selected_command_unit()
	if cmd_unit == null:
		_set_battle_status("No selectable field unit.")
		return
	var action_label: String = action_id
	for action_any in UNIT_BUILD_MENU_ACTIONS:
		var action: Dictionary = action_any as Dictionary
		if String(action.get("id", "")) == action_id:
			action_label = String(action.get("label", action_id))
			break
	_pending_build_action_id = action_id
	_pending_build_action_label = action_label
	_build_line_start_world = Vector3.INF
	_clear_build_line_start_marker()
	_set_build_menu_visible(false)
	_ensure_build_preview_node(action_id)
	_update_build_preview_at_screen(get_viewport().get_mouse_position())
	if action_id == "build_zhalan":
		_set_battle_status("放置%s：左键设置起点，再左键设置终点；右键/ESC取消。" % _pending_build_action_label)
	else:
		_set_battle_status("放置%s：左键确认，右键/ESC取消。" % _pending_build_action_label)

func _is_build_placement_active() -> bool:
	return not _pending_build_action_id.is_empty()

func is_build_placement_active() -> bool:
	return _is_build_placement_active()

func _ensure_build_preview_node(action_id: String) -> void:
	_clear_build_preview_node()
	if _strategy_map_view == null or not is_instance_valid(_strategy_map_view):
		return
	if not _strategy_map_view.has_method("get_unit_build_preview"):
		return
	var preview_any: Variant = _strategy_map_view.call("get_unit_build_preview", action_id)
	if not (preview_any is Dictionary):
		return
	var preview: Dictionary = preview_any as Dictionary
	var model_path: String = String(preview.get("model_path", "")).strip_edges()
	var scale_mul: float = maxf(0.001, float(preview.get("model_scale", 1.0)))
	var root := Node3D.new()
	root.name = "BuildPreview"
	add_child(root)
	_build_preview_node = root
	var procedural_id: String = String(preview.get("procedural_id", "")).strip_edges()
	if not procedural_id.is_empty() and _strategy_map_view.has_method("create_unit_build_preview_instance"):
		var procedural_any: Variant = _strategy_map_view.call("create_unit_build_preview_instance", action_id)
		if procedural_any is Node3D:
			var procedural := procedural_any as Node3D
			root.add_child(procedural)
			_apply_build_preview_visual(procedural)
			return
	if model_path.is_empty():
		return
	var packed: PackedScene = load(model_path) as PackedScene
	if packed == null:
		return
	var inst: Node = packed.instantiate()
	if inst is Node3D:
		var model := inst as Node3D
		model.scale = Vector3.ONE * scale_mul
		root.add_child(model)
		_apply_build_preview_visual(model)

func _apply_build_preview_visual(root: Node) -> void:
	if root == null:
		return
	if root is GeometryInstance3D:
		var geo: GeometryInstance3D = root as GeometryInstance3D
		geo.transparency = 0.55
		geo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child in root.get_children():
		_apply_build_preview_visual(child)

func _clear_build_preview_node() -> void:
	if _build_preview_node != null and is_instance_valid(_build_preview_node):
		_build_preview_node.queue_free()
	_build_preview_node = null

func _update_build_preview_at_screen(screen_pos: Vector2) -> void:
	if not _is_build_placement_active():
		_clear_strategy_map_build_preview()
		return
	var hit: Dictionary = _raycast_screen(screen_pos)
	if hit.is_empty() or not hit.has("position"):
		return
	var pos: Vector3 = hit.get("position", Vector3.ZERO)
	if _build_preview_node != null and is_instance_valid(_build_preview_node):
		_build_preview_node.global_position = pos
	_sync_strategy_map_build_preview(pos)

func _confirm_build_placement(screen_pos: Vector2) -> void:
	var cmd_unit = _get_selected_command_unit()
	if cmd_unit == null:
		_cancel_build_placement("No unit selected.")
		return
	if _strategy_map_view == null or not is_instance_valid(_strategy_map_view):
		_cancel_build_placement("Strategy map runtime missing.")
		return
	if not _strategy_map_view.has_method("request_unit_build_action"):
		_cancel_build_placement("Map runtime has no build interface.")
		return
	var hit: Dictionary = _raycast_screen(screen_pos)
	if hit.is_empty() or not hit.has("position"):
		_set_battle_status("Invalid build position.")
		return
	var world_pos: Vector3 = hit.get("position", Vector3.ZERO)
	var result_any: Variant = _strategy_map_view.call("request_unit_build_action", cmd_unit, _pending_build_action_id, world_pos)
	var result: Dictionary = result_any as Dictionary if result_any is Dictionary else {}
	var ok: bool = bool(result.get("ok", false))
	var message: String = String(result.get("message", "Build action finished."))
	_set_battle_status(message)
	if ok:
		_pending_build_action_id = ""
		_pending_build_action_label = ""
		_build_line_start_world = Vector3.INF
		_clear_build_line_start_marker()
		_clear_build_preview_node()
		_clear_strategy_map_build_preview()

func _confirm_build_fence_line_click(screen_pos: Vector2) -> void:
	var hit: Dictionary = _raycast_screen(screen_pos)
	if hit.is_empty() or not hit.has("position"):
		_set_battle_status("Invalid build position.")
		return
	var world_pos: Vector3 = hit.get("position", Vector3.ZERO)
	if _build_line_start_world == Vector3.INF:
		_build_line_start_world = world_pos
		_update_build_preview_at_screen(screen_pos)
		_show_build_line_start_marker(world_pos)
		_set_battle_status("栅栏起点已设置：请左键点终点确认。")
		return
	_confirm_build_fence_line(world_pos)

func _confirm_build_fence_line(end_world: Vector3) -> void:
	var cmd_unit = _get_selected_command_unit()
	if cmd_unit == null:
		_cancel_build_placement("No unit selected.")
		return
	if _strategy_map_view == null or not is_instance_valid(_strategy_map_view):
		_cancel_build_placement("Strategy map runtime missing.")
		return
	if not _strategy_map_view.has_method("request_unit_build_line_action"):
		_set_battle_status("当前地图未接入直线栅栏建造接口。")
		_build_line_start_world = Vector3.INF
		_clear_build_line_start_marker()
		return
	var result_any: Variant = _strategy_map_view.call("request_unit_build_line_action", cmd_unit, "build_zhalan", _build_line_start_world, end_world)
	var result: Dictionary = result_any as Dictionary if result_any is Dictionary else {}
	var ok: bool = bool(result.get("ok", false))
	var message: String = String(result.get("message", "Build action finished."))
	_set_battle_status(message)
	_build_line_start_world = Vector3.INF
	_clear_build_line_start_marker()
	if ok:
		_pending_build_action_id = ""
		_pending_build_action_label = ""
		_clear_build_preview_node()
		_clear_strategy_map_build_preview()

func _show_build_line_start_marker(world_pos: Vector3) -> void:
	if _build_line_start_marker == null or not is_instance_valid(_build_line_start_marker):
		var marker := Node3D.new()
		marker.name = "BuildLineStartMarker"
		var has_marker_model: bool = false
		if _build_preview_node != null and is_instance_valid(_build_preview_node):
			for child in _build_preview_node.get_children():
				if not (child is Node3D):
					continue
				var marker_model := (child as Node3D).duplicate()
				marker.add_child(marker_model)
				_apply_build_preview_visual(marker_model)
				has_marker_model = true
				break
		if _strategy_map_view != null and is_instance_valid(_strategy_map_view) and _strategy_map_view.has_method("create_unit_build_preview_instance"):
			var marker_model_any: Variant = _strategy_map_view.call("create_unit_build_preview_instance", "build_zhalan")
			if not has_marker_model and marker_model_any is Node3D:
				var marker_model := marker_model_any as Node3D
				marker.add_child(marker_model)
				_apply_build_preview_visual(marker_model)
				has_marker_model = true
		if not has_marker_model:
			var mesh := MeshInstance3D.new()
			var sphere := SphereMesh.new()
			sphere.radius = 4.0
			sphere.height = 8.0
			mesh.mesh = sphere
			var mat := StandardMaterial3D.new()
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat.albedo_color = Color(0.72, 0.5, 0.26, 0.7)
			mesh.material_override = mat
			marker.add_child(mesh)
		add_child(marker)
		_build_line_start_marker = marker
	_build_line_start_marker.global_position = world_pos + Vector3(0.0, 0.25, 0.0)
	_build_line_start_marker.visible = true

func _clear_build_line_start_marker() -> void:
	if _build_line_start_marker != null and is_instance_valid(_build_line_start_marker):
		_build_line_start_marker.queue_free()
	_build_line_start_marker = null

func _cancel_build_placement(message: String = "") -> void:
	_pending_build_action_id = ""
	_pending_build_action_label = ""
	_build_line_start_world = Vector3.INF
	_clear_build_line_start_marker()
	_clear_build_preview_node()
	_clear_strategy_map_build_preview()
	if not message.is_empty():
		_set_battle_status(message)
func _load_weather_settings() -> void:
	var settings_path: String = WEATHER_SETTINGS_PATH
	if _weather_context_pending.has("settings_path"):
		settings_path = String(_weather_context_pending.get("settings_path", WEATHER_SETTINGS_PATH))
	if not FileAccess.file_exists(settings_path):
		weather_settings = {}
		return
	var raw_text: String = FileAccess.get_file_as_string(settings_path)
	var parsed: Variant = JSON.parse_string(raw_text)
	if parsed is Dictionary:
		weather_settings = (parsed as Dictionary).duplicate(true)
	else:
		weather_settings = {}

func _load_battle_rules() -> void:
	if not FileAccess.file_exists(BATTLE_RULES_PATH):
		return
	var raw_text: String = FileAccess.get_file_as_string(BATTLE_RULES_PATH)
	var parsed: Variant = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		return
	_apply_battle_rules(parsed as Dictionary)

func _load_unique_skills() -> void:
	unique_skill_catalog.clear()
	unique_skill_by_officer_id.clear()
	unique_skill_by_owner_key.clear()
	if not FileAccess.file_exists(UNIQUE_SKILLS_PATH):
		return
	var raw_text: String = FileAccess.get_file_as_string(UNIQUE_SKILLS_PATH)
	var parsed: Variant = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		return
	var root: Dictionary = parsed as Dictionary
	var skills_any: Variant = root.get("skills", [])
	if not (skills_any is Array):
		return
	for entry_any in (skills_any as Array):
		if not (entry_any is Dictionary):
			continue
		var entry: Dictionary = (entry_any as Dictionary).duplicate(true)
		var skill_id: String = str(entry.get("id", "")).strip_edges().to_lower()
		if skill_id.is_empty():
			continue
		unique_skill_catalog[skill_id] = entry
		var officer_id: String = str(entry.get("officer_id", "")).strip_edges().to_lower()
		if not officer_id.is_empty():
			unique_skill_by_officer_id[officer_id] = skill_id
		var owner_names_any: Variant = entry.get("owner_names", [])
		if owner_names_any is Array:
			for name_any in (owner_names_any as Array):
				var owner_key: String = _normalize_unique_skill_owner_key(str(name_any))
				if not owner_key.is_empty():
					unique_skill_by_owner_key[owner_key] = skill_id

func _normalize_unique_skill_owner_key(raw: String) -> String:
	var text_key: String = raw.strip_edges().to_lower()
	for token in [" ", "_", "-", "\t", "\n", "\r"]:
		text_key = text_key.replace(token, "")
	return text_key

func _resolve_unique_skill_cfg(officer_id: String = "", officer_name: String = "") -> Dictionary:
	var skill_id: String = officer_id.strip_edges().to_lower()
	if not skill_id.is_empty() and unique_skill_by_officer_id.has(skill_id):
		var mapped_id: String = str(unique_skill_by_officer_id.get(skill_id, "")).strip_edges().to_lower()
		if unique_skill_catalog.has(mapped_id):
			return (unique_skill_catalog.get(mapped_id, {}) as Dictionary).duplicate(true)
	var owner_key: String = _normalize_unique_skill_owner_key(officer_name)
	if not owner_key.is_empty() and unique_skill_by_owner_key.has(owner_key):
		var mapped_name_id: String = str(unique_skill_by_owner_key.get(owner_key, "")).strip_edges().to_lower()
		if unique_skill_catalog.has(mapped_name_id):
			return (unique_skill_catalog.get(mapped_name_id, {}) as Dictionary).duplicate(true)
	return {}

func _get_unique_skill_cfg_for_unit(unit) -> Dictionary:
	if unit == null or not is_instance_valid(unit):
		return {}
	var skill_id: String = str(unit.get_meta("unique_skill_id", "")).strip_edges().to_lower()
	if not skill_id.is_empty() and unique_skill_catalog.has(skill_id):
		return (unique_skill_catalog.get(skill_id, {}) as Dictionary).duplicate(true)
	var officer_id: String = str(unit.get_meta("officer_id", "")).strip_edges().to_lower()
	var officer_name: String = str(unit.get_meta("unique_skill_owner_name", unit.get("main_commander_name"))).strip_edges()
	return _resolve_unique_skill_cfg(officer_id, officer_name)

func _apply_unique_skill_identity(unit, officer_id: String = "", officer_name: String = "") -> void:
	if unit == null or not is_instance_valid(unit):
		return
	var cfg: Dictionary = _resolve_unique_skill_cfg(officer_id, officer_name)
	unit.set_meta("officer_id", officer_id.strip_edges().to_lower())
	unit.set_meta("unique_skill_owner_name", officer_name)
	if cfg.is_empty():
		unit.set_meta("unique_skill_id", "")
		unit.famous_skill_name = ""
		unit.famous_skill_desc = ""
		return
	var skill_id: String = str(cfg.get("id", "")).strip_edges().to_lower()
	unit.set_meta("unique_skill_id", skill_id)
	unit.famous_skill_name = str(cfg.get("name", ""))
	unit.famous_skill_desc = str(cfg.get("desc", ""))

func _get_famous_skill_cd_left(unit) -> float:
	if unit == null or not is_instance_valid(unit):
		return 0.0
	return maxf(0.0, float(famous_skill_cooldowns.get(unit.get_instance_id(), 0.0)))

func _read_unit_attack_power(unit) -> float:
	if unit == null or not is_instance_valid(unit):
		return 0.0
	var panel_data: Dictionary = unit.call("get_rts_panel_data") if unit.has_method("get_rts_panel_data") else {}
	var attack_power: float = float(panel_data.get("physical_attack", unit.get("attack_damage")))
	if attack_power <= 0.001:
		attack_power = maxf(1.0, float(unit.get("attack_damage")) * 8.0)
	return attack_power

func _adjust_unit_morale(unit, delta_value: float) -> void:
	if unit == null or not is_instance_valid(unit) or delta_value == 0.0:
		return
	if unit.has_method("_apply_morale_delta"):
		unit.call("_apply_morale_delta", delta_value, true)

func _adjust_unit_spirit(unit, delta_value: float) -> void:
	if unit == null or not is_instance_valid(unit) or delta_value == 0.0:
		return
	var spirit_now: float = float(unit.get("spirit_current"))
	var spirit_cap: float = maxf(1.0, float(unit.get("spirit_cap_current")))
	unit.set("spirit_current", clampf(spirit_now + delta_value, 0.0, spirit_cap))

func _clear_unit_control_statuses(unit, cfg: Dictionary) -> void:
	if unit == null or not is_instance_valid(unit) or not unit.has_method("clear_status"):
		return
	if bool(cfg.get("cleanse_confusion", false)):
		unit.call("clear_status", int(UnitController.StatusId.CONFUSION))
	if bool(cfg.get("cleanse_slow", false)):
		unit.call("clear_status", int(UnitController.StatusId.SLOWED))
	if bool(cfg.get("cleanse_misinformation", false)):
		unit.call("clear_status", int(UnitController.StatusId.MISINFORMATION))

func _get_unique_skill_face_dir(caster, preferred_target = null) -> Vector3:
	if caster == null or not is_instance_valid(caster):
		return Vector3.FORWARD
	var face: Vector3 = Vector3.ZERO
	if preferred_target != null and is_instance_valid(preferred_target) and not preferred_target.dead:
		face = preferred_target.global_position - caster.global_position
		face.y = 0.0
	if face.length_squared() <= 0.001:
		var locked = _resolve_locked_skill_target(caster)
		if locked != null and is_instance_valid(locked) and not locked.dead:
			face = locked.global_position - caster.global_position
			face.y = 0.0
	if face.length_squared() <= 0.001 and caster.has_method("get_collision_forward_flat"):
		face = caster.get_collision_forward_flat()
	if face.length_squared() <= 0.001:
		face = Vector3.FORWARD
	return face.normalized()

func _get_units_in_frontal_cone(caster, radius: float, cone_angle_deg: float, face_dir: Vector3 = Vector3.ZERO) -> Array:
	var out: Array = []
	if caster == null or not is_instance_valid(caster):
		return out
	var enemies: Array = get_enemies_in_radius(caster.global_position, radius, int(caster.team_id))
	var face: Vector3 = face_dir
	if face.length_squared() <= 0.001:
		face = caster.get_collision_forward_flat() if caster.has_method("get_collision_forward_flat") else Vector3.FORWARD
	if face.length_squared() <= 0.001:
		face = Vector3.FORWARD
	face = face.normalized()
	var min_dot: float = cos(deg_to_rad(cone_angle_deg * 0.5))
	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		var to_enemy: Vector3 = enemy.global_position - caster.global_position
		to_enemy.y = 0.0
		if to_enemy.length_squared() <= 0.001:
			continue
		if face.dot(to_enemy.normalized()) >= min_dot:
			out.append(enemy)
	return out

func _reduce_unit_cooldowns(unit, refund_pct: float) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	var pct: float = clampf(refund_pct, 0.0, 0.95)
	var skill_cds_any: Variant = unit.get("skill_cooldowns")
	if skill_cds_any is Dictionary:
		var skill_cds: Dictionary = (skill_cds_any as Dictionary).duplicate(true)
		for key_any in skill_cds.keys():
			var key: int = int(key_any)
			var left: float = maxf(0.0, float(skill_cds.get(key_any, 0.0)) * (1.0 - pct))
			if left <= 0.001:
				skill_cds.erase(key)
			else:
				skill_cds[key] = left
		unit.set("skill_cooldowns", skill_cds)
	var tactics_any: Variant = unit.get("unlocked_tactics")
	if tactics_any is Array:
		for tactic_any in (tactics_any as Array):
			var tactic_id: String = str(tactic_any).strip_edges()
			if tactic_id.is_empty():
				continue
			var key: String = _tactic_key(unit, tactic_id)
			var left: float = float(tactic_cooldowns.get(key, 0.0))
			if left <= 0.001:
				continue
			left = maxf(0.0, left * (1.0 - pct))
			if left <= 0.001:
				tactic_cooldowns.erase(key)
			else:
				tactic_cooldowns[key] = left

func _pick_unique_skill_target(unit, cfg: Dictionary):
	var range_limit: float = maxf(6.0, float(cfg.get("range", cfg.get("radius", 16.0))))
	var template_id: String = str(cfg.get("effect_template", "")).strip_edges().to_lower()
	var target_mul: float = 1.4
	if template_id == "charge_break_line" or template_id == "flank_dash_assault":
		target_mul = 2.0
	var locked = _resolve_locked_skill_target(unit)
	if locked != null and is_instance_valid(locked) and not locked.dead:
		var delta_pos: Vector3 = locked.global_position - unit.global_position
		delta_pos.y = 0.0
		if delta_pos.length() <= range_limit * target_mul:
			return locked
	var search_mul: float = 1.0 if target_mul <= 1.4 else 1.35
	return _get_closest_enemy_in_range(unit, range_limit * search_mul)
func _play_unique_skill_vfx(caster, cfg: Dictionary, center: Vector3, radius: float) -> void:
	var template_id: String = str(cfg.get("effect_template", "")).strip_edges().to_lower()
	var tactic_id: String = "strat_cheer"
	if template_id.find("fire") != -1:
		tactic_id = "strat_fire_attack"
	elif template_id.find("control") != -1 or template_id.find("interrupt") != -1:
		tactic_id = "strat_chain"
	elif template_id.find("cone") != -1 or template_id.find("cleave") != -1 or template_id.find("charge") != -1 or template_id.find("flank") != -1:
		tactic_id = "strat_delay"
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.28)
	_play_tactic_area_vfx(caster, tactic_id, center, maxf(4.0, radius), maxf(1.2, float(cfg.get("duration_sec", 4.0))), 1, 0.1)

func _cast_unique_team_aura_buff(caster, cfg: Dictionary) -> bool:
	var radius: float = float(cfg.get("radius", 18.0))
	var duration: float = float(cfg.get("duration_sec", 8.0))
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	var allies: Array = _get_friendly_units_in_radius(caster.global_position, radius, int(caster.team_id))
	if allies.is_empty():
		allies.append(caster)
	for ally in allies:
		if ally == null or not is_instance_valid(ally) or ally.dead:
			continue
		if ally.has_method("apply_status"):
			ally.call("apply_status", int(UnitController.StatusId.HIGH_MORALE), maxf(0.2, duration))
			ally.call("apply_status", int(UnitController.StatusId.TACTIC_BUFF), maxf(0.2, duration))
		_adjust_unit_morale(ally, float(effects.get("ally_morale_gain_flat", 0.0)))
		_adjust_unit_spirit(ally, float(effects.get("ally_spirit_gain_flat", 0.0)))
	for enemy in get_enemies_in_radius(caster.global_position, radius, int(caster.team_id)):
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		_adjust_unit_morale(enemy, -float(effects.get("enemy_morale_pressure_flat", 0.0)))
	_play_unique_skill_vfx(caster, cfg, caster.global_position, radius)
	return true

func _cast_unique_team_cdr_support(caster, cfg: Dictionary) -> bool:
	var radius: float = float(cfg.get("radius", 18.0))
	var duration: float = float(cfg.get("duration_sec", 8.0))
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	var allies: Array = _get_friendly_units_in_radius(caster.global_position, radius, int(caster.team_id))
	if allies.is_empty():
		allies.append(caster)
	for ally in allies:
		if ally == null or not is_instance_valid(ally) or ally.dead:
			continue
		if ally.has_method("apply_status"):
			ally.call("apply_status", int(UnitController.StatusId.HIGH_MORALE), maxf(0.2, duration))
			ally.call("apply_status", int(UnitController.StatusId.TACTIC_BUFF), maxf(0.2, duration))
		_adjust_unit_morale(ally, float(effects.get("ally_morale_gain_flat", 0.0)))
		_adjust_unit_spirit(ally, float(effects.get("ally_spirit_gain_flat", 0.0)))
		_reduce_unit_cooldowns(ally, float(effects.get("ally_skill_cooldown_refund_pct", 0.0)))
	_play_unique_skill_vfx(caster, cfg, caster.global_position, radius)
	return true

func _cast_unique_morale_recover_cleanse(caster, cfg: Dictionary) -> bool:
	var radius: float = float(cfg.get("radius", 18.0))
	var duration: float = float(cfg.get("duration_sec", 6.0))
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	var allies: Array = _get_friendly_units_in_radius(caster.global_position, radius, int(caster.team_id))
	if allies.is_empty():
		allies.append(caster)
	for ally in allies:
		if ally == null or not is_instance_valid(ally) or ally.dead:
			continue
		_adjust_unit_morale(ally, float(effects.get("ally_morale_gain_flat", 0.0)))
		_adjust_unit_spirit(ally, float(effects.get("ally_spirit_gain_flat", 0.0)))
		_clear_unit_control_statuses(ally, effects)
		if ally.has_method("apply_status"):
			ally.call("apply_status", int(UnitController.StatusId.HIGH_MORALE), maxf(0.2, duration))
	_play_unique_skill_vfx(caster, cfg, caster.global_position, radius)
	return true

func _cast_unique_single_interrupt_debuff(caster, cfg: Dictionary) -> bool:
	var target = _pick_unique_skill_target(caster, cfg)
	if target == null or not is_instance_valid(target) or target.dead:
		return false
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	if target.has_method("apply_status"):
		target.call("apply_status", int(UnitController.StatusId.PARALYZED), maxf(0.12, float(effects.get("paralyze_sec", 0.5))))
		target.call("apply_status", int(UnitController.StatusId.MISINFORMATION), maxf(0.2, float(effects.get("apply_misinformation_sec", 4.0))))
	_adjust_unit_morale(target, -float(effects.get("morale_damage_flat", 0.0)))
	_play_unique_skill_vfx(caster, cfg, target.global_position, maxf(5.0, float(cfg.get("range", 12.0))))
	return true

func _cast_unique_area_control_zone(caster, cfg: Dictionary) -> bool:
	var target = _pick_unique_skill_target(caster, cfg)
	if target == null or not is_instance_valid(target) or target.dead:
		return false
	var radius: float = float(cfg.get("radius", 14.0))
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	for enemy in get_enemies_in_radius(target.global_position, radius, int(caster.team_id)):
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.SLOWED), maxf(0.2, float(effects.get("apply_slow_sec", 4.0))))
			enemy.call("apply_status", int(UnitController.StatusId.MISINFORMATION), maxf(0.2, float(effects.get("apply_misinformation_sec", 4.0))))
	_play_unique_skill_vfx(caster, cfg, target.global_position, radius)
	return true

func _cast_unique_frontal_cleave_pressure(caster, cfg: Dictionary) -> bool:
	var radius: float = float(cfg.get("range", 12.0))
	var cone_deg: float = float(cfg.get("cone_angle_deg", 70.0))
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	var primary_target = _pick_unique_skill_target(caster, cfg)
	var face_dir: Vector3 = _get_unique_skill_face_dir(caster, primary_target)
	var targets: Array = _get_units_in_frontal_cone(caster, radius, cone_deg, face_dir)
	if targets.is_empty() and primary_target != null and is_instance_valid(primary_target) and not primary_target.dead:
		targets.append(primary_target)
	if targets.is_empty():
		targets = get_enemies_in_radius(caster.global_position, radius, int(caster.team_id))
	if targets.is_empty():
		return false
	var base_damage: float = _read_unit_attack_power(caster) * float(effects.get("front_damage_mul", 1.6))
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		enemy.receive_damage(base_damage, caster)
		_adjust_unit_morale(enemy, -float(effects.get("morale_damage_flat", 0.0)))
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.COUNTERED), maxf(0.2, float(effects.get("apply_countered_sec", 3.0))))
	_play_unique_skill_vfx(caster, cfg, caster.global_position + face_dir * (radius * 0.5), radius)
	return true
func _cast_unique_cone_roar_disrupt(caster, cfg: Dictionary) -> bool:
	var radius: float = float(cfg.get("range", 14.0))
	var cone_deg: float = float(cfg.get("cone_angle_deg", 90.0))
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	var primary_target = _pick_unique_skill_target(caster, cfg)
	var face_dir: Vector3 = _get_unique_skill_face_dir(caster, primary_target)
	var targets: Array = _get_units_in_frontal_cone(caster, radius, cone_deg, face_dir)
	if targets.is_empty() and primary_target != null and is_instance_valid(primary_target) and not primary_target.dead:
		targets.append(primary_target)
	if targets.is_empty():
		targets = get_enemies_in_radius(caster.global_position, radius, int(caster.team_id))
	if targets.is_empty():
		return false
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		_adjust_unit_morale(enemy, -float(effects.get("morale_damage_flat", 0.0)))
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.PARALYZED), maxf(0.12, float(effects.get("apply_paralyze_sec", 0.8))))
			enemy.call("apply_status", int(UnitController.StatusId.CONFUSION), maxf(0.2, float(effects.get("apply_confusion_sec", 3.0))))
	_play_unique_skill_vfx(caster, cfg, caster.global_position + face_dir * (radius * 0.4), radius)
	return true
func _cast_unique_area_fire_burst(caster, cfg: Dictionary) -> bool:
	if is_fire_blocked_by_weather():
		_set_battle_status("Rain blocks fire-based unique skills.")
		return false
	var target = _pick_unique_skill_target(caster, cfg)
	if target == null or not is_instance_valid(target) or target.dead:
		return false
	var radius: float = float(cfg.get("radius", 13.0))
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	var base_damage: float = _read_unit_attack_power(caster) * 0.55 * float(effects.get("initial_magic_damage_mul", 1.4))
	var burn_sec: float = float(effects.get("apply_burning_sec", 8.0))
	var burn_dps: float = float(effects.get("burn_damage_per_sec", 5.0))
	for enemy in get_enemies_in_radius(target.global_position, radius, int(caster.team_id)):
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		enemy.receive_damage(base_damage, caster)
		if enemy.has_method("apply_burn"):
			enemy.call("apply_burn", burn_sec, burn_dps, int(caster.team_id))
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.CONFUSION), maxf(0.2, float(effects.get("apply_confusion_sec", 0.0))))
	_play_unique_skill_vfx(caster, cfg, target.global_position, radius * 2.0)
	return true

func _cast_unique_chain_fire_spread(caster, cfg: Dictionary) -> bool:
	if is_fire_blocked_by_weather():
		_set_battle_status("Rain blocks fire-based unique skills.")
		return false
	var target = _pick_unique_skill_target(caster, cfg)
	if target == null or not is_instance_valid(target) or target.dead:
		return false
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	var spread_radius: float = float(effects.get("spread_radius", 8.0))
	var spread_count: int = maxi(1, int(effects.get("spread_count", 3)))
	var burn_sec: float = float(effects.get("apply_burning_sec", 8.0))
	var burn_dps: float = float(effects.get("burn_damage_per_sec", 4.5))
	var impacted: Array = []
	for enemy in get_enemies_in_radius(target.global_position, spread_radius, int(caster.team_id)):
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		impacted.append(enemy)
	if impacted.is_empty():
		impacted.append(target)
	var base_damage: float = _read_unit_attack_power(caster) * 0.38
	var count: int = 0
	for enemy in impacted:
		if count > spread_count:
			break
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		var damage_mul: float = 1.0
		if enemy.has_method("is_burning") and bool(enemy.call("is_burning")):
			damage_mul += float(effects.get("bonus_vs_burning_pct", 0.0))
		enemy.receive_damage(base_damage * damage_mul, caster)
		if enemy.has_method("apply_burn"):
			enemy.call("apply_burn", burn_sec, burn_dps, int(caster.team_id))
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.COUNTERED), maxf(0.2, float(effects.get("apply_countered_sec", 4.0))))
		count += 1
	_play_unique_skill_vfx(caster, cfg, target.global_position, spread_radius * 1.8)
	return true

func _cast_unique_dash_assault(caster, cfg: Dictionary) -> bool:
	var target = _pick_unique_skill_target(caster, cfg)
	if target == null or not is_instance_valid(target) or target.dead:
		return false
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	var damage_mul: float = float(effects.get("impact_damage_mul", 1.6))
	var damage: float = _read_unit_attack_power(caster) * damage_mul
	var role_id: String = str(target.get("combat_role_id")).strip_edges().to_lower()
	if role_id == "archer" or role_id == "crossbow":
		damage *= 1.0 + float(effects.get("bonus_vs_ranged_pct", 0.0))
	if role_id == "strategist":
		damage *= 1.0 + float(effects.get("bonus_vs_strategist_pct", 0.0))
	target.receive_damage(damage, caster)
	_adjust_unit_morale(target, -float(effects.get("impact_morale_damage_flat", 0.0)))
	if target.has_method("apply_status"):
		target.call("apply_status", int(UnitController.StatusId.CONFUSION), maxf(0.2, float(effects.get("apply_confusion_sec", effects.get("apply_disrupt_sec", 2.5)))))
	if caster.has_method("apply_status"):
		caster.call("apply_status", int(UnitController.StatusId.HIGH_MORALE), maxf(0.2, float(cfg.get("duration_sec", 4.0))))
	_play_unique_skill_vfx(caster, cfg, target.global_position, maxf(6.0, float(cfg.get("range", 12.0))))
	return true

func _cast_unique_self_berserk_buff(caster, cfg: Dictionary) -> bool:
	var duration: float = float(cfg.get("duration_sec", 8.0))
	var effects: Dictionary = cfg.get("effects", {}) if cfg.get("effects", {}) is Dictionary else {}
	if caster.has_method("apply_status"):
		caster.call("apply_status", int(UnitController.StatusId.HIGH_MORALE), maxf(0.2, duration))
		caster.call("apply_status", int(UnitController.StatusId.TACTIC_BUFF), maxf(0.2, duration))
	_adjust_unit_morale(caster, float(effects.get("self_morale_gain_flat", 12.0)))
	_adjust_unit_spirit(caster, float(effects.get("self_spirit_gain_flat", 10.0)))
	_play_unique_skill_vfx(caster, cfg, caster.global_position, 10.0)
	return true

func _execute_unique_skill(caster, cfg: Dictionary) -> bool:
	var template_id: String = str(cfg.get("effect_template", "")).strip_edges().to_lower()
	match template_id:
		"team_aura_buff":
			return _cast_unique_team_aura_buff(caster, cfg)
		"team_cdr_support":
			return _cast_unique_team_cdr_support(caster, cfg)
		"morale_recover_cleanse":
			return _cast_unique_morale_recover_cleanse(caster, cfg)
		"single_interrupt_debuff":
			return _cast_unique_single_interrupt_debuff(caster, cfg)
		"area_control_zone":
			return _cast_unique_area_control_zone(caster, cfg)
		"frontal_cleave_pressure":
			return _cast_unique_frontal_cleave_pressure(caster, cfg)
		"cone_roar_disrupt":
			return _cast_unique_cone_roar_disrupt(caster, cfg)
		"area_fire_burst":
			return _cast_unique_area_fire_burst(caster, cfg)
		"chain_fire_spread":
			return _cast_unique_chain_fire_spread(caster, cfg)
		"charge_break_line", "flank_dash_assault":
			return _cast_unique_dash_assault(caster, cfg)
		"self_berserk_buff":
			return _cast_unique_self_berserk_buff(caster, cfg)
		_:
			return false

func _should_auto_cast_unique_skill(unit, cfg: Dictionary) -> bool:
	if unit == null or not is_instance_valid(unit) or cfg.is_empty():
		return false
	var template_id: String = str(cfg.get("effect_template", "")).strip_edges().to_lower()
	var rules: Dictionary = cfg.get("auto_cast_rules", {}) if cfg.get("auto_cast_rules", {}) is Dictionary else {}
	var target = _pick_unique_skill_target(unit, cfg)
	var close_enemy_count: int = _count_enemy_units_near(unit.global_position, 10.5, int(unit.team_id))
	var hp_ratio: float = _read_unit_hp_ratio(unit)
	var melee_state: bool = int(unit.get("state")) == int(UnitController.UnitState.MELEE)
	match template_id:
		"team_aura_buff":
			var ally_count: int = _get_friendly_units_in_radius(unit.global_position, float(cfg.get("radius", 18.0)), int(unit.team_id)).size()
			return ally_count >= int(rules.get("min_allies_in_combat", 2)) and close_enemy_count >= int(rules.get("min_enemies_in_radius", 2))
		"team_cdr_support":
			var allies: Array = _get_friendly_units_in_radius(unit.global_position, float(cfg.get("radius", 18.0)), int(unit.team_id))
			var ready_count: int = 0
			for ally in allies:
				if ally == null or not is_instance_valid(ally) or ally.dead:
					continue
				var skill_cds_any: Variant = ally.get("skill_cooldowns")
				if skill_cds_any is Dictionary and not (skill_cds_any as Dictionary).is_empty():
					ready_count += 1
			return ready_count >= int(rules.get("min_allies_with_skill_on_cooldown", 2))
		"morale_recover_cleanse":
			for ally in _get_friendly_units_in_radius(unit.global_position, float(cfg.get("radius", 18.0)), int(unit.team_id)):
				if ally == null or not is_instance_valid(ally) or ally.dead:
					continue
				if float(ally.get("morale_current")) <= 55.0:
					return true
				if ally.has_method("has_status") and (bool(ally.call("has_status", int(UnitController.StatusId.CONFUSION))) or bool(ally.call("has_status", int(UnitController.StatusId.SLOWED))) or bool(ally.call("has_status", int(UnitController.StatusId.MISINFORMATION)))):
					return true
			return false
		"single_interrupt_debuff":
			return target != null
		"area_control_zone", "area_fire_burst", "chain_fire_spread", "frontal_cleave_pressure", "cone_roar_disrupt":
			return close_enemy_count >= 2 or melee_state
		"charge_break_line", "flank_dash_assault":
			if target == null or not is_instance_valid(target):
				return false
			var to_target: Vector3 = target.global_position - unit.global_position
			to_target.y = 0.0
			var range_limit: float = maxf(6.0, float(cfg.get("range", 16.0)))
			return melee_state or close_enemy_count >= 1 or to_target.length() <= range_limit * 1.8
		"self_berserk_buff":
			return hp_ratio <= float(rules.get("self_hp_below_ratio", 0.60)) or close_enemy_count >= 2
		_:
			return target != null or close_enemy_count >= 2
func _rules_role_array(value: Variant, fallback: PackedStringArray) -> PackedStringArray:
	var out := PackedStringArray()
	if value is Array:
		for role_any in (value as Array):
			var role_id: String = String(role_any).strip_edges().to_lower()
			if role_id.is_empty():
				continue
			out.append(role_id)
	return fallback if out.is_empty() else out

func _rules_dict_or_fallback(value: Variant, fallback: Dictionary) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return fallback.duplicate(true)

func _apply_battle_rules(battle_rules: Dictionary) -> void:
	units_per_team = maxi(1, int(battle_rules.get("demo_units_per_team", units_per_team)))
	soldiers_per_unit = maxi(8, int(battle_rules.get("demo_soldiers_per_unit", soldiers_per_unit)))
	team_spacing_x = maxf(8.0, float(battle_rules.get("demo_team_spacing_x", team_spacing_x)))
	team_front_offset_z = maxf(28.0, float(battle_rules.get("demo_front_offset_z", team_front_offset_z)))
	unit_node_scale = maxf(0.2, float(battle_rules.get("demo_unit_node_scale", unit_node_scale)))
	raycast_length = maxf(5000.0, float(battle_rules.get("demo_raycast_length", raycast_length)))
	infantry_model_scale_mul = maxf(1.0, float(battle_rules.get("demo_infantry_scale_mul", infantry_model_scale_mul)))
	cavalry_model_scale_mul = maxf(1.0, float(battle_rules.get("demo_cavalry_scale_mul", cavalry_model_scale_mul)))
	spear_model_scale_mul = maxf(1.0, float(battle_rules.get("demo_spear_scale_mul", spear_model_scale_mul)))
	archer_model_scale_mul = maxf(1.0, float(battle_rules.get("demo_archer_scale_mul", archer_model_scale_mul)))
	archer_role_attack_range = maxf(6.0, float(battle_rules.get("demo_archer_attack_range", archer_role_attack_range)))
	archer_role_attack_interval = maxf(0.2, float(battle_rules.get("demo_archer_attack_interval", archer_role_attack_interval)))
	unit_base_max_hp = maxf(1.0, float(battle_rules.get("demo_unit_max_hp", unit_base_max_hp)))
	unit_base_attack_damage = maxf(0.1, float(battle_rules.get("demo_unit_attack_damage", unit_base_attack_damage)))
	auto_engage_max_distance = maxf(maxf(120.0, auto_engage_max_distance), team_front_offset_z * 3.0)
	lod_enabled = bool(battle_rules.get("demo_lod_enabled", lod_enabled))
	lod_update_interval = maxf(0.06, float(battle_rules.get("demo_lod_update_interval", lod_update_interval)))
	lod_soldier_visible_depth = maxf(120.0, float(battle_rules.get("demo_lod_soldier_visible_depth", lod_soldier_visible_depth)))
	lod_soldier_hysteresis_depth = maxf(0.0, float(battle_rules.get("demo_lod_soldier_hysteresis_depth", lod_soldier_hysteresis_depth)))
	lod_engaged_hold_sec = maxf(0.1, float(battle_rules.get("demo_lod_engaged_hold_sec", lod_engaged_hold_sec)))
	lod_tag_visible_max_depth = maxf(240.0, float(battle_rules.get("demo_lod_tag_visible_max_depth", lod_tag_visible_max_depth)))
	unit_tag_near_distance = maxf(1.0, float(battle_rules.get("demo_unit_tag_near_distance", unit_tag_near_distance)))
	unit_tag_far_distance = maxf(unit_tag_near_distance + 1.0, float(battle_rules.get("demo_unit_tag_far_distance", unit_tag_far_distance)))
	unit_tag_near_ops_depth = maxf(0.0, float(battle_rules.get("demo_unit_tag_near_ops_depth", unit_tag_near_ops_depth)))
	unit_tag_text_refresh_interval = maxf(0.05, float(battle_rules.get("demo_tag_text_refresh_interval", unit_tag_text_refresh_interval)))
	unit_tag_position_refresh_interval = maxf(0.02, float(battle_rules.get("demo_tag_position_refresh_interval", unit_tag_position_refresh_interval)))
	lod_preserve_player_ops_depth = maxf(0.0, float(battle_rules.get("demo_lod_player_ops_preserve_depth", lod_preserve_player_ops_depth)))
	unit_tag_far_perf_enabled = bool(battle_rules.get("demo_tag_far_perf_enabled", unit_tag_far_perf_enabled))
	unit_tag_far_depth = maxf(unit_tag_near_ops_depth + 1.0, float(battle_rules.get("demo_tag_far_depth", unit_tag_far_depth)))
	unit_tag_very_far_depth = maxf(unit_tag_far_depth + 1.0, float(battle_rules.get("demo_tag_very_far_depth", unit_tag_very_far_depth)))
	unit_tag_far_position_stride = maxi(1, int(battle_rules.get("demo_tag_far_position_stride", unit_tag_far_position_stride)))
	unit_tag_very_far_position_stride = maxi(unit_tag_far_position_stride, int(battle_rules.get("demo_tag_very_far_position_stride", unit_tag_very_far_position_stride)))
	unit_tag_far_text_stride = maxi(1, int(battle_rules.get("demo_tag_far_text_stride", unit_tag_far_text_stride)))
	unit_tag_very_far_text_stride = maxi(unit_tag_far_text_stride, int(battle_rules.get("demo_tag_very_far_text_stride", unit_tag_very_far_text_stride)))
	commander_report_enabled = bool(battle_rules.get("demo_commander_report_enabled", commander_report_enabled))
	commander_report_duration = maxf(1.0, float(battle_rules.get("demo_commander_report_duration", commander_report_duration)))
	commander_report_keep_lines = maxi(1, int(battle_rules.get("demo_commander_report_keep_lines", commander_report_keep_lines)))
	commander_report_supply_events_enabled = bool(battle_rules.get("demo_commander_report_supply_events_enabled", commander_report_supply_events_enabled))
	commander_report_facility_events_enabled = bool(battle_rules.get("demo_commander_report_facility_events_enabled", commander_report_facility_events_enabled))
	commander_report_supply_cooldown_sec = maxf(0.5, float(battle_rules.get("demo_commander_report_supply_cooldown_sec", commander_report_supply_cooldown_sec)))
	unit_skill_cd_charge = maxf(0.0, float(battle_rules.get("demo_skill_cd_charge", unit_skill_cd_charge)))
	unit_skill_cd_breakthrough = maxf(0.0, float(battle_rules.get("demo_skill_cd_breakthrough", unit_skill_cd_breakthrough)))
	unit_skill_cd_sweep = maxf(0.0, float(battle_rules.get("demo_skill_cd_sweep", unit_skill_cd_sweep)))
	unit_skill_spirit_cost_charge = maxf(0.0, float(battle_rules.get("demo_skill_spirit_cost_charge", unit_skill_spirit_cost_charge)))
	unit_skill_spirit_cost_breakthrough = maxf(0.0, float(battle_rules.get("demo_skill_spirit_cost_breakthrough", unit_skill_spirit_cost_breakthrough)))
	unit_skill_spirit_cost_sweep = maxf(0.0, float(battle_rules.get("demo_skill_spirit_cost_sweep", unit_skill_spirit_cost_sweep)))
	unit_skill_will_cost_charge = maxf(0.0, float(battle_rules.get("demo_skill_will_cost_charge", unit_skill_will_cost_charge)))
	unit_skill_will_cost_breakthrough = maxf(0.0, float(battle_rules.get("demo_skill_will_cost_breakthrough", unit_skill_will_cost_breakthrough)))
	unit_skill_will_cost_sweep = maxf(0.0, float(battle_rules.get("demo_skill_will_cost_sweep", unit_skill_will_cost_sweep)))
	soldier_formation_spacing = maxf(0.3, float(battle_rules.get("demo_soldier_formation_spacing", soldier_formation_spacing)))
	lod_show_tag_when_near = bool(battle_rules.get("demo_show_tag_when_near", lod_show_tag_when_near))
	show_unit_tags = bool(battle_rules.get("demo_show_unit_tags", show_unit_tags))
	team_a_unit_roles = _rules_role_array(battle_rules.get("demo_team_a_unit_roles", team_a_unit_roles), team_a_unit_roles)
	team_b_unit_roles = _rules_role_array(battle_rules.get("demo_team_b_unit_roles", team_b_unit_roles), team_b_unit_roles)
	unit_tag_height_offset = clampf(float(battle_rules.get("demo_tag_height_offset", unit_tag_height_offset)), 2.0, 40.0)
	unit_tag_near_scale = clampf(float(battle_rules.get("demo_tag_near_scale", unit_tag_near_scale)), 0.08, 2.0)
	unit_tag_far_scale = clampf(float(battle_rules.get("demo_tag_far_scale", unit_tag_far_scale)), 0.05, unit_tag_near_scale)
	soldier_use_model_albedo_texture = bool(battle_rules.get("demo_use_model_albedo_texture", soldier_use_model_albedo_texture))
	soldier_team_tint_strength = clampf(float(battle_rules.get("demo_team_tint_strength", soldier_team_tint_strength)), 0.0, 1.0)
	melee_frontline_width_mul = clampf(float(battle_rules.get("demo_melee_frontline_width_mul", melee_frontline_width_mul)), 0.5, 3.0)
	melee_frontline_depth_mul = clampf(float(battle_rules.get("demo_melee_frontline_depth_mul", melee_frontline_depth_mul)), 0.4, 2.5)
	melee_contact_distance_mul = clampf(float(battle_rules.get("demo_melee_contact_distance_mul", melee_contact_distance_mul)), 0.7, 2.5)
	melee_contact_distance_bias = clampf(float(battle_rules.get("demo_melee_contact_distance_bias", melee_contact_distance_bias)), 0.0, 8.0)
	melee_activity_radius_mul = clampf(float(battle_rules.get("demo_melee_activity_radius_mul", melee_activity_radius_mul)), 0.5, 3.0)
	melee_activity_radius_visual_weight = clampf(float(battle_rules.get("demo_melee_activity_radius_visual_weight", melee_activity_radius_visual_weight)), 0.0, 1.0)
	unit_player_force_chase_sec = maxf(0.0, float(battle_rules.get("demo_player_force_chase_sec", unit_player_force_chase_sec)))
	unit_player_force_chase_max_distance = maxf(32.0, float(battle_rules.get("demo_player_force_chase_max_distance", unit_player_force_chase_max_distance)))
	unit_player_force_chase_never_timeout = bool(battle_rules.get("demo_player_force_chase_never_timeout", unit_player_force_chase_never_timeout))
	unit_player_force_chase_ignore_distance = bool(battle_rules.get("demo_player_force_chase_ignore_distance", unit_player_force_chase_ignore_distance))
	unit_nav_goal_retry_max_attempts = maxi(0, int(battle_rules.get("demo_nav_goal_retry_max_attempts", unit_nav_goal_retry_max_attempts)))
	unit_nav_goal_retry_radius_step = maxf(0.5, float(battle_rules.get("demo_nav_goal_retry_radius_step", unit_nav_goal_retry_radius_step)))
	unit_nav_goal_retry_directions = maxi(4, int(battle_rules.get("demo_nav_goal_retry_directions", unit_nav_goal_retry_directions)))
	unit_nav_goal_retry_snap_distance_mul = maxf(1.0, float(battle_rules.get("demo_nav_goal_retry_snap_distance_mul", unit_nav_goal_retry_snap_distance_mul)))
	unit_morale_loss_per_10pct_troop = maxf(0.0, float(battle_rules.get("demo_morale_loss_per_10pct_troop", unit_morale_loss_per_10pct_troop)))
	unit_morale_stat_penalty_per_10 = clampf(float(battle_rules.get("demo_morale_stat_penalty_per_10", unit_morale_stat_penalty_per_10)), 0.0, 0.3)
	unit_morale_zero_hp_loss_per_sec = maxf(0.0, float(battle_rules.get("demo_morale_zero_hp_loss_per_sec", unit_morale_zero_hp_loss_per_sec)))
	unit_rout_troop_ratio_normal = clampf(float(battle_rules.get("demo_rout_troop_ratio_normal", unit_rout_troop_ratio_normal)), 0.01, 0.95)
	unit_rout_troop_ratio_garrison = clampf(float(battle_rules.get("demo_rout_troop_ratio_garrison", unit_rout_troop_ratio_garrison)), 0.01, 0.95)
	unit_garrison_morale_loss_mul = clampf(float(battle_rules.get("demo_garrison_morale_loss_mul", unit_garrison_morale_loss_mul)), 0.05, 1.0)
	unit_morale_loss_countered_bonus = maxf(0.0, float(battle_rules.get("demo_morale_loss_countered_bonus", unit_morale_loss_countered_bonus)))
	unit_morale_loss_flanked_bonus = maxf(0.0, float(battle_rules.get("demo_morale_loss_flanked_bonus", unit_morale_loss_flanked_bonus)))
	unit_morale_loss_out_of_supply_per_sec = maxf(0.0, float(battle_rules.get("demo_morale_loss_out_of_supply_per_sec", unit_morale_loss_out_of_supply_per_sec)))
	unit_morale_loss_special_terrain_per_sec = maxf(0.0, float(battle_rules.get("demo_morale_loss_special_terrain_per_sec", unit_morale_loss_special_terrain_per_sec)))
	unit_morale_loss_burning_per_sec = maxf(0.0, float(battle_rules.get("demo_morale_loss_burning_per_sec", unit_morale_loss_burning_per_sec)))
	terrain_adaptation_enabled = bool(battle_rules.get("demo_terrain_adaptation_enabled", terrain_adaptation_enabled))
	terrain_adaptation_interval_sec = maxf(0.1, float(battle_rules.get("demo_terrain_adaptation_interval_sec", terrain_adaptation_interval_sec)))
	terrain_status_hold_sec = maxf(0.1, float(battle_rules.get("demo_terrain_status_hold_sec", terrain_status_hold_sec)))
	demo_naval_enabled = bool(battle_rules.get("demo_naval_enabled", demo_naval_enabled))
	demo_naval_auto_embark = bool(battle_rules.get("demo_naval_auto_embark", demo_naval_auto_embark))
	demo_naval_ferry_radius = maxf(1.0, float(battle_rules.get("demo_naval_ferry_radius", demo_naval_ferry_radius)))
	demo_naval_shoal_radius = maxf(0.5, float(battle_rules.get("demo_naval_shoal_radius", demo_naval_shoal_radius)))
	demo_naval_default_ship_type = _normalize_ship_type_id(String(battle_rules.get("demo_naval_default_ship_type", demo_naval_default_ship_type)))
	demo_naval_default_ship_type_by_role = _rules_dict_or_fallback(
		battle_rules.get("demo_naval_default_ship_type_by_role", demo_naval_default_ship_type_by_role),
		demo_naval_default_ship_type_by_role
	)
	_demo_naval_ferry_cache_ready = false
	_demo_naval_ferry_points.clear()
	demo_siege_vs_facility_enabled = bool(battle_rules.get("demo_siege_vs_facility_enabled", demo_siege_vs_facility_enabled))
	demo_siege_vs_facility_dps_scale = maxf(0.0, float(battle_rules.get("demo_siege_vs_facility_dps_scale", demo_siege_vs_facility_dps_scale)))
	demo_siege_facility_destroy_log_enabled = bool(battle_rules.get("demo_siege_facility_destroy_log_enabled", demo_siege_facility_destroy_log_enabled))
	demo_siege_ai_priority_enabled = bool(battle_rules.get("demo_siege_ai_priority_enabled", demo_siege_ai_priority_enabled))
	demo_siege_ai_apply_to_player_team = bool(battle_rules.get("demo_siege_ai_apply_to_player_team", demo_siege_ai_apply_to_player_team))
	demo_siege_ai_order_interval = maxf(0.1, float(battle_rules.get("demo_siege_ai_order_interval", demo_siege_ai_order_interval)))
	demo_siege_ai_retarget_tolerance = maxf(1.0, float(battle_rules.get("demo_siege_ai_retarget_tolerance", demo_siege_ai_retarget_tolerance)))
	demo_siege_ai_only_facility_mode = bool(battle_rules.get("demo_siege_ai_only_facility_mode", demo_siege_ai_only_facility_mode))
	demo_siege_objective_enabled = bool(battle_rules.get("demo_siege_objective_enabled", demo_siege_objective_enabled))
	demo_siege_objective_require_all_city_falls = bool(battle_rules.get("demo_siege_objective_require_all_city_falls", demo_siege_objective_require_all_city_falls))
	demo_siege_objective_report_enabled = bool(battle_rules.get("demo_siege_objective_report_enabled", demo_siege_objective_report_enabled))
	demo_siege_objective_status_hold_sec = maxf(0.5, float(battle_rules.get("demo_siege_objective_status_hold_sec", demo_siege_objective_status_hold_sec)))
	demo_siege_objective_panel_enabled = bool(battle_rules.get("demo_siege_objective_panel_enabled", demo_siege_objective_panel_enabled))
	demo_siege_objective_panel_refresh_sec = maxf(0.1, float(battle_rules.get("demo_siege_objective_panel_refresh_sec", demo_siege_objective_panel_refresh_sec)))
	demo_siege_objective_panel_show_prediction = bool(battle_rules.get("demo_siege_objective_panel_show_prediction", demo_siege_objective_panel_show_prediction))
	demo_siege_variant_skill_enabled = bool(battle_rules.get("demo_siege_variant_skill_enabled", demo_siege_variant_skill_enabled))
	demo_siege_skill_cd_ram = maxf(2.0, float(battle_rules.get("demo_siege_skill_cd_ram", demo_siege_skill_cd_ram)))
	demo_siege_skill_cd_ladder = maxf(2.0, float(battle_rules.get("demo_siege_skill_cd_ladder", demo_siege_skill_cd_ladder)))
	demo_siege_skill_cd_catapult = maxf(2.0, float(battle_rules.get("demo_siege_skill_cd_catapult", demo_siege_skill_cd_catapult)))
	demo_siege_skill_ram_bonus_sec = maxf(0.1, float(battle_rules.get("demo_siege_skill_ram_bonus_sec", demo_siege_skill_ram_bonus_sec)))
	demo_siege_skill_ladder_bonus_sec = maxf(0.1, float(battle_rules.get("demo_siege_skill_ladder_bonus_sec", demo_siege_skill_ladder_bonus_sec)))
	demo_siege_skill_catapult_bonus_sec = maxf(0.1, float(battle_rules.get("demo_siege_skill_catapult_bonus_sec", demo_siege_skill_catapult_bonus_sec)))
	demo_siege_debug_overlay_enabled = bool(battle_rules.get("demo_siege_debug_overlay_enabled", demo_siege_debug_overlay_enabled))
	demo_siege_debug_overlay_refresh_sec = maxf(0.1, float(battle_rules.get("demo_siege_debug_overlay_refresh_sec", demo_siege_debug_overlay_refresh_sec)))
	demo_siege_facility_hp_by_type = _rules_dict_or_fallback(battle_rules.get("demo_siege_facility_hp_by_type", demo_siege_facility_hp_by_type), demo_siege_facility_hp_by_type)
	demo_siege_facility_attack_radius_by_type = _rules_dict_or_fallback(battle_rules.get("demo_siege_facility_attack_radius_by_type", demo_siege_facility_attack_radius_by_type), demo_siege_facility_attack_radius_by_type)
	demo_siege_role_damage_mul = _rules_dict_or_fallback(battle_rules.get("demo_siege_role_damage_mul", demo_siege_role_damage_mul), demo_siege_role_damage_mul)
	demo_siege_target_damage_mul = _rules_dict_or_fallback(battle_rules.get("demo_siege_target_damage_mul", demo_siege_target_damage_mul), demo_siege_target_damage_mul)
	demo_siege_variant_effects = _rules_dict_or_fallback(battle_rules.get("demo_siege_variant_effects", demo_siege_variant_effects), demo_siege_variant_effects)
	demo_recon_enabled = bool(battle_rules.get("demo_recon_enabled", demo_recon_enabled))
	demo_recon_tick_interval = maxf(0.05, float(battle_rules.get("demo_recon_tick_interval", demo_recon_tick_interval)))
	demo_recon_spot_duration_sec = maxf(0.5, float(battle_rules.get("demo_recon_spot_duration_sec", demo_recon_spot_duration_sec)))
	demo_recon_scout_vision_mul = clampf(float(battle_rules.get("demo_recon_scout_vision_mul", demo_recon_scout_vision_mul)), 0.5, 3.0)
	demo_recon_player_team_id = maxi(0, int(battle_rules.get("demo_recon_player_team_id", demo_recon_player_team_id)))
	demo_recon_lost_log_enabled = bool(battle_rules.get("demo_recon_lost_log_enabled", demo_recon_lost_log_enabled))
	demo_recon_day_phase_vision_mul = _rules_dict_or_fallback(battle_rules.get("demo_recon_day_phase_vision_mul", demo_recon_day_phase_vision_mul), demo_recon_day_phase_vision_mul)
	demo_recon_weather_vision_mul = _rules_dict_or_fallback(battle_rules.get("demo_recon_weather_vision_mul", demo_recon_weather_vision_mul), demo_recon_weather_vision_mul)
	demo_recon_day_phase_spot_duration_mul = _rules_dict_or_fallback(battle_rules.get("demo_recon_day_phase_spot_duration_mul", demo_recon_day_phase_spot_duration_mul), demo_recon_day_phase_spot_duration_mul)
	demo_recon_weather_spot_duration_mul = _rules_dict_or_fallback(battle_rules.get("demo_recon_weather_spot_duration_mul", demo_recon_weather_spot_duration_mul), demo_recon_weather_spot_duration_mul)
	role_counter_damage_matrix = _rules_dict_or_fallback(battle_rules.get("demo_role_counter_damage_matrix", role_counter_damage_matrix), role_counter_damage_matrix)
	role_terrain_profiles = _rules_dict_or_fallback(battle_rules.get("demo_role_terrain_profiles", role_terrain_profiles), role_terrain_profiles)
	height_advantage_enabled = bool(battle_rules.get("demo_height_advantage_enabled", height_advantage_enabled))
	height_advantage_rules = _rules_dict_or_fallback(battle_rules.get("demo_height_advantage_rules", height_advantage_rules), height_advantage_rules)
	role_height_modifiers = _rules_dict_or_fallback(battle_rules.get("demo_role_height_modifiers", role_height_modifiers), role_height_modifiers)
	soft_repulsion_include_same_team = bool(battle_rules.get("demo_soft_repulsion_include_same_team", soft_repulsion_include_same_team))
	soft_repulsion_same_team_strength = maxf(0.1, float(battle_rules.get("demo_soft_repulsion_same_team_strength", soft_repulsion_same_team_strength)))
	soft_repulsion_enemy_strength = maxf(0.1, float(battle_rules.get("demo_soft_repulsion_enemy_strength", soft_repulsion_enemy_strength)))
	soft_repulsion_base_padding = maxf(0.0, float(battle_rules.get("demo_soft_repulsion_base_padding", soft_repulsion_base_padding)))
	soft_repulsion_radius_mul = maxf(0.25, float(battle_rules.get("demo_soft_repulsion_radius_mul", soft_repulsion_radius_mul)))
	spear_override_model_path = str(battle_rules.get("demo_spear_override_model_path", spear_override_model_path))
	spear_override_albedo_path = str(battle_rules.get("demo_spear_override_albedo_path", spear_override_albedo_path))
	archer_override_model_path = str(battle_rules.get("demo_archer_override_model_path", archer_override_model_path))
	archer_override_albedo_path = str(battle_rules.get("demo_archer_override_albedo_path", archer_override_albedo_path))
	infantry_override_albedo_path = str(battle_rules.get("demo_infantry_override_albedo_path", infantry_override_albedo_path))
	cavalry_override_albedo_path = str(battle_rules.get("demo_cavalry_override_albedo_path", cavalry_override_albedo_path))

func _apply_weather_context() -> void:
	var weather_ctx: Dictionary = {}
	if _weather_context_pending.has("weather") and _weather_context_pending.get("weather", null) is Dictionary:
		weather_ctx = (_weather_context_pending.get("weather", {}) as Dictionary).duplicate(true)
	elif _weather_context_pending.has("state"):
		weather_ctx = _weather_context_pending.duplicate(true)
	var default_state: String = String(weather_settings.get("default_weather_state", "sunny"))
	var default_wind: Variant = weather_settings.get("default_wind_dir", [1.0, 0.0])
	var default_strength: float = float(weather_settings.get("default_wind_strength", 0.0))
	var state: String = _normalize_recon_weather_state(String(weather_ctx.get("state", default_state)))
	var wind_dir: Vector2 = _raw_wind_to_vec2(weather_ctx.get("wind_dir", default_wind))
	var wind_strength: float = float(weather_ctx.get("wind_strength", default_strength))
	var phase_raw: String = String(weather_ctx.get("day_phase", weather_ctx.get("phase", _weather_context_pending.get("day_phase", _weather_context_pending.get("phase", weather_day_phase)))))
	weather_day_phase = _normalize_recon_day_phase(phase_raw)
	_set_weather_state(state, wind_dir, wind_strength, false)

func _set_weather_state(state: String, wind_dir: Vector2, wind_strength: float, publish: bool = true) -> void:
	weather_state = _normalize_recon_weather_state(state)
	weather_wind_dir = wind_dir.normalized() if wind_dir.length() > 0.001 else Vector2.RIGHT
	weather_wind_strength = maxf(0.0, wind_strength)
	if _is_rain_like_weather() and bool(weather_settings.get("rain_clears_burn", true)):
		_clear_all_burns()
	if publish:
		weather_state_changed.emit({
			"state": weather_state,
			"day_phase": weather_day_phase,
			"wind_dir": [weather_wind_dir.x, weather_wind_dir.y],
			"wind_strength": weather_wind_strength
		})

func _is_rain_like_weather() -> bool:
	return weather_state == "rain" or weather_state == "storm"

func _is_overcast_weather() -> bool:
	return weather_state == "cloudy" or weather_state == "windy"

func is_fire_blocked_by_weather() -> bool:
	return bool(weather_settings.get("rain_blocks_fire", true)) and _is_rain_like_weather()

func _is_thunder_cast_weather() -> bool:
	return _is_rain_like_weather() or _is_overcast_weather()

func _is_wind_spread_weather() -> bool:
	return weather_state == "windy" or weather_state == "storm"

func _raw_wind_to_vec2(raw: Variant) -> Vector2:
	if raw is Array:
		var arr: Array = raw
		if arr.size() >= 2:
			return Vector2(float(arr[0]), float(arr[1]))
	return Vector2.RIGHT

func _ensure_role_balance_defaults() -> void:
	if role_counter_damage_matrix.is_empty():
		role_counter_damage_matrix = {
			"spear": {"cavalry": 1.24, "scout": 1.18},
			"cavalry": {"archer": 1.2, "crossbow": 1.16, "siege": 1.22, "strategist": 1.22},
			"archer": {"spear": 1.12, "strategist": 1.08},
			"crossbow": {"shield": 1.15, "spear": 1.1},
			"shield": {"archer": 1.08, "crossbow": 1.08},
			"siege": {"shield": 1.18, "infantry": 1.1},
			"scout": {"archer": 1.08},
			"naval": {"siege": 1.08},
			"strategist": {"spear": 1.12, "shield": 1.18}
		}
	if role_terrain_profiles.is_empty():
		role_terrain_profiles = {
			"infantry": {"advantage": ["grass", "road"], "disadvantage": ["water"]},
			"shield": {"advantage": ["forest", "mountain"], "disadvantage": ["water", "swamp"]},
			"spear": {"advantage": ["hill", "mountain", "forest"], "disadvantage": ["swamp", "water"]},
			"cavalry": {"advantage": ["grass", "road"], "disadvantage": ["forest", "swamp", "mountain", "water"]},
			"archer": {"advantage": ["forest", "hill"], "disadvantage": ["swamp", "water"]},
			"crossbow": {"advantage": ["road", "grass"], "disadvantage": ["swamp", "water", "forest"]},
			"siege": {"advantage": ["road", "grass"], "disadvantage": ["forest", "swamp", "mountain", "water"]},
			"scout": {"advantage": ["road", "grass", "forest"], "disadvantage": ["water", "swamp"]},
			"naval": {"advantage": ["water"], "disadvantage": ["forest", "swamp", "mountain", "road", "grass"]},
			"strategist": {"advantage": ["road", "grass"], "disadvantage": ["swamp", "water", "mountain"]}
		}

func _ensure_height_advantage_defaults() -> void:
	if height_advantage_rules.is_empty():
		height_advantage_rules = {
			"height_diff_threshold": 2.0,
			"downhill_probe_distance": 6.0
		}
	if role_height_modifiers.is_empty():
		role_height_modifiers = {
			"archer": {"high_to_low_attack_mul": 1.15},
			"crossbow": {"high_to_low_attack_mul": 1.1},
			"cavalry": {"downhill_speed_mul": 1.2}
		}

func _normalize_role_id(raw: String) -> String:
	var role_id: String = raw.strip_edges().to_lower()
	if role_id.is_empty():
		return "infantry"
	return role_id

func _unit_role_id(unit) -> String:
	if unit == null or not is_instance_valid(unit):
		return "infantry"
	if unit.has_method("_get_self_role_id"):
		return _normalize_role_id(String(unit.call("_get_self_role_id")))
	return _normalize_role_id(String(unit.get("combat_role_id")))

func _unit_siege_variant_id(unit: UnitController) -> String:
	if unit == null or not is_instance_valid(unit):
		return ""
	var raw: String = ""
	if unit.has_meta("siege_variant"):
		raw = String(unit.get_meta("siege_variant", ""))
	var normalized: String = _normalize_siege_variant_id(raw)
	if normalized.is_empty() and _unit_role_id(unit) == "siege":
		return "ram"
	return normalized

func _siege_variant_cfg(variant_id: String) -> Dictionary:
	var key: String = _normalize_siege_variant_id(variant_id)
	if key.is_empty():
		return {}
	var cfg_any: Variant = demo_siege_variant_effects.get(key, {})
	return (cfg_any as Dictionary) if cfg_any is Dictionary else {}

func _cfg_float(cfg: Dictionary, key: String, fallback: float) -> float:
	if cfg.has(key):
		return float(cfg.get(key, fallback))
	return fallback

func _cfg_target_mul(cfg: Dictionary, table_key: String, target_key: String, fallback: float = 1.0) -> float:
	var table_any: Variant = cfg.get(table_key, {})
	if not (table_any is Dictionary):
		return fallback
	var table: Dictionary = table_any as Dictionary
	if table.has(target_key):
		return maxf(0.1, float(table.get(target_key, fallback)))
	if table.has("default"):
		return maxf(0.1, float(table.get("default", fallback)))
	return fallback

func _consume_siege_variant_proc(unit: UnitController, proc_suffix: String, cooldown_sec: float) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	var safe_cd: float = maxf(0.0, cooldown_sec)
	if safe_cd <= 0.001:
		return true
	var key: String = "%d|%s" % [unit.get_instance_id(), proc_suffix]
	var left: float = float(_siege_variant_proc_cooldowns.get(key, 0.0))
	if left > 0.001:
		return false
	_siege_variant_proc_cooldowns[key] = safe_cd
	return true

func get_siege_variant_unit_damage_mul(attacker: UnitController, defender: UnitController, _is_skill_hit: bool = false, is_ranged_hit: bool = false) -> float:
	if attacker == null or defender == null:
		return 1.0
	if not is_instance_valid(attacker) or not is_instance_valid(defender):
		return 1.0
	if _unit_role_id(attacker) != "siege":
		return 1.0
	var variant_id: String = _unit_siege_variant_id(attacker)
	if variant_id.is_empty():
		return 1.0
	var cfg: Dictionary = _siege_variant_cfg(variant_id)
	if cfg.is_empty():
		return 1.0
	var mul: float = maxf(0.1, _cfg_float(cfg, "unit_damage_mul", 1.0))
	if is_ranged_hit:
		mul *= maxf(0.1, _cfg_float(cfg, "ranged_damage_mul", 1.0))
	mul *= _cfg_target_mul(cfg, "target_role_mul", _unit_role_id(defender), 1.0)
	return clampf(mul, 0.1, 3.0)

func apply_siege_variant_on_hit(attacker: UnitController, defender: UnitController, dealt_damage: float, _is_skill_hit: bool = false, _is_ranged_hit: bool = false) -> void:
	if attacker == null or defender == null:
		return
	if not is_instance_valid(attacker) or not is_instance_valid(defender):
		return
	if dealt_damage <= 0.001 or defender.dead:
		return
	if _unit_role_id(attacker) != "siege":
		return
	var variant_id: String = _unit_siege_variant_id(attacker)
	if variant_id.is_empty():
		return
	var cfg: Dictionary = _siege_variant_cfg(variant_id)
	if cfg.is_empty():
		return
	match variant_id:
		"ram":
			var burn_chance: float = clampf(_cfg_float(cfg, "on_hit_burn_chance", 0.0), 0.0, 1.0)
			var burn_cd: float = maxf(0.0, _cfg_float(cfg, "on_hit_proc_cooldown_sec", 0.0))
			if burn_chance > 0.0 and _consume_siege_variant_proc(attacker, "ram_on_hit_burn", burn_cd) and randf() <= burn_chance:
				var burn_duration: float = maxf(0.1, _cfg_float(cfg, "on_hit_burn_duration_sec", 3.0))
				var burn_dps: float = maxf(0.1, _cfg_float(cfg, "on_hit_burn_dps", 3.0))
				if defender.has_method("apply_burn"):
					defender.call("apply_burn", burn_duration, burn_dps, int(attacker.team_id))
					_record_demo_siege_variant_proc(variant_id, "on_hit_burn")
		"ladder":
			var morale_damage: float = maxf(0.0, _cfg_float(cfg, "on_hit_morale_damage", 0.0))
			var morale_cd: float = maxf(0.0, _cfg_float(cfg, "on_hit_proc_cooldown_sec", 0.0))
			if morale_damage > 0.0 and _consume_siege_variant_proc(attacker, "ladder_on_hit_morale", morale_cd):
				if defender.has_method("_apply_morale_delta"):
					defender.call("_apply_morale_delta", -morale_damage, true)
					_record_demo_siege_variant_proc(variant_id, "on_hit_morale")
		"catapult":
			var splash_ratio: float = clampf(_cfg_float(cfg, "on_hit_splash_ratio", 0.0), 0.0, 1.0)
			var splash_radius: float = maxf(0.0, _cfg_float(cfg, "on_hit_splash_radius", 0.0))
			var splash_cd: float = maxf(0.0, _cfg_float(cfg, "on_hit_proc_cooldown_sec", 0.0))
			if splash_ratio <= 0.0 or splash_radius <= 0.001:
				return
			if not _consume_siege_variant_proc(attacker, "catapult_on_hit_splash", splash_cd):
				return
			var splash_damage: float = maxf(0.0, dealt_damage * splash_ratio)
			var splash_morale: float = maxf(0.0, _cfg_float(cfg, "on_hit_morale_damage", 0.0))
			var impacted: Array = get_enemies_in_radius(defender.global_position, splash_radius, int(attacker.team_id))
			var triggered: bool = false
			for enemy_any in impacted:
				if not (enemy_any is UnitController):
					continue
				var enemy: UnitController = enemy_any as UnitController
				if enemy == null or not is_instance_valid(enemy) or enemy.dead:
					continue
				if enemy == defender:
					continue
				if enemy.has_method("receive_damage") and splash_damage > 0.001:
					enemy.call("receive_damage", splash_damage, attacker, true)
					triggered = true
				if splash_morale > 0.001 and enemy.has_method("_apply_morale_delta"):
					enemy.call("_apply_morale_delta", -splash_morale, true)
					triggered = true
			if triggered:
				_record_demo_siege_variant_proc(variant_id, "on_hit_splash")
		_:
			pass

func get_role_counter_damage_mul(attacker_role: String, defender_role: String) -> float:
	var atk: String = _normalize_role_id(attacker_role)
	var def: String = _normalize_role_id(defender_role)
	var role_cfg: Dictionary = role_counter_damage_matrix.get(atk, {}) as Dictionary
	if role_cfg.is_empty():
		return 1.0
	return maxf(0.2, float(role_cfg.get(def, 1.0)))

func is_role_countered(attacker_role: String, defender_role: String) -> bool:
	return get_role_counter_damage_mul(attacker_role, defender_role) > 1.001

func _terrain_type_at_world(world_pos: Vector3) -> String:
	if _strategy_map_view != null and is_instance_valid(_strategy_map_view) and _strategy_map_view.has_method("terrain_type_at_world"):
		return String(_strategy_map_view.call("terrain_type_at_world", world_pos)).strip_edges().to_lower()
	return "grass"

func _terrain_height_at_world(world_pos: Vector3) -> float:
	if _strategy_map_view != null and is_instance_valid(_strategy_map_view):
		if _strategy_map_view.has_method("terrain_height_at_world"):
			return float(_strategy_map_view.call("terrain_height_at_world", world_pos))
		if _strategy_map_view.has_method("_ground_height_at_world"):
			return float(_strategy_map_view.call("_ground_height_at_world", world_pos))
	return float(world_pos.y)

func _height_adv_threshold() -> float:
	return maxf(0.1, float(height_advantage_rules.get("height_diff_threshold", 2.0)))

func _role_height_cfg(role_id: String) -> Dictionary:
	return role_height_modifiers.get(_normalize_role_id(role_id), {}) as Dictionary

func get_height_attack_mul(attacker, defender) -> float:
	if not height_advantage_enabled:
		return 1.0
	if attacker == null or defender == null:
		return 1.0
	if not is_instance_valid(attacker) or not is_instance_valid(defender):
		return 1.0
	var atk_role: String = _unit_role_id(attacker)
	var cfg: Dictionary = _role_height_cfg(atk_role)
	if cfg.is_empty():
		return 1.0
	var mul: float = maxf(0.2, float(cfg.get("high_to_low_attack_mul", 1.0)))
	if absf(mul - 1.0) <= 0.001:
		return 1.0
	var h_diff: float = _terrain_height_at_world(attacker.global_position) - _terrain_height_at_world(defender.global_position)
	if h_diff >= _height_adv_threshold():
		return mul
	return 1.0

func get_height_speed_mul(unit, move_dir: Vector3) -> float:
	if not height_advantage_enabled:
		return 1.0
	if unit == null or not is_instance_valid(unit):
		return 1.0
	var dir: Vector3 = move_dir
	dir.y = 0.0
	if dir.length_squared() <= 0.0001:
		return 1.0
	var cfg: Dictionary = _role_height_cfg(_unit_role_id(unit))
	if cfg.is_empty():
		return 1.0
	var downhill_mul: float = maxf(0.2, float(cfg.get("downhill_speed_mul", 1.0)))
	if absf(downhill_mul - 1.0) <= 0.001:
		return 1.0
	var probe_distance: float = maxf(0.5, float(height_advantage_rules.get("downhill_probe_distance", 6.0)))
	var from_pos: Vector3 = unit.global_position
	var to_pos: Vector3 = from_pos + dir.normalized() * probe_distance
	var from_h: float = _terrain_height_at_world(from_pos)
	var to_h: float = _terrain_height_at_world(to_pos)
	if (from_h - to_h) >= _height_adv_threshold():
		return downhill_mul
	return 1.0

func _unit_height_effect_text(unit) -> String:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return ""
	var role_id: String = _unit_role_id(unit)
	if role_id == "archer" or role_id == "crossbow":
		var target = unit.get("target_unit")
		if target != null and is_instance_valid(target) and not target.dead:
			var dmg_mul: float = get_height_attack_mul(unit, target)
			if dmg_mul > 1.001:
				return "Height bonus damage x%.2f" % dmg_mul
	if role_id == "cavalry":
		var move_velocity_any: Variant = unit.get("move_velocity")
		if move_velocity_any is Vector3:
			var move_velocity: Vector3 = move_velocity_any
			move_velocity.y = 0.0
			if move_velocity.length_squared() > 0.0001:
				var speed_mul: float = get_height_speed_mul(unit, move_velocity)
				if speed_mul > 1.001:
					return "Downhill speed bonus x%.2f" % speed_mul
	return ""

func _dict_string_array(dict_obj: Dictionary, key: String) -> Array[String]:
	var out: Array[String] = []
	var raw: Variant = dict_obj.get(key, [])
	if raw is Array:
		for item in raw:
			var text: String = String(item).strip_edges().to_lower()
			if text.is_empty():
				continue
			out.append(text)
	return out

func _tick_unit_terrain_adaptation(delta: float) -> void:
	if not terrain_adaptation_enabled:
		return
	terrain_adaptation_timer -= maxf(0.0, delta)
	if terrain_adaptation_timer > 0.0:
		return
	terrain_adaptation_timer = maxf(0.1, terrain_adaptation_interval_sec)
	for unit in units:
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		if demo_naval_enabled and _unit_is_embarked(unit):
			if unit.has_method("set_terrain_advantage"):
				unit.call("set_terrain_advantage", false, terrain_status_hold_sec)
			if unit.has_method("set_terrain_disadvantage"):
				unit.call("set_terrain_disadvantage", false, terrain_status_hold_sec)
			continue
		var role_id: String = _unit_role_id(unit)
		var profile: Dictionary = role_terrain_profiles.get(role_id, role_terrain_profiles.get("infantry", {})) as Dictionary
		var terrain_type: String = _terrain_type_at_world(unit.global_position)
		var adv_list: Array[String] = _dict_string_array(profile, "advantage")
		var disadv_list: Array[String] = _dict_string_array(profile, "disadvantage")
		var has_adv: bool = adv_list.has(terrain_type)
		var has_disadv: bool = disadv_list.has(terrain_type)
		if unit.has_method("set_terrain_advantage"):
			unit.call("set_terrain_advantage", has_adv and not has_disadv, terrain_status_hold_sec)
		if unit.has_method("set_terrain_disadvantage"):
			unit.call("set_terrain_disadvantage", has_disadv, terrain_status_hold_sec)

func _clear_all_burns() -> void:
	for unit in units:
		if unit == null or not is_instance_valid(unit):
			continue
		if unit.has_method("clear_burn"):
			unit.call("clear_burn")

func _resolve_locked_skill_target(caster):
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return null
	var caster_team: int = int(caster.team_id)
	for key in ["manual_priority_target_unit", "chase_target_unit", "target_unit"]:
		var candidate: Variant = caster.get(StringName(key))
		if candidate != null and is_instance_valid(candidate) and not candidate.dead and int(candidate.team_id) != caster_team and is_enemy_targetable_for_team(caster_team, candidate):
			return candidate
	return null

func _unit_has_locked_skill_target(caster) -> bool:
	return _resolve_locked_skill_target(caster) != null

func _try_cast_unit_skill(caster, skill_id: int) -> void:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return
	var cd_left: float = 0.0
	if caster.has_method("get_skill_cd_left"):
		cd_left = float(caster.call("get_skill_cd_left", int(skill_id)))
	if cd_left > 0.001:
		_set_battle_status("Skill cooling down: %.1fs." % cd_left)
		return
	var spirit_now: float = 0.0
	if caster.has_method("get_current_will"):
		spirit_now = float(caster.call("get_current_will"))
	elif caster.has_method("get_current_spirit"):
		spirit_now = float(caster.call("get_current_spirit"))
	var spirit_cost: float = 0.0
	if caster.has_method("get_skill_will_cost_value"):
		spirit_cost = float(caster.call("get_skill_will_cost_value", int(skill_id)))
	elif caster.has_method("get_skill_spirit_cost_value"):
		spirit_cost = float(caster.call("get_skill_spirit_cost_value", int(skill_id)))
	if spirit_now + 0.001 < spirit_cost:
		_set_battle_status("Not enough will.")
		return
	var role_id: String = ""
	if caster.has_method("get_combat_role_id"):
		role_id = String(caster.call("get_combat_role_id")).strip_edges().to_lower()
	var shield_free_cast: bool = role_id == "shield" and (int(skill_id) == int(UnitController.SkillType.CHARGE) or int(skill_id) == int(UnitController.SkillType.SWEEP))
	var target = _resolve_locked_skill_target(caster)
	if target == null and not shield_free_cast:
		_set_battle_status("No valid skill target.")
		return
	var ok: bool = bool(caster.call("issue_skill", int(skill_id), target if target != null else null))
	if not ok:
		var reason: String = "Skill cast failed."
		if caster.has_method("_prepare_pierce_cast") and not shield_free_cast and (int(skill_id) == int(UnitController.SkillType.CHARGE) or int(skill_id) == int(UnitController.SkillType.BREAKTHROUGH)):
			var info: Dictionary = caster.call("_prepare_pierce_cast", target)
			var reason_code: String = String(info.get("reason", ""))
			match reason_code:
				"invalid_target":
					reason = "Invalid target."
				"bad_status":
					reason = "Blocked by current status."
				"low_morale":
					reason = "Low morale."
				"bad_direction":
					reason = "Bad direction."
				"bad_terrain":
					reason = "Target point blocked."
				_:
					if reason_code != "":
						reason = reason_code
		_set_battle_status(reason)
	else:
		_set_battle_status("%s cast." % _panel_skill_display_name_for_unit(caster, int(skill_id)))

func _tick_tactic_cooldowns(delta: float) -> void:
	if delta <= 0.0 or tactic_cooldowns.is_empty():
		return
	var remove_keys: Array = []
	for key_any in tactic_cooldowns.keys():
		var key: String = String(key_any)
		var left: float = maxf(0.0, float(tactic_cooldowns.get(key, 0.0)) - delta)
		if left <= 0.0:
			remove_keys.append(key)
		else:
			tactic_cooldowns[key] = left
	for key_any in remove_keys:
		tactic_cooldowns.erase(String(key_any))

func _tick_siege_variant_proc_cooldowns(delta: float) -> void:
	if delta <= 0.0:
		return
	if _siege_variant_proc_cooldowns.is_empty():
		return
	var remove_keys: Array = []
	for key_any in _siege_variant_proc_cooldowns.keys():
		var key: String = String(key_any)
		var left: float = maxf(0.0, float(_siege_variant_proc_cooldowns.get(key, 0.0)) - delta)
		if left <= 0.0:
			remove_keys.append(key)
		else:
			_siege_variant_proc_cooldowns[key] = left
	for key_any in remove_keys:
		_siege_variant_proc_cooldowns.erase(String(key_any))

func _clear_siege_variant_proc_cooldowns_for_unit(unit_id: int) -> void:
	if unit_id <= 0:
		return
	if _siege_variant_proc_cooldowns.is_empty():
		return
	var prefix: String = "%d|" % unit_id
	var remove_keys: Array = []
	for key_any in _siege_variant_proc_cooldowns.keys():
		var key: String = String(key_any)
		if key.begins_with(prefix):
			remove_keys.append(key)
	for key_any in remove_keys:
		_siege_variant_proc_cooldowns.erase(String(key_any))

func _clear_demo_siege_variant_skill_cooldowns_for_unit(unit_id: int) -> void:
	if unit_id <= 0:
		return
	if _demo_siege_variant_skill_cooldowns.is_empty():
		return
	var prefix: String = "%d|" % unit_id
	var remove_keys: Array = []
	for key_any in _demo_siege_variant_skill_cooldowns.keys():
		var key: String = String(key_any)
		if key.begins_with(prefix):
			remove_keys.append(key)
	for key_any in remove_keys:
		_demo_siege_variant_skill_cooldowns.erase(String(key_any))

func _tactic_key(unit, tactic_id: String) -> String:
	var id: String = _canonical_tactic_id(tactic_id)
	return "%d|%s" % [unit.get_instance_id(), id]

func _get_tactic_cfg(tactic_id: String) -> Dictionary:
	var id: String = _canonical_tactic_id(tactic_id)
	return weather_settings.get("tactics", {}).get(id, {})

func _get_tactic_cd_left(unit, tactic_id: String) -> float:
	return float(tactic_cooldowns.get(_tactic_key(unit, tactic_id), 0.0))

func _consume_tactic_cost_and_cd(unit, tactic_id: String) -> bool:
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var cd_left: float = _get_tactic_cd_left(unit, tactic_id)
	if cd_left > 0.001:
		_set_battle_status("Tactic cooling down: %.1fs." % cd_left)
		return false
	var spirit_cost: float = float(cfg.get("will_cost", cfg.get("spirit_cost", 0.0)))
	if spirit_cost > 0.0:
		var consumed: bool = false
		if unit.has_method("try_consume_will"):
			consumed = bool(unit.call("try_consume_will", spirit_cost))
		elif unit.has_method("try_consume_spirit"):
			consumed = bool(unit.call("try_consume_spirit", spirit_cost))
		if not consumed:
			_set_battle_status("Not enough will for tactic.")
			return false
	var cooldown: float = float(cfg.get("cooldown_sec", 0.0))
	if cooldown > 0.0:
		tactic_cooldowns[_tactic_key(unit, tactic_id)] = cooldown
	return true

func _role_in_list(role_id: String, raw_list: Variant) -> bool:
	if not (raw_list is Array):
		return false
	var target: String = _normalize_role_id(role_id)
	for item in raw_list:
		if _normalize_role_id(String(item)) == target:
			return true
	return false

func _terrain_in_list(terrain_type: String, raw_list: Variant) -> bool:
	if not (raw_list is Array):
		return false
	var target: String = String(terrain_type).strip_edges().to_lower()
	for item in raw_list:
		if String(item).strip_edges().to_lower() == target:
			return true
	return false

func _check_tactic_cast_conditions(caster, tactic_id: String, target = null) -> bool:
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var caster_role: String = _unit_role_id(caster)
	var caster_terrain: String = _terrain_type_at_world(caster.global_position)
	if _role_in_list(caster_role, cfg.get("caster_blocked_roles", [])):
		_set_battle_status("Current unit role cannot cast this tactic.")
		return false
	if cfg.has("caster_allowed_roles") and not _role_in_list(caster_role, cfg.get("caster_allowed_roles", [])):
		_set_battle_status("Current unit role cannot cast this tactic.")
		return false
	if _terrain_in_list(caster_terrain, cfg.get("caster_blocked_terrains", [])):
		_set_battle_status("Current terrain blocks this tactic.")
		return false
	if cfg.has("caster_allowed_terrains") and not _terrain_in_list(caster_terrain, cfg.get("caster_allowed_terrains", [])):
		_set_battle_status("Current terrain blocks this tactic.")
		return false
	if target == null or not is_instance_valid(target):
		return true
	var target_role: String = _unit_role_id(target)
	var target_terrain: String = _terrain_type_at_world(target.global_position)
	if _role_in_list(target_role, cfg.get("target_blocked_roles", [])):
		_set_battle_status("Target role is immune to this tactic.")
		return false
	if cfg.has("target_allowed_roles") and not _role_in_list(target_role, cfg.get("target_allowed_roles", [])):
		_set_battle_status("Target role blocked for this tactic.")
		return false
	if _terrain_in_list(target_terrain, cfg.get("target_blocked_terrains", [])):
		_set_battle_status("Target terrain blocks this tactic.")
		return false
	if cfg.has("target_allowed_terrains") and not _terrain_in_list(target_terrain, cfg.get("target_allowed_terrains", [])):
		_set_battle_status("Target terrain blocks this tactic.")
		return false
	return true

func _get_friendly_units_in_radius(center: Vector3, radius: float, team_id: int) -> Array:
	var result: Array = []
	var radius_sq: float = radius * radius
	for unit in units:
		if unit == null or not is_instance_valid(unit):
			continue
		if unit.dead or unit.team_id != team_id:
			continue
		var d: Vector3 = unit.global_position - center
		d.y = 0.0
		if d.length_squared() <= radius_sq:
			result.append(unit)
	return result

func _try_cast_tactic_by_id(caster, tactic_id: String) -> bool:
	var id: String = _canonical_tactic_id(tactic_id)
	match id:
		"strat_fire_attack", "strat_skyfire":
			return _try_cast_fire_tactic(caster, id)
		"strat_thunder", "strat_thunder_lock":
			return _try_cast_thunder_tactic(caster, id)
		"strat_weather_change", "strat_borrow_wind":
			return _try_cast_weather_change(caster, id)
		"strat_cheer":
			return _try_cast_cheer_tactic(caster, id)
		"strat_delay":
			return _try_cast_delay_tactic(caster, id)
		"strat_sow_discord":
			return _try_cast_discord_tactic(caster, id)
		"strat_chain":
			return _try_cast_chain_tactic(caster, id)
		"strat_trap":
			return _try_cast_trap_tactic(caster, id)
		"strat_dragon_bind":
			return _try_cast_dragon_bind_tactic(caster, id)
		_:
			_set_battle_status("Unknown tactic.")
			return false

func _try_cast_cheer_tactic(caster, tactic_id: String = "strat_cheer") -> bool:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return false
	if not _check_tactic_cast_conditions(caster, tactic_id, null):
		return false
	if not _consume_tactic_cost_and_cd(caster, tactic_id):
		return false
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var radius: float = float(cfg.get("radius", 10.0))
	var buff_duration: float = float(cfg.get("buff_duration_sec", 4.0))
	var will_restore: float = float(cfg.get("will_restore", 9.0))
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.3)
	_play_tactic_area_vfx(caster, tactic_id, caster.global_position, radius, maxf(1.4, buff_duration), 1, 0.1)
	var allies: Array = _get_friendly_units_in_radius(caster.global_position, radius, int(caster.team_id))
	if allies.is_empty():
		allies.append(caster)
	for ally in allies:
		if ally == null or not is_instance_valid(ally) or ally.dead:
			continue
		if ally.has_method("apply_status"):
			ally.call("apply_status", int(UnitController.StatusId.HIGH_MORALE), maxf(0.2, buff_duration))
			ally.call("apply_status", int(UnitController.StatusId.TACTIC_BUFF), maxf(0.2, buff_duration))
		var current_will: float = float(ally.call("get_current_will")) if ally.has_method("get_current_will") else float(ally.get("spirit_current"))
		var will_cap: float = maxf(1.0, float(ally.get("spirit_cap_current")))
		ally.set("spirit_current", clampf(current_will + will_restore, 0.0, will_cap))
	_set_battle_status("%s cast." % _panel_tactic_display_name(tactic_id))
	return true

func _try_cast_delay_tactic(caster, tactic_id: String = "strat_delay") -> bool:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return false
	var center_target = get_closest_enemy(caster)
	if center_target == null or not is_instance_valid(center_target):
		_set_battle_status("No valid target.")
		return false
	if not _check_tactic_cast_conditions(caster, tactic_id, center_target):
		return false
	if not _consume_tactic_cost_and_cd(caster, tactic_id):
		return false
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var radius: float = float(cfg.get("radius", 8.0))
	var damage: float = float(cfg.get("damage", 35.0))
	var slow_duration: float = float(cfg.get("slow_duration_sec", 2.6))
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.3)
	_play_tactic_area_vfx(caster, tactic_id, center_target.global_position, radius, maxf(1.6, slow_duration))
	var targets: Array = get_enemies_in_radius(center_target.global_position, radius, caster.team_id)
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		if damage > 0.0:
			enemy.receive_damage(damage, caster)
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.SLOWED), maxf(0.2, slow_duration))
	_set_battle_status("%s cast." % _panel_tactic_display_name(tactic_id))
	return true

func _try_cast_discord_tactic(caster, tactic_id: String = "strat_sow_discord") -> bool:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return false
	var center_target = get_closest_enemy(caster)
	if center_target == null or not is_instance_valid(center_target):
		_set_battle_status("No valid target.")
		return false
	if not _check_tactic_cast_conditions(caster, tactic_id, center_target):
		return false
	if not _consume_tactic_cost_and_cd(caster, tactic_id):
		return false
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var radius: float = float(cfg.get("radius", 8.4))
	var confusion_duration: float = float(cfg.get("confusion_duration_sec", 2.8))
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.32)
	_play_tactic_area_vfx(caster, tactic_id, center_target.global_position, radius, maxf(1.8, confusion_duration))
	var targets: Array = get_enemies_in_radius(center_target.global_position, radius, caster.team_id)
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.CONFUSION), maxf(0.2, confusion_duration))
			enemy.call("apply_status", int(UnitController.StatusId.MISINFORMATION), maxf(0.2, confusion_duration * 0.85))
	_set_battle_status("%s cast." % _panel_tactic_display_name(tactic_id))
	return true

func _try_cast_chain_tactic(caster, tactic_id: String = "strat_chain") -> bool:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return false
	var center_target = get_closest_enemy(caster)
	if center_target == null or not is_instance_valid(center_target):
		_set_battle_status("No valid target.")
		return false
	if not _check_tactic_cast_conditions(caster, tactic_id, center_target):
		return false
	if not _consume_tactic_cost_and_cd(caster, tactic_id):
		return false
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var radius: float = float(cfg.get("radius", 8.8))
	var damage: float = float(cfg.get("damage", 55.0))
	var slow_duration: float = float(cfg.get("slow_duration_sec", 3.2))
	var center_paralyze_duration: float = float(cfg.get("center_paralyze_duration_sec", 0.7))
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.34)
	_play_tactic_area_vfx(caster, tactic_id, center_target.global_position, radius, maxf(2.0, slow_duration))
	var targets: Array = get_enemies_in_radius(center_target.global_position, radius, caster.team_id)
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		if damage > 0.0:
			enemy.receive_damage(damage, caster)
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.SLOWED), maxf(0.2, slow_duration))
	var center_enemy = center_target
	if center_enemy != null and is_instance_valid(center_enemy) and not center_enemy.dead and center_enemy.has_method("apply_status"):
		center_enemy.call("apply_status", int(UnitController.StatusId.PARALYZED), maxf(0.2, center_paralyze_duration))
	_play_tactic_link_group_vfx(center_target.global_position, targets, tactic_id, 0.3)
	_set_battle_status("%s cast." % _panel_tactic_display_name(tactic_id))
	return true

func _try_cast_trap_tactic(caster, tactic_id: String = "strat_trap") -> bool:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return false
	var center_target = get_closest_enemy(caster)
	if center_target == null or not is_instance_valid(center_target):
		_set_battle_status("No valid target.")
		return false
	if not _check_tactic_cast_conditions(caster, tactic_id, center_target):
		return false
	if not _consume_tactic_cost_and_cd(caster, tactic_id):
		return false
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var radius: float = float(cfg.get("radius", 9.2))
	var slow_duration: float = float(cfg.get("slow_duration_sec", 3.8))
	var damage: float = float(cfg.get("damage", 40.0))
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.32)
	_play_tactic_area_vfx(caster, tactic_id, center_target.global_position, radius, maxf(2.2, slow_duration))
	var targets: Array = get_enemies_in_radius(center_target.global_position, radius, caster.team_id)
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		if damage > 0.0:
			enemy.receive_damage(damage, caster)
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.SLOWED), maxf(0.2, slow_duration))
			enemy.call("apply_status", int(UnitController.StatusId.COUNTERED), maxf(0.2, slow_duration * 0.5))
	_set_battle_status("%s cast." % _panel_tactic_display_name(tactic_id))
	return true

func _try_cast_dragon_bind_tactic(caster, tactic_id: String = "strat_dragon_bind") -> bool:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return false
	var center_target = get_closest_enemy(caster)
	if center_target == null or not is_instance_valid(center_target):
		_set_battle_status("No valid target.")
		return false
	if not _check_tactic_cast_conditions(caster, tactic_id, center_target):
		return false
	if not _consume_tactic_cost_and_cd(caster, tactic_id):
		return false
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var radius: float = float(cfg.get("radius", 9.5))
	var slow_duration: float = float(cfg.get("slow_duration_sec", 4.2))
	var paralyze_duration: float = float(cfg.get("paralyze_duration_sec", 1.0))
	var taunt_duration: float = float(cfg.get("taunt_duration_sec", 2.4))
	var damage: float = float(cfg.get("damage", 70.0))
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.36)
	_play_tactic_area_vfx(caster, tactic_id, center_target.global_position, radius, maxf(2.6, slow_duration))
	var targets: Array = get_enemies_in_radius(center_target.global_position, radius, caster.team_id)
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		if damage > 0.0:
			enemy.receive_damage(damage, caster)
		if enemy.has_method("apply_status"):
			enemy.call("apply_status", int(UnitController.StatusId.SLOWED), maxf(0.2, slow_duration))
			enemy.call("apply_status", int(UnitController.StatusId.PARALYZED), maxf(0.2, paralyze_duration))
		if enemy.has_method("apply_taunt"):
			enemy.call("apply_taunt", caster, maxf(0.2, taunt_duration))
	_play_tactic_link_group_vfx(caster.global_position, targets, tactic_id, 0.36)
	_set_battle_status("%s cast." % _panel_tactic_display_name(tactic_id))
	return true

func _try_cast_fire_tactic(caster, tactic_id: String = "strat_fire_attack") -> bool:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return false
	if is_fire_blocked_by_weather():
		_set_battle_status("Rain blocks fire tactics.")
		return false
	var center_target = get_closest_enemy(caster)
	if center_target == null or not is_instance_valid(center_target):
		_set_battle_status("No valid fire target found.")
		return false
	if not _check_tactic_cast_conditions(caster, tactic_id, center_target):
		return false
	if not _consume_tactic_cost_and_cd(caster, tactic_id):
		return false
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var radius: float = float(cfg.get("radius", 8.0))
	var burn_duration: float = float(cfg.get("burn_duration_sec", 7.0))
	var burn_dps: float = float(cfg.get("burn_dps", 6.0))
	var direct_damage: float = float(cfg.get("damage", 0.0))
	var vfx_radius: float = radius * 2.4
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.34)
	_play_tactic_area_vfx(caster, tactic_id, center_target.global_position, vfx_radius, maxf(2.8, burn_duration))
	var targets: Array = get_enemies_in_radius(center_target.global_position, radius, caster.team_id)
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		if direct_damage > 0.0:
			enemy.receive_damage(direct_damage, caster)
		if enemy.has_method("apply_burn"):
			enemy.call("apply_burn", burn_duration, burn_dps, caster.team_id)
	_set_battle_status("%s cast." % _panel_tactic_display_name(tactic_id))
	return true

func _try_cast_thunder_tactic(caster, tactic_id: String = "strat_thunder") -> bool:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return false
	if not _is_thunder_cast_weather():
		_set_battle_status("Thunder can only be cast in rain/overcast.")
		return false
	var center_target = get_closest_enemy(caster)
	if center_target == null or not is_instance_valid(center_target):
		_set_battle_status("No valid thunder target found.")
		return false
	if not _check_tactic_cast_conditions(caster, tactic_id, center_target):
		return false
	if not _consume_tactic_cost_and_cd(caster, tactic_id):
		return false
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var radius: float = float(cfg.get("radius", 9.0))
	var damage: float = float(cfg.get("damage", 130.0))
	var paralyze_duration: float = float(cfg.get("paralyze_duration_sec", 0.0))
	var slow_duration: float = float(cfg.get("slow_duration_sec", 0.0))
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.34)
	_play_tactic_area_vfx(caster, tactic_id, center_target.global_position, radius, maxf(1.6, maxf(paralyze_duration, slow_duration)))
	var targets: Array = get_enemies_in_radius(center_target.global_position, radius, caster.team_id)
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		enemy.receive_damage(damage, caster)
		if enemy.has_method("apply_status"):
			if paralyze_duration > 0.0:
				enemy.call("apply_status", int(UnitController.StatusId.PARALYZED), maxf(0.2, paralyze_duration))
			if slow_duration > 0.0:
				enemy.call("apply_status", int(UnitController.StatusId.SLOWED), maxf(0.2, slow_duration))
	_play_tactic_thunder_target_vfx(caster, tactic_id, targets)
	_play_tactic_link_group_vfx(center_target.global_position + Vector3(0.0, 0.35, 0.0), targets, tactic_id, 0.24)
	_set_battle_status("%s cast." % _panel_tactic_display_name(tactic_id))
	return true

func _try_cast_weather_change(caster, tactic_id: String = "strat_weather_change") -> bool:
	if caster == null or not is_instance_valid(caster) or caster.dead:
		return false
	if not _check_tactic_cast_conditions(caster, tactic_id, null):
		return false
	if not _consume_tactic_cost_and_cd(caster, tactic_id):
		return false
	_spawn_tactic_cast_vfx(caster, tactic_id, 0.32)
	var cfg: Dictionary = _get_tactic_cfg(tactic_id)
	var mode: String = String(cfg.get("mode", "toggle_sun_rain")).strip_edges().to_lower()
	var to_state: String = String(cfg.get("to_state", "")).strip_edges().to_lower()
	if mode == "toggle_sun_rain" or to_state.is_empty():
		var sunny_state: String = String(cfg.get("sunny_state", "sunny"))
		var rain_state: String = String(cfg.get("rain_state", "rain"))
		to_state = rain_state
		if _is_rain_like_weather():
			to_state = sunny_state
	var to_strength: float = float(cfg.get("wind_strength", 0.0))
	var wind_dir: Vector2 = _raw_wind_to_vec2(cfg.get("wind_dir", weather_settings.get("default_wind_dir", [1.0, 0.0])))
	_set_weather_state(to_state, wind_dir, to_strength, true)
	var weather_radius: float = float(cfg.get("radius", 9.0))
	_play_tactic_area_vfx(caster, tactic_id, caster.global_position, weather_radius, 2.8, 2, 0.12)
	_set_battle_status("%s: %s." % [_panel_tactic_display_name(tactic_id), _weather_label(to_state)])
	return true

func _update_wind_fire_spread(delta: float) -> void:
	if not _is_wind_spread_weather():
		return
	var spread_cfg: Dictionary = weather_settings.get("wind_spread", {})
	if not bool(spread_cfg.get("enabled", true)):
		return
	burn_wind_timer -= delta
	if burn_wind_timer > 0.0:
		return
	burn_wind_timer = maxf(0.2, float(spread_cfg.get("interval_sec", 1.0)))
	var radius: float = float(spread_cfg.get("radius", 11.0))
	var cone_deg: float = float(spread_cfg.get("cone_angle_deg", 72.0))
	var chance_base: float = float(spread_cfg.get("chance", 0.55))
	var spread_duration: float = float(spread_cfg.get("burn_duration_sec", 6.0))
	var spread_dps: float = float(spread_cfg.get("burn_dps", 4.0))
	var wind_dir_3d := Vector3(weather_wind_dir.x, 0.0, weather_wind_dir.y).normalized()
	var half_cone: float = deg_to_rad(cone_deg * 0.5)
	for source in units:
		if source == null or not is_instance_valid(source) or source.dead:
			continue
		if not source.has_method("is_burning") or not bool(source.call("is_burning")):
			continue
		for enemy in units:
			if enemy == null or not is_instance_valid(enemy) or enemy.dead:
				continue
			if enemy.team_id == source.team_id:
				continue
			if enemy.has_method("is_burning") and bool(enemy.call("is_burning")):
				continue
			var offset: Vector3 = enemy.global_position - source.global_position
			offset.y = 0.0
			var dist: float = offset.length()
			if dist <= 0.001 or dist > radius:
				continue
			var dir_to_enemy: Vector3 = offset / dist
			var angle: float = acos(clampf(wind_dir_3d.dot(dir_to_enemy), -1.0, 1.0))
			if angle > half_cone:
				continue
			var chance: float = clampf(chance_base * maxf(0.35, weather_wind_strength), 0.0, 1.0)
			if randf() > chance:
				continue
			if enemy.has_method("apply_burn"):
				enemy.call("apply_burn", spread_duration, spread_dps, source.team_id)

func _weather_label(state: String) -> String:
	var labels: Dictionary = weather_settings.get("labels", {})
	return String(labels.get(state, state))

func _wind_text() -> String:
	if weather_wind_strength <= 0.001 or weather_wind_dir.length() <= 0.001:
		return "-"
	var n: Vector2 = weather_wind_dir.normalized()
	var angle: float = fposmod(rad_to_deg(atan2(n.y, n.x)), 360.0)
	var idx: int = int(round(angle / 45.0)) % 8
	var names: Array[String] = ["E", "NE", "N", "NW", "W", "SW", "S", "SE"]
	return "%s wind" % names[idx]

func _current_weather_text() -> String:
	return "Weather %s | %s" % [_weather_label(weather_state), _wind_text()]

func _setup_commander_report_panel() -> void:
	if unit_tag_layer == null:
		return
	if commander_report_panel != null and is_instance_valid(commander_report_panel):
		return
	commander_report_panel = PanelContainer.new()
	commander_report_panel.name = "CommanderReportPanel"
	commander_report_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	commander_report_panel.offset_left = 20.0
	commander_report_panel.offset_top = -238.0
	commander_report_panel.offset_right = 660.0
	commander_report_panel.offset_bottom = -20.0
	commander_report_panel.custom_minimum_size = Vector2(640.0, 0.0)
	commander_report_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var report_style := StyleBoxFlat.new()
	report_style.bg_color = Color(0.07, 0.10, 0.08, 0.22)
	report_style.border_color = Color(0.79, 0.70, 0.47, 0.42)
	report_style.set_border_width_all(1)
	report_style.set_corner_radius_all(8)
	report_style.shadow_color = Color(0.0, 0.0, 0.0, 0.16)
	report_style.shadow_size = 2
	report_style.shadow_offset = Vector2(0.0, 1.0)
	commander_report_panel.add_theme_stylebox_override("panel", report_style)
	unit_tag_layer.add_child(commander_report_panel)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	commander_report_panel.add_child(margin)
	commander_report_list = VBoxContainer.new()
	commander_report_list.name = "Lines"
	commander_report_list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	commander_report_list.add_theme_constant_override("separation", 5)
	margin.add_child(commander_report_list)
	_refresh_commander_report_panel()

func _setup_siege_debug_panel() -> void:
	if unit_tag_layer == null:
		return
	if siege_debug_panel != null and is_instance_valid(siege_debug_panel):
		return
	siege_debug_panel = PanelContainer.new()
	siege_debug_panel.name = "SiegeDebugPanel"
	siege_debug_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	siege_debug_panel.offset_left = 20.0
	siege_debug_panel.offset_top = -368.0
	siege_debug_panel.offset_right = 660.0
	siege_debug_panel.offset_bottom = -244.0
	siege_debug_panel.custom_minimum_size = Vector2(640.0, 0.0)
	siege_debug_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.09, 0.08, 0.26)
	panel_style.border_color = Color(0.60, 0.74, 0.51, 0.52)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.16)
	panel_style.shadow_size = 2
	panel_style.shadow_offset = Vector2(0.0, 1.0)
	siege_debug_panel.add_theme_stylebox_override("panel", panel_style)
	unit_tag_layer.add_child(siege_debug_panel)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	siege_debug_panel.add_child(margin)
	siege_debug_text = Label.new()
	siege_debug_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	siege_debug_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	siege_debug_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	siege_debug_text.add_theme_font_size_override("font_size", 14)
	siege_debug_text.add_theme_color_override("font_color", Color(0.88, 0.97, 0.86, 0.96))
	if _tag_font != null:
		siege_debug_text.add_theme_font_override("font", _tag_font)
	margin.add_child(siege_debug_text)
	_reset_demo_siege_debug_stats()
	_refresh_demo_siege_debug_overlay(true)

func _setup_siege_objective_panel() -> void:
	if unit_tag_layer == null:
		return
	if siege_objective_panel != null and is_instance_valid(siege_objective_panel):
		return
	siege_objective_panel = PanelContainer.new()
	siege_objective_panel.name = "SiegeObjectivePanel"
	siege_objective_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	siege_objective_panel.offset_left = 20.0
	siege_objective_panel.offset_top = 16.0
	siege_objective_panel.offset_right = 620.0
	siege_objective_panel.offset_bottom = 126.0
	siege_objective_panel.custom_minimum_size = Vector2(600.0, 0.0)
	siege_objective_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.09, 0.08, 0.26)
	panel_style.border_color = Color(0.80, 0.67, 0.36, 0.56)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.16)
	panel_style.shadow_size = 2
	panel_style.shadow_offset = Vector2(0.0, 1.0)
	siege_objective_panel.add_theme_stylebox_override("panel", panel_style)
	unit_tag_layer.add_child(siege_objective_panel)
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	siege_objective_panel.add_child(margin)
	siege_objective_text = Label.new()
	siege_objective_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	siege_objective_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	siege_objective_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	siege_objective_text.add_theme_font_size_override("font_size", 15)
	siege_objective_text.add_theme_color_override("font_color", Color(0.93, 0.96, 0.88, 0.97))
	if _tag_font != null:
		siege_objective_text.add_theme_font_override("font", _tag_font)
	margin.add_child(siege_objective_text)
	_refresh_demo_siege_objective_panel(true)

func _setup_commander_dialogue_hud() -> void:
	if unit_tag_layer == null:
		return
	if commander_dialogue_hud_panel != null and is_instance_valid(commander_dialogue_hud_panel):
		return
	commander_dialogue_hud_panel = PanelContainer.new()
	commander_dialogue_hud_panel.name = "CommanderDialogueHud"
	commander_dialogue_hud_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	commander_dialogue_hud_panel.offset_left = -470.0
	commander_dialogue_hud_panel.offset_top = -230.0
	commander_dialogue_hud_panel.offset_right = 470.0
	commander_dialogue_hud_panel.offset_bottom = -68.0
	commander_dialogue_hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	commander_dialogue_hud_panel.visible = false
	commander_dialogue_hud_panel.z_index = 8
	var hud_style := StyleBoxFlat.new()
	hud_style.bg_color = Color(0.97, 0.97, 0.95, 0.96)
	hud_style.border_color = Color(0.78, 0.62, 0.34, 0.98)
	hud_style.set_border_width_all(3)
	hud_style.set_corner_radius_all(9)
	hud_style.shadow_color = Color(0.0, 0.0, 0.0, 0.20)
	hud_style.shadow_size = 3
	hud_style.shadow_offset = Vector2(0.0, 1.0)
	commander_dialogue_hud_panel.add_theme_stylebox_override("panel", hud_style)
	unit_tag_layer.add_child(commander_dialogue_hud_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	commander_dialogue_hud_panel.add_child(margin)

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 14)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	var portrait_shell := PanelContainer.new()
	portrait_shell.custom_minimum_size = Vector2(112.0, 112.0)
	portrait_shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var portrait_style := StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.95, 0.93, 0.89, 0.98)
	portrait_style.border_color = Color(0.78, 0.62, 0.34, 0.98)
	portrait_style.set_border_width_all(3)
	portrait_style.set_corner_radius_all(5)
	portrait_shell.add_theme_stylebox_override("panel", portrait_style)
	row.add_child(portrait_shell)

	commander_dialogue_hud_portrait_rect = TextureRect.new()
	commander_dialogue_hud_portrait_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	commander_dialogue_hud_portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	commander_dialogue_hud_portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	commander_dialogue_hud_portrait_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_shell.add_child(commander_dialogue_hud_portrait_rect)

	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(body)

	commander_dialogue_hud_name_label = Label.new()
	commander_dialogue_hud_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	commander_dialogue_hud_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	commander_dialogue_hud_name_label.add_theme_font_size_override("font_size", 24)
	commander_dialogue_hud_name_label.add_theme_color_override("font_color", Color(0.62, 0.44, 0.23, 0.98))
	commander_dialogue_hud_name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.0))
	commander_dialogue_hud_name_label.add_theme_color_override("font_outline_color", Color(0.95, 0.91, 0.82, 0.95))
	commander_dialogue_hud_name_label.add_theme_constant_override("outline_size", 1)
	if _tag_font != null:
		commander_dialogue_hud_name_label.add_theme_font_override("font", _tag_font)
	body.add_child(commander_dialogue_hud_name_label)

	commander_dialogue_hud_line_label = Label.new()
	commander_dialogue_hud_line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	commander_dialogue_hud_line_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	commander_dialogue_hud_line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	commander_dialogue_hud_line_label.clip_text = false
	commander_dialogue_hud_line_label.add_theme_font_size_override("font_size", 31)
	commander_dialogue_hud_line_label.add_theme_color_override("font_color", Color(0.19, 0.12, 0.07, 1.0))
	commander_dialogue_hud_line_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.0))
	commander_dialogue_hud_line_label.add_theme_color_override("font_outline_color", Color(0.96, 0.92, 0.84, 0.92))
	commander_dialogue_hud_line_label.add_theme_constant_override("outline_size", 2)
	if _tag_font != null:
		commander_dialogue_hud_line_label.add_theme_font_override("font", _tag_font)
	body.add_child(commander_dialogue_hud_line_label)
	commander_dialogue_hud_queue.clear()
	commander_dialogue_hud_time_left = 0.0
	commander_dialogue_hud_last_text = ""

func _enqueue_commander_dialogue_hud(line_text: String, team_id: int = -1, speaker_name: String = "", duration_sec: float = 3.6) -> void:
	var text: String = line_text.strip_edges()
	if text.is_empty():
		return
	var side_text: String = ""
	if team_id == 0:
		side_text = "我军"
	elif team_id == 1:
		side_text = "敌军"
	var speaker: String = speaker_name.strip_edges()
	if speaker.is_empty() and team_id >= 0:
		speaker = _resolve_report_unit_name(_find_team_report_commander(team_id))
	if speaker.is_empty():
		speaker = "前线"
	var name_text: String = speaker if side_text.is_empty() else "%s·%s" % [side_text, speaker]
	var duration: float = maxf(1.6, duration_sec)
	if not commander_dialogue_hud_queue.is_empty():
		var last_idx: int = commander_dialogue_hud_queue.size() - 1
		var last_entry: Dictionary = commander_dialogue_hud_queue[last_idx]
		var last_key: String = "%s|%s" % [String(last_entry.get("speaker", "")), String(last_entry.get("text", ""))]
		var key: String = "%s|%s" % [speaker, text]
		if last_key == key:
			return
	commander_dialogue_hud_queue.append({
		"name": name_text,
		"speaker": speaker,
		"text": text,
		"team_id": team_id,
		"duration": duration
	})
	while commander_dialogue_hud_queue.size() > 8:
		commander_dialogue_hud_queue.remove_at(0)

func _show_next_commander_dialogue_hud() -> void:
	if commander_dialogue_hud_panel == null or not is_instance_valid(commander_dialogue_hud_panel):
		return
	if commander_dialogue_hud_queue.is_empty():
		commander_dialogue_hud_panel.visible = false
		commander_dialogue_hud_last_text = ""
		commander_dialogue_hud_time_left = 0.0
		return
	var entry: Dictionary = commander_dialogue_hud_queue[0]
	commander_dialogue_hud_queue.remove_at(0)
	var name_text: String = String(entry.get("name", "")).strip_edges()
	var text: String = String(entry.get("text", "")).strip_edges()
	if name_text.is_empty() or text.is_empty():
		_show_next_commander_dialogue_hud()
		return
	var key: String = "%s|%s" % [name_text, text]
	if commander_dialogue_hud_last_text == key and commander_dialogue_hud_time_left > 0.2:
		commander_dialogue_hud_time_left = maxf(commander_dialogue_hud_time_left, float(entry.get("duration", 3.6)))
		commander_dialogue_hud_panel.visible = true
		return
	if commander_dialogue_hud_name_label != null and is_instance_valid(commander_dialogue_hud_name_label):
		commander_dialogue_hud_name_label.text = name_text
	if commander_dialogue_hud_line_label != null and is_instance_valid(commander_dialogue_hud_line_label):
		commander_dialogue_hud_line_label.text = "“%s”" % text
	if commander_dialogue_hud_portrait_rect != null and is_instance_valid(commander_dialogue_hud_portrait_rect):
		var speaker_name: String = String(entry.get("speaker", name_text)).strip_edges()
		commander_dialogue_hud_portrait_rect.texture = _get_tag_head_portrait_for_commander(speaker_name)
	commander_dialogue_hud_last_text = key
	commander_dialogue_hud_time_left = maxf(1.6, float(entry.get("duration", 3.6)))
	commander_dialogue_hud_panel.visible = true

func _tick_commander_dialogue_hud(delta: float) -> void:
	if commander_dialogue_hud_panel == null or not is_instance_valid(commander_dialogue_hud_panel):
		return
	if commander_dialogue_hud_time_left > 0.0:
		commander_dialogue_hud_time_left = maxf(0.0, commander_dialogue_hud_time_left - maxf(0.0, delta))
	if commander_dialogue_hud_time_left <= 0.001:
		_show_next_commander_dialogue_hud()

func _tick_commander_reports(_delta: float) -> void:
	if not commander_report_enabled:
		if commander_report_panel != null and is_instance_valid(commander_report_panel):
			commander_report_panel.visible = false
		return
	if commander_report_entries.is_empty():
		if commander_report_panel != null and is_instance_valid(commander_report_panel):
			commander_report_panel.visible = false
		return
	var now_sec: float = float(Time.get_ticks_msec()) * 0.001
	var changed: bool = false
	for i in range(commander_report_entries.size() - 1, -1, -1):
		var entry: Dictionary = commander_report_entries[i]
		if float(entry.get("expire_at", 0.0)) <= now_sec:
			commander_report_entries.remove_at(i)
			changed = true
	if changed:
		_refresh_commander_report_panel()
	if commander_report_panel != null and is_instance_valid(commander_report_panel):
		commander_report_panel.visible = not commander_report_entries.is_empty()

func _refresh_commander_report_panel() -> void:
	if commander_report_list == null or not is_instance_valid(commander_report_list):
		return
	for child in commander_report_list.get_children():
		child.queue_free()
	var keep_lines: int = maxi(1, commander_report_keep_lines)
	var start_idx: int = maxi(0, commander_report_entries.size() - keep_lines)
	for i in range(start_idx, commander_report_entries.size()):
		var entry: Dictionary = commander_report_entries[i]
		var line_text: String = String(entry.get("text", "")).strip_edges()
		if line_text.is_empty():
			continue
		var line_label := Label.new()
		line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		line_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line_label.text = line_text
		line_label.add_theme_font_size_override("font_size", 17)
		line_label.add_theme_color_override("font_color", Color(0.97, 0.94, 0.86, 0.98))
		line_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.0))
		line_label.add_theme_color_override("font_outline_color", Color(0.16, 0.11, 0.07, 0.88))
		line_label.add_theme_constant_override("outline_size", 1)
		if _tag_font != null:
			line_label.add_theme_font_override("font", _tag_font)
		commander_report_list.add_child(line_label)
	if commander_report_panel != null and is_instance_valid(commander_report_panel):
		commander_report_panel.visible = commander_report_enabled and not commander_report_entries.is_empty()

func _push_commander_report(message: String, duration_sec: float = -1.0, hud_payload: Dictionary = {}) -> void:
	if not commander_report_enabled:
		return
	var text: String = message.strip_edges()
	if text.is_empty():
		return
	var now_sec: float = float(Time.get_ticks_msec()) * 0.001
	var keep_lines: int = maxi(1, commander_report_keep_lines)
	var hold_sec: float = maxf(0.8, duration_sec if duration_sec > 0.0 else commander_report_duration)
	commander_report_entries.append({
		"text": text,
		"expire_at": now_sec + hold_sec
	})
	while commander_report_entries.size() > keep_lines:
		commander_report_entries.remove_at(0)
	_refresh_commander_report_panel()
	if not hud_payload.is_empty() and bool(hud_payload.get("show_hud", false)):
		_enqueue_commander_dialogue_hud(
			text,
			int(hud_payload.get("team_id", -1)),
			String(hud_payload.get("speaker", "")),
			float(hud_payload.get("hud_duration", minf(4.2, hold_sec)))
		)

func _reset_demo_siege_debug_stats() -> void:
	_demo_siege_ai_tick_accum = 0.0
	_demo_siege_debug_tick_accum = 0.0
	_demo_siege_objective_panel_tick_accum = 0.0
	_demo_siege_variant_skill_cooldowns.clear()
	_demo_siege_variant_facility_damage.clear()
	_demo_siege_variant_proc_counts.clear()
	_demo_siege_objective_winner_team = -1
	_demo_siege_objective_message = ""
	for variant_id in SIEGE_VARIANT_ORDER:
		_demo_siege_variant_facility_damage[variant_id] = 0.0

func _record_demo_siege_variant_facility_damage(unit: UnitController, damage: float) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	if damage <= 0.001:
		return
	var variant_id: String = _unit_siege_variant_id(unit)
	if variant_id.is_empty():
		return
	_demo_siege_variant_facility_damage[variant_id] = float(_demo_siege_variant_facility_damage.get(variant_id, 0.0)) + maxf(0.0, damage)

func _record_demo_siege_variant_proc(variant_id: String, proc_key: String) -> void:
	var safe_variant: String = _normalize_siege_variant_id(variant_id)
	var safe_proc: String = proc_key.strip_edges().to_lower()
	if safe_variant.is_empty() or safe_proc.is_empty():
		return
	var key: String = "%s:%s" % [safe_variant, safe_proc]
	_demo_siege_variant_proc_counts[key] = int(_demo_siege_variant_proc_counts.get(key, 0)) + 1

func _demo_siege_proc_count(variant_id: String, proc_key: String) -> int:
	var key: String = "%s:%s" % [_normalize_siege_variant_id(variant_id), proc_key.strip_edges().to_lower()]
	return int(_demo_siege_variant_proc_counts.get(key, 0))

func _build_demo_siege_debug_line(variant_id: String) -> String:
	var display_name: String = _siege_variant_display_name(variant_id)
	var facility_damage: float = float(_demo_siege_variant_facility_damage.get(variant_id, 0.0))
	match variant_id:
		"ram":
			return "%s 城伤 %.0f | 触发: 对兵燃烧 %d / 攻城燃烧 %d / 技能突击 %d" % [
				display_name,
				facility_damage,
				_demo_siege_proc_count(variant_id, "on_hit_burn"),
				_demo_siege_proc_count(variant_id, "facility_burn"),
				_demo_siege_proc_count(variant_id, "skill_ram")
			]
		"ladder":
			return "%s 城伤 %.0f | 触发: 对兵士气打击 %d / 攻城士气压制 %d / 技能压制 %d" % [
				display_name,
				facility_damage,
				_demo_siege_proc_count(variant_id, "on_hit_morale"),
				_demo_siege_proc_count(variant_id, "facility_morale"),
				_demo_siege_proc_count(variant_id, "skill_ladder")
			]
		"catapult":
			return "%s 城伤 %.0f | 触发: 对兵溅射 %d / 攻城溅射 %d / 技能轰击 %d" % [
				display_name,
				facility_damage,
				_demo_siege_proc_count(variant_id, "on_hit_splash"),
				_demo_siege_proc_count(variant_id, "facility_splash"),
				_demo_siege_proc_count(variant_id, "skill_catapult")
			]
		_:
			return "%s 城伤 %.0f" % [display_name, facility_damage]

func _refresh_demo_siege_debug_overlay(force: bool = false) -> void:
	if siege_debug_panel == null or not is_instance_valid(siege_debug_panel):
		return
	if siege_debug_text == null or not is_instance_valid(siege_debug_text):
		return
	var enabled: bool = demo_siege_debug_overlay_enabled and not embedded_on_strategy_map
	siege_debug_panel.visible = enabled
	if not enabled:
		return
	if not force and _demo_siege_debug_tick_accum < maxf(0.1, demo_siege_debug_overlay_refresh_sec):
		return
	_demo_siege_debug_tick_accum = 0.0
	var lines: Array[String] = ["攻城调试"]
	lines.append("AI模式: %s" % ("只攻城" if demo_siege_ai_only_facility_mode else "优先攻城"))
	for variant_id in SIEGE_VARIANT_ORDER:
		lines.append(_build_demo_siege_debug_line(variant_id))
	if _demo_siege_objective_winner_team >= 0:
		lines.append("目标判定: T%d 胜利" % _demo_siege_objective_winner_team)
	siege_debug_text.text = "\n".join(lines)

func _tick_demo_siege_debug_overlay(delta: float) -> void:
	_demo_siege_debug_tick_accum += maxf(0.0, delta)
	_refresh_demo_siege_debug_overlay(false)

func _is_demo_siege_ai_team_enabled(team_id: int) -> bool:
	return team_id != 0 or demo_siege_ai_apply_to_player_team

func _has_enemy_alive_demo_facility(team_id: int) -> bool:
	for fac_any in _demo_facilities:
		if not (fac_any is Dictionary):
			continue
		var fac: Dictionary = fac_any as Dictionary
		if _is_demo_facility_destroyed(fac):
			continue
		if int(fac.get("team_id", -1)) != team_id:
			return true
	return false

func _should_force_demo_siege_ai_only_facility(unit: UnitController) -> bool:
	if not demo_siege_ai_only_facility_mode:
		return false
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return false
	if _unit_role_id(unit) != "siege":
		return false
	if not _is_demo_siege_ai_team_enabled(int(unit.team_id)):
		return false
	return _has_enemy_alive_demo_facility(int(unit.team_id))

func _collect_demo_siege_troops_by_team() -> Dictionary:
	var troops_by_team: Dictionary = {}
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if not _is_live_demo_unit(unit):
			continue
		var team_id: int = int(unit.team_id)
		var alive_troops: int = 0
		if unit.has_method("get_alive_troop_count"):
			alive_troops = maxi(0, int(unit.call("get_alive_troop_count")))
		else:
			alive_troops = maxi(0, int(unit.troop_count))
		troops_by_team[team_id] = int(troops_by_team.get(team_id, 0)) + alive_troops
	return troops_by_team

func _collect_demo_siege_city_metrics() -> Dictionary:
	var city_total_by_team: Dictionary = {}
	var city_alive_by_team: Dictionary = {}
	var city_hp_by_team: Dictionary = {}
	var city_max_hp_by_team: Dictionary = {}
	for fac_any in _demo_facilities:
		if not (fac_any is Dictionary):
			continue
		var fac: Dictionary = fac_any as Dictionary
		var type_key: String = String(fac.get("type", "")).to_lower().strip_edges()
		if type_key != "chengzhai":
			continue
		var team_id: int = int(fac.get("team_id", -1))
		if team_id < 0:
			continue
		city_total_by_team[team_id] = int(city_total_by_team.get(team_id, 0)) + 1
		var hp: float = maxf(0.0, float(fac.get("hp", 0.0)))
		var max_hp: float = maxf(1.0, float(fac.get("max_hp", 1.0)))
		city_max_hp_by_team[team_id] = float(city_max_hp_by_team.get(team_id, 0.0)) + max_hp
		if not _is_demo_facility_destroyed(fac):
			city_alive_by_team[team_id] = int(city_alive_by_team.get(team_id, 0)) + 1
			city_hp_by_team[team_id] = float(city_hp_by_team.get(team_id, 0.0)) + hp
	for team_id in [0, 1]:
		city_total_by_team[team_id] = int(city_total_by_team.get(team_id, 0))
		city_alive_by_team[team_id] = int(city_alive_by_team.get(team_id, 0))
		city_hp_by_team[team_id] = float(city_hp_by_team.get(team_id, 0.0))
		city_max_hp_by_team[team_id] = float(city_max_hp_by_team.get(team_id, 0.0))
	return {
		"total": city_total_by_team,
		"alive": city_alive_by_team,
		"hp": city_hp_by_team,
		"max_hp": city_max_hp_by_team
	}

func _predict_demo_siege_objective_team(city_metrics: Dictionary, troops_by_team: Dictionary) -> int:
	if _demo_siege_objective_winner_team >= 0:
		return _demo_siege_objective_winner_team
	var city_total_any: Variant = city_metrics.get("total", {})
	var city_alive_any: Variant = city_metrics.get("alive", {})
	var city_hp_any: Variant = city_metrics.get("hp", {})
	var city_max_hp_any: Variant = city_metrics.get("max_hp", {})
	var city_total: Dictionary = (city_total_any as Dictionary) if city_total_any is Dictionary else {}
	var city_alive: Dictionary = (city_alive_any as Dictionary) if city_alive_any is Dictionary else {}
	var city_hp: Dictionary = (city_hp_any as Dictionary) if city_hp_any is Dictionary else {}
	var city_max_hp: Dictionary = (city_max_hp_any as Dictionary) if city_max_hp_any is Dictionary else {}
	var troop_0: float = maxf(0.0, float(troops_by_team.get(0, 0.0)))
	var troop_1: float = maxf(0.0, float(troops_by_team.get(1, 0.0)))
	var troop_sum: float = troop_0 + troop_1
	var troop_ratio_0: float = troop_0 / troop_sum if troop_sum > 0.001 else 0.5
	var troop_ratio_1: float = troop_1 / troop_sum if troop_sum > 0.001 else 0.5
	var city_total_0: float = maxf(0.0, float(city_total.get(0, 0.0)))
	var city_total_1: float = maxf(0.0, float(city_total.get(1, 0.0)))
	var city_alive_0: float = maxf(0.0, float(city_alive.get(0, 0.0)))
	var city_alive_1: float = maxf(0.0, float(city_alive.get(1, 0.0)))
	var city_control_0: float = city_alive_0 / city_total_0 if city_total_0 > 0.001 else 0.5
	var city_control_1: float = city_alive_1 / city_total_1 if city_total_1 > 0.001 else 0.5
	var city_hp_sum_0: float = maxf(0.0, float(city_hp.get(0, 0.0)))
	var city_hp_sum_1: float = maxf(0.0, float(city_hp.get(1, 0.0)))
	var city_max_sum_0: float = maxf(0.0, float(city_max_hp.get(0, 0.0)))
	var city_max_sum_1: float = maxf(0.0, float(city_max_hp.get(1, 0.0)))
	var city_hp_ratio_0: float = city_hp_sum_0 / city_max_sum_0 if city_max_sum_0 > 0.001 else city_control_0
	var city_hp_ratio_1: float = city_hp_sum_1 / city_max_sum_1 if city_max_sum_1 > 0.001 else city_control_1
	var city_score_0: float = city_control_0 * 0.62 + city_hp_ratio_0 * 0.38
	var city_score_1: float = city_control_1 * 0.62 + city_hp_ratio_1 * 0.38
	var score_0: float = troop_ratio_0 * 0.58 + city_score_0 * 0.42
	var score_1: float = troop_ratio_1 * 0.58 + city_score_1 * 0.42
	if absf(score_0 - score_1) <= 0.04:
		return -1
	return 0 if score_0 > score_1 else 1

func _demo_team_side_text(team_id: int) -> String:
	if team_id == 0:
		return "我军"
	if team_id == 1:
		return "敌军"
	return "未知"

func _build_demo_siege_objective_panel_text() -> String:
	if _demo_facilities.is_empty():
		return "攻城目标\n尚未部署攻城设施。"
	var city_metrics: Dictionary = _collect_demo_siege_city_metrics()
	var total_any: Variant = city_metrics.get("total", {})
	var alive_any: Variant = city_metrics.get("alive", {})
	var total: Dictionary = (total_any as Dictionary) if total_any is Dictionary else {}
	var alive: Dictionary = (alive_any as Dictionary) if alive_any is Dictionary else {}
	var troops_by_team: Dictionary = _collect_demo_siege_troops_by_team()
	var team0_city_total: int = int(total.get(0, 0))
	var team1_city_total: int = int(total.get(1, 0))
	var team0_city_alive: int = int(alive.get(0, 0))
	var team1_city_alive: int = int(alive.get(1, 0))
	var team0_troops: int = maxi(0, int(troops_by_team.get(0, 0)))
	var team1_troops: int = maxi(0, int(troops_by_team.get(1, 0)))
	var team0_progress: float = 0.0
	var team1_progress: float = 0.0
	if team1_city_total > 0:
		team0_progress = clampf(1.0 - float(team1_city_alive) / float(team1_city_total), 0.0, 1.0)
	if team0_city_total > 0:
		team1_progress = clampf(1.0 - float(team0_city_alive) / float(team0_city_total), 0.0, 1.0)
	var lines: Array[String] = ["攻城目标"]
	lines.append("城池: 我方 %d/%d | 敌方 %d/%d" % [team0_city_alive, team0_city_total, team1_city_alive, team1_city_total])
	lines.append("进度: 我军 %.0f%% | 敌军 %.0f%%" % [team0_progress * 100.0, team1_progress * 100.0])
	lines.append("兵力: 我军 %d | 敌军 %d" % [team0_troops, team1_troops])
	if _demo_siege_objective_winner_team >= 0:
		lines.append("判定: %s已达成攻城目标" % _demo_team_side_text(_demo_siege_objective_winner_team))
	elif demo_siege_objective_panel_show_prediction:
		var predicted_team: int = _predict_demo_siege_objective_team(city_metrics, troops_by_team)
		var trend_text: String = "胶着"
		if predicted_team == 0:
			trend_text = "我军占优"
		elif predicted_team == 1:
			trend_text = "敌军占优"
		lines.append("倾向: %s" % trend_text)
	if not _demo_siege_objective_message.is_empty():
		lines.append(_demo_siege_objective_message)
	return "\n".join(lines)

func _refresh_demo_siege_objective_panel(force: bool = false) -> void:
	if siege_objective_panel == null or not is_instance_valid(siege_objective_panel):
		return
	if siege_objective_text == null or not is_instance_valid(siege_objective_text):
		return
	var enabled: bool = demo_siege_objective_panel_enabled and demo_siege_vs_facility_enabled and demo_siege_objective_enabled and demo_facility_test_setup_enabled and not embedded_on_strategy_map
	siege_objective_panel.visible = enabled
	if not enabled:
		return
	if not force and _demo_siege_objective_panel_tick_accum < maxf(0.1, demo_siege_objective_panel_refresh_sec):
		return
	_demo_siege_objective_panel_tick_accum = 0.0
	siege_objective_text.text = _build_demo_siege_objective_panel_text()

func _tick_demo_siege_objective_panel(delta: float) -> void:
	_demo_siege_objective_panel_tick_accum += maxf(0.0, delta)
	_refresh_demo_siege_objective_panel(false)

func get_demo_objective_winner_team() -> int:
	return _demo_siege_objective_winner_team

func has_demo_objective_result() -> bool:
	return _demo_siege_objective_winner_team >= 0

func get_demo_siege_debug_snapshot() -> Dictionary:
	return {
		"objective_winner_team": _demo_siege_objective_winner_team,
		"objective_message": _demo_siege_objective_message,
		"facility_damage_by_variant": _demo_siege_variant_facility_damage.duplicate(true),
		"proc_counts": _demo_siege_variant_proc_counts.duplicate(true)
	}

func _tick_demo_siege_variant_skill_cooldowns(step_sec: float) -> void:
	if step_sec <= 0.0 or _demo_siege_variant_skill_cooldowns.is_empty():
		return
	var remove_keys: Array = []
	for key_any in _demo_siege_variant_skill_cooldowns.keys():
		var key: String = String(key_any)
		var left: float = maxf(0.0, float(_demo_siege_variant_skill_cooldowns.get(key, 0.0)) - step_sec)
		if left <= 0.001:
			remove_keys.append(key)
		else:
			_demo_siege_variant_skill_cooldowns[key] = left
	for key_any in remove_keys:
		_demo_siege_variant_skill_cooldowns.erase(String(key_any))

func _demo_siege_variant_skill_cd_sec(variant_id: String) -> float:
	match variant_id:
		"ram":
			return maxf(0.0, demo_siege_skill_cd_ram)
		"ladder":
			return maxf(0.0, demo_siege_skill_cd_ladder)
		"catapult":
			return maxf(0.0, demo_siege_skill_cd_catapult)
		_:
			return 0.0

func _demo_siege_variant_skill_bonus_sec(variant_id: String) -> float:
	match variant_id:
		"ram":
			return maxf(0.0, demo_siege_skill_ram_bonus_sec)
		"ladder":
			return maxf(0.0, demo_siege_skill_ladder_bonus_sec)
		"catapult":
			return maxf(0.0, demo_siege_skill_catapult_bonus_sec)
		_:
			return 0.0

func _consume_demo_siege_variant_skill(unit: UnitController, variant_id: String) -> bool:
	if unit == null or not is_instance_valid(unit):
		return false
	var cd_sec: float = _demo_siege_variant_skill_cd_sec(variant_id)
	if cd_sec <= 0.001:
		return true
	var key: String = "%d|%s" % [unit.get_instance_id(), variant_id]
	var left: float = float(_demo_siege_variant_skill_cooldowns.get(key, 0.0))
	if left > 0.001:
		return false
	_demo_siege_variant_skill_cooldowns[key] = cd_sec
	return true

func _try_trigger_demo_siege_variant_skill(unit: UnitController, base_dps: float) -> float:
	if not demo_siege_variant_skill_enabled:
		return 0.0
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return 0.0
	if _unit_role_id(unit) != "siege":
		return 0.0
	if base_dps <= 0.001:
		return 0.0
	var variant_id: String = _unit_siege_variant_id(unit)
	if variant_id.is_empty():
		return 0.0
	if not _consume_demo_siege_variant_skill(unit, variant_id):
		return 0.0
	var bonus_sec: float = _demo_siege_variant_skill_bonus_sec(variant_id)
	if bonus_sec <= 0.001:
		return 0.0
	var extra_damage: float = maxf(0.0, base_dps * bonus_sec)
	if extra_damage <= 0.001:
		return 0.0
	_record_demo_siege_variant_proc(variant_id, "skill_%s" % variant_id)
	return extra_damage

func _resolve_demo_objective_winner_from_units(excluded_teams: Array = []) -> int:
	var excluded: Dictionary = {}
	for team_any in excluded_teams:
		excluded[int(team_any)] = true
	var troops_by_team: Dictionary = {}
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if not _is_live_demo_unit(unit):
			continue
		var team_id: int = int(unit.team_id)
		if excluded.has(team_id):
			continue
		var alive_troops: int = 0
		if unit.has_method("get_alive_troop_count"):
			alive_troops = maxi(0, int(unit.call("get_alive_troop_count")))
		else:
			alive_troops = maxi(0, int(unit.troop_count))
		troops_by_team[team_id] = int(troops_by_team.get(team_id, 0)) + alive_troops
	var best_team: int = -1
	var best_troops: int = -1
	var tie: bool = false
	for team_any in troops_by_team.keys():
		var team_id: int = int(team_any)
		var troops: int = int(troops_by_team.get(team_any, 0))
		if troops > best_troops:
			best_troops = troops
			best_team = team_id
			tie = false
		elif troops == best_troops and troops > 0:
			tie = true
	if best_team >= 0 and best_troops > 0 and not tie:
		return best_team
	var alive_facilities_by_team: Dictionary = {}
	for fac_any in _demo_facilities:
		if not (fac_any is Dictionary):
			continue
		var fac: Dictionary = fac_any as Dictionary
		if _is_demo_facility_destroyed(fac):
			continue
		var team_id: int = int(fac.get("team_id", -1))
		if team_id < 0 or excluded.has(team_id):
			continue
		alive_facilities_by_team[team_id] = int(alive_facilities_by_team.get(team_id, 0)) + 1
	var best_fac_team: int = -1
	var best_fac_count: int = -1
	tie = false
	for team_any in alive_facilities_by_team.keys():
		var team_id: int = int(team_any)
		var count: int = int(alive_facilities_by_team.get(team_any, 0))
		if count > best_fac_count:
			best_fac_count = count
			best_fac_team = team_id
			tie = false
		elif count == best_fac_count and count > 0:
			tie = true
	if best_fac_team >= 0 and best_fac_count > 0 and not tie:
		return best_fac_team
	return -1

func _resolve_demo_objective_winner_against(defender_team_id: int) -> int:
	if defender_team_id == 0:
		if _resolve_demo_objective_winner_from_units([defender_team_id]) == 1:
			return 1
	elif defender_team_id == 1:
		if _resolve_demo_objective_winner_from_units([defender_team_id]) == 0:
			return 0
	return _resolve_demo_objective_winner_from_units([defender_team_id])

func _commit_demo_siege_objective_result(winner_team: int, message: String) -> void:
	if winner_team < 0:
		return
	if _demo_siege_objective_winner_team >= 0:
		return
	var text: String = message.strip_edges()
	if text.is_empty():
		var side_text: String = "我军" if winner_team == 0 else "敌军"
		text = "主公，%s攻破敌方城池，已得全胜。" % side_text
	_demo_siege_objective_winner_team = winner_team
	_demo_siege_objective_message = text
	var hold_sec: float = maxf(1.0, demo_siege_objective_status_hold_sec)
	if demo_siege_objective_report_enabled:
		_push_commander_report(text, hold_sec)
	_set_battle_status(text, hold_sec)
	_refresh_demo_siege_objective_panel(true)

func _evaluate_demo_siege_objective() -> void:
	if not demo_siege_objective_enabled:
		return
	if _demo_siege_objective_winner_team >= 0:
		return
	if _demo_facilities.is_empty():
		return
	var city_total_by_team: Dictionary = {}
	var city_alive_by_team: Dictionary = {}
	for fac_any in _demo_facilities:
		if not (fac_any is Dictionary):
			continue
		var fac: Dictionary = fac_any as Dictionary
		var type_key: String = String(fac.get("type", "")).to_lower().strip_edges()
		if type_key != "chengzhai":
			continue
		var team_id: int = int(fac.get("team_id", -1))
		if team_id < 0:
			continue
		city_total_by_team[team_id] = int(city_total_by_team.get(team_id, 0)) + 1
		if not _is_demo_facility_destroyed(fac):
			city_alive_by_team[team_id] = int(city_alive_by_team.get(team_id, 0)) + 1
	if city_total_by_team.is_empty():
		return
	var fallen_teams: Array = []
	for team_any in city_total_by_team.keys():
		var team_id: int = int(team_any)
		var total_city: int = int(city_total_by_team.get(team_any, 0))
		if total_city <= 0:
			continue
		var alive_city: int = int(city_alive_by_team.get(team_any, 0))
		var reached: bool = alive_city <= 0 if demo_siege_objective_require_all_city_falls else alive_city < total_city
		if reached:
			fallen_teams.append(team_id)
	if fallen_teams.is_empty():
		return
	var winner_team: int = -1
	if fallen_teams.size() == 1:
		winner_team = _resolve_demo_objective_winner_against(int(fallen_teams[0]))
	else:
		winner_team = _resolve_demo_objective_winner_from_units(fallen_teams)
	if winner_team < 0:
		return
	var target_desc: Array[String] = []
	for team_any in fallen_teams:
		var team_id: int = int(team_any)
		var side_text: String = "我方" if team_id == 0 else "敌方"
		target_desc.append("%s城池" % side_text)
	var winner_text: String = "我军" if winner_team == 0 else "敌军"
	var text: String = "主公，%s摧毁%s，攻城告捷。" % [winner_text, "、".join(target_desc)]
	_commit_demo_siege_objective_result(winner_team, text)

func _resolve_report_unit_name(unit) -> String:
	if unit == null or not is_instance_valid(unit):
		return "未知部队"
	var panel_data: Dictionary = unit.call("get_rts_panel_data") if unit.has_method("get_rts_panel_data") else {}
	var display_name: String = ""
	if not panel_data.is_empty():
		display_name = String(panel_data.get("main_name", panel_data.get("commander_name", panel_data.get("name", "")))).strip_edges()
	if display_name.is_empty():
		display_name = String(unit.name).strip_edges()
	return display_name if not display_name.is_empty() else "未知部队"

func _empty_battle_reward() -> Dictionary:
	return {
		"war_merit": 0,
		"gongji": 0,
		"tech_points": 0,
		"grain": 0,
		"wood": 0,
		"iron": 0
	}

func _normalize_battle_reward(reward: Dictionary) -> Dictionary:
	var normalized: Dictionary = _empty_battle_reward()
	for key_any in normalized.keys():
		var key: String = String(key_any)
		normalized[key] = maxi(0, int(round(float(reward.get(key, 0)))))
	return normalized

func _ensure_team_battle_stats(team_id: int) -> Dictionary:
	var stats_any: Variant = commander_report_team_stats.get(team_id, {})
	var stats: Dictionary = {}
	if stats_any is Dictionary:
		stats = (stats_any as Dictionary).duplicate(true)
	if stats.is_empty():
		stats = _empty_battle_reward()
	else:
		for key_any in _empty_battle_reward().keys():
			var key: String = String(key_any)
			if not stats.has(key):
				stats[key] = 0
			else:
				stats[key] = maxi(0, int(stats[key]))
	commander_report_team_stats[team_id] = stats
	return stats

func _pick_report_text(choices: Array[String], fallback: String) -> String:
	if choices.is_empty():
		return fallback
	var idx: int = randi() % choices.size()
	return String(choices[idx]).strip_edges()

func _format_battle_reward_delta(reward: Dictionary) -> String:
	return "此役获战绩%d、功绩%d、科技点%d，并得粮草%d、木材%d、镔铁%d" % [
		int(reward.get("war_merit", 0)),
		int(reward.get("gongji", 0)),
		int(reward.get("tech_points", 0)),
		int(reward.get("grain", 0)),
		int(reward.get("wood", 0)),
		int(reward.get("iron", 0))
	]

func _format_battle_reward_total(team_id: int) -> String:
	var stats: Dictionary = _ensure_team_battle_stats(team_id)
	return "今计战绩%d、功绩%d、科技点%d（粮草%d 木材%d 镔铁%d）" % [
		int(stats.get("war_merit", 0)),
		int(stats.get("gongji", 0)),
		int(stats.get("tech_points", 0)),
		int(stats.get("grain", 0)),
		int(stats.get("wood", 0)),
		int(stats.get("iron", 0))
	]

func _grant_team_battle_reward(team_id: int, reward: Dictionary, reason: String = "", hold_sec: float = 5.8, announce_report: bool = true, speaker_name: String = "") -> Dictionary:
	if team_id < 0:
		return _empty_battle_reward()
	var delta: Dictionary = _normalize_battle_reward(reward)
	var stats: Dictionary = _ensure_team_battle_stats(team_id)
	for key_any in delta.keys():
		var key: String = String(key_any)
		stats[key] = int(stats.get(key, 0)) + int(delta.get(key, 0))
	commander_report_team_stats[team_id] = stats
	if not announce_report:
		return delta
	var side_text: String = "我军" if team_id == 0 else "敌军"
	var reason_text: String = reason.strip_edges()
	var prefix: String = ""
	if not reason_text.is_empty():
		prefix = _pick_report_text([
			"主公，%s%s，士气大振。" % [side_text, reason_text],
			"主公，%s%s，三军请功。" % [side_text, reason_text],
			"主公，%s%s，前线威势如虹。" % [side_text, reason_text]
		], "主公，%s%s，士气大振。" % [side_text, reason_text])
	else:
		prefix = _pick_report_text([
			"主公，%s捷音已至。" % side_text,
			"主公，%s前线传来佳讯。" % side_text,
			"主公，%s军心大振，战势正盛。" % side_text
		], "主公，%s捷音已至。" % side_text)
	var reporter_name: String = speaker_name.strip_edges()
	if reporter_name.is_empty():
		reporter_name = _resolve_report_unit_name(_find_team_report_commander(team_id))
	_push_commander_report(
		"%s %s." % [prefix, _format_battle_reward_delta(delta)],
		hold_sec,
		{
			"show_hud": true,
			"team_id": team_id,
			"speaker": reporter_name,
			"hud_duration": 3.9
		}
	)
	return delta
func _find_team_report_commander(team_id: int):
	var best = null
	var best_alive: int = -1
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if not _is_live_demo_unit(unit):
			continue
		if int(unit.team_id) != team_id:
			continue
		var alive_count: int = int(unit.soldier_count)
		if unit.has_method("get_alive_troop_count"):
			alive_count = int(unit.call("get_alive_troop_count"))
		elif unit.has_method("get_alive_soldier_count"):
			alive_count = int(unit.call("get_alive_soldier_count"))
		if best == null or alive_count > best_alive:
			best = unit
			best_alive = alive_count
	return best

func _trigger_commander_event_line(unit, event_key: String, fallback_text: String, context: Dictionary = {}, duration_sec: float = 3.1, priority: int = 2) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	var final_text: String = fallback_text.strip_edges()
	if unit.has_method("pick_commander_dialogue_line"):
		var picked_any: Variant = unit.call("pick_commander_dialogue_line", event_key, fallback_text, context)
		final_text = String(picked_any).strip_edges()
	if final_text.is_empty():
		final_text = fallback_text.strip_edges()
	if final_text.is_empty():
		return
	if unit.has_method("say_commander_line"):
		unit.call("say_commander_line", final_text, duration_sec, priority)

func on_unit_defeated(killer, defeated) -> void:
	var defender_name: String = _resolve_report_unit_name(defeated)
	var defender_team_id: int = int(defeated.team_id) if defeated != null and is_instance_valid(defeated) else -1
	var report_line: String = ""
	var hud_team_id: int = defender_team_id
	var hud_speaker: String = defender_name
	if killer == null or not is_instance_valid(killer):
		report_line = _pick_report_text([
			"主公，%s阵线崩解，已现溃动。" % defender_name,
			"主公，%s军形尽乱，已退入后阵。" % defender_name,
			"主公，%s兵锋受挫，阵脚已失。" % defender_name
		], "主公，%s阵线崩解，已现溃动。" % defender_name)
		_push_commander_report(
			report_line,
			5.2,
			{
				"show_hud": true,
				"team_id": hud_team_id,
				"speaker": hud_speaker,
				"hud_duration": 3.7
			}
		)
		_set_battle_status(report_line, 2.4)
		return
	var attacker_name: String = _resolve_report_unit_name(killer)
	var attacker_team_id: int = int(killer.team_id)
	if attacker_team_id == 0:
		report_line = _pick_report_text([
			"主公，前锋%s已击破敌军%s，缴获已入册。" % [attacker_name, defender_name],
			"主公，%s破阵得手，敌军%s已被拿下。" % [attacker_name, defender_name],
			"主公，%s斩溃敌军%s，前线捷报传来。" % [attacker_name, defender_name]
		], "主公，%s已击破敌军%s，缴获已入册。" % [attacker_name, defender_name])
		hud_team_id = attacker_team_id
		hud_speaker = attacker_name
		var reward_delta: Dictionary = _grant_team_battle_reward(attacker_team_id, REPORT_REWARD_UNIT_DEFEAT, "击破%s" % defender_name, 5.8, false, attacker_name)
		var combined_line: String = "%s %s." % [report_line, _format_battle_reward_delta(reward_delta)]
		_push_commander_report(
			combined_line,
			5.8,
			{
				"show_hud": true,
				"team_id": hud_team_id,
				"speaker": hud_speaker,
				"hud_duration": 4.3
			}
		)
		_set_battle_status(report_line, 2.4)
	else:
		var reporter = _find_team_report_commander(defender_team_id)
		var reporter_name: String = _resolve_report_unit_name(reporter if reporter != null else defeated)
		report_line = _pick_report_text([
			"主公，我军%s已被敌将%s击破，战线告急。" % [defender_name, attacker_name],
			"主公，%s所部失利，敌将%s正乘势压进。" % [defender_name, attacker_name],
			"主公，我军%s退入后阵，敌军攻势未止。" % defender_name
		], "主公，我军%s已被敌将%s击破，战线告急。" % [defender_name, attacker_name])
		hud_team_id = defender_team_id
		hud_speaker = reporter_name
		_push_commander_report(
			report_line,
			5.6,
			{
				"show_hud": true,
				"team_id": hud_team_id,
				"speaker": hud_speaker,
				"hud_duration": 4.0
			}
		)
		_set_battle_status(report_line, 2.4)
	var ctx := {"target": defender_name}
	_trigger_commander_event_line(killer, "victory_unit", "敌军已破，乘胜追击！", ctx, 3.0, 2)
func on_site_captured(captor_team_id: int, site_name: String, reward: Dictionary = {}) -> void:
	if captor_team_id < 0:
		return
	var site_text: String = site_name.strip_edges()
	if site_text.is_empty():
		site_text = "据点"
	var reward_payload: Dictionary = REPORT_REWARD_CITY_CAPTURE if reward.is_empty() else reward
	var commander = _find_team_report_commander(captor_team_id)
	var commander_name: String = _resolve_report_unit_name(commander)
	var report_line: String = ""
	if captor_team_id == 0:
		report_line = _pick_report_text([
			"主公，我军已夺取%s，军资尽入掌中。" % site_text,
			"主公，%s已归我军控制，前线战获已清点。" % site_text,
			"主公，我军攻克%s，辎重与战资皆已接收。" % site_text
		], "主公，我军已夺取%s，军资尽入掌中。" % site_text)
		var reward_delta: Dictionary = _grant_team_battle_reward(captor_team_id, reward_payload, "占领%s" % site_text, 6.2, false, commander_name)
		var combined_line: String = "%s %s." % [report_line, _format_battle_reward_delta(reward_delta)]
		_push_commander_report(
			combined_line,
			6.2,
			{
				"show_hud": true,
				"team_id": captor_team_id,
				"speaker": commander_name,
				"hud_duration": 4.4
			}
		)
		_set_battle_status(report_line, 2.8)
		var ctx_win := {"site": site_text}
		_trigger_commander_event_line(commander, "victory_site", "据点已克，收拢军资！", ctx_win, 3.2, 2)
	else:
		var defender_commander = _find_team_report_commander(0)
		var defender_name: String = _resolve_report_unit_name(defender_commander)
		report_line = _pick_report_text([
			"主公，敌军已夺占%s，我军前线据点失守。" % site_text,
			"主公，%s已落入敌手，需速整军再夺。" % site_text,
			"主公，我军失去%s，前线压力陡增。" % site_text
		], "主公，敌军已夺占%s，我军前线据点失守。" % site_text)
		_push_commander_report(
			report_line,
			5.8,
			{
				"show_hud": true,
				"team_id": 0,
				"speaker": defender_name,
				"hud_duration": 4.0
			}
		)
		_set_battle_status(report_line, 2.8)
func _set_battle_status(message: String, hold_sec: float = 2.2) -> void:
	battle_tip_message = message
	battle_tip_timer = maxf(0.1, hold_sec)
	if not rts_panel_widgets.has("status"):
		return
	var status_label: Label = rts_panel_widgets.get("status")
	if status_label != null:
		status_label.text = "%s | %s" % [message, _current_weather_text()]

func _ensure_tactic_vfx_root() -> Node3D:
	if tactic_vfx_root != null and is_instance_valid(tactic_vfx_root):
		return tactic_vfx_root
	tactic_vfx_root = Node3D.new()
	tactic_vfx_root.name = "TacticVfxRoot"
	tactic_vfx_root.top_level = true
	add_child(tactic_vfx_root)
	return tactic_vfx_root

func _register_temp_tactic_vfx(node: Node, ttl: float) -> void:
	if node == null or not is_instance_valid(node):
		return
	tactic_temp_vfx_nodes.append({
		"node": node,
		"time_left": maxf(0.08, ttl)
	})

func _make_tactic_vfx_material(base_color: Color, alpha: float = 0.7, emission_mul: float = 1.8) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mat.albedo_color = Color(base_color.r, base_color.g, base_color.b, clampf(alpha, 0.0, 1.0))
	mat.emission_enabled = true
	mat.emission = Color(base_color.r, base_color.g, base_color.b, 1.0)
	mat.emission_energy_multiplier = maxf(0.2, emission_mul)
	return mat

func _make_tactic_sprite_material(tex: Texture2D, tint: Color, alpha: float, emission_mul: float, h_frames: int, v_frames: int, loop: bool) -> StandardMaterial3D:
	if tex == null:
		return null
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mat.albedo_texture = tex
	mat.albedo_color = Color(tint.r, tint.g, tint.b, clampf(alpha, 0.0, 1.0))
	mat.emission_enabled = true
	mat.emission = Color(tint.r, tint.g, tint.b, 1.0)
	mat.emission_energy_multiplier = maxf(0.2, emission_mul)
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.billboard_keep_scale = true
	mat.particles_anim_h_frames = maxi(1, h_frames)
	mat.particles_anim_v_frames = maxi(1, v_frames)
	mat.particles_anim_loop = loop
	return mat

func _spawn_tactic_sprite_vfx(center: Vector3, tex: Texture2D, tint: Color, duration_sec: float, h_frames: int, v_frames: int, loop: bool, height: float, alpha_mul: float, spin: float, scale_from: float, scale_to: float) -> void:
	if tex == null:
		return
	var parent_root: Node3D = _ensure_tactic_vfx_root()
	var root_node := Node3D.new()
	root_node.name = "TacticSpriteVfx"
	root_node.top_level = true
	root_node.scale = Vector3.ONE * maxf(0.05, scale_from)
	parent_root.add_child(root_node)
	root_node.global_position = center + Vector3(0.0, height, 0.0)
	var emitter := GPUParticles3D.new()
	emitter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	emitter.one_shot = true
	emitter.amount = 1
	emitter.lifetime = maxf(0.1, duration_sec)
	emitter.explosiveness = 1.0
	emitter.preprocess = 0.0
	emitter.fixed_fps = 0
	var pm := ParticleProcessMaterial.new()
	pm.set("emission_shape", int(ParticleProcessMaterial.EMISSION_SHAPE_POINT))
	pm.set("direction", Vector3.UP)
	pm.set("spread", 0.0)
	pm.set("gravity", Vector3.ZERO)
	pm.set("initial_velocity_min", 0.0)
	pm.set("initial_velocity_max", 0.0)
	pm.set("scale_min", 1.0)
	pm.set("scale_max", 1.0)
	pm.set("anim_speed_min", 1.0)
	pm.set("anim_speed_max", 1.0)
	emitter.process_material = pm
	var mat: StandardMaterial3D = _make_tactic_sprite_material(tex, tint, alpha_mul, 1.9, h_frames, v_frames, loop)
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	quad.material = mat
	emitter.draw_pass_1 = quad
	emitter.emitting = true
	root_node.add_child(emitter)
	tactic_sprite_vfx_items.append({
		"root": root_node,
		"emitter": emitter,
		"mat": mat,
		"age": 0.0,
		"duration": maxf(0.1, duration_sec),
		"color": tint,
		"spin": spin,
		"alpha_mul": alpha_mul,
		"scale_from": maxf(0.05, scale_from),
		"scale_to": maxf(0.05, scale_to)
	})

func _make_fire_flame_shader_material(core: Color, edge: Color, alpha_mul: float = 1.0) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = TACTIC_FIRE_FLAME_SHADER
	mat.set_shader_parameter("u_core_color", Color(core.r, core.g, core.b, clampf(core.a * alpha_mul, 0.08, 1.0)))
	mat.set_shader_parameter("u_edge_color", Color(edge.r, edge.g, edge.b, 1.0))
	mat.set_shader_parameter("u_time", 0.0)
	mat.set_shader_parameter("u_intensity", 1.0)
	return mat

func _make_particle_color_ramp(points: PackedFloat32Array, colors: PackedColorArray) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.offsets = points
	gradient.colors = colors
	var tex := GradientTexture1D.new()
	tex.gradient = gradient
	return tex

func _make_smoke_particle_material(base_alpha: float = 0.32) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	mat.albedo_color = Color(0.2, 0.2, 0.2, clampf(base_alpha, 0.06, 0.8))
	mat.emission_enabled = true
	mat.emission = Color(0.18, 0.16, 0.14, 1.0)
	mat.emission_energy_multiplier = 0.18
	return mat

func _spawn_fire_particles(root_node: Node3D, radius: float, primary: Color, accent: Color) -> Dictionary:
	var fire_emitters: Array[GPUParticles3D] = []
	var fire_emitter_materials: Array[ShaderMaterial] = []
	if root_node == null or not is_instance_valid(root_node):
		return {"emitters": fire_emitters, "shader_mats": fire_emitter_materials}
	var safe_radius: float = maxf(0.8, radius)
	var plume_radius: float = clampf(1.0 + safe_radius * 0.22, 1.0, 3.2)
	var body_count: int = clampi(int(round(24.0 + safe_radius * 8.0)), 24, 120)
	var tongue_count: int = clampi(int(round(12.0 + safe_radius * 4.0)), 12, 80)
	var ember_count: int = clampi(int(round(8.0 + safe_radius * 3.0)), 8, 56)

	var body_particles := GPUParticles3D.new()
	body_particles.name = "FireBody"
	body_particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body_particles.amount = body_count
	body_particles.lifetime = 1.24
	body_particles.one_shot = false
	body_particles.preprocess = 0.42
	body_particles.fixed_fps = 0
	body_particles.position = Vector3(0.0, 0.86, 0.0)
	var body_pm := ParticleProcessMaterial.new()
	body_pm.set("emission_shape", int(ParticleProcessMaterial.EMISSION_SHAPE_SPHERE))
	body_pm.set("emission_sphere_radius", plume_radius)
	body_pm.set("direction", Vector3.UP)
	body_pm.set("spread", 34.0)
	body_pm.set("gravity", Vector3(0.0, 3.4, 0.0))
	body_pm.set("initial_velocity_min", 1.8)
	body_pm.set("initial_velocity_max", 4.6)
	body_pm.set("damping_min", 0.06)
	body_pm.set("damping_max", 0.34)
	body_pm.set("scale_min", 1.0)
	body_pm.set("scale_max", 2.8)
	body_pm.set("anim_speed_min", 0.92)
	body_pm.set("anim_speed_max", 1.62)
	body_pm.set("color_ramp", _make_particle_color_ramp(
		PackedFloat32Array([0.0, 0.18, 0.54, 1.0]),
		PackedColorArray([
			Color(1.0, 0.98, 0.9, 0.86),
			Color(1.0, 0.86, 0.42, 0.9),
			Color(1.0, 0.48, 0.14, 0.62),
			Color(1.0, 0.24, 0.06, 0.0)
		])
	))
	body_particles.process_material = body_pm
	var body_mat: StandardMaterial3D = _make_tactic_sprite_material(TACTIC_TEX_FIRE_FLIPBOOK_03, primary.lerp(accent, 0.3), 0.98, 5.2, 8, 8, false)
	if body_mat != null:
		body_mat.no_depth_test = false
	var body_quad := QuadMesh.new()
	body_quad.size = Vector2(2.8, 2.8)
	body_quad.material = body_mat
	body_particles.draw_pass_1 = body_quad
	body_particles.emitting = true
	root_node.add_child(body_particles)
	fire_emitters.append(body_particles)

	var tongue_particles := GPUParticles3D.new()
	tongue_particles.name = "FireTongues"
	tongue_particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	tongue_particles.amount = tongue_count
	tongue_particles.lifetime = 1.36
	tongue_particles.one_shot = false
	tongue_particles.preprocess = 0.38
	tongue_particles.fixed_fps = 0
	tongue_particles.position = Vector3(0.0, 1.18, 0.0)
	var tongue_pm := ParticleProcessMaterial.new()
	tongue_pm.set("emission_shape", int(ParticleProcessMaterial.EMISSION_SHAPE_SPHERE))
	tongue_pm.set("emission_sphere_radius", plume_radius * 0.62)
	tongue_pm.set("direction", Vector3.UP)
	tongue_pm.set("spread", 20.0)
	tongue_pm.set("gravity", Vector3(0.0, 4.6, 0.0))
	tongue_pm.set("initial_velocity_min", 3.0)
	tongue_pm.set("initial_velocity_max", 6.2)
	tongue_pm.set("damping_min", 0.1)
	tongue_pm.set("damping_max", 0.5)
	tongue_pm.set("scale_min", 1.2)
	tongue_pm.set("scale_max", 3.2)
	tongue_pm.set("anim_speed_min", 1.12)
	tongue_pm.set("anim_speed_max", 2.08)
	tongue_pm.set("color_ramp", _make_particle_color_ramp(
		PackedFloat32Array([0.0, 0.16, 0.52, 1.0]),
		PackedColorArray([
			Color(1.0, 1.0, 0.94, 0.82),
			Color(1.0, 0.9, 0.46, 0.84),
			Color(1.0, 0.5, 0.16, 0.5),
			Color(1.0, 0.24, 0.06, 0.0)
		])
	))
	tongue_particles.process_material = tongue_pm
	var tongue_tint: Color = primary.lerp(Color(1.0, 0.92, 0.66, 1.0), 0.34).lerp(accent, 0.22)
	var tongue_mat: StandardMaterial3D = _make_tactic_sprite_material(TACTIC_TEX_FIRE_FLIPBOOK_03, tongue_tint, 0.9, 6.1, 8, 8, false)
	if tongue_mat != null:
		tongue_mat.no_depth_test = false
	var tongue_quad := QuadMesh.new()
	tongue_quad.size = Vector2(2.3, 4.2)
	tongue_quad.material = tongue_mat
	tongue_particles.draw_pass_1 = tongue_quad
	tongue_particles.emitting = true
	root_node.add_child(tongue_particles)
	fire_emitters.append(tongue_particles)

	var ember_particles := GPUParticles3D.new()
	ember_particles.name = "FireEmbers"
	ember_particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ember_particles.amount = ember_count
	ember_particles.lifetime = 1.18
	ember_particles.one_shot = false
	ember_particles.preprocess = 0.25
	ember_particles.fixed_fps = 0
	ember_particles.position = Vector3(0.0, 1.04, 0.0)
	var ember_pm := ParticleProcessMaterial.new()
	ember_pm.set("emission_shape", int(ParticleProcessMaterial.EMISSION_SHAPE_SPHERE))
	ember_pm.set("emission_sphere_radius", plume_radius * 0.9)
	ember_pm.set("direction", Vector3.UP)
	ember_pm.set("spread", 42.0)
	ember_pm.set("gravity", Vector3(0.0, 3.1, 0.0))
	ember_pm.set("initial_velocity_min", 1.4)
	ember_pm.set("initial_velocity_max", 3.8)
	ember_pm.set("damping_min", 0.35)
	ember_pm.set("damping_max", 1.28)
	ember_pm.set("scale_min", 0.06)
	ember_pm.set("scale_max", 0.2)
	ember_pm.set("color_ramp", _make_particle_color_ramp(
		PackedFloat32Array([0.0, 0.26, 0.72, 1.0]),
		PackedColorArray([
			Color(1.0, 1.0, 0.94, 0.9),
			Color(1.0, 0.84, 0.28, 0.8),
			Color(1.0, 0.44, 0.1, 0.34),
			Color(1.0, 0.24, 0.06, 0.0)
		])
	))
	ember_particles.process_material = ember_pm
	var ember_mesh := SphereMesh.new()
	ember_mesh.radius = 0.05
	ember_mesh.height = 0.1
	ember_particles.draw_pass_1 = ember_mesh
	var ember_shader: ShaderMaterial = _make_fire_flame_shader_material(primary.lerp(accent, 0.28), primary.lerp(Color(1.0, 0.18, 0.08, 1.0), 0.36), 0.92)
	ember_particles.material_override = ember_shader
	ember_particles.emitting = true
	root_node.add_child(ember_particles)
	fire_emitters.append(ember_particles)
	fire_emitter_materials.append(ember_shader)
	return {"emitters": fire_emitters, "shader_mats": fire_emitter_materials}

func _spawn_fire_cluster_vfx(center: Vector3, radius: float, duration_sec: float, primary: Color, accent: Color, lift: float = 0.0) -> void:
	if not tactic_vfx_enabled:
		return
	var root_node := Node3D.new()
	root_node.name = "TacticFireClusterVfx"
	root_node.top_level = true
	_ensure_tactic_vfx_root().add_child(root_node)
	root_node.global_position = center + Vector3(0.0, maxf(0.0, lift), 0.0)
	_spawn_fire_particles(root_node, maxf(0.8, radius), primary, accent)
	_register_temp_tactic_vfx(root_node, maxf(0.18, duration_sec))

func _random_flat_point(radius: float) -> Vector3:
	var r: float = maxf(0.0, radius)
	if r <= 0.001:
		return Vector3.ZERO
	var ang: float = randf() * TAU
	var len: float = sqrt(randf()) * r
	return Vector3(cos(ang) * len, 0.0, sin(ang) * len)

func _tactic_vfx_profile(tactic_id: String) -> Dictionary:
	var id: String = _canonical_tactic_id(tactic_id)
	match id:
		"strat_cheer":
			return {
				"color": Color(1.0, 0.9, 0.36, 1.0),
				"accent": Color(1.0, 0.98, 0.78, 1.0),
				"style": "support",
				"waves": 1,
				"wave_gap": 0.14,
				"style_idx": 1,
				"field_sec": 2.8,
				"cast_tex": TACTIC_TEX_STAR_03,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_STAR_EXPLOSION,
				"field_h": 6,
				"field_v": 5,
				"field_loop": false,
				"burst_tex": TACTIC_TEX_FLARE_01,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_delay":
			return {
				"color": Color(0.42, 0.84, 1.0, 1.0),
				"accent": Color(0.8, 0.97, 1.0, 1.0),
				"style": "wind",
				"waves": 2,
				"wave_gap": 0.16,
				"style_idx": 1,
				"field_sec": 2.6,
				"cast_tex": TACTIC_TEX_TWIRL_02,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_WAVY_BLUE,
				"field_h": 6,
				"field_v": 5,
				"field_loop": true,
				"burst_tex": TACTIC_TEX_CIRCLE_02,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_borrow_wind":
			return {
				"color": Color(0.48, 0.92, 0.98, 1.0),
				"accent": Color(0.95, 1.0, 1.0, 1.0),
				"style": "wind",
				"waves": 2,
				"wave_gap": 0.12,
				"style_idx": 1,
				"field_sec": 3.2,
				"cast_tex": TACTIC_TEX_TRACE_05,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_LIGHTSTREAKS,
				"field_h": 6,
				"field_v": 5,
				"field_loop": true,
				"burst_tex": TACTIC_TEX_SPOTLIGHT_06,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_fire_attack":
			return {
				"color": Color(1.0, 0.46, 0.14, 1.0),
				"accent": Color(1.0, 0.76, 0.26, 1.0),
				"style": "fire",
				"waves": 2,
				"wave_gap": 0.17,
				"style_idx": 2,
				"field_sec": 3.6,
				"cast_tex": TACTIC_TEX_FIRE_02,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_FIRE_RING,
				"field_h": 6,
				"field_v": 5,
				"field_loop": false,
				"burst_tex": TACTIC_TEX_FLAME_04,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_sow_discord":
			return {
				"color": Color(0.74, 0.46, 1.0, 1.0),
				"accent": Color(0.96, 0.84, 1.0, 1.0),
				"style": "control",
				"waves": 2,
				"wave_gap": 0.16,
				"style_idx": 2,
				"field_sec": 2.9,
				"cast_tex": TACTIC_TEX_TWIRL_04,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_WAVY_PURPLE,
				"field_h": 6,
				"field_v": 5,
				"field_loop": true,
				"burst_tex": TACTIC_TEX_SMOKE_06,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_weather_change":
			return {
				"color": Color(0.54, 0.84, 1.0, 1.0),
				"accent": Color(1.0, 0.95, 0.72, 1.0),
				"style": "support",
				"waves": 2,
				"wave_gap": 0.12,
				"style_idx": 2,
				"field_sec": 3.2,
				"cast_tex": TACTIC_TEX_LIGHT_03,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_WAVY_BLUE,
				"field_h": 6,
				"field_v": 5,
				"field_loop": true,
				"burst_tex": TACTIC_TEX_SPOTLIGHT_03,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_chain":
			return {
				"color": Color(0.52, 0.76, 1.0, 1.0),
				"accent": Color(0.94, 0.98, 1.0, 1.0),
				"style": "thunder",
				"waves": 2,
				"wave_gap": 0.14,
				"style_idx": 2,
				"field_sec": 3.2,
				"cast_tex": TACTIC_TEX_SPARK_02,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_ELECTRIC_RING,
				"field_h": 6,
				"field_v": 5,
				"field_loop": false,
				"burst_tex": TACTIC_TEX_TRACE_06,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_thunder":
			return {
				"color": Color(0.66, 0.86, 1.0, 1.0),
				"accent": Color(1.0, 1.0, 1.0, 1.0),
				"style": "thunder",
				"waves": 2,
				"wave_gap": 0.13,
				"style_idx": 2,
				"field_sec": 2.5,
				"cast_tex": TACTIC_TEX_FLARE_01,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_ELECTRIC_RING,
				"field_h": 6,
				"field_v": 5,
				"field_loop": false,
				"burst_tex": TACTIC_TEX_SPARK_05,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_trap":
			return {
				"color": Color(0.76, 0.62, 0.34, 1.0),
				"accent": Color(0.96, 0.86, 0.62, 1.0),
				"style": "earth",
				"waves": 2,
				"wave_gap": 0.18,
				"style_idx": 2,
				"field_sec": 3.8,
				"cast_tex": TACTIC_TEX_SYMBOL_01,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_DIRT_02,
				"field_h": 1,
				"field_v": 1,
				"field_loop": false,
				"burst_tex": TACTIC_TEX_SCRATCH_01,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_skyfire":
			return {
				"color": Color(1.0, 0.34, 0.12, 1.0),
				"accent": Color(1.0, 0.86, 0.44, 1.0),
				"style": "fire",
				"waves": 3,
				"wave_gap": 0.16,
				"style_idx": 3,
				"field_sec": 4.4,
				"cast_tex": TACTIC_TEX_MAGIC_02,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_FIRE_POINT,
				"field_h": 6,
				"field_v": 5,
				"field_loop": false,
				"burst_tex": TACTIC_TEX_BIG_HIT,
				"burst_h": 6,
				"burst_v": 5,
				"burst_loop": false
			}
		"strat_dragon_bind":
			return {
				"color": Color(0.32, 0.92, 0.72, 1.0),
				"accent": Color(0.98, 0.94, 0.6, 1.0),
				"style": "control",
				"waves": 3,
				"wave_gap": 0.14,
				"style_idx": 3,
				"field_sec": 4.2,
				"cast_tex": TACTIC_TEX_SYMBOL_02,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_VORTEX,
				"field_h": 6,
				"field_v": 5,
				"field_loop": true,
				"burst_tex": TACTIC_TEX_TWIRL_03,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		"strat_thunder_lock":
			return {
				"color": Color(0.74, 0.92, 1.0, 1.0),
				"accent": Color(1.0, 1.0, 1.0, 1.0),
				"style": "thunder",
				"waves": 3,
				"wave_gap": 0.12,
				"style_idx": 3,
				"field_sec": 4.0,
				"cast_tex": TACTIC_TEX_SPARK_06,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_LIGHTSTREAKS,
				"field_h": 6,
				"field_v": 5,
				"field_loop": true,
				"burst_tex": TACTIC_TEX_FLARE_01,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}
		_:
			return {
				"color": Color(0.88, 0.84, 0.72, 1.0),
				"accent": Color(1.0, 0.98, 0.9, 1.0),
				"style": "support",
				"waves": 1,
				"wave_gap": 0.15,
				"style_idx": 1,
				"field_sec": 2.2,
				"cast_tex": TACTIC_TEX_STAR_03,
				"cast_h": 1,
				"cast_v": 1,
				"cast_loop": false,
				"field_tex": TACTIC_TEX_WAVY_BLUE,
				"field_h": 6,
				"field_v": 5,
				"field_loop": true,
				"burst_tex": TACTIC_TEX_FLARE_01,
				"burst_h": 1,
				"burst_v": 1,
				"burst_loop": false
			}

func _spawn_tactic_cast_vfx(caster, tactic_id: String, duration_sec: float = 0.34) -> void:
	if not tactic_vfx_enabled:
		return
	if caster == null or not is_instance_valid(caster):
		return
	var profile: Dictionary = _tactic_vfx_profile(tactic_id)
	var tint: Color = profile.get("color", Color(0.9, 0.82, 0.62, 1.0))
	var style_idx: int = clampi(int(profile.get("style_idx", 1)), 1, 3)
	var style_id: String = String(profile.get("style", "support")).strip_edges().to_lower()
	var cast_vfx: Node = null
	if style_id != "fire":
		cast_vfx = TACTIC_CAST_VFX_SCENE.instantiate()
		var root: Node3D = _ensure_tactic_vfx_root()
		root.add_child(cast_vfx)
		if cast_vfx is Node3D:
			var cast_node: Node3D = cast_vfx as Node3D
			cast_node.global_position = caster.global_position + Vector3(0.0, 0.1, 0.0)
		if cast_vfx.has_method("play"):
			cast_vfx.call("play", style_idx, false, maxf(0.14, duration_sec), tint)
	else:
		var fire_cast_count: int = 1
		for i in range(fire_cast_count):
			var p: Vector3 = caster.global_position + _random_flat_point(randf_range(0.2, 0.72))
			var fire_primary: Color = tint.lerp(Color(1.0, 0.94, 0.72, 1.0), randf_range(0.24, 0.58))
			var fire_accent: Color = fire_primary.lerp(Color(1.0, 0.26, 0.08, 1.0), randf_range(0.28, 0.44))
			_spawn_fire_cluster_vfx(
				p,
				randf_range(2.0, 3.2) * maxf(0.5, tactic_vfx_intensity_mul),
				maxf(0.24, duration_sec) * randf_range(1.08, 1.62),
				fire_primary,
				fire_accent,
				randf_range(0.62, 1.28)
			)
	var cast_tex: Texture2D = profile.get("cast_tex", null)
	if cast_tex != null and style_id != "fire":
		var cast_h: int = int(profile.get("cast_h", 1))
		var cast_v: int = int(profile.get("cast_v", 1))
		var cast_loop: bool = bool(profile.get("cast_loop", false))
		var scale_mul: float = (0.78 + float(style_idx) * 0.12) * maxf(0.5, tactic_vfx_intensity_mul)
		_spawn_tactic_sprite_vfx(
			caster.global_position,
			cast_tex,
			tint,
			maxf(0.14, duration_sec),
			cast_h,
			cast_v,
			cast_loop,
			0.08,
			0.75,
			1.4,
			scale_mul * 0.65,
			scale_mul * 1.15
		)
	if cast_vfx != null:
		_register_temp_tactic_vfx(cast_vfx, duration_sec + 0.22)

func _spawn_tactic_burst_vfx(tactic_id: String, center: Vector3, forward_dir: Vector3, scale_mul: float, tint: Color, style_idx: int, duration_sec: float = 0.36) -> void:
	if not tactic_vfx_enabled:
		return
	var profile: Dictionary = _tactic_vfx_profile(tactic_id)
	var style_id: String = String(profile.get("style", "support")).strip_edges().to_lower()
	var burst_vfx: Node = null
	if style_id != "fire":
		burst_vfx = TACTIC_SUCCESS_VFX_SCENE.instantiate()
		var root: Node3D = _ensure_tactic_vfx_root()
		root.add_child(burst_vfx)
	var face: Vector3 = Vector3(forward_dir.x, 0.0, forward_dir.z)
	if face.length_squared() <= 0.0001:
		face = Vector3.FORWARD
	else:
		face = face.normalized()
	var world_center: Vector3 = center + Vector3(0.03, 0.06, 0.03)
	if burst_vfx != null and burst_vfx.has_method("play"):
		burst_vfx.call("play", clampi(style_idx, 1, 3), world_center, face, maxf(0.35, scale_mul), tint, maxf(0.12, duration_sec))
	if style_id == "fire":
		var splash_count: int = 1
		for i in range(splash_count):
			var p: Vector3 = world_center + _random_flat_point(randf_range(0.2, 0.86) * maxf(0.68, scale_mul))
			var fire_primary: Color = tint.lerp(Color(1.0, 0.94, 0.74, 1.0), randf_range(0.28, 0.62))
			var fire_accent: Color = fire_primary.lerp(Color(1.0, 0.24, 0.08, 1.0), randf_range(0.3, 0.5))
			_spawn_fire_cluster_vfx(
				p,
				randf_range(2.2, 4.2) * maxf(0.5, scale_mul),
				maxf(0.26, duration_sec) * randf_range(1.18, 1.96),
				fire_primary,
				fire_accent,
				randf_range(0.72, 1.62)
			)
	var burst_tex: Texture2D = profile.get("burst_tex", null)
	if burst_tex != null and style_id != "fire":
		var burst_h: int = int(profile.get("burst_h", 1))
		var burst_v: int = int(profile.get("burst_v", 1))
		var burst_loop: bool = bool(profile.get("burst_loop", false))
		var burst_scale: float = maxf(0.35, scale_mul) * maxf(0.5, tactic_vfx_intensity_mul)
		_spawn_tactic_sprite_vfx(
			world_center,
			burst_tex,
			tint,
			maxf(0.12, duration_sec),
			burst_h,
			burst_v,
			burst_loop,
			0.14,
			0.82,
			2.1,
			burst_scale * 0.55,
			burst_scale * 1.35
		)
	if burst_vfx != null:
		_register_temp_tactic_vfx(burst_vfx, duration_sec + 0.2)

func _spawn_tactic_field_vfx(tactic_id: String, center: Vector3, radius: float, duration_sec: float, primary: Color, accent: Color, style: String) -> void:
	if not tactic_vfx_enabled:
		return
	var safe_radius: float = maxf(0.8, radius)
	var style_id: String = style.strip_edges().to_lower()
	var root_node := Node3D.new()
	root_node.name = "TacticFieldVfx"
	root_node.top_level = true
	var parent_root: Node3D = _ensure_tactic_vfx_root()
	parent_root.add_child(root_node)
	root_node.global_position = center + Vector3(0.0, 0.05, 0.0)
	var profile: Dictionary = _tactic_vfx_profile(tactic_id)
	var field_tex: Texture2D = profile.get("field_tex", null)
	if field_tex != null and style_id != "fire":
		var field_h: int = int(profile.get("field_h", 1))
		var field_v: int = int(profile.get("field_v", 1))
		var field_loop: bool = bool(profile.get("field_loop", false))
		var field_scale: float = maxf(0.65, safe_radius * 0.55) * maxf(0.5, tactic_vfx_intensity_mul)
		_spawn_tactic_sprite_vfx(
			center,
			field_tex,
			primary.lerp(accent, 0.35),
			maxf(0.2, duration_sec),
			field_h,
			field_v,
			field_loop,
			0.04,
			0.55,
			0.9,
			field_scale * 0.9,
			field_scale * 1.05
		)
	var ring: MeshInstance3D = null
	var disc: MeshInstance3D = null
	var ring_mat: StandardMaterial3D = null
	var disc_mat: StandardMaterial3D = null
	if style_id != "fire":
		ring = MeshInstance3D.new()
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var ring_mesh := CylinderMesh.new()
		ring_mesh.top_radius = 1.0
		ring_mesh.bottom_radius = 1.08
		ring_mesh.height = 0.03
		ring_mesh.radial_segments = 28
		ring.mesh = ring_mesh
		ring_mat = _make_tactic_vfx_material(primary, 0.78, 2.2)
		ring.material_override = ring_mat
		root_node.add_child(ring)
		disc = MeshInstance3D.new()
		disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var disc_mesh := CylinderMesh.new()
		disc_mesh.top_radius = 0.95
		disc_mesh.bottom_radius = 0.95
		disc_mesh.height = 0.012
		disc_mesh.radial_segments = 24
		disc.mesh = disc_mesh
		disc_mat = _make_tactic_vfx_material(primary.lerp(accent, 0.26), 0.34, 1.55)
		disc.material_override = disc_mat
		root_node.add_child(disc)
	var mark_count: int = 7
	if style_id == "support":
		mark_count = 6
	elif style_id == "fire":
		mark_count = 0
	elif style_id == "thunder":
		mark_count = 9
	elif style_id == "earth":
		mark_count = 5
	var marks: Array[MeshInstance3D] = []
	var mark_mats: Array[StandardMaterial3D] = []
	var mark_mesh := BoxMesh.new()
	mark_mesh.size = Vector3(0.16, 0.02, 0.65)
	for i in range(mark_count):
		var mark := MeshInstance3D.new()
		mark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mark.mesh = mark_mesh
		var m: StandardMaterial3D = _make_tactic_vfx_material(accent, 0.72, 2.0)
		mark.material_override = m
		root_node.add_child(mark)
		marks.append(mark)
		mark_mats.append(m)
	var ornaments: Array[MeshInstance3D] = []
	var ornament_mats: Array[StandardMaterial3D] = []
	var fire_particle_emitters: Array[GPUParticles3D] = []
	var fire_particle_shader_mats: Array[ShaderMaterial] = []
	if style_id == "thunder" or style_id == "wind":
		var orn_count: int = 4 if style_id != "thunder" else 6
		for i in range(orn_count):
			var ornament := MeshInstance3D.new()
			ornament.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			var orn_mesh := BoxMesh.new()
			if style_id == "thunder":
				orn_mesh.size = Vector3(0.1, 0.65, 0.1)
			elif style_id == "fire":
				orn_mesh.size = Vector3(0.16, 0.36, 0.12)
			else:
				orn_mesh.size = Vector3(0.1, 0.04, 0.58)
			ornament.mesh = orn_mesh
			var om: StandardMaterial3D = _make_tactic_vfx_material(accent, 0.68, 2.25)
			ornament.material_override = om
			root_node.add_child(ornament)
			ornaments.append(ornament)
			ornament_mats.append(om)
	if style_id == "fire":
		var ignition_cluster_count: int = clampi(int(round(1.0 + safe_radius * 0.12)), 1, 2)
		for i in range(ignition_cluster_count):
			var ignition_pos: Vector3 = center + _random_flat_point(safe_radius * randf_range(0.16, 0.58))
			var ignition_primary: Color = primary.lerp(accent, randf_range(0.2, 0.52))
			var ignition_accent: Color = ignition_primary.lerp(Color(1.0, 0.24, 0.08, 1.0), randf_range(0.26, 0.44))
			_spawn_fire_cluster_vfx(
				ignition_pos,
				randf_range(2.4, 4.2) * maxf(0.5, tactic_vfx_intensity_mul),
				maxf(0.4, duration_sec) * randf_range(0.32, 0.64),
				ignition_primary,
				ignition_accent,
				randf_range(0.72, 1.58)
			)
		var fire_particles: Dictionary = _spawn_fire_particles(root_node, safe_radius * 2.6, primary, accent)
		fire_particle_emitters = fire_particles.get("emitters", [])
		fire_particle_shader_mats = fire_particles.get("shader_mats", [])
	tactic_field_vfx_items.append({
		"root": root_node,
		"ring": ring,
		"disc": disc,
		"ring_mat": ring_mat,
		"disc_mat": disc_mat,
		"marks": marks,
		"mark_mats": mark_mats,
		"ornaments": ornaments,
		"ornament_mats": ornament_mats,
		"fire_emitters": fire_particle_emitters,
		"fire_emitter_shader_mats": fire_particle_shader_mats,
		"age": 0.0,
		"duration": maxf(0.2, duration_sec),
		"radius": safe_radius,
		"style": style_id,
		"primary": primary,
		"accent": accent,
		"spin": randf_range(1.1, 2.4),
		"pulse": randf_range(4.2, 7.6),
		"phase": randf() * TAU
	})

func _spawn_tactic_link_vfx(start_pos: Vector3, end_pos: Vector3, tint: Color, duration_sec: float = 0.34, width: float = 0.12, style_id: String = "", preserve_vertical: bool = false) -> void:
	if not tactic_vfx_enabled:
		return
	var dir: Vector3 = end_pos - start_pos
	if not preserve_vertical:
		dir.y = 0.0
	var dist: float = dir.length()
	if dist <= 0.08:
		return
	var style_norm: String = style_id.strip_edges().to_lower()
	var dir_n: Vector3 = dir.normalized()
	var up_axis: Vector3 = Vector3.UP
	if absf(dir_n.dot(up_axis)) >= 0.98:
		up_axis = Vector3.FORWARD
	var root_node := Node3D.new()
	root_node.name = "TacticLinkVfx"
	root_node.top_level = true
	root_node.global_position = (start_pos + end_pos) * 0.5 + Vector3(0.0, 0.18, 0.0)
	root_node.global_basis = Basis.looking_at(dir_n, up_axis, true)
	_ensure_tactic_vfx_root().add_child(root_node)
	var beam := MeshInstance3D.new()
	beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(1.0, 1.0, 1.0)
	beam.mesh = beam_mesh
	var safe_width: float = maxf(0.04, width)
	var beam_mat: StandardMaterial3D = null
	var beam_shader_mat: ShaderMaterial = null
	var shader_seed: float = randf_range(1.0, 9.0)
	if style_norm == "thunder":
		safe_width = maxf(safe_width, 0.075)
		beam_shader_mat = ShaderMaterial.new()
		beam_shader_mat.shader = TACTIC_THUNDER_BOLT_SHADER
		var core_color: Color = tint.lerp(Color(0.96, 0.98, 1.0, 1.0), 0.24)
		var edge_color: Color = tint.lerp(Color(0.22, 0.18, 1.0, 1.0), 0.58)
		beam_shader_mat.set_shader_parameter("u_core_color", core_color)
		beam_shader_mat.set_shader_parameter("u_edge_color", edge_color)
		beam_shader_mat.set_shader_parameter("u_alpha_mul", 1.0)
		beam_shader_mat.set_shader_parameter("u_energy_mul", 4.2)
		beam_shader_mat.set_shader_parameter("u_noise_mul", 1.0)
		beam_shader_mat.set_shader_parameter("u_seed", shader_seed)
		beam.material_override = beam_shader_mat
	else:
		beam_mat = _make_tactic_vfx_material(tint, 0.86, 2.45)
		beam.material_override = beam_mat
	beam.scale = Vector3(safe_width, safe_width, dist)
	root_node.add_child(beam)
	tactic_link_vfx_items.append({
		"root": root_node,
		"beam": beam,
		"mat": beam_mat,
		"shader_mat": beam_shader_mat,
		"age": 0.0,
		"duration": maxf(0.08, duration_sec),
		"color": tint,
		"width": safe_width,
		"length": dist,
		"phase": randf() * TAU,
		"style": style_norm,
		"seed": shader_seed
	})

func _emit_tactic_wave_once(caster, tactic_id: String, center: Vector3, radius: float, wave_index: int, wave_count: int) -> void:
	if not tactic_vfx_enabled:
		return
	var profile: Dictionary = _tactic_vfx_profile(tactic_id)
	var color: Color = profile.get("color", Color(0.9, 0.82, 0.66, 1.0))
	var accent: Color = profile.get("accent", Color(1.0, 0.97, 0.9, 1.0))
	var style_idx: int = clampi(int(profile.get("style_idx", 1)), 1, 3)
	var style_id: String = String(profile.get("style", "support")).strip_edges().to_lower()
	var safe_radius: float = maxf(1.2, radius)
	var face: Vector3 = Vector3.FORWARD
	if caster != null and is_instance_valid(caster):
		var to_center: Vector3 = center - caster.global_position
		to_center.y = 0.0
		if to_center.length_squared() > 0.0001:
			face = to_center.normalized()
	var wave_t: float = float(wave_index) / maxf(1.0, float(maxi(1, wave_count - 1)))
	var main_scale: float = maxf(0.7, safe_radius * (0.14 + tactic_vfx_intensity_mul * 0.03)) * (1.0 + wave_t * 0.28)
	_spawn_tactic_burst_vfx(tactic_id, center, face, main_scale, color, style_idx, 0.34 + wave_t * 0.08)
	if style_id == "fire":
		return
	var satellite_count: int = clampi(2 + int(round(safe_radius * 0.45)), 2, 8)
	for i in range(satellite_count):
		var p: Vector3 = center + _random_flat_point(safe_radius * randf_range(0.12, 0.4))
		var side_scale: float = main_scale * randf_range(0.42, 0.74)
		var tint: Color = color.lerp(accent, randf_range(0.16, 0.56))
		_spawn_tactic_burst_vfx(tactic_id, p, face, side_scale, tint, style_idx, randf_range(0.22, 0.36))

func _schedule_tactic_wave(caster, tactic_id: String, center: Vector3, radius: float, delay_sec: float, wave_index: int, wave_count: int) -> void:
	if delay_sec <= 0.001:
		_emit_tactic_wave_once(caster, tactic_id, center, radius, wave_index, wave_count)
		return
	var timer: SceneTreeTimer = get_tree().create_timer(delay_sec)
	timer.timeout.connect(func() -> void:
		if not is_inside_tree():
			return
		_emit_tactic_wave_once(caster, tactic_id, center, radius, wave_index, wave_count)
	)

func _play_tactic_area_vfx(caster, tactic_id: String, center: Vector3, radius: float, linger_sec: float = 0.0, wave_count: int = -1, wave_gap: float = -1.0) -> void:
	if not tactic_vfx_enabled:
		return
	var profile: Dictionary = _tactic_vfx_profile(tactic_id)
	var style_id: String = String(profile.get("style", "support"))
	var color: Color = profile.get("color", Color(0.9, 0.82, 0.66, 1.0))
	var accent: Color = profile.get("accent", Color(1.0, 0.97, 0.9, 1.0))
	var safe_radius: float = maxf(1.2, radius * maxf(0.4, tactic_vfx_radius_mul))
	var waves: int = wave_count if wave_count > 0 else int(profile.get("waves", 1))
	if style_id.strip_edges().to_lower() == "fire":
		waves = mini(waves, 2)
	waves = clampi(waves, 1, 6)
	var gap: float = wave_gap if wave_gap >= 0.0 else float(profile.get("wave_gap", 0.16))
	gap = clampf(gap, 0.04, 0.6)
	for w in range(waves):
		_schedule_tactic_wave(caster, tactic_id, center, safe_radius, float(w) * gap, w, waves)
	var field_sec: float = maxf(linger_sec, float(profile.get("field_sec", 0.0)))
	if field_sec > 0.08:
		_spawn_tactic_field_vfx(tactic_id, center, safe_radius, field_sec, color, accent, style_id)

func _play_tactic_link_group_vfx(origin: Vector3, targets: Array, tactic_id: String, duration_sec: float = 0.34) -> void:
	if not tactic_vfx_enabled:
		return
	var profile: Dictionary = _tactic_vfx_profile(tactic_id)
	var tint: Color = profile.get("accent", profile.get("color", Color(0.9, 0.9, 1.0, 1.0)))
	var style_id: String = String(profile.get("style", "support"))
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		var dst: Vector3 = enemy.global_position + Vector3(0.0, 0.24, 0.0)
		_spawn_tactic_link_vfx(origin + Vector3(0.0, 0.26, 0.0), dst, tint, duration_sec, 0.11 + randf() * 0.07, style_id, false)

func _play_tactic_thunder_target_vfx(caster, tactic_id: String, targets: Array) -> void:
	if not tactic_vfx_enabled:
		return
	var profile: Dictionary = _tactic_vfx_profile(tactic_id)
	var color: Color = profile.get("color", Color(0.76, 0.9, 1.0, 1.0))
	var accent: Color = profile.get("accent", Color(1.0, 1.0, 1.0, 1.0))
	var style_idx: int = clampi(int(profile.get("style_idx", 2)), 1, 3)
	for enemy in targets:
		if enemy == null or not is_instance_valid(enemy) or enemy.dead:
			continue
		var center: Vector3 = enemy.global_position + Vector3(0.0, 0.06, 0.0)
		var face: Vector3 = Vector3.FORWARD
		if caster != null and is_instance_valid(caster):
			var dir: Vector3 = center - caster.global_position
			dir.y = 0.0
			if dir.length_squared() > 0.0001:
				face = dir.normalized()
		_spawn_tactic_burst_vfx(tactic_id, center, face, randf_range(0.62, 0.9), color.lerp(accent, randf_range(0.25, 0.62)), style_idx, randf_range(0.22, 0.34))
		var sky_point: Vector3 = center + Vector3(randf_range(-0.7, 0.7), 1.8 + randf() * 0.9, randf_range(-0.7, 0.7))
		_spawn_tactic_link_vfx(sky_point, center + Vector3(0.0, 0.08, 0.0), accent, 0.26, 0.11, "thunder", true)

func _update_tactic_vfx(delta: float) -> void:
	if delta <= 0.0:
		return
	for i in range(tactic_temp_vfx_nodes.size() - 1, -1, -1):
		var item: Dictionary = tactic_temp_vfx_nodes[i]
		var node: Node = item.get("node", null)
		if node == null or not is_instance_valid(node):
			tactic_temp_vfx_nodes.remove_at(i)
			continue
		var left: float = float(item.get("time_left", 0.0)) - delta
		if left <= 0.0:
			node.queue_free()
			tactic_temp_vfx_nodes.remove_at(i)
			continue
		item["time_left"] = left
		tactic_temp_vfx_nodes[i] = item
	for i in range(tactic_sprite_vfx_items.size() - 1, -1, -1):
		var item: Dictionary = tactic_sprite_vfx_items[i]
		var root_node: Node3D = item.get("root", null)
		var mat: StandardMaterial3D = item.get("mat", null)
		if root_node == null or not is_instance_valid(root_node):
			tactic_sprite_vfx_items.remove_at(i)
			continue
		var age: float = float(item.get("age", 0.0)) + delta
		var duration_sec: float = maxf(0.1, float(item.get("duration", 0.4)))
		var p: float = clampf(age / duration_sec, 0.0, 1.0)
		if p >= 1.0:
			root_node.queue_free()
			tactic_sprite_vfx_items.remove_at(i)
			continue
		var fade: float = pow(maxf(0.0, 1.0 - p), 1.1)
		var alpha_mul: float = float(item.get("alpha_mul", 0.75))
		var tint: Color = item.get("color", Color(1.0, 1.0, 1.0, 1.0))
		if mat != null:
			mat.albedo_color = Color(tint.r, tint.g, tint.b, clampf(fade * alpha_mul, 0.0, 1.0))
			mat.emission = Color(tint.r, tint.g, tint.b, 1.0)
			mat.emission_energy_multiplier = 1.1 + fade * 1.6
		var spin: float = float(item.get("spin", 0.0))
		var scale_from: float = float(item.get("scale_from", 1.0))
		var scale_to: float = float(item.get("scale_to", scale_from))
		root_node.rotation.y = age * spin
		root_node.scale = Vector3.ONE * lerpf(scale_from, scale_to, p)
		item["age"] = age
		tactic_sprite_vfx_items[i] = item
	for i in range(tactic_link_vfx_items.size() - 1, -1, -1):
		var item: Dictionary = tactic_link_vfx_items[i]
		var root_node: Node3D = item.get("root", null)
		var beam: MeshInstance3D = item.get("beam", null)
		var mat: StandardMaterial3D = item.get("mat", null)
		var shader_mat: ShaderMaterial = item.get("shader_mat", null)
		if root_node == null or not is_instance_valid(root_node) or beam == null or not is_instance_valid(beam):
			if root_node != null and is_instance_valid(root_node):
				root_node.queue_free()
			tactic_link_vfx_items.remove_at(i)
			continue
		var age: float = float(item.get("age", 0.0)) + delta
		var duration_sec: float = maxf(0.06, float(item.get("duration", 0.22)))
		var p: float = clampf(age / duration_sec, 0.0, 1.0)
		if p >= 1.0:
			root_node.queue_free()
			tactic_link_vfx_items.remove_at(i)
			continue
		var phase: float = float(item.get("phase", 0.0))
		var width: float = maxf(0.04, float(item.get("width", 0.1)))
		var length: float = maxf(0.08, float(item.get("length", 1.0)))
		var flicker: float = 0.82 + sin(age * 22.0 + phase) * 0.18
		var alpha: float = maxf(0.0, 1.0 - p) * flicker
		var style_id: String = String(item.get("style", ""))
		var width_mul: float = 1.35 if style_id == "thunder" else 1.0
		beam.scale = Vector3(width * width_mul * (1.0 + sin(age * 13.0 + phase) * 0.12), width * width_mul * (1.0 + sin(age * 17.0 + phase * 1.3) * 0.12), length)
		var col: Color = item.get("color", Color(0.9, 0.9, 1.0, 1.0))
		if shader_mat != null and style_id == "thunder":
			var core_col: Color = col.lerp(Color(0.98, 0.99, 1.0, 1.0), 0.24 + sin(age * 11.0 + phase) * 0.06)
			var edge_col: Color = col.lerp(Color(0.22, 0.18, 1.0, 1.0), 0.6)
			shader_mat.set_shader_parameter("u_core_color", core_col)
			shader_mat.set_shader_parameter("u_edge_color", edge_col)
			shader_mat.set_shader_parameter("u_alpha_mul", alpha * 1.25)
			shader_mat.set_shader_parameter("u_energy_mul", 3.8 + flicker * 2.6)
			shader_mat.set_shader_parameter("u_noise_mul", 0.85 + sin(age * 9.0 + phase * 0.7) * 0.25)
			shader_mat.set_shader_parameter("u_seed", float(item.get("seed", 1.0)))
		elif mat != null:
			mat.albedo_color = Color(col.r, col.g, col.b, alpha)
			mat.emission = col.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.24)
			mat.emission_energy_multiplier = 1.7 + flicker * 1.2
		item["age"] = age
		tactic_link_vfx_items[i] = item
	for i in range(tactic_field_vfx_items.size() - 1, -1, -1):
		var item: Dictionary = tactic_field_vfx_items[i]
		var root_node: Node3D = item.get("root", null)
		var ring: MeshInstance3D = item.get("ring", null)
		var disc: MeshInstance3D = item.get("disc", null)
		if root_node == null or not is_instance_valid(root_node):
			tactic_field_vfx_items.remove_at(i)
			continue
		var age: float = float(item.get("age", 0.0)) + delta
		var duration_sec: float = maxf(0.1, float(item.get("duration", 1.0)))
		var p: float = clampf(age / duration_sec, 0.0, 1.0)
		if p >= 1.0:
			root_node.queue_free()
			tactic_field_vfx_items.remove_at(i)
			continue
		var radius: float = maxf(0.8, float(item.get("radius", 2.0)))
		var style_id: String = String(item.get("style", "support"))
		var spin: float = float(item.get("spin", 1.6))
		var pulse: float = float(item.get("pulse", 5.2))
		var phase: float = float(item.get("phase", 0.0))
		var primary: Color = item.get("primary", Color(0.9, 0.8, 0.6, 1.0))
		var accent: Color = item.get("accent", Color(1.0, 0.96, 0.88, 1.0))
		var fade: float = pow(maxf(0.0, 1.0 - p), 1.12)
		var pulse_a: float = 1.0 + sin(age * pulse + phase) * 0.12
		var pulse_b: float = 1.0 + sin(age * (pulse * 0.58) + phase * 1.2) * 0.08
		if ring != null and is_instance_valid(ring):
			var ring_scale: float = radius * (0.74 + p * 0.42) * pulse_a
			ring.scale = Vector3(ring_scale, 1.0, ring_scale)
			ring.rotation.y = age * spin
		if disc != null and is_instance_valid(disc):
			var disc_scale: float = radius * (0.58 + p * 0.22) * pulse_b
			disc.scale = Vector3(disc_scale, 1.0, disc_scale)
			disc.rotation.y = -age * spin * 0.55
		var ring_mat: StandardMaterial3D = item.get("ring_mat", null)
		var disc_mat: StandardMaterial3D = item.get("disc_mat", null)
		if ring_mat != null:
			var ring_alpha: float = fade * (0.7 + sin(age * 6.5 + phase) * 0.1)
			if style_id == "fire":
				ring_alpha *= 0.34
			ring_mat.albedo_color = Color(primary.r, primary.g, primary.b, ring_alpha)
			ring_mat.emission = primary.lerp(accent, 0.22)
			ring_mat.emission_energy_multiplier = (0.78 + fade * 0.82) if style_id == "fire" else (1.5 + fade * 1.4)
		if disc_mat != null:
			var disc_alpha: float = fade * (0.32 + sin(age * 4.1 + phase * 1.4) * 0.06)
			if style_id == "fire":
				disc_alpha *= 0.22
			disc_mat.albedo_color = Color(primary.r, primary.g, primary.b, disc_alpha)
			disc_mat.emission = primary.lerp(accent, 0.4)
			disc_mat.emission_energy_multiplier = (0.65 + fade * 0.55) if style_id == "fire" else (1.2 + fade * 0.8)
		var marks: Array = item.get("marks", [])
		var mark_mats: Array = item.get("mark_mats", [])
		var mark_count: int = marks.size()
		for m_idx in range(mark_count):
			var mark: MeshInstance3D = marks[m_idx]
			if mark == null or not is_instance_valid(mark):
				continue
			var t: float = float(m_idx) / maxf(1.0, float(mark_count))
			var ang: float = t * TAU + age * spin * (0.7 + t * 0.28) + phase
			var orbit: float = radius * (0.46 + 0.18 * (0.5 + sin(age * 2.4 + t * TAU * 1.2) * 0.5))
			mark.position = Vector3(cos(ang) * orbit, 0.03 + sin(age * 6.0 + t * TAU) * 0.04, sin(ang) * orbit)
			mark.rotation.y = ang + PI * 0.5
			var stretch: float = 1.0 + sin(age * 8.0 + t * TAU * 1.8) * 0.16
			mark.scale = Vector3(stretch, 1.0, 0.82 + sin(age * 5.0 + t * TAU) * 0.18)
			if m_idx < mark_mats.size() and mark_mats[m_idx] != null:
				var mm: StandardMaterial3D = mark_mats[m_idx]
				var mark_alpha: float = fade * (0.5 + sin(age * 9.4 + t * TAU * 2.2) * 0.18)
				var mark_col: Color = accent.lerp(primary, 0.2 + t * 0.3)
				mm.albedo_color = Color(mark_col.r, mark_col.g, mark_col.b, mark_alpha)
				mm.emission = mark_col
				mm.emission_energy_multiplier = 1.8 + fade * 1.1
		var ornaments: Array = item.get("ornaments", [])
		var ornament_mats: Array = item.get("ornament_mats", [])
		var orn_count: int = ornaments.size()
		for o_idx in range(orn_count):
			var ornament: MeshInstance3D = ornaments[o_idx]
			if ornament == null or not is_instance_valid(ornament):
				continue
			var o_t: float = float(o_idx) / maxf(1.0, float(orn_count))
			var o_ang: float = o_t * TAU + age * spin * 0.9 + phase * 0.6
			var o_orbit: float = radius * (0.25 + 0.14 * (0.5 + sin(age * 3.2 + o_t * TAU) * 0.5))
			if style_id == "thunder":
				ornament.position = Vector3(cos(o_ang) * o_orbit, 0.38 + sin(age * 14.0 + o_t * TAU) * 0.16, sin(o_ang) * o_orbit)
				ornament.scale = Vector3(1.0, 0.8 + sin(age * 18.0 + o_t * TAU) * 0.25, 1.0)
			elif style_id == "fire":
				ornament.position = Vector3(cos(o_ang) * o_orbit, 0.14 + sin(age * 11.0 + o_t * TAU) * 0.08, sin(o_ang) * o_orbit)
				ornament.rotation.y = o_ang
				ornament.scale = Vector3(0.88 + sin(age * 12.0 + o_t * TAU) * 0.24, 0.9 + sin(age * 13.2 + o_t * TAU) * 0.22, 0.9)
			else:
				ornament.position = Vector3(cos(o_ang) * o_orbit, 0.08, sin(o_ang) * o_orbit)
				ornament.rotation.y = o_ang + PI * 0.5
				ornament.scale = Vector3(1.0 + sin(age * 7.2 + o_t * TAU) * 0.22, 1.0, 0.82 + sin(age * 5.5 + o_t * TAU) * 0.18)
			if o_idx < ornament_mats.size() and ornament_mats[o_idx] != null:
				var om: StandardMaterial3D = ornament_mats[o_idx]
				var orn_alpha: float = fade * (0.58 + sin(age * 10.5 + o_t * TAU * 1.6) * 0.24)
				var orn_col: Color = accent.lerp(primary, 0.2 + o_t * 0.4)
				om.albedo_color = Color(orn_col.r, orn_col.g, orn_col.b, orn_alpha)
				om.emission = orn_col
				om.emission_energy_multiplier = 1.85 + fade * 1.45
		if style_id == "fire":
			var fire_emitters: Array = item.get("fire_emitters", [])
			for emitter_any in fire_emitters:
				var emitter: GPUParticles3D = emitter_any as GPUParticles3D
				if emitter == null or not is_instance_valid(emitter):
					continue
				emitter.speed_scale = 0.84 + fade * 0.86
				emitter.set("amount_ratio", clampf(fade * 1.25, 0.0, 1.0))
				if p > 0.92:
					emitter.emitting = false
			var fire_particle_shader_mats: Array = item.get("fire_emitter_shader_mats", [])
			for shader_mat_any in fire_particle_shader_mats:
				var shader_mat: ShaderMaterial = shader_mat_any as ShaderMaterial
				if shader_mat == null:
					continue
				shader_mat.set_shader_parameter("u_time", age * 1.22 + phase * 0.35)
				shader_mat.set_shader_parameter("u_intensity", maxf(0.22, fade * 1.18))
		item["age"] = age
		tactic_field_vfx_items[i] = item

func _make_unit_tag(unit) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	var id: int = unit.get_instance_id()
	if unit_tag_buttons.has(id):
		return
	var tag_anchor: Node3D = unit.get_node_or_null("TagAnchor") as Node3D
	var faction_color: Color = _faction_tag_color(int(unit.team_id))
	if tag_anchor != null and is_instance_valid(tag_anchor):
		tag_anchor.visible = false

	var card := Button.new()
	card.name = "UnitTagCard_%d" % id
	card.text = ""
	card.focus_mode = Control.FOCUS_NONE
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.custom_minimum_size = unit_tag_lod0_size
	card.size = card.custom_minimum_size
	card.pressed.connect(func() -> void:
		_on_unit_tag_pressed(id)
	)
	card.gui_input.connect(func(event: InputEvent) -> void:
		if not (event is InputEventMouseButton):
			return
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_RIGHT:
			return
		if not unit_tag_units.has(id):
			return
		var target_unit = unit_tag_units[id]
		if target_unit == null or not is_instance_valid(target_unit) or target_unit.dead:
			return
		if _can_player_direct_unit(target_unit):
			return
		var viewer_team_id: int = demo_recon_player_team_id
		var lead = _get_selected_command_unit()
		if lead != null and is_instance_valid(lead):
			viewer_team_id = int(lead.team_id)
		if not is_enemy_targetable_for_team(viewer_team_id, target_unit):
			_set_battle_status("目标未暴露，需先侦察。")
			return
		_issue_selected_force_attack_on_unit(target_unit, viewer_team_id)
		get_viewport().set_input_as_handled()
	)
	unit_tag_root.add_child(card)

	var panel_margin := MarginContainer.new()
	panel_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_margin.offset_left = 8.0
	panel_margin.offset_top = 6.0
	panel_margin.offset_right = -10.0
	panel_margin.offset_bottom = -6.0
	panel_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(panel_margin)

	var flag_bg := ColorRect.new()
	flag_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	flag_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flag_bg.offset_right = 74.0
	flag_bg.z_index = -1
	flag_bg.color = Color(1.0, 1.0, 1.0, 1.0)
	if _unit_tag_flag_shader != null:
		var flag_mat := ShaderMaterial.new()
		flag_mat.shader = _unit_tag_flag_shader
		var cloth_col := Color(faction_color.r, faction_color.g, faction_color.b, 0.9)
		var edge_col := cloth_col.darkened(0.22)
		flag_mat.set_shader_parameter("cloth_color", cloth_col)
		flag_mat.set_shader_parameter("edge_color", edge_col)
		flag_mat.set_shader_parameter("notch_depth", 0.18)
		flag_mat.set_shader_parameter("tassel_count", 7.0)
		flag_mat.set_shader_parameter("edge_width", 0.02)
		flag_bg.material = flag_mat
	panel_margin.add_child(flag_bg)

	var dialogue_wrap := Control.new()
	dialogue_wrap.set_anchors_preset(Control.PRESET_TOP_WIDE)
	dialogue_wrap.offset_left = -36.0
	dialogue_wrap.offset_top = -72.0
	dialogue_wrap.offset_right = 56.0
	dialogue_wrap.offset_bottom = -8.0
	dialogue_wrap.custom_minimum_size = Vector2(0.0, 48.0)
	dialogue_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_wrap.visible = false
	dialogue_wrap.z_index = 3
	card.add_child(dialogue_wrap)

	var dialogue_bg := ColorRect.new()
	dialogue_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_bg.color = Color(1.0, 1.0, 1.0, 1.0)
	dialogue_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _unit_tag_dialogue_shader != null:
		var dialogue_mat := ShaderMaterial.new()
		dialogue_mat.shader = _unit_tag_dialogue_shader
		dialogue_mat.set_shader_parameter("base_color", Color(0.97, 0.97, 0.95, 0.95))
		dialogue_mat.set_shader_parameter("edge_color", Color(0.84, 0.84, 0.81, 0.98))
		dialogue_bg.material = dialogue_mat
	dialogue_wrap.add_child(dialogue_bg)

	var dialogue_pad := MarginContainer.new()
	dialogue_pad.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_pad.add_theme_constant_override("margin_left", 12)
	dialogue_pad.add_theme_constant_override("margin_right", 12)
	dialogue_pad.add_theme_constant_override("margin_top", 5)
	dialogue_pad.add_theme_constant_override("margin_bottom", 5)
	dialogue_wrap.add_child(dialogue_pad)

	var dialogue_label := Label.new()
	dialogue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialogue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dialogue_label.clip_text = false
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_unit_tag_dialogue_label(dialogue_label, 13, Color(0.16, 0.11, 0.07, 1.0))
	dialogue_pad.add_child(dialogue_label)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 2)
	layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_margin.add_child(layout)

	var body_row := HBoxContainer.new()
	body_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_row.add_theme_constant_override("separation", 6)
	body_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(body_row)

	var left_col := VBoxContainer.new()
	left_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_col.custom_minimum_size = Vector2(46.0, 0.0)
	left_col.add_theme_constant_override("separation", 2)
	left_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body_row.add_child(left_col)

	var name_label := Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.clip_text = true
	name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_style_unit_tag_label(name_label, 12, Color(0.96, 0.9, 0.74, 1.0))
	left_col.add_child(name_label)

	var portrait_holder := MarginContainer.new()
	portrait_holder.custom_minimum_size = Vector2(43.0, 43.0)
	portrait_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portrait_holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	portrait_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_col.add_child(portrait_holder)

	var portrait_bg := ColorRect.new()
	portrait_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait_bg.color = Color(0.08, 0.06, 0.04, 0.78)
	portrait_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_holder.add_child(portrait_bg)

	var portrait_rect := TextureRect.new()
	portrait_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_holder.add_child(portrait_rect)

	var portrait_frame := Panel.new()
	portrait_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var portrait_frame_style := StyleBoxFlat.new()
	portrait_frame_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	portrait_frame_style.border_color = TAG_FRAME_GOLD
	portrait_frame_style.set_border_width_all(1)
	portrait_frame_style.set_corner_radius_all(1)
	portrait_frame.add_theme_stylebox_override("panel", portrait_frame_style)
	portrait_holder.add_child(portrait_frame)

	var right_pad := MarginContainer.new()
	right_pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_pad.add_theme_constant_override("margin_right", 12)
	right_pad.add_theme_constant_override("margin_top", 2)
	body_row.add_child(right_pad)

	var right_col := VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_col.custom_minimum_size = Vector2(46.0, 0.0)
	right_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_col.add_theme_constant_override("separation", 2)
	right_pad.add_child(right_col)

	var info_row := HBoxContainer.new()
	info_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_row.add_theme_constant_override("separation", 4)
	info_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_col.add_child(info_row)

	var type_label := Label.new()
	type_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	type_label.clip_text = true
	type_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_style_unit_tag_label(type_label, 10, Color(0.93, 0.95, 0.98, 0.94))
	info_row.add_child(type_label)

	var count_label := Label.new()
	count_label.custom_minimum_size = Vector2(34.0, 0.0)
	count_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_label.clip_text = true
	count_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_style_unit_tag_label(count_label, 10, Color(1.0, 1.0, 1.0, 0.96))
	info_row.add_child(count_label)

	var status_row := MarginContainer.new()
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_row.add_theme_constant_override("margin_left", 1)
	status_row.add_theme_constant_override("margin_right", 1)
	status_row.add_theme_constant_override("margin_top", 0)
	status_row.add_theme_constant_override("margin_bottom", 0)
	right_col.add_child(status_row)

	var status_label := Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	status_label.clip_text = true
	status_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_style_unit_tag_label(status_label, 9, Color(0.92, 0.95, 0.82, 0.92))
	status_row.add_child(status_label)

	var morale_bar := _make_status_bar()
	_set_status_bar_colors(morale_bar, Color(0.86, 0.24, 0.18, 0.98), Color(0.22, 0.08, 0.08, 0.92))
	morale_bar.custom_minimum_size = Vector2(0.0, 6.0)
	right_col.add_child(morale_bar)

	var will_bar := _make_status_bar()
	_set_status_bar_colors(will_bar, Color(0.18, 0.8, 0.96, 0.98), Color(0.07, 0.16, 0.22, 0.92))
	will_bar.custom_minimum_size = Vector2(0.0, 6.0)
	right_col.add_child(will_bar)

	var normal_style: StyleBoxFlat = _make_card_stylebox(faction_color, Color(0.92, 0.82, 0.62), 1)
	var hover_style: StyleBoxFlat = _make_card_stylebox(faction_color.lightened(0.12), Color(1.0, 0.92, 0.7), 1)
	var selected_style: StyleBoxFlat = _make_card_stylebox(faction_color.lightened(0.2), Color(1.0, 0.95, 0.8), 2)
	card.add_theme_stylebox_override("normal", normal_style)
	card.add_theme_stylebox_override("hover", hover_style)
	card.add_theme_stylebox_override("pressed", selected_style)
	card.add_theme_stylebox_override("focus", selected_style)
	card.add_theme_stylebox_override("disabled", normal_style)

	unit_tag_buttons[id] = card
	unit_tag_units[id] = unit
	unit_tag_widgets[id] = {
		"card": card,
		"panel_margin": panel_margin,
		"layout": layout,
		"body_row": body_row,
		"dialogue_wrap": dialogue_wrap,
		"dialogue_label": dialogue_label,
		"left_col": left_col,
		"right_col": right_col,
		"name_label": name_label,
		"portrait_rect": portrait_rect,
		"portrait_holder": portrait_holder,
		"info_row": info_row,
		"status_row": status_row,
		"status_label": status_label,
		"type_label": type_label,
		"count_label": count_label,
		"morale_bar": morale_bar,
		"will_bar": will_bar,
		"normal_style": normal_style,
		"hover_style": hover_style,
		"selected_style": selected_style
	}
	_update_unit_tag_data(unit, unit_tag_widgets[id])

func _remove_unit_tag(unit) -> void:
	if unit == null:
		return
	var id: int = unit.get_instance_id()
	var widgets: Dictionary = unit_tag_widgets.get(id, {})
	var card: Control = widgets.get("card")
	if card != null and is_instance_valid(card):
		card.queue_free()
	var tag_anchor: Node3D = unit.get_node_or_null("TagAnchor") as Node3D
	if tag_anchor != null and is_instance_valid(tag_anchor):
		tag_anchor.visible = false
	unit_tag_buttons.erase(id)
	unit_tag_units.erase(id)
	unit_tag_widgets.erase(id)

func _on_unit_tag_pressed(unit_id: int) -> void:
	if not unit_tag_units.has(unit_id):
		return
	var unit = unit_tag_units[unit_id]
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return
	if not _can_player_direct_unit(unit) and not _is_unit_visible_for_player_ui(unit):
		_set_battle_status("目标未暴露，需先侦察。")
		return
	if _can_player_direct_unit(unit):
		_set_selected_unit(unit)
	else:
		_set_inspected_enemy_unit(unit)
		_set_battle_status("Enemy unit selected.")

func _update_unit_tags(refresh_text: bool = false, force_near_positions: bool = false, refresh_positions: bool = true) -> void:
	if not show_unit_tags:
		return
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return
	var near_depth: float = maxf(0.0, unit_tag_near_ops_depth)
	var inv := camera.global_transform.affine_inverse()
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var remove_ids: Array[int] = []
	var cleared_inspected_enemy: bool = false
	for id in unit_tag_buttons.keys():
		var card: Control = unit_tag_buttons.get(id)
		var unit: Node3D = unit_tag_units.get(id)
		var widgets: Dictionary = unit_tag_widgets.get(id, {})
		if card == null or not is_instance_valid(card) or unit == null or not is_instance_valid(unit) or unit.dead or widgets.is_empty():
			remove_ids.append(id)
			continue
		var depth := _get_camera_depth_from_inv(inv, unit.global_position)
		var tier: int = _get_unit_tag_lod_tier(unit, depth)
		var world_pos: Vector3 = _get_unit_tag_world_pos(unit, tier)
		if depth > lod_tag_visible_max_depth or camera.is_position_behind(world_pos):
			card.visible = false
			continue
		if not _is_unit_visible_for_player_ui(unit):
			card.visible = false
			if inspected_unit == unit:
				inspected_unit = null
				cleared_inspected_enemy = true
			continue
		var force_near_ops: bool = depth <= near_depth or selected_units.has(unit) or selected_unit == unit or inspected_unit == unit
		var was_visible: bool = card.visible
		var do_refresh_text: bool = refresh_text
		var force_dialogue_refresh: bool = false
		if unit.has_method("get_commander_dialogue_snapshot"):
			var dialogue_any: Variant = unit.call("get_commander_dialogue_snapshot")
			if dialogue_any is Dictionary:
				force_dialogue_refresh = bool((dialogue_any as Dictionary).get("active", false))
		if do_refresh_text and unit_tag_far_perf_enabled and not force_near_ops:
			var text_stride: int = _resolve_tag_update_stride(depth, true)
			if text_stride > 1 and (unit_tag_text_refresh_cycle % text_stride) != 0:
				do_refresh_text = false
		if force_dialogue_refresh:
			do_refresh_text = true
		if do_refresh_text:
			_update_unit_tag_data(unit, widgets)
		card.visible = true
		var tier_changed: bool = _apply_unit_tag_lod_style(unit, widgets, tier)
		var update_pos: bool = refresh_positions
		if update_pos and unit_tag_far_perf_enabled and not force_near_ops:
			var pos_stride: int = _resolve_tag_update_stride(depth, false)
			if pos_stride > 1 and (unit_tag_position_refresh_cycle % pos_stride) != 0:
				update_pos = false
		if not update_pos and force_near_positions:
			if force_near_ops:
				update_pos = true
		if not update_pos and (not was_visible or tier_changed):
			update_pos = true
		if update_pos:
			var screen_pos: Vector2 = camera.unproject_position(world_pos)
			var card_size: Vector2 = card.size
			if card_size.x <= 0.0 or card_size.y <= 0.0:
				card_size = card.custom_minimum_size
			var pos := Vector2(screen_pos.x - card_size.x * 0.5, screen_pos.y - card_size.y - _get_unit_tag_screen_gap(tier))
			pos.x = clampf(pos.x, 4.0, maxf(4.0, viewport_rect.size.x - card_size.x - 4.0))
			pos.y = clampf(pos.y, 4.0, maxf(4.0, viewport_rect.size.y - card_size.y - 4.0))
			card.position = pos.round()
		_apply_card_selection_style(card as Button, widgets, selected_units.has(unit) or selected_unit == unit or inspected_unit == unit)
	for id in remove_ids:
		var stale: Control = unit_tag_buttons.get(id)
		if stale != null and is_instance_valid(stale):
			stale.queue_free()
		unit_tag_buttons.erase(id)
		unit_tag_units.erase(id)
		unit_tag_widgets.erase(id)
	if cleared_inspected_enemy:
		_refresh_selection_ui_state()

func _resolve_tag_update_stride(depth: float, text_refresh: bool) -> int:
	var far_depth: float = maxf(unit_tag_far_depth, unit_tag_near_ops_depth + 1.0)
	var very_far_depth: float = maxf(unit_tag_very_far_depth, far_depth + 1.0)
	var far_stride: int = maxi(1, unit_tag_far_text_stride if text_refresh else unit_tag_far_position_stride)
	var very_far_stride: int = maxi(far_stride, unit_tag_very_far_text_stride if text_refresh else unit_tag_very_far_position_stride)
	if depth >= very_far_depth:
		return very_far_stride
	if depth >= far_depth:
		return far_stride
	return 1

func _style_unit_tag_label(label: Label, font_size: int, font_color: Color) -> void:
	if label == null or not is_instance_valid(label):
		return
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.88))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_font_size_override("font_size", font_size)
	if _tag_font != null:
		label.add_theme_font_override("font", _tag_font)

func _style_unit_tag_dialogue_label(label: Label, font_size: int, font_color: Color) -> void:
	if label == null or not is_instance_valid(label):
		return
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.0))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)
	label.add_theme_color_override("font_outline_color", Color(0.95, 0.92, 0.82, 0.95))
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_font_size_override("font_size", font_size)
	if _tag_font != null:
		label.add_theme_font_override("font", _tag_font)
func _update_unit_lod_visibility() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return
	var inv := camera.global_transform.affine_inverse()
	var now_sec: float = Time.get_ticks_msec() / 1000.0
	var show_depth: float = maxf(1.0, lod_soldier_visible_depth)
	var hysteresis: float = maxf(0.0, lod_soldier_hysteresis_depth)
	var hide_depth: float = show_depth + hysteresis
	var force_depth: float = show_depth * 1.25
	var ops_keep_depth: float = maxf(0.0, lod_preserve_player_ops_depth)
	for unit in units:
		if unit == null or not is_instance_valid(unit) or unit.dead:
			continue
		var unit_id: int = unit.get_instance_id()
		var depth := _get_camera_depth_from_inv(inv, unit.global_position)
		var prev_visible: bool = bool(lod_soldier_visible_cache.get(unit_id, true))
		var show_soldiers: bool = prev_visible
		if prev_visible:
			show_soldiers = depth <= hide_depth
		else:
			show_soldiers = depth <= show_depth
		if lod_force_show_soldiers_in_melee:
			var state_value: int = int(unit.state)
			if state_value == int(UnitController.UnitState.MELEE) and depth <= force_depth:
				show_soldiers = true
		if lod_force_show_soldiers_when_engaged:
			var engaged: bool = false
			var state_now: int = int(unit.state)
			if state_now == int(UnitController.UnitState.MELEE) or state_now == int(UnitController.UnitState.SKILL_FORM) or state_now == int(UnitController.UnitState.SKILL_EXEC):
				engaged = true
			elif unit.target_unit != null and is_instance_valid(unit.target_unit) and not unit.target_unit.dead:
				engaged = true
			if engaged:
				lod_soldier_force_until[unit_id] = now_sec + maxf(0.1, lod_engaged_hold_sec)
			var force_until: float = float(lod_soldier_force_until.get(unit_id, 0.0))
			if now_sec <= force_until:
				show_soldiers = true
		var preserve_for_ops: bool = false
		if selected_units.has(unit) or selected_unit == unit or inspected_unit == unit:
			preserve_for_ops = true
		elif depth <= ops_keep_depth and _can_player_direct_unit(unit):
			preserve_for_ops = true
		if preserve_for_ops:
			show_soldiers = true
		var changed: bool = (show_soldiers != prev_visible)
		lod_soldier_visible_cache[unit_id] = show_soldiers
		if changed and unit.has_method("set_soldier_render_enabled"):
			unit.call("set_soldier_render_enabled", show_soldiers)

func _get_camera_depth_from_inv(inv: Transform3D, world_pos: Vector3) -> float:
	var local_pos := inv * world_pos
	return maxf(-local_pos.z, 0.01)

func _compute_tag_scale(camera: Camera3D, world_pos: Vector3) -> float:
	var local_pos := camera.global_transform.affine_inverse() * world_pos
	var depth := maxf(-local_pos.z, 0.01)
	var t := inverse_lerp(unit_tag_near_distance, unit_tag_far_distance, depth)
	return lerpf(unit_tag_near_scale, unit_tag_far_scale, clampf(t, 0.0, 1.0))

func _make_status_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size = Vector2(0.0, 8.0)
	_set_status_bar_colors(bar, TAG_BAR_GREEN, TAG_BAR_EMPTY)
	return bar

func _set_status_bar_colors(bar: ProgressBar, fill_color: Color, bg_color: Color) -> void:
	if bar == null or not is_instance_valid(bar):
		return
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.border_color = Color(fill_color.r, fill_color.g, fill_color.b, 0.98)
	fill_style.set_border_width_all(1)
	fill_style.set_corner_radius_all(2)
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = bg_color
	bg_style.border_color = TAG_FRAME_GOLD
	bg_style.set_border_width_all(1)
	bg_style.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill_style)
	bar.add_theme_stylebox_override("background", bg_style)

func _make_card_line() -> ColorRect:
	var line := ColorRect.new()
	line.color = TAG_LINE_BRONZE
	line.custom_minimum_size = Vector2(0.0, 1.0)
	return line
func _make_card_stylebox(bg: Color, _border: Color, _border_w: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg.r, bg.g, bg.b, 0.0)
	style.border_color = Color(0.0, 0.0, 0.0, 0.0)
	style.set_border_width_all(0)
	style.set_corner_radius_all(0)
	return style

func _faction_tag_color(team_id: int) -> Color:
	if team_id == 0:
		return Color(0.56, 0.16, 0.15)
	if team_id == 1:
		return Color(0.15, 0.23, 0.5)
	return Color(0.29, 0.24, 0.18)

func _apply_card_selection_style(btn: Button, widgets: Dictionary, selected: bool) -> void:
	var normal_style: StyleBoxFlat = widgets.get("normal_style")
	var hover_style: StyleBoxFlat = widgets.get("hover_style")
	var selected_style: StyleBoxFlat = widgets.get("selected_style")
	if selected:
		btn.add_theme_stylebox_override("normal", selected_style)
		btn.add_theme_stylebox_override("hover", selected_style)
		btn.add_theme_stylebox_override("pressed", selected_style)
		btn.add_theme_stylebox_override("focus", selected_style)
	else:
		btn.add_theme_stylebox_override("normal", normal_style)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("pressed", selected_style)
		btn.add_theme_stylebox_override("focus", selected_style)

func _get_unit_tag_lod_tier(unit, depth: float) -> int:
	if unit == null or not is_instance_valid(unit):
		return 0
	var unit_id: int = unit.get_instance_id()
	var soldiers_visible: bool = bool(lod_soldier_visible_cache.get(unit_id, true))
	if not soldiers_visible:
		return 2
	if depth >= maxf(unit_tag_near_distance * 2.1, unit_tag_far_distance * 0.32):
		return 1
	return 0

func _get_unit_tag_world_pos(unit, tier: int) -> Vector3:
	var lift: float = unit_tag_lod0_world_lift
	match tier:
		2:
			lift = unit_tag_lod2_world_lift
		1:
			lift = unit_tag_lod1_world_lift
		_:
			lift = unit_tag_lod0_world_lift
	return unit.global_position + Vector3(0.0, unit_tag_height_offset + lift, 0.0)

func _get_unit_tag_screen_gap(tier: int) -> float:
	match tier:
		2:
			return unit_tag_lod2_screen_gap
		1:
			return unit_tag_lod1_screen_gap
		_:
			return unit_tag_lod0_screen_gap

func _apply_unit_tag_lod_style(unit, widgets: Dictionary, tier: int) -> bool:
	var card: Button = widgets.get("card")
	var portrait_holder: Control = widgets.get("portrait_holder")
	var name_label: Label = widgets.get("name_label")
	var type_label: Label = widgets.get("type_label")
	var status_label: Label = widgets.get("status_label")
	var dialogue_wrap: Control = widgets.get("dialogue_wrap")
	var dialogue_label: Label = widgets.get("dialogue_label")
	var count_label: Label = widgets.get("count_label")
	var morale_bar: ProgressBar = widgets.get("morale_bar")
	var will_bar: ProgressBar = widgets.get("will_bar")
	if card == null or not is_instance_valid(card):
		return false
	var prev_tier: int = int(widgets.get("lod_tier", -1))
	if prev_tier == tier:
		return false
	var supply_alert: bool = bool(widgets.get("supply_alert_active", false))
	var dialogue_active: bool = bool(widgets.get("dialogue_active", false))
	var dialogue_text: String = String(widgets.get("dialogue_text", "")).strip_edges()
	var dialogue_visible: bool = dialogue_active and not dialogue_text.is_empty()
	var status_color_any: Variant = widgets.get("status_line_color", Color(0.92, 0.95, 0.82, 0.92))
	var status_color: Color = status_color_any if status_color_any is Color else Color(0.92, 0.95, 0.82, 0.92)
	var status_visible: bool = bool(widgets.get("status_line_visible", true))
	var type_color: Color = Color(1.0, 0.5, 0.42, 0.98) if supply_alert else Color(0.93, 0.95, 0.98, 0.94)
	var count_color: Color = Color(1.0, 0.52, 0.46, 1.0) if supply_alert else Color(1.0, 1.0, 1.0, 0.96)
	widgets["lod_tier"] = tier
	match tier:
		2:
			card.custom_minimum_size = unit_tag_lod2_size
			if portrait_holder != null: portrait_holder.custom_minimum_size = Vector2(16.0, 16.0)
			if name_label != null:
				name_label.visible = true
				_style_unit_tag_label(name_label, 8, Color(0.96, 0.9, 0.74, 0.95))
			if type_label != null:
				type_label.visible = true
				_style_unit_tag_label(type_label, 8, type_color)
			if status_label != null:
				status_label.visible = false
			if count_label != null:
				count_label.custom_minimum_size = Vector2(22.0, 0.0)
				_style_unit_tag_label(count_label, 9, count_color)
			if morale_bar != null:
				morale_bar.visible = true
				morale_bar.custom_minimum_size = Vector2(0.0, 3.0)
			if will_bar != null:
				will_bar.visible = true
				will_bar.custom_minimum_size = Vector2(0.0, 3.0)
			if dialogue_wrap != null:
				dialogue_wrap.visible = dialogue_visible
				dialogue_wrap.offset_left = -20.0
				dialogue_wrap.offset_top = -54.0
				dialogue_wrap.offset_right = 34.0
				dialogue_wrap.offset_bottom = -4.0
			if dialogue_label != null:
				dialogue_label.text = "“%s”" % dialogue_text if dialogue_visible else ""
				_style_unit_tag_dialogue_label(dialogue_label, 11, Color(0.16, 0.11, 0.07, 1.0))
		1:
			card.custom_minimum_size = unit_tag_lod1_size
			if portrait_holder != null: portrait_holder.custom_minimum_size = Vector2(24.0, 24.0)
			if name_label != null:
				name_label.visible = true
				_style_unit_tag_label(name_label, 10, Color(0.96, 0.9, 0.74, 1.0))
			if type_label != null:
				type_label.visible = true
				_style_unit_tag_label(type_label, 9, type_color)
			if status_label != null:
				status_label.visible = status_visible
				_style_unit_tag_label(status_label, 9 if dialogue_active else 8, status_color)
			if count_label != null:
				count_label.custom_minimum_size = Vector2(26.0, 0.0)
				_style_unit_tag_label(count_label, 10, count_color)
			if morale_bar != null:
				morale_bar.visible = true
				morale_bar.custom_minimum_size = Vector2(0.0, 4.0)
			if will_bar != null:
				will_bar.visible = true
				will_bar.custom_minimum_size = Vector2(0.0, 4.0)
			if dialogue_wrap != null:
				dialogue_wrap.visible = dialogue_visible
				dialogue_wrap.offset_left = -28.0
				dialogue_wrap.offset_top = -62.0
				dialogue_wrap.offset_right = 44.0
				dialogue_wrap.offset_bottom = -5.0
			if dialogue_label != null:
				dialogue_label.text = "“%s”" % dialogue_text if dialogue_visible else ""
				_style_unit_tag_dialogue_label(dialogue_label, 12, Color(0.16, 0.11, 0.07, 1.0))
		_:
			card.custom_minimum_size = unit_tag_lod0_size
			if portrait_holder != null: portrait_holder.custom_minimum_size = Vector2(32.0, 32.0)
			if name_label != null:
				name_label.visible = true
				_style_unit_tag_label(name_label, 11, Color(0.96, 0.9, 0.74, 1.0))
			if type_label != null:
				type_label.visible = true
				_style_unit_tag_label(type_label, 10, type_color)
			if status_label != null:
				status_label.visible = status_visible
				_style_unit_tag_label(status_label, 10 if dialogue_active else 9, status_color)
			if count_label != null:
				count_label.custom_minimum_size = Vector2(30.0, 0.0)
				_style_unit_tag_label(count_label, 11, count_color)
			if morale_bar != null:
				morale_bar.visible = true
				morale_bar.custom_minimum_size = Vector2(0.0, 5.0)
			if will_bar != null:
				will_bar.visible = true
				will_bar.custom_minimum_size = Vector2(0.0, 5.0)
			if dialogue_wrap != null:
				dialogue_wrap.visible = dialogue_visible
				dialogue_wrap.offset_left = -36.0
				dialogue_wrap.offset_top = -72.0
				dialogue_wrap.offset_right = 56.0
				dialogue_wrap.offset_bottom = -6.0
			if dialogue_label != null:
				dialogue_label.text = "“%s”" % dialogue_text if dialogue_visible else ""
				_style_unit_tag_dialogue_label(dialogue_label, 13, Color(0.16, 0.11, 0.07, 1.0))
	card.size = card.custom_minimum_size
	return true

func _update_unit_tag_data(unit, widgets: Dictionary) -> void:
	var name_label: Label = widgets.get("name_label")
	var portrait_rect: TextureRect = widgets.get("portrait_rect")
	var type_label: Label = widgets.get("type_label")
	var status_label: Label = widgets.get("status_label")
	var dialogue_wrap: Control = widgets.get("dialogue_wrap")
	var dialogue_label: Label = widgets.get("dialogue_label")
	var count_label: Label = widgets.get("count_label")
	var morale_bar: ProgressBar = widgets.get("morale_bar")
	var will_bar: ProgressBar = widgets.get("will_bar")
	if name_label == null or not is_instance_valid(name_label):
		return

	var hp_ratio := clampf(unit.hp / maxf(unit.max_hp, 1.0), 0.0, 1.0)
	var morale_ratio: float = float(unit.call("get_morale_ratio")) if unit.has_method("get_morale_ratio") else hp_ratio
	var will_ratio: float = float(unit.call("get_spirit_ratio")) if unit.has_method("get_spirit_ratio") else 0.62

	var unit_count_now: int = int(round(float(unit.soldier_count) * hp_ratio))
	if unit.has_method("get_alive_troop_count"):
		unit_count_now = int(unit.call("get_alive_troop_count"))
	elif unit.has_method("get_alive_soldier_count"):
		unit_count_now = int(unit.call("get_alive_soldier_count"))

	var panel_data: Dictionary = unit.call("get_rts_panel_data") if unit.has_method("get_rts_panel_data") else {}
	var commander_name := ""
	if int(unit.team_id) == 0 and int(unit.unit_type) == int(UnitController.UnitType.CAVALRY):
		commander_name = "Guan Yu"
	elif not panel_data.is_empty():
		commander_name = String(panel_data.get("main_name", ""))
	if commander_name.is_empty():
		commander_name = "Unit %02d" % int(unit.get_instance_id() % 100)

	var type_name := String(unit.unit_type_label_override).strip_edges()
	if type_name.is_empty():
		type_name = _unit_type_text(unit.unit_type)
	var type_name_compact: String = _compact_unit_type_text_for_tag(type_name)
	var out_of_supply: bool = _unit_is_out_of_supply(unit, panel_data)
	widgets["supply_alert_active"] = out_of_supply

	var status_items: Array[String] = []
	if out_of_supply:
		status_items.append("断粮")
	var statuses_any: Variant = panel_data.get("active_statuses", [])
	if statuses_any is Array:
		for status_any in (statuses_any as Array):
			var raw_text: String = String(status_any).strip_edges()
			if raw_text.is_empty():
				continue
			var base_text: String = raw_text
			var space_idx: int = base_text.find(" ")
			if space_idx > 0:
				base_text = base_text.substr(0, space_idx)
			if base_text.is_empty() or base_text == "补给充足":
				continue
			if base_text.find("断粮") != -1:
				widgets["supply_alert_active"] = true
				base_text = "断粮"
			if status_items.has(base_text):
				continue
			status_items.append(base_text)
			if status_items.size() >= 3:
				break
	var status_line_text: String = "正常"
	if not status_items.is_empty():
		status_line_text = "·".join(PackedStringArray(status_items))
	var status_color: Color = Color(1.0, 0.38, 0.3, 0.98) if bool(widgets.get("supply_alert_active", false)) else Color(0.92, 0.95, 0.82, 0.92)
	var dialogue_active: bool = false
	var dialogue_text: String = ""
	if unit.has_method("get_commander_dialogue_snapshot"):
		var dialogue_any: Variant = unit.call("get_commander_dialogue_snapshot")
		if dialogue_any is Dictionary:
			var dialogue: Dictionary = dialogue_any as Dictionary
			if bool(dialogue.get("active", false)):
				dialogue_text = String(dialogue.get("text", "")).strip_edges()
				if not dialogue_text.is_empty():
					dialogue_active = true
	widgets["status_line_text"] = status_line_text
	widgets["status_line_color"] = status_color
	widgets["status_line_visible"] = true
	widgets["dialogue_active"] = dialogue_active
	widgets["dialogue_text"] = dialogue_text

	name_label.text = commander_name
	if portrait_rect != null and is_instance_valid(portrait_rect):
		portrait_rect.texture = _get_tag_head_portrait_for_commander(commander_name)
	if type_label != null and is_instance_valid(type_label):
		type_label.text = type_name_compact
	if status_label != null and is_instance_valid(status_label):
		status_label.visible = true
		status_label.text = status_line_text
		_style_unit_tag_label(status_label, 9, status_color)
	if dialogue_wrap != null and is_instance_valid(dialogue_wrap):
		dialogue_wrap.visible = dialogue_active
	if dialogue_label != null and is_instance_valid(dialogue_label):
		dialogue_label.text = "“%s”" % dialogue_text if dialogue_active else ""
		_style_unit_tag_dialogue_label(dialogue_label, 12, Color(0.16, 0.11, 0.07, 1.0))
	if count_label != null and is_instance_valid(count_label):
		count_label.text = str(unit_count_now)
	if morale_bar != null and is_instance_valid(morale_bar):
		morale_bar.value = clampf(morale_ratio * 100.0, 0.0, 100.0)
	if will_bar != null and is_instance_valid(will_bar):
		will_bar.value = clampf(will_ratio * 100.0, 0.0, 100.0)

func _unit_type_text(unit_type: int) -> String:
	if unit_type == UnitController.UnitType.CAVALRY:
		return "\u9a91\u5175"
	return "\u6b65\u5175"

func _compact_unit_type_text_for_tag(type_text: String) -> String:
	var text: String = type_text.strip_edges()
	if text.is_empty():
		return "\u6b65\u5175"
	match text:
		"\u91ce\u6218\u90e8\u961f":
			return "\u91ce\u6218"
		"\u6728\u725b\u6d41\u9a6c":
			return "\u8fd0\u7cae"
		_:
			pass
	if text.ends_with("\u90e8\u961f") and text.length() > 2:
		text = text.substr(0, text.length() - 2)
	if text.length() > 3:
		text = text.substr(0, 3)
	return text

func _set_tag_quad_color(node_any: Variant, color: Color) -> void:
	if not (node_any is MeshInstance3D):
		return
	var node: MeshInstance3D = node_any as MeshInstance3D
	if node == null or not is_instance_valid(node):
		return
	var mat: StandardMaterial3D = node.material_override as StandardMaterial3D
	if mat == null:
		return
	mat.albedo_color = color

func _setup_tag_label_node(label: Label3D, local_pos: Vector3, font_size: int) -> void:
	if label == null or not is_instance_valid(label):
		return
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.fixed_size = false
	label.pixel_size = 0.0074
	label.font_size = font_size
	label.outline_size = 4
	label.outline_modulate = Color(0.05, 0.04, 0.03, 0.92)
	if _tag_font != null:
		label.font = _tag_font
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = local_pos
	label.visible = true

func _setup_tag_textured_quad_node(node: MeshInstance3D, size: Vector2, local_pos: Vector3, texture: Texture2D) -> void:
	if node == null or not is_instance_valid(node):
		return
	var quad: QuadMesh = node.mesh as QuadMesh
	if quad == null:
		return
	quad.size = size
	var mat: StandardMaterial3D = node.material_override as StandardMaterial3D
	if mat == null:
		return
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.no_depth_test = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	mat.albedo_texture = texture
	node.scale = Vector3.ONE
	node.position = local_pos
	node.visible = true

func _setup_tag_quad_node(node: MeshInstance3D, size: Vector2, local_pos: Vector3, fill_color: Color) -> void:
	if node == null or not is_instance_valid(node):
		return
	var quad: QuadMesh = node.mesh as QuadMesh
	if quad == null:
		return
	quad.size = size
	var mat: StandardMaterial3D = node.material_override as StandardMaterial3D
	if mat == null:
		return
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = fill_color
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.no_depth_test = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.rim_enabled = true
	mat.rim = 0.35
	mat.rim_tint = 1.0
	node.scale = Vector3.ONE
	node.position = local_pos

func _apply_units_motion_state() -> void:
	for unit in units:
		if unit == null or not is_instance_valid(unit):
			continue
		unit.process_mode = Node.PROCESS_MODE_INHERIT if _units_motion_enabled else Node.PROCESS_MODE_DISABLED
func _raycast_screen(screen_pos: Vector2) -> Dictionary:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return {}
	var from: Vector3 = camera.project_ray_origin(screen_pos)
	var to: Vector3 = from + camera.project_ray_normal(screen_pos) * maxf(1200.0, raycast_length)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = GROUND_LAYER_MASK
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		return hit
	if _strategy_map_view != null and is_instance_valid(_strategy_map_view) and _strategy_map_view.has_method("query_terrain_from_screen"):
		var terrain_hit: Variant = _strategy_map_view.call("query_terrain_from_screen", screen_pos)
		if terrain_hit is Dictionary:
			return terrain_hit
	return {}

func _setup_environment() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.54, 0.73, 0.95)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.8, 0.84)
	environment.ambient_light_energy = 0.75
	env.environment = environment
	add_child(env)

	var light := DirectionalLight3D.new()
	light.light_energy = 2.2
	light.rotation_degrees = Vector3(-52.0, -35.0, 0.0)
	add_child(light)

	var ground_mesh := MeshInstance3D.new()
	ground_mesh.name = "GroundMesh"
	var plane := PlaneMesh.new()
	plane.size = Vector2(160.0, 160.0)
	ground_mesh.mesh = plane
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.34, 0.49, 0.31)
	ground_mat.roughness = 0.95
	ground_mesh.material_override = ground_mat
	add_child(ground_mesh)

	var ground_body := StaticBody3D.new()
	ground_body.name = "GroundBody"
	ground_body.collision_layer = GROUND_LAYER_MASK
	ground_body.collision_mask = 0
	add_child(ground_body)

	var ground_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(160.0, 0.2, 160.0)
	ground_shape.shape = box
	ground_shape.position = Vector3(0.0, -0.1, 0.0)
	ground_body.add_child(ground_shape)

	var camera := Camera3D.new()
	camera.name = "BattleCamera"
	camera.set_script(BattleCameraController)
	camera.set("max_distance", 140.0)
	camera.set("zoom_speed", 3.0)
	camera.position = Vector3(0.0, 58.0, 56.0)
	camera.rotation_degrees = Vector3(-62.0, 0.0, 0.0)
	camera.current = true
	add_child(camera)
	camera.call("set_focus_point", Vector3(0.0, 0.0, 0.0))

func _spawn_demo_units() -> void:
	_clear_existing_demo_units()
	var roots: Dictionary = _ensure_demo_unit_roots()
	var team_a_root: Node3D = roots.get("team_a") as Node3D
	var team_b_root: Node3D = roots.get("team_b") as Node3D
	var template_a: Array[UnitController] = _collect_template_units(team_a_root)
	var template_b: Array[UnitController] = _collect_template_units(team_b_root)
	_clear_team_runtime_children(team_a_root)
	_clear_team_runtime_children(team_b_root)

	var spacing: float = maxf(2.0, team_spacing_x)
	var front: float = maxf(6.0, team_front_offset_z)
	var center: Vector3 = spawn_center
	var center_y: float = center.y
	var deployment_a: Array[Dictionary] = _normalize_team_deployment(team_a_deployment)
	var roles_a: Array[String] = _build_roles_for_team(team_a_unit_roles, units_per_team, ["cavalry"])
	var roles_b: Array[String] = _build_roles_for_team(team_b_unit_roles, units_per_team, ["spear", "archer", "strategist_s", "strategist_a", "strategist_b", "strategist_c"])
	if not deployment_a.is_empty():
		roles_a = _merge_roles_with_deployment(roles_a, deployment_a, units_per_team)
	var first_team_a_pos: Vector3 = Vector3(center.x, center_y, center.z + front)
	var first_enemy_role: String = _spawn_role_base(roles_b[0]) if roles_b.size() >= 1 else ""
	var use_close_test_layout: bool = roles_a.size() == 1 and roles_b.size() >= 1 and _spawn_role_base(roles_a[0]) == "cavalry" and first_enemy_role == "spear"
	var close_test_cavalry: UnitController = null
	var close_test_spear: UnitController = null
	var close_test_archer: UnitController = null
	var strategist_counter_a: int = 0
	var strategist_counter_b: int = 0
	var siege_variant_counter_a: int = 0
	var siege_variant_counter_b: int = 0

	for i in range(roles_a.size()):
		var x_offset: float = (float(i) - float(roles_a.size() - 1) * 0.5) * spacing
		var unit_a: UnitController = template_a[i] if i < template_a.size() else _instantiate_unit_controller()
		if unit_a == null:
			continue
		var deploy_entry_a: Dictionary = deployment_a[i] if i < deployment_a.size() else {}
		var role_token_a: String = String(deploy_entry_a.get("role", roles_a[i])).strip_edges()
		var role_a: String = _spawn_role_base(role_token_a)
		if role_a == "siege":
			var siege_variant_a: String = _resolve_siege_variant_from_role_token(role_token_a, siege_variant_counter_a)
			role_token_a = "siege_%s" % siege_variant_a
			siege_variant_counter_a += 1
		_apply_unit_common_runtime_tuning(unit_a)
		var type_a: int = _apply_role_visual(unit_a, role_a, role_token_a)
		if role_a == "strategist":
			_apply_demo_strategist_aptitude(unit_a, role_token_a, strategist_counter_a)
			strategist_counter_a += 1
		unit_a.configure(self, 0, type_a, soldiers_per_unit, UnitController.FormationType.SQUARE)
		_apply_team_deployment_entry(unit_a, deploy_entry_a, 0, role_a, i)
		unit_a.process_mode = Node.PROCESS_MODE_INHERIT
		unit_a.visible = true
		var spawn_pos_a := Vector3(center.x + x_offset, center_y, center.z + front)
		spawn_pos_a.y = _terrain_height_at_world(spawn_pos_a)
		unit_a.position = spawn_pos_a
		if i == 0:
			first_team_a_pos = unit_a.position
			if role_a == "cavalry":
				close_test_cavalry = unit_a
		unit_a.rotation_degrees = Vector3.ZERO
		if unit_a.get_parent() != team_a_root:
			team_a_root.add_child(unit_a)
		register_unit(unit_a)

	for i in range(roles_b.size()):
		var x_offset: float = (float(i) - float(roles_b.size() - 1) * 0.5) * spacing
		var unit_b: UnitController = template_b[i] if i < template_b.size() else _instantiate_unit_controller()
		if unit_b == null:
			continue
		var role_token_b: String = String(roles_b[i]).strip_edges()
		var role_b: String = _spawn_role_base(role_token_b)
		if role_b == "siege":
			var siege_variant_b: String = _resolve_siege_variant_from_role_token(role_token_b, siege_variant_counter_b)
			role_token_b = "siege_%s" % siege_variant_b
			siege_variant_counter_b += 1
		_apply_unit_common_runtime_tuning(unit_b)
		var type_b: int = _apply_role_visual(unit_b, role_b, role_token_b)
		if role_b == "strategist":
			_apply_demo_strategist_aptitude(unit_b, role_token_b, strategist_counter_b)
			strategist_counter_b += 1
		unit_b.configure(self, 1, type_b, soldiers_per_unit, UnitController.FormationType.SQUARE)
		_assign_demo_commander_identity(unit_b, 1, role_b, i)
		if unit_b.has_method("set_stance"):
			var enemy_stance: int = int(UnitController.StanceType.HOLD) if role_b == "archer" or role_b == "crossbow" or role_b == "siege" or role_b == "strategist" else int(UnitController.StanceType.ACTIVE)
			unit_b.set_stance(enemy_stance)
		unit_b.visible = true
		var spawn_pos_b := Vector3(center.x + x_offset, center_y, center.z - front)
		if use_close_test_layout:
			if i == 0 and role_b == "spear":
				spawn_pos_b = first_team_a_pos + Vector3(3.4, 0.0, -0.6)
			elif i == 1 and role_b == "archer":
				spawn_pos_b = first_team_a_pos + Vector3(22.0, 0.0, -14.0)
		spawn_pos_b.y = _terrain_height_at_world(spawn_pos_b)
		unit_b.position = spawn_pos_b
		unit_b.rotation_degrees = Vector3(0.0, 180.0, 0.0)
		if unit_b.get_parent() != team_b_root:
			team_b_root.add_child(unit_b)
		register_unit(unit_b)
		if use_close_test_layout and role_b == "spear" and close_test_spear == null:
			close_test_spear = unit_b
		elif use_close_test_layout and role_b == "archer" and close_test_archer == null:
			close_test_archer = unit_b

	if use_close_test_layout and close_test_cavalry != null and close_test_spear != null:
		close_test_cavalry.issue_attack_order(close_test_spear, close_test_spear.global_position, false, true, false, true)
		close_test_spear.issue_attack_order(close_test_cavalry, close_test_cavalry.global_position, false, true, false, true)
		if close_test_archer != null:
			close_test_archer.issue_attack_order(close_test_cavalry, close_test_cavalry.global_position, false, true, false, true)
	if not embedded_on_strategy_map:
		_setup_demo_test_facilities(center, front)
	for i in range(roles_a.size(), template_a.size()):
		var extra_a: UnitController = template_a[i]
		_remove_unit_tag(extra_a)
		extra_a.visible = false
		extra_a.process_mode = Node.PROCESS_MODE_DISABLED
	for i in range(roles_b.size(), template_b.size()):
		var extra_b: UnitController = template_b[i]
		_remove_unit_tag(extra_b)
		extra_b.visible = false
		extra_b.process_mode = Node.PROCESS_MODE_DISABLED

func _apply_unit_common_runtime_tuning(unit: UnitController) -> void:
	unit.scale = Vector3.ONE * maxf(0.6, unit_node_scale)
	unit.max_hp = maxf(1.0, unit_base_max_hp)
	unit.attack_damage = maxf(0.1, unit_base_attack_damage)
	unit.hp = minf(unit.hp, unit.max_hp)
	unit.infantry_model_scale_mul = infantry_model_scale_mul
	unit.cavalry_model_scale_mul = cavalry_model_scale_mul
	unit.formation_spacing = maxf(0.3, soldier_formation_spacing)
	unit.use_model_albedo_texture = soldier_use_model_albedo_texture
	unit.team_tint_strength = clampf(soldier_team_tint_strength, 0.0, 1.0)
	unit.melee_frontline_width_mul = melee_frontline_width_mul
	unit.melee_frontline_depth_mul = melee_frontline_depth_mul
	unit.melee_contact_distance_mul = melee_contact_distance_mul
	unit.melee_contact_distance_bias = melee_contact_distance_bias
	unit.activity_radius_mul = melee_activity_radius_mul
	unit.activity_radius_visual_weight = melee_activity_radius_visual_weight
	unit.skill_cd_charge = maxf(0.0, unit_skill_cd_charge)
	unit.skill_cd_breakthrough = maxf(0.0, unit_skill_cd_breakthrough)
	unit.skill_cd_sweep = maxf(0.0, unit_skill_cd_sweep)
	var charge_cost: float = unit_skill_will_cost_charge if unit_skill_will_cost_charge > 0.0 else unit_skill_spirit_cost_charge
	var breakthrough_cost: float = unit_skill_will_cost_breakthrough if unit_skill_will_cost_breakthrough > 0.0 else unit_skill_spirit_cost_breakthrough
	var sweep_cost: float = unit_skill_will_cost_sweep if unit_skill_will_cost_sweep > 0.0 else unit_skill_spirit_cost_sweep
	unit.skill_cost_charge = maxf(0.0, charge_cost)
	unit.skill_cost_breakthrough = maxf(0.0, breakthrough_cost)
	unit.skill_cost_sweep = maxf(0.0, sweep_cost)
	unit.player_command_force_chase_sec = maxf(0.0, unit_player_force_chase_sec)
	unit.player_command_force_chase_max_distance = maxf(32.0, unit_player_force_chase_max_distance)
	unit.player_command_force_chase_never_timeout = unit_player_force_chase_never_timeout
	unit.player_command_force_chase_ignore_distance = unit_player_force_chase_ignore_distance
	unit.nav_goal_retry_max_attempts = maxi(0, unit_nav_goal_retry_max_attempts)
	unit.nav_goal_retry_radius_step = maxf(0.5, unit_nav_goal_retry_radius_step)
	unit.nav_goal_retry_directions = maxi(4, unit_nav_goal_retry_directions)
	unit.nav_goal_retry_snap_distance_mul = maxf(1.0, unit_nav_goal_retry_snap_distance_mul)
	unit.morale_loss_per_10pct_troop = maxf(0.0, unit_morale_loss_per_10pct_troop)
	unit.morale_stat_penalty_per_10 = clampf(unit_morale_stat_penalty_per_10, 0.0, 0.3)
	unit.morale_zero_hp_loss_per_sec = maxf(0.0, unit_morale_zero_hp_loss_per_sec)
	unit.rout_troop_ratio_normal = clampf(unit_rout_troop_ratio_normal, 0.01, 0.95)
	unit.rout_troop_ratio_garrison = clampf(unit_rout_troop_ratio_garrison, 0.01, 0.95)
	unit.garrison_morale_loss_mul = clampf(unit_garrison_morale_loss_mul, 0.05, 1.0)
	unit.morale_loss_countered_bonus = maxf(0.0, unit_morale_loss_countered_bonus)
	unit.morale_loss_flanked_bonus = maxf(0.0, unit_morale_loss_flanked_bonus)
	unit.morale_loss_out_of_supply_per_sec = maxf(0.0, unit_morale_loss_out_of_supply_per_sec)
	unit.morale_loss_special_terrain_per_sec = maxf(0.0, unit_morale_loss_special_terrain_per_sec)
	unit.morale_loss_burning_per_sec = maxf(0.0, unit_morale_loss_burning_per_sec)
	var fx_near_depth: float = maxf(220.0, lod_soldier_visible_depth * 1.15)
	var fx_mid_depth: float = minf(maxf(fx_near_depth + 180.0, lod_soldier_visible_depth * 2.6), maxf(fx_near_depth + 40.0, lod_tag_visible_max_depth * 0.58))
	unit.effect_visible_near_depth = fx_near_depth
	unit.effect_visible_mid_depth = fx_mid_depth
	unit.effect_world_scale_mul = maxf(4.6, 1600.0 / maxf(220.0, lod_soldier_visible_depth))
	unit.effect_mid_scale_mul = 0.78
	unit.damage_number_pixel_size = maxf(0.018, 0.0064 * unit.effect_world_scale_mul)
	unit.damage_number_font_size = maxi(96, int(round(24.0 * unit.effect_world_scale_mul)))
	unit.damage_number_outline_size = maxi(12, int(round(3.2 * unit.effect_world_scale_mul)))

func _build_roles_for_team(role_cfg: PackedStringArray, fallback_count: int, default_roles: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for role_any in role_cfg:
		var role: String = String(role_any).strip_edges().to_lower()
		if role.is_empty():
			continue
		out.append(role)
	if out.is_empty():
		var count: int = maxi(1, fallback_count)
		var defaults: Array[String] = default_roles if not default_roles.is_empty() else ["infantry"]
		for i in range(count):
			out.append(String(defaults[i % defaults.size()]))
	return out

func _normalize_team_deployment(raw_entries: Array[Dictionary]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry_any in raw_entries:
		if not (entry_any is Dictionary):
			continue
		var entry: Dictionary = (entry_any as Dictionary).duplicate(true)
		var role_base: String = _spawn_role_base(str(entry.get("role", "")).strip_edges().to_lower())
		if role_base.is_empty():
			role_base = "shield"
		entry["role"] = role_base
		var ship_type: String = _normalize_ship_type_id(str(entry.get("ship_type", "")))
		if ship_type.is_empty():
			entry.erase("ship_type")
		else:
			entry["ship_type"] = ship_type
		entry["officer_name"] = str(entry.get("officer_name", "")).strip_edges()
		entry["vice_1_name"] = str(entry.get("vice_1_name", "")).strip_edges()
		entry["vice_2_name"] = str(entry.get("vice_2_name", "")).strip_edges()
		entry["aptitude"] = str(entry.get("aptitude", "")).strip_edges().to_upper()
		entry["personality_trait_id"] = str(entry.get("personality_trait_id", "")).strip_edges().to_lower()
		entry["personality_text"] = str(entry.get("personality_text", "")).strip_edges()
		entry["personality_level"] = maxi(0, int(entry.get("personality_level", 0)))
		out.append(entry)
	return out

func _merge_roles_with_deployment(base_roles: Array[String], deployment_entries: Array[Dictionary], target_count: int) -> Array[String]:
	var out: Array[String] = base_roles.duplicate()
	var count: int = maxi(1, target_count)
	var fallback_roles: Array[String] = out.duplicate() if not out.is_empty() else ["shield"]
	while out.size() < count:
		out.append(str(fallback_roles[out.size() % fallback_roles.size()]))
	for i in range(mini(deployment_entries.size(), count)):
		var entry: Dictionary = deployment_entries[i]
		var role: String = _spawn_role_base(str(entry.get("role", "")).strip_edges().to_lower())
		if role.is_empty():
			continue
		out[i] = role
	return out

func _aptitude_grade_from_text(grade_text: String) -> int:
	var normalized: String = grade_text.strip_edges().to_upper()
	match normalized:
		"S":
			return int(UnitController.AptitudeGrade.S)
		"A":
			return int(UnitController.AptitudeGrade.A)
		"B":
			return int(UnitController.AptitudeGrade.B)
		_:
			return int(UnitController.AptitudeGrade.C)

func _spawn_role_base(role_token: String) -> String:
	var role: String = role_token.strip_edges().to_lower()
	if role == "strategist":
		return "strategist"
	if role.begins_with("strategist_") or role.begins_with("strategist:") or role.begins_with("strategist-"):
		return "strategist"
	if role == "siege" or not _resolve_siege_variant_from_role_token(role, -1).is_empty():
		return "siege"
	return role

func _resolve_demo_strategist_aptitude(role_token: String, strategist_index: int) -> int:
	var token: String = role_token.strip_edges().to_lower()
	if token == "strategist_s" or token == "strategist:s" or token == "strategist-s":
		return int(UnitController.AptitudeGrade.S)
	if token == "strategist_a" or token == "strategist:a" or token == "strategist-a":
		return int(UnitController.AptitudeGrade.A)
	if token == "strategist_b" or token == "strategist:b" or token == "strategist-b":
		return int(UnitController.AptitudeGrade.B)
	if token == "strategist_c" or token == "strategist:c" or token == "strategist-c":
		return int(UnitController.AptitudeGrade.C)
	var cycle: Array[int] = [
		int(UnitController.AptitudeGrade.S),
		int(UnitController.AptitudeGrade.A),
		int(UnitController.AptitudeGrade.B),
		int(UnitController.AptitudeGrade.C)
	]
	var idx: int = strategist_index % cycle.size()
	if idx < 0:
		idx += cycle.size()
	return cycle[idx]

func _aptitude_grade_short_text(grade: int) -> String:
	match grade:
		int(UnitController.AptitudeGrade.S):
			return "S"
		int(UnitController.AptitudeGrade.A):
			return "A"
		int(UnitController.AptitudeGrade.B):
			return "B"
		_:
			return "C"

func _pick_demo_commander_name(team_id: int, role_base: String, unit_index: int) -> String:
	var pool: Array[String] = DEMO_TEAM0_COMMANDER_POOL if team_id == 0 else DEMO_TEAM1_COMMANDER_POOL
	if role_base == "strategist":
		pool = DEMO_TEAM0_STRATEGIST_POOL if team_id == 0 else DEMO_TEAM1_STRATEGIST_POOL
	if pool.is_empty():
		return "主帅"
	var idx: int = unit_index % pool.size()
	if idx < 0:
		idx += pool.size()
	return String(pool[idx])

func _assign_demo_commander_identity(unit: UnitController, team_id: int, role_base: String, unit_index: int) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	var main_name: String = _pick_demo_commander_name(team_id, role_base, unit_index)
	var vice_1_name: String = _pick_demo_commander_name(team_id, "general", unit_index + 2)
	var vice_2_name: String = _pick_demo_commander_name(team_id, "general", unit_index + 4)
	unit.main_commander_name = main_name
	unit.vice_commander_1_name = vice_1_name
	unit.vice_commander_2_name = vice_2_name
	_apply_unique_skill_identity(unit, "", main_name)

func _apply_team_deployment_entry(unit: UnitController, deployment_entry: Dictionary, team_id: int, role_base: String, unit_index: int) -> void:
	if unit == null or not is_instance_valid(unit):
		return
	_assign_demo_commander_identity(unit, team_id, role_base, unit_index)
	if deployment_entry.is_empty():
		return
	var officer_id: String = str(deployment_entry.get("officer_id", "")).strip_edges().to_lower()
	var officer_name: String = str(deployment_entry.get("officer_name", "")).strip_edges()
	if not officer_name.is_empty():
		unit.main_commander_name = officer_name
	var vice_1_name: String = str(deployment_entry.get("vice_1_name", "")).strip_edges()
	if not vice_1_name.is_empty():
		unit.vice_commander_1_name = vice_1_name
	var vice_2_name: String = str(deployment_entry.get("vice_2_name", "")).strip_edges()
	if not vice_2_name.is_empty():
		unit.vice_commander_2_name = vice_2_name
	var aptitude_text: String = str(deployment_entry.get("aptitude", "")).strip_edges().to_upper()
	if not aptitude_text.is_empty():
		var grade: int = _aptitude_grade_from_text(aptitude_text)
		unit.main_unit_aptitude = grade
		unit.vice_1_unit_aptitude = grade
		unit.vice_2_unit_aptitude = grade
		if role_base == "strategist":
			unit.unit_type_label_override = "Strategist %s" % _aptitude_grade_short_text(grade)
	var personality_trait_id: String = str(deployment_entry.get("personality_trait_id", "")).strip_edges().to_lower()
	var personality_text: String = str(deployment_entry.get("personality_text", personality_trait_id)).strip_edges()
	var personality_level: int = maxi(0, int(deployment_entry.get("personality_level", 0)))
	unit.main_battle_personality = ""
	unit.main_battle_personality_trait_id = ""
	unit.main_battle_personality_level = 0
	if not personality_trait_id.is_empty():
		unit.main_battle_personality_trait_id = personality_trait_id
		unit.main_battle_personality_level = maxi(1, personality_level)
		unit.main_battle_personality = personality_text if not personality_text.is_empty() else personality_trait_id
	var ship_type: String = _normalize_ship_type_id(str(deployment_entry.get("ship_type", "")))
	if not ship_type.is_empty() and unit.has_method("set_preferred_ship_type"):
		unit.call("set_preferred_ship_type", ship_type)
	_apply_unique_skill_identity(unit, officer_id, unit.main_commander_name)

func _apply_demo_strategist_aptitude(unit: UnitController, role_token: String, strategist_index: int) -> void:
	if unit == null:
		return
	var grade: int = _resolve_demo_strategist_aptitude(role_token, strategist_index)
	unit.main_unit_aptitude = grade
	unit.vice_1_unit_aptitude = grade
	unit.vice_2_unit_aptitude = grade
	var grade_text: String = _aptitude_grade_short_text(grade)
	unit.unit_type_label_override = "Strategist %s" % grade_text

func _apply_role_visual(unit: UnitController, role: String, role_token: String = "") -> int:
	var role_id: String = role.strip_edges().to_lower()
	unit.override_model_source_path = ""
	unit.override_albedo_texture_path = ""
	unit.unit_type_label_override = ""
	unit.combat_role_id = "infantry"
	unit.set_meta("siege_variant", "")
	unit.set_meta("siege_variant_label", "")
	unit.attack_range = 2.6
	unit.archer_preferred_range = maxf(6.0, archer_role_attack_range)
	unit.archer_attack_interval = maxf(0.2, archer_role_attack_interval)
	unit.archer_damage_mul = 0.92
	unit.move_speed = 4.8
	var charge_cost: float = maxf(0.0, unit_skill_will_cost_charge if unit_skill_will_cost_charge > 0.0 else unit_skill_spirit_cost_charge)
	var breakthrough_cost: float = maxf(0.0, unit_skill_will_cost_breakthrough if unit_skill_will_cost_breakthrough > 0.0 else unit_skill_spirit_cost_breakthrough)
	var sweep_cost: float = maxf(0.0, unit_skill_will_cost_sweep if unit_skill_will_cost_sweep > 0.0 else unit_skill_spirit_cost_sweep)
	match role_id:
		"cavalry":
			unit.override_albedo_texture_path = cavalry_override_albedo_path
			unit.unit_type_label_override = "\u9a91\u5175"
			unit.combat_role_id = "cavalry"
			return int(UnitController.UnitType.CAVALRY)
		"scout":
			unit.override_albedo_texture_path = cavalry_override_albedo_path
			unit.unit_type_label_override = "\u65a5\u5019"
			unit.combat_role_id = "scout"
			unit.move_speed = 6.8
			unit.attack_range = 2.2
			unit.vision_radius = maxf(unit.vision_radius, 72.0)
			unit.hold_attack_scan_radius = maxf(unit.hold_attack_scan_radius, 58.0)
			unit.max_hp *= 1.12
			unit.attack_damage *= 0.34
			unit.skill_cost_charge = 9999.0
			unit.skill_cost_breakthrough = 9999.0
			unit.skill_cost_sweep = 9999.0
			return int(UnitController.UnitType.CAVALRY)
		"spear":
			unit.override_model_source_path = spear_override_model_path
			unit.override_albedo_texture_path = spear_override_albedo_path
			unit.unit_type_label_override = "\u67aa\u5175"
			unit.combat_role_id = "spear"
			unit.infantry_model_scale_mul = infantry_model_scale_mul * maxf(1.0, spear_model_scale_mul)
			return int(UnitController.UnitType.INFANTRY)
		"shield":
			unit.override_albedo_texture_path = infantry_override_albedo_path
			unit.unit_type_label_override = "\u76fe\u5175"
			unit.combat_role_id = "shield"
			unit.move_speed = 4.1
			unit.attack_range = 2.3
			unit.skill_cost_charge = charge_cost
			unit.skill_cost_breakthrough = breakthrough_cost
			unit.skill_cost_sweep = sweep_cost
			unit.shield_skill_cost_charge = charge_cost
			unit.shield_skill_cost_breakthrough = breakthrough_cost
			unit.shield_skill_cost_sweep = sweep_cost
			return int(UnitController.UnitType.INFANTRY)
		"archer":
			unit.override_model_source_path = archer_override_model_path
			unit.override_albedo_texture_path = archer_override_albedo_path
			unit.unit_type_label_override = "\u5f13\u5175"
			unit.combat_role_id = "archer"
			# Archer model source has taller bounds; use a smaller multiplier to match spear visual size.
			unit.infantry_model_scale_mul = infantry_model_scale_mul * maxf(0.8, spear_model_scale_mul * 0.72)
			unit.attack_range = maxf(16.0, archer_role_attack_range + 8.0)
			unit.archer_preferred_range = maxf(20.0, archer_role_attack_range + 12.0)
			unit.vision_radius = maxf(unit.vision_radius, unit.archer_preferred_range + 18.0)
			unit.hold_attack_scan_radius = maxf(unit.hold_attack_scan_radius, unit.archer_preferred_range + 12.0)
			unit.archer_attack_interval = maxf(0.2, archer_role_attack_interval)
			unit.archer_damage_mul = 1.08
			unit.max_hp *= 0.82
			return int(UnitController.UnitType.INFANTRY)
		"crossbow":
			unit.override_model_source_path = archer_override_model_path
			unit.override_albedo_texture_path = archer_override_albedo_path
			unit.unit_type_label_override = "\u5f29\u5175"
			unit.combat_role_id = "crossbow"
			unit.infantry_model_scale_mul = infantry_model_scale_mul * maxf(0.8, spear_model_scale_mul * 0.72)
			unit.attack_range = maxf(8.0, archer_role_attack_range + 1.0)
			unit.archer_preferred_range = maxf(10.0, archer_role_attack_range + 2.5)
			unit.archer_attack_interval = maxf(0.35, archer_role_attack_interval * 1.28)
			unit.archer_damage_mul = 1.28
			unit.max_hp *= 0.86
			unit.skill_cost_charge = charge_cost
			unit.skill_cost_breakthrough = breakthrough_cost
			unit.skill_cost_sweep = sweep_cost
			return int(UnitController.UnitType.INFANTRY)
		"strategist":
			unit.override_model_source_path = archer_override_model_path
			unit.override_albedo_texture_path = archer_override_albedo_path
			unit.unit_type_label_override = "\u7b56\u58eb"
			unit.combat_role_id = "strategist"
			unit.infantry_model_scale_mul = infantry_model_scale_mul * maxf(0.8, spear_model_scale_mul * 0.72)
			unit.attack_range = maxf(14.0, archer_role_attack_range + 6.0)
			unit.archer_preferred_range = maxf(18.0, archer_role_attack_range + 10.0)
			unit.vision_radius = maxf(unit.vision_radius, unit.archer_preferred_range + 16.0)
			unit.hold_attack_scan_radius = maxf(unit.hold_attack_scan_radius, unit.archer_preferred_range + 10.0)
			unit.archer_attack_interval = maxf(0.35, archer_role_attack_interval * 1.06)
			unit.archer_damage_mul = 0.9
			unit.move_speed = 4.5
			return int(UnitController.UnitType.INFANTRY)
		"siege":
			unit.override_model_source_path = spear_override_model_path
			unit.override_albedo_texture_path = spear_override_albedo_path
			unit.combat_role_id = "siege"
			unit.infantry_model_scale_mul = infantry_model_scale_mul * maxf(1.15, spear_model_scale_mul)
			unit.attack_range = maxf(8.0, archer_role_attack_range + 4.0)
			unit.archer_preferred_range = unit.attack_range
			unit.archer_attack_interval = maxf(0.6, archer_role_attack_interval * 1.85)
			unit.archer_damage_mul = 1.65
			unit.move_speed = 3.1
			_apply_siege_variant_profile(unit, _resolve_siege_variant_from_role_token(role_token, -1))
			return int(UnitController.UnitType.INFANTRY)
		"naval":
			unit.override_albedo_texture_path = infantry_override_albedo_path
			unit.unit_type_label_override = "\u8239\u53ea"
			unit.combat_role_id = "naval"
			unit.move_speed = 4.6
			unit.attack_range = maxf(6.0, archer_role_attack_range - 1.0)
			unit.archer_preferred_range = unit.attack_range
			unit.archer_attack_interval = maxf(0.3, archer_role_attack_interval * 1.1)
			unit.archer_damage_mul = 1.05
			return int(UnitController.UnitType.INFANTRY)
		_:
			unit.override_albedo_texture_path = infantry_override_albedo_path
			unit.unit_type_label_override = "\u6b65\u5175"
			unit.combat_role_id = "infantry"
			return int(UnitController.UnitType.INFANTRY)

func _normalize_siege_variant_id(raw: String) -> String:
	var key: String = raw.strip_edges().to_lower()
	if key.is_empty():
		return ""
	if SIEGE_VARIANT_ALIAS_TO_ID.has(key):
		return String(SIEGE_VARIANT_ALIAS_TO_ID.get(key, ""))
	if SIEGE_VARIANT_ORDER.has(key):
		return key
	return ""

func _resolve_siege_variant_from_role_token(role_token: String, cycle_index: int = 0) -> String:
	var token: String = role_token.strip_edges().to_lower()
	if token.is_empty():
		if cycle_index < 0:
			return ""
		return SIEGE_VARIANT_ORDER[0]
	if token == "siege":
		if cycle_index < 0:
			return SIEGE_VARIANT_ORDER[0]
		var idx: int = cycle_index % SIEGE_VARIANT_ORDER.size()
		if idx < 0:
			idx += SIEGE_VARIANT_ORDER.size()
		return SIEGE_VARIANT_ORDER[idx]
	if token.begins_with("siege_"):
		token = token.substr(6)
	elif token.begins_with("siege-"):
		token = token.substr(6)
	elif token.begins_with("siege:"):
		token = token.substr(6)
	var normalized: String = _normalize_siege_variant_id(token)
	if not normalized.is_empty():
		return normalized
	if cycle_index >= 0:
		var fallback_idx: int = cycle_index % SIEGE_VARIANT_ORDER.size()
		if fallback_idx < 0:
			fallback_idx += SIEGE_VARIANT_ORDER.size()
		return SIEGE_VARIANT_ORDER[fallback_idx]
	return ""

func _siege_variant_display_name(variant_id: String) -> String:
	match variant_id:
		"ram":
			return "冲车/木兽"
		"ladder":
			return "云梯/井阑"
		"catapult":
			return "投石车"
		_:
			return "器械"

func _apply_siege_variant_profile(unit: UnitController, variant_raw: String) -> void:
	if unit == null:
		return
	var variant_id: String = _normalize_siege_variant_id(variant_raw)
	if variant_id.is_empty():
		variant_id = "ram"
	unit.set_meta("siege_variant", variant_id)
	unit.set_meta("siege_variant_label", _siege_variant_display_name(variant_id))
	unit.unit_type_label_override = _siege_variant_display_name(variant_id)
	match variant_id:
		"ram":
			unit.attack_range = maxf(7.0, archer_role_attack_range + 2.0)
			unit.archer_preferred_range = unit.attack_range
			unit.archer_attack_interval = maxf(0.55, archer_role_attack_interval * 1.55)
			unit.archer_damage_mul = 1.78
			unit.move_speed = 3.35
		"ladder":
			unit.attack_range = maxf(9.0, archer_role_attack_range + 4.5)
			unit.archer_preferred_range = unit.attack_range
			unit.archer_attack_interval = maxf(0.58, archer_role_attack_interval * 1.7)
			unit.archer_damage_mul = 1.58
			unit.move_speed = 3.55
		"catapult":
			unit.attack_range = maxf(14.0, archer_role_attack_range + 9.0)
			unit.archer_preferred_range = unit.attack_range
			unit.archer_attack_interval = maxf(0.7, archer_role_attack_interval * 2.25)
			unit.archer_damage_mul = 1.86
			unit.move_speed = 2.7
			unit.vision_radius = maxf(unit.vision_radius, unit.archer_preferred_range + 12.0)
			unit.hold_attack_scan_radius = maxf(unit.hold_attack_scan_radius, unit.archer_preferred_range + 8.0)
		_:
			pass

func _instantiate_unit_controller() -> UnitController:
	if UNIT_CONTROLLER_SCENE == null:
		push_error("UnitController scene is missing: res://scenes/units/unit_controller.tscn")
		return null
	var inst: Node = UNIT_CONTROLLER_SCENE.instantiate()
	if inst is UnitController:
		return inst as UnitController
	if inst != null and is_instance_valid(inst):
		inst.queue_free()
	push_error("UnitController scene root must be UnitController: res://scenes/units/unit_controller.tscn")
	return null

func _clear_existing_demo_units() -> void:
	var stale_units: Array = units.duplicate()
	for unit in stale_units:
		if unit == null or not is_instance_valid(unit):
			continue
		_remove_unit_tag(unit)
		if _is_template_unit_node(unit):
			unit.visible = false
			unit.process_mode = Node.PROCESS_MODE_DISABLED
			continue
		unit.queue_free()
	units.clear()
	selected_unit = null
	selected_units.clear()
	lod_soldier_visible_cache.clear()
	lod_soldier_force_until.clear()
	_siege_variant_proc_cooldowns.clear()
	_reset_demo_siege_debug_stats()
	unit_skill_auto_mode.clear()
	unit_famous_auto_mode.clear()
	famous_auto_cooldowns.clear()
	famous_skill_cooldowns.clear()
	_clear_recon_runtime_state()
	_clear_demo_test_facilities()

func _ensure_demo_unit_roots() -> Dictionary:
	var units_root: Node3D = get_node_or_null(DEMO_UNITS_ROOT_NAME) as Node3D
	if units_root == null:
		units_root = Node3D.new()
		units_root.name = DEMO_UNITS_ROOT_NAME
		add_child(units_root)

	var team_a_root: Node3D = units_root.get_node_or_null(DEMO_TEAM_A_NAME) as Node3D
	if team_a_root == null:
		team_a_root = Node3D.new()
		team_a_root.name = DEMO_TEAM_A_NAME
		units_root.add_child(team_a_root)

	var team_b_root: Node3D = units_root.get_node_or_null(DEMO_TEAM_B_NAME) as Node3D
	if team_b_root == null:
		team_b_root = Node3D.new()
		team_b_root.name = DEMO_TEAM_B_NAME
		units_root.add_child(team_b_root)

	return {
		"root": units_root,
		"team_a": team_a_root,
		"team_b": team_b_root
	}

func _ensure_demo_facility_root() -> void:
	if _demo_facility_root != null and is_instance_valid(_demo_facility_root):
		return
	var existing: Node = get_node_or_null(DEMO_FACILITY_ROOT_NAME)
	if existing is Node3D:
		_demo_facility_root = existing as Node3D
		return
	_demo_facility_root = Node3D.new()
	_demo_facility_root.name = DEMO_FACILITY_ROOT_NAME
	add_child(_demo_facility_root)

func _clear_demo_test_facilities() -> void:
	_demo_facility_effect_tick_accum = 0.0
	_demo_siege_ai_tick_accum = 0.0
	_demo_tower_cooldowns.clear()
	_demo_facilities.clear()
	_reset_demo_siege_debug_stats()
	_refresh_demo_siege_debug_overlay(true)
	_refresh_demo_siege_objective_panel(true)
	if _demo_facility_root == null or not is_instance_valid(_demo_facility_root):
		var existing: Node = get_node_or_null(DEMO_FACILITY_ROOT_NAME)
		if existing is Node3D:
			_demo_facility_root = existing as Node3D
	if _demo_facility_root == null or not is_instance_valid(_demo_facility_root):
		return
	for child in _demo_facility_root.get_children():
		if child is Node:
			(child as Node).queue_free()

func _setup_demo_test_facilities(center: Vector3, front: float) -> void:
	_clear_demo_test_facilities()
	if not demo_facility_test_setup_enabled:
		return
	_ensure_demo_facility_root()
	if _demo_facility_root == null or not is_instance_valid(_demo_facility_root):
		return
	var core_layout: Array = [
		{"type": "chengzhai", "x": 0.0, "z": front - 6.0},
		{"type": "muzhai", "x": -18.0, "z": front - 8.0},
		{"type": "chengzhai", "x": 18.0, "z": front - 8.0},
		{"type": "jianlou", "x": -36.0, "z": front - 12.0},
		{"type": "gaojijianlou", "x": 36.0, "z": front - 12.0},
		{"type": "taigutai", "x": -10.0, "z": front + 11.0},
		{"type": "junyuetai", "x": 10.0, "z": front + 11.0},
		{"type": "granary", "x": -28.0, "z": front + 15.0}
	]
	for team_id in [0, 1]:
		var side: float = 1.0 if team_id == 0 else -1.0
		var idx: int = 0
		for def_any in core_layout:
			if not (def_any is Dictionary):
				continue
			var def: Dictionary = def_any as Dictionary
			var type_key: String = String(def.get("type", "")).to_lower().strip_edges()
			if type_key.is_empty():
				continue
			var world_pos := Vector3(
				center.x + float(def.get("x", 0.0)),
				center.y,
				center.z + float(def.get("z", 0.0)) * side
			)
			world_pos.y = _terrain_height_at_world(world_pos)
			var facility_id: String = "demo_%s_t%d_%02d" % [type_key, team_id, idx]
			_create_demo_facility_marker(facility_id, type_key, team_id, world_pos, 180.0 if team_id == 1 else 0.0)
			idx += 1
		var wall_z: float = center.z + front * 0.34 * side
		for n in range(-2, 3):
			var wall_pos := Vector3(center.x + float(n) * 8.5, center.y, wall_z)
			wall_pos.y = _terrain_height_at_world(wall_pos)
			var wall_id: String = "demo_zhalan_t%d_%d" % [team_id, n + 2]
			_create_demo_facility_marker(wall_id, "zhalan", team_id, wall_pos, 90.0)

func _demo_facility_type_name(type_key: String) -> String:
	match type_key:
		"jianlou":
			return "箭楼"
		"gaojijianlou":
			return "高级箭楼"
		"muzhai":
			return "木寨"
		"chengzhai":
			return "城池"
		"zhalan":
			return "栅栏"
		"taigutai":
			return "太鼓台"
		"junyuetai":
			return "军乐台"
		"granary":
			return "粮仓"
		_:
			return type_key

func _demo_facility_max_hp(type_key: String) -> float:
	if demo_siege_facility_hp_by_type.has(type_key):
		return maxf(1.0, float(demo_siege_facility_hp_by_type.get(type_key, 360.0)))
	if demo_siege_facility_hp_by_type.has("default"):
		return maxf(1.0, float(demo_siege_facility_hp_by_type.get("default", 360.0)))
	return 360.0

func _demo_facility_attack_radius(type_key: String) -> float:
	if demo_siege_facility_attack_radius_by_type.has(type_key):
		return maxf(3.0, float(demo_siege_facility_attack_radius_by_type.get(type_key, 12.0)))
	if demo_siege_facility_attack_radius_by_type.has("default"):
		return maxf(3.0, float(demo_siege_facility_attack_radius_by_type.get("default", 12.0)))
	return 12.0

func _demo_facility_role_damage_mul(role_id: String) -> float:
	if demo_siege_role_damage_mul.has(role_id):
		return maxf(0.0, float(demo_siege_role_damage_mul.get(role_id, 0.0)))
	if demo_siege_role_damage_mul.has("default"):
		return maxf(0.0, float(demo_siege_role_damage_mul.get("default", 0.0)))
	return 0.0

func _demo_facility_target_damage_mul(type_key: String) -> float:
	if demo_siege_target_damage_mul.has(type_key):
		return maxf(0.1, float(demo_siege_target_damage_mul.get(type_key, 1.0)))
	if demo_siege_target_damage_mul.has("default"):
		return maxf(0.1, float(demo_siege_target_damage_mul.get("default", 1.0)))
	return 1.0

func _is_demo_facility_destroyed(facility: Dictionary) -> bool:
	return bool(facility.get("destroyed", false)) or float(facility.get("hp", 0.0)) <= 0.001

func _refresh_demo_facility_label(facility: Dictionary) -> void:
	var label: Label3D = facility.get("label", null) as Label3D
	if label == null or not is_instance_valid(label):
		return
	var type_key: String = String(facility.get("type", "")).to_lower().strip_edges()
	var team_id: int = int(facility.get("team_id", 0))
	var name_text: String = _demo_facility_type_name(type_key)
	var hp: float = maxf(0.0, float(facility.get("hp", 0.0)))
	var max_hp: float = maxf(1.0, float(facility.get("max_hp", 1.0)))
	if _is_demo_facility_destroyed(facility):
		label.text = "%s T%d [已毁]" % [name_text, team_id]
		label.modulate = Color(0.72, 0.66, 0.58, 0.9)
		return
	var hp_ratio: float = clampf(hp / max_hp, 0.0, 1.0)
	label.text = "%s T%d %.0f%%" % [name_text, team_id, hp_ratio * 100.0]
	if hp_ratio >= 0.6:
		label.modulate = Color(0.95, 0.98, 0.92, 0.96)
	elif hp_ratio >= 0.3:
		label.modulate = Color(0.98, 0.86, 0.54, 0.96)
	else:
		label.modulate = Color(1.0, 0.56, 0.46, 0.98)

func _apply_demo_facility_destroyed_visual(facility: Dictionary) -> void:
	var mesh: MeshInstance3D = facility.get("mesh", null) as MeshInstance3D
	if mesh != null and is_instance_valid(mesh):
		var mat: StandardMaterial3D = mesh.material_override as StandardMaterial3D
		if mat != null:
			mat.albedo_color = mat.albedo_color.darkened(0.68)
			mat.roughness = 0.9

func _demo_siege_unit_dps_to_facility(unit: UnitController, type_key: String) -> float:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return 0.0
	var role_id: String = _unit_role_id(unit)
	var role_mul: float = _demo_facility_role_damage_mul(role_id)
	if role_mul <= 0.001:
		return 0.0
	var panel_data: Dictionary = unit.call("get_rts_panel_data") if unit.has_method("get_rts_panel_data") else {}
	var siege_power: float = float(panel_data.get("siege_power", panel_data.get("physical_attack", unit.attack_damage)))
	siege_power = maxf(0.1, siege_power)
	var troop_ratio: float = 1.0
	if unit.has_method("get_alive_troop_count"):
		var alive_troops: float = maxf(0.0, float(unit.call("get_alive_troop_count")))
		var total_troops: float = maxf(1.0, float(unit.troop_count))
		troop_ratio = clampf(alive_troops / total_troops, 0.2, 1.0)
	var target_mul: float = _demo_facility_target_damage_mul(type_key)
	var variant_mul: float = 1.0
	if role_id == "siege":
		var variant_id: String = _unit_siege_variant_id(unit)
		if not variant_id.is_empty():
			var cfg: Dictionary = _siege_variant_cfg(variant_id)
			if not cfg.is_empty():
				variant_mul *= maxf(0.1, _cfg_float(cfg, "facility_damage_mul", 1.0))
				variant_mul *= _cfg_target_mul(cfg, "facility_target_mul", type_key, 1.0)
	var dps_scale: float = maxf(0.0, demo_siege_vs_facility_dps_scale)
	return maxf(0.0, siege_power * troop_ratio * dps_scale * role_mul * target_mul * variant_mul)

func _report_demo_facility_destroyed(facility: Dictionary, attacker_team_id: int) -> void:
	if not demo_siege_facility_destroy_log_enabled:
		return
	var type_key: String = String(facility.get("type", "")).to_lower().strip_edges()
	var defender_team_id: int = int(facility.get("team_id", 0))
	var facility_name: String = _demo_facility_type_name(type_key)
	if attacker_team_id < 0:
		return
	if type_key == "chengzhai":
		on_site_captured(attacker_team_id, facility_name, REPORT_REWARD_CITY_CAPTURE)
		return
	if attacker_team_id == 0:
		var commander = _find_team_report_commander(attacker_team_id)
		var commander_name: String = _resolve_report_unit_name(commander)
		var report_line: String = _pick_report_text([
			"主公，我军已摧毁敌方%s，战获正在清点。" % facility_name,
			"主公，敌方%s已毁，前线工事尽入我手。" % facility_name,
			"主公，我军攻毁%s，辎材与战资已收拢。" % facility_name
		], "主公，我军已摧毁敌方%s，战获正在清点。" % facility_name)
		var reward_delta: Dictionary = _grant_team_battle_reward(attacker_team_id, REPORT_REWARD_FACILITY_DESTROY, "摧毁%s" % facility_name, 5.8, false, commander_name)
		var combined_line: String = "%s %s." % [report_line, _format_battle_reward_delta(reward_delta)]
		_push_commander_report(
			combined_line,
			5.8,
			{
				"show_hud": true,
				"team_id": attacker_team_id,
				"speaker": commander_name,
				"hud_duration": 4.2
			}
		)
		_set_battle_status(report_line, 2.6)
		var dialogue_ctx := {"site": facility_name}
		_trigger_commander_event_line(commander, "victory_site", "据点拿下，清点战获！", dialogue_ctx, 3.0, 2)
	else:
		var defender_commander = _find_team_report_commander(defender_team_id)
		var defender_name: String = _resolve_report_unit_name(defender_commander)
		var report_line_loss: String = _pick_report_text([
			"主公，我军%s已被敌军摧毁，前线屏障告破。" % facility_name,
			"主公，敌军攻毁我方%s，防线压力骤增。" % facility_name,
			"主公，我军失去%s，需尽快补筑防线。" % facility_name
		], "主公，我军%s已被敌军摧毁，前线屏障告破。" % facility_name)
		_push_commander_report(
			report_line_loss,
			5.4,
			{
				"show_hud": true,
				"team_id": defender_team_id,
				"speaker": defender_name,
				"hud_duration": 4.0
			}
		)
		_set_battle_status(report_line_loss, 2.6)
func _is_demo_siege_ai_unit_eligible(unit: UnitController) -> bool:
	if not demo_siege_ai_priority_enabled:
		return false
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return false
	if _unit_role_id(unit) != "siege":
		return false
	if not _is_demo_siege_ai_team_enabled(int(unit.team_id)):
		return false
	var force_facility_only: bool = _should_force_demo_siege_ai_only_facility(unit)
	if not force_facility_only and unit.target_unit != null and is_instance_valid(unit.target_unit) and not unit.target_unit.dead:
		return false
	var cmd_mode: int = int(unit.get_command_mode()) if unit.has_method("get_command_mode") else int(unit.get("command_mode"))
	if cmd_mode == int(UnitController.CommandMode.FORCE_ATTACK) or cmd_mode == int(UnitController.CommandMode.RETREAT):
		return false
	return true

func _pick_demo_siege_priority_facility(unit: UnitController) -> Dictionary:
	if unit == null or not is_instance_valid(unit):
		return {}
	var variant_id: String = _unit_siege_variant_id(unit)
	var variant_cfg: Dictionary = _siege_variant_cfg(variant_id)
	var best: Dictionary = {}
	var best_score: float = -INF
	for fac_any in _demo_facilities:
		if not (fac_any is Dictionary):
			continue
		var fac: Dictionary = fac_any as Dictionary
		if _is_demo_facility_destroyed(fac):
			continue
		if int(fac.get("team_id", 0)) == int(unit.team_id):
			continue
		var node: Node3D = fac.get("node", null) as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var type_key: String = String(fac.get("type", "")).to_lower().strip_edges()
		var base_priority: float = 1.0
		if type_key == "chengzhai":
			base_priority = 1.45
		elif type_key == "gaojijianlou":
			base_priority = 1.18
		var variant_priority: float = 1.0
		if not variant_cfg.is_empty():
			variant_priority *= maxf(0.1, _cfg_float(variant_cfg, "facility_damage_mul", 1.0))
			variant_priority *= _cfg_target_mul(variant_cfg, "facility_target_mul", type_key, 1.0)
		var hp: float = maxf(0.0, float(fac.get("hp", 0.0)))
		var max_hp: float = maxf(1.0, float(fac.get("max_hp", 1.0)))
		var finish_bonus: float = 1.0 + (1.0 - clampf(hp / max_hp, 0.0, 1.0)) * 0.22
		var dist: float = _flat_distance_3d(unit.global_position, node.global_position)
		var score: float = base_priority * variant_priority * finish_bonus / maxf(8.0, dist)
		if score <= best_score:
			continue
		best_score = score
		best = {
			"id": String(fac.get("id", "")),
			"type": type_key,
			"team_id": int(fac.get("team_id", 0)),
			"world_pos": node.global_position,
			"attack_radius": _demo_facility_attack_radius(type_key)
		}
	return best

func _tick_demo_siege_priority_ai(step_sec: float) -> void:
	if not demo_siege_ai_priority_enabled:
		return
	if _demo_facilities.is_empty() or units.is_empty():
		return
	_demo_siege_ai_tick_accum += maxf(0.0, step_sec)
	if _demo_siege_ai_tick_accum < maxf(0.1, demo_siege_ai_order_interval):
		return
	_demo_siege_ai_tick_accum = 0.0
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if not _is_demo_siege_ai_unit_eligible(unit):
			continue
		var force_facility_only: bool = _should_force_demo_siege_ai_only_facility(unit)
		if force_facility_only and unit.target_unit != null and is_instance_valid(unit.target_unit) and not unit.target_unit.dead:
			if unit.has_method("issue_stop_order"):
				unit.call("issue_stop_order")
		var target: Dictionary = _pick_demo_siege_priority_facility(unit)
		if target.is_empty():
			continue
		var target_pos: Vector3 = target.get("world_pos", unit.global_position)
		var attack_radius: float = maxf(3.0, float(target.get("attack_radius", 10.0)))
		if _flat_distance_3d(unit.global_position, target_pos) <= maxf(6.0, attack_radius * 0.82):
			if bool(unit.get("has_move_target")) and unit.has_method("issue_stop_order"):
				unit.call("issue_stop_order")
			continue
		var has_move_target: bool = bool(unit.get("has_move_target"))
		if has_move_target:
			var current_goal: Vector3 = unit.get("move_target")
			current_goal.y = unit.global_position.y
			if _flat_distance_3d(current_goal, target_pos) <= maxf(1.0, demo_siege_ai_retarget_tolerance):
				continue
		if unit.has_method("issue_attack_move_order"):
			unit.call("issue_attack_move_order", target_pos)

func _tick_demo_siege_vs_facility(step_sec: float) -> void:
	if not demo_siege_vs_facility_enabled:
		return
	if step_sec <= 0.0 or _demo_facilities.is_empty():
		return
	if demo_siege_objective_enabled and _demo_siege_objective_winner_team >= 0:
		return
	_tick_demo_siege_variant_skill_cooldowns(step_sec)
	for i in range(_demo_facilities.size()):
		var fac: Dictionary = _demo_facilities[i]
		if _is_demo_facility_destroyed(fac):
			continue
		var node: Node3D = fac.get("node", null) as Node3D
		if node == null or not is_instance_valid(node):
			continue
		var team_id: int = int(fac.get("team_id", 0))
		var type_key: String = String(fac.get("type", "")).to_lower().strip_edges()
		var range_sq: float = pow(_demo_facility_attack_radius(type_key), 2.0)
		var damage_by_team: Dictionary = {}
		for unit_any in units:
			var unit: UnitController = unit_any as UnitController
			if not _is_live_demo_unit(unit):
				continue
			if int(unit.team_id) == team_id:
				continue
			var d: Vector3 = unit.global_position - node.global_position
			d.y = 0.0
			if d.length_squared() > range_sq:
				continue
			var dps: float = _demo_siege_unit_dps_to_facility(unit, type_key)
			if dps <= 0.001:
				continue
			var atk_team: int = int(unit.team_id)
			var accumulated: float = float(damage_by_team.get(atk_team, 0.0))
			var fac_damage: float = dps * step_sec
			fac_damage += _try_trigger_demo_siege_variant_skill(unit, dps)
			damage_by_team[atk_team] = accumulated + fac_damage
			_record_demo_siege_variant_facility_damage(unit, fac_damage)
			_apply_siege_variant_facility_effect(unit, fac, step_sec, dps)
		if damage_by_team.is_empty():
			continue
		var total_damage: float = 0.0
		var best_team: int = -1
		var best_team_damage: float = -1.0
		for team_any in damage_by_team.keys():
			var t: int = int(team_any)
			var dmg: float = maxf(0.0, float(damage_by_team.get(team_any, 0.0)))
			total_damage += dmg
			if dmg > best_team_damage:
				best_team_damage = dmg
				best_team = t
		if total_damage <= 0.001:
			continue
		var hp: float = maxf(0.0, float(fac.get("hp", 0.0)))
		hp = maxf(0.0, hp - total_damage)
		fac["hp"] = hp
		if hp <= 0.001:
			fac["destroyed"] = true
			_apply_demo_facility_destroyed_visual(fac)
			_report_demo_facility_destroyed(fac, best_team)
		_refresh_demo_facility_label(fac)
		_demo_facilities[i] = fac
	_evaluate_demo_siege_objective()

func _apply_siege_variant_facility_effect(unit: UnitController, facility: Dictionary, step_sec: float, dps: float) -> void:
	if unit == null or not is_instance_valid(unit) or unit.dead:
		return
	if step_sec <= 0.0 or dps <= 0.001:
		return
	var variant_id: String = _unit_siege_variant_id(unit)
	if variant_id.is_empty():
		return
	var cfg: Dictionary = _siege_variant_cfg(variant_id)
	if cfg.is_empty():
		return
	var node: Node3D = facility.get("node", null) as Node3D
	if node == null or not is_instance_valid(node):
		return
	var center: Vector3 = node.global_position
	var attacker_team: int = int(unit.team_id)
	match variant_id:
		"ram":
			var burn_chance: float = clampf(_cfg_float(cfg, "facility_burn_chance", 0.0), 0.0, 1.0)
			var burn_radius: float = maxf(0.0, _cfg_float(cfg, "facility_burn_radius", 0.0))
			var burn_cd: float = maxf(0.0, _cfg_float(cfg, "facility_proc_cooldown_sec", 0.0))
			if burn_chance <= 0.0 or burn_radius <= 0.001:
				return
			if not _consume_siege_variant_proc(unit, "ram_facility_burn", burn_cd):
				return
			if randf() > burn_chance:
				return
			var burn_duration: float = maxf(0.1, _cfg_float(cfg, "facility_burn_duration_sec", 3.0))
			var burn_dps: float = maxf(0.1, _cfg_float(cfg, "facility_burn_dps", 3.0))
			var burn_applied: bool = false
			for enemy_any in get_enemies_in_radius(center, burn_radius, attacker_team):
				if not (enemy_any is UnitController):
					continue
				var enemy: UnitController = enemy_any as UnitController
				if enemy == null or not is_instance_valid(enemy) or enemy.dead:
					continue
				if enemy.has_method("apply_burn"):
					enemy.call("apply_burn", burn_duration, burn_dps, attacker_team)
					burn_applied = true
			if burn_applied:
				_record_demo_siege_variant_proc(variant_id, "facility_burn")
		"ladder":
			var morale_per_sec: float = maxf(0.0, _cfg_float(cfg, "facility_morale_per_sec", 0.0))
			var effect_radius: float = maxf(0.0, _cfg_float(cfg, "facility_effect_radius", 0.0))
			if morale_per_sec <= 0.001 or effect_radius <= 0.001:
				return
			var morale_delta: float = -morale_per_sec * step_sec
			var morale_applied: bool = false
			for enemy_any in get_enemies_in_radius(center, effect_radius, attacker_team):
				if not (enemy_any is UnitController):
					continue
				var enemy: UnitController = enemy_any as UnitController
				if enemy == null or not is_instance_valid(enemy) or enemy.dead:
					continue
				if enemy.has_method("_apply_morale_delta"):
					enemy.call("_apply_morale_delta", morale_delta, true)
					morale_applied = true
			if morale_applied:
				_record_demo_siege_variant_proc(variant_id, "facility_morale")
		"catapult":
			var splash_ratio: float = clampf(_cfg_float(cfg, "facility_splash_ratio", 0.0), 0.0, 1.0)
			var splash_radius: float = maxf(0.0, _cfg_float(cfg, "facility_splash_radius", 0.0))
			var splash_cd: float = maxf(0.0, _cfg_float(cfg, "facility_proc_cooldown_sec", 0.0))
			if splash_ratio <= 0.0 or splash_radius <= 0.001:
				return
			if not _consume_siege_variant_proc(unit, "catapult_facility_splash", splash_cd):
				return
			var splash_damage: float = maxf(0.0, dps * step_sec * splash_ratio)
			var splash_morale: float = maxf(0.0, _cfg_float(cfg, "on_hit_morale_damage", 0.0))
			var splash_applied: bool = false
			for enemy_any in get_enemies_in_radius(center, splash_radius, attacker_team):
				if not (enemy_any is UnitController):
					continue
				var enemy: UnitController = enemy_any as UnitController
				if enemy == null or not is_instance_valid(enemy) or enemy.dead:
					continue
				if enemy.has_method("receive_damage") and splash_damage > 0.001:
					enemy.call("receive_damage", splash_damage, unit, false)
					splash_applied = true
				if splash_morale > 0.001 and enemy.has_method("_apply_morale_delta"):
					enemy.call("_apply_morale_delta", -splash_morale, true)
					splash_applied = true
			if splash_applied:
				_record_demo_siege_variant_proc(variant_id, "facility_splash")
		_:
			pass

func _create_demo_facility_marker(facility_id: String, type_key: String, team_id: int, world_pos: Vector3, yaw_deg: float = 0.0) -> void:
	if _demo_facility_root == null or not is_instance_valid(_demo_facility_root):
		return
	var node := Node3D.new()
	node.name = "Facility_%s" % facility_id
	node.position = world_pos
	node.rotation_degrees = Vector3(0.0, yaw_deg, 0.0)
	node.set_meta("facility_id", facility_id)
	node.set_meta("facility_type", type_key)
	node.set_meta("facility_team_id", team_id)
	_demo_facility_root.add_child(node)

	var mesh := MeshInstance3D.new()
	var mat := StandardMaterial3D.new()
	var ally_color: Color = Color(0.9, 0.3, 0.25, 0.96)
	var enemy_color: Color = Color(0.28, 0.58, 0.95, 0.96)
	mat.albedo_color = ally_color if team_id == 0 else enemy_color
	mat.roughness = 0.45
	mesh.material_override = mat
	match type_key:
		"jianlou":
			var tower := CylinderMesh.new()
			tower.top_radius = 1.5
			tower.bottom_radius = 1.8
			tower.height = 5.6
			mesh.mesh = tower
			mesh.position = Vector3(0.0, 2.8, 0.0)
		"gaojijianlou":
			var tower2 := CylinderMesh.new()
			tower2.top_radius = 1.7
			tower2.bottom_radius = 2.0
			tower2.height = 7.2
			mesh.mesh = tower2
			mesh.position = Vector3(0.0, 3.6, 0.0)
		"muzhai":
			var fort := BoxMesh.new()
			fort.size = Vector3(5.2, 3.0, 3.8)
			mesh.mesh = fort
			mesh.position = Vector3(0.0, 1.5, 0.0)
		"chengzhai":
			var fort2 := BoxMesh.new()
			fort2.size = Vector3(6.4, 3.8, 4.6)
			mesh.mesh = fort2
			mesh.position = Vector3(0.0, 1.9, 0.0)
		"zhalan":
			var wall := BoxMesh.new()
			wall.size = Vector3(7.6, 2.0, 0.8)
			mesh.mesh = wall
			mesh.position = Vector3(0.0, 1.0, 0.0)
		"taigutai":
			var drum := CylinderMesh.new()
			drum.top_radius = 2.0
			drum.bottom_radius = 2.0
			drum.height = 1.4
			mesh.mesh = drum
			mesh.position = Vector3(0.0, 0.7, 0.0)
		"junyuetai":
			var stage := CylinderMesh.new()
			stage.top_radius = 2.4
			stage.bottom_radius = 2.4
			stage.height = 1.6
			mesh.mesh = stage
			mesh.position = Vector3(0.0, 0.8, 0.0)
		"granary":
			var storage := BoxMesh.new()
			storage.size = Vector3(4.0, 2.6, 4.0)
			mesh.mesh = storage
			mesh.position = Vector3(0.0, 1.3, 0.0)
		_:
			var fallback := BoxMesh.new()
			fallback.size = Vector3(3.0, 2.4, 3.0)
			mesh.mesh = fallback
			mesh.position = Vector3(0.0, 1.2, 0.0)
	node.add_child(mesh)

	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = 28
	label.outline_size = 4
	label.text = "%s T%d" % [_demo_facility_type_name(type_key), team_id]
	label.position = Vector3(0.0, 4.8, 0.0)
	node.add_child(label)

	var max_hp: float = _demo_facility_max_hp(type_key)
	var entry: Dictionary = {
		"id": facility_id,
		"type": type_key,
		"team_id": team_id,
		"node": node,
		"mesh": mesh,
		"label": label,
		"max_hp": max_hp,
		"hp": max_hp,
		"destroyed": false
	}
	_demo_facilities.append(entry)
	_refresh_demo_facility_label(entry)

func _is_live_demo_unit(unit: UnitController) -> bool:
	return unit != null and is_instance_valid(unit) and not unit.dead and unit.visible

func _tick_demo_facility_effects(delta: float) -> void:
	if _demo_facilities.is_empty():
		return
	_demo_facility_effect_tick_accum += maxf(0.0, delta)
	if _demo_facility_effect_tick_accum < maxf(0.05, demo_facility_effect_tick_interval):
		return
	var step_sec: float = _demo_facility_effect_tick_accum
	_demo_facility_effect_tick_accum = 0.0
	_tick_demo_siege_priority_ai(step_sec)
	_tick_demo_siege_vs_facility(step_sec)
	_tick_demo_tower_cooldowns(step_sec)
	var active_tower_ids: Dictionary = {}
	for fac_any in _demo_facilities:
		if not (fac_any is Dictionary):
			continue
		var fac: Dictionary = fac_any as Dictionary
		if _is_demo_facility_destroyed(fac):
			continue
		var type_key: String = String(fac.get("type", "")).to_lower().strip_edges()
		match type_key:
			"jianlou":
				active_tower_ids[String(fac.get("id", ""))] = true
				_tick_single_demo_tower(fac, demo_jianlou_range, demo_jianlou_damage, demo_jianlou_cooldown)
			"gaojijianlou":
				active_tower_ids[String(fac.get("id", ""))] = true
				_tick_single_demo_tower(fac, demo_gaojijianlou_range, demo_gaojijianlou_damage, demo_gaojijianlou_cooldown)
			"muzhai":
				_apply_demo_defense_aura(fac, demo_muzhai_defense_range)
			"chengzhai":
				_apply_demo_defense_aura(fac, demo_chengzhai_defense_range)
			"taigutai":
				_apply_demo_taigutai_recovery(fac, step_sec)
			"junyuetai":
				_apply_demo_junyuetai_attack_buff(fac)
			_:
				pass
	_prune_demo_tower_cooldowns(active_tower_ids)

func _tick_demo_tower_cooldowns(step_sec: float) -> void:
	if _demo_tower_cooldowns.is_empty():
		return
	for id_any in _demo_tower_cooldowns.keys():
		var key: String = String(id_any)
		var left: float = maxf(0.0, float(_demo_tower_cooldowns.get(id_any, 0.0)) - step_sec)
		if left <= 0.001:
			_demo_tower_cooldowns.erase(key)
		else:
			_demo_tower_cooldowns[key] = left

func _prune_demo_tower_cooldowns(active_towers: Dictionary) -> void:
	if _demo_tower_cooldowns.is_empty():
		return
	for id_any in _demo_tower_cooldowns.keys():
		var key: String = String(id_any)
		if active_towers.has(key):
			continue
		_demo_tower_cooldowns.erase(key)

func _tick_single_demo_tower(facility: Dictionary, range_value: float, damage: float, cooldown_sec: float) -> void:
	if _is_demo_facility_destroyed(facility):
		return
	var fac_id: String = String(facility.get("id", "")).strip_edges()
	if fac_id.is_empty():
		return
	if float(_demo_tower_cooldowns.get(fac_id, 0.0)) > 0.001:
		return
	var node: Node3D = facility.get("node", null) as Node3D
	if node == null or not is_instance_valid(node):
		return
	var team_id: int = int(facility.get("team_id", 0))
	var best_target: UnitController = null
	var best_dist_sq: float = range_value * range_value
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if not _is_live_demo_unit(unit):
			continue
		if int(unit.team_id) == team_id:
			continue
		var d: Vector3 = unit.global_position - node.global_position
		d.y = 0.0
		var d2: float = d.length_squared()
		if d2 >= best_dist_sq:
			continue
		best_dist_sq = d2
		best_target = unit
	if best_target == null or not is_instance_valid(best_target):
		return
	if best_target.has_method("receive_damage"):
		best_target.call("receive_damage", maxf(0.0, damage), null, true)
	_demo_tower_cooldowns[fac_id] = maxf(0.12, cooldown_sec)

func _apply_demo_defense_aura(facility: Dictionary, range_value: float) -> void:
	if _is_demo_facility_destroyed(facility):
		return
	var node: Node3D = facility.get("node", null) as Node3D
	if node == null or not is_instance_valid(node):
		return
	var team_id: int = int(facility.get("team_id", 0))
	var range_sq: float = range_value * range_value
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if not _is_live_demo_unit(unit):
			continue
		if int(unit.team_id) != team_id:
			continue
		var d: Vector3 = unit.global_position - node.global_position
		d.y = 0.0
		if d.length_squared() > range_sq:
			continue
		if unit.has_method("apply_status"):
			unit.call("apply_status", int(UnitController.StatusId.TERRAIN_ADVANTAGE), maxf(0.1, demo_defense_buff_hold_sec))

func _apply_demo_taigutai_recovery(facility: Dictionary, step_sec: float) -> void:
	if _is_demo_facility_destroyed(facility):
		return
	var node: Node3D = facility.get("node", null) as Node3D
	if node == null or not is_instance_valid(node):
		return
	var team_id: int = int(facility.get("team_id", 0))
	var range_sq: float = demo_taigutai_recover_range * demo_taigutai_recover_range
	var morale_delta: float = maxf(0.0, demo_taigutai_morale_recover_per_sec) * maxf(0.0, step_sec)
	var spirit_delta: float = maxf(0.0, demo_taigutai_will_recover_per_sec) * maxf(0.0, step_sec)
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if not _is_live_demo_unit(unit):
			continue
		if int(unit.team_id) != team_id:
			continue
		var d: Vector3 = unit.global_position - node.global_position
		d.y = 0.0
		if d.length_squared() > range_sq:
			continue
		if morale_delta > 0.001 and unit.has_method("_apply_morale_delta"):
			unit.call("_apply_morale_delta", morale_delta, false)
		if spirit_delta > 0.001:
			var spirit_cap: float = maxf(1.0, float(unit.get("spirit_cap_current")))
			var spirit_now: float = float(unit.get("spirit_current"))
			unit.set("spirit_current", clampf(spirit_now + spirit_delta, 0.0, spirit_cap))

func _apply_demo_junyuetai_attack_buff(facility: Dictionary) -> void:
	if _is_demo_facility_destroyed(facility):
		return
	var node: Node3D = facility.get("node", null) as Node3D
	if node == null or not is_instance_valid(node):
		return
	var team_id: int = int(facility.get("team_id", 0))
	var range_sq: float = demo_junyuetai_attack_buff_range * demo_junyuetai_attack_buff_range
	for unit_any in units:
		var unit: UnitController = unit_any as UnitController
		if not _is_live_demo_unit(unit):
			continue
		if int(unit.team_id) != team_id:
			continue
		var d: Vector3 = unit.global_position - node.global_position
		d.y = 0.0
		if d.length_squared() > range_sq:
			continue
		if unit.has_method("apply_status"):
			unit.call("apply_status", int(UnitController.StatusId.TACTIC_BUFF), maxf(0.1, demo_junyuetai_attack_buff_hold_sec))

func _clear_team_runtime_children(root: Node3D) -> void:
	if root == null:
		return
	for child in root.get_children():
		if _is_template_unit_node(child):
			continue
		if child is Node:
			(child as Node).queue_free()

func _collect_template_units(root: Node3D) -> Array[UnitController]:
	var out: Array[UnitController] = []
	if root == null:
		return out
	for child in root.get_children():
		if not (child is UnitController):
			continue
		if not _is_template_unit_node(child):
			continue
		out.append(child as UnitController)
	return out

func _is_template_unit_node(node: Node) -> bool:
	if node == null:
		return false
	return String(node.name).begins_with("Tpl_")
