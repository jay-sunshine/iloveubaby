extends Node3D
class_name UnitController

enum UnitType {
	INFANTRY,
	CAVALRY
}

enum FormationType {
	SQUARE,
	LINE,
	WEDGE
}

enum UnitState {
	IDLE,
	MOVE,
	MELEE,
	SKILL_FORM,
	SKILL_EXEC
}

enum SkillType {
	NONE,
	CHARGE,
	BREAKTHROUGH,
	SWEEP
}

enum AptitudeGrade {
	C,
	B,
	A,
	S
}

enum NavMode {
	NONE,
	POINT_MOVE,
	ATTACK_MOVE,
	CHASE_TARGET
}

enum CommandMode {
	NONE,
	STOP,
	MOVE,
	FORCE_ATTACK,
	ATTACK_MOVE,
	HOLD_POSITION,
	RETREAT
}

enum StanceType {
	ACTIVE,
	HOLD,
	PASSIVE
}

enum PathRequestReason {
	POINT_MOVE,
	ATTACK_MOVE,
	CHASE_UPDATE,
	CHASE_FALLBACK,
	SKILL_RESUME
}

enum PathCorridorMode {
	NORMAL,
	COMPRESSED,
	SINGLE_QUEUE
}

enum StatusId {
	SUPPLY_NORMAL,
	HIGH_MORALE,
	TACTIC_BUFF,
	PERSONALITY_BUFF,
	TERRAIN_ADVANTAGE,
	OUT_OF_SUPPLY,
	MORALE_COLLAPSE,
	COUNTERED,
	CONFUSION,
	MISINFORMATION,
	BURNING,
	SLOWED,
	PARALYZED,
	TERRAIN_DISADVANTAGE,
	FACILITY_ATTACK_AURA
}

const EPS := 0.0001
const PERSONALITY_COUNTER_APPLY := 0
const PERSONALITY_COUNTER_BLOCKED := 1
const PERSONALITY_COUNTER_FORCED := 2
const PERSONALITY_SLOT_WEIGHTS := [0.6, 0.2, 0.2]
const DEFAULT_INFANTRY_MODEL_SOURCE_PATH := "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/dunbing.glb"
const DEFAULT_CAVALRY_MODEL_SOURCE_PATH := "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/qingqibing.glb"
const DEFAULT_INFANTRY_MODEL_PATH := "res://.godot/imported/dunbing.glb-7595cb2dafabf2ca2624fe3ac430368e.scn"
const DEFAULT_CAVALRY_MODEL_PATH := "res://.godot/imported/qingqibing.glb-f9c9986f8a1c35e5d740dd8c679d9c14.scn"
const DEFAULT_INFANTRY_ALBEDO_PATH := "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/dunbing_texture_pbr_20250901.png"
const DEFAULT_CAVALRY_ALBEDO_PATH := "res://\u7d20\u6750/\u5efa\u6a21/\u5175\u79cd/qingqibing_texture_pbr_20250901.png"
const SOLDIER_GPU_SHADER := preload("res://scripts/soldier_gpu_anim.gdshader")
const TACTIC_CAST_VFX_SCENE := preload("res://scenes/vfx/tactic_cast_vfx.tscn")
const TACTIC_SUCCESS_VFX_SCENE := preload("res://scenes/vfx/tactic_success_vfx.tscn")
const PROJECTILE_TRACE_VFX_SCENE := preload("res://scenes/vfx/projectile_trace_vfx.tscn")
const STRATEGIST_CAST_SIGIL_TEX := preload("res://素材/brackeys_vfx_bundle/particles/alpha/magic_03_a.png")
const STRATEGIST_SPARK_TEX := preload("res://素材/brackeys_vfx_bundle/particles/alpha/spark_03_a.png")
const STRATEGIST_IMPACT_FLASH_TEX := preload("res://素材/brackeys_vfx_bundle/particles/alpha/flare_01_a.png")
const BURNING_FLAME_TEX := preload("res://素材/brackeys_vfx_bundle/particles/alpha/flame_06_a.png")
const FLOAT_TEXT_FONT_PATH := "res://\u7d20\u6750/\u6c47\u6587\u660e\u671d\u4f53\u6c47\u6587\u660e\u671d\u4f53.ttf"
const INFANTRY_BASE_TINT := Color(0.68, 0.62, 0.54)
const CAVALRY_BASE_TINT := Color(0.6, 0.57, 0.52)
const COMMANDER_DIALOGUE_GENERIC: Dictionary = {
	"state_melee": ["全军压上！", "跟我上，破其锋线！"],
	"state_skill_form": ["谋定而后动。", "稳住阵脚，听令。"],
	"state_skill_exec": ["计成，发令！", "按令齐发！"],
	"state_move": ["稳住阵线，继续推进。", "压住节奏，缓步推进。"],
	"status_out_of_supply": ["粮道已断，速接补给！", "断粮在前，先稳军心！"],
	"status_supply_recovered": ["粮道恢复，全军再进！", "补给已通，恢复攻势！"],
	"status_burning": ["部队起火，稳住阵脚！", "灭火整队，别乱！"],
	"status_morale_low": ["军心动摇，不可乱阵！", "稳住士气，跟紧旗号！"],
	"status_morale_collapse": ["稳住！不可溃散！", "后队顶上，止住溃势！"],
	"command_retreat": ["全军后撤，重整阵线！", "边打边退，莫要断列！"],
	"cast_skill": ["施展{skill}！", "全军配合，{skill}！"],
	"victory_unit": ["敌军已破，乘胜追击！", "此阵已破，继续压进！"],
	"victory_site": ["据点已克，收拢军资！", "据点拿下，清点战获！"]
}
const COMMANDER_DIALOGUE_BY_ROLE: Dictionary = {
	"infantry": {
		"state_melee": ["步阵压上，盾矛齐进！"],
		"state_move": ["步阵稳推，不可冒进。"],
		"status_morale_low": ["步阵勿乱，结阵固守！"]
	},
	"spear": {
		"state_melee": ["长枪列阵，破其前锋！"],
		"cast_skill": ["枪阵已成，{skill}！"]
	},
	"shield": {
		"state_melee": ["举盾顶上，护住阵线！"],
		"status_burning": ["护盾前压，先护本阵！"],
		"command_retreat": ["盾阵殿后，掩护后撤！"]
	},
	"cavalry": {
		"state_melee": ["骑阵展开，冲垮他们！"],
		"state_move": ["骑军机动，切其侧翼！"],
		"cast_skill": ["马势已起，{skill}！"]
	},
	"scout": {
		"state_move": ["斥候先行，探清前路！"],
		"status_out_of_supply": ["轻骑断粮，需速接应！"]
	},
	"archer": {
		"state_melee": ["弓队稳住，保持射界！"],
		"cast_skill": ["弓弦齐鸣，{skill}！"],
		"status_morale_low": ["稳住弓阵，别乱放箭！"]
	},
	"crossbow": {
		"state_melee": ["弩阵上弦，压制敌前！"],
		"cast_skill": ["机弩就位，{skill}！"]
	},
	"strategist": {
		"state_skill_form": ["阵势已定，候我号令。"],
		"state_skill_exec": ["奇策即发，诸军并进。"],
		"cast_skill": ["谋算既成，{skill}！"],
		"victory_site": ["据点既定，速修粮道。"]
	},
	"siege": {
		"state_move": ["器械前推，压近城垣！"],
		"victory_site": ["城防已破，清点工械！"]
	},
	"naval": {
		"state_move": ["舟阵并进，抢占水道！"],
		"cast_skill": ["水势可借，{skill}！"]
	}
}
const COMMANDER_PERSONALITY_ARCHETYPE_BY_TRAIT_ID: Dictionary = {
	"baozhu": "fierce", "bawang": "fierce", "wusheng": "fierce", "feijiang": "fierce", "doujiang": "fierce", "pozhu": "fierce", "qiangxi": "fierce",
	"wolong": "strategist", "fengchu": "strategist", "shenji_gold": "strategist", "mougong": "strategist", "guimou": "strategist", "fanji": "strategist", "quanbian": "strategist",
	"jianjia": "defender", "rengu": "defender", "dunwei": "defender", "zhongzhuang": "defender", "buqu": "defender", "huwei": "defender",
	"jixing": "agile", "qitu": "agile", "chihou": "agile", "yeyan": "agile", "fanfu": "agile",
	"liangzheng": "supply", "jieliang": "supply", "gucang": "supply", "suzhu": "supply", "qianglei": "supply",
	"gongcheng": "siege", "chonglei": "siege", "jingong": "siege", "yunti": "siege", "polei": "siege",
	"shuijiang": "naval", "louzhan": "naval", "doujian": "naval", "qingzhou": "naval", "shuixi": "naval",
	"qingfeng": "weather", "yumu": "weather", "fengjie": "weather", "wuzhan": "weather", "leiding": "weather"
}
const COMMANDER_DIALOGUE_BY_PERSONALITY_ARCHETYPE: Dictionary = {
	"fierce": {
		"state_melee": ["破其阵，斩其将！", "今番不退，直取中军！"],
		"cast_skill": ["杀势已起，{skill}！"],
		"victory_unit": ["敌将已破，继续压上！"]
	},
	"strategist": {
		"state_skill_form": ["先布后战，勿乱军令。"],
		"state_skill_exec": ["策已成局，按令推进。"],
		"cast_skill": ["借势而发，{skill}。"],
		"status_out_of_supply": ["先通粮，再图战。"]
	},
	"defender": {
		"state_melee": ["稳住阵脚，层层顶住！"],
		"status_morale_low": ["守阵不退，军心自定！"],
		"command_retreat": ["交替掩护，稳步后撤。"]
	},
	"agile": {
		"state_move": ["机动穿插，抓其空档！"],
		"cast_skill": ["借势突进，{skill}！"]
	},
	"supply": {
		"status_out_of_supply": ["先护粮道，再言决战。"],
		"status_supply_recovered": ["补给已续，战线可稳。"],
		"victory_site": ["据点既下，立刻整粮。"]
	},
	"siege": {
		"state_move": ["攻具前推，压迫城防！"],
		"victory_site": ["城防已破，转入巩固。"]
	},
	"naval": {
		"state_move": ["控住水道，侧击其阵！"],
		"cast_skill": ["乘潮而战，{skill}！"]
	},
	"weather": {
		"state_skill_exec": ["借天时一击，令其崩阵。"],
		"cast_skill": ["天时已至，{skill}！"]
	}
}
const GOLD_PERSONALITY_TRAIT_IDS: Dictionary = {
	"xionglue": true, "baozhu": true, "longdan": true, "xianji_gold": true, "quanbian": true, "huoshen": true,
	"feijiang": true, "rendun": true, "shenwei": true, "huangtian_gold": true, "doujiang": true, "jueshuo": true,
	"wusheng": true, "wolong": true, "fengchu": true, "shenji_gold": true, "bawang": true
}
const COMMANDER_DIALOGUE_BY_GOLD_TRAIT: Dictionary = {
	"xionglue": {"state_melee": ["雄略在胸，压其全线！"], "victory_unit": ["此战顺势而取，勿失机！"]},
	"baozhu": {"state_melee": ["暴势已起，破阵就在此刻！"], "cast_skill": ["以势碾之，{skill}！"]},
	"longdan": {"state_melee": ["龙胆当前，谁敢阻我！"], "command_retreat": ["整队而退，回身再战！"]},
	"xianji_gold": {"state_skill_form": ["先机在我，先手制敌。"], "cast_skill": ["抢先一步，{skill}！"]},
	"quanbian": {"state_skill_exec": ["权变行令，随势转锋。"], "cast_skill": ["应机而断，{skill}。"]},
	"huoshen": {"cast_skill": ["火势已成，{skill}！"], "state_skill_exec": ["借火攻心，一举破敌！"]},
	"feijiang": {"state_move": ["飞将突进，撕开其阵！"], "victory_unit": ["敌锋已折，快马追击！"]},
	"rendun": {"command_retreat": ["仁遁有序，后撤不乱。"], "status_morale_low": ["稳阵勿惊，徐徐转守。"]},
	"shenwei": {"state_melee": ["神威镇阵，敌莫近前！"], "status_morale_low": ["军心勿摇，跟旗而进！"]},
	"huangtian_gold": {"cast_skill": ["借天命行令，{skill}！"], "state_skill_exec": ["天时已合，令下即发。"]},
	"doujiang": {"state_melee": ["斗将在前，敢战者随我！"], "victory_unit": ["斩其锐锋，再压一步！"]},
	"jueshuo": {"cast_skill": ["目力既至，{skill}！"], "victory_unit": ["一击中的，敌军自乱。"]},
	"wusheng": {"state_melee": ["武圣在此，破其胆魄！"], "victory_unit": ["敌阵已裂，乘势尽取！"]},
	"wolong": {"state_skill_form": ["卧龙运筹，诸军听令。"], "cast_skill": ["羽扇轻举，{skill}。"]},
	"fengchu": {"state_skill_form": ["凤雏定策，稍候片刻。"], "cast_skill": ["奇谋已成，{skill}！"]},
	"shenji_gold": {"state_skill_exec": ["神机既发，不容其喘。"], "cast_skill": ["神机一动，{skill}！"]},
	"bawang": {"state_melee": ["霸王临阵，谁敢不退！"], "victory_unit": ["再战一阵，尽破之！"]}
}
const FAMOUS_COMMANDER_ALIASES: Dictionary = {
	"关云长": "关羽", "张翼德": "张飞", "赵子龙": "赵云", "诸葛孔明": "诸葛亮", "孔明": "诸葛亮",
	"司马仲达": "司马懿", "曹孟德": "曹操", "刘玄德": "刘备", "孙仲谋": "孙权", "周公瑾": "周瑜",
	"吕奉先": "吕布", "张文远": "张辽", "陆伯言": "陆逊", "马孟起": "马超", "黄汉升": "黄忠"
}
const COMMANDER_DIALOGUE_BY_FAMOUS: Dictionary = {
	"关羽": {"state_melee": ["义军随我，斩将破阵！"], "cast_skill": ["青龙偃月，{skill}！"], "victory_unit": ["关某在此，敌阵自破！"], "victory_site": ["此地已下，秋毫无犯。"]},
	"张飞": {"state_melee": ["随我冲阵！喝破敌胆！"], "cast_skill": ["看我一击，{skill}！"], "victory_unit": ["贼军已溃，追！"]},
	"赵云": {"state_melee": ["白马当先，破阵护主！"], "cast_skill": ["子龙在此，{skill}！"], "command_retreat": ["列阵后撤，不失行伍。"]},
	"诸葛亮": {"state_skill_form": ["且按此策，徐徐图之。"], "cast_skill": ["羽扇一挥，{skill}。"], "status_out_of_supply": ["军无粮，不可久战。"], "victory_site": ["据点既定，先修粮道。"]},
	"司马懿": {"state_skill_form": ["先观其势，再断其机。"], "cast_skill": ["权变在手，{skill}。"], "victory_unit": ["敌已入彀，顺势尽取。"]},
	"曹操": {"state_melee": ["诸军奋击，建功在今！"], "cast_skill": ["号令既下，{skill}！"], "victory_unit": ["破敌一阵，犒军！"]},
	"刘备": {"state_melee": ["同袍并肩，救民安众！"], "status_morale_low": ["众将莫乱，与我同心！"], "victory_site": ["城已克定，务安百姓。"]},
	"孙权": {"state_melee": ["将士齐进，稳取其地！"], "cast_skill": ["依令行事，{skill}！"], "victory_site": ["据点到手，速固防务。"]},
	"周瑜": {"cast_skill": ["火势风势，皆为我用，{skill}！"], "state_skill_exec": ["号令齐发，焚其前军！"]},
	"陆逊": {"state_skill_form": ["隐锋蓄势，待机而动。"], "cast_skill": ["后发制人，{skill}。"], "victory_site": ["既得据点，当先固守。"]},
	"吕布": {"state_melee": ["方天在手，谁敢当我！"], "victory_unit": ["再来一阵，皆可斩之！"], "cast_skill": ["看我，{skill}！"]},
	"张辽": {"state_melee": ["陷阵当前，破其胆气！"], "victory_unit": ["敌锋已折，继续冲击！"]},
	"甘宁": {"state_move": ["轻军疾进，直插其后！"], "victory_unit": ["锦帆所至，敌无完阵！"]},
	"夏侯惇": {"state_melee": ["前队顶上，硬破其阵！"], "status_morale_low": ["诸军勿退，随我死战！"]},
	"典韦": {"state_melee": ["重甲突进，谁敢拦我！"], "victory_unit": ["已斩其锋，再压一步！"]},
	"马超": {"state_move": ["西凉铁骑，随我突进！"], "state_melee": ["骑枪并举，撕开敌阵！"]},
	"黄忠": {"cast_skill": ["老将弓稳，{skill}！"], "victory_unit": ["箭下无虚发，敌已溃退。"]}
}
static var _cached_model_mesh_by_type: Dictionary = {}
static var _cached_model_albedo_by_type: Dictionary = {}
static var _cached_model_basis_by_type: Dictionary = {}
static var _cached_proxy_mesh_by_type: Dictionary = {}
static var _cached_commander_mount_mesh_by_path: Dictionary = {}
static var _cached_commander_mount_basis_by_path: Dictionary = {}
static var _cached_float_text_font: FontFile = null

@export var team_id: int = 0
@export var unit_type: UnitType = UnitType.INFANTRY
@export var soldier_count: int = 64
@export var troop_count: int = 6000
@export var visual_troop_threshold_low: int = 3000
@export var visual_troop_threshold_mid: int = 5000
@export var visual_soldier_count_low: int = 16   # 4x4
@export var visual_soldier_count_mid: int = 36   # 6x6
@export var visual_soldier_count_high: int = 64  # 8x8
@export var performance_mode_low: bool = true
@export_range(4, 10, 1) var visual_square_dim_cap: int = 6
@export_range(0.1, 1.0, 0.05) var effect_particle_density_scale: float = 0.55
@export var base_formation: FormationType = FormationType.SQUARE
@export var formation_spacing: float = 0.8
@export var unit_collision_height: float = 2.0
@export var unit_collision_min_scale: float = 0.12
@export var unit_collision_padding_x: float = 0.08
@export var unit_collision_padding_z: float = 0.08
@export var unit_collision_debug_visible: bool = false
@export var walkable_correction_max_distance: float = 12.0
@export var ground_snap_enabled: bool = true
@export var ground_snap_sample_interval: float = 0.12
@export var ground_visual_align_enabled: bool = true
@export var ground_visual_align_probe_distance: float = 2.2
@export var ground_visual_align_max_tilt_deg: float = 20.0
@export var ground_visual_align_lerp_deg_per_sec: float = 120.0
@export var pierce_windup_sec: float = 1.5
@export var pierce_form_duration_sec: float = 1.5
@export var pierce_max_cast_distance: float = 15.0
@export var pierce_speed_mul: float = 3.1
@export var pierce_end_gap: float = 3.0
@export var pierce_end_min_gap: float = 2.0
@export var pierce_max_duration_sec: float = 3.0
@export var pierce_path_probe_step: float = 0.8
@export var pierce_damage_mul_charge: float = 1.95
@export var pierce_damage_mul_breakthrough: float = 2.05
@export var pierce_morale_shock: float = 18.0
@export var pierce_confusion_chance: float = 0.35
@export var pierce_slow_chance: float = 0.45
@export var pierce_confusion_duration: float = 2.2
@export var pierce_slow_duration: float = 2.6
@export var charge_wedge_spacing_mul: float = 0.68
@export var charge_split_reaction_duration: float = 1.05
@export var charge_split_side_push: float = 7.2
@export var charge_split_back_push: float = 2.4
@export var charge_windup_backstep_distance: float = 3.6
@export var move_speed: float = 4.8
@export var charge_speed: float = 20.0
@export var charge_distance: float = 11.0
@export var attack_range: float = 2.6
@export var vision_radius: float = 40.0
@export var chase_max_range_mul: float = 1.5
@export var chase_repath_interval: float = 0.3
@export var chase_repath_threshold: float = 3.0
@export var player_command_force_chase_sec: float = 18.0
@export var player_command_force_chase_max_distance: float = 320.0
@export var player_command_force_chase_never_timeout: bool = true
@export var player_command_force_chase_ignore_distance: bool = true
@export var zoc_enabled: bool = true
@export var zoc_radius: float = 10.5
@export var zoc_speed_mul: float = 0.48
@export var zoc_min_enemy_count: int = 1
@export var zoc_ignore_for_retreat: bool = true
@export var zoc_ignore_for_skill_charge: bool = true
@export var attack_move_scan_interval: float = 0.25
@export var attack_move_scan_radius: float = 22.0
@export var nav_path_reach_tolerance: float = 0.08
@export var nav_adherence_tolerance: float = 0.6
@export var nav_path_search_max_distance: float = 12000.0
@export var nav_path_search_max_polygons: int = 120000
@export var nav_path_return_max_length: float = 0.0
@export var nav_query_timeout_sec: float = 0.35
@export var enable_path_validity_sampling: bool = false
@export var nav_goal_retry_max_attempts: int = 3
@export var nav_goal_retry_radius_step: float = 3.0
@export var nav_goal_retry_directions: int = 12
@export var nav_goal_retry_snap_distance_mul: float = 1.35
@export var blocked_repath_interval_sec: float = 0.35
@export var blocked_force_stop_sec: float = 5.0
@export var enable_corridor_width_scan: bool = false
@export var path_sample_interval: float = 3.0
@export var path_probe_max_width: float = 24.0
@export var path_probe_step: float = 0.6
@export var narrow_width_threshold: float = 2.0
@export var compressed_width_padding: float = 0.5
@export var queue_spacing: float = 1.5
@export var queue_transition_sec: float = 0.9
@export var enable_parent_nav_snap: bool = false
@export var parent_nav_snap_interval: float = 0.2
@export var parent_nav_snap_tolerance: float = 1.6
@export var attack_interval: float = 0.7
@export var infantry_attack_interval: float = 0.9
@export var cavalry_attack_interval: float = 0.72
@export var attack_damage: float = 6.0
@export var safety_distance: float = 2.0
@export var downhill_speed_accel_per_sec: float = 1.6
@export var downhill_speed_decel_per_sec: float = 2.2
@export var stance: StanceType = StanceType.ACTIVE
@export var stance_scan_interval: float = 0.3
@export var hold_scan_interval: float = 0.25
@export var hold_attack_scan_radius: float = 40.0
@export var retreat_arrive_distance: float = 2.4
@export var archer_attack_interval: float = 1.05
@export var archer_damage_mul: float = 0.92
@export var archer_preferred_range: float = 28.0
@export var archer_hold_min_range: float = 5.2
@export var archer_range_hysteresis: float = 4.5
@export var archer_arrow_line_duration: float = 0.45
@export var archer_arrow_height_offset: float = 1.35
@export var archer_reposition_interval: float = 0.35
@export var archer_line_width_mul: float = 1.55
@export var archer_line_depth_mul: float = 0.55
@export var archer_frontline_enemy_radius_mul: float = 0.55
@export var archer_frontline_self_radius_mul: float = 0.18
@export var archer_arrow_lane_half_width: float = 0.32
@export var archer_arrow_arc_height: float = 0.78
@export var archer_arrow_trail_length_ratio: float = 0.38
@export var archer_arrow_trail_head_alpha: float = 0.96
@export var archer_arrow_trail_tail_alpha: float = 0.16
@export var archer_arrow_burst_base: int = 18
@export var archer_arrow_burst_scale_per_1000: float = 1.6
@export var archer_arrow_burst_max: int = 48
@export var archer_arrow_origin_spread_radius: float = 3.0
@export var archer_arrow_target_spread_radius: float = 10.0
@export var archer_arrow_height_jitter: float = 1.1
@export var archer_arrow_use_anchor_nodes: bool = false
@export var archer_arrow_origin_anchor_path: NodePath = NodePath("ArcherArrowOriginAnchor")
@export var archer_arrow_target_anchor_path: NodePath = NodePath("ArcherArrowTargetAnchor")
@export var archer_arrow_anchor_marker_visible: bool = false
@export_range(0.04, 0.8, 0.01) var archer_arrow_anchor_marker_radius: float = 0.12
@export var archer_relayout_speed_threshold: float = 1.1
@export var archer_offset_noise_depth: float = 0.0
@export var archer_offset_noise_lateral: float = 0.0
@export var archer_refresh_min_interval_sec: float = 0.45
@export var archer_refresh_target_move_threshold: float = 2.4
@export var archer_move_dead_zone: float = 1.2
@export var archer_backstep_cooldown_sec: float = 0.55
@export var strategist_trace_duration: float = 0.66
@export var strategist_trace_length_ratio: float = 0.82
@export var strategist_trace_head_alpha: float = 1.0
@export var strategist_trace_tail_alpha: float = 0.62
@export var strategist_trace_arc_mul: float = 0.42
@export var strategist_trace_width_mul: float = 5.2
@export var strategist_trace_burst_base: int = 1
@export var strategist_trace_burst_scale_per_1000: float = 0.0
@export var strategist_trace_burst_max: int = 1
@export var strategist_blade_face_offset_deg: float = 0.0
@export var strategist_blade_curve_sign: float = 1.0
@export var strategist_blade_tail_white_ratio: float = 0.34
@export var strategist_blade_debug_visible: bool = false
@export var strategist_blade_debug_length: float = 7.5
@export var strategist_cast_vfx_duration: float = 0.24
@export var strategist_impact_vfx_duration: float = 0.32
@export var strategist_impact_delay_mul: float = 0.55

@export var infantry_activity_radius: float = 3.0
@export var cavalry_activity_radius: float = 4.0

@export var max_hp: float = 650.0
@export var skill_form_duration: float = 1.45
@export var archer_skill_form_duration_mul: float = 0.72
@export_range(0.2, 1.0, 0.01) var archer_skill_form_transition_ratio: float = 0.46
@export var archer_skill_recover_transition_sec: float = 0.56
@export var charge_duration: float = 1.45
@export var breakthrough_duration: float = 1.25
@export var sweep_duration: float = 1.35
@export var charge_speed_bonus_damage_scale: float = 0.9
@export var charge_damage_mul: float = 1.16
@export var breakthrough_speed: float = 24.0
@export var sweep_dash_speed: float = 16.5
@export var breakthrough_lance_spacing_mul: float = 0.88
@export var breakthrough_wedge_max_cols: int = 99
@export var breakthrough_windup_backstep_mul: float = 3.0
@export var breakthrough_front_knockback_distance: float = 0.85
@export var breakthrough_side_blast_distance: float = 3.2
@export var breakthrough_split_side_mul: float = 1.55
@export var breakthrough_split_lift_mul: float = 2.1
@export var breakthrough_exec_speed_mul: float = 2.65
@export var sweep_crescent_radius_mul: float = 1.55
@export var sweep_side_distance: float = 10.0
@export var sweep_forward_distance: float = 3.4
@export var breakthrough_distance: float = 13.0
@export var breakthrough_damage_mul: float = 1.05
@export var sweep_damage_mul: float = 1.14
@export var sweep_radius: float = 5.2
@export var sweep_stun_duration: float = 1.6
@export var paralyzed_hit_stop_duration: float = 0.09
@export var paralyzed_vfx_height: float = 2.55
@export var paralyzed_vfx_orbit_radius: float = 0.62
@export var paralyzed_vfx_spin_speed: float = 6.8
@export var paralyzed_status_vfx_enabled: bool = false
@export var burning_vfx_height: float = 1.34
@export var burning_vfx_radius: float = 1.15
@export var burning_vfx_flame_height: float = 0.56
@export var burning_vfx_flame_width: float = 0.2
@export var burning_vfx_ember_rise: float = 1.42
@export var burning_vfx_smoke_height: float = 1.8
@export var sweep_impact_vfx_duration: float = 0.34
@export var sweep_impact_vfx_scale: float = 1.55
@export var sweep_impact_forward_offset: float = 0.42
@export var sweep_impact_front_heavy_alpha: float = 0.34
@export var sweep_impact_back_fade_alpha: float = 0.14
@export var skill_success_vfx_duration: float = 0.44
@export var skill_success_vfx_scale: float = 1.28
@export var skill_success_vfx_height: float = 0.12
@export var skill_success_flash_peak_alpha: float = 0.98
@export var skill_success_particle_spread: float = 0.95
@export var sweep_impact_puff_alpha: float = 0.28
@export var damage_number_duration: float = 0.72
@export var damage_number_rise_height: float = 1.1
@export var effect_visible_near_depth: float = 360.0
@export var effect_visible_mid_depth: float = 680.0
@export var effect_world_scale_mul: float = 4.6
@export var effect_mid_scale_mul: float = 0.76
@export var effect_force_no_depth_test: bool = true
@export var damage_number_pixel_size: float = 0.02
@export var damage_number_font_size: int = 110
@export var damage_number_outline_size: int = 16
@export var tactic_damage_number_scale_mul: float = 1.35
@export var skill_name_duration: float = 0.95
@export var skill_name_rise_height: float = 0.88
@export var skill_name_pixel_size: float = 0.018
@export var skill_name_font_size: int = 92
@export var skill_name_outline_size: int = 14
@export var skill_name_scale_mul: float = 5.0
@export var commander_dialogue_enabled: bool = true
@export var commander_dialogue_duration: float = 2.4
@export var commander_dialogue_min_interval: float = 1.9
@export var commander_dialogue_state_check_interval: float = 0.24
@export var spear_brace_duration: float = 1.45
@export var spear_brace_trigger_range: float = 6.4
@export var spear_brace_damage_mul: float = 1.28
@export var spear_lunge_distance: float = 8.4
@export var spear_lunge_speed_mul: float = 2.25
@export var spear_lunge_lift_mul: float = 2.35
@export var spear_lunge_knockback_distance: float = 1.7
@export var spear_hook_radius: float = 6.0
@export var spear_hook_stun_duration: float = 1.1
@export var spear_throw_range: float = 11.0
@export var spear_throw_damage_mul: float = 1.18
@export var spear_throw_arc_height: float = 3.1
@export var spear_throw_trace_width: float = 0.34
@export var shield_wall_exec_duration: float = 0.82
@export var shield_wall_damage_mul: float = 0.88
@export var shield_wall_trigger_range: float = 0.9
@export var shield_wall_slow_duration: float = 0.9
@export var shield_wall_buff_duration: float = 2.8
@export var shield_wall_buff_defense_mul: float = 1.32
@export var shield_wall_buff_speed_mul: float = 0.8
@export var shield_wall_buff_attack_mul: float = 0.9
@export var shield_wall_absorb_ratio: float = 0.72
@export var shield_wall_guard_absorb_flat: float = 900.0
@export var shield_wall_guard_absorb_hp_mul: float = 1.0
@export var shield_wall_guard_max_duration: float = 5.0
@export var shield_bash_exec_duration: float = 0.86
@export var shield_bash_speed_mul: float = 1.46
@export var shield_bash_damage_mul: float = 1.26
@export var shield_bash_trigger_range: float = 0.72
@export var shield_bash_knockback_distance: float = 1.2
@export var shield_bash_stun_duration: float = 0.75
@export var shield_bash_slow_duration: float = 1.2
@export var shield_tortoise_exec_duration: float = 1.02
@export var shield_tortoise_radius: float = 6.0
@export var shield_tortoise_damage_mul: float = 0.82
@export var shield_tortoise_slow_duration: float = 1.25
@export var shield_tortoise_taunt_duration: float = 2.8
@export var shield_tortoise_buff_duration: float = 4.6
@export var shield_tortoise_buff_defense_mul: float = 1.45
@export var shield_tortoise_buff_speed_mul: float = 0.68
@export var shield_tortoise_buff_attack_mul: float = 0.82
@export var shield_tortoise_guard_max_duration: float = 8.0
@export var impact_launch_duration: float = 0.62
@export var impact_launch_height: float = 4.6
@export var impact_launch_forward_drift: float = 0.96
@export var impact_launch_peak_hold_ratio: float = 0.16
@export var impact_launch_landing_dust_scale: float = 1.18
@export var tactic_crit_enabled: bool = true
@export var tactic_crit_chance: float = 0.22
@export var tactic_crit_damage_mul: float = 1.55
@export var auto_charge_on_contact: bool = true
@export var auto_charge_cooldown_sec: float = 8.0
@export var auto_charge_contact_extra_range: float = 0.22
@export var auto_skill_recent_damage_window_sec: float = 3.0
@export var use_model_mesh: bool = true
@export var use_proxy_soldier_mesh_when_low_perf: bool = true
@export_range(8, 48, 1) var proxy_soldier_radial_segments: int = 32
@export var proxy_soldier_scale_mul: float = 1.0
@export var commander_mount_enabled: bool = true
@export_file("*.glb", "*.gltf", "*.scn", "*.tscn") var commander_mount_model_source_path: String = DEFAULT_CAVALRY_MODEL_SOURCE_PATH
@export var commander_mount_scale_mul: float = 1.35
@export var commander_mount_target_height: float = 2.3
@export var commander_mount_local_offset: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var commander_mount_place_in_front: bool = true
@export_range(0.0, 2.0, 0.05) var commander_mount_front_factor: float = 0.95
@export var commander_mount_front_extra: float = 0.55
@export var commander_mount_forward_yaw_degrees: float = 180.0
@export var commander_mount_visible_near_depth: float = 2400.0
@export var commander_mount_hide_when_soldiers_hidden: bool = true
@export var infantry_model_scale_mul: float = 0.72
@export var cavalry_model_scale_mul: float = 1.0
@export var soldier_cast_shadow: bool = false
@export var use_model_albedo_texture: bool = true
@export var team_tint_strength: float = 0.35
@export_file("*.glb", "*.gltf", "*.scn", "*.tscn") var override_model_source_path: String = ""
@export_file("*.png", "*.jpg", "*.jpeg", "*.webp", "*.exr") var override_albedo_texture_path: String = ""
@export var unit_type_label_override: String = ""
@export var combat_role_id: String = "infantry"
@export var infantry_sway_mul: float = 0.3
@export var cavalry_sway_mul: float = 1.0
@export var archer_use_idle_gpu_anim_in_combat: bool = true
@export_range(0.0, 1.2, 0.01) var archer_gpu_sway_mul: float = 0.08
@export_range(0.2, 1.5, 0.01) var archer_idle_cycle_mul: float = 0.48
@export var archer_use_idle_gpu_anim_while_moving: bool = true
@export_range(0.0, 1.2, 0.01) var archer_gpu_sway_mul_move: float = 0.0
@export_range(0.0, 1.2, 0.01) var archer_gpu_sway_mul_attack: float = 0.0
@export var archer_skill_volley_damage_mul: float = 1.34
@export var archer_skill_fire_arrow_burn_duration: float = 2.4
@export var archer_skill_fire_arrow_burn_dps: float = 3.4
@export var archer_skill_volley_slow_duration: float = 0.75
@export var archer_skill_pierce_damage_mul: float = 1.22
@export var archer_skill_pierce_depth: float = 14.0
@export var archer_skill_pierce_width: float = 3.4
@export_range(1, 6, 1) var archer_skill_pierce_cover_units: int = 3
@export var archer_skill_barrage_damage_mul: float = 1.08
@export var archer_skill_barrage_radius: float = 6.2
@export var archer_skill_barrage_slow_duration: float = 0.9
@export var crossbow_skill_volley_damage_mul: float = 1.5
@export var crossbow_skill_volley_slow_duration: float = 1.12
@export var crossbow_skill_volley_paralyze_duration: float = 0.36
@export var crossbow_skill_pierce_damage_mul: float = 1.32
@export var crossbow_skill_pierce_depth: float = 20.0
@export var crossbow_skill_pierce_width: float = 2.7
@export_range(1, 8, 1) var crossbow_skill_pierce_cover_units: int = 4
@export var crossbow_skill_pierce_slow_duration: float = 0.88
@export var crossbow_skill_pierce_paralyze_duration: float = 0.24
@export var crossbow_skill_barrage_damage_mul: float = 1.12
@export var crossbow_skill_barrage_radius: float = 5.4
@export var crossbow_skill_barrage_slow_duration: float = 1.2
@export var crossbow_skill_barrage_paralyze_duration: float = 0.22
@export var archer_skill_yan_width_mul: float = 1.18
@export var archer_skill_yan_depth_mul: float = 1.05
@export var archer_skill_yan_wing_mul: float = 0.82
@export_range(0.2, 1.5, 0.01) var archer_move_cycle_mul: float = 0.52
@export var archer_move_facing_smooth: bool = true
@export var archer_move_facing_lerp_speed: float = 10.0
@export var archer_move_facing_min_angle_deg: float = 1.4
@export var unit_turn_rate_deg: float = 240.0
@export var chase_reengage_lock_sec: float = 0.55
@export var zoc_front_dot_threshold: float = -0.05
@export var melee_max_per_row: int = 14
@export var melee_front_anchor_ratio: float = 0.5
@export var melee_contact_front_ratio: float = 0.74
@export var melee_front_gap: float = 1.45
@export var melee_boundary_gap: float = 0.5
@export var infantry_melee_row_spacing: float = 0.9
@export var cavalry_melee_row_spacing: float = 1.2
@export var infantry_melee_lateral_spacing: float = 1.25
@export var cavalry_melee_lateral_spacing: float = 1.9
@export var melee_side_spread: float = 0.12
@export var melee_reposition_interval: float = 0.2
@export var melee_overclose_ratio: float = 0.86
@export var melee_leave_distance_mul: float = 1.6
@export var melee_leave_grace_sec: float = 0.32
@export_range(0.5, 3.0, 0.05) var melee_frontline_width_mul: float = 1.0
@export_range(0.4, 2.5, 0.05) var melee_frontline_depth_mul: float = 1.0
@export_range(0.7, 2.5, 0.05) var melee_contact_distance_mul: float = 1.0
@export_range(0.0, 8.0, 0.1) var melee_contact_distance_bias: float = 0.0
@export var simple_rts_keep_home_formation: bool = true
@export var melee_center_distance_rows_total: float = 4.0
@export var melee_center_distance_tolerance: float = 0.28
@export var melee_fixed_center_attack_distance: float = 4.0
@export var ranged_fixed_center_attack_distance: float = 10.0
@export var melee_slot_lateral_clamp_mul: float = 1.15
@export var melee_slot_follow_speed_mul: float = 0.88
@export_range(0.5, 3.0, 0.05) var activity_radius_mul: float = 1.0
@export_range(0.0, 1.0, 0.05) var activity_radius_visual_weight: float = 0.65
@export var formation_dim_10_min_troops: int = 10000
@export var formation_dim_9_min_troops: int = 8000
@export var formation_dim_8_min_troops: int = 6000
@export var formation_dim_7_min_troops: int = 4500
@export var formation_dim_6_min_troops: int = 3000
@export var formation_dim_5_min_troops: int = 1800
@export var line_rows_for_dim_4: int = 2
@export var line_rows_for_dim_5: int = 2
@export var line_rows_for_dim_6: int = 3
@export var line_rows_for_dim_7: int = 3
@export var line_rows_for_dim_8: int = 4
@export var line_rows_for_dim_9: int = 4
@export var line_rows_for_dim_10: int = 5
@export var normal_formation_follow_speed: float = 9.0
@export var skill_form_start_speed: float = 3.2
@export var skill_form_end_speed: float = 11.0
@export_range(0.0, 0.95, 0.01) var charge_windup_backstep_start_ratio: float = 0.34
@export_range(0.05, 1.0, 0.01) var charge_windup_backstep_end_ratio: float = 0.86
@export_range(0.05, 1.0, 0.01) var charge_skill_form_transition_ratio: float = 0.42
@export var model_forward_yaw_degrees: float = 180.0

# Commander setup: 1 main + 2 vice (vice weights are equal)
@export var main_commander_name: String = "\u4e3b\u5e05"
@export var vice_commander_1_name: String = "\u526f\u5c06\u4e00"
@export var vice_commander_2_name: String = "\u526f\u5c06\u4e8c"
@export var main_leadership: int = 70
@export var main_might: int = 70
@export var main_intelligence: int = 70
@export var main_politics: int = 70
@export var main_charm: int = 70
@export var vice_1_leadership: int = 65
@export var vice_1_might: int = 65
@export var vice_1_intelligence: int = 65
@export var vice_1_politics: int = 65
@export var vice_1_charm: int = 65
@export var vice_2_leadership: int = 65
@export var vice_2_might: int = 65
@export var vice_2_intelligence: int = 65
@export var vice_2_politics: int = 65
@export var vice_2_charm: int = 65
@export var main_unit_aptitude: AptitudeGrade = AptitudeGrade.A
@export var vice_1_unit_aptitude: AptitudeGrade = AptitudeGrade.B
@export var vice_2_unit_aptitude: AptitudeGrade = AptitudeGrade.B
@export var main_battle_personality: String = ""
@export var vice_1_battle_personality: String = ""
@export var vice_2_battle_personality: String = ""
@export var main_battle_personality_trait_id: String = ""
@export var vice_1_battle_personality_trait_id: String = ""
@export var vice_2_battle_personality_trait_id: String = ""
@export var main_battle_personality_level: int = 0
@export var vice_1_battle_personality_level: int = 0
@export var vice_2_battle_personality_level: int = 0

# Morale and spirit rules
@export var morale_cap_base: float = 100.0
@export var morale_training_value: float = 80.0
@export var tech_morale_cap_bonus: float = 0.0
@export var spirit_cap_base: float = 100.0
@export var tech_spirit_cap_bonus: float = 0.0
@export var spirit_base_outbound: float = 18.0
@export var spirit_outbound_politics_mul: float = 0.55
@export var spirit_outbound_high_politics_mul: float = 0.25
@export var spirit_recover_base_per_sec: float = 0.8
@export var spirit_recover_politics_per_sec: float = 0.012
@export var spirit_recover_morale_factor: float = 0.7
@export var spirit_recover_move_mul: float = 0.88
@export var spirit_recover_melee_mul: float = 0.58
@export var spirit_recover_skill_mul: float = 0.45
@export var is_city_garrison: bool = false
@export var garrison_morale_loss_mul: float = 0.5
@export var morale_loss_per_10pct_troop: float = 10.0
@export var morale_stat_penalty_per_10: float = 0.05
@export var morale_stat_mul_min: float = 0.35
@export var morale_zero_hp_loss_per_sec: float = 0.02
@export var rout_troop_ratio_normal: float = 0.2
@export var rout_troop_ratio_garrison: float = 0.1
@export var morale_loss_countered_bonus: float = 3.0
@export var morale_loss_flanked_bonus: float = 4.0
@export var morale_loss_duel_lost: float = 14.0
@export var morale_loss_vice_down: float = 12.0
@export var morale_loss_main_down: float = 100.0
@export var status_countered_duration: float = 3.0
@export var flanked_dot_threshold: float = -0.2
@export var high_morale_threshold: float = 80.0
@export var morale_loss_out_of_supply_per_sec: float = 2.2
@export var morale_loss_special_terrain_per_sec: float = 1.2
@export var morale_loss_burning_per_sec: float = 1.0
@export var status_supply_normal_attack_mul: float = 1.04
@export var status_supply_normal_defense_mul: float = 1.04
@export var status_supply_normal_speed_mul: float = 1.02
@export var status_high_morale_attack_mul: float = 1.08
@export var status_high_morale_defense_mul: float = 1.08
@export var status_high_morale_speed_mul: float = 1.04
@export var status_tactic_buff_attack_mul: float = 1.12
@export var status_tactic_buff_defense_mul: float = 1.06
@export var status_tactic_buff_speed_mul: float = 1.02
@export var status_facility_attack_aura_mul: float = 1.12
@export var status_personality_buff_attack_mul: float = 1.06
@export var status_personality_buff_defense_mul: float = 1.04
@export var status_personality_buff_speed_mul: float = 1.04
@export var status_terrain_advantage_attack_mul: float = 1.06
@export var status_terrain_advantage_defense_mul: float = 1.1
@export var status_terrain_advantage_speed_mul: float = 1.05
@export var status_out_of_supply_attack_mul: float = 0.7
@export var status_out_of_supply_defense_mul: float = 0.72
@export var status_out_of_supply_speed_mul: float = 0.7
@export var status_countered_attack_mul: float = 0.9
@export var status_countered_defense_mul: float = 0.9
@export var status_countered_speed_mul: float = 0.94
@export var status_confusion_attack_mul: float = 0.78
@export var status_confusion_defense_mul: float = 0.85
@export var status_confusion_speed_mul: float = 0.82
@export var status_misinformation_attack_mul: float = 0.84
@export var status_misinformation_defense_mul: float = 0.9
@export var status_misinformation_speed_mul: float = 0.9
@export var status_burning_attack_mul: float = 0.92
@export var status_burning_defense_mul: float = 0.9
@export var status_burning_speed_mul: float = 0.9
@export var status_slowed_speed_mul: float = 0.65
@export var status_paralyzed_attack_mul: float = 0.0
@export var status_paralyzed_defense_mul: float = 0.78
@export var status_paralyzed_speed_mul: float = 0.0
@export var status_terrain_disadvantage_attack_mul: float = 0.9
@export var status_terrain_disadvantage_defense_mul: float = 0.88
@export var status_terrain_disadvantage_speed_mul: float = 0.9

# Personality / famous / tech bonuses
@export var personality_attack_bonus_pct: float = 0.0
@export var personality_defense_bonus_pct: float = 0.0
@export var personality_speed_bonus_pct: float = 0.0
@export var personality_spirit_bonus_flat: float = 0.0
@export var personality_event_framework_enabled: bool = true
@export var personality_event_light_mode: bool = true
@export_range(0.0, 0.25, 0.01) var personality_event_light_tick_interval_sec: float = 0.0
@export_range(1, 16, 1) var personality_event_trigger_budget_per_frame: int = 6
@export_range(1, 8, 1) var personality_event_force_trigger_after_blocked_count: int = 2
@export var personality_event_debug_stats_enabled: bool = true
@export var personality_event_counter_chain_enabled: bool = true
@export_range(0.0, 1.0, 0.01) var personality_event_counter_immunity_base_chance: float = 0.07
@export_range(0.0, 1.0, 0.01) var personality_event_counter_immunity_control_resist_weight: float = 0.32
@export_range(0.0, 0.02, 0.0005) var personality_event_counter_immunity_int_weight: float = 0.002
@export_range(0.0, 1.0, 0.01) var personality_event_counter_suppression_base_chance: float = 0.05
@export_range(0.0, 1.0, 0.01) var personality_event_counter_suppression_lv1_bonus: float = 0.06
@export_range(0.0, 1.0, 0.01) var personality_event_counter_suppression_lv2_bonus: float = 0.12
@export_range(0.1, 1.0, 0.01) var personality_event_counter_forced_duration_mul: float = 0.62
@export var personality_event_counter_dispel_on_block: bool = true
@export_range(0.0, 1.0, 0.01) var personality_event_counter_dispel_chance_on_block: float = 0.35
@export var famous_skill_name: String = ""
@export var famous_skill_desc: String = ""
@export var famous_extra_tactic_slots: int = 0
@export var tech_attack_bonus_pct: float = 0.0
@export var tech_defense_bonus_pct: float = 0.0
@export var tech_speed_bonus_pct: float = 0.0
@export var tech_magic_attack_bonus_pct: float = 0.0
@export var tech_magic_defense_bonus_pct: float = 0.0
@export var tech_range_bonus_flat: float = 0.0
@export var tech_spirit_cost_reduction_pct: float = 0.0
var tech_traits_runtime: Array = []
var tech_effect_cumulative_runtime: Dictionary = {}
@export var skill_cost_charge: float = 10.0
@export var skill_cost_breakthrough: float = 14.0
@export var skill_cost_sweep: float = 20.0
@export var shield_skill_cost_charge: float = 10.0
@export var shield_skill_cost_breakthrough: float = 15.0
@export var shield_skill_cost_sweep: float = 20.0
@export var skill_cd_charge: float = 10.0
@export var skill_cd_breakthrough: float = 14.0
@export var skill_cd_sweep: float = 12.0

var battlefield: Node = null
var hp: float = 0.0
var dead: bool = false
var naval_embarked: bool = false
var naval_ship_type: String = ""
var naval_preferred_ship_type: String = ""
var burn_time_left: float = 0.0
var burn_dps: float = 0.0
var burn_source_team: int = -1
var morale_current: float = 0.0
var spirit_current: float = 0.0
var spirit_cap_current: float = 100.0
var spirit_recover_per_sec: float = 0.0
var profile_cache: Dictionary = {}
var tactic_slots: int = 0
var unlocked_tactics: Array[String] = []
var skill_cooldowns: Dictionary = {}
var timed_statuses: Dictionary = {}
var main_commander_down: bool = false
var vice_1_down: bool = false
var vice_2_down: bool = false
var last_out_of_supply_tick: float = 0.0

var state: UnitState = UnitState.IDLE
var state_time: float = 0.0
var command_mode: CommandMode = CommandMode.NONE
var hold_anchor_position: Vector3 = Vector3.ZERO
var retreat_destination: Vector3 = Vector3.INF
var stance_scan_timer: float = 0.0
var hold_scan_timer: float = 0.0

var has_move_target: bool = false
var move_target: Vector3 = Vector3.ZERO
var move_velocity: Vector3 = Vector3.ZERO
var downhill_speed_bonus_current: float = 0.0
var desired_facing: Vector3 = Vector3.FORWARD
var motion_dir: Vector3 = Vector3.FORWARD
var detour_goal: Vector3 = Vector3.INF
var detour_time_left: float = 0.0
var reengage_time_left: float = 0.0
var path_points: PackedVector3Array = PackedVector3Array()
var path_index: int = 0
var nav_mode: NavMode = NavMode.NONE
var attack_move_active: bool = false
var attack_move_goal: Vector3 = Vector3.ZERO
var attack_move_scan_timer: float = 0.0
var chase_target_unit: UnitController = null
var chase_fallback_point: Vector3 = Vector3.ZERO
var chase_origin_point: Vector3 = Vector3.ZERO
var chase_last_goal_point: Vector3 = Vector3.ZERO
var chase_slot_offset: Vector3 = Vector3.ZERO
var chase_use_slot_follow: bool = false
var chase_repath_timer: float = 0.0
var chase_updates_paused: bool = false
var chase_dynamic_repath: bool = false
var player_force_chase_active: bool = false
var player_force_chase_timer: float = 0.0
var nav_request_serial: int = 0
var nav_pending_request_id: int = 0
var command_serial: int = 0
var nav_pending_command_serial: int = 0
var nav_query_pending: bool = false
var nav_query_pending_timer: float = 0.0
var blocked_move_timer: float = 0.0
var blocked_repath_cd: float = 0.0
var corridor_mode: PathCorridorMode = PathCorridorMode.NORMAL
var corridor_min_width: float = INF
var corridor_entry_index: int = -1
var corridor_exit_index: int = -1
var queue_mode_active: bool = false
var queue_trail_points: Array[Vector3] = []
var queue_trail_total_len: float = 0.0
var parent_nav_snap_timer: float = 0.0
var staged_move_targets: Array[Vector3] = []

var target_unit: UnitController = null
var manual_priority_target_unit: UnitController = null
var attack_timer: float = 0.0
var archer_skill_fire_lock_timer: float = 0.0
var melee_refresh_timer: float = 0.0
var melee_leave_timer: float = 0.0
var melee_lock_target_id: int = 0
var melee_lock_lateral_offset: float = 0.0
var melee_lock_ready: bool = false

var skill_type: SkillType = SkillType.NONE
var skill_target: UnitController = null
var skill_timer: float = 0.0
var charge_goal: Vector3 = Vector3.ZERO
var charge_hit_timer: float = 0.0
var charge_form_origin: Vector3 = Vector3.ZERO
var charge_form_duration_ref: float = 0.0
var allow_overlap: bool = false
var auto_charge_cooldown_timer: float = 0.0
var skill_exec_speed_ref: float = 0.0
var pierce_active: bool = false
var pierce_ignore_target_id: int = 0
var pierce_path_start: Vector3 = Vector3.ZERO
var pierce_path_end: Vector3 = Vector3.ZERO
var pierce_path_forward: Vector3 = Vector3.FORWARD
var pierce_can_pass_through: bool = true
var pierce_hit_applied: bool = false
var skill_return_pending: bool = false
var skill_return_resume_target: UnitController = null
var skill_return_face_dir: Vector3 = Vector3.FORWARD
var shield_skill_buff_timer: float = 0.0
var shield_skill_defense_mul: float = 1.0
var shield_skill_speed_mul: float = 1.0
var shield_skill_attack_mul: float = 1.0
var shield_skill_absorb_pool: float = 0.0
var shield_skill_force_end_timer: float = 0.0
var taunt_source_unit: UnitController = null
var taunt_timer: float = 0.0
var auto_skill_recent_damage: float = 0.0
var auto_skill_recent_damage_timer: float = 0.0
var personality_event_attack_bonus_kill_pct: float = 0.0
var personality_event_attack_bonus_kill_left: float = 0.0
var personality_event_speed_bonus_kill_pct: float = 0.0
var personality_event_speed_bonus_kill_left: float = 0.0
var personality_event_ignore_defense_pct_runtime: float = 0.0
var personality_event_ignore_defense_left: float = 0.0
var personality_event_doujiang_stack_count: int = 0
var personality_event_doujiang_stack_left: float = 0.0
var personality_event_doujiang_defense_bonus_pct: float = 0.0
var personality_event_doujiang_defense_bonus_left: float = 0.0
var personality_event_bawang_attack_bonus_pct: float = 0.0
var personality_event_bawang_control_resist_pct: float = 0.0
var personality_event_bawang_active_left: float = 0.0
var personality_event_bawang_first_engage_consumed: bool = false
var personality_event_bawang_kill_reward_cd_left: float = 0.0
var personality_event_longdan_attack_bonus_pct: float = 0.0
var personality_event_longdan_attack_bonus_left: float = 0.0
var personality_event_longdan_defense_bonus_pct: float = 0.0
var personality_event_longdan_defense_bonus_left: float = 0.0
var personality_event_quanbian_defense_bonus_pct: float = 0.0
var personality_event_quanbian_defense_bonus_left: float = 0.0
var personality_event_shenwei_control_resist_pct: float = 0.0
var personality_event_shenwei_control_resist_left: float = 0.0
var personality_event_rendun_speed_bonus_pct: float = 0.0
var personality_event_rendun_speed_bonus_left: float = 0.0
var personality_event_rendun_ignore_zoc_left: float = 0.0
var personality_event_internal_cd: Dictionary = {}
var personality_event_blocked_counter: Dictionary = {}
var personality_event_trigger_budget_left: int = 0
var personality_event_debug_trigger_total: int = 0
var personality_event_debug_blocked_total: int = 0
var personality_event_debug_forced_total: int = 0
var personality_event_debug_trigger_by_key: Dictionary = {}
var personality_event_debug_blocked_by_key: Dictionary = {}
var personality_event_debug_forced_by_key: Dictionary = {}
var personality_event_attack_bonus_pct_runtime: float = 0.0
var personality_event_defense_bonus_pct_runtime: float = 0.0
var personality_event_speed_bonus_pct_runtime: float = 0.0
var pierce_preview_node: MeshInstance3D = null
var unit_collision_body: StaticBody3D = null
var unit_collision_shape_node: CollisionShape3D = null
var unit_collision_box_shape: BoxShape3D = null

var pending_displacement: Vector3 = Vector3.ZERO

var soldiers_mmi: MultiMeshInstance3D
var soldiers_mm: MultiMesh

var home_offsets: Array[Vector3] = []
var desired_offsets: Array[Vector3] = []
var current_offsets: Array[Vector3] = []
var skill_offsets: Array[Vector3] = []
var seeds: Array[float] = []
var visual_time: float = 0.0
var soldier_visual_scale: float = 1.0
var soldier_yaw_offset: float = 0.0
var soldier_mesh_basis: Basis = Basis.IDENTITY
var frame_motion_dir: Vector3 = Vector3.ZERO
var attack_dir_local: Vector3 = Vector3.FORWARD
var soldier_anim_material: ShaderMaterial = null
var seeds_uploaded: bool = false
var soldier_render_enabled: bool = true
var commander_mount_root: Node3D = null
var commander_mount_mesh_node: MeshInstance3D = null
var commander_mount_mesh_basis: Basis = Basis.IDENTITY
var commander_mount_scale_runtime: float = 1.0
var commander_mount_signature: String = ""

var transition_active: bool = false
var transition_from: Array[Vector3] = []
var transition_to: Array[Vector3] = []
var transition_duration: float = 0.0
var transition_elapsed: float = 0.0
var transition_avoid_enemy_overlap: bool = false
var transition_restore_home_lock: bool = false
var formation_transition_min_interval_sec: float = 0.14
var formation_transition_cooldown_timer: float = 0.0
var role_profile_runtime_applied: bool = false
@onready var vfx_root: Node3D = get_node_or_null("VfxRoot") as Node3D
var skill_vfx_instance: Node = null
var skill_success_vfx_instance: Node = null

var skill_vfx_node: MeshInstance3D = null
var skill_vfx_material: StandardMaterial3D = null
var skill_vfx_timer: float = 0.0
var skill_vfx_duration: float = 0.0
var skill_vfx_color: Color = Color(1.0, 0.8, 0.2, 0.8)
var skill_vfx_skill: int = SkillType.NONE
var skill_vfx_executing: bool = false
var status_vfx_root: Node3D = null
var paralyzed_ring_node: MeshInstance3D = null
var paralyzed_ring_material: StandardMaterial3D = null
var paralyzed_star_nodes: Array[MeshInstance3D] = []
var paralyzed_star_materials: Array[StandardMaterial3D] = []
var burning_vfx_root: Node3D = null
var burning_aura_node: MeshInstance3D = null
var burning_aura_material: StandardMaterial3D = null
var burning_flame_nodes: Array[MeshInstance3D] = []
var burning_flame_materials: Array[StandardMaterial3D] = []
var burning_ember_nodes: Array[MeshInstance3D] = []
var burning_ember_materials: Array[StandardMaterial3D] = []
var burning_smoke_nodes: Array[MeshInstance3D] = []
var burning_smoke_materials: Array[StandardMaterial3D] = []
var paralyzed_vfx_timer: float = 0.0
var paralyzed_vfx_total: float = 0.0
var status_hit_stop_timer: float = 0.0
var sweep_impact_vfx_root: Node3D = null
var sweep_impact_ring_node: MeshInstance3D = null
var sweep_impact_ring_material: StandardMaterial3D = null
var sweep_impact_disc_node: MeshInstance3D = null
var sweep_impact_disc_material: StandardMaterial3D = null
var sweep_impact_vfx_timer: float = 0.0
var sweep_impact_vfx_total: float = 0.0
var sweep_impact_triggered: bool = false
var sweep_impact_forward_dir: Vector3 = Vector3.FORWARD
var skill_success_vfx_root: Node3D = null
var skill_success_ring_node: MeshInstance3D = null
var skill_success_ring_material: StandardMaterial3D = null
var skill_success_core_node: MeshInstance3D = null
var skill_success_core_material: StandardMaterial3D = null
var skill_success_beam_a: MeshInstance3D = null
var skill_success_beam_b: MeshInstance3D = null
var skill_success_beam_material_a: StandardMaterial3D = null
var skill_success_beam_material_b: StandardMaterial3D = null
var skill_success_vfx_timer: float = 0.0
var skill_success_vfx_total: float = 0.0
var skill_success_triggered: bool = false
var skill_success_flash_node: MeshInstance3D = null
var skill_success_flash_material: StandardMaterial3D = null
var skill_success_particle_nodes: Array[MeshInstance3D] = []
var skill_success_particle_materials: Array[StandardMaterial3D] = []
var sweep_impact_puff_nodes: Array[MeshInstance3D] = []
var sweep_impact_puff_materials: Array[StandardMaterial3D] = []
var damage_number_root: Node3D = null
var damage_number_labels: Array[Label3D] = []
var damage_number_timers: Array[float] = []
var damage_number_origins: Array[Vector3] = []
var damage_number_scale_bases: Array[float] = []
var damage_number_emphasis: Array[bool] = []
var skill_name_root: Node3D = null
var skill_name_label: Label3D = null
var skill_name_timer: float = 0.0
var skill_name_origin: Vector3 = Vector3.ZERO
var skill_name_scale_base: float = 0.0
var commander_dialogue_timer: float = 0.0
var commander_dialogue_total: float = 0.0
var commander_dialogue_text: String = ""
var commander_dialogue_priority: int = 0
var commander_dialogue_global_cooldown: float = 0.0
var commander_dialogue_poll_timer: float = 0.0
var commander_dialogue_key_cooldowns: Dictionary = {}
var commander_dialogue_last_line_by_event: Dictionary = {}
var commander_dialogue_prev_state: int = -1
var commander_dialogue_prev_out_of_supply: bool = false
var commander_dialogue_prev_burning: bool = false
var commander_dialogue_prev_morale_low: bool = false
var commander_dialogue_prev_morale_collapse: bool = false
var defeat_report_dispatched: bool = false
var archer_arrow_origin_anchor: Node3D = null
var archer_arrow_target_anchor: Node3D = null
var archer_arrow_anchor_marker_root: Node3D = null
var archer_arrow_origin_marker: MeshInstance3D = null
var archer_arrow_target_marker: MeshInstance3D = null
var archer_arrow_trails: Array[Dictionary] = []
var projectile_trace_vfx: Node3D = null
var strategist_cast_vfx_root: Node3D = null
var strategist_cast_ring_node: MeshInstance3D = null
var strategist_cast_ring_material: StandardMaterial3D = null
var strategist_cast_core_node: MeshInstance3D = null
var strategist_cast_core_material: StandardMaterial3D = null
var strategist_cast_sigil_node: MeshInstance3D = null
var strategist_cast_sigil_material: StandardMaterial3D = null
var strategist_cast_spark_emitter: GPUParticles3D = null
var strategist_cast_spark_material: StandardMaterial3D = null
var strategist_cast_spark_process: ParticleProcessMaterial = null
var strategist_impact_vfx_root: Node3D = null
var strategist_impact_ring_node: MeshInstance3D = null
var strategist_impact_ring_material: StandardMaterial3D = null
var strategist_impact_core_node: MeshInstance3D = null
var strategist_impact_core_material: StandardMaterial3D = null
var strategist_impact_flash_node: MeshInstance3D = null
var strategist_impact_flash_material: StandardMaterial3D = null
var strategist_impact_spark_emitter: GPUParticles3D = null
var strategist_impact_spark_material: StandardMaterial3D = null
var strategist_impact_spark_process: ParticleProcessMaterial = null
var strategist_cast_timer: float = 0.0
var strategist_cast_total: float = 0.0
var strategist_impact_timer: float = 0.0
var strategist_impact_total: float = 0.0
var strategist_pending_impacts: Array[Dictionary] = []
var strategist_blade_debug_node: MeshInstance3D = null
var strategist_blade_debug_mesh: ImmediateMesh = null
var strategist_blade_debug_material: StandardMaterial3D = null
var charge_split_reaction_timer: float = 0.0
var charge_split_reaction_total: float = 0.0
var charge_split_reaction_side_local: Vector3 = Vector3.RIGHT
var charge_split_reaction_forward_local: Vector3 = Vector3.FORWARD
var charge_split_reaction_lift_mul: float = 1.0
var charge_split_reaction_back_mul: float = 1.0
var charge_split_reaction_side_mul: float = 1.0
var impact_launch_timer: float = 0.0
var impact_launch_total: float = 0.0
var impact_launch_height_current: float = 0.0
var impact_launch_forward_local: Vector3 = Vector3.FORWARD
var impact_launch_landing_triggered: bool = false
var ground_snap_timer: float = 0.0
var ground_target_height: float = 0.0
var ground_target_pitch_deg: float = 0.0
var ground_target_roll_deg: float = 0.0
var ground_pitch_deg_current: float = 0.0
var ground_roll_deg_current: float = 0.0

func _ready() -> void:
	_ensure_navigation_async_mode()
	hp = max_hp
	downhill_speed_bonus_current = 0.0
	command_mode = CommandMode.NONE
	hold_anchor_position = global_position
	retreat_destination = Vector3.INF
	stance_scan_timer = 0.0
	hold_scan_timer = 0.0
	timed_statuses.clear()
	shield_skill_buff_timer = 0.0
	shield_skill_defense_mul = 1.0
	shield_skill_speed_mul = 1.0
	shield_skill_attack_mul = 1.0
	shield_skill_absorb_pool = 0.0
	shield_skill_force_end_timer = 0.0
	taunt_source_unit = null
	taunt_timer = 0.0
	auto_skill_recent_damage = 0.0
	auto_skill_recent_damage_timer = 0.0
	_clear_personality_event_runtime_state()
	_reset_personality_event_frame_budget()
	main_commander_down = false
	vice_1_down = false
	vice_2_down = false
	_rebuild_unit_profile()
	_refresh_auto_statuses()
	_build_status_vfx()
	_build_sweep_impact_vfx()
	_build_damage_numbers()
	_build_skill_name_popup()
	_build_pierce_preview()
	_build_archer_arrow_trace()
	if _is_strategist_role():
		_build_strategist_attack_vfx()
	_setup_archer_arrow_anchor_nodes()
	_ensure_unit_collision_proxy()
	_build_multimesh_visual()
	_rebuild_commander_mount_visual()
	_initialize_soldier_offsets()
	_sync_visible_soldier_count()
	_apply_offsets_immediate(home_offsets, false)
	_refresh_commander_mount_visibility()
	commander_dialogue_key_cooldowns.clear()
	commander_dialogue_last_line_by_event.clear()
	commander_dialogue_global_cooldown = 0.0
	commander_dialogue_poll_timer = 0.0
	defeat_report_dispatched = false
	_update_gpu_anim_state()
	_commander_dialogue_sync_state_snapshot()
	role_profile_runtime_applied = false
	ground_target_height = global_position.y
	_update_ground_alignment(0.0, true)
	_update_unit_collision_proxy()
	motion_dir = get_collision_forward_flat()

func _physics_process(delta: float) -> void:
	if dead:
		return

	_reset_personality_event_frame_budget()
	_ensure_runtime_role_profile_applied()
	var prev_pos: Vector3 = global_position
	visual_time += delta
	state_time += delta
	archer_skill_fire_lock_timer = maxf(0.0, archer_skill_fire_lock_timer - delta)
	auto_charge_cooldown_timer = maxf(0.0, auto_charge_cooldown_timer - delta)
	if auto_skill_recent_damage_timer > 0.0:
		auto_skill_recent_damage_timer = maxf(0.0, auto_skill_recent_damage_timer - delta)
		if auto_skill_recent_damage_timer <= 0.001:
			auto_skill_recent_damage = 0.0
	_tick_shield_skill_effects(delta)
	_tick_taunt(delta)
	detour_time_left = maxf(0.0, detour_time_left - delta)
	if detour_time_left <= 0.0:
		detour_goal = Vector3.INF
	reengage_time_left = maxf(0.0, reengage_time_left - delta)
	if player_force_chase_active:
		if player_command_force_chase_never_timeout:
			player_force_chase_timer = maxf(player_force_chase_timer, player_command_force_chase_sec)
		else:
			player_force_chase_timer = maxf(0.0, player_force_chase_timer - delta)
			if player_force_chase_timer <= 0.0:
				player_force_chase_active = false
	_tick_skill_cooldowns(delta)
	_tick_personality_event_effects(delta)
	_tick_timed_statuses(delta)
	_refresh_auto_statuses()
	_tick_status_morale_pressure(delta)
	_update_burn(delta)
	_tick_morale_zero_attrition(delta)
	_check_pierce_interrupts()
	_update_spirit_recovery(delta)
	_update_skill_vfx(delta)
	_update_status_vfx(delta)
	_update_sweep_impact_vfx(delta)
	_update_strategist_attack_vfx(delta)
	_update_strategist_blade_debug_marker()
	_update_skill_success_vfx(delta)
	_update_damage_numbers(delta)
	_update_skill_name_popup(delta)
	_update_commander_dialogue_popup(delta)
	if status_hit_stop_timer > 0.0:
		status_hit_stop_timer = maxf(0.0, status_hit_stop_timer - delta)
		delta = 0.0
	_tick_commander_dialogue_state(delta)
	formation_transition_cooldown_timer = maxf(0.0, formation_transition_cooldown_timer - delta)
	_apply_pending_displacement()
	if battlefield != null and battlefield.has_method("sync_unit_naval_state"):
		battlefield.call("sync_unit_naval_state", self)
	_enforce_walkable_position()
	_tick_nav_query_timeout(delta)
	blocked_repath_cd = maxf(0.0, blocked_repath_cd - delta)
	_update_state(delta)
	_enforce_walkable_position()
	_process_staged_transition(delta)
	_update_queue_render_offsets()
	_update_charge_split_reaction_visual(delta)
	_update_impact_launch_visual(delta)
	_tick_parent_nav_snap(delta)
	_update_ground_alignment(delta)
	var frame_delta: Vector3 = global_position - prev_pos
	frame_delta.y = 0.0
	frame_motion_dir = frame_delta.normalized() if frame_delta.length_squared() > EPS else Vector3.ZERO
	if frame_motion_dir.length_squared() > EPS and state != UnitState.SKILL_FORM and state != UnitState.SKILL_EXEC:
		_apply_unit_facing(frame_motion_dir, delta)
	_refresh_commander_mount_visibility()
	_update_unit_collision_proxy()
	_update_archer_arrow_anchor_markers()
	_check_rout_conditions()

func configure(world_ref: Node, in_team: int, in_type: UnitType, in_soldiers: int, in_formation: FormationType) -> void:
	battlefield = world_ref
	team_id = in_team
	unit_type = in_type
	troop_count = max(1, in_soldiers)
	soldier_count = _resolve_visual_soldier_count(troop_count)
	base_formation = in_formation
	hp = max_hp
	downhill_speed_bonus_current = 0.0
	command_mode = CommandMode.NONE
	hold_anchor_position = global_position
	retreat_destination = Vector3.INF
	stance_scan_timer = 0.0
	hold_scan_timer = 0.0
	timed_statuses.clear()
	main_commander_down = false
	vice_1_down = false
	vice_2_down = false
	_clear_personality_event_runtime_state()
	if is_inside_tree():
		_rebuild_unit_profile()
		_refresh_auto_statuses()
		_rebuild_visual_instances_from_soldier_count()
		_rebuild_commander_mount_visual()
		_refresh_commander_mount_visibility()
		_update_unit_collision_proxy()
		commander_dialogue_key_cooldowns.clear()
		commander_dialogue_last_line_by_event.clear()
		commander_dialogue_global_cooldown = 0.0
		commander_dialogue_poll_timer = 0.0
		_commander_dialogue_sync_state_snapshot()

func _resolve_visual_soldier_count(in_troops: int) -> int:
	var dim: int = _get_square_dim_for_troops(max(1, in_troops))
	var resolved_dim: int = dim
	if performance_mode_low:
		resolved_dim = mini(dim, clampi(visual_square_dim_cap, 4, 10))
	return resolved_dim * resolved_dim

func _get_square_dim_for_troops(troops: int) -> int:
	var v: int = max(1, troops)
	if v >= formation_dim_10_min_troops:
		return 10
	if v >= formation_dim_9_min_troops:
		return 9
	if v >= formation_dim_8_min_troops:
		return 8
	if v >= formation_dim_7_min_troops:
		return 7
	if v >= formation_dim_6_min_troops:
		return 6
	if v >= formation_dim_5_min_troops:
		return 5
	return 4

func _get_line_rows_for_square_dim(square_dim: int) -> int:
	match clampi(square_dim, 4, 10):
		4:
			return maxi(1, line_rows_for_dim_4)
		5:
			return maxi(1, line_rows_for_dim_5)
		6:
			return maxi(1, line_rows_for_dim_6)
		7:
			return maxi(1, line_rows_for_dim_7)
		8:
			return maxi(1, line_rows_for_dim_8)
		9:
			return maxi(1, line_rows_for_dim_9)
		10:
			return maxi(1, line_rows_for_dim_10)
		_:
			return 2

func _rebuild_visual_instances_from_soldier_count() -> void:
	if not is_inside_tree():
		return
	if soldiers_mmi != null and is_instance_valid(soldiers_mmi):
		remove_child(soldiers_mmi)
		soldiers_mmi.free()
	soldiers_mmi = null
	soldiers_mm = null
	home_offsets.clear()
	desired_offsets.clear()
	current_offsets.clear()
	skill_offsets.clear()
	seeds.clear()
	_build_multimesh_visual()
	_initialize_soldier_offsets()
	_sync_visible_soldier_count()
	_apply_offsets_immediate(home_offsets, false)
	_update_gpu_anim_state()
	role_profile_runtime_applied = false

func issue_move_order(world_pos: Vector3) -> bool:
	if dead:
		return false
	_begin_new_command()
	_cancel_targeting_intents()
	manual_priority_target_unit = null
	command_mode = CommandMode.MOVE
	var plan: Dictionary = _plan_move_order_targets(world_pos)
	if not bool(plan.get("ok", false)):
		has_move_target = false
		move_target = global_position
		nav_mode = NavMode.NONE
		return false
	var first_target: Vector3 = plan.get("first_target", Vector3(world_pos.x, global_position.y, world_pos.z))
	staged_move_targets = _variant_to_vec3_array(plan.get("next_targets", []))
	has_move_target = true
	move_target = Vector3(first_target.x, global_position.y, first_target.z)
	nav_mode = NavMode.POINT_MOVE
	attack_move_active = false
	attack_move_goal = Vector3.ZERO
	retreat_destination = Vector3.INF
	_stop_staged_transition()
	_request_path_async(move_target, PathRequestReason.POINT_MOVE, true, true)
	_mark_repulsion_dirty()
	if state != UnitState.SKILL_FORM and state != UnitState.SKILL_EXEC:
		_enter_state(UnitState.MOVE)
	return true

func issue_attack_move_order(world_pos: Vector3) -> bool:
	if dead:
		return false
	_begin_new_command()
	_cancel_targeting_intents()
	manual_priority_target_unit = null
	command_mode = CommandMode.ATTACK_MOVE
	attack_move_active = true
	attack_move_goal = Vector3(world_pos.x, global_position.y, world_pos.z)
	attack_move_scan_timer = 0.0
	var plan: Dictionary = _plan_move_order_targets(attack_move_goal)
	if not bool(plan.get("ok", false)):
		has_move_target = false
		move_target = global_position
		nav_mode = NavMode.NONE
		attack_move_active = false
		attack_move_goal = Vector3.ZERO
		return false
	var first_target: Vector3 = plan.get("first_target", attack_move_goal)
	staged_move_targets = _variant_to_vec3_array(plan.get("next_targets", []))
	move_target = Vector3(first_target.x, global_position.y, first_target.z)
	has_move_target = true
	nav_mode = NavMode.ATTACK_MOVE
	retreat_destination = Vector3.INF
	_request_path_async(move_target, PathRequestReason.ATTACK_MOVE, true, true)
	_mark_repulsion_dirty()
	if state != UnitState.SKILL_FORM and state != UnitState.SKILL_EXEC:
		_enter_state(UnitState.MOVE)
	return true

func issue_attack_order(
	enemy: UnitController,
	fallback_world_pos: Vector3 = Vector3.INF,
	from_attack_move: bool = false,
	enable_dynamic_repath: bool = false,
	player_priority: bool = false,
	force_lock_target: bool = false
) -> void:
	if dead:
		return
	if enemy == null or enemy.dead or enemy.team_id == team_id:
		return
	_begin_new_command()
	_cancel_targeting_intents()
	manual_priority_target_unit = enemy if player_priority or force_lock_target else null
	command_mode = CommandMode.FORCE_ATTACK if force_lock_target else (CommandMode.ATTACK_MOVE if from_attack_move else CommandMode.NONE)
	var fallback: Vector3 = fallback_world_pos
	if fallback == Vector3.INF:
		fallback = enemy.global_position
	chase_target_unit = enemy
	chase_fallback_point = fallback
	chase_origin_point = global_position
	chase_last_goal_point = enemy.global_position
	chase_slot_offset = Vector3.ZERO
	chase_use_slot_follow = false
	chase_repath_timer = 0.0
	chase_dynamic_repath = false
	player_force_chase_active = player_priority
	player_force_chase_timer = maxf(0.0, player_command_force_chase_sec) if player_priority else 0.0
	attack_move_active = from_attack_move
	if from_attack_move and attack_move_goal == Vector3.ZERO:
		attack_move_goal = fallback
	retreat_destination = Vector3.INF
	target_unit = enemy
	nav_mode = NavMode.CHASE_TARGET
	has_move_target = false
	move_target = global_position
	_stop_staged_transition()
	path_points.clear()
	path_index = 0
	nav_query_pending = false
	nav_query_pending_timer = 0.0
	nav_pending_request_id = 0
	nav_pending_command_serial = 0
	_mark_repulsion_dirty()
	if state != UnitState.SKILL_FORM and state != UnitState.SKILL_EXEC:
		attack_timer = 0.05
		melee_refresh_timer = 0.0
		_enter_state(UnitState.MOVE)

func issue_stop_order() -> void:
	if dead:
		return
	_begin_new_command()
	manual_priority_target_unit = null
	command_mode = CommandMode.STOP
	_cancel_targeting_intents()
	has_move_target = false
	move_target = global_position
	retreat_destination = Vector3.INF
	hold_anchor_position = global_position
	move_velocity = Vector3.ZERO
	attack_timer = 0.0
	if state != UnitState.SKILL_FORM and state != UnitState.SKILL_EXEC:
		_enter_state(UnitState.IDLE)

func issue_hold_position_order(anchor_world_pos: Vector3 = Vector3.INF) -> void:
	if dead:
		return
	_begin_new_command()
	manual_priority_target_unit = null
	command_mode = CommandMode.HOLD_POSITION
	_cancel_targeting_intents()
	has_move_target = false
	move_target = global_position
	retreat_destination = Vector3.INF
	hold_anchor_position = global_position if anchor_world_pos == Vector3.INF else Vector3(anchor_world_pos.x, global_position.y, anchor_world_pos.z)
	move_velocity = Vector3.ZERO
	attack_timer = minf(attack_timer, 0.12)
	hold_scan_timer = 0.0
	if state != UnitState.SKILL_FORM and state != UnitState.SKILL_EXEC:
		_enter_state(UnitState.IDLE)

func issue_retreat_order(world_pos: Vector3) -> void:
	if dead:
		return
	var was_melee: bool = state == UnitState.MELEE
	_begin_new_command()
	_cancel_targeting_intents()
	manual_priority_target_unit = null
	command_mode = CommandMode.RETREAT
	stance = StanceType.PASSIVE
	retreat_destination = Vector3(world_pos.x, global_position.y, world_pos.z)
	has_move_target = true
	move_target = retreat_destination
	nav_mode = NavMode.POINT_MOVE
	attack_move_active = false
	attack_move_goal = Vector3.ZERO
	_stop_staged_transition()
	if _is_personality_event_layer_enabled():
		var rendun_lv: int = _personality_highest_level("rendun")
		if rendun_lv > 0:
			personality_event_rendun_speed_bonus_pct = maxf(personality_event_rendun_speed_bonus_pct, 0.4 if rendun_lv >= 2 else 0.3)
			personality_event_rendun_speed_bonus_left = maxf(personality_event_rendun_speed_bonus_left, 10.0 if rendun_lv >= 2 else 8.0)
			personality_event_rendun_ignore_zoc_left = maxf(personality_event_rendun_ignore_zoc_left, 10.0 if rendun_lv >= 2 else 8.0)
			if rendun_lv >= 2 and was_melee:
				hp = clampf(hp + max_hp * 0.1, 0.0, max_hp)
				_apply_morale_delta(12.0, true)
			_rebuild_personality_event_runtime_bonus()
	_request_path_async(move_target, PathRequestReason.POINT_MOVE, true, true)
	_mark_repulsion_dirty()
	var retreat_line: String = pick_commander_dialogue_line("command_retreat", "全军后撤，重整阵线！")
	_try_commander_line_by_key("command_retreat", retreat_line, 8.0, 2.2, 2)
	if state != UnitState.SKILL_FORM and state != UnitState.SKILL_EXEC:
		_enter_state(UnitState.MOVE)

func set_stance(new_stance: int) -> void:
	stance = clampi(new_stance, int(StanceType.ACTIVE), int(StanceType.PASSIVE))
	stance_scan_timer = 0.0
	hold_scan_timer = 0.0
	if stance == StanceType.HOLD and command_mode == CommandMode.NONE:
		hold_anchor_position = global_position

func get_stance() -> int:
	return int(stance)

func get_command_mode() -> int:
	return int(command_mode)

func can_auto_engage() -> bool:
	if dead:
		return false
	if stance == StanceType.PASSIVE or stance == StanceType.HOLD:
		return false
	match command_mode:
		CommandMode.NONE, CommandMode.ATTACK_MOVE:
			return true
		_:
			return false

func issue_skill(new_skill: SkillType, enemy: UnitController = null) -> bool:
	if dead:
		return false
	if new_skill == SkillType.NONE:
		return false
	if get_skill_cd_left(int(new_skill)) > 0.001:
		return false
	var is_pierce_skill: bool = (new_skill == SkillType.CHARGE or new_skill == SkillType.BREAKTHROUGH) and not _is_archer_role() and not _is_shield_role()
	var cast_enemy: UnitController = enemy
	if cast_enemy == null or cast_enemy.dead or cast_enemy.team_id == team_id:
		if manual_priority_target_unit != null and is_instance_valid(manual_priority_target_unit) and not manual_priority_target_unit.dead and manual_priority_target_unit.team_id != team_id:
			cast_enemy = manual_priority_target_unit
		elif chase_target_unit != null and is_instance_valid(chase_target_unit) and not chase_target_unit.dead and chase_target_unit.team_id != team_id:
			cast_enemy = chase_target_unit
		elif target_unit != null and is_instance_valid(target_unit) and not target_unit.dead and target_unit.team_id != team_id:
			cast_enemy = target_unit
	if _is_archer_role() and (cast_enemy == null or cast_enemy.dead or cast_enemy.team_id == team_id):
		return false
	var pierce_check: Dictionary = {}
	if is_pierce_skill:
		if cast_enemy == null or cast_enemy.dead or cast_enemy.team_id == team_id:
			if manual_priority_target_unit != null and is_instance_valid(manual_priority_target_unit) and not manual_priority_target_unit.dead and manual_priority_target_unit.team_id != team_id:
				cast_enemy = manual_priority_target_unit
			elif chase_target_unit != null and is_instance_valid(chase_target_unit) and not chase_target_unit.dead and chase_target_unit.team_id != team_id:
				cast_enemy = chase_target_unit
			elif target_unit != null and is_instance_valid(target_unit) and not target_unit.dead and target_unit.team_id != team_id:
				cast_enemy = target_unit
		pierce_check = _prepare_pierce_cast(cast_enemy)
		if not bool(pierce_check.get("ok", false)):
			return false
	var cost := _get_skill_spirit_cost(new_skill)
	if not try_consume_spirit(cost):
		return false
	_cancel_navigation_only()
	clear_temporary_detour()
	reengage_time_left = 0.0
	enemy = cast_enemy if cast_enemy != null else enemy
	if is_pierce_skill:
		pierce_path_start = global_position
		pierce_path_end = pierce_check.get("end", global_position)
		pierce_path_forward = pierce_check.get("forward", Vector3.FORWARD)
		pierce_can_pass_through = bool(pierce_check.get("pass_through", true))
		desired_facing = pierce_path_forward
		motion_dir = pierce_path_forward.normalized() if pierce_path_forward.length_squared() > EPS else get_collision_forward_flat()
		look_at(global_position + desired_facing, Vector3.UP)
		pierce_ignore_target_id = cast_enemy.get_instance_id() if cast_enemy != null and pierce_can_pass_through else 0
		pierce_hit_applied = false
		_show_pierce_preview(pierce_path_start, pierce_path_end)
	else:
		_hide_pierce_preview()
		pierce_path_start = Vector3.ZERO
		pierce_path_end = Vector3.ZERO
		pierce_path_forward = Vector3.FORWARD
		pierce_can_pass_through = true
	skill_type = new_skill
	skill_target = enemy
	target_unit = enemy if enemy != null and not enemy.dead else target_unit
	var form_duration: float = maxf(0.08, maxf(pierce_windup_sec, pierce_form_duration_sec)) if is_pierce_skill else skill_form_duration
	if _is_archer_role():
		form_duration *= maxf(0.1, archer_skill_form_duration_mul)
	var formation_transition_duration: float = form_duration
	if is_pierce_skill:
		formation_transition_duration = clampf(form_duration * clampf(charge_skill_form_transition_ratio, 0.05, 1.0), 0.12, form_duration)
	elif _is_archer_role():
		formation_transition_duration = clampf(form_duration * clampf(archer_skill_form_transition_ratio, 0.1, 1.0), 0.12, form_duration)
	skill_timer = form_duration
	charge_form_origin = global_position
	charge_form_duration_ref = form_duration
	allow_overlap = false

	if _is_archer_role():
		var is_crossbow: bool = _is_crossbow_role()
		match skill_type:
			SkillType.CHARGE:
				skill_offsets = _generate_archer_yanxing_offsets(0.94, 1.2, 0.98) if is_crossbow else _generate_archer_yanxing_offsets(1.08, 1.0, 0.86)
			SkillType.BREAKTHROUGH:
				skill_offsets = _generate_archer_yanxing_offsets(0.72, 1.38, 1.14) if is_crossbow else _generate_archer_yanxing_offsets(0.82, 1.18, 1.12)
			SkillType.SWEEP:
				skill_offsets = _generate_archer_yanxing_offsets(1.2, 1.08, 0.56) if is_crossbow else _generate_archer_yanxing_offsets(1.34, 0.94, 0.62)
			_:
				skill_offsets = home_offsets.duplicate()
	elif _is_shield_role():
		match skill_type:
			SkillType.CHARGE:
				skill_offsets = _generate_shield_wall_offsets()
			SkillType.BREAKTHROUGH:
				skill_offsets = _generate_shield_bash_offsets()
			SkillType.SWEEP:
				skill_offsets = _generate_shield_tortoise_offsets()
			_:
				skill_offsets = home_offsets.duplicate()
	elif _is_spear_role():
		match skill_type:
			SkillType.CHARGE:
				skill_offsets = _generate_spear_brace_offsets()
			SkillType.BREAKTHROUGH:
				skill_offsets = _generate_spear_lunge_offsets()
			SkillType.SWEEP:
				skill_offsets = home_offsets.duplicate()
			_:
				skill_offsets = _generate_formation_offsets(FormationType.LINE, soldier_count, formation_spacing)
	elif skill_type == SkillType.CHARGE:
		skill_offsets = _generate_charge_wedge_offsets()
	elif skill_type == SkillType.BREAKTHROUGH:
		skill_offsets = _generate_breakthrough_lance_offsets()
	elif skill_type == SkillType.SWEEP:
		skill_offsets = _generate_sweep_crescent_offsets()
	else:
		skill_offsets = _generate_formation_offsets(FormationType.LINE, soldier_count, formation_spacing)
	_start_staged_transition(skill_offsets, formation_transition_duration, 24, false)
	_play_skill_vfx(skill_type, false)
	_show_skill_name_popup(new_skill)
	var skill_line_name: String = _get_skill_display_name(new_skill)
	if not skill_line_name.is_empty():
		var cast_ctx := {"skill": skill_line_name}
		var cast_line: String = pick_commander_dialogue_line("cast_skill", "施展{skill}！", cast_ctx)
		_try_commander_line_by_key("cast_%d" % int(new_skill), cast_line, 4.0, 1.8, 1)
	_mark_repulsion_dirty()
	_enter_state(UnitState.SKILL_FORM)
	var cooldown: float = _get_skill_cooldown_sec(new_skill)
	if cooldown > 0.0:
		skill_cooldowns[int(new_skill)] = cooldown
	return true

func _prepare_pierce_cast(enemy: UnitController) -> Dictionary:
	if enemy == null or enemy.dead or enemy.team_id == team_id:
		return {"ok": false, "reason": "invalid_target"}
	if has_status(StatusId.CONFUSION) or has_status(StatusId.PARALYZED) or has_status(StatusId.OUT_OF_SUPPLY) or has_status(StatusId.MORALE_COLLAPSE):
		return {"ok": false, "reason": "bad_status"}
	if main_commander_down or morale_current <= 0.001:
		return {"ok": false, "reason": "low_morale"}
	var forward := enemy.global_position - global_position
	forward.y = 0.0
	if forward.length_squared() <= EPS:
		return {"ok": false, "reason": "bad_direction"}
	forward = forward.normalized()
	var enemy_half: Vector2 = enemy.get_collision_half_extents()
	var own_half: Vector2 = get_collision_half_extents()
	var end_gap: float = maxf(maxf(pierce_end_gap, pierce_end_min_gap), 2.0)
	var rear_end_pos: Vector3 = enemy.global_position + forward * (enemy_half.y + own_half.y + end_gap)
	var front_stop_gap: float = maxf(0.35, own_half.y * 0.18)
	var front_end_pos: Vector3 = enemy.global_position - forward * maxf(0.6, enemy_half.y + own_half.y - front_stop_gap)
	var pass_through: bool = true
	var final_end_pos: Vector3 = rear_end_pos
	if battlefield != null and battlefield.has_method("can_unit_walk_at_world"):
		if not bool(battlefield.call("can_unit_walk_at_world", rear_end_pos, self)):
			pass_through = false
			final_end_pos = front_end_pos
			if not bool(battlefield.call("can_unit_walk_at_world", final_end_pos, self)):
				return {"ok": false, "reason": "bad_terrain"}
	return {
		"ok": true,
		"end": final_end_pos,
		"forward": forward,
		"pass_through": pass_through
	}

func _generate_charge_wedge_offsets() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	var lateral_step: float = maxf(0.16, formation_spacing * clampf(charge_wedge_spacing_mul, 0.42, 1.2) * 1.06)
	var depth_step: float = maxf(0.28, formation_spacing * 2.05)
	var placed: int = 0
	var row_id: int = 0
	while placed < safe_count:
		var row_count: int = row_id * 2 + 1
		for j in range(row_count):
			if placed >= safe_count:
				break
			var x: float = (float(j) - float(row_id)) * lateral_step
			var z: float = float(row_id) * depth_step
			out.append(Vector3(x, 0.0, z))
			placed += 1
		row_id += 1
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _generate_breakthrough_lance_offsets() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	var max_cols: int = clampi(breakthrough_wedge_max_cols, 3, 99)
	if max_cols % 2 == 0:
		max_cols -= 1
	var lateral_step: float = maxf(0.42, formation_spacing * maxf(0.68, breakthrough_lance_spacing_mul) * 1.12)
	var depth_step: float = maxf(0.72, lateral_step * 1.72)
	var placed: int = 0
	var row_id: int = 0
	while placed < safe_count:
		var row_count: int = row_id * 2 + 1
		if row_count > max_cols:
			row_count = max_cols
		var half_row: float = float(row_count - 1) * 0.5
		for j in range(row_count):
			if placed >= safe_count:
				break
			var x: float = (float(j) - half_row) * lateral_step
			var z: float = float(row_id) * depth_step
			out.append(Vector3(x, 0.0, z))
			placed += 1
		row_id += 1
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _append_skill_block_offsets(out: Array[Vector3], anchor: Vector3, count: int, cols: int, lateral_step: float, depth_step: float) -> void:
	if count <= 0:
		return
	var safe_cols: int = maxi(1, cols)
	var half_cols: float = float(safe_cols - 1) * 0.5
	for i in range(count):
		var row: int = i / safe_cols
		var col: int = i % safe_cols
		var x: float = (float(col) - half_cols) * lateral_step
		var z: float = float(row) * depth_step
		out.append(anchor + Vector3(x, 0.0, z))

func _generate_archer_yanxing_offsets(width_mul: float = 1.0, depth_mul: float = 1.0, wing_mul: float = 1.0) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	var square_dim: int = _get_square_dim_for_troops(troop_count)
	var cols: int = clampi(square_dim * 2, 5, maxi(5, safe_count))
	var rows: int = maxi(1, int(ceil(float(safe_count) / float(cols))))
	var lateral_step: float = maxf(0.4, formation_spacing * maxf(0.55, archer_skill_yan_width_mul * width_mul) * 1.2)
	var depth_step: float = maxf(0.34, formation_spacing * maxf(0.5, archer_skill_yan_depth_mul * depth_mul) * 1.05)
	var wing_step: float = maxf(0.12, formation_spacing * maxf(0.35, archer_skill_yan_wing_mul * wing_mul))
	var half_cols: float = float(cols - 1) * 0.5
	for i in range(safe_count):
		var row: int = i / cols
		var col: int = i % cols
		var x: float = (float(col) - half_cols) * lateral_step
		var z: float = float(row) * depth_step - absf(x) * wing_step
		out.append(Vector3(x, 0.0, z))
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _generate_sweep_crescent_offsets() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	var front_count: int = maxi(1, int(round(float(safe_count) * 0.22)))
	var flank_total: int = maxi(0, safe_count - front_count)
	var left_count: int = flank_total / 2
	var right_count: int = flank_total - left_count
	var lateral_step: float = maxf(0.48, formation_spacing * 2.18)
	var depth_step: float = maxf(0.52, formation_spacing * 1.82)
	var front_offset: float = maxf(4.6, sweep_forward_distance * 1.95)
	var side_offset: float = maxf(6.8, sweep_side_distance * 0.96)
	var flank_depth: float = -maxf(3.2, sweep_forward_distance * 1.15)
	var front_cols: int = clampi(int(ceil(sqrt(float(front_count)))), 2, 8)
	var flank_cols: int = clampi(int(ceil(sqrt(float(maxi(1, maxi(left_count, right_count)))))), 2, 7)
	_append_skill_block_offsets(out, Vector3(0.0, 0.0, -front_offset), front_count, front_cols, lateral_step, depth_step)
	_append_skill_block_offsets(out, Vector3(-side_offset, 0.0, flank_depth), left_count, flank_cols, lateral_step, depth_step)
	_append_skill_block_offsets(out, Vector3(side_offset, 0.0, flank_depth), right_count, flank_cols, lateral_step, depth_step)
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _generate_spear_brace_offsets() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	var rows: int = 2 if safe_count <= 16 else 3
	var cols: int = clampi(int(ceil(float(safe_count) / float(rows))), 6, 18)
	var step_x: float = maxf(0.82, formation_spacing * 3.2)
	var step_z: float = maxf(0.18, formation_spacing * 0.58)
	for i in safe_count:
		var row: int = i / cols
		var col: int = i % cols
		var x: float = (float(col) - float(cols - 1) * 0.5) * step_x
		var z: float = (float(row) - float(rows - 1) * 0.5) * step_z
		out.append(Vector3(x, 0.0, z))
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _generate_spear_lunge_offsets() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	var front_count: int = maxi(3, int(round(float(safe_count) * 0.36)))
	var rear_count: int = maxi(0, safe_count - front_count)
	var lateral_step: float = maxf(0.42, formation_spacing * 1.8)
	var depth_step: float = maxf(0.48, formation_spacing * 1.55)
	var front_cols: int = clampi(int(ceil(sqrt(float(front_count)))) + 2, 4, 10)
	var rear_cols: int = clampi(int(ceil(sqrt(float(maxi(1, rear_count))))), 3, 8)
	_append_skill_block_offsets(out, Vector3(0.0, 0.0, -2.8), front_count, front_cols, lateral_step, depth_step)
	_append_skill_block_offsets(out, Vector3(0.0, 0.0, 1.5), rear_count, rear_cols, lateral_step * 1.04, depth_step)
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _generate_spear_hook_offsets() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	var center_count: int = maxi(1, int(round(float(safe_count) * 0.28)))
	var flank_total: int = maxi(0, safe_count - center_count)
	var left_count: int = flank_total / 2
	var right_count: int = flank_total - left_count
	var lateral_step: float = maxf(0.46, formation_spacing * 1.9)
	var depth_step: float = maxf(0.48, formation_spacing * 1.52)
	var center_cols: int = clampi(int(ceil(sqrt(float(center_count)))) + 1, 3, 8)
	var flank_cols: int = clampi(int(ceil(sqrt(float(maxi(1, maxi(left_count, right_count)))))), 3, 7)
	_append_skill_block_offsets(out, Vector3(0.0, 0.0, -2.2), center_count, center_cols, lateral_step, depth_step)
	_append_skill_block_offsets(out, Vector3(-4.8, 0.0, -0.2), left_count, flank_cols, lateral_step, depth_step)
	_append_skill_block_offsets(out, Vector3(4.8, 0.0, -0.2), right_count, flank_cols, lateral_step, depth_step)
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _generate_shield_wall_offsets() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	var rows: int = 2 if safe_count <= 24 else 3
	var cols: int = clampi(int(ceil(float(safe_count) / float(rows))), 6, 20)
	var step_x: float = maxf(0.82, formation_spacing * 3.05)
	var step_z: float = maxf(0.2, formation_spacing * 0.6)
	for i in safe_count:
		var row: int = i / cols
		var col: int = i % cols
		var x: float = (float(col) - float(cols - 1) * 0.5) * step_x
		var z: float = (float(row) - float(rows - 1) * 0.5) * step_z
		out.append(Vector3(x, 0.0, z))
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _generate_shield_bash_offsets() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	var front_count: int = maxi(3, int(round(float(safe_count) * 0.42)))
	var rear_count: int = maxi(0, safe_count - front_count)
	var lateral_step: float = maxf(0.44, formation_spacing * 1.95)
	var depth_step: float = maxf(0.46, formation_spacing * 1.52)
	var front_cols: int = clampi(int(ceil(sqrt(float(front_count)))) + 1, 4, 9)
	var rear_cols: int = clampi(int(ceil(sqrt(float(maxi(1, rear_count))))), 3, 8)
	_append_skill_block_offsets(out, Vector3(0.0, 0.0, -2.4), front_count, front_cols, lateral_step, depth_step)
	_append_skill_block_offsets(out, Vector3(0.0, 0.0, 1.3), rear_count, rear_cols, lateral_step * 1.05, depth_step)
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _generate_shield_tortoise_offsets() -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, soldier_count)
	if safe_count <= 4:
		return _generate_formation_offsets(FormationType.SQUARE, safe_count, formation_spacing)
	var outer_count: int = maxi(4, int(round(float(safe_count) * 0.62)))
	var inner_count: int = maxi(0, safe_count - outer_count)
	var outer_radius: float = maxf(1.9, formation_spacing * 4.6)
	var inner_radius: float = maxf(0.9, outer_radius * 0.58)
	for i in range(outer_count):
		var angle: float = TAU * float(i) / maxf(1.0, float(outer_count))
		out.append(Vector3(cos(angle) * outer_radius, 0.0, sin(angle) * outer_radius))
	for i in range(inner_count):
		var angle: float = TAU * float(i) / maxf(1.0, float(inner_count)) + TAU * 0.5 / maxf(1.0, float(inner_count))
		out.append(Vector3(cos(angle) * inner_radius, 0.0, sin(angle) * inner_radius))
	if out.is_empty():
		return out
	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func _check_pierce_interrupts() -> void:
	if not pierce_active:
		return
	if dead:
		return
	if has_status(StatusId.CONFUSION) or has_status(StatusId.PARALYZED) or has_status(StatusId.MORALE_COLLAPSE) or has_status(StatusId.OUT_OF_SUPPLY):
		_finish_skill()
		return
	if main_commander_down:
		_finish_skill()
		return

func _normalize_personality_trait_id(raw: String) -> String:
	return raw.strip_edges().to_lower()

func _personality_highest_level(trait_id: String) -> int:
	var key: String = _normalize_personality_trait_id(trait_id)
	if key.is_empty():
		return 0
	var highest: int = 0
	if _normalize_personality_trait_id(main_battle_personality_trait_id) == key:
		highest = maxi(highest, maxi(0, main_battle_personality_level))
	if _normalize_personality_trait_id(vice_1_battle_personality_trait_id) == key:
		highest = maxi(highest, maxi(0, vice_1_battle_personality_level))
	if _normalize_personality_trait_id(vice_2_battle_personality_trait_id) == key:
		highest = maxi(highest, maxi(0, vice_2_battle_personality_level))
	return highest

func _is_personality_event_layer_enabled() -> bool:
	return personality_event_framework_enabled

func _reset_personality_event_frame_budget() -> void:
	personality_event_trigger_budget_left = maxi(1, personality_event_trigger_budget_per_frame)

func _debug_inc_counter(counter_map: Dictionary, key: String) -> void:
	if key.is_empty():
		return
	counter_map[key] = int(counter_map.get(key, 0)) + 1

func _debug_record_personality_event_trigger(key: String) -> void:
	if not personality_event_debug_stats_enabled:
		return
	personality_event_debug_trigger_total += 1
	_debug_inc_counter(personality_event_debug_trigger_by_key, key)

func _debug_record_personality_event_blocked(key: String) -> void:
	if not personality_event_debug_stats_enabled:
		return
	personality_event_debug_blocked_total += 1
	_debug_inc_counter(personality_event_debug_blocked_by_key, key)

func _debug_record_personality_event_forced(key: String) -> void:
	if not personality_event_debug_stats_enabled:
		return
	personality_event_debug_forced_total += 1
	_debug_inc_counter(personality_event_debug_forced_by_key, key)

func _consume_personality_event_budget(cost: int = 1, trigger_key: String = "") -> bool:
	if not _is_personality_event_layer_enabled():
		return false
	var key: String = trigger_key.strip_edges().to_lower()
	if not personality_event_light_mode:
		if not key.is_empty():
			personality_event_blocked_counter.erase(key)
		_debug_record_personality_event_trigger(key)
		return true
	var spend: int = maxi(1, cost)
	if personality_event_trigger_budget_left >= spend:
		personality_event_trigger_budget_left -= spend
		if not key.is_empty():
			personality_event_blocked_counter.erase(key)
		_debug_record_personality_event_trigger(key)
		return true
	if key.is_empty():
		_debug_record_personality_event_blocked(key)
		return false
	var blocked_count: int = int(personality_event_blocked_counter.get(key, 0)) + 1
	var force_after: int = maxi(1, personality_event_force_trigger_after_blocked_count)
	if blocked_count >= force_after:
		personality_event_blocked_counter.erase(key)
		_debug_record_personality_event_forced(key)
		_debug_record_personality_event_trigger(key)
		return true
	personality_event_blocked_counter[key] = blocked_count
	_debug_record_personality_event_blocked(key)
	return false

func _personality_proc_ready(key: String) -> bool:
	if key.is_empty():
		return true
	return float(personality_event_internal_cd.get(key, 0.0)) <= 0.001

func _set_personality_proc_cd(key: String, duration_sec: float) -> void:
	if key.is_empty():
		return
	var sec: float = maxf(0.0, duration_sec)
	if sec <= 0.0:
		personality_event_internal_cd.erase(key)
		return
	personality_event_internal_cd[key] = maxf(sec, float(personality_event_internal_cd.get(key, 0.0)))

func _get_personality_control_resist_pct() -> float:
	if not _is_personality_event_layer_enabled():
		return 0.0
	var resist: float = personality_event_bawang_control_resist_pct + personality_event_shenwei_control_resist_pct
	var quanbian_lv: int = _personality_highest_level("quanbian")
	if quanbian_lv >= 2:
		resist += 0.45
	elif quanbian_lv >= 1:
		resist += 0.35
	return clampf(resist, 0.0, 0.8)

func _get_unit_intelligence_value() -> float:
	return _mix_stat(float(main_intelligence), float(vice_1_intelligence), float(vice_2_intelligence))

func _is_personality_counter_chain_enabled() -> bool:
	return _is_personality_event_layer_enabled() and personality_event_counter_chain_enabled

func _personality_counter_immunity_chance(source: UnitController, incoming_status: StatusId) -> float:
	if source == null or not is_instance_valid(source):
		return 0.0
	var chance: float = personality_event_counter_immunity_base_chance
	var control_resist_weight: float = personality_event_counter_immunity_control_resist_weight
	if not _is_control_status(incoming_status):
		control_resist_weight *= 0.55
	chance += _get_personality_control_resist_pct() * control_resist_weight
	var int_delta: float = _get_unit_intelligence_value() - source._get_unit_intelligence_value()
	chance += clampf(int_delta * personality_event_counter_immunity_int_weight, -0.08, 0.2)
	var longdan_lv: int = _personality_highest_level("longdan")
	if longdan_lv >= 2:
		chance += 0.16
	elif longdan_lv >= 1:
		chance += 0.1
	var shenwei_lv: int = _personality_highest_level("shenwei")
	if shenwei_lv >= 2:
		chance += 0.08
	elif shenwei_lv >= 1:
		chance += 0.05
	if personality_event_bawang_active_left > 0.001:
		chance += 0.05
	return clampf(chance, 0.0, 0.85)

func _personality_counter_suppression_chance(source: UnitController, source_trait_level: int) -> float:
	if source == null or not is_instance_valid(source):
		return 0.0
	var chance: float = personality_event_counter_suppression_base_chance
	if source_trait_level >= 2:
		chance += personality_event_counter_suppression_lv2_bonus
	elif source_trait_level >= 1:
		chance += personality_event_counter_suppression_lv1_bonus
	var bawang_lv: int = source._personality_highest_level("bawang")
	if bawang_lv >= 2 and source.personality_event_bawang_active_left > 0.001:
		chance += 0.06
	return clampf(chance, 0.0, 0.85)

func _try_personality_dispel_on_block() -> void:
	if not personality_event_counter_dispel_on_block:
		return
	if randf() > clampf(personality_event_counter_dispel_chance_on_block, 0.0, 1.0):
		return
	var dispel_candidates: Array = [StatusId.PARALYZED, StatusId.CONFUSION, StatusId.MISINFORMATION, StatusId.BURNING, StatusId.SLOWED, StatusId.COUNTERED]
	for status_any in dispel_candidates:
		var status_id: StatusId = int(status_any)
		if not has_status(status_id):
			continue
		if status_id == StatusId.BURNING:
			clear_burn()
		else:
			clear_status(status_id)
		return

func _resolve_personality_debuff_counter(source: UnitController, trigger_key: String, incoming_status: StatusId, source_trait_level: int = 1) -> int:
	if not _is_personality_counter_chain_enabled():
		return PERSONALITY_COUNTER_APPLY
	if source == null or not is_instance_valid(source) or source.dead:
		return PERSONALITY_COUNTER_APPLY
	if source.team_id == team_id:
		return PERSONALITY_COUNTER_APPLY
	if not source._is_personality_event_layer_enabled():
		return PERSONALITY_COUNTER_APPLY
	var key: String = trigger_key.strip_edges().to_lower()
	var immunity_chance: float = _personality_counter_immunity_chance(source, incoming_status)
	if immunity_chance <= 0.0 or randf() > immunity_chance:
		return PERSONALITY_COUNTER_APPLY
	var suppression_chance: float = _personality_counter_suppression_chance(source, source_trait_level)
	if suppression_chance > 0.0 and randf() <= suppression_chance:
		source._debug_record_personality_event_forced(key)
		return PERSONALITY_COUNTER_FORCED
	source._debug_record_personality_event_blocked(key)
	_try_personality_dispel_on_block()
	return PERSONALITY_COUNTER_BLOCKED

func _apply_personality_status_with_counter(source: UnitController, status_id: StatusId, duration_sec: float, trigger_key: String, source_trait_level: int = 1) -> bool:
	if dead:
		return false
	var outcome: int = _resolve_personality_debuff_counter(source, trigger_key, status_id, source_trait_level)
	if outcome == PERSONALITY_COUNTER_BLOCKED:
		return false
	var duration_final: float = maxf(0.1, duration_sec)
	if outcome == PERSONALITY_COUNTER_FORCED:
		duration_final = maxf(0.1, duration_final * personality_event_counter_forced_duration_mul)
	apply_status(status_id, duration_final)
	return true

func _apply_personality_burn_with_counter(source: UnitController, duration_sec: float, dps: float, source_team: int, trigger_key: String, source_trait_level: int = 1) -> bool:
	if dead:
		return false
	var outcome: int = _resolve_personality_debuff_counter(source, trigger_key, StatusId.BURNING, source_trait_level)
	if outcome == PERSONALITY_COUNTER_BLOCKED:
		return false
	var duration_final: float = maxf(0.1, duration_sec)
	if outcome == PERSONALITY_COUNTER_FORCED:
		duration_final = maxf(0.1, duration_final * personality_event_counter_forced_duration_mul)
	apply_burn(duration_final, maxf(0.0, dps), source_team)
	return true

func _clear_personality_event_runtime_state() -> void:
	personality_event_attack_bonus_kill_pct = 0.0
	personality_event_attack_bonus_kill_left = 0.0
	personality_event_speed_bonus_kill_pct = 0.0
	personality_event_speed_bonus_kill_left = 0.0
	personality_event_ignore_defense_pct_runtime = 0.0
	personality_event_ignore_defense_left = 0.0
	personality_event_doujiang_stack_count = 0
	personality_event_doujiang_stack_left = 0.0
	personality_event_doujiang_defense_bonus_pct = 0.0
	personality_event_doujiang_defense_bonus_left = 0.0
	personality_event_bawang_attack_bonus_pct = 0.0
	personality_event_bawang_control_resist_pct = 0.0
	personality_event_bawang_active_left = 0.0
	personality_event_bawang_first_engage_consumed = false
	personality_event_bawang_kill_reward_cd_left = 0.0
	personality_event_longdan_attack_bonus_pct = 0.0
	personality_event_longdan_attack_bonus_left = 0.0
	personality_event_longdan_defense_bonus_pct = 0.0
	personality_event_longdan_defense_bonus_left = 0.0
	personality_event_quanbian_defense_bonus_pct = 0.0
	personality_event_quanbian_defense_bonus_left = 0.0
	personality_event_shenwei_control_resist_pct = 0.0
	personality_event_shenwei_control_resist_left = 0.0
	personality_event_rendun_speed_bonus_pct = 0.0
	personality_event_rendun_speed_bonus_left = 0.0
	personality_event_rendun_ignore_zoc_left = 0.0
	personality_event_internal_cd.clear()
	personality_event_blocked_counter.clear()
	personality_event_debug_trigger_total = 0
	personality_event_debug_blocked_total = 0
	personality_event_debug_forced_total = 0
	personality_event_debug_trigger_by_key.clear()
	personality_event_debug_blocked_by_key.clear()
	personality_event_debug_forced_by_key.clear()
	_reset_personality_event_frame_budget()
	personality_event_attack_bonus_pct_runtime = 0.0
	personality_event_defense_bonus_pct_runtime = 0.0
	personality_event_speed_bonus_pct_runtime = 0.0

func _rebuild_personality_event_runtime_bonus() -> void:
	var doujiang_lv: int = _personality_highest_level("doujiang")
	var doujiang_per_stack: float = 0.0
	if doujiang_lv >= 2:
		doujiang_per_stack = 0.04
	elif doujiang_lv >= 1:
		doujiang_per_stack = 0.03
	personality_event_attack_bonus_pct_runtime = clampf(personality_event_attack_bonus_kill_pct + float(personality_event_doujiang_stack_count) * doujiang_per_stack + personality_event_bawang_attack_bonus_pct + personality_event_longdan_attack_bonus_pct, 0.0, 0.85)
	personality_event_defense_bonus_pct_runtime = clampf(personality_event_doujiang_defense_bonus_pct + personality_event_longdan_defense_bonus_pct + personality_event_quanbian_defense_bonus_pct, 0.0, 0.6)
	personality_event_speed_bonus_pct_runtime = clampf(personality_event_speed_bonus_kill_pct + personality_event_rendun_speed_bonus_pct, 0.0, 0.55)

func _refund_skill_cooldowns_by_ratio(refund_ratio: float, only_ranged_role: bool = false) -> void:
	if only_ranged_role and not _is_archer_role():
		return
	var ratio: float = clampf(refund_ratio, 0.0, 1.0)
	if ratio <= 0.001:
		return
	for key_any in skill_cooldowns.keys():
		var key: int = int(key_any)
		if key <= int(SkillType.NONE):
			continue
		var left: float = float(skill_cooldowns.get(key, 0.0))
		if left <= 0.001:
			continue
		skill_cooldowns[key] = maxf(0.0, left * (1.0 - ratio))

func _on_personality_first_engage(enemy: UnitController) -> void:
	if not _is_personality_event_layer_enabled():
		return
	if enemy == null or enemy.dead:
		return
	if personality_event_bawang_first_engage_consumed:
		return
	var bawang_lv: int = _personality_highest_level("bawang")
	if bawang_lv <= 0:
		return
	personality_event_bawang_first_engage_consumed = true
	if bawang_lv >= 2:
		personality_event_bawang_attack_bonus_pct = maxf(personality_event_bawang_attack_bonus_pct, 0.28)
		personality_event_bawang_control_resist_pct = maxf(personality_event_bawang_control_resist_pct, 0.4)
		personality_event_bawang_active_left = maxf(personality_event_bawang_active_left, 14.0)
	else:
		personality_event_bawang_attack_bonus_pct = maxf(personality_event_bawang_attack_bonus_pct, 0.2)
		personality_event_bawang_control_resist_pct = maxf(personality_event_bawang_control_resist_pct, 0.3)
		personality_event_bawang_active_left = maxf(personality_event_bawang_active_left, 12.0)
	_rebuild_personality_event_runtime_bonus()

func _personality_damage_dealt_mul(enemy: UnitController, is_skill_hit: bool, is_ranged_hit: bool) -> float:
	if not _is_personality_event_layer_enabled():
		return 1.0
	var mul: float = 1.0
	var baozhu_lv: int = _personality_highest_level("baozhu")
	if baozhu_lv >= 2 and enemy != null and is_instance_valid(enemy) and enemy.morale_current < 40.0:
		mul *= 1.18
	if is_skill_hit and (skill_type == SkillType.CHARGE or skill_type == SkillType.BREAKTHROUGH) and not is_ranged_hit:
		var shenwei_lv: int = _personality_highest_level("shenwei")
		if shenwei_lv >= 2:
			mul *= 1.28
		elif shenwei_lv >= 1:
			mul *= 1.2
	var jueshuo_lv: int = _personality_highest_level("jueshuo")
	if jueshuo_lv > 0 and is_ranged_hit and enemy != null and is_instance_valid(enemy):
		if get_hp_ratio() >= 0.6:
			mul *= 1.12 if jueshuo_lv >= 2 else 1.08
		if enemy.get_hp_ratio() >= 0.6:
			mul *= 1.15 if jueshuo_lv >= 2 else 1.1
	if is_skill_hit and _is_strategist_role() and enemy != null and is_instance_valid(enemy):
		var xianji_lv: int = _personality_highest_level("xianji_gold")
		if xianji_lv >= 2:
			mul *= 1.18
		elif xianji_lv >= 1:
			mul *= 1.12
		var shenji_lv: int = _personality_highest_level("shenji_gold")
		if shenji_lv >= 2:
			mul *= 1.18
		elif shenji_lv >= 1:
			mul *= 1.12
		var wolong_lv: int = _personality_highest_level("wolong")
		if wolong_lv > 0:
			var self_int: float = _get_unit_intelligence_value()
			var enemy_int: float = enemy._get_unit_intelligence_value()
			if self_int >= enemy_int:
				mul *= 1.2 if wolong_lv >= 2 else 1.12
			else:
				mul *= 1.12 if wolong_lv >= 2 else 1.08
		var fengchu_lv: int = _personality_highest_level("fengchu")
		if fengchu_lv > 0 and enemy.has_status(StatusId.MISINFORMATION):
			mul *= 1.18 if fengchu_lv >= 2 else 1.1
	return maxf(0.1, mul)

func _tick_personality_event_effects(delta: float) -> void:
	var dt: float = maxf(0.0, delta)
	if dt <= 0.0:
		return
	if not _is_personality_event_layer_enabled():
		if personality_event_attack_bonus_pct_runtime > 0.001 or personality_event_defense_bonus_pct_runtime > 0.001 or personality_event_speed_bonus_pct_runtime > 0.001 or personality_event_ignore_defense_pct_runtime > 0.001:
			_clear_personality_event_runtime_state()
		return
	if personality_event_attack_bonus_kill_left > 0.0:
		personality_event_attack_bonus_kill_left = maxf(0.0, personality_event_attack_bonus_kill_left - dt)
		if personality_event_attack_bonus_kill_left <= 0.001:
			personality_event_attack_bonus_kill_pct = 0.0
	if personality_event_speed_bonus_kill_left > 0.0:
		personality_event_speed_bonus_kill_left = maxf(0.0, personality_event_speed_bonus_kill_left - dt)
		if personality_event_speed_bonus_kill_left <= 0.001:
			personality_event_speed_bonus_kill_pct = 0.0
	if personality_event_ignore_defense_left > 0.0:
		personality_event_ignore_defense_left = maxf(0.0, personality_event_ignore_defense_left - dt)
		if personality_event_ignore_defense_left <= 0.001:
			personality_event_ignore_defense_pct_runtime = 0.0
	if personality_event_doujiang_stack_left > 0.0:
		personality_event_doujiang_stack_left = maxf(0.0, personality_event_doujiang_stack_left - dt)
		if personality_event_doujiang_stack_left <= 0.001:
			personality_event_doujiang_stack_count = 0
	if personality_event_doujiang_defense_bonus_left > 0.0:
		personality_event_doujiang_defense_bonus_left = maxf(0.0, personality_event_doujiang_defense_bonus_left - dt)
		if personality_event_doujiang_defense_bonus_left <= 0.001:
			personality_event_doujiang_defense_bonus_pct = 0.0
	if personality_event_bawang_active_left > 0.0:
		personality_event_bawang_active_left = maxf(0.0, personality_event_bawang_active_left - dt)
		if personality_event_bawang_active_left <= 0.001:
			personality_event_bawang_attack_bonus_pct = 0.0
			personality_event_bawang_control_resist_pct = 0.0
	if personality_event_bawang_kill_reward_cd_left > 0.0:
		personality_event_bawang_kill_reward_cd_left = maxf(0.0, personality_event_bawang_kill_reward_cd_left - dt)
	if personality_event_longdan_attack_bonus_left > 0.0:
		personality_event_longdan_attack_bonus_left = maxf(0.0, personality_event_longdan_attack_bonus_left - dt)
		if personality_event_longdan_attack_bonus_left <= 0.001:
			personality_event_longdan_attack_bonus_pct = 0.0
	if personality_event_longdan_defense_bonus_left > 0.0:
		personality_event_longdan_defense_bonus_left = maxf(0.0, personality_event_longdan_defense_bonus_left - dt)
		if personality_event_longdan_defense_bonus_left <= 0.001:
			personality_event_longdan_defense_bonus_pct = 0.0
	if personality_event_quanbian_defense_bonus_left > 0.0:
		personality_event_quanbian_defense_bonus_left = maxf(0.0, personality_event_quanbian_defense_bonus_left - dt)
		if personality_event_quanbian_defense_bonus_left <= 0.001:
			personality_event_quanbian_defense_bonus_pct = 0.0
	if personality_event_shenwei_control_resist_left > 0.0:
		personality_event_shenwei_control_resist_left = maxf(0.0, personality_event_shenwei_control_resist_left - dt)
		if personality_event_shenwei_control_resist_left <= 0.001:
			personality_event_shenwei_control_resist_pct = 0.0
	if personality_event_rendun_speed_bonus_left > 0.0:
		personality_event_rendun_speed_bonus_left = maxf(0.0, personality_event_rendun_speed_bonus_left - dt)
		if personality_event_rendun_speed_bonus_left <= 0.001:
			personality_event_rendun_speed_bonus_pct = 0.0
	if personality_event_rendun_ignore_zoc_left > 0.0:
		personality_event_rendun_ignore_zoc_left = maxf(0.0, personality_event_rendun_ignore_zoc_left - dt)
	if not personality_event_internal_cd.is_empty():
		var erase_cd_keys: Array[String] = []
		for cd_key_any in personality_event_internal_cd.keys():
			var cd_key: String = String(cd_key_any)
			var left: float = maxf(0.0, float(personality_event_internal_cd.get(cd_key_any, 0.0)) - dt)
			if left <= 0.001:
				erase_cd_keys.append(cd_key)
			else:
				personality_event_internal_cd[cd_key] = left
		for cd_key in erase_cd_keys:
			personality_event_internal_cd.erase(cd_key)
	_rebuild_personality_event_runtime_bonus()

func _on_personality_damage_taken(source: UnitController, final_damage: float) -> void:
	if not _is_personality_event_layer_enabled():
		return
	if source == null or source.dead or source.team_id == team_id:
		return
	if final_damage <= EPS:
		return
	var doujiang_lv: int = _personality_highest_level("doujiang")
	if doujiang_lv <= 0:
		return
	if source.skill_type != SkillType.NONE:
		return
	if source._is_archer_role():
		return
	personality_event_doujiang_stack_count = clampi(personality_event_doujiang_stack_count + 1, 0, 5)
	personality_event_doujiang_stack_left = 8.0
	_rebuild_personality_event_runtime_bonus()

func _on_personality_damage_dealt(enemy: UnitController, dealt_damage: float, is_skill_hit: bool, _is_ranged_hit: bool) -> void:
	if not _is_personality_event_layer_enabled():
		return
	if enemy == null or not is_instance_valid(enemy):
		return
	if dealt_damage <= EPS:
		return
	var baozhu_lv: int = _personality_highest_level("baozhu")
	if baozhu_lv > 0 and not enemy.dead:
		var morale_loss: float = 12.0 if baozhu_lv >= 2 else 8.0
		enemy._apply_morale_delta(-morale_loss, true)
	var doujiang_lv: int = _personality_highest_level("doujiang")
	if doujiang_lv >= 2 and is_skill_hit and personality_event_doujiang_stack_count >= 5:
		enemy.apply_status(StatusId.PARALYZED, 1.5)
		personality_event_doujiang_stack_count = 0
		personality_event_doujiang_stack_left = 0.0
		personality_event_doujiang_defense_bonus_pct = maxf(personality_event_doujiang_defense_bonus_pct, 0.2)
		personality_event_doujiang_defense_bonus_left = maxf(personality_event_doujiang_defense_bonus_left, 4.0)
	if is_skill_hit and (skill_type == SkillType.CHARGE or skill_type == SkillType.BREAKTHROUGH):
		var shenwei_lv: int = _personality_highest_level("shenwei")
		if shenwei_lv > 0 and _consume_personality_event_budget(1, "shenwei_charge_hit"):
			personality_event_shenwei_control_resist_pct = maxf(personality_event_shenwei_control_resist_pct, 0.25 if shenwei_lv == 1 else 0.35)
			personality_event_shenwei_control_resist_left = maxf(personality_event_shenwei_control_resist_left, 3.0)
			if shenwei_lv >= 2:
				enemy._apply_personality_status_with_counter(self, StatusId.MISINFORMATION, 6.0, "shenwei_charge_hit", shenwei_lv)
		var feijiang_lv: int = _personality_highest_level("feijiang")
		if feijiang_lv > 0 and _consume_personality_event_budget(1, "feijiang_followup"):
			var cd_key: String = "feijiang_followup"
			if _personality_proc_ready(cd_key):
				var chance: float = 0.5 if feijiang_lv >= 2 else 0.4
				if randf() <= chance:
					enemy.receive_damage(maxf(1.0, dealt_damage * 0.45), self, true)
					_set_personality_proc_cd(cd_key, 6.0)
	_rebuild_personality_event_runtime_bonus()

func _personality_skill_hit_damage_mul(enemy: UnitController) -> float:
	if not _is_personality_event_layer_enabled():
		return 1.0
	var mul: float = 1.0
	var xionglue_lv: int = _personality_highest_level("xionglue")
	if xionglue_lv >= 2:
		mul *= 1.24
	elif xionglue_lv >= 1:
		mul *= 1.18
	var huoshen_lv: int = _personality_highest_level("huoshen")
	if huoshen_lv > 0 and enemy != null and is_instance_valid(enemy) and enemy.is_burning():
		mul *= 1.22 if huoshen_lv >= 2 else 1.15
	return maxf(0.1, mul)

func _on_personality_skill_hit(enemy: UnitController, dealt_damage: float) -> void:
	if not _is_personality_event_layer_enabled():
		return
	if enemy == null or not is_instance_valid(enemy) or enemy.dead:
		return
	if dealt_damage <= EPS:
		return
	var enemy_has_debuff: bool = enemy.has_status(StatusId.CONFUSION) or enemy.has_status(StatusId.MISINFORMATION) or enemy.has_status(StatusId.BURNING) or enemy.has_status(StatusId.SLOWED) or enemy.has_status(StatusId.PARALYZED)
	var xionglue_lv: int = _personality_highest_level("xionglue")
	if xionglue_lv >= 2 and _consume_personality_event_budget(1, "xionglue_confuse"):
		enemy._apply_personality_status_with_counter(self, StatusId.CONFUSION, 6.0, "xionglue_confuse", xionglue_lv)
	var huoshen_lv: int = _personality_highest_level("huoshen")
	if huoshen_lv > 0 and _consume_personality_event_budget(1, "huoshen_burn"):
		var burn_duration: float = 8.0 if huoshen_lv >= 2 else 6.0
		var burn_dps: float = maxf(0.5, archer_skill_fire_arrow_burn_dps)
		enemy._apply_personality_burn_with_counter(self, burn_duration, burn_dps, team_id, "huoshen_burn", huoshen_lv)
		if huoshen_lv >= 2 and _personality_proc_ready("huoshen_refund"):
			_refund_skill_cooldowns_by_ratio(0.2)
			_set_personality_proc_cd("huoshen_refund", 8.0)
	var fengchu_lv: int = _personality_highest_level("fengchu")
	if fengchu_lv > 0 and _consume_personality_event_budget(1, "fengchu_misinformation"):
		enemy._apply_personality_status_with_counter(self, StatusId.MISINFORMATION, 8.0 if fengchu_lv >= 2 else 6.0, "fengchu_misinformation", fengchu_lv)
	var quanbian_lv: int = _personality_highest_level("quanbian")
	if quanbian_lv >= 2 and _consume_personality_event_budget(1, "quanbian_defense"):
		personality_event_quanbian_defense_bonus_pct = maxf(personality_event_quanbian_defense_bonus_pct, 0.15)
		personality_event_quanbian_defense_bonus_left = maxf(personality_event_quanbian_defense_bonus_left, 4.0)
	var huangtian_lv: int = _personality_highest_level("huangtian_gold")
	if huangtian_lv > 0 and _consume_personality_event_budget(1, "huangtian_confuse"):
		var confuse_chance: float = 0.3 if huangtian_lv >= 2 else 0.2
		if randf() <= confuse_chance:
			enemy._apply_personality_status_with_counter(self, StatusId.CONFUSION, 4.0, "huangtian_confuse", huangtian_lv)
		if huangtian_lv >= 2 and _personality_proc_ready("huangtian_reward"):
			_apply_morale_delta(10.0, true)
			_refund_skill_cooldowns_by_ratio(0.15)
			_set_personality_proc_cd("huangtian_reward", 8.0)
	if _is_strategist_role():
		var xianji_lv: int = _personality_highest_level("xianji_gold")
		if xianji_lv >= 2 and _consume_personality_event_budget(1, "xianji_refund") and _personality_proc_ready("xianji_refund"):
			_refund_skill_cooldowns_by_ratio(0.2)
			_set_personality_proc_cd("xianji_refund", 8.0)
		var wolong_lv: int = _personality_highest_level("wolong")
		if wolong_lv >= 2 and _consume_personality_event_budget(1, "wolong_refund") and _personality_proc_ready("wolong_refund"):
			_refund_skill_cooldowns_by_ratio(0.2)
			_set_personality_proc_cd("wolong_refund", 8.0)
		var shenji_lv: int = _personality_highest_level("shenji_gold")
		if shenji_lv >= 2 and enemy_has_debuff and _consume_personality_event_budget(1, "shenji_refund") and _personality_proc_ready("shenji_refund"):
			_refund_skill_cooldowns_by_ratio(0.25)
			_set_personality_proc_cd("shenji_refund", 8.0)
	_rebuild_personality_event_runtime_bonus()

func _on_personality_kill(_victim: UnitController) -> void:
	if not _is_personality_event_layer_enabled():
		return
	var feijiang_lv: int = _personality_highest_level("feijiang")
	if feijiang_lv >= 2:
		personality_event_speed_bonus_kill_pct = maxf(personality_event_speed_bonus_kill_pct, 0.2)
		personality_event_speed_bonus_kill_left = maxf(personality_event_speed_bonus_kill_left, 3.0)
	var wusheng_lv: int = _personality_highest_level("wusheng")
	if wusheng_lv >= 2:
		personality_event_attack_bonus_kill_pct = maxf(personality_event_attack_bonus_kill_pct, 0.2)
		personality_event_attack_bonus_kill_left = maxf(personality_event_attack_bonus_kill_left, 8.0)
		personality_event_ignore_defense_pct_runtime = maxf(personality_event_ignore_defense_pct_runtime, 0.2)
		personality_event_ignore_defense_left = maxf(personality_event_ignore_defense_left, 8.0)
	var bawang_lv: int = _personality_highest_level("bawang")
	if bawang_lv >= 2 and personality_event_bawang_active_left > 0.001 and personality_event_bawang_kill_reward_cd_left <= 0.001:
		_apply_morale_delta(15.0, true)
		_refund_skill_cooldowns_by_ratio(0.4)
		personality_event_bawang_kill_reward_cd_left = 20.0
	var jueshuo_lv: int = _personality_highest_level("jueshuo")
	if jueshuo_lv >= 2 and _is_archer_role() and _consume_personality_event_budget(1, "jueshuo_kill_refund"):
		_refund_skill_cooldowns_by_ratio(0.4, true)
	_rebuild_personality_event_runtime_bonus()

func receive_damage(amount: float, source: UnitController = null, show_damage_popup: bool = false) -> void:
	if dead:
		return
	var incoming: float = maxf(0.0, amount)
	if incoming <= EPS:
		return
	var before_hp: float = hp
	var defense_mul: float = maxf(0.05, _get_runtime_defense_mul())
	var final_damage: float = incoming / defense_mul
	if _is_shield_role() and shield_skill_absorb_pool > 0.001 and final_damage > 0.0:
		var absorb_ratio: float = clampf(shield_wall_absorb_ratio, 0.0, 0.98)
		var absorbed: float = minf(final_damage * absorb_ratio, shield_skill_absorb_pool)
		shield_skill_absorb_pool = maxf(0.0, shield_skill_absorb_pool - absorbed)
		final_damage = maxf(0.0, final_damage - absorbed)
		if shield_skill_buff_timer < 0.0 and shield_skill_absorb_pool <= 0.001:
			_clear_shield_skill_buff()
	hp = clampf(hp - final_damage, 0.0, max_hp)
	_sync_visible_soldier_count()
	_apply_morale_loss_from_hp_change(before_hp, hp)
	if show_damage_popup and final_damage > EPS:
		var emphasized_popup: bool = source != null and not source.dead and source.skill_type != SkillType.NONE
		_show_damage_number(final_damage, emphasized_popup)
	if source != null and not source.dead and source.team_id != team_id and final_damage > EPS:
		auto_skill_recent_damage += final_damage
		auto_skill_recent_damage_timer = maxf(auto_skill_recent_damage_window_sec, auto_skill_recent_damage_timer)
		_on_personality_damage_taken(source, final_damage)
	_apply_morale_shock_from_source(source)
	_check_rout_conditions()

	if source != null and not source.dead and source.team_id != team_id:
		if _can_retarget_from_hit(source) and state != UnitState.SKILL_FORM and state != UnitState.SKILL_EXEC:
			if target_unit == null or target_unit.dead or state != UnitState.MELEE:
				target_unit = source
				has_move_target = false
				path_points.clear()
				path_index = 0
				attack_timer = minf(attack_timer, 0.15)
				melee_refresh_timer = 0.0
				_enter_state(UnitState.MELEE)

	if hp <= 0.0:
		var killer: UnitController = null
		if source != null and not source.dead and source.team_id != team_id:
			killer = source
			source._on_personality_kill(self)
		_dispatch_defeat_report(killer)
		_die()

func _dispatch_defeat_report(killer: UnitController = null) -> void:
	if defeat_report_dispatched:
		return
	defeat_report_dispatched = true
	var battle_node: Node = battlefield
	if battle_node == null and killer != null:
		battle_node = killer.battlefield
	if battle_node != null and is_instance_valid(battle_node) and battle_node.has_method("on_unit_defeated"):
		battle_node.call("on_unit_defeated", killer, self)

func _can_retarget_from_hit(source: UnitController) -> bool:
	if source == null or source.dead or source.team_id == team_id:
		return false
	if stance == StanceType.PASSIVE:
		return false
	match command_mode:
		CommandMode.FORCE_ATTACK:
			return false
		CommandMode.HOLD_POSITION:
			return false
		CommandMode.STOP:
			return false
		CommandMode.RETREAT:
			return false
		CommandMode.MOVE:
			return false
		CommandMode.ATTACK_MOVE:
			return true
		_:
			return stance == StanceType.ACTIVE

func apply_burn(duration_sec: float, dps: float, source_team: int = -1) -> void:
	if dead:
		return
	if battlefield != null and is_instance_valid(battlefield):
		if battlefield.has_method("is_fire_blocked_by_weather") and bool(battlefield.call("is_fire_blocked_by_weather")):
			return
	burn_time_left = maxf(burn_time_left, maxf(0.0, duration_sec))
	burn_dps = maxf(burn_dps, maxf(0.0, dps))
	burn_source_team = source_team
	apply_status(StatusId.BURNING, burn_time_left)

func clear_burn() -> void:
	burn_time_left = 0.0
	burn_dps = 0.0
	burn_source_team = -1
	clear_status(StatusId.BURNING)

func is_burning() -> bool:
	return burn_time_left > 0.001 and burn_dps > 0.001

func _update_burn(delta: float) -> void:
	if not is_burning():
		return
	burn_time_left = maxf(0.0, burn_time_left - delta)
	receive_damage(burn_dps * delta, null)
	if burn_time_left <= 0.001:
		clear_burn()

func apply_soft_repulsion(_push: Vector3) -> void:
	pending_displacement = Vector3.ZERO

func can_soft_repel() -> bool:
	return not dead and not allow_overlap

func _ensure_unit_collision_proxy() -> void:
	if unit_collision_body != null and is_instance_valid(unit_collision_body):
		return
	unit_collision_body = StaticBody3D.new()
	unit_collision_body.name = "UnitCollisionBody"
	unit_collision_body.collision_layer = 1 << 19
	unit_collision_body.collision_mask = 0
	add_child(unit_collision_body)
	unit_collision_shape_node = CollisionShape3D.new()
	unit_collision_shape_node.name = "UnitCollisionShape"
	unit_collision_box_shape = BoxShape3D.new()
	unit_collision_shape_node.shape = unit_collision_box_shape
	unit_collision_shape_node.disabled = false
	unit_collision_body.add_child(unit_collision_shape_node)

func _compute_offsets_depth(offsets: Array[Vector3]) -> float:
	if offsets.is_empty():
		return 0.0
	var min_z: float = INF
	var max_z: float = -INF
	for off in offsets:
		min_z = minf(min_z, off.z)
		max_z = maxf(max_z, off.z)
	return maxf(0.0, max_z - min_z)

func get_logic_radius() -> float:
	var half: Vector2 = get_collision_half_extents()
	return maxf(0.5, maxf(half.x, half.y) * 1.08)

func get_collision_half_extents() -> Vector2:
	var width: float = maxf(_compute_offsets_width(home_offsets), _compute_offsets_width(current_offsets))
	var depth: float = maxf(_compute_offsets_depth(home_offsets), _compute_offsets_depth(current_offsets))
	if width <= EPS:
		width = maxf(1.4, formation_spacing * float(maxi(2, soldier_count / 2)))
	if depth <= EPS:
		depth = maxf(1.2, formation_spacing * 2.0)
	var basis_scale: Vector3 = global_basis.get_scale()
	var node_scale_xz: float = maxf(1.0, maxf(absf(basis_scale.x), absf(basis_scale.z)))
	var footprint_mul: float = 0.92
	width = width * node_scale_xz * footprint_mul
	depth = depth * node_scale_xz * footprint_mul
	var body_padding: float = maxf(0.08, formation_spacing * 0.22)
	width += body_padding
	depth += body_padding
	var troop_ratio: float = clampf(float(get_alive_troop_count()) / maxf(1.0, float(troop_count)), 0.0, 1.0)
	var scale: float = maxf(unit_collision_min_scale, sqrt(troop_ratio))
	var hx: float = maxf(0.2, width * 0.5 * scale + maxf(0.0, unit_collision_padding_x))
	var hz: float = maxf(0.2, depth * 0.5 * scale + maxf(0.0, unit_collision_padding_z))
	return Vector2(hx, hz)

func get_collision_forward_flat() -> Vector3:
	var forward: Vector3 = desired_facing
	forward.y = 0.0
	if forward.length_squared() <= EPS:
		forward = -global_basis.z
		forward.y = 0.0
	if forward.length_squared() <= EPS:
		forward = Vector3.FORWARD
	return forward.normalized()

func get_collision_obb_at(world_pos: Vector3, forward_hint: Vector3 = Vector3.ZERO) -> Dictionary:
	var forward: Vector3 = forward_hint
	forward.y = 0.0
	if forward.length_squared() <= EPS:
		forward = get_collision_forward_flat()
	var right := Vector3(forward.z, 0.0, -forward.x)
	if right.length_squared() <= EPS:
		right = Vector3.RIGHT
	else:
		right = right.normalized()
	var half: Vector2 = get_collision_half_extents()
	return {
		"center": Vector2(world_pos.x, world_pos.z),
		"forward": Vector2(forward.x, forward.z),
		"right": Vector2(right.x, right.z),
		"half_x": half.x,
		"half_z": half.y
	}

func can_ignore_collision_with(other: UnitController) -> bool:
	if other == null:
		return false
	if pierce_active and pierce_ignore_target_id != 0 and other.get_instance_id() == pierce_ignore_target_id:
		return true
	return false

func _update_unit_collision_proxy() -> void:
	if unit_collision_body == null or not is_instance_valid(unit_collision_body):
		return
	if unit_collision_shape_node == null or unit_collision_box_shape == null:
		return
	var half: Vector2 = get_collision_half_extents()
	unit_collision_box_shape.size = Vector3(half.x * 2.0, maxf(0.2, unit_collision_height), half.y * 2.0)
	unit_collision_body.visible = unit_collision_debug_visible
	unit_collision_body.position = Vector3(0.0, maxf(0.1, unit_collision_height) * 0.5, 0.0)

func get_activity_radius() -> float:
	var base_radius: float = cavalry_activity_radius if unit_type == UnitType.CAVALRY else infantry_activity_radius
	var visual_factor: float = maxf(1.0, soldier_visual_scale)
	var visual_mul: float = lerpf(1.0, visual_factor, clampf(activity_radius_visual_weight, 0.0, 1.0))
	return base_radius * maxf(0.5, activity_radius_mul) * visual_mul

func _get_non_melee_formation_radius() -> float:
	if home_offsets.is_empty():
		return 0.0
	var max_dist: float = 0.0
	for p_any in home_offsets:
		var p: Vector3 = p_any
		var flat_len: float = Vector2(p.x, p.z).length()
		if flat_len > max_dist:
			max_dist = flat_len
	return max_dist + maxf(0.2, formation_spacing * 0.5)

func _mix_stat(main_value: float, vice_1_value: float, vice_2_value: float) -> float:
	# 部队五维固定规则：主将60% + 副将1 20% + 副将2 20%
	return main_value * 0.6 + vice_1_value * 0.2 + vice_2_value * 0.2

func _get_base_attack_interval_by_type() -> float:
	if _is_archer_role():
		return maxf(0.2, archer_attack_interval)
	return cavalry_attack_interval if unit_type == UnitType.CAVALRY else infantry_attack_interval

func _is_archer_role() -> bool:
	var role_id: String = combat_role_id.strip_edges().to_lower()
	return role_id == "archer" or role_id == "crossbow" or role_id == "siege" or role_id == "strategist"

func _is_crossbow_role() -> bool:
	return combat_role_id.strip_edges().to_lower() == "crossbow"

func _is_spear_role() -> bool:
	return combat_role_id.strip_edges().to_lower() == "spear"

func _is_shield_role() -> bool:
	return combat_role_id.strip_edges().to_lower() == "shield"

func _is_strategist_role() -> bool:
	return combat_role_id.strip_edges().to_lower() == "strategist"

func _get_effective_attack_range() -> float:
	return maxf(1.2, float(profile_cache.get("final_range", attack_range)))

func _get_melee_fixed_center_attack_distance() -> float:
	return maxf(0.5, melee_fixed_center_attack_distance)

func get_melee_engage_center_distance(enemy: UnitController = null) -> float:
	var base_dist: float = _get_melee_fixed_center_attack_distance()
	if enemy == null or enemy.dead:
		return base_dist
	var own_half: Vector2 = get_collision_half_extents()
	var enemy_half: Vector2 = enemy.get_collision_half_extents()
	var front_gap: float = maxf(0.3, melee_front_gap * 0.3)
	var footprint_dist: float = own_half.y + enemy_half.y + front_gap
	return maxf(base_dist, footprint_dist)

func _get_ranged_fixed_center_attack_distance() -> float:
	return maxf(maxf(0.5, ranged_fixed_center_attack_distance), maxf(_get_effective_attack_range(), archer_preferred_range))

func get_ranged_engage_center_distance(enemy: UnitController = null) -> float:
	var base_dist: float = _get_ranged_fixed_center_attack_distance()
	if enemy == null or enemy.dead:
		return base_dist
	var ctx: Dictionary = _get_archer_frontline_context(enemy)
	var own_front: float = float(ctx.get("own_front", 0.0))
	var enemy_front: float = float(ctx.get("enemy_front", 0.0))
	var visual_gap: float = maxf(12.0, own_front + enemy_front + 8.0)
	return base_dist + visual_gap

func _get_type_multipliers() -> Dictionary:
	if unit_type == UnitType.CAVALRY:
		return {
			"attack": 1.15,
			"defense": 0.95,
			"magic_attack": 0.72,
			"magic_defense": 0.85,
			"speed": 1.2,
			"range_bonus": 0.0
		}
	return {
		"attack": 1.0,
		"defense": 1.12,
		"magic_attack": 0.82,
		"magic_defense": 1.0,
		"speed": 0.9,
		"range_bonus": 0.0
	}

func _aptitude_score(grade: AptitudeGrade) -> float:
	match grade:
		AptitudeGrade.S:
			return 3.0
		AptitudeGrade.A:
			return 2.0
		AptitudeGrade.B:
			return 1.0
		_:
			return 0.0

func _score_to_aptitude(score: float) -> AptitudeGrade:
	if score >= 2.5:
		return AptitudeGrade.S
	if score >= 1.5:
		return AptitudeGrade.A
	if score >= 0.5:
		return AptitudeGrade.B
	return AptitudeGrade.C

func _aptitude_to_text(grade: AptitudeGrade) -> String:
	match grade:
		AptitudeGrade.S:
			return "S"
		AptitudeGrade.A:
			return "A"
		AptitudeGrade.B:
			return "B"
		_:
			return "C"

func _aptitude_tactic_slots(grade: AptitudeGrade) -> int:
	match grade:
		AptitudeGrade.S:
			return 3
		AptitudeGrade.A:
			return 3
		AptitudeGrade.B:
			return 2
		_:
			return 1

func _build_tactic_pool(grade: AptitudeGrade) -> Array[String]:
	if not _is_strategist_role():
		return []
	match grade:
		AptitudeGrade.S:
			return ["strat_skyfire", "strat_dragon_bind", "strat_thunder_lock"]
		AptitudeGrade.A:
			return ["strat_chain", "strat_thunder", "strat_trap"]
		AptitudeGrade.B:
			return ["strat_fire_attack", "strat_sow_discord", "strat_weather_change"]
		_:
			return ["strat_cheer", "strat_delay", "strat_borrow_wind"]

func _rebuild_unit_profile() -> void:
	var lead_mix := _mix_stat(main_leadership, vice_1_leadership, vice_2_leadership)
	var might_mix := _mix_stat(main_might, vice_1_might, vice_2_might)
	var int_mix := _mix_stat(main_intelligence, vice_1_intelligence, vice_2_intelligence)
	var pol_mix := _mix_stat(main_politics, vice_1_politics, vice_2_politics)
	var charm_mix := _mix_stat(main_charm, vice_1_charm, vice_2_charm)
	var final_apt := maxi(int(main_unit_aptitude), maxi(int(vice_1_unit_aptitude), int(vice_2_unit_aptitude)))

	var morale_cap := morale_cap_base + tech_morale_cap_bonus
	morale_current = clampf(morale_training_value, 0.0, maxf(1.0, morale_cap))

	spirit_cap_current = maxf(1.0, spirit_cap_base + tech_spirit_cap_bonus)
	var high_pol_bonus := maxf(pol_mix - 70.0, 0.0) * spirit_outbound_high_politics_mul
	var spirit_from_politics := spirit_base_outbound + pol_mix * spirit_outbound_politics_mul + high_pol_bonus
	spirit_current = clampf(spirit_from_politics + personality_spirit_bonus_flat, 0.0, spirit_cap_current)
	spirit_recover_per_sec = spirit_recover_base_per_sec + pol_mix * spirit_recover_politics_per_sec

	var atk_mul := (1.0 + 0.006 * (might_mix - 50.0)) * (1.0 + tech_attack_bonus_pct + personality_attack_bonus_pct)
	var def_mul := (1.0 + 0.006 * (lead_mix - 50.0)) * (1.0 + tech_defense_bonus_pct + personality_defense_bonus_pct)
	var matk_mul := (1.0 + 0.008 * (int_mix - 50.0)) * (1.0 + tech_magic_attack_bonus_pct)
	var mdef_mul := (1.0 + 0.008 * (int_mix - 50.0)) * (1.0 + tech_magic_defense_bonus_pct)
	var speed_mul := (1.0 + 0.003 * (lead_mix - 50.0)) * (1.0 + tech_speed_bonus_pct + personality_speed_bonus_pct)
	var type_mul := _get_type_multipliers()
	atk_mul *= float(type_mul.get("attack", 1.0))
	def_mul *= float(type_mul.get("defense", 1.0))
	matk_mul *= float(type_mul.get("magic_attack", 1.0))
	mdef_mul *= float(type_mul.get("magic_defense", 1.0))
	speed_mul *= float(type_mul.get("speed", 1.0))

	var slot_bonus: int = maxi(0, famous_extra_tactic_slots)
	if _is_strategist_role():
		tactic_slots = _aptitude_tactic_slots(final_apt) + slot_bonus
		var tactic_pool: Array[String] = _build_tactic_pool(final_apt)
		var equip_count: int = mini(tactic_pool.size(), tactic_slots)
		unlocked_tactics = []
		for i in range(equip_count):
			unlocked_tactics.append(tactic_pool[i])
	else:
		tactic_slots = 0
		unlocked_tactics = []
	var base_attack_interval := _get_base_attack_interval_by_type()
	profile_cache = {
		"leadership_mix": lead_mix,
		"might_mix": might_mix,
		"intelligence_mix": int_mix,
		"politics_mix": pol_mix,
		"charm_mix": charm_mix,
		"aptitude": _aptitude_to_text(final_apt),
		"final_attack": attack_damage * atk_mul,
		"final_defense": max_hp * 0.08 * def_mul,
		"final_magic_attack": attack_damage * 0.45 * matk_mul,
		"final_magic_defense": max_hp * 0.05 * mdef_mul,
		"final_speed": move_speed * speed_mul,
		"final_attack_speed": 1.0 / maxf(base_attack_interval, 0.05),
		"final_range": attack_range + tech_range_bonus_flat + float(type_mul.get("range_bonus", 0.0))
	}

func _update_spirit_recovery(delta: float) -> void:
	if delta <= 0.0:
		return
	var recover := spirit_recover_per_sec * (1.0 + get_morale_ratio() * spirit_recover_morale_factor)
	match state:
		UnitState.MOVE:
			recover *= spirit_recover_move_mul
		UnitState.MELEE:
			recover *= spirit_recover_melee_mul
		UnitState.SKILL_FORM, UnitState.SKILL_EXEC:
			recover *= spirit_recover_skill_mul
		_:
			recover *= 1.0
	spirit_current = clampf(spirit_current + recover * delta, 0.0, spirit_cap_current)

func get_morale_ratio() -> float:
	var morale_cap := maxf(1.0, morale_cap_base + tech_morale_cap_bonus)
	return clampf(morale_current / morale_cap, 0.0, 1.0)

func get_spirit_ratio() -> float:
	return clampf(spirit_current / maxf(1.0, spirit_cap_current), 0.0, 1.0)

func try_consume_spirit(cost: float) -> bool:
	var final_cost := maxf(0.0, cost * (1.0 - tech_spirit_cost_reduction_pct))
	if spirit_current < final_cost:
		return false
	spirit_current -= final_cost
	return true

func try_consume_will(cost: float) -> bool:
	return try_consume_spirit(cost)

func _get_skill_spirit_cost(skill: SkillType) -> float:
	if _is_shield_role():
		match skill:
			SkillType.CHARGE:
				return shield_skill_cost_charge
			SkillType.BREAKTHROUGH:
				return shield_skill_cost_breakthrough
			SkillType.SWEEP:
				return shield_skill_cost_sweep
			_:
				return 0.0
	match skill:
		SkillType.CHARGE:
			return skill_cost_charge
		SkillType.BREAKTHROUGH:
			return skill_cost_breakthrough
		SkillType.SWEEP:
			return skill_cost_sweep
		_:
			return 0.0

func _resolve_skill_forward() -> Vector3:
	var dir := -global_basis.z
	dir.y = 0.0
	if (skill_type == SkillType.CHARGE or skill_type == SkillType.BREAKTHROUGH) and pierce_path_forward.length_squared() > EPS:
		dir = pierce_path_forward.normalized()
		return dir if dir.length_squared() > EPS else Vector3.FORWARD
	if skill_target != null and not skill_target.dead:
		var to_enemy := skill_target.global_position - global_position
		to_enemy.y = 0.0
		if to_enemy.length_squared() > EPS:
			dir = to_enemy.normalized()
	elif target_unit != null and not target_unit.dead:
		var to_target := target_unit.global_position - global_position
		to_target.y = 0.0
		if to_target.length_squared() > EPS:
			dir = to_target.normalized()
	elif desired_facing.length_squared() > EPS:
		dir = desired_facing.normalized()
	return dir if dir.length_squared() > EPS else Vector3.FORWARD

func _get_base_attack_damage() -> float:
	var base_attack: float = float(profile_cache.get("final_attack", attack_damage))
	return base_attack * _get_runtime_attack_mul()

func _calc_tactic_damage(base_damage: float) -> Dictionary:
	var out := maxf(base_damage, 0.0)
	var is_crit: bool = false
	if tactic_crit_enabled and randf() <= clampf(tactic_crit_chance, 0.0, 1.0):
		out *= maxf(1.0, tactic_crit_damage_mul)
		is_crit = true
		_mark_tactic_crit_vfx()
	return {
		"damage": out,
		"is_crit": is_crit
	}

func _apply_tactic_damage_to(enemy: UnitController, base_damage: float, force_damage_popup: bool = false) -> void:
	if enemy == null or enemy.dead:
		return
	var role_mul: float = _get_role_counter_damage_mul_to(enemy)
	var height_mul: float = _get_height_attack_mul_to(enemy)
	var is_skill_hit: bool = skill_type != SkillType.NONE
	var is_ranged_hit: bool = _is_archer_role()
	var siege_variant_mul: float = 1.0
	if battlefield != null and battlefield.has_method("get_siege_variant_unit_damage_mul"):
		siege_variant_mul = float(battlefield.call("get_siege_variant_unit_damage_mul", self, enemy, is_skill_hit, is_ranged_hit))
	var personality_skill_mul: float = _personality_skill_hit_damage_mul(enemy) if is_skill_hit else 1.0
	var personality_damage_mul: float = _personality_damage_dealt_mul(enemy, is_skill_hit, is_ranged_hit)
	var result: Dictionary = _calc_tactic_damage(base_damage * role_mul * height_mul * siege_variant_mul * personality_skill_mul * personality_damage_mul)
	var final_damage: float = float(result.get("damage", 0.0))
	var show_popup: bool = force_damage_popup or skill_type != SkillType.NONE or bool(result.get("is_crit", false))
	var hp_before: float = enemy.hp
	enemy.receive_damage(final_damage, self, show_popup)
	var dealt_damage: float = maxf(0.0, hp_before - enemy.hp)
	if dealt_damage > EPS and battlefield != null and battlefield.has_method("apply_siege_variant_on_hit"):
		battlefield.call("apply_siege_variant_on_hit", self, enemy, dealt_damage, is_skill_hit, is_ranged_hit)
	_on_personality_damage_dealt(enemy, dealt_damage, is_skill_hit, is_ranged_hit)
	if is_skill_hit:
		_on_personality_skill_hit(enemy, dealt_damage)

func _apply_charge_hits(hit_radius: float) -> void:
	if battlefield == null or not battlefield.has_method("get_enemies_in_radius"):
		return
	var speed_ratio := clampf(charge_speed / maxf(move_speed, 0.1), 1.0, 3.0)
	var speed_bonus := 1.0 + (speed_ratio - 1.0) * charge_speed_bonus_damage_scale
	var hit := _get_base_attack_damage() * charge_damage_mul * speed_bonus
	var enemies: Array = battlefield.call("get_enemies_in_radius", global_position, hit_radius, team_id)
	for enemy_any in enemies:
		if enemy_any is UnitController:
			_apply_tactic_damage_to(enemy_any, hit)

func _apply_breakthrough_hits(hit_radius: float) -> void:
	if battlefield == null or not battlefield.has_method("get_enemies_in_radius"):
		return
	var hit := _get_base_attack_damage() * breakthrough_damage_mul
	var enemies: Array = battlefield.call("get_enemies_in_radius", global_position, hit_radius, team_id)
	for enemy_any in enemies:
		if enemy_any is UnitController:
			_apply_tactic_damage_to(enemy_any, hit)

func _try_apply_pierce_hit(skill_id: SkillType) -> void:
	if not pierce_active or pierce_hit_applied:
		return
	if skill_target == null or skill_target.dead:
		return
	var hit_ready: bool = false
	var front_contact_dist: float = get_collision_half_extents().y + skill_target.get_collision_half_extents().y + 0.8
	if pierce_can_pass_through:
		if battlefield != null and battlefield.has_method("are_units_rect_overlapping"):
			hit_ready = bool(battlefield.call("are_units_rect_overlapping", self, skill_target))
		if not hit_ready:
			var to_target: Vector3 = skill_target.global_position - global_position
			to_target.y = 0.0
			var passed_center: bool = pierce_path_forward.length_squared() > EPS and to_target.dot(pierce_path_forward.normalized()) <= maxf(0.18, get_collision_half_extents().y * 0.35)
			hit_ready = passed_center or _flat_distance_to(skill_target.global_position) <= front_contact_dist
	else:
		hit_ready = _flat_distance_to(skill_target.global_position) <= front_contact_dist
	if not hit_ready:
		return
	pierce_hit_applied = true
	var base_damage: float = _get_base_attack_damage()
	var pierce_mul: float = pierce_damage_mul_charge if skill_id == SkillType.CHARGE else pierce_damage_mul_breakthrough
	var role_mul: float = _get_role_counter_damage_mul_to(skill_target)
	var height_mul: float = _get_height_attack_mul_to(skill_target)
	var damage: float = base_damage * maxf(0.5, pierce_mul) * role_mul * height_mul
	var impact_knockback: float = 2.8 if skill_id == SkillType.CHARGE else breakthrough_front_knockback_distance
	var impact_lift: float = 1.55 if skill_id == SkillType.CHARGE else breakthrough_split_lift_mul
	var impact_side: float = 0.0
	var impact_side_mul: float = 1.0 if skill_id == SkillType.CHARGE else 0.0
	var allow_chain_reaction: bool = skill_id == SkillType.CHARGE
	skill_target.apply_pierce_impact(
		damage,
		pierce_morale_shock,
		pierce_confusion_chance,
		pierce_slow_chance,
		pierce_confusion_duration,
		pierce_slow_duration,
		self,
		impact_knockback,
		impact_lift,
		impact_side,
		impact_side_mul,
		allow_chain_reaction
	)
	var success_forward: Vector3 = get_collision_forward_flat()
	var success_radius: float = maxf(2.2, skill_target.get_activity_radius() * 0.72)
	_trigger_sweep_impact_vfx(skill_target.global_position, success_radius, success_forward)
	if not skill_success_triggered:
		skill_success_triggered = true
		_trigger_skill_success_vfx(skill_id, skill_target.global_position, success_forward, 1.0 if skill_id == SkillType.CHARGE else 1.12)

func apply_pierce_impact(
	damage: float,
	morale_loss: float,
	confuse_chance: float,
	slow_chance: float,
	confuse_duration: float,
	slow_duration: float,
	source: UnitController,
	knockback_distance: float = 0.0,
	lift_mul: float = 1.0,
	side_push_distance: float = 0.0,
	side_visual_mul: float = 1.0,
	allow_chain_reaction: bool = true
) -> void:
	receive_damage(maxf(0.0, damage), source, true)
	_apply_morale_delta(-absf(morale_loss), true)
	if source != null:
		var split_forward: Vector3 = source.get_collision_forward_flat()
		start_charge_split_reaction(split_forward, lift_mul, 1.0 + knockback_distance * 0.22, side_visual_mul)
		if lift_mul >= 1.85:
			start_impact_launch(split_forward, lift_mul)
		if allow_chain_reaction and battlefield != null and battlefield.has_method("get_enemies_in_radius"):
			var reaction_radius: float = maxf(5.0, get_activity_radius() * 1.2)
			var impacted: Array = battlefield.call("get_enemies_in_radius", global_position, reaction_radius, source.team_id)
			for other_any in impacted:
				if not (other_any is UnitController):
					continue
				var other: UnitController = other_any
				if other == self or other.dead:
					continue
				other.start_charge_split_reaction(split_forward, lift_mul * 0.82, 0.92 + knockback_distance * 0.12, lerpf(1.0, side_visual_mul, 0.78))
	if randf() <= clampf(confuse_chance, 0.0, 1.0):
		apply_status(StatusId.CONFUSION, maxf(0.1, confuse_duration))
	if randf() <= clampf(slow_chance, 0.0, 1.0):
		apply_status(StatusId.SLOWED, maxf(0.1, slow_duration))
	if source != null:
		var push_dir: Vector3 = source.get_collision_forward_flat()
		push_dir.y = 0.0
		if push_dir.length_squared() > EPS:
			var push_flat: Vector3 = push_dir.normalized()
			if knockback_distance > 0.001:
				pending_displacement += push_flat * knockback_distance
			if side_push_distance > 0.001:
				var side_dir := Vector3(push_flat.z, 0.0, -push_flat.x)
				if side_dir.length_squared() > EPS:
					side_dir = side_dir.normalized()
					var rel := global_position - source.global_position
					rel.y = 0.0
					var side_sign: float = signf(rel.dot(side_dir))
					if absf(side_sign) <= 0.001:
						side_sign = -1.0 if get_instance_id() % 2 == 0 else 1.0
					pending_displacement += side_dir * side_sign * side_push_distance
	_check_rout_conditions()

func start_charge_split_reaction(source_forward: Vector3, lift_mul: float = 1.0, back_mul: float = 1.0, side_mul: float = 1.0) -> void:
	if soldiers_mm == null or soldiers_mmi == null:
		return
	var local_forward: Vector3 = global_basis.inverse() * source_forward
	local_forward.y = 0.0
	if local_forward.length_squared() <= EPS:
		local_forward = Vector3.FORWARD
	else:
		local_forward = local_forward.normalized()
	var side_local := Vector3(local_forward.z, 0.0, -local_forward.x)
	if side_local.length_squared() <= EPS:
		side_local = Vector3.RIGHT
	else:
		side_local = side_local.normalized()
	charge_split_reaction_forward_local = local_forward
	charge_split_reaction_side_local = side_local
	charge_split_reaction_total = maxf(0.08, charge_split_reaction_duration)
	charge_split_reaction_timer = charge_split_reaction_total
	charge_split_reaction_lift_mul = maxf(0.0, lift_mul)
	charge_split_reaction_back_mul = maxf(0.0, back_mul)
	charge_split_reaction_side_mul = maxf(0.0, side_mul)

func _update_charge_split_reaction_visual(delta: float) -> void:
	if soldiers_mm == null or soldiers_mmi == null:
		return
	if charge_split_reaction_timer <= 0.0:
		return
	charge_split_reaction_timer = maxf(0.0, charge_split_reaction_timer - maxf(0.0, delta))
	var total: float = maxf(0.001, charge_split_reaction_total)
	var p: float = clampf(1.0 - charge_split_reaction_timer / total, 0.0, 1.0)
	var pulse: float = sin(p * PI)
	var base_basis := _sanitize_basis_for_instances(soldier_mesh_basis.scaled(Vector3.ONE * soldier_visual_scale))
	var side_local: Vector3 = charge_split_reaction_side_local
	var forward_local: Vector3 = charge_split_reaction_forward_local
	var half_width: float = maxf(0.4, _compute_offsets_width(current_offsets) * 0.5)
	for i in soldier_count:
		var fallback_off: Vector3 = home_offsets[i] if i < home_offsets.size() else Vector3.ZERO
		var base_off: Vector3 = _sanitize_local_offset(current_offsets[i], fallback_off)
		var lateral_pos: float = base_off.dot(side_local)
		var side_sign: float = signf(lateral_pos)
		if absf(side_sign) <= 0.001:
			side_sign = -1.0 if i % 2 == 0 else 1.0
		var edge_factor: float = clampf(absf(lateral_pos) / half_width, 0.24, 1.0)
		var local_target: Vector3 = base_off
		var spread: Vector3 = side_local * side_sign * charge_split_side_push * charge_split_reaction_side_mul * pulse * edge_factor
		var shove_back: Vector3 = -forward_local * charge_split_back_push * charge_split_reaction_back_mul * pulse * (0.45 + edge_factor * 0.3)
		local_target = _sanitize_local_offset(local_target + spread + shove_back, base_off)
		var lift_y: float = pulse * charge_split_reaction_lift_mul * (0.48 + edge_factor * 0.82)
		if not _is_finite_float(lift_y):
			lift_y = 0.0
		_set_soldier_instance_transform_safe(i, base_basis, Vector3(local_target.x, 0.68 + lift_y, local_target.z))
	if charge_split_reaction_timer <= 0.0:
		_apply_offsets_immediate(current_offsets, false, true)

func start_impact_launch(source_forward: Vector3, lift_mul: float = 1.0) -> void:
	var forward: Vector3 = source_forward
	forward.y = 0.0
	if forward.length_squared() <= EPS:
		forward = get_collision_forward_flat()
	forward = global_basis.inverse() * forward.normalized()
	forward.y = 0.0
	if forward.length_squared() <= EPS:
		forward = Vector3.FORWARD
	impact_launch_forward_local = forward.normalized()
	impact_launch_total = maxf(0.18, impact_launch_duration * lerpf(0.94, 1.14, clampf((lift_mul - 1.0) / 1.8, 0.0, 1.0)))
	impact_launch_timer = impact_launch_total
	impact_launch_height_current = maxf(1.4, impact_launch_height * maxf(1.0, lift_mul * 0.86))
	impact_launch_landing_triggered = false

func _apply_impact_launch_transform(y_offset: float, forward_offset: float) -> void:
	if soldiers_mmi != null and is_instance_valid(soldiers_mmi):
		soldiers_mmi.position = Vector3(0.0, y_offset, forward_offset)
	if status_vfx_root != null and is_instance_valid(status_vfx_root):
		status_vfx_root.position = Vector3(0.0, paralyzed_vfx_height + y_offset, forward_offset)

func _update_impact_launch_visual(delta: float) -> void:
	if impact_launch_timer <= 0.0:
		_apply_impact_launch_transform(0.0, 0.0)
		return
	impact_launch_timer = maxf(0.0, impact_launch_timer - maxf(0.0, delta))
	var total: float = maxf(0.001, impact_launch_total)
	var p: float = clampf(1.0 - impact_launch_timer / total, 0.0, 1.0)
	var hold_ratio: float = clampf(impact_launch_peak_hold_ratio, 0.0, 0.35)
	var rise_end: float = clampf((1.0 - hold_ratio) * 0.5, 0.18, 0.48)
	var fall_start: float = clampf(1.0 - rise_end, 0.52, 0.9)
	var y_norm: float = 0.0
	if p < rise_end:
		var local_rise: float = p / maxf(0.001, rise_end)
		y_norm = sin(local_rise * PI * 0.5)
	elif p < fall_start:
		y_norm = 1.0
	else:
		var local_fall: float = (p - fall_start) / maxf(0.001, 1.0 - fall_start)
		y_norm = cos(local_fall * PI * 0.5)
	var y_offset: float = y_norm * impact_launch_height_current
	var drift: float = ease(p, 0.78) * impact_launch_forward_drift * (0.9 + y_norm * 0.3)
	_apply_impact_launch_transform(y_offset, drift)
	if not impact_launch_landing_triggered and p >= 0.84:
		impact_launch_landing_triggered = true
		var dust_forward: Vector3 = global_basis * impact_launch_forward_local
		_trigger_sweep_impact_vfx(global_position, maxf(1.8, get_activity_radius() * impact_launch_landing_dust_scale), dust_forward)
	if impact_launch_timer <= 0.0:
		impact_launch_landing_triggered = false
		_apply_impact_launch_transform(0.0, 0.0)

func _apply_sweep_hits() -> void:
	if battlefield == null or not battlefield.has_method("get_enemies_in_radius"):
		return
	var center: Vector3 = global_position
	var lock_target: UnitController = skill_target if skill_target != null and is_instance_valid(skill_target) and not skill_target.dead else null
	if lock_target != null:
		center = lock_target.global_position
	var face := motion_dir if motion_dir.length_squared() > EPS else _resolve_skill_forward()
	if face.length_squared() <= EPS:
		face = get_collision_forward_flat()
	var hit: float = _get_base_attack_damage() * sweep_damage_mul * 1.18
	var effect_radius: float = maxf(sweep_radius, get_collision_half_extents().x * 1.2)
	if not sweep_impact_triggered:
		sweep_impact_triggered = true
		_trigger_sweep_impact_vfx(center, effect_radius, face)
	var enemies: Array = battlefield.call("get_enemies_in_radius", center, effect_radius, team_id)
	for enemy_any in enemies:
		if not (enemy_any is UnitController):
			continue
		var enemy: UnitController = enemy_any
		if enemy.dead:
			continue
		var to_enemy := enemy.global_position - center
		to_enemy.y = 0.0
		if to_enemy.length_squared() <= EPS:
			_apply_tactic_damage_to(enemy, hit * 1.08, true)
			enemy.apply_status(StatusId.PARALYZED, maxf(0.4, sweep_stun_duration))
			if not skill_success_triggered:
				skill_success_triggered = true
				_trigger_skill_success_vfx(SkillType.SWEEP, center, face, 1.08)
			continue
		var frontal: float = to_enemy.normalized().dot(face)
		if enemy != lock_target and frontal < -0.55:
			continue
		var distance_mul: float = 1.0 - clampf(to_enemy.length() / maxf(0.1, effect_radius), 0.0, 1.0) * 0.22
		_apply_tactic_damage_to(enemy, hit * distance_mul, true)
		enemy.apply_status(StatusId.PARALYZED, maxf(0.4, sweep_stun_duration))
		if not skill_success_triggered:
			skill_success_triggered = true
			_trigger_skill_success_vfx(SkillType.SWEEP, center, face, 1.08)
		if enemy.has_method("start_charge_split_reaction"):
			enemy.call("start_charge_split_reaction", -to_enemy.normalized(), 0.72, 0.82, 1.12)
func _trigger_skill_success_once(skill_id: SkillType, world_center: Vector3, forward_dir: Vector3, scale_mul: float = 1.0) -> void:
	if skill_success_triggered:
		return
	skill_success_triggered = true
	_trigger_skill_success_vfx(skill_id, world_center, forward_dir, scale_mul)

func _clear_shield_skill_buff() -> void:
	shield_skill_buff_timer = 0.0
	shield_skill_defense_mul = 1.0
	shield_skill_speed_mul = 1.0
	shield_skill_attack_mul = 1.0
	shield_skill_absorb_pool = 0.0
	shield_skill_force_end_timer = 0.0
	if state != UnitState.SKILL_FORM and state != UnitState.SKILL_EXEC and not home_offsets.is_empty():
		transition_restore_home_lock = true
		_start_staged_transition(home_offsets, 0.42, 16, false)

func _has_persistent_shield_formation() -> bool:
	if not _is_shield_role():
		return false
	return shield_skill_buff_timer < 0.0 or shield_skill_buff_timer > 0.001 or shield_skill_absorb_pool > 0.001

func _activate_shield_skill_buff(
	defense_mul: float,
	speed_mul: float,
	duration_sec: float,
	attack_mul: float = 1.0,
	absorb_pool: float = 0.0,
	persistent_until_absorb: bool = false,
	force_end_sec: float = 0.0
) -> void:
	shield_skill_buff_timer = maxf(shield_skill_buff_timer, duration_sec)
	if persistent_until_absorb:
		shield_skill_buff_timer = -1.0
	shield_skill_defense_mul = maxf(shield_skill_defense_mul, maxf(0.05, defense_mul))
	shield_skill_speed_mul = minf(shield_skill_speed_mul, clampf(speed_mul, 0.1, 1.0))
	shield_skill_attack_mul = minf(shield_skill_attack_mul, clampf(attack_mul, 0.1, 1.4))
	if absorb_pool > 0.0:
		shield_skill_absorb_pool = maxf(shield_skill_absorb_pool, absorb_pool)
	if force_end_sec > 0.0:
		shield_skill_force_end_timer = maxf(shield_skill_force_end_timer, force_end_sec)

func _tick_shield_skill_effects(delta: float) -> void:
	if shield_skill_force_end_timer > 0.0:
		shield_skill_force_end_timer = maxf(0.0, shield_skill_force_end_timer - maxf(0.0, delta))
		if shield_skill_force_end_timer <= 0.001 and _has_persistent_shield_formation():
			_clear_shield_skill_buff()
			return
	if shield_skill_buff_timer < 0.0:
		if shield_skill_absorb_pool <= 0.001:
			_clear_shield_skill_buff()
		return
	if shield_skill_buff_timer <= 0.0:
		return
	shield_skill_buff_timer = maxf(0.0, shield_skill_buff_timer - maxf(0.0, delta))
	if shield_skill_buff_timer <= 0.001:
		_clear_shield_skill_buff()

func apply_taunt(source: UnitController, duration_sec: float) -> void:
	if dead:
		return
	if source == null or source.dead or source.team_id == team_id:
		return
	if command_mode == CommandMode.RETREAT:
		return
	taunt_source_unit = source
	taunt_timer = maxf(taunt_timer, maxf(0.0, duration_sec))
	_enforce_taunt_target()

func _tick_taunt(delta: float) -> void:
	if taunt_timer <= 0.0:
		taunt_source_unit = null
		return
	taunt_timer = maxf(0.0, taunt_timer - maxf(0.0, delta))
	if taunt_source_unit == null or not is_instance_valid(taunt_source_unit) or taunt_source_unit.dead or taunt_source_unit.team_id == team_id:
		taunt_source_unit = null
		taunt_timer = 0.0
		return
	if command_mode == CommandMode.RETREAT:
		taunt_source_unit = null
		taunt_timer = 0.0
		return
	_enforce_taunt_target()
	if taunt_timer <= 0.001:
		taunt_source_unit = null

func _enforce_taunt_target() -> void:
	if taunt_source_unit == null or not is_instance_valid(taunt_source_unit) or taunt_source_unit.dead:
		return
	if taunt_source_unit.team_id == team_id or command_mode == CommandMode.RETREAT:
		return
	manual_priority_target_unit = taunt_source_unit
	target_unit = taunt_source_unit
	chase_target_unit = taunt_source_unit
	chase_fallback_point = taunt_source_unit.global_position
	if nav_mode != NavMode.CHASE_TARGET:
		chase_origin_point = global_position
	nav_mode = NavMode.CHASE_TARGET
	has_move_target = false
	attack_move_active = false
	retreat_destination = Vector3.INF
	if state == UnitState.IDLE:
		attack_timer = minf(attack_timer, 0.05)
		_enter_state(UnitState.MOVE)

func _compute_shield_bash_goal(active_skill_target: UnitController) -> Vector3:
	var goal: Vector3 = global_position
	goal.y = global_position.y
	if active_skill_target == null or active_skill_target.dead:
		return goal
	var to_target: Vector3 = active_skill_target.global_position - global_position
	to_target.y = 0.0
	if to_target.length_squared() <= EPS:
		return goal
	var dir: Vector3 = to_target.normalized()
	var desired_center_dist: float = get_collision_half_extents().y + active_skill_target.get_collision_half_extents().y + maxf(0.18, shield_bash_trigger_range * 0.45)
	if to_target.length() <= desired_center_dist:
		return goal
	goal = active_skill_target.global_position - dir * desired_center_dist
	goal.y = global_position.y
	return goal

func _apply_shield_wall_hit(active_skill_target: UnitController) -> void:
	if pierce_hit_applied:
		return
	pierce_hit_applied = true
	var guard_pool: float = maxf(0.0, shield_wall_guard_absorb_flat) + maxf(0.0, shield_wall_guard_absorb_hp_mul) * maxf(1.0, max_hp)
	_activate_shield_skill_buff(
		shield_wall_buff_defense_mul,
		shield_wall_buff_speed_mul,
		maxf(0.2, shield_wall_buff_duration),
		shield_wall_buff_attack_mul,
		maxf(120.0, guard_pool),
		true,
		maxf(0.2, shield_wall_guard_max_duration)
	)
	var face: Vector3 = _resolve_skill_forward()
	if active_skill_target != null and not active_skill_target.dead:
		face = _flat_dir_to(global_position, active_skill_target.global_position)
	if face.length_squared() <= EPS:
		face = get_collision_forward_flat()
	var success_pos: Vector3 = global_position + face * maxf(0.8, get_collision_half_extents().y * 0.35)
	if active_skill_target != null and not active_skill_target.dead:
		var to_target: Vector3 = active_skill_target.global_position - global_position
		to_target.y = 0.0
		var hit_distance: float = get_collision_half_extents().y + active_skill_target.get_collision_half_extents().y + maxf(0.1, shield_wall_trigger_range)
		var frontal: float = 1.0
		if to_target.length_squared() > EPS:
			frontal = to_target.normalized().dot(face)
		if to_target.length() <= hit_distance and frontal >= -0.18:
			var hit: float = _get_base_attack_damage() * shield_wall_damage_mul
			_apply_tactic_damage_to(active_skill_target, hit, true)
			active_skill_target._apply_morale_delta(-absf(pierce_morale_shock * 0.52), true)
			active_skill_target.apply_status(StatusId.SLOWED, maxf(0.2, shield_wall_slow_duration))
			if active_skill_target.has_method("start_charge_split_reaction"):
				active_skill_target.call("start_charge_split_reaction", face, 0.0, 0.18, 0.0)
			success_pos = active_skill_target.global_position
	_trigger_sweep_impact_vfx(success_pos, maxf(2.2, get_activity_radius() * 0.72), face)
	_trigger_skill_success_once(SkillType.CHARGE, success_pos, face, 1.12)

func _try_apply_shield_bash_hit(active_skill_target: UnitController) -> void:
	if pierce_hit_applied or active_skill_target == null or active_skill_target.dead:
		return
	var hit_distance: float = get_collision_half_extents().y + active_skill_target.get_collision_half_extents().y + maxf(0.12, shield_bash_trigger_range)
	if _flat_distance_to(active_skill_target.global_position) > hit_distance:
		return
	pierce_hit_applied = true
	var face: Vector3 = _flat_dir_to(global_position, active_skill_target.global_position)
	if face.length_squared() <= EPS:
		face = get_collision_forward_flat()
	var hit: float = _get_base_attack_damage() * shield_bash_damage_mul
	_apply_tactic_damage_to(active_skill_target, hit, true)
	active_skill_target._apply_morale_delta(-absf(pierce_morale_shock * 0.86), true)
	active_skill_target.apply_status(StatusId.PARALYZED, maxf(0.2, shield_bash_stun_duration))
	active_skill_target.apply_status(StatusId.SLOWED, maxf(0.2, shield_bash_slow_duration))
	active_skill_target.pending_displacement += face * maxf(0.0, shield_bash_knockback_distance)
	if active_skill_target.has_method("start_charge_split_reaction"):
		active_skill_target.call("start_charge_split_reaction", face, 0.22, 0.58, 0.22)
	_trigger_sweep_impact_vfx(active_skill_target.global_position, maxf(2.4, active_skill_target.get_activity_radius() * 0.78), face)
	_trigger_skill_success_once(SkillType.BREAKTHROUGH, active_skill_target.global_position, face, 1.16)

func _apply_shield_tortoise_hit(active_skill_target: UnitController) -> void:
	if sweep_impact_triggered:
		return
	sweep_impact_triggered = true
	_activate_shield_skill_buff(
		shield_tortoise_buff_defense_mul,
		shield_tortoise_buff_speed_mul,
		maxf(0.2, shield_tortoise_buff_duration),
		shield_tortoise_buff_attack_mul,
		0.0,
		false,
		maxf(0.2, shield_tortoise_guard_max_duration)
	)
	var center: Vector3 = global_position
	var face: Vector3 = _resolve_skill_forward()
	if active_skill_target != null and not active_skill_target.dead:
		face = _flat_dir_to(global_position, active_skill_target.global_position)
	if face.length_squared() <= EPS:
		face = get_collision_forward_flat()
	var effect_radius: float = maxf(2.4, shield_tortoise_radius)
	if battlefield != null and battlefield.has_method("get_enemies_in_radius"):
		var enemies: Array = battlefield.call("get_enemies_in_radius", center, effect_radius, team_id)
		for enemy_any in enemies:
			if not (enemy_any is UnitController):
				continue
			var enemy: UnitController = enemy_any
			if enemy.dead:
				continue
			var dist: float = enemy.global_position.distance_to(center)
			var falloff: float = clampf(1.0 - dist / maxf(0.001, effect_radius * 1.2), 0.36, 1.0)
			var hit: float = _get_base_attack_damage() * shield_tortoise_damage_mul * falloff
			_apply_tactic_damage_to(enemy, hit, true)
			enemy._apply_morale_delta(-absf(pierce_morale_shock * 0.38 * falloff), true)
			enemy.apply_status(StatusId.SLOWED, maxf(0.2, shield_tortoise_slow_duration * falloff))
			enemy.apply_taunt(self, maxf(0.2, shield_tortoise_taunt_duration * falloff))
			if enemy.has_method("start_charge_split_reaction"):
				var to_enemy: Vector3 = enemy.global_position - center
				to_enemy.y = 0.0
				if to_enemy.length_squared() > EPS:
					enemy.call("start_charge_split_reaction", to_enemy.normalized(), 0.0, 0.16, 0.56)
	_trigger_sweep_impact_vfx(center, maxf(3.0, effect_radius * 0.9), face)
	_trigger_skill_success_once(SkillType.SWEEP, center, face, 1.22)

func _apply_tactic_hit_reaction_preset(target: UnitController, source_forward: Vector3, preset: String) -> void:
	if target == null or target.dead:
		return
	match preset:
		"brace_stagger":
			if target.has_method("start_charge_split_reaction"):
				target.call("start_charge_split_reaction", source_forward, 0.0, 0.22, 0.0)
		_:
			return
func _try_apply_spear_brace_hit(active_skill_target: UnitController) -> void:
	if pierce_hit_applied or active_skill_target == null or active_skill_target.dead:
		return
	var to_target: Vector3 = active_skill_target.global_position - global_position
	to_target.y = 0.0
	if to_target.length_squared() <= EPS:
		return
	var face: Vector3 = get_collision_forward_flat()
	var frontal: float = to_target.normalized().dot(face)
	var hit_distance: float = get_collision_half_extents().y + active_skill_target.get_collision_half_extents().y + maxf(0.8, spear_brace_trigger_range)
	if to_target.length() > hit_distance or frontal < 0.18:
		return
	pierce_hit_applied = true
	var damage: float = _get_base_attack_damage() * spear_brace_damage_mul * _get_role_counter_damage_mul_to(active_skill_target) * _get_height_attack_mul_to(active_skill_target)
	_apply_tactic_damage_to(active_skill_target, damage, true)
	active_skill_target._apply_morale_delta(-absf(pierce_morale_shock * 1.1), true)
	active_skill_target.apply_status(StatusId.SLOWED, maxf(0.2, pierce_slow_duration * 0.55))
	var effect_forward: Vector3 = face if face.length_squared() > EPS else _resolve_skill_forward()
	_apply_tactic_hit_reaction_preset(active_skill_target, effect_forward, "brace_stagger")
	_trigger_sweep_impact_vfx(active_skill_target.global_position, maxf(2.6, active_skill_target.get_activity_radius() * 0.7), effect_forward)
	_trigger_skill_success_once(SkillType.CHARGE, active_skill_target.global_position, effect_forward, 1.18)
func _try_apply_spear_lunge_hit(active_skill_target: UnitController) -> void:
	if pierce_hit_applied or active_skill_target == null or active_skill_target.dead:
		return
	var hit_distance: float = get_collision_half_extents().y + active_skill_target.get_collision_half_extents().y + 0.55
	if _flat_distance_to(active_skill_target.global_position) > hit_distance:
		return
	pierce_hit_applied = true
	var face: Vector3 = get_collision_forward_flat()
	var damage: float = _get_base_attack_damage() * breakthrough_damage_mul * 0.96 * _get_role_counter_damage_mul_to(active_skill_target) * _get_height_attack_mul_to(active_skill_target)
	active_skill_target.apply_pierce_impact(damage, pierce_morale_shock * 1.18, 0.2, 0.72, maxf(0.2, pierce_confusion_duration * 0.45), maxf(0.2, pierce_slow_duration * 0.55), self, spear_lunge_knockback_distance, spear_lunge_lift_mul, 0.0, 0.0, false)
	active_skill_target.apply_status(StatusId.PARALYZED, maxf(0.2, sweep_stun_duration * 0.42))
	_trigger_sweep_impact_vfx(active_skill_target.global_position, maxf(2.8, active_skill_target.get_activity_radius() * 0.82), face)
	_trigger_skill_success_once(SkillType.BREAKTHROUGH, active_skill_target.global_position, face, 1.2)

func _apply_archer_volley_hit(active_skill_target: UnitController) -> void:
	if pierce_hit_applied or active_skill_target == null or active_skill_target.dead:
		return
	pierce_hit_applied = true
	var face: Vector3 = _flat_dir_to(global_position, active_skill_target.global_position)
	if face.length_squared() <= EPS:
		face = _resolve_skill_forward()
	if _is_crossbow_role():
		var volley_wave_delays: Array = [0.0, 0.12, 0.24]
		_emit_archer_skill_trace(
			active_skill_target,
			11,
			volley_wave_delays,
			0.52,
			0.36,
			0.78,
			0.88,
			0.36,
			0.6,
			Color(0.8, 0.9, 1.0, 1.0),
			Color(0.94, 0.97, 1.0, 1.0),
			true
		)
		_set_archer_skill_fire_lock(volley_wave_delays)
		var crossbow_hit: float = _get_base_attack_damage() * archer_damage_mul * crossbow_skill_volley_damage_mul
		_apply_tactic_damage_to(active_skill_target, crossbow_hit, true)
		active_skill_target._apply_morale_delta(-absf(pierce_morale_shock * 0.82), true)
		active_skill_target.apply_status(StatusId.SLOWED, maxf(0.18, crossbow_skill_volley_slow_duration))
		active_skill_target.apply_status(StatusId.PARALYZED, maxf(0.12, crossbow_skill_volley_paralyze_duration))
		_trigger_sweep_impact_vfx(active_skill_target.global_position, maxf(2.4, active_skill_target.get_activity_radius() * 0.74), face)
		_trigger_skill_success_once(SkillType.CHARGE, active_skill_target.global_position, face, 1.14)
		return
	_emit_archer_skill_trace(
		active_skill_target,
		9,
		[0.0, 0.1, 0.2],
		0.7,
		0.58,
		1.1,
		0.95,
		0.45,
		0.82,
		Color(1.0, 0.36, 0.1, 1.0),
		Color(1.0, 0.88, 0.34, 1.0)
	)
	_set_archer_skill_fire_lock([0.0, 0.1, 0.2])
	var hit: float = _get_base_attack_damage() * archer_damage_mul * archer_skill_volley_damage_mul
	_apply_tactic_damage_to(active_skill_target, hit, true)
	active_skill_target._apply_morale_delta(-absf(pierce_morale_shock * 0.72), true)
	active_skill_target.apply_burn(maxf(0.2, archer_skill_fire_arrow_burn_duration), maxf(0.0, archer_skill_fire_arrow_burn_dps), team_id)
	_trigger_sweep_impact_vfx(active_skill_target.global_position, maxf(2.2, active_skill_target.get_activity_radius() * 0.66), face)
	_trigger_skill_success_once(SkillType.CHARGE, active_skill_target.global_position, face, 1.08)

func _apply_archer_pierce_hit(active_skill_target: UnitController) -> void:
	if pierce_hit_applied or active_skill_target == null or active_skill_target.dead:
		return
	pierce_hit_applied = true
	var face: Vector3 = _flat_dir_to(global_position, active_skill_target.global_position)
	if face.length_squared() <= EPS:
		face = _resolve_skill_forward()
	var is_crossbow: bool = _is_crossbow_role()
	var pierce_wave_delays: Array = [0.0, 0.05] if is_crossbow else [0.0, 0.08]
	if is_crossbow:
		_emit_archer_skill_trace(active_skill_target, 10, pierce_wave_delays, 0.5, 0.18, 0.78, 0.68, 1.46, 0.58, Color(0.82, 0.92, 1.0, 1.0), Color(0.98, 1.0, 1.0, 1.0), true)
	else:
		_emit_archer_skill_trace(active_skill_target, 12, pierce_wave_delays, 0.55, 0.28, 0.96, 0.82, 1.28, 0.64, Color(1.0, 0.98, 0.9, 1.0), Color(1.0, 0.98, 0.9, 1.0), true)
	_set_archer_skill_fire_lock(pierce_wave_delays)
	var targets: Array[UnitController] = [active_skill_target]
	if battlefield != null and battlefield.has_method("get_enemies_in_radius"):
		var ctx: Dictionary = _get_archer_frontline_context(active_skill_target)
		var own_front: float = float(ctx.get("own_front", 0.0))
		var line_start: Vector3 = global_position + face * own_front
		var to_primary: Vector3 = active_skill_target.global_position - line_start
		to_primary.y = 0.0
		var primary_forward: float = maxf(0.0, to_primary.dot(face))
		var primary_half: Vector2 = active_skill_target.get_collision_half_extents()
		var enemy_len: float = maxf(2.0, primary_half.y * 2.0)
		var cover_units_cap: int = maxi(1, crossbow_skill_pierce_cover_units if is_crossbow else archer_skill_pierce_cover_units)
		var min_reach_after_primary: float = enemy_len * float(maxi(0, cover_units_cap - 1)) + enemy_len * 0.7
		var pierce_depth: float = crossbow_skill_pierce_depth if is_crossbow else archer_skill_pierce_depth
		var pierce_width: float = crossbow_skill_pierce_width if is_crossbow else archer_skill_pierce_width
		var forward_reach_after_primary: float = maxf(maxf(0.0, pierce_depth), min_reach_after_primary)
		var line_depth: float = primary_forward + forward_reach_after_primary
		var back_allow: float = maxf(1.0, own_front * 0.45)
		var query_center: Vector3 = line_start + face * (line_depth * 0.5)
		var query_radius: float = maxf(7.0, line_depth * 0.54 + pierce_width * 1.25 + enemy_len * 0.35)
		var side_vec: Vector3 = Vector3(-face.z, 0.0, face.x)
		if side_vec.length_squared() <= EPS:
			side_vec = Vector3.RIGHT
		side_vec = side_vec.normalized()
		for enemy_any in battlefield.call("get_enemies_in_radius", query_center, query_radius, team_id):
			if not (enemy_any is UnitController):
				continue
			var enemy: UnitController = enemy_any
			if enemy == active_skill_target or enemy.dead:
				continue
			var rel: Vector3 = enemy.global_position - line_start
			rel.y = 0.0
			var forward_dist: float = rel.dot(face)
			var enemy_half: Vector2 = enemy.get_collision_half_extents()
			var forward_pad: float = maxf(0.6, enemy_half.y * 0.72)
			if forward_dist < -back_allow - forward_pad or forward_dist > line_depth + forward_pad:
				continue
			var side_dist: float = absf(rel.dot(side_vec))
			var side_pad: float = maxf(0.3, enemy_half.x * 0.86)
			if side_dist > pierce_width + side_pad:
				continue
			if targets.has(enemy):
				continue
			targets.append(enemy)
	var hit_mul: float = crossbow_skill_pierce_damage_mul if is_crossbow else archer_skill_pierce_damage_mul
	var hit: float = _get_base_attack_damage() * archer_damage_mul * hit_mul
	for i in range(targets.size()):
		var enemy: UnitController = targets[i]
		var mul: float = 1.0 if i == 0 else (maxf(0.64, 0.92 - float(i) * 0.09) if is_crossbow else maxf(0.58, 0.86 - float(i) * 0.1))
		_apply_tactic_damage_to(enemy, hit * mul, true)
		enemy._apply_morale_delta(-absf(pierce_morale_shock * (0.64 if is_crossbow else 0.58) * mul), true)
		if is_crossbow:
			enemy.apply_status(StatusId.SLOWED, maxf(0.18, crossbow_skill_pierce_slow_duration * mul))
			if i == 0:
				enemy.apply_status(StatusId.PARALYZED, maxf(0.12, crossbow_skill_pierce_paralyze_duration))
	_trigger_sweep_impact_vfx(active_skill_target.global_position, maxf(2.6, active_skill_target.get_activity_radius() * (0.82 if is_crossbow else 0.74)), face)
	_trigger_skill_success_once(SkillType.BREAKTHROUGH, active_skill_target.global_position, face, 1.2 if is_crossbow else 1.16)

func _apply_archer_barrage_hit(active_skill_target: UnitController) -> void:
	if sweep_impact_triggered or active_skill_target == null or active_skill_target.dead:
		return
	sweep_impact_triggered = true
	var face: Vector3 = _flat_dir_to(global_position, active_skill_target.global_position)
	if face.length_squared() <= EPS:
		face = _resolve_skill_forward()
	var is_crossbow: bool = _is_crossbow_role()
	# Barrage should be clearly readable as 3 distinct waves.
	var barrage_wave_delays: Array = [0.0, 0.26, 0.52] if is_crossbow else [0.0, 0.34, 0.68]
	if is_crossbow:
		_emit_archer_skill_trace(
			active_skill_target,
			12,
			barrage_wave_delays,
			0.84,
			1.62,
			1.14,
			1.18,
			1.08,
			0.86,
			Color(0.8, 0.9, 1.0, 1.0),
			Color(0.96, 0.99, 1.0, 1.0),
			true
		)
	else:
		_emit_archer_skill_trace(
			active_skill_target,
			14,
			barrage_wave_delays,
			1.05,
			2.35,
			1.95,
			1.52,
			1.38,
			1.04,
			Color(1.0, 0.44, 0.08, 1.0),
			Color(1.0, 0.9, 0.3, 1.0)
		)
	_set_archer_skill_fire_lock(barrage_wave_delays)
	var barrage_damage_mul: float = crossbow_skill_barrage_damage_mul if is_crossbow else archer_skill_barrage_damage_mul
	var barrage_radius: float = crossbow_skill_barrage_radius if is_crossbow else archer_skill_barrage_radius
	var barrage_slow_duration: float = crossbow_skill_barrage_slow_duration if is_crossbow else archer_skill_barrage_slow_duration
	var hit: float = _get_base_attack_damage() * archer_damage_mul * barrage_damage_mul
	var impacted: Array = [active_skill_target]
	if battlefield != null and battlefield.has_method("get_enemies_in_radius"):
		impacted = battlefield.call("get_enemies_in_radius", active_skill_target.global_position, maxf(2.4, barrage_radius), team_id)
	for enemy_any in impacted:
		if not (enemy_any is UnitController):
			continue
		var enemy: UnitController = enemy_any
		if enemy.dead:
			continue
		var dist: float = enemy.global_position.distance_to(active_skill_target.global_position)
		var falloff: float = clampf(1.0 - dist / maxf(0.001, barrage_radius * 1.15), 0.38, 1.0)
		_apply_tactic_damage_to(enemy, hit * falloff, true)
		enemy._apply_morale_delta(-absf(pierce_morale_shock * (0.46 if is_crossbow else 0.4) * falloff), true)
		enemy.apply_status(StatusId.SLOWED, maxf(0.18, barrage_slow_duration * falloff))
		if is_crossbow and dist <= barrage_radius * 0.42:
			enemy.apply_status(StatusId.PARALYZED, maxf(0.12, crossbow_skill_barrage_paralyze_duration * falloff))
	_trigger_sweep_impact_vfx(active_skill_target.global_position, maxf(3.9, barrage_radius * 0.96), face)
	_trigger_skill_success_once(SkillType.SWEEP, active_skill_target.global_position, face, 1.2 if is_crossbow else 1.26)

func _compute_spear_hook_goal(active_skill_target: UnitController) -> Vector3:
	var forward: Vector3 = _resolve_skill_forward()
	var target_pos: Vector3 = global_position + forward * maxf(3.2, sweep_forward_distance * 0.7)
	if active_skill_target != null:
		target_pos = active_skill_target.global_position - forward * maxf(0.8, active_skill_target.get_collision_half_extents().y * 0.18)
	var goal: Vector3 = target_pos
	goal.y = global_position.y
	return goal

func _compute_spear_throw_goal(active_skill_target: UnitController) -> Vector3:
	var goal: Vector3 = global_position
	goal.y = global_position.y
	if active_skill_target == null:
		return goal
	var to_target: Vector3 = active_skill_target.global_position - global_position
	to_target.y = 0.0
	if to_target.length_squared() <= EPS:
		return goal
	var dir: Vector3 = to_target.normalized()
	var desired_center_dist: float = maxf(2.8, spear_throw_range)
	var flat_dist: float = to_target.length()
	if flat_dist <= desired_center_dist:
		return goal
	goal = active_skill_target.global_position - dir * desired_center_dist
	goal.y = global_position.y
	return goal

func _emit_spear_throw_trace(enemy: UnitController) -> void:
	if enemy == null or enemy.dead:
		return
	if not _has_projectile_trace_vfx():
		return
	var ctx: Dictionary = _get_archer_frontline_context(enemy)
	var own_front: float = float(ctx.get("own_front", 0.0))
	var enemy_front: float = float(ctx.get("enemy_front", 0.0))
	var dir2d: Vector3 = enemy.global_position - global_position
	dir2d.y = 0.0
	if dir2d.length_squared() <= EPS:
		dir2d = desired_facing if desired_facing.length_squared() > EPS else Vector3.FORWARD
	var dir: Vector3 = dir2d.normalized()
	var start: Vector3 = global_position + dir * own_front + Vector3(0.0, maxf(1.02, archer_arrow_height_offset * 0.88), 0.0)
	var end: Vector3 = enemy.global_position - dir * enemy_front + Vector3(0.0, maxf(0.98, archer_arrow_height_offset * 0.82), 0.0)
	if start.distance_to(end) < 0.65:
		end = enemy.global_position + Vector3(0.0, maxf(0.98, archer_arrow_height_offset * 0.82), 0.0)
	var side: Vector3 = Vector3(-dir.z, 0.0, dir.x)
	if side.length_squared() <= EPS:
		side = Vector3.RIGHT
	side = side.normalized()
	var forward: Vector3 = dir
	var view_side: Vector3 = side
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam != null:
		var to_cam: Vector3 = cam.global_position - ((start + end) * 0.5)
		if to_cam.length_squared() > EPS:
			view_side = dir.cross(to_cam.normalized())
			if view_side.length_squared() > EPS:
				view_side = view_side.normalized()
			else:
				view_side = side
	var travel_dist: float = start.distance_to(end)
	var start_spread: float = maxf(1.9, get_collision_half_extents().x * 0.52)
	var target_spread: float = maxf(2.8, enemy.get_activity_radius() * 0.98)
	var per_wave_count: int = 12
	archer_arrow_trails.clear()
	for wave in [0.0, 0.14]:
		for i in range(per_wave_count):
			var start_side: float = randf_range(-start_spread, start_spread)
			var target_side: float = randf_range(-target_spread, target_spread)
			var start_i: Vector3 = start + side * start_side + forward * randf_range(-0.42, 0.32)
			var end_i: Vector3 = end + side * target_side + forward * randf_range(-0.95, 0.85)
			archer_arrow_trails.append({
				"start": start_i,
				"end": end_i,
				"side": view_side * maxf(0.14, spear_throw_trace_width * (0.82 + randf() * 0.34)),
				"arc_height": maxf(1.9, spear_throw_arc_height + travel_dist * 0.14 + randf_range(-0.18, 0.46) + wave * 0.32),
				"delay": wave + randf_range(0.0, 0.05)
			})
	_play_projectile_trace(archer_arrow_trails, maxf(0.28, archer_arrow_line_duration * 2.7))

func _apply_spear_throw_hit(active_skill_target: UnitController) -> void:
	if active_skill_target == null or active_skill_target.dead or sweep_impact_triggered:
		return
	var face: Vector3 = _flat_dir_to(global_position, active_skill_target.global_position)
	if face.length_squared() <= EPS:
		face = _resolve_skill_forward()
	sweep_impact_triggered = true
	_emit_spear_throw_trace(active_skill_target)
	_trigger_sweep_impact_vfx(active_skill_target.global_position, maxf(1.9, active_skill_target.get_activity_radius() * 0.72), face)
	var hit: float = _get_base_attack_damage() * sweep_damage_mul * spear_throw_damage_mul
	_apply_tactic_damage_to(active_skill_target, hit, true)
	_trigger_skill_success_once(SkillType.SWEEP, active_skill_target.global_position, face, 1.12)
func _finish_skill() -> void:
	var finished_skill: SkillType = skill_type
	var resume_target: UnitController = target_unit if target_unit != null and not target_unit.dead else null
	var skill_can_pass_through: bool = pierce_can_pass_through
	var return_origin: Vector3 = charge_form_origin
	var should_return_to_origin: bool = _should_return_to_origin_after_skill(finished_skill, skill_can_pass_through)
	allow_overlap = false
	pierce_active = false
	pierce_ignore_target_id = 0
	pierce_hit_applied = false
	pierce_path_start = Vector3.ZERO
	pierce_path_end = Vector3.ZERO
	pierce_path_forward = Vector3.FORWARD
	pierce_can_pass_through = true
	skill_return_pending = false
	skill_return_resume_target = null
	skill_return_face_dir = Vector3.FORWARD
	sweep_impact_triggered = false
	skill_success_triggered = false
	charge_form_duration_ref = 0.0
	clear_temporary_detour()
	_hide_pierce_preview()
	_play_skill_vfx(SkillType.NONE, false)
	skill_type = SkillType.NONE
	skill_target = null
	_stop_staged_transition()
	var keep_shield_formation: bool = _is_shield_role() and (finished_skill == SkillType.CHARGE or finished_skill == SkillType.SWEEP) and _has_persistent_shield_formation()
	if finished_skill == SkillType.CHARGE or finished_skill == SkillType.BREAKTHROUGH or finished_skill == SkillType.SWEEP:
		if keep_shield_formation:
			transition_restore_home_lock = false
			_apply_offsets_immediate(skill_offsets, false)
		else:
			transition_restore_home_lock = true
			var recover_transition_sec: float = 0.34
			if _is_archer_role():
				recover_transition_sec = maxf(recover_transition_sec, archer_skill_recover_transition_sec)
			_start_staged_transition(home_offsets, recover_transition_sec, 18, false)
	_mark_repulsion_dirty()
	if should_return_to_origin and _start_skill_return_to_origin(return_origin, resume_target):
		return
	if (finished_skill == SkillType.CHARGE or finished_skill == SkillType.BREAKTHROUGH or finished_skill == SkillType.SWEEP) and resume_target != null:
		chase_target_unit = resume_target
		target_unit = resume_target
		nav_mode = NavMode.CHASE_TARGET
		has_move_target = false
		move_target = global_position
		move_velocity = Vector3.ZERO
		melee_refresh_timer = 0.0
		attack_timer = minf(attack_timer, 0.05)
		reengage_time_left = maxf(0.0, chase_reengage_lock_sec)
		motion_dir = _flat_dir_to(global_position, resume_target.global_position)
		_enter_state(UnitState.MOVE)
	elif target_unit != null and not target_unit.dead:
		melee_refresh_timer = 0.0
		_enter_state(UnitState.MELEE)
	elif has_move_target:
		if path_points.is_empty():
			_request_path_async(move_target, PathRequestReason.SKILL_RESUME, true, true)
		_enter_state(UnitState.MOVE)
	else:
		nav_mode = NavMode.NONE
		_enter_state(UnitState.IDLE)

func _should_return_to_origin_after_skill(finished_skill: SkillType, skill_can_pass_through: bool) -> bool:
	match finished_skill:
		SkillType.CHARGE:
			return true
		SkillType.BREAKTHROUGH:
			return _is_spear_role() or not skill_can_pass_through
		SkillType.SWEEP:
			return not _is_spear_role()
		_:
			return false

func _start_skill_return_to_origin(origin: Vector3, resume_target: UnitController) -> bool:
	var return_target: Vector3 = origin
	return_target.y = global_position.y
	if _flat_distance_to(return_target) <= 0.8:
		return false
	skill_return_pending = true
	skill_return_resume_target = resume_target
	if resume_target != null and not resume_target.dead:
		skill_return_face_dir = _flat_dir_to(return_target, resume_target.global_position)
	else:
		skill_return_face_dir = desired_facing if desired_facing.length_squared() > EPS else get_collision_forward_flat()
	chase_target_unit = null
	target_unit = null
	nav_mode = NavMode.NONE
	has_move_target = true
	move_target = return_target
	move_velocity = Vector3.ZERO
	if _flat_distance_to(return_target) > EPS:
		motion_dir = _flat_dir_to(global_position, return_target)
		desired_facing = motion_dir
	_request_path_async(move_target, PathRequestReason.SKILL_RESUME, true, true)
	_enter_state(UnitState.MOVE)
	return true
func _plan_move_path(goal: Vector3) -> void:
	_request_path_async(goal, PathRequestReason.POINT_MOVE, true, true)

func _ensure_navigation_async_mode() -> void:
	var map_rid: RID = get_world_3d().navigation_map
	if map_rid.is_valid() and _has_nav_regions(map_rid):
		NavigationServer3D.map_set_use_async_iterations(map_rid, true)

func _begin_new_command() -> void:
	command_serial += 1
	nav_request_serial += 1
	staged_move_targets.clear()
	clear_temporary_detour()
	reengage_time_left = 0.0
	nav_query_pending = false
	nav_query_pending_timer = 0.0
	nav_pending_request_id = 0
	nav_pending_command_serial = 0
	staged_move_targets.clear()
	blocked_move_timer = 0.0
	blocked_repath_cd = 0.0
	chase_repath_timer = 0.0
	attack_move_scan_timer = 0.0
	path_points.clear()
	path_index = 0
	queue_mode_active = false
	queue_trail_points.clear()
	queue_trail_total_len = 0.0
	corridor_mode = PathCorridorMode.NORMAL
	corridor_min_width = INF
	corridor_entry_index = -1
	corridor_exit_index = -1

func _cancel_targeting_intents() -> void:
	clear_temporary_detour()
	reengage_time_left = 0.0
	target_unit = null
	manual_priority_target_unit = null
	chase_target_unit = null
	chase_slot_offset = Vector3.ZERO
	chase_use_slot_follow = false
	chase_dynamic_repath = false
	chase_updates_paused = false
	player_force_chase_active = false
	player_force_chase_timer = 0.0
	attack_move_active = false
	nav_mode = NavMode.NONE
	pierce_active = false
	pierce_ignore_target_id = 0
	pierce_hit_applied = false
	pierce_path_start = Vector3.ZERO
	pierce_path_end = Vector3.ZERO
	pierce_path_forward = Vector3.FORWARD
	_hide_pierce_preview()

func _cancel_navigation_only() -> void:
	nav_request_serial += 1
	clear_temporary_detour()
	reengage_time_left = 0.0
	nav_query_pending = false
	nav_query_pending_timer = 0.0
	nav_pending_request_id = 0
	nav_pending_command_serial = 0
	staged_move_targets.clear()
	blocked_move_timer = 0.0
	blocked_repath_cd = 0.0
	path_points.clear()
	path_index = 0
	chase_target_unit = null
	chase_slot_offset = Vector3.ZERO
	chase_use_slot_follow = false
	chase_dynamic_repath = false
	player_force_chase_active = false
	player_force_chase_timer = 0.0
	nav_mode = NavMode.NONE
	chase_updates_paused = false
	pierce_active = false
	pierce_ignore_target_id = 0
	pierce_hit_applied = false
	pierce_path_start = Vector3.ZERO
	pierce_path_end = Vector3.ZERO
	pierce_path_forward = Vector3.FORWARD
	_hide_pierce_preview()

func _request_path_async(goal_world: Vector3, reason: int, lock_path: bool, clear_current_path: bool, retry_count: int = 0) -> void:
	if _requires_naval_direct_path(goal_world):
		var direct_goal := Vector3(goal_world.x, global_position.y, goal_world.z)
		var direct := PackedVector3Array([global_position, direct_goal])
		_apply_new_path(direct, reason, lock_path)
		return
	var map_rid: RID = get_world_3d().navigation_map
	if not map_rid.is_valid() or not _has_nav_regions(map_rid):
		var direct := PackedVector3Array([global_position, goal_world])
		_apply_new_path(direct, reason, lock_path)
		return
	if clear_current_path:
		path_points.clear()
		path_index = 0
	var goal := _snap_world_to_nav(goal_world)
	var params := NavigationPathQueryParameters3D.new()
	params.map = map_rid
	params.start_position = _snap_world_to_nav(global_position)
	params.target_position = goal
	params.navigation_layers = 1
	params.pathfinding_algorithm = NavigationPathQueryParameters3D.PATHFINDING_ALGORITHM_ASTAR
	params.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_CORRIDORFUNNEL
	params.simplify_path = false
	params.path_search_max_distance = maxf(1.0, nav_path_search_max_distance)
	params.path_search_max_polygons = maxi(1024, nav_path_search_max_polygons)
	params.path_return_max_length = maxf(0.0, nav_path_return_max_length)

	var result := NavigationPathQueryResult3D.new()
	nav_request_serial += 1
	nav_query_pending = true
	nav_query_pending_timer = 0.0
	nav_pending_request_id = nav_request_serial
	nav_pending_command_serial = command_serial
	NavigationServer3D.query_path(
		params,
		result,
		Callable(self, "_on_nav_query_done").bind(nav_pending_request_id, int(reason), goal, lock_path, clear_current_path, retry_count, command_serial)
	)

func _on_nav_query_done(
	result: NavigationPathQueryResult3D,
	request_id: int,
	reason_i: int,
	goal: Vector3,
	lock_path: bool,
	_clear_current_path: bool,
	retry_count: int,
	req_command_serial: int
) -> void:
	if request_id != nav_pending_request_id:
		return
	if req_command_serial != command_serial:
		return
	nav_query_pending = false
	nav_query_pending_timer = 0.0
	var reason: int = reason_i
	var path: PackedVector3Array = result.path
	var path_invalid: bool = path.size() < 2
	if path_invalid:
		path = PackedVector3Array([global_position, goal])
	path = _sanitize_path_points(path)
	if not path_invalid and enable_path_validity_sampling:
		path_invalid = not _validate_path_is_nav_walkable(path)
	if path_invalid:
		var max_retry: int = maxi(0, nav_goal_retry_max_attempts)
		if retry_count < max_retry:
			var retry_goal: Vector3 = _pick_retry_nav_goal(goal, retry_count, reason)
			if retry_goal != Vector3.INF:
				_request_path_async(retry_goal, reason, lock_path, true, retry_count + 1)
				return
		path = PackedVector3Array([_snap_world_to_nav(global_position), _snap_world_to_nav(goal)])
	_apply_new_path(path, reason, lock_path)

func _apply_new_path(path: PackedVector3Array, reason: int, _lock_path: bool) -> void:
	path_points = path
	path_index = 1 if path_points.size() > 1 else 0
	if enable_corridor_width_scan and reason != PathRequestReason.CHASE_UPDATE:
		_analyze_corridor_mode(path_points)
	else:
		corridor_mode = PathCorridorMode.NORMAL
		corridor_min_width = INF
		corridor_entry_index = -1
		corridor_exit_index = -1
		if queue_mode_active:
			_leave_queue_mode()
	_update_corridor_runtime_state()

func _sanitize_path_points(path: PackedVector3Array) -> PackedVector3Array:
	var out := PackedVector3Array()
	if path.is_empty():
		return out
	for p in path:
		var snapped := _snap_world_to_nav(p)
		if out.is_empty() or out[out.size() - 1].distance_to(snapped) > 0.02:
			out.append(snapped)
	if out.size() < 2:
		out = PackedVector3Array([_snap_world_to_nav(global_position), _snap_world_to_nav(move_target if has_move_target else global_position)])
	return out

func _pick_retry_nav_goal(base_goal: Vector3, retry_count: int, reason: int) -> Vector3:
	var snapped_base: Vector3 = _snap_world_to_nav(base_goal)
	if _is_nav_retry_goal_acceptable(base_goal, snapped_base):
		return snapped_base
	var directions: int = maxi(4, nav_goal_retry_directions)
	var radius: float = maxf(0.5, nav_goal_retry_radius_step) * float(retry_count + 1)
	var dir_base: Vector3 = Vector3.RIGHT
	if reason == PathRequestReason.CHASE_UPDATE and chase_target_unit != null and is_instance_valid(chase_target_unit) and not chase_target_unit.dead:
		var to_target: Vector3 = chase_target_unit.global_position - global_position
		to_target.y = 0.0
		if to_target.length_squared() > EPS:
			dir_base = to_target.normalized()
	elif has_move_target:
		var to_move: Vector3 = move_target - global_position
		to_move.y = 0.0
		if to_move.length_squared() > EPS:
			dir_base = to_move.normalized()
	var angle_offset: float = PI / float(directions)
	for i in range(directions):
		var angle: float = angle_offset + TAU * (float(i) / float(directions))
		var probe_dir: Vector3 = dir_base.rotated(Vector3.UP, angle)
		var probe_goal: Vector3 = base_goal + probe_dir * radius
		var snapped_probe: Vector3 = _snap_world_to_nav(probe_goal)
		if _is_nav_retry_goal_acceptable(probe_goal, snapped_probe):
			return snapped_probe
	return snapped_base if _is_nav_retry_goal_acceptable(base_goal, snapped_base) else Vector3.INF

func _is_nav_retry_goal_acceptable(raw_goal: Vector3, snapped_goal: Vector3) -> bool:
	var max_snap_dist: float = maxf(0.2, nav_adherence_tolerance * maxf(1.0, nav_goal_retry_snap_distance_mul))
	return raw_goal.distance_to(snapped_goal) <= max_snap_dist

func _validate_path_is_nav_walkable(path: PackedVector3Array) -> bool:
	if path.size() < 2:
		return false
	for i in range(path.size() - 1):
		var a: Vector3 = path[i]
		var b: Vector3 = path[i + 1]
		if _flat_distance(a, b) <= EPS:
			continue
		var steps: int = maxi(1, int(ceil(_flat_distance(a, b) / 1.5)))
		for s in range(steps + 1):
			var t: float = float(s) / float(steps)
			var sample: Vector3 = a.lerp(b, t)
			var snapped := _snap_world_to_nav(sample)
			if sample.distance_to(snapped) > nav_adherence_tolerance:
				return false
			if battlefield != null and battlefield.has_method("can_unit_walk_at_world"):
				if not bool(battlefield.call("can_unit_walk_at_world", sample, self)):
					return false
	return true

func _enforce_walkable_position() -> void:
	if battlefield == null or not battlefield.has_method("can_unit_walk_at_world"):
		return
	if bool(battlefield.call("can_unit_walk_at_world", global_position, self)):
		return
	var fixed: Vector3 = Vector3.INF
	if battlefield.has_method("resolve_walkable_point_near"):
		fixed = battlefield.call("resolve_walkable_point_near", global_position, maxf(0.5, walkable_correction_max_distance), self)
	elif battlefield.has_method("resolve_walkable_point"):
		fixed = battlefield.call("resolve_walkable_point", global_position, self)
	elif battlefield.has_method("_resolve_walkable_command_point"):
		fixed = battlefield.call("_resolve_walkable_command_point", global_position, self)
	if fixed != Vector3.INF:
		var fix_dist: float = _flat_distance(global_position, fixed)
		if fix_dist <= maxf(0.2, walkable_correction_max_distance):
			global_position = Vector3(fixed.x, global_position.y, fixed.z)
			return
		if has_move_target and not nav_query_pending:
			var reason: int = PathRequestReason.CHASE_UPDATE if nav_mode == NavMode.CHASE_TARGET else PathRequestReason.POINT_MOVE
			var goal: Vector3 = chase_last_goal_point if nav_mode == NavMode.CHASE_TARGET else move_target
			_request_path_async(goal, reason, nav_mode != NavMode.CHASE_TARGET, true)
		move_velocity = Vector3.ZERO
		return
	var snapped: Vector3 = _snap_world_to_nav(global_position)
	if battlefield.has_method("can_unit_walk_at_world") and bool(battlefield.call("can_unit_walk_at_world", snapped, self)):
		if _flat_distance(global_position, snapped) <= maxf(0.2, walkable_correction_max_distance):
			global_position = Vector3(snapped.x, global_position.y, snapped.z)

func _terrain_height_at_world(world_pos: Vector3) -> float:
	if battlefield != null:
		if battlefield.has_method("terrain_height_at_world"):
			return float(battlefield.call("terrain_height_at_world", world_pos))
		if battlefield.has_method("_terrain_height_at_world"):
			return float(battlefield.call("_terrain_height_at_world", world_pos))
	return float(world_pos.y)

func _sample_ground_tilt_targets() -> void:
	ground_target_pitch_deg = 0.0
	ground_target_roll_deg = 0.0
	if not ground_visual_align_enabled:
		return
	if soldiers_mmi == null or not is_instance_valid(soldiers_mmi):
		return
	var forward: Vector3 = get_collision_forward_flat()
	forward.y = 0.0
	if forward.length_squared() <= EPS:
		forward = Vector3.FORWARD
	forward = forward.normalized()
	var right := Vector3(forward.z, 0.0, -forward.x)
	if right.length_squared() <= EPS:
		right = Vector3.RIGHT
	else:
		right = right.normalized()
	var probe: float = maxf(0.5, ground_visual_align_probe_distance)
	var pos: Vector3 = global_position
	var front_h: float = _terrain_height_at_world(pos + forward * probe)
	var back_h: float = _terrain_height_at_world(pos - forward * probe)
	var right_h: float = _terrain_height_at_world(pos + right * probe)
	var left_h: float = _terrain_height_at_world(pos - right * probe)
	var pitch_deg: float = rad_to_deg(atan2(front_h - back_h, probe * 2.0))
	var roll_deg: float = rad_to_deg(atan2(left_h - right_h, probe * 2.0))
	var max_tilt: float = maxf(0.0, ground_visual_align_max_tilt_deg)
	ground_target_pitch_deg = clampf(pitch_deg, -max_tilt, max_tilt)
	ground_target_roll_deg = clampf(roll_deg, -max_tilt, max_tilt)

func _apply_ground_visual_tilt(delta: float, force: bool = false) -> void:
	if soldiers_mmi == null or not is_instance_valid(soldiers_mmi):
		return
	if not ground_visual_align_enabled:
		ground_pitch_deg_current = 0.0
		ground_roll_deg_current = 0.0
		soldiers_mmi.rotation = Vector3.ZERO
		return
	if force:
		ground_pitch_deg_current = ground_target_pitch_deg
		ground_roll_deg_current = ground_target_roll_deg
	else:
		var lerp_deg: float = maxf(1.0, ground_visual_align_lerp_deg_per_sec) * maxf(0.0, delta)
		ground_pitch_deg_current = move_toward(ground_pitch_deg_current, ground_target_pitch_deg, lerp_deg)
		ground_roll_deg_current = move_toward(ground_roll_deg_current, ground_target_roll_deg, lerp_deg)
	soldiers_mmi.rotation = Vector3(deg_to_rad(ground_pitch_deg_current), 0.0, deg_to_rad(ground_roll_deg_current))

func _update_ground_alignment(delta: float, force: bool = false) -> void:
	if not ground_snap_enabled:
		return
	ground_snap_timer -= maxf(0.0, delta)
	if force or ground_snap_timer <= 0.0:
		ground_snap_timer = maxf(0.03, ground_snap_sample_interval)
		ground_target_height = _terrain_height_at_world(global_position)
		_sample_ground_tilt_targets()
	global_position = Vector3(global_position.x, ground_target_height, global_position.z)
	_apply_ground_visual_tilt(delta, force)

func _analyze_corridor_mode(path: PackedVector3Array) -> void:
	corridor_mode = PathCorridorMode.NORMAL
	corridor_min_width = INF
	corridor_entry_index = -1
	corridor_exit_index = -1
	if _is_archer_role():
		if queue_mode_active:
			_leave_queue_mode()
		return
	if path.size() < 2:
		return
	var formation_width: float = _compute_offsets_width(home_offsets)
	var min_width: float = INF
	var min_idx: int = -1
	var narrow_start: int = -1
	var narrow_end: int = -1
	var sample_step: int = maxi(1, int(round(path_sample_interval)))
	for i in range(1, path.size() - 1):
		if (i % sample_step) != 0:
			continue
		var w: float = _estimate_local_corridor_width(path, i)
		if w < min_width:
			min_width = w
			min_idx = i
		if w < narrow_width_threshold:
			if narrow_start < 0:
				narrow_start = i
			narrow_end = i
	if min_idx < 0:
		return
	corridor_min_width = min_width
	if min_width < narrow_width_threshold:
		corridor_mode = PathCorridorMode.SINGLE_QUEUE
		corridor_entry_index = maxi(1, narrow_start - 1)
		corridor_exit_index = mini(path.size() - 1, narrow_end + 1)
		return
	if min_width < formation_width:
		corridor_mode = PathCorridorMode.COMPRESSED
		var safe_width: float = maxf(1.0, min_width - compressed_width_padding)
		var compressed_offsets := _build_compressed_offsets(home_offsets, safe_width)
		_start_staged_transition(compressed_offsets, 0.55, 2, true)
		return
	corridor_mode = PathCorridorMode.NORMAL

func _compute_offsets_width(offsets: Array[Vector3]) -> float:
	if offsets.is_empty():
		return 0.0
	var min_x: float = INF
	var max_x: float = -INF
	for off in offsets:
		min_x = minf(min_x, off.x)
		max_x = maxf(max_x, off.x)
	return maxf(0.0, max_x - min_x)

func _build_compressed_offsets(source_offsets: Array[Vector3], max_width: float) -> Array[Vector3]:
	var out: Array[Vector3] = []
	if source_offsets.is_empty():
		return out
	var src_width: float = _compute_offsets_width(source_offsets)
	if src_width <= EPS:
		return source_offsets.duplicate()
	var x_scale: float = clampf(max_width / src_width, 0.25, 1.0)
	for off in source_offsets:
		out.append(Vector3(off.x * x_scale, off.y, off.z))
	return out

func _estimate_local_corridor_width(path: PackedVector3Array, idx: int) -> float:
	if idx <= 0 or idx >= path.size() - 1:
		return path_probe_max_width
	var p: Vector3 = path[idx]
	var tangent: Vector3 = path[idx + 1] - path[idx - 1]
	tangent.y = 0.0
	if tangent.length_squared() <= EPS:
		return path_probe_max_width
	tangent = tangent.normalized()
	var right := Vector3(tangent.z, 0.0, -tangent.x).normalized()
	var left_w := _scan_nav_half_width(p, -right)
	var right_w := _scan_nav_half_width(p, right)
	return left_w + right_w

func _scan_nav_half_width(origin: Vector3, dir: Vector3) -> float:
	var best: float = 0.0
	var d: float = 0.0
	while d <= path_probe_max_width:
		var sample := origin + dir * d
		var snapped := _snap_world_to_nav(sample)
		if sample.distance_to(snapped) > nav_adherence_tolerance:
			break
		best = d
		d += maxf(0.2, path_probe_step)
	return best

func _update_corridor_runtime_state() -> void:
	if corridor_mode != PathCorridorMode.SINGLE_QUEUE:
		return
	if corridor_entry_index < 0 or corridor_exit_index < 0:
		return
	if not queue_mode_active and path_index >= corridor_entry_index:
		_enter_queue_mode()
	elif queue_mode_active and path_index > corridor_exit_index:
		_leave_queue_mode()

func _enter_queue_mode() -> void:
	if queue_mode_active:
		return
	if _is_archer_role():
		return
	queue_mode_active = true
	chase_updates_paused = true
	queue_trail_points.clear()
	queue_trail_points.append(global_position)
	queue_trail_total_len = 0.0
	var queue_offsets := _generate_formation_offsets(FormationType.LINE, soldier_count, maxf(0.35, queue_spacing))
	_start_staged_transition(queue_offsets, maxf(0.2, queue_transition_sec), 2, false)

func _leave_queue_mode() -> void:
	if not queue_mode_active:
		return
	queue_mode_active = false
	chase_updates_paused = false
	queue_trail_points.clear()
	queue_trail_total_len = 0.0
	_restore_post_move_formation()

func _restore_post_move_formation() -> void:
	if state == UnitState.SKILL_FORM or state == UnitState.SKILL_EXEC:
		return
	if _has_persistent_shield_formation():
		transition_restore_home_lock = false
		if not _offset_sets_close(current_offsets, skill_offsets):
			_start_staged_transition(skill_offsets, 0.4, 16, false)
		return
	if _offset_sets_close(current_offsets, home_offsets):
		transition_restore_home_lock = false
		return
	transition_restore_home_lock = true
	_start_staged_transition(home_offsets, 0.6, 2, true)

func _update_queue_render_offsets() -> void:
	if not queue_mode_active:
		return
	if state != UnitState.MOVE:
		return
	_push_queue_trail_point(global_position)
	var offsets: Array[Vector3] = []
	offsets.resize(soldier_count)
	for i in soldier_count:
		var back_dist: float = float(i) * maxf(0.3, queue_spacing)
		var world_p := _sample_queue_trail(back_dist)
		var local := global_basis.inverse() * (world_p - global_position)
		local.y = 0.0
		offsets[i] = local
	_apply_offsets_immediate(offsets, false, true)

func _push_queue_trail_point(world_pos: Vector3) -> void:
	if queue_trail_points.is_empty():
		queue_trail_points.append(world_pos)
		return
	var last: Vector3 = queue_trail_points[queue_trail_points.size() - 1]
	var seg: float = _flat_distance(last, world_pos)
	if seg < maxf(0.2, queue_spacing * 0.35):
		return
	queue_trail_points.append(world_pos)
	queue_trail_total_len += seg
	_trim_queue_trail(maxf(8.0, float(soldier_count - 1) * queue_spacing + 4.0))

func _trim_queue_trail(need_len: float) -> void:
	while queue_trail_points.size() > 2 and queue_trail_total_len > need_len:
		var a: Vector3 = queue_trail_points[0]
		var b: Vector3 = queue_trail_points[1]
		queue_trail_total_len -= _flat_distance(a, b)
		queue_trail_points.remove_at(0)

func _sample_queue_trail(back_distance: float) -> Vector3:
	if queue_trail_points.is_empty():
		return global_position
	var remain: float = maxf(0.0, back_distance)
	var idx := queue_trail_points.size() - 1
	var p: Vector3 = queue_trail_points[idx]
	while idx > 0 and remain > 0.0:
		var prev: Vector3 = queue_trail_points[idx - 1]
		var seg_len: float = _flat_distance(prev, p)
		if seg_len <= EPS:
			p = prev
			idx -= 1
			continue
		if remain <= seg_len:
			var t: float = remain / seg_len
			return p.lerp(prev, t)
		remain -= seg_len
		p = prev
		idx -= 1
	return queue_trail_points[0]

func _is_enemy_target_trackable(enemy: UnitController) -> bool:
	if enemy == null or enemy.dead:
		return false
	if enemy.team_id == team_id:
		return false
	if battlefield != null and is_instance_valid(battlefield):
		if battlefield.has_method("is_enemy_targetable_for_team"):
			return bool(battlefield.call("is_enemy_targetable_for_team", team_id, enemy))
		if battlefield.has_method("is_enemy_spotted_for_team"):
			return bool(battlefield.call("is_enemy_spotted_for_team", team_id, enemy))
	return true

func _is_chase_target_lost(target: UnitController) -> bool:
	if target == null or target.dead:
		return true
	if not _is_enemy_target_trackable(target):
		return true
	var dist_to_target: float = _flat_distance_to(target.global_position)
	if player_force_chase_active:
		if player_command_force_chase_ignore_distance:
			return false
		var max_force_dist: float = maxf(vision_radius * 1.5, player_command_force_chase_max_distance)
		return dist_to_target > maxf(1.0, max_force_dist)
	if dist_to_target > maxf(1.0, vision_radius):
		return true
	var max_chase_dist: float = maxf(vision_radius * chase_max_range_mul, vision_radius)
	if _flat_distance(chase_origin_point, target.global_position) > max_chase_dist:
		return true
	return false

func _get_chase_navigation_goal(target: UnitController) -> Vector3:
	if target == null or target.dead:
		return chase_fallback_point
	if not chase_use_slot_follow:
		return target.global_position
	var goal: Vector3 = target.global_position + chase_slot_offset
	return Vector3(goal.x, target.global_position.y, goal.z)

func _switch_chase_to_fallback_move() -> void:
	if command_mode == CommandMode.FORCE_ATTACK:
		issue_stop_order()
		return
	chase_target_unit = null
	chase_slot_offset = Vector3.ZERO
	chase_use_slot_follow = false
	chase_dynamic_repath = false
	player_force_chase_active = false
	player_force_chase_timer = 0.0
	target_unit = null
	var fallback := chase_fallback_point
	if attack_move_active and attack_move_goal != Vector3.ZERO:
		fallback = attack_move_goal
	move_target = fallback
	has_move_target = true
	nav_mode = NavMode.ATTACK_MOVE if attack_move_active else NavMode.POINT_MOVE
	_request_path_async(move_target, PathRequestReason.CHASE_FALLBACK, true, true)
	_enter_state(UnitState.MOVE)

func _try_lock_attack_move_target(delta: float) -> bool:
	attack_move_scan_timer -= delta
	if attack_move_scan_timer > 0.0:
		return false
	attack_move_scan_timer = maxf(0.12, attack_move_scan_interval)
	var enemy := _find_enemy_in_radius(maxf(attack_range + 2.0, attack_move_scan_radius))
	if enemy == null:
		return false
	issue_attack_order(enemy, attack_move_goal, true, true)
	return true

func _find_enemy_in_radius(radius: float) -> UnitController:
	if battlefield == null or not battlefield.has_method("get_enemy_units"):
		return null
	var enemies: Array = battlefield.call("get_enemy_units", team_id)
	var best: UnitController = null
	var best_dist_sq: float = radius * radius
	for enemy_any in enemies:
		if not (enemy_any is UnitController):
			continue
		var enemy: UnitController = enemy_any
		if enemy.dead:
			continue
		if not _is_enemy_target_trackable(enemy):
			continue
		var d := enemy.global_position - global_position
		d.y = 0.0
		var dist_sq := d.length_squared()
		if dist_sq <= best_dist_sq:
			best_dist_sq = dist_sq
			best = enemy
	return best

func _flat_distance(a: Vector3, b: Vector3) -> float:
	var d := a - b
	d.y = 0.0
	return d.length()

func _flat_distance_to(world_pos: Vector3) -> float:
	return _flat_distance(global_position, world_pos)

func _snap_world_to_nav(world_pos: Vector3) -> Vector3:
	if naval_embarked:
		return world_pos
	var map_rid: RID = get_world_3d().navigation_map
	if map_rid.is_valid() and _has_nav_regions(map_rid):
		return NavigationServer3D.map_get_closest_point(map_rid, world_pos)
	return world_pos

func _has_nav_regions(map_rid: RID) -> bool:
	if not map_rid.is_valid():
		return false
	return NavigationServer3D.map_get_regions(map_rid).size() > 0

func _snap_unit_to_nav() -> void:
	if naval_embarked:
		return
	global_position = _snap_world_to_nav(global_position)

func _tick_nav_query_timeout(delta: float) -> void:
	if not nav_query_pending:
		return
	nav_query_pending_timer += maxf(0.0, delta)
	if nav_query_pending_timer < maxf(0.12, nav_query_timeout_sec):
		return
	_force_fallback_path_from_pending()

func _force_fallback_path_from_pending() -> void:
	nav_query_pending = false
	nav_query_pending_timer = 0.0
	nav_pending_request_id = 0
	nav_pending_command_serial = 0
	var goal: Vector3 = move_target
	match nav_mode:
		NavMode.CHASE_TARGET:
			if chase_target_unit != null and is_instance_valid(chase_target_unit) and not chase_target_unit.dead:
				goal = _get_chase_navigation_goal(chase_target_unit)
				chase_last_goal_point = goal
			else:
				goal = chase_last_goal_point if chase_last_goal_point != Vector3.ZERO else chase_fallback_point
		NavMode.ATTACK_MOVE:
			goal = attack_move_goal if attack_move_goal != Vector3.ZERO else move_target
		_:
			goal = move_target
	var fallback_path := PackedVector3Array([global_position, goal])
	_apply_new_path(fallback_path, PathRequestReason.POINT_MOVE, true)

func _tick_parent_nav_snap(delta: float) -> void:
	if not enable_parent_nav_snap:
		return
	if naval_embarked:
		return
	parent_nav_snap_timer -= delta
	if parent_nav_snap_timer > 0.0:
		return
	parent_nav_snap_timer = maxf(0.05, parent_nav_snap_interval)
	var snapped := _snap_world_to_nav(global_position)
	if snapped.distance_to(global_position) > maxf(0.2, parent_nav_snap_tolerance):
		return
	global_position = snapped

func _get_current_waypoint() -> Vector3:
	if path_points.is_empty() or path_index >= path_points.size():
		return move_target
	return path_points[path_index]

func has_active_detour() -> bool:
	return detour_goal != Vector3.INF and detour_time_left > 0.0

func clear_temporary_detour() -> void:
	detour_goal = Vector3.INF
	detour_time_left = 0.0

func set_temporary_detour(world_goal: Vector3, duration_sec: float = 0.9) -> void:
	detour_goal = Vector3(world_goal.x, global_position.y, world_goal.z)
	detour_time_left = maxf(0.15, duration_sec)

func _flat_dir_to(from_pos: Vector3, to_pos: Vector3) -> Vector3:
	var flat: Vector3 = to_pos - from_pos
	flat.y = 0.0
	if flat.length_squared() <= EPS:
		return get_collision_forward_flat()
	return flat.normalized()

func _blend_flat_dir(current: Vector3, target: Vector3, max_turn_radians: float) -> Vector3:
	var current_flat: Vector3 = current
	current_flat.y = 0.0
	var target_flat: Vector3 = target
	target_flat.y = 0.0
	if target_flat.length_squared() <= EPS:
		if current_flat.length_squared() <= EPS:
			return Vector3.FORWARD
		return current_flat.normalized()
	if current_flat.length_squared() <= EPS:
		return target_flat.normalized()
	current_flat = current_flat.normalized()
	target_flat = target_flat.normalized()
	var current_angle: float = atan2(current_flat.x, current_flat.z)
	var target_angle: float = atan2(target_flat.x, target_flat.z)
	var next_angle: float = rotate_toward(current_angle, target_angle, maxf(0.0, max_turn_radians))
	return Vector3(sin(next_angle), 0.0, cos(next_angle)).normalized()

func _apply_unit_facing(face_dir: Vector3, delta: float) -> void:
	var flat: Vector3 = Vector3(face_dir.x, 0.0, face_dir.z)
	if flat.length_squared() <= EPS:
		return
	var target: Vector3 = flat.normalized()
	if _is_archer_role() and state == UnitState.MOVE:
		desired_facing = target
		look_at(global_position + desired_facing, Vector3.UP)
		return
	if _is_archer_role() and archer_move_facing_smooth:
		var current: Vector3 = desired_facing
		current.y = 0.0
		if current.length_squared() <= EPS:
			current = target
		else:
			current = current.normalized()
		var dot_v: float = clampf(current.dot(target), -1.0, 1.0)
		var angle: float = acos(dot_v)
		var min_angle: float = deg_to_rad(maxf(0.0, archer_move_facing_min_angle_deg))
		if angle <= min_angle:
			return
		var turn_step_archer: float = deg_to_rad(maxf(1.0, archer_move_facing_lerp_speed * 24.0) * maxf(0.0, delta))
		desired_facing = _blend_flat_dir(current, target, turn_step_archer)
	else:
		var turn_step: float = deg_to_rad(maxf(1.0, unit_turn_rate_deg) * maxf(0.0, delta))
		desired_facing = _blend_flat_dir(desired_facing, target, turn_step)
	look_at(global_position + desired_facing, Vector3.UP)

func _move_towards(world_target: Vector3, speed: float, delta: float, move_mode: String = "move", move_target_unit: UnitController = null) -> float:
	if has_active_detour() and global_position.distance_to(detour_goal) <= 0.9:
		clear_temporary_detour()
	var active_goal: Vector3 = detour_goal if has_active_detour() else world_target
	var delta_pos := active_goal - global_position
	delta_pos.y = 0.0
	var dist := delta_pos.length()
	if dist <= 0.01:
		_update_downhill_speed_bonus(0.0, delta)
		move_velocity = Vector3.ZERO
		return 0.0
	var desired_dir := delta_pos / dist
	var turn_step: float = deg_to_rad(maxf(1.0, unit_turn_rate_deg) * maxf(0.0, delta))
	motion_dir = _blend_flat_dir(motion_dir, desired_dir, turn_step)
	var terrain_speed_mul: float = _get_height_speed_mul_towards(active_goal)
	var target_bonus: float = maxf(0.0, terrain_speed_mul - 1.0)
	var dynamic_bonus: float = _update_downhill_speed_bonus(target_bonus, delta)
	var ignore_zoc: bool = move_mode == "reengage"
	var zoc_mul: float = _get_zoc_speed_mul_for_dir(motion_dir, move_target_unit, ignore_zoc)
	var runtime_speed: float = maxf(0.0, speed * _get_runtime_speed_mul() * (1.0 + dynamic_bonus) * zoc_mul)
	if runtime_speed <= 0.001:
		move_velocity = Vector3.ZERO
		return dist
	var step: float = minf(dist, runtime_speed * delta)
	var from_pos: Vector3 = global_position
	if battlefield != null and battlefield.has_method("resolve_unit_motion"):
		var motion: Dictionary = battlefield.call("resolve_unit_motion", self, active_goal, motion_dir, step, move_mode, move_target_unit)
		var next_pos: Vector3 = _sanitize_world_position(motion.get("position", global_position), from_pos)
		var next_forward: Vector3 = motion.get("forward", motion_dir)
		next_forward.y = 0.0
		if next_forward.length_squared() > EPS:
			motion_dir = _blend_flat_dir(motion_dir, next_forward.normalized(), turn_step * 0.7)
		if motion.has("detour_goal"):
			var detour_goal_pos: Vector3 = _sanitize_world_position(motion.get("detour_goal", next_pos), next_pos)
			set_temporary_detour(detour_goal_pos, float(motion.get("detour_sec", 0.9)))
		global_position = next_pos
	else:
		var desired_pos: Vector3 = from_pos + motion_dir * step
		if battlefield != null and battlefield.has_method("resolve_unit_step"):
			global_position = _sanitize_world_position(battlefield.call("resolve_unit_step", self, from_pos, desired_pos, motion_dir), from_pos)
		else:
			global_position = _sanitize_world_position(desired_pos, from_pos)
	if not global_position.is_finite():
		global_position = from_pos
	var moved_vec: Vector3 = global_position - from_pos
	moved_vec.y = 0.0
	var moved_len: float = moved_vec.length()
	var moved_dir: Vector3 = moved_vec / moved_len if moved_len > EPS else motion_dir
	move_velocity = moved_dir * runtime_speed if moved_len > EPS else Vector3.ZERO
	if moved_len <= 0.0001:
		_handle_blocked_movement(active_goal, motion_dir, delta)
	else:
		blocked_move_timer = 0.0
	if moved_dir.length_squared() > EPS:
		_apply_unit_facing(moved_dir, delta)
	return maxf(0.0, active_goal.distance_to(global_position))

func _handle_blocked_movement(_world_target: Vector3, _move_dir: Vector3, delta: float) -> void:
	blocked_move_timer += maxf(0.0, delta)
	# No path avoidance / no soft bypass:
	# when blocked by hard collision, wait for lane to clear or for a new player order.
	blocked_repath_cd = 0.0
	move_velocity = Vector3.ZERO

func _update_downhill_speed_bonus(target_bonus: float, delta: float) -> float:
	var clamped_target: float = clampf(target_bonus, 0.0, 2.0)
	var accel: float = maxf(0.01, downhill_speed_accel_per_sec)
	var decel: float = maxf(0.01, downhill_speed_decel_per_sec)
	if clamped_target > downhill_speed_bonus_current:
		downhill_speed_bonus_current = move_toward(downhill_speed_bonus_current, clamped_target, accel * maxf(0.0, delta))
	else:
		downhill_speed_bonus_current = move_toward(downhill_speed_bonus_current, clamped_target, decel * maxf(0.0, delta))
	return downhill_speed_bonus_current

func _apply_pending_displacement() -> void:
	if pending_displacement.length_squared() <= EPS:
		pending_displacement = Vector3.ZERO
		return
	var from_pos: Vector3 = global_position
	var desired_pos: Vector3 = from_pos + pending_displacement
	desired_pos.y = from_pos.y
	if battlefield != null and battlefield.has_method("resolve_unit_step"):
		global_position = _sanitize_world_position(battlefield.call("resolve_unit_step", self, from_pos, desired_pos, pending_displacement.normalized()), from_pos)
	else:
		global_position = _sanitize_world_position(desired_pos, from_pos)
	pending_displacement = Vector3.ZERO

func _is_finite_float(value: float) -> bool:
	return value == value and absf(value) < INF

func _sanitize_world_position(world_pos: Vector3, fallback: Vector3) -> Vector3:
	if world_pos.is_finite():
		return world_pos
	if fallback.is_finite():
		return fallback
	return Vector3.ZERO

func _sanitize_basis_for_instances(input_basis: Basis) -> Basis:
	if input_basis.x.is_finite() and input_basis.y.is_finite() and input_basis.z.is_finite():
		return input_basis
	return Basis.IDENTITY

func _sanitize_local_offset(local_offset: Vector3, fallback: Vector3 = Vector3.ZERO) -> Vector3:
	var flat := Vector3(local_offset.x, 0.0, local_offset.z)
	if flat.is_finite():
		return flat
	var fallback_flat := Vector3(fallback.x, 0.0, fallback.z)
	if fallback_flat.is_finite():
		return fallback_flat
	return Vector3.ZERO

func _set_soldier_instance_transform_safe(instance_idx: int, basis: Basis, origin: Vector3) -> void:
	if soldiers_mm == null:
		return
	var safe_basis: Basis = _sanitize_basis_for_instances(basis)
	var safe_origin: Vector3 = origin if origin.is_finite() else Vector3(0.0, 0.68, 0.0)
	var xf := Transform3D(safe_basis, safe_origin)
	if not xf.origin.is_finite() or not xf.basis.x.is_finite() or not xf.basis.y.is_finite() or not xf.basis.z.is_finite():
		xf = Transform3D(Basis.IDENTITY, Vector3(0.0, 0.68, 0.0))
	soldiers_mm.set_instance_transform(instance_idx, xf)

func _apply_offsets_immediate(offsets: Array[Vector3], _avoid_enemy_overlap: bool, bypass_radius_clamp: bool = false) -> void:
	if soldiers_mm == null:
		return

	if current_offsets.size() != soldier_count:
		current_offsets.resize(soldier_count)

	var base_basis := _sanitize_basis_for_instances(soldier_mesh_basis.scaled(Vector3.ONE * soldier_visual_scale))
	for i in soldier_count:
		var fallback_off: Vector3 = home_offsets[i] if i < home_offsets.size() else Vector3.ZERO
		var local_target: Vector3 = _sanitize_local_offset(offsets[i], fallback_off)
		if not bypass_radius_clamp:
			local_target = _clamp_local_radius(local_target)
		local_target = _sanitize_local_offset(local_target, fallback_off)
		current_offsets[i] = local_target
		_set_soldier_instance_transform_safe(i, base_basis, Vector3(local_target.x, 0.68, local_target.z))
		if not seeds_uploaded:
			var seed_value: float = float(seeds[i]) if i < seeds.size() else 0.0
			if not _is_finite_float(seed_value):
				seed_value = 0.0
			soldiers_mm.set_instance_custom_data(i, Color(seed_value, 0.0, 0.0, 1.0))
	seeds_uploaded = true

func _start_staged_transition(target_offsets: Array[Vector3], duration: float, _steps: int, avoid_enemy_overlap: bool) -> void:
	if target_offsets.size() != soldier_count:
		return
	if formation_transition_cooldown_timer > 0.0:
		return
	if transition_active and transition_to.size() == target_offsets.size():
		var max_delta_sq: float = 0.0
		for i in range(target_offsets.size()):
			var cur: Vector3 = transition_to[i]
			var nxt: Vector3 = target_offsets[i]
			var d: Vector3 = nxt - cur
			max_delta_sq = maxf(max_delta_sq, d.length_squared())
		if max_delta_sq <= 0.0009:
			return
	transition_active = true
	transition_from = []
	transition_to = []
	for i in soldier_count:
		transition_from.append(current_offsets[i] if i < current_offsets.size() else home_offsets[i])
		transition_to.append(target_offsets[i])
	transition_duration = maxf(duration, 0.05)
	transition_elapsed = 0.0
	transition_avoid_enemy_overlap = false
	if not _offset_sets_close(target_offsets, home_offsets):
		transition_restore_home_lock = false
	formation_transition_cooldown_timer = maxf(0.0, formation_transition_min_interval_sec)
	_apply_offsets_immediate(_blend_offsets(transition_from, transition_to, 0.0), false)

func _process_staged_transition(delta: float) -> void:
	if not transition_active:
		return
	transition_elapsed = minf(transition_elapsed + delta, transition_duration)
	var t := clampf(transition_elapsed / maxf(transition_duration, 0.001), 0.0, 1.0)
	t = t * t * (3.0 - 2.0 * t)
	var blend := _blend_offsets(transition_from, transition_to, t)
	var avoid := false
	_apply_offsets_immediate(blend, avoid)
	if transition_elapsed >= transition_duration:
		transition_active = false
		transition_restore_home_lock = false

func _stop_staged_transition() -> void:
	transition_active = false
	transition_from = []
	transition_to = []
	transition_duration = 0.0
	transition_elapsed = 0.0
	transition_avoid_enemy_overlap = false
	transition_restore_home_lock = false

func _blend_offsets(from_offsets: Array[Vector3], to_offsets: Array[Vector3], t: float) -> Array[Vector3]:
	var out: Array[Vector3] = []
	out.resize(soldier_count)
	for i in soldier_count:
		out[i] = from_offsets[i].lerp(to_offsets[i], t)
	return out


func _offset_sets_close(a: Array[Vector3], b: Array[Vector3], tolerance_sq: float = 0.0009) -> bool:
	if a.size() != b.size():
		return false
	for i in range(a.size()):
		if (a[i] - b[i]).length_squared() > tolerance_sq:
			return false
	return true
func _ensure_vfx_root() -> Node3D:
	if vfx_root != null and is_instance_valid(vfx_root):
		return vfx_root
	vfx_root = get_node_or_null("VfxRoot") as Node3D
	if vfx_root == null:
		vfx_root = Node3D.new()
		vfx_root.name = "VfxRoot"
		add_child(vfx_root)
	return vfx_root

func _get_skill_vfx_color(skill: SkillType, executing: bool = false) -> Color:
	match skill:
		SkillType.CHARGE:
			return Color(1.0, 0.82, 0.18, 0.96 if executing else 0.9)
		SkillType.BREAKTHROUGH:
			return Color(1.0, 0.33, 0.1, 0.98 if executing else 0.94)
		SkillType.SWEEP:
			return Color(1.0, 0.9, 0.5, 0.98 if executing else 0.94)
		_:
			return Color(1.0, 0.8, 0.2, 0.78)

func _get_skill_vfx_duration(skill: SkillType, executing: bool) -> float:
	match skill:
		SkillType.CHARGE:
			return charge_duration if executing else maxf(0.8, pierce_form_duration_sec)
		SkillType.BREAKTHROUGH:
			return breakthrough_duration if executing else maxf(0.85, pierce_form_duration_sec)
		SkillType.SWEEP:
			return sweep_duration if executing else 0.95
		_:
			return 0.6

func _build_skill_vfx() -> void:
	return
func _build_status_vfx() -> void:
	status_vfx_root = Node3D.new()
	status_vfx_root.name = "StatusVfx"
	status_vfx_root.visible = false
	status_vfx_root.position = Vector3(0.0, paralyzed_vfx_height, 0.0)
	add_child(status_vfx_root)

	paralyzed_ring_node = null
	paralyzed_ring_material = null
	paralyzed_star_nodes.clear()
	paralyzed_star_materials.clear()
	if paralyzed_status_vfx_enabled:
		paralyzed_ring_node = MeshInstance3D.new()
		paralyzed_ring_node.name = "ParalyzedRing"
		paralyzed_ring_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var ring := CylinderMesh.new()
		ring.top_radius = 0.42
		ring.bottom_radius = 0.52
		ring.height = 0.08
		ring.radial_segments = 24
		paralyzed_ring_node.mesh = ring
		paralyzed_ring_material = StandardMaterial3D.new()
		paralyzed_ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		paralyzed_ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		paralyzed_ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		paralyzed_ring_material.albedo_color = Color(1.0, 0.9, 0.36, 0.92)
		paralyzed_ring_material.emission_enabled = true
		paralyzed_ring_material.emission = Color(1.0, 0.92, 0.42, 1.0)
		paralyzed_ring_material.emission_energy_multiplier = 1.8
		paralyzed_ring_node.material_override = paralyzed_ring_material
		status_vfx_root.add_child(paralyzed_ring_node)

		var star_mesh := SphereMesh.new()
		star_mesh.radius = 0.12
		star_mesh.height = 0.24
		for i in range(3):
			var star := MeshInstance3D.new()
			star.name = "ParalyzedStar%d" % i
			star.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			star.mesh = star_mesh
			var star_mat := StandardMaterial3D.new()
			star_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			star_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			star_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			star_mat.albedo_color = Color(1.0, 0.98, 0.72, 0.95)
			star_mat.emission_enabled = true
			star_mat.emission = Color(1.0, 0.95, 0.58, 1.0)
			star_mat.emission_energy_multiplier = 1.9
			star.material_override = star_mat
			status_vfx_root.add_child(star)
			paralyzed_star_nodes.append(star)
			paralyzed_star_materials.append(star_mat)
	_build_burning_status_vfx()

func _build_burning_status_vfx() -> void:
	if status_vfx_root == null:
		return
	burning_vfx_root = Node3D.new()
	burning_vfx_root.name = "BurningVfx"
	burning_vfx_root.visible = false
	status_vfx_root.add_child(burning_vfx_root)

	# Do not build ground aura to avoid persistent ground circles under burning units.
	burning_aura_node = null
	burning_aura_material = null

	burning_flame_nodes.clear()
	burning_flame_materials.clear()
	var flame_mesh := QuadMesh.new()
	flame_mesh.size = Vector2(0.56, 1.28)
	for i in range(4):
		var flame := MeshInstance3D.new()
		flame.name = "BurningFlame%d" % i
		flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		flame.mesh = flame_mesh
		var flame_mat := _make_vfx_sprite_material(BURNING_FLAME_TEX, Color(1.0, 0.54, 0.18, 0.0), 2.8, BaseMaterial3D.BILLBOARD_ENABLED)
		flame_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		flame.material_override = flame_mat
		burning_vfx_root.add_child(flame)
		burning_flame_nodes.append(flame)
		burning_flame_materials.append(flame_mat)

	burning_ember_nodes.clear()
	burning_ember_materials.clear()
	var ember_mesh := SphereMesh.new()
	ember_mesh.radius = 0.06
	ember_mesh.height = 0.12
	for i in range(4):
		var ember := MeshInstance3D.new()
		ember.name = "BurningEmber%d" % i
		ember.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ember.mesh = ember_mesh
		var ember_mat := StandardMaterial3D.new()
		ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ember_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ember_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		ember_mat.albedo_color = Color(1.0, 0.78, 0.42, 0.0)
		ember_mat.emission_enabled = true
		ember_mat.emission = Color(1.0, 0.72, 0.28, 1.0)
		ember_mat.emission_energy_multiplier = 1.8
		_set_vfx_material_depth_mode(ember_mat)
		ember.material_override = ember_mat
		burning_vfx_root.add_child(ember)
		burning_ember_nodes.append(ember)
		burning_ember_materials.append(ember_mat)

	# Remove smoke from burn status effect to keep fire visuals clean.
	burning_smoke_nodes.clear()
	burning_smoke_materials.clear()

func _trigger_paralyzed_feedback(duration_sec: float) -> void:
	paralyzed_vfx_total = maxf(0.16, duration_sec)
	paralyzed_vfx_timer = paralyzed_vfx_total
	status_hit_stop_timer = maxf(status_hit_stop_timer, paralyzed_hit_stop_duration)
	if paralyzed_status_vfx_enabled and status_vfx_root != null:
		status_vfx_root.visible = true

func _update_status_vfx(delta: float) -> void:
	if status_vfx_root == null:
		return
	var paralyzed_left: float = paralyzed_vfx_timer
	if has_status(StatusId.PARALYZED):
		paralyzed_left = maxf(paralyzed_left, float(timed_statuses.get(int(StatusId.PARALYZED), 0.0)))
	var paralyzed_active: bool = paralyzed_left > 0.001
	var paralyzed_visual_active: bool = paralyzed_active and paralyzed_status_vfx_enabled
	var burning_active: bool = is_burning() or has_status(StatusId.BURNING)
	if not paralyzed_visual_active and not burning_active:
		status_vfx_root.visible = false
		return
	status_vfx_root.visible = true
	var root_bob: float = sin(visual_time * 3.1) * 0.05 if paralyzed_visual_active else sin(visual_time * 2.5) * 0.02
	status_vfx_root.position = Vector3(0.0, paralyzed_vfx_height + root_bob, 0.0)
	if paralyzed_vfx_timer > 0.0:
		paralyzed_vfx_timer = maxf(0.0, paralyzed_vfx_timer - delta)
	if paralyzed_visual_active:
		var total: float = maxf(0.001, maxf(paralyzed_vfx_total, paralyzed_left))
		var life: float = clampf(paralyzed_left / total, 0.0, 1.0)
		var spin: float = visual_time * paralyzed_vfx_spin_speed
		var orbit_r: float = paralyzed_vfx_orbit_radius * (0.92 + sin(visual_time * 5.2) * 0.08)
		if paralyzed_ring_node != null:
			paralyzed_ring_node.visible = true
			paralyzed_ring_node.rotation.y = spin * 0.6
			var ring_scale: float = 1.0 + sin(visual_time * 9.0) * 0.08
			paralyzed_ring_node.scale = Vector3.ONE * ring_scale
		if paralyzed_ring_material != null:
			var ring_color := Color(1.0, 0.9, 0.34, 0.5 + life * 0.42)
			paralyzed_ring_material.albedo_color = ring_color
			paralyzed_ring_material.emission = Color(1.0, 0.93, 0.44, 1.0)
		for i in range(paralyzed_star_nodes.size()):
			var star := paralyzed_star_nodes[i]
			if star == null:
				continue
			star.visible = true
			var angle: float = spin + TAU * float(i) / maxf(1.0, float(paralyzed_star_nodes.size()))
			var bob: float = 0.16 + sin(visual_time * 7.6 + float(i) * 0.9) * 0.06
			star.position = Vector3(cos(angle) * orbit_r, bob, sin(angle) * orbit_r)
			var star_scale: float = 0.92 + sin(visual_time * 11.0 + float(i)) * 0.12
			star.scale = Vector3.ONE * star_scale
			star.rotation.y = -angle
			if i < paralyzed_star_materials.size() and paralyzed_star_materials[i] != null:
				var star_alpha: float = 0.46 + life * 0.48
				paralyzed_star_materials[i].albedo_color = Color(1.0, 0.98, 0.72, star_alpha)
				paralyzed_star_materials[i].emission = Color(1.0, 0.95, 0.58, 1.0)
	else:
		if paralyzed_ring_node != null:
			paralyzed_ring_node.visible = false
		for star in paralyzed_star_nodes:
			if star != null:
				star.visible = false
	_update_burning_status_vfx(burning_active)

func _update_burning_status_vfx(burning_active: bool) -> void:
	if burning_vfx_root == null:
		return
	if not burning_active:
		burning_vfx_root.visible = false
		return
	var lod_tier: int = _get_effect_lod_tier()
	if lod_tier <= 0:
		burning_vfx_root.visible = false
		return
	burning_vfx_root.visible = true
	var life_strength: float = clampf(burn_time_left / maxf(0.001, archer_skill_fire_arrow_burn_duration), 0.35, 1.0)
	var burn_strength: float = clampf(0.62 + burn_dps / 7.5, 0.62, 1.55)
	var intensity: float = life_strength * burn_strength
	var radius: float = maxf(0.7, burning_vfx_radius * 2.1) * (0.92 + intensity * 0.42)
	burning_vfx_root.position = Vector3(0.0, burning_vfx_height - paralyzed_vfx_height + sin(visual_time * 6.0) * 0.03, 0.0)

	if burning_aura_node != null:
		burning_aura_node.visible = false
	if burning_aura_material != null:
		burning_aura_material.albedo_color.a = 0.0

	var flame_count: int = burning_flame_nodes.size() if lod_tier >= 2 else mini(2, burning_flame_nodes.size())
	var flame_denom: float = maxf(1.0, float(maxi(1, burning_flame_nodes.size() - 1)))
	for i in range(burning_flame_nodes.size()):
		var flame := burning_flame_nodes[i]
		if flame == null:
			continue
		if i >= flame_count:
			flame.visible = false
			continue
		flame.visible = true
		var slot: float = float(i) / flame_denom
		var swirl: float = visual_time * (1.9 + slot * 0.35) + TAU * slot
		var flicker: float = 0.84 + sin(visual_time * 13.0 + slot * 8.2) * 0.16
		var ring_r: float = radius * (0.34 + (0.28 + slot * 0.14) * (0.5 + sin(visual_time * 5.4 + slot * 4.2) * 0.5))
		flame.position = Vector3(cos(swirl) * ring_r, 0.12 + sin(visual_time * 11.0 + slot * 7.0) * 0.08, sin(swirl) * ring_r)
		var flame_h: float = maxf(0.42, burning_vfx_flame_height * (2.1 + intensity * 1.05) * flicker)
		var flame_w: float = maxf(0.24, burning_vfx_flame_width * (2.2 + intensity * 0.9) * (0.82 + sin(visual_time * 9.5 + slot * 2.9) * 0.18))
		flame.scale = Vector3(flame_w, flame_h, 1.0)
		flame.rotation.y = swirl
		if i < burning_flame_materials.size() and burning_flame_materials[i] != null:
			var heat: float = clampf(0.5 + sin(visual_time * 12.2 + slot * 9.0) * 0.5, 0.0, 1.0)
			var flame_alpha: float = clampf((0.44 + intensity * 0.36) * (0.84 + heat * 0.22), 0.18, 0.95)
			var flame_green: float = lerpf(0.26, 0.78, heat)
			var flame_blue: float = lerpf(0.08, 0.24, heat)
			burning_flame_materials[i].albedo_color = Color(1.0, flame_green, flame_blue, flame_alpha)
			burning_flame_materials[i].emission = Color(1.0, lerpf(0.44, 0.86, heat), flame_blue, 1.0)
			burning_flame_materials[i].emission_energy_multiplier = 1.5 + intensity * 1.8 + heat * 0.6

	var ember_count: int = burning_ember_nodes.size() if lod_tier >= 2 else mini(1, burning_ember_nodes.size())
	var ember_denom: float = maxf(1.0, float(maxi(1, burning_ember_nodes.size() - 1)))
	for i in range(burning_ember_nodes.size()):
		var ember := burning_ember_nodes[i]
		if ember == null:
			continue
		if i >= ember_count:
			ember.visible = false
			continue
		ember.visible = true
		var slot: float = float(i) / ember_denom
		var rise: float = fposmod(visual_time * (0.52 + slot * 0.24) + slot * 0.9, 1.0)
		var ang: float = visual_time * (3.7 + slot) + TAU * slot * 1.38
		var ember_r: float = radius * (0.12 + rise * 0.78)
		ember.position = Vector3(cos(ang) * ember_r, 0.2 + rise * maxf(0.4, burning_vfx_ember_rise), sin(ang) * ember_r)
		var ember_scale: float = 0.1 + (1.0 - rise) * 0.12
		ember.scale = Vector3.ONE * ember_scale
		if i < burning_ember_materials.size() and burning_ember_materials[i] != null:
			var ember_alpha: float = clampf((1.0 - rise) * (0.34 + intensity * 0.24), 0.0, 0.6)
			burning_ember_materials[i].albedo_color = Color(1.0, 0.78, 0.36, ember_alpha)
			burning_ember_materials[i].emission = Color(1.0, 0.74, 0.3, 1.0)
			burning_ember_materials[i].emission_energy_multiplier = 1.2 + intensity * 0.9

	for smoke in burning_smoke_nodes:
		if smoke != null:
			smoke.visible = false

func _get_effect_camera_depth() -> float:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return 0.0
	var local_pos := cam.global_transform.affine_inverse() * global_position
	return maxf(-local_pos.z, 0.0)

func _get_effect_lod_tier() -> int:
	var depth: float = _get_effect_camera_depth()
	var near_depth: float = maxf(1.0, effect_visible_near_depth)
	var mid_depth: float = maxf(near_depth, effect_visible_mid_depth)
	if depth <= near_depth:
		return 2
	if depth <= mid_depth:
		return 1
	return 0

func _get_effect_scale_mul_for_tier(tier: int) -> float:
	var base_mul: float = maxf(1.0, effect_world_scale_mul)
	if tier >= 2:
		return base_mul
	if tier == 1:
		return base_mul * clampf(effect_mid_scale_mul, 0.3, 1.0)
	return 0.0

func _set_vfx_material_depth_mode(mat: BaseMaterial3D) -> void:
	if mat == null:
		return
	mat.no_depth_test = effect_force_no_depth_test

func _make_vfx_sprite_material(tex: Texture2D, tint: Color, emission_mul: float, billboard_mode: int) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_texture = tex
	mat.albedo_color = tint
	mat.emission_enabled = true
	mat.emission = Color(tint.r, tint.g, tint.b, 1.0)
	mat.emission_energy_multiplier = emission_mul
	mat.billboard_mode = billboard_mode
	_set_vfx_material_depth_mode(mat)
	return mat

func _get_lod_particle_amount(base_amount: int, lod_tier: int) -> int:
	if lod_tier <= 0:
		return 0
	if lod_tier >= 2:
		return base_amount
	return maxi(2, int(round(float(base_amount) * 0.55)))

func _restart_vfx_particles(emitter: GPUParticles3D, amount: int) -> void:
	if emitter == null:
		return
	var final_amount: int = amount
	if performance_mode_low:
		var density_scale: float = clampf(effect_particle_density_scale, 0.05, 1.0)
		final_amount = maxi(1, int(round(float(amount) * density_scale)))
	if final_amount <= 0:
		emitter.emitting = false
		return
	emitter.amount = final_amount
	emitter.emitting = false
	emitter.restart()
	emitter.emitting = true

func _build_strategist_attack_vfx() -> void:
	if strategist_cast_vfx_root != null and is_instance_valid(strategist_cast_vfx_root):
		return
	var parent_root: Node3D = _ensure_vfx_root()

	strategist_cast_vfx_root = Node3D.new()
	strategist_cast_vfx_root.name = "StrategistCastVfx"
	strategist_cast_vfx_root.top_level = true
	strategist_cast_vfx_root.visible = false
	parent_root.add_child(strategist_cast_vfx_root)

	strategist_cast_ring_node = MeshInstance3D.new()
	strategist_cast_ring_node.name = "CastRing"
	strategist_cast_ring_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var cast_ring_mesh := CylinderMesh.new()
	cast_ring_mesh.top_radius = 0.42
	cast_ring_mesh.bottom_radius = 0.5
	cast_ring_mesh.height = 0.02
	cast_ring_mesh.radial_segments = 28
	strategist_cast_ring_node.mesh = cast_ring_mesh
	strategist_cast_ring_material = StandardMaterial3D.new()
	strategist_cast_ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	strategist_cast_ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	strategist_cast_ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	strategist_cast_ring_material.albedo_color = Color(0.56, 0.93, 1.0, 0.0)
	strategist_cast_ring_material.emission_enabled = true
	strategist_cast_ring_material.emission = Color(0.42, 0.9, 1.0, 1.0)
	strategist_cast_ring_material.emission_energy_multiplier = 1.9
	_set_vfx_material_depth_mode(strategist_cast_ring_material)
	strategist_cast_ring_node.material_override = strategist_cast_ring_material
	strategist_cast_vfx_root.add_child(strategist_cast_ring_node)

	strategist_cast_core_node = MeshInstance3D.new()
	strategist_cast_core_node.name = "CastCore"
	strategist_cast_core_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var cast_core_mesh := SphereMesh.new()
	cast_core_mesh.radius = 0.17
	cast_core_mesh.height = 0.34
	strategist_cast_core_node.mesh = cast_core_mesh
	strategist_cast_core_material = StandardMaterial3D.new()
	strategist_cast_core_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	strategist_cast_core_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	strategist_cast_core_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	strategist_cast_core_material.albedo_color = Color(0.86, 0.98, 1.0, 0.0)
	strategist_cast_core_material.emission_enabled = true
	strategist_cast_core_material.emission = Color(0.68, 0.96, 1.0, 1.0)
	strategist_cast_core_material.emission_energy_multiplier = 2.2
	_set_vfx_material_depth_mode(strategist_cast_core_material)
	strategist_cast_core_node.material_override = strategist_cast_core_material
	strategist_cast_vfx_root.add_child(strategist_cast_core_node)

	strategist_cast_sigil_node = MeshInstance3D.new()
	strategist_cast_sigil_node.name = "CastSigil"
	strategist_cast_sigil_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var cast_sigil_mesh := QuadMesh.new()
	cast_sigil_mesh.size = Vector2(1.1, 1.1)
	strategist_cast_sigil_node.mesh = cast_sigil_mesh
	strategist_cast_sigil_node.rotation_degrees.x = -90.0
	strategist_cast_sigil_node.position = Vector3(0.0, 0.02, 0.0)
	strategist_cast_sigil_material = _make_vfx_sprite_material(STRATEGIST_CAST_SIGIL_TEX, Color(0.45, 0.9, 1.0, 0.0), 1.45, BaseMaterial3D.BILLBOARD_DISABLED)
	strategist_cast_sigil_node.material_override = strategist_cast_sigil_material
	strategist_cast_vfx_root.add_child(strategist_cast_sigil_node)

	strategist_cast_spark_emitter = GPUParticles3D.new()
	strategist_cast_spark_emitter.name = "CastSparks"
	strategist_cast_spark_emitter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	strategist_cast_spark_emitter.one_shot = true
	strategist_cast_spark_emitter.amount = 12
	strategist_cast_spark_emitter.lifetime = 0.42
	strategist_cast_spark_emitter.preprocess = 0.0
	strategist_cast_spark_emitter.fixed_fps = 0
	var cast_spark_pm := ParticleProcessMaterial.new()
	cast_spark_pm.set("emission_shape", int(ParticleProcessMaterial.EMISSION_SHAPE_SPHERE))
	cast_spark_pm.set("emission_sphere_radius", 0.28)
	cast_spark_pm.set("direction", Vector3.UP)
	cast_spark_pm.set("spread", 64.0)
	cast_spark_pm.set("gravity", Vector3(0.0, 0.55, 0.0))
	cast_spark_pm.set("initial_velocity_min", 0.6)
	cast_spark_pm.set("initial_velocity_max", 1.6)
	cast_spark_pm.set("damping_min", 0.4)
	cast_spark_pm.set("damping_max", 1.2)
	cast_spark_pm.set("scale_min", 0.08)
	cast_spark_pm.set("scale_max", 0.18)
	cast_spark_pm.set("color", Color(0.62, 0.96, 1.0, 0.78))
	strategist_cast_spark_process = cast_spark_pm
	strategist_cast_spark_emitter.process_material = cast_spark_pm
	var cast_spark_mesh := QuadMesh.new()
	cast_spark_mesh.size = Vector2(0.18, 0.18)
	strategist_cast_spark_emitter.draw_pass_1 = cast_spark_mesh
	strategist_cast_spark_material = _make_vfx_sprite_material(STRATEGIST_SPARK_TEX, Color(0.76, 0.98, 1.0, 0.9), 1.6, BaseMaterial3D.BILLBOARD_ENABLED)
	strategist_cast_spark_emitter.material_override = strategist_cast_spark_material
	strategist_cast_spark_emitter.emitting = false
	strategist_cast_spark_emitter.position = Vector3(0.0, 0.08, 0.0)
	strategist_cast_vfx_root.add_child(strategist_cast_spark_emitter)

	strategist_impact_vfx_root = Node3D.new()
	strategist_impact_vfx_root.name = "StrategistImpactVfx"
	strategist_impact_vfx_root.top_level = true
	strategist_impact_vfx_root.visible = false
	parent_root.add_child(strategist_impact_vfx_root)

	strategist_impact_ring_node = MeshInstance3D.new()
	strategist_impact_ring_node.name = "ImpactRing"
	strategist_impact_ring_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var impact_ring_mesh := CylinderMesh.new()
	impact_ring_mesh.top_radius = 0.48
	impact_ring_mesh.bottom_radius = 0.56
	impact_ring_mesh.height = 0.02
	impact_ring_mesh.radial_segments = 28
	strategist_impact_ring_node.mesh = impact_ring_mesh
	strategist_impact_ring_material = StandardMaterial3D.new()
	strategist_impact_ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	strategist_impact_ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	strategist_impact_ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	strategist_impact_ring_material.albedo_color = Color(0.62, 0.95, 1.0, 0.0)
	strategist_impact_ring_material.emission_enabled = true
	strategist_impact_ring_material.emission = Color(0.52, 0.95, 1.0, 1.0)
	strategist_impact_ring_material.emission_energy_multiplier = 2.1
	_set_vfx_material_depth_mode(strategist_impact_ring_material)
	strategist_impact_ring_node.material_override = strategist_impact_ring_material
	strategist_impact_vfx_root.add_child(strategist_impact_ring_node)

	strategist_impact_core_node = MeshInstance3D.new()
	strategist_impact_core_node.name = "ImpactCore"
	strategist_impact_core_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var impact_core_mesh := SphereMesh.new()
	impact_core_mesh.radius = 0.2
	impact_core_mesh.height = 0.38
	strategist_impact_core_node.mesh = impact_core_mesh
	strategist_impact_core_material = StandardMaterial3D.new()
	strategist_impact_core_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	strategist_impact_core_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	strategist_impact_core_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	strategist_impact_core_material.albedo_color = Color(0.95, 0.99, 1.0, 0.0)
	strategist_impact_core_material.emission_enabled = true
	strategist_impact_core_material.emission = Color(0.78, 0.98, 1.0, 1.0)
	strategist_impact_core_material.emission_energy_multiplier = 2.4
	_set_vfx_material_depth_mode(strategist_impact_core_material)
	strategist_impact_core_node.material_override = strategist_impact_core_material
	strategist_impact_vfx_root.add_child(strategist_impact_core_node)

	strategist_impact_flash_node = MeshInstance3D.new()
	strategist_impact_flash_node.name = "ImpactFlash"
	strategist_impact_flash_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var impact_flash_mesh := QuadMesh.new()
	impact_flash_mesh.size = Vector2(1.6, 1.6)
	strategist_impact_flash_node.mesh = impact_flash_mesh
	strategist_impact_flash_node.position = Vector3(0.0, 0.18, 0.0)
	strategist_impact_flash_material = _make_vfx_sprite_material(STRATEGIST_IMPACT_FLASH_TEX, Color(0.82, 0.98, 1.0, 0.0), 2.2, BaseMaterial3D.BILLBOARD_ENABLED)
	strategist_impact_flash_node.material_override = strategist_impact_flash_material
	strategist_impact_vfx_root.add_child(strategist_impact_flash_node)

	strategist_impact_spark_emitter = GPUParticles3D.new()
	strategist_impact_spark_emitter.name = "ImpactSparks"
	strategist_impact_spark_emitter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	strategist_impact_spark_emitter.one_shot = true
	strategist_impact_spark_emitter.amount = 16
	strategist_impact_spark_emitter.lifetime = 0.5
	strategist_impact_spark_emitter.preprocess = 0.0
	strategist_impact_spark_emitter.fixed_fps = 0
	var impact_spark_pm := ParticleProcessMaterial.new()
	impact_spark_pm.set("emission_shape", int(ParticleProcessMaterial.EMISSION_SHAPE_SPHERE))
	impact_spark_pm.set("emission_sphere_radius", 0.34)
	impact_spark_pm.set("direction", Vector3.UP)
	impact_spark_pm.set("spread", 78.0)
	impact_spark_pm.set("gravity", Vector3(0.0, 0.9, 0.0))
	impact_spark_pm.set("initial_velocity_min", 1.0)
	impact_spark_pm.set("initial_velocity_max", 2.4)
	impact_spark_pm.set("damping_min", 0.3)
	impact_spark_pm.set("damping_max", 1.2)
	impact_spark_pm.set("scale_min", 0.1)
	impact_spark_pm.set("scale_max", 0.24)
	impact_spark_pm.set("color", Color(0.72, 0.98, 1.0, 0.78))
	strategist_impact_spark_process = impact_spark_pm
	strategist_impact_spark_emitter.process_material = impact_spark_pm
	var impact_spark_mesh := QuadMesh.new()
	impact_spark_mesh.size = Vector2(0.2, 0.2)
	strategist_impact_spark_emitter.draw_pass_1 = impact_spark_mesh
	strategist_impact_spark_material = _make_vfx_sprite_material(STRATEGIST_SPARK_TEX, Color(0.86, 0.98, 1.0, 0.95), 1.8, BaseMaterial3D.BILLBOARD_ENABLED)
	strategist_impact_spark_emitter.material_override = strategist_impact_spark_material
	strategist_impact_spark_emitter.emitting = false
	strategist_impact_spark_emitter.position = Vector3(0.0, 0.12, 0.0)
	strategist_impact_vfx_root.add_child(strategist_impact_spark_emitter)

func _trigger_strategist_cast_vfx() -> void:
	if not _is_strategist_role():
		return
	var lod_tier: int = _get_effect_lod_tier()
	if lod_tier <= 0:
		return
	if strategist_cast_vfx_root == null or not is_instance_valid(strategist_cast_vfx_root):
		_build_strategist_attack_vfx()
		if strategist_cast_vfx_root == null:
			return
	strategist_cast_total = maxf(0.08, strategist_cast_vfx_duration)
	strategist_cast_timer = strategist_cast_total
	strategist_cast_vfx_root.visible = true
	var forward: Vector3 = get_collision_forward_flat()
	if forward.length_squared() <= EPS:
		forward = desired_facing if desired_facing.length_squared() > EPS else Vector3.FORWARD
	forward = forward.normalized()
	strategist_cast_vfx_root.global_position = global_position + forward * maxf(0.12, get_collision_half_extents().y * 0.22) + Vector3(0.0, archer_arrow_height_offset * 0.72, 0.0)
	strategist_cast_vfx_root.scale = Vector3.ONE
	var spark_amount: int = _get_lod_particle_amount(12, lod_tier)
	_restart_vfx_particles(strategist_cast_spark_emitter, spark_amount)

func _queue_strategist_impact_vfx(enemy: UnitController) -> void:
	if enemy == null or enemy.dead or not _is_strategist_role():
		return
	var from: Vector3 = global_position + Vector3(0.0, archer_arrow_height_offset, 0.0)
	var to: Vector3 = enemy.global_position + Vector3(0.0, archer_arrow_height_offset, 0.0)
	var dist: float = from.distance_to(to)
	var travel_ref: float = maxf(12.0, archer_preferred_range * 1.8)
	var delay: float = clampf((dist / travel_ref) * maxf(0.1, strategist_impact_delay_mul), 0.06, 0.42)
	strategist_pending_impacts.append({
		"delay": delay,
		"target": enemy,
		"fallback_pos": enemy.global_position
	})

func _trigger_strategist_impact_vfx(world_pos: Vector3) -> void:
	var lod_tier: int = _get_effect_lod_tier()
	if lod_tier <= 0:
		return
	if strategist_impact_vfx_root == null or not is_instance_valid(strategist_impact_vfx_root):
		_build_strategist_attack_vfx()
		if strategist_impact_vfx_root == null:
			return
	strategist_impact_total = maxf(0.08, strategist_impact_vfx_duration)
	strategist_impact_timer = strategist_impact_total
	strategist_impact_vfx_root.visible = true
	strategist_impact_vfx_root.global_position = Vector3(world_pos.x, world_pos.y + archer_arrow_height_offset * 0.62, world_pos.z)
	strategist_impact_vfx_root.scale = Vector3.ONE
	var spark_amount: int = _get_lod_particle_amount(16, lod_tier)
	_restart_vfx_particles(strategist_impact_spark_emitter, spark_amount)

func _update_strategist_attack_vfx(delta: float) -> void:
	if strategist_cast_vfx_root == null or strategist_impact_vfx_root == null:
		return
	var lod_tier: int = _get_effect_lod_tier()
	for i in range(strategist_pending_impacts.size() - 1, -1, -1):
		var item: Dictionary = strategist_pending_impacts[i]
		var left: float = maxf(0.0, float(item.get("delay", 0.0)) - maxf(0.0, delta))
		if left > 0.001:
			item["delay"] = left
			strategist_pending_impacts[i] = item
			continue
		var target_any: Variant = item.get("target", null)
		var hit_pos: Vector3 = item.get("fallback_pos", global_position)
		if target_any != null and is_instance_valid(target_any) and target_any is UnitController:
			var target: UnitController = target_any as UnitController
			if target != null and is_instance_valid(target) and not target.dead:
				hit_pos = target.global_position
		_trigger_strategist_impact_vfx(hit_pos)
		strategist_pending_impacts.remove_at(i)

	if strategist_cast_timer > 0.0 and strategist_cast_vfx_root != null:
		strategist_cast_timer = maxf(0.0, strategist_cast_timer - maxf(0.0, delta))
		if lod_tier <= 0:
			strategist_cast_vfx_root.visible = false
			strategist_cast_timer = 0.0
			if strategist_cast_spark_emitter != null:
				strategist_cast_spark_emitter.emitting = false
			if strategist_cast_sigil_node != null:
				strategist_cast_sigil_node.visible = false
		else:
			strategist_cast_vfx_root.visible = true
			var cast_p: float = clampf(1.0 - strategist_cast_timer / maxf(0.001, strategist_cast_total), 0.0, 1.0)
			var cast_ease: float = ease(cast_p, -1.25)
			if strategist_cast_ring_node != null:
				strategist_cast_ring_node.visible = true
				var r_scale: float = lerpf(0.38, 1.38, cast_ease)
				strategist_cast_ring_node.scale = Vector3(r_scale, 1.0, r_scale)
				strategist_cast_ring_node.rotation.y = visual_time * 2.2
			if strategist_cast_ring_material != null:
				strategist_cast_ring_material.albedo_color = Color(0.56, 0.93, 1.0, (1.0 - cast_p) * 0.78)
				strategist_cast_ring_material.emission_energy_multiplier = 1.6 + (1.0 - cast_p) * 1.2
			if strategist_cast_core_node != null:
				strategist_cast_core_node.visible = true
				var c_scale: float = lerpf(0.22, 0.74, cast_ease)
				strategist_cast_core_node.scale = Vector3.ONE * c_scale
			if strategist_cast_core_material != null:
				var core_alpha: float = clampf((1.0 - cast_p * 0.85) * 0.92, 0.0, 0.92)
				strategist_cast_core_material.albedo_color = Color(0.86, 0.98, 1.0, core_alpha)
				strategist_cast_core_material.emission_energy_multiplier = 1.8 + (1.0 - cast_p) * 1.4
			var sigil_alpha: float = clampf((1.0 - cast_p) * 0.6, 0.0, 0.85)
			if lod_tier == 1:
				sigil_alpha *= 0.7
			if strategist_cast_sigil_node != null:
				strategist_cast_sigil_node.visible = true
				var sigil_scale: float = lerpf(0.5, 1.45, cast_ease)
				strategist_cast_sigil_node.scale = Vector3.ONE * sigil_scale
				strategist_cast_sigil_node.rotation.y = visual_time * 1.6
			if strategist_cast_sigil_material != null:
				strategist_cast_sigil_material.albedo_color = Color(0.45, 0.9, 1.0, sigil_alpha)
				strategist_cast_sigil_material.emission_energy_multiplier = 1.1 + (1.0 - cast_p) * 1.0
	else:
		if strategist_cast_vfx_root != null:
			strategist_cast_vfx_root.visible = false
		if strategist_cast_spark_emitter != null:
			strategist_cast_spark_emitter.emitting = false
		if strategist_cast_sigil_node != null:
			strategist_cast_sigil_node.visible = false

	if strategist_impact_timer > 0.0 and strategist_impact_vfx_root != null:
		strategist_impact_timer = maxf(0.0, strategist_impact_timer - maxf(0.0, delta))
		if lod_tier <= 0:
			strategist_impact_vfx_root.visible = false
			strategist_impact_timer = 0.0
			if strategist_impact_spark_emitter != null:
				strategist_impact_spark_emitter.emitting = false
			if strategist_impact_flash_node != null:
				strategist_impact_flash_node.visible = false
		else:
			strategist_impact_vfx_root.visible = true
			var hit_p: float = clampf(1.0 - strategist_impact_timer / maxf(0.001, strategist_impact_total), 0.0, 1.0)
			var hit_ease: float = ease(hit_p, -1.2)
			if strategist_impact_ring_node != null:
				strategist_impact_ring_node.visible = true
				var ring_scale: float = lerpf(0.28, 1.86, hit_ease)
				strategist_impact_ring_node.scale = Vector3(ring_scale, 1.0, ring_scale)
				strategist_impact_ring_node.rotation.y = visual_time * 3.1
			if strategist_impact_ring_material != null:
				strategist_impact_ring_material.albedo_color = Color(0.62, 0.95, 1.0, (1.0 - hit_p) * 0.86)
				strategist_impact_ring_material.emission_energy_multiplier = 1.9 + (1.0 - hit_p) * 1.8
			if strategist_impact_core_node != null:
				strategist_impact_core_node.visible = true
				var core_scale: float = lerpf(0.84, 0.16, hit_ease)
				strategist_impact_core_node.scale = Vector3.ONE * core_scale
			if strategist_impact_core_material != null:
				var a: float = clampf((1.0 - hit_p * 1.1) * 0.92, 0.0, 0.92)
				strategist_impact_core_material.albedo_color = Color(0.95, 0.99, 1.0, a)
				strategist_impact_core_material.emission_energy_multiplier = 2.1 + (1.0 - hit_p) * 1.5
			var flash_alpha: float = clampf(1.0 - hit_p * 1.2, 0.0, 1.0) * 0.75
			if lod_tier == 1:
				flash_alpha *= 0.7
			if strategist_impact_flash_node != null:
				strategist_impact_flash_node.visible = true
				var flash_scale: float = lerpf(0.6, 1.8, hit_ease)
				strategist_impact_flash_node.scale = Vector3.ONE * flash_scale
				strategist_impact_flash_node.rotation.y = visual_time * 2.0
			if strategist_impact_flash_material != null:
				strategist_impact_flash_material.albedo_color = Color(0.82, 0.98, 1.0, flash_alpha)
				strategist_impact_flash_material.emission_energy_multiplier = 2.0 + (1.0 - hit_p) * 1.6
	else:
		if strategist_impact_vfx_root != null:
			strategist_impact_vfx_root.visible = false
		if strategist_impact_spark_emitter != null:
			strategist_impact_spark_emitter.emitting = false
		if strategist_impact_flash_node != null:
			strategist_impact_flash_node.visible = false

func _get_current_enemy_target_for_vfx() -> UnitController:
	if target_unit != null and is_instance_valid(target_unit) and not target_unit.dead and target_unit.team_id != team_id:
		return target_unit
	if chase_target_unit != null and is_instance_valid(chase_target_unit) and not chase_target_unit.dead and chase_target_unit.team_id != team_id:
		return chase_target_unit
	return null

func _get_strategist_blade_face_dir(base_dir: Vector3 = Vector3.FORWARD, enemy: UnitController = null) -> Vector3:
	var dir: Vector3 = base_dir
	if enemy != null and is_instance_valid(enemy) and not enemy.dead:
		dir = enemy.global_position - global_position
		dir.y = 0.0
	if dir.length_squared() <= EPS:
		dir = get_collision_forward_flat()
	if dir.length_squared() <= EPS:
		dir = desired_facing
	if dir.length_squared() <= EPS:
		dir = Vector3.FORWARD
	dir = dir.normalized()
	var yaw_offset_rad: float = deg_to_rad(strategist_blade_face_offset_deg)
	if absf(yaw_offset_rad) > 0.00001:
		dir = dir.rotated(Vector3.UP, yaw_offset_rad).normalized()
	return dir

func _ensure_strategist_blade_debug_marker() -> void:
	if strategist_blade_debug_node != null and is_instance_valid(strategist_blade_debug_node) and strategist_blade_debug_mesh != null:
		return
	strategist_blade_debug_node = MeshInstance3D.new()
	strategist_blade_debug_node.name = "StrategistBladeDebug"
	strategist_blade_debug_node.top_level = true
	strategist_blade_debug_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	strategist_blade_debug_mesh = ImmediateMesh.new()
	strategist_blade_debug_node.mesh = strategist_blade_debug_mesh
	strategist_blade_debug_material = StandardMaterial3D.new()
	strategist_blade_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	strategist_blade_debug_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	strategist_blade_debug_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	strategist_blade_debug_material.vertex_color_use_as_albedo = true
	strategist_blade_debug_material.albedo_color = Color(1.0, 1.0, 1.0, 0.95)
	strategist_blade_debug_material.emission_enabled = true
	strategist_blade_debug_material.emission = Color(0.9, 0.96, 1.0, 1.0)
	strategist_blade_debug_material.emission_energy_multiplier = 1.2
	_set_vfx_material_depth_mode(strategist_blade_debug_material)
	strategist_blade_debug_node.material_override = strategist_blade_debug_material
	var parent_root: Node3D = _ensure_vfx_root()
	parent_root.add_child(strategist_blade_debug_node)
	strategist_blade_debug_node.visible = false

func _update_strategist_blade_debug_marker() -> void:
	if not strategist_blade_debug_visible or not _is_strategist_role():
		if strategist_blade_debug_node != null and is_instance_valid(strategist_blade_debug_node):
			strategist_blade_debug_node.visible = false
		return
	_ensure_strategist_blade_debug_marker()
	if strategist_blade_debug_node == null or strategist_blade_debug_mesh == null:
		return
	var enemy: UnitController = _get_current_enemy_target_for_vfx()
	var face_dir: Vector3 = _get_strategist_blade_face_dir(get_collision_forward_flat(), enemy)
	var side_dir: Vector3 = Vector3(-face_dir.z, 0.0, face_dir.x)
	if side_dir.length_squared() <= EPS:
		side_dir = Vector3.RIGHT
	side_dir = side_dir.normalized() * (1.0 if strategist_blade_curve_sign >= 0.0 else -1.0)
	var base: Vector3 = global_position + Vector3(0.0, archer_arrow_height_offset * 0.72, 0.0)
	var len: float = maxf(1.0, strategist_blade_debug_length)
	var side_len: float = len * 0.75
	strategist_blade_debug_node.visible = true
	strategist_blade_debug_node.global_position = Vector3.ZERO
	strategist_blade_debug_mesh.clear_surfaces()
	strategist_blade_debug_mesh.surface_begin(Mesh.PRIMITIVE_LINES, strategist_blade_debug_material)
	strategist_blade_debug_mesh.surface_set_color(Color(0.2, 1.0, 0.58, 0.95))
	strategist_blade_debug_mesh.surface_add_vertex(base)
	strategist_blade_debug_mesh.surface_add_vertex(base + face_dir * len)
	strategist_blade_debug_mesh.surface_set_color(Color(1.0, 0.72, 0.18, 0.95))
	strategist_blade_debug_mesh.surface_add_vertex(base)
	strategist_blade_debug_mesh.surface_add_vertex(base + side_dir * side_len)
	strategist_blade_debug_mesh.surface_end()

func _build_sweep_impact_vfx() -> void:
	sweep_impact_vfx_root = Node3D.new()
	sweep_impact_vfx_root.name = "SweepImpactVfx"
	sweep_impact_vfx_root.top_level = true
	sweep_impact_vfx_root.visible = false
	add_child(sweep_impact_vfx_root)

	sweep_impact_ring_node = MeshInstance3D.new()
	sweep_impact_ring_node.name = "DustOuter"
	sweep_impact_ring_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var impact_ring := CylinderMesh.new()
	impact_ring.top_radius = 0.84
	impact_ring.bottom_radius = 0.98
	impact_ring.height = 0.02
	impact_ring.radial_segments = 28
	sweep_impact_ring_node.mesh = impact_ring
	sweep_impact_ring_material = StandardMaterial3D.new()
	sweep_impact_ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sweep_impact_ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sweep_impact_ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	sweep_impact_ring_material.albedo_color = Color(0.44, 0.38, 0.31, 0.0)
	sweep_impact_ring_material.emission_enabled = false
	_set_vfx_material_depth_mode(sweep_impact_ring_material)
	sweep_impact_ring_node.material_override = sweep_impact_ring_material
	sweep_impact_vfx_root.add_child(sweep_impact_ring_node)

	sweep_impact_disc_node = MeshInstance3D.new()
	sweep_impact_disc_node.name = "DustCore"
	sweep_impact_disc_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var impact_disc := CylinderMesh.new()
	impact_disc.top_radius = 0.62
	impact_disc.bottom_radius = 0.72
	impact_disc.height = 0.016
	impact_disc.radial_segments = 24
	sweep_impact_disc_node.mesh = impact_disc
	sweep_impact_disc_material = StandardMaterial3D.new()
	sweep_impact_disc_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sweep_impact_disc_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sweep_impact_disc_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	sweep_impact_disc_material.albedo_color = Color(0.39, 0.34, 0.28, 0.0)
	sweep_impact_disc_material.emission_enabled = false
	_set_vfx_material_depth_mode(sweep_impact_disc_material)
	sweep_impact_disc_node.material_override = sweep_impact_disc_material
	sweep_impact_vfx_root.add_child(sweep_impact_disc_node)

	sweep_impact_puff_nodes.clear()
	sweep_impact_puff_materials.clear()
	var puff_mesh := SphereMesh.new()
	puff_mesh.radius = 0.22
	puff_mesh.height = 0.48
	for i in range(6):
		var puff := MeshInstance3D.new()
		puff.name = "DustPuff%d" % i
		puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		puff.mesh = puff_mesh
		var puff_mat := StandardMaterial3D.new()
		puff_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		puff_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		puff_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		puff_mat.albedo_color = Color(0.46, 0.4, 0.32, 0.0)
		puff_mat.emission_enabled = false
		_set_vfx_material_depth_mode(puff_mat)
		puff.material_override = puff_mat
		sweep_impact_vfx_root.add_child(puff)
		sweep_impact_puff_nodes.append(puff)
		sweep_impact_puff_materials.append(puff_mat)

func _trigger_sweep_impact_vfx(world_center: Vector3, radius: float, forward_dir: Vector3 = Vector3.ZERO) -> void:
	if sweep_impact_vfx_root == null:
		return
	var lod_tier: int = maxi(1, _get_effect_lod_tier())
	var scale_boost: float = _get_effect_scale_mul_for_tier(lod_tier)
	sweep_impact_vfx_total = maxf(0.12, sweep_impact_vfx_duration)
	sweep_impact_vfx_timer = sweep_impact_vfx_total
	sweep_impact_vfx_root.visible = true
	sweep_impact_vfx_root.global_position = Vector3(world_center.x, world_center.y + 0.04, world_center.z)
	sweep_impact_forward_dir = forward_dir
	sweep_impact_forward_dir.y = 0.0
	if sweep_impact_forward_dir.length_squared() <= EPS:
		sweep_impact_forward_dir = get_collision_forward_flat()
	sweep_impact_forward_dir = sweep_impact_forward_dir.normalized()
	if sweep_impact_forward_dir.length_squared() > EPS:
		sweep_impact_vfx_root.global_basis = Basis.looking_at(sweep_impact_forward_dir, Vector3.UP, true)
	var base_scale: float = clampf(radius * (0.88 + scale_boost * 0.06), maxf(1.5, radius * 0.92), maxf(4.6, radius * 1.46))
	sweep_impact_vfx_root.scale = Vector3(base_scale, 1.0, base_scale)
	if sweep_impact_ring_node != null:
		sweep_impact_ring_node.visible = false
		sweep_impact_ring_node.scale = Vector3.ONE
		sweep_impact_ring_node.position = Vector3.ZERO
	if sweep_impact_disc_node != null:
		sweep_impact_disc_node.visible = false
		sweep_impact_disc_node.scale = Vector3.ONE
		sweep_impact_disc_node.position = Vector3.ZERO
	for i in range(sweep_impact_puff_nodes.size()):
		var puff := sweep_impact_puff_nodes[i]
		if puff == null:
			continue
		puff.visible = true
		puff.scale = Vector3(0.18, 0.62, 0.18)
		puff.position = Vector3.ZERO

func _update_sweep_impact_vfx(delta: float) -> void:
	if sweep_impact_vfx_root == null:
		return
	if sweep_impact_vfx_timer <= 0.0:
		sweep_impact_vfx_root.visible = false
		return
	sweep_impact_vfx_timer = maxf(0.0, sweep_impact_vfx_timer - delta)
	if _get_effect_lod_tier() <= 0:
		sweep_impact_vfx_root.visible = false
		sweep_impact_vfx_timer = 0.0
		return
	sweep_impact_vfx_root.visible = true
	var total: float = maxf(0.001, sweep_impact_vfx_total)
	var p: float = clampf(1.0 - sweep_impact_vfx_timer / total, 0.0, 1.0)
	var ease_out: float = ease(p, -1.18)
	var drift: float = lerpf(0.0, sweep_impact_forward_offset * 0.55, ease_out)
	var visual_time: float = p * total
	if sweep_impact_ring_node != null:
		sweep_impact_ring_node.visible = false
	if sweep_impact_disc_node != null:
		sweep_impact_disc_node.visible = false
	if sweep_impact_ring_material != null:
		sweep_impact_ring_material.albedo_color = Color(0.43, 0.38, 0.31, 0.0)
	if sweep_impact_disc_material != null:
		sweep_impact_disc_material.albedo_color = Color(0.36, 0.31, 0.25, 0.0)
	for i in range(sweep_impact_puff_nodes.size()):
		var puff := sweep_impact_puff_nodes[i]
		if puff == null:
			continue
		var t: float = float(i) / maxf(1.0, float(sweep_impact_puff_nodes.size() - 1))
		var side_sign: float = -1.0 if i % 2 == 0 else 1.0
		var lateral: float = lerpf(0.12, 0.92, t)
		var forward_push: float = lerpf(0.14, 0.82, t)
		puff.position = Vector3(side_sign * lateral * (0.18 + ease_out * 0.64), 0.05 + p * (0.08 + t * 0.12), -drift * (0.22 + t * 0.26) - forward_push * ease_out * 0.28)
		puff.scale = Vector3(0.2 + ease_out * (0.46 + t * 0.18), 0.32 + ease_out * 0.22, 0.16 + ease_out * (0.52 + t * 0.22))
		puff.rotation.y = side_sign * (0.18 + visual_time * (0.7 + t * 0.24))
		if i < sweep_impact_puff_materials.size() and sweep_impact_puff_materials[i] != null:
			var puff_alpha: float = minf(1.0, sweep_impact_puff_alpha * 1.16) * (0.96 - t * 0.18) * (1.0 - p * (0.68 + t * 0.16))
			sweep_impact_puff_materials[i].albedo_color = Color(0.5, 0.43, 0.35, puff_alpha)
	if sweep_impact_vfx_timer <= 0.0:
		sweep_impact_vfx_root.visible = false

func _build_skill_success_vfx() -> void:
	var parent_root: Node3D = _ensure_vfx_root()
	if skill_success_vfx_instance != null and is_instance_valid(skill_success_vfx_instance):
		return
	skill_success_vfx_instance = TACTIC_SUCCESS_VFX_SCENE.instantiate()
	skill_success_vfx_instance.name = "SkillSuccessVfx"
	parent_root.add_child(skill_success_vfx_instance)

func _trigger_skill_success_vfx(skill_id: SkillType, world_center: Vector3, forward_dir: Vector3 = Vector3.ZERO, scale_mul: float = 1.0) -> void:
	_show_skill_name_popup(skill_id)

func _update_skill_success_vfx(_delta: float) -> void:
	pass
static func _get_float_text_font() -> FontFile:
	if _cached_float_text_font == null and ResourceLoader.exists(FLOAT_TEXT_FONT_PATH):
		_cached_float_text_font = load(FLOAT_TEXT_FONT_PATH) as FontFile
	return _cached_float_text_font

func _get_skill_display_name(skill_id: SkillType) -> String:
	var role_id: String = combat_role_id.strip_edges().to_lower()
	var is_archer: bool = role_id == "archer"
	var is_crossbow: bool = role_id == "crossbow"
	match skill_id:
		SkillType.CHARGE:
			if role_id == "spear":
				return "\u62d2\u9635\u523a"
			if role_id == "shield":
				return "\u94c1\u58c1\u9635"
			if is_crossbow:
				return "\u673a\u5f29\u9f50\u53d1"
			if is_archer:
				return "\u71ce\u539f\u706b\u77e2"
			return "\u51b2\u950b"
		SkillType.BREAKTHROUGH:
			if role_id == "spear":
				return "\u7a81\u67aa\u6311\u9635"
			if role_id == "shield":
				return "\u9707\u76fe\u51fb"
			if is_crossbow:
				return "\u7834\u7532\u900f\u9635"
			if is_archer:
				return "\u7a7f\u4e91\u8d2f\u8679"
			return "\u8d2f\u7a81"
		SkillType.SWEEP:
			if role_id == "spear":
				return "\u98de\u67aa\u9aa4\u96e8"
			if role_id == "shield":
				return "\u7384\u7532\u9f9f\u9635"
			if is_crossbow:
				return "\u8fde\u5f29\u538b\u9635"
			if is_archer:
				return "\u6d41\u706b\u8fde\u77e2"
			return "\u56de\u65cb\u7a81\u51fb"
		_:
			return ""
func _build_damage_numbers() -> void:
	damage_number_root = Node3D.new()
	damage_number_root.name = "DamageNumbers"
	damage_number_root.top_level = true
	add_child(damage_number_root)
	var float_font: FontFile = _get_float_text_font()
	for i in range(10):
		var label := Label3D.new()
		label.name = "DamageNumber%d" % i
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.top_level = true
		label.no_depth_test = true
		label.pixel_size = maxf(0.006, damage_number_pixel_size)
		label.font_size = maxi(36, damage_number_font_size)
		label.outline_size = maxi(4, damage_number_outline_size)
		label.outline_modulate = Color(0.18, 0.02, 0.02, 0.92)
		if float_font != null:
			label.font = float_font
		label.modulate = Color(1.0, 0.26, 0.22, 0.0)
		label.visible = false
		label.text = ""
		damage_number_root.add_child(label)
		damage_number_labels.append(label)
		damage_number_timers.append(0.0)
		damage_number_origins.append(Vector3.ZERO)
		damage_number_scale_bases.append(0.0)
		damage_number_emphasis.append(false)

func _build_skill_name_popup() -> void:
	skill_name_root = Node3D.new()
	skill_name_root.name = "SkillNamePopup"
	skill_name_root.top_level = true
	add_child(skill_name_root)
	skill_name_label = Label3D.new()
	skill_name_label.name = "SkillNameLabel"
	skill_name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	skill_name_label.top_level = true
	skill_name_label.no_depth_test = true
	skill_name_label.pixel_size = maxf(0.005, skill_name_pixel_size)
	skill_name_label.font_size = maxi(28, skill_name_font_size)
	skill_name_label.outline_size = maxi(4, skill_name_outline_size)
	skill_name_label.outline_modulate = Color(0.12, 0.07, 0.02, 0.94)
	skill_name_label.modulate = Color(0.97, 0.82, 0.42, 0.0)
	skill_name_label.render_priority = 2
	skill_name_label.outline_render_priority = 1
	skill_name_label.visible = false
	skill_name_label.text = ""
	var float_font: FontFile = _get_float_text_font()
	if float_font != null:
		skill_name_label.font = float_font
	skill_name_root.add_child(skill_name_label)

func _dialogue_pool_to_string_array(value: Variant) -> Array[String]:
	var out: Array[String] = []
	if value is Array:
		for item in (value as Array):
			if item is Dictionary or item is Array:
				continue
			var text: String = str(item).strip_edges()
			if text.is_empty():
				continue
			out.append(text)
	elif value != null:
		if value is Dictionary or value is Array:
			return out
		var single: String = str(value).strip_edges()
		if not single.is_empty():
			out.append(single)
	return out

func _resolve_dialogue_pool_from_source(source: Dictionary, event_key: String) -> Array[String]:
	if source.is_empty():
		return []
	var event_norm: String = event_key.strip_edges().to_lower()
	if event_norm.is_empty():
		return []
	var out: Array[String] = []
	if source.has(event_norm):
		out.append_array(_dialogue_pool_to_string_array(source.get(event_norm, [])))
	if out.is_empty() and source.has("default"):
		out.append_array(_dialogue_pool_to_string_array(source.get("default", [])))
	return out

func _normalize_commander_name_for_dialogue(raw: String) -> String:
	var text: String = raw.strip_edges()
	text = text.replace(" ", "")
	text = text.replace("\t", "")
	text = text.replace("\n", "")
	text = text.replace("·", "")
	text = text.replace("　", "")
	var suffixes: Array[String] = ["将军", "都督", "军师", "元帅", "主帅", "先锋", "太守", "都尉", "校尉", "太尉"]
	for suffix in suffixes:
		if text.ends_with(suffix):
			text = text.substr(0, maxi(0, text.length() - suffix.length()))
	return text.strip_edges()

func _resolve_famous_commander_key() -> String:
	var name_norm: String = _normalize_commander_name_for_dialogue(get_commander_display_name())
	if name_norm.is_empty():
		return ""
	if COMMANDER_DIALOGUE_BY_FAMOUS.has(name_norm):
		return name_norm
	for alias_any in FAMOUS_COMMANDER_ALIASES.keys():
		var alias: String = String(alias_any).strip_edges()
		if alias.is_empty():
			continue
		if name_norm.find(alias) >= 0:
			return String(FAMOUS_COMMANDER_ALIASES.get(alias, "")).strip_edges()
	for famous_any in COMMANDER_DIALOGUE_BY_FAMOUS.keys():
		var famous_name: String = String(famous_any).strip_edges()
		if famous_name.is_empty():
			continue
		if name_norm.find(famous_name) >= 0:
			return famous_name
	return ""

func _dialogue_trait_candidates() -> Array[String]:
	var out: Array[String] = []
	for raw_any in [main_battle_personality_trait_id, vice_1_battle_personality_trait_id, vice_2_battle_personality_trait_id]:
		var trait_id: String = String(raw_any).strip_edges().to_lower()
		if trait_id.is_empty():
			continue
		if out.has(trait_id):
			continue
		out.append(trait_id)
	return out

func _resolve_gold_trait_dialogue_key() -> String:
	for trait_id in _dialogue_trait_candidates():
		if GOLD_PERSONALITY_TRAIT_IDS.has(trait_id):
			return trait_id
	return ""

func _resolve_personality_dialogue_archetype() -> String:
	for trait_id in _dialogue_trait_candidates():
		if COMMANDER_PERSONALITY_ARCHETYPE_BY_TRAIT_ID.has(trait_id):
			return String(COMMANDER_PERSONALITY_ARCHETYPE_BY_TRAIT_ID.get(trait_id, "")).strip_edges()
	var personality_text: String = main_battle_personality.strip_edges()
	if personality_text.find("谋") >= 0 or personality_text.find("计") >= 0 or personality_text.find("军师") >= 0:
		return "strategist"
	if personality_text.find("武") >= 0 or personality_text.find("猛") >= 0 or personality_text.find("霸王") >= 0 or personality_text.find("飞将") >= 0:
		return "fierce"
	if personality_text.find("守") >= 0 or personality_text.find("盾") >= 0 or personality_text.find("甲") >= 0:
		return "defender"
	if personality_text.find("粮") >= 0 or personality_text.find("仓") >= 0 or personality_text.find("补给") >= 0 or personality_text.find("筑") >= 0:
		return "supply"
	if personality_text.find("骑") >= 0 or personality_text.find("速") >= 0 or personality_text.find("突") >= 0:
		return "agile"
	if personality_text.find("水") >= 0 or personality_text.find("舟") >= 0 or personality_text.find("舰") >= 0:
		return "naval"
	return ""

func _format_dialogue_line(raw_text: String, context: Dictionary) -> String:
	var line: String = raw_text
	if context.is_empty():
		return line.strip_edges()
	for key_any in context.keys():
		var key: String = str(key_any).strip_edges()
		if key.is_empty():
			continue
		var token: String = "{%s}" % key
		if line.find(token) == -1:
			continue
		var value_any: Variant = context.get(key_any, "")
		if value_any is Dictionary or value_any is Array:
			continue
		var value_text: String = str(value_any)
		line = line.replace(token, value_text)
	return line.strip_edges()

func _pick_non_repeat_dialogue_line(event_key: String, pool: Array[String], context: Dictionary) -> String:
	if pool.is_empty():
		return ""
	var event_norm: String = event_key.strip_edges().to_lower()
	var last_raw: String = String(commander_dialogue_last_line_by_event.get(event_norm, ""))
	var candidates: Array[String] = []
	for line in pool:
		if pool.size() > 1 and line == last_raw:
			continue
		candidates.append(line)
	if candidates.is_empty():
		candidates = pool.duplicate()
	var pick_idx: int = randi() % maxi(1, candidates.size())
	var picked_raw: String = String(candidates[pick_idx]).strip_edges()
	commander_dialogue_last_line_by_event[event_norm] = picked_raw
	return _format_dialogue_line(picked_raw, context)

func pick_commander_dialogue_line(event_key: String, fallback_text: String = "", context: Dictionary = {}) -> String:
	var event_norm: String = event_key.strip_edges().to_lower()
	if event_norm.is_empty():
		return _format_dialogue_line(fallback_text, context)
	var famous_key: String = _resolve_famous_commander_key()
	var gold_trait_key: String = _resolve_gold_trait_dialogue_key()
	var role_key: String = combat_role_id.strip_edges().to_lower()
	var personality_arch: String = _resolve_personality_dialogue_archetype()
	var famous_pool: Array[String] = _resolve_dialogue_pool_from_source(COMMANDER_DIALOGUE_BY_FAMOUS.get(famous_key, {}) as Dictionary, event_norm)
	var gold_trait_pool: Array[String] = _resolve_dialogue_pool_from_source(COMMANDER_DIALOGUE_BY_GOLD_TRAIT.get(gold_trait_key, {}) as Dictionary, event_norm)
	var personality_pool: Array[String] = _resolve_dialogue_pool_from_source(COMMANDER_DIALOGUE_BY_PERSONALITY_ARCHETYPE.get(personality_arch, {}) as Dictionary, event_norm)
	var role_pool: Array[String] = _resolve_dialogue_pool_from_source(COMMANDER_DIALOGUE_BY_ROLE.get(role_key, {}) as Dictionary, event_norm)
	var generic_pool: Array[String] = _resolve_dialogue_pool_from_source(COMMANDER_DIALOGUE_GENERIC, event_norm)
	var pool: Array[String] = []
	if not famous_pool.is_empty():
		pool = famous_pool
	elif not gold_trait_pool.is_empty():
		if not role_pool.is_empty() and (randi() % 100) < 20:
			pool = role_pool
		else:
			pool = gold_trait_pool
	elif not personality_pool.is_empty():
		if not role_pool.is_empty() and (randi() % 100) < 30:
			pool = role_pool
		else:
			pool = personality_pool
	elif not role_pool.is_empty():
		pool = role_pool
	else:
		pool = generic_pool
	var chosen: String = _pick_non_repeat_dialogue_line(event_norm, pool, context)
	if chosen.is_empty():
		return _format_dialogue_line(fallback_text, context)
	return chosen

func _commander_dialogue_sync_state_snapshot() -> void:
	commander_dialogue_prev_state = int(state)
	commander_dialogue_prev_out_of_supply = has_status(StatusId.OUT_OF_SUPPLY)
	commander_dialogue_prev_burning = has_status(StatusId.BURNING)
	commander_dialogue_prev_morale_low = get_morale_ratio() <= 0.35
	commander_dialogue_prev_morale_collapse = has_status(StatusId.MORALE_COLLAPSE)

func _tick_commander_dialogue_state(delta: float) -> void:
	if dead or not commander_dialogue_enabled:
		return
	if commander_dialogue_global_cooldown > 0.0:
		commander_dialogue_global_cooldown = maxf(0.0, commander_dialogue_global_cooldown - maxf(0.0, delta))
	if not commander_dialogue_key_cooldowns.is_empty():
		var erase_keys: Array[String] = []
		for key_any in commander_dialogue_key_cooldowns.keys():
			var key: String = String(key_any)
			var left: float = maxf(0.0, float(commander_dialogue_key_cooldowns.get(key, 0.0)) - maxf(0.0, delta))
			if left <= 0.001:
				erase_keys.append(key)
			else:
				commander_dialogue_key_cooldowns[key] = left
		for key in erase_keys:
			commander_dialogue_key_cooldowns.erase(key)
	commander_dialogue_poll_timer = maxf(0.0, commander_dialogue_poll_timer - maxf(0.0, delta))
	if commander_dialogue_poll_timer > 0.0:
		return
	commander_dialogue_poll_timer = maxf(0.08, commander_dialogue_state_check_interval)

	var state_now: int = int(state)
	if commander_dialogue_prev_state != state_now:
		match state_now:
			int(UnitState.MELEE):
				_try_commander_line_by_key("state_melee", pick_commander_dialogue_line("state_melee", "全军压上！"), 5.5, 2.0, 1)
			int(UnitState.SKILL_FORM):
				_try_commander_line_by_key("state_skill_form", pick_commander_dialogue_line("state_skill_form", "谋定而后动！"), 6.0, 1.9, 1)
			int(UnitState.SKILL_EXEC):
				_try_commander_line_by_key("state_skill_exec", pick_commander_dialogue_line("state_skill_exec", "计成，发令！"), 6.0, 1.9, 1)
			int(UnitState.MOVE):
				if commander_dialogue_prev_state == int(UnitState.MELEE):
					_try_commander_line_by_key("state_move", pick_commander_dialogue_line("state_move", "稳住阵线，继续推进。"), 7.5, 1.9, 0)
		commander_dialogue_prev_state = state_now

	var out_of_supply_now: bool = has_status(StatusId.OUT_OF_SUPPLY)
	if out_of_supply_now != commander_dialogue_prev_out_of_supply:
		if out_of_supply_now:
			_try_commander_line_by_key("status_out_of_supply", pick_commander_dialogue_line("status_out_of_supply", "粮道已断，速接补给！"), 10.0, 2.4, 2)
		else:
			_try_commander_line_by_key("status_supply_recovered", pick_commander_dialogue_line("status_supply_recovered", "粮道恢复，全军再进！"), 8.0, 2.1, 1)
		commander_dialogue_prev_out_of_supply = out_of_supply_now

	var burning_now: bool = has_status(StatusId.BURNING)
	if burning_now and not commander_dialogue_prev_burning:
		_try_commander_line_by_key("status_burning", pick_commander_dialogue_line("status_burning", "部队起火，稳住阵脚！"), 9.0, 2.0, 1)
	commander_dialogue_prev_burning = burning_now

	var morale_low_now: bool = get_morale_ratio() <= 0.35
	if morale_low_now and not commander_dialogue_prev_morale_low:
		_try_commander_line_by_key("status_morale_low", pick_commander_dialogue_line("status_morale_low", "军心动摇，不可乱阵！"), 12.0, 2.2, 2)
	commander_dialogue_prev_morale_low = morale_low_now

	var morale_collapse_now: bool = has_status(StatusId.MORALE_COLLAPSE)
	if morale_collapse_now and not commander_dialogue_prev_morale_collapse:
		_try_commander_line_by_key("status_morale_collapse", pick_commander_dialogue_line("status_morale_collapse", "稳住！不可溃散！"), 12.0, 2.4, 3)
	commander_dialogue_prev_morale_collapse = morale_collapse_now

func _try_commander_line_by_key(key: String, text: String, cooldown_sec: float, duration_sec: float, priority: int = 0) -> void:
	var k: String = key.strip_edges()
	if k.is_empty():
		say_commander_line(text, duration_sec, priority)
		return
	if float(commander_dialogue_key_cooldowns.get(k, 0.0)) > 0.001:
		return
	commander_dialogue_key_cooldowns[k] = maxf(0.1, cooldown_sec)
	say_commander_line(text, duration_sec, priority)

func say_commander_line(text: String, duration_sec: float = -1.0, priority: int = 0) -> void:
	if dead or not commander_dialogue_enabled:
		return
	var line: String = text.strip_edges()
	if line.is_empty():
		return
	var show_duration: float = maxf(0.25, commander_dialogue_duration if duration_sec <= 0.0 else duration_sec)
	var current_priority: int = commander_dialogue_priority
	if commander_dialogue_global_cooldown > 0.001 and priority < current_priority:
		return
	commander_dialogue_timer = show_duration
	commander_dialogue_total = show_duration
	commander_dialogue_priority = priority
	commander_dialogue_global_cooldown = maxf(commander_dialogue_min_interval, show_duration * 0.45)
	commander_dialogue_text = line

func get_commander_dialogue_snapshot() -> Dictionary:
	var text: String = commander_dialogue_text.strip_edges()
	var remaining: float = maxf(0.0, commander_dialogue_timer)
	var total: float = maxf(0.001, commander_dialogue_total)
	var active: bool = commander_dialogue_enabled and not dead and remaining > 0.0 and not text.is_empty()
	return {
		"active": active,
		"text": text,
		"remaining": remaining,
		"duration": total,
		"progress": clampf(1.0 - remaining / total, 0.0, 1.0),
		"priority": commander_dialogue_priority
	}

func _show_skill_name_popup(skill_id: SkillType) -> void:
	if skill_name_label == null:
		return
	var skill_text: String = _get_skill_display_name(skill_id)
	if skill_text.is_empty():
		return
	var lod_tier: int = maxi(1, _get_effect_lod_tier())
	var scale_boost: float = _get_effect_scale_mul_for_tier(lod_tier)
	skill_name_timer = maxf(0.2, skill_name_duration)
	skill_name_scale_base = maxf(0.18, 0.1 * scale_boost * maxf(1.0, skill_name_scale_mul))
	skill_name_origin = global_position + Vector3(0.0, 7.4 + randf_range(0.0, 0.5), 0.0)
	skill_name_label.text = skill_text
	skill_name_label.visible = true
	skill_name_label.global_position = skill_name_origin
	skill_name_label.scale = Vector3.ONE * skill_name_scale_base
	skill_name_label.modulate = Color(0.98, 0.83, 0.46, 1.0)

func _show_damage_number(amount: float, emphasized: bool = false) -> void:
	if damage_number_root == null:
		return
	var lod_tier: int = maxi(1, _get_effect_lod_tier())
	var scale_boost: float = _get_effect_scale_mul_for_tier(lod_tier)
	var slot: int = -1
	for i in range(damage_number_timers.size()):
		if damage_number_timers[i] <= 0.0:
			slot = i
			break
	if slot < 0:
		slot = 0
	var label: Label3D = damage_number_labels[slot]
	if label == null:
		return
	damage_number_timers[slot] = maxf(0.18, damage_number_duration)
	var base_scale_mul: float = tactic_damage_number_scale_mul if emphasized else 1.0
	damage_number_scale_bases[slot] = maxf(0.22, 0.11 * scale_boost * base_scale_mul)
	damage_number_emphasis[slot] = emphasized
	damage_number_origins[slot] = global_position + Vector3(
		randf_range(-1.1, 1.1),
		(6.8 if emphasized else 6.2) + randf_range(0.0, 1.4),
		randf_range(-0.9, 0.9)
	)
	var amount_text: String = str(int(round(amount)))
	label.text = "-" + amount_text
	label.visible = true
	label.global_position = damage_number_origins[slot]
	label.outline_modulate = Color(0.22, 0.02, 0.02, 0.96) if emphasized else Color(0.18, 0.02, 0.02, 0.92)
	label.modulate = Color(1.0, 0.08, 0.08, 1.0) if emphasized else Color(1.0, 0.22, 0.18, 1.0)
	label.scale = Vector3.ONE * damage_number_scale_bases[slot]

func _update_damage_numbers(delta: float) -> void:
	if damage_number_root == null:
		return
	var lod_tier: int = _get_effect_lod_tier()
	for i in range(damage_number_timers.size()):
		var left: float = damage_number_timers[i]
		var label: Label3D = damage_number_labels[i]
		if label == null:
			continue
		if left <= 0.0:
			label.visible = false
			continue
		left = maxf(0.0, left - delta)
		damage_number_timers[i] = left
		if lod_tier <= 0:
			label.visible = false
			continue
		label.visible = true
		var total: float = maxf(0.001, damage_number_duration)
		var p: float = clampf(1.0 - left / total, 0.0, 1.0)
		var rise_scale: float = maxf(1.0, effect_world_scale_mul * 0.65)
		var rise: float = damage_number_rise_height * rise_scale * (0.18 + p)
		label.global_position = damage_number_origins[i] + Vector3(0.0, rise, 0.0)
		var base_scale: float = damage_number_scale_bases[i] if i < damage_number_scale_bases.size() else 0.08
		label.scale = Vector3.ONE * (base_scale + sin(p * PI) * base_scale * (0.5 if damage_number_emphasis[i] else 0.42))
		if damage_number_emphasis[i]:
			label.modulate = Color(1.0, 0.04, 0.04, 1.0 - p * 0.82)
		else:
			label.modulate = Color(1.0, 0.18, 0.14, 1.0 - p * 0.9)
		if left <= 0.0:
			label.visible = false

func _update_skill_name_popup(delta: float) -> void:
	if skill_name_label == null:
		return
	if skill_name_timer <= 0.0:
		skill_name_label.visible = false
		return
	skill_name_timer = maxf(0.0, skill_name_timer - delta)
	var total: float = maxf(0.001, skill_name_duration)
	var p: float = clampf(1.0 - skill_name_timer / total, 0.0, 1.0)
	var rise_scale: float = maxf(1.0, effect_world_scale_mul * 0.52)
	var rise: float = skill_name_rise_height * rise_scale * p
	skill_name_label.visible = true
	skill_name_label.global_position = skill_name_origin + Vector3(0.0, rise, 0.0)
	skill_name_label.scale = Vector3.ONE * (skill_name_scale_base + sin(p * PI) * skill_name_scale_base * 0.24)
	skill_name_label.modulate = Color(0.98, 0.83, 0.46, 1.0 - p * 0.92)
	if skill_name_timer <= 0.0:
		skill_name_label.visible = false

func _update_commander_dialogue_popup(delta: float) -> void:
	if commander_dialogue_timer <= 0.0:
		commander_dialogue_priority = 0
		commander_dialogue_text = ""
		return
	commander_dialogue_timer = maxf(0.0, commander_dialogue_timer - maxf(0.0, delta))
	if commander_dialogue_timer <= 0.0:
		commander_dialogue_priority = 0
		commander_dialogue_text = ""

func _build_pierce_preview() -> void:
	pierce_preview_node = MeshInstance3D.new()
	pierce_preview_node.name = "PiercePathPreview"
	pierce_preview_node.top_level = true
	pierce_preview_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pierce_preview_node.visible = false
	var imm := ImmediateMesh.new()
	pierce_preview_node.mesh = imm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(1.0, 0.88, 0.28, 0.5)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.82, 0.24, 1.0)
	mat.emission_energy_multiplier = 1.1
	pierce_preview_node.material_override = mat
	add_child(pierce_preview_node)

func _show_pierce_preview(start_world: Vector3, end_world: Vector3) -> void:
	if pierce_preview_node == null or not is_instance_valid(pierce_preview_node):
		return
	var imm: ImmediateMesh = pierce_preview_node.mesh as ImmediateMesh
	if imm == null:
		return
	imm.clear_surfaces()
	imm.surface_begin(Mesh.PRIMITIVE_LINES, null)
	imm.surface_set_color(Color(1.0, 0.9, 0.34, 0.62))
	imm.surface_add_vertex(start_world + Vector3(0.0, 0.22, 0.0))
	imm.surface_add_vertex(end_world + Vector3(0.0, 0.22, 0.0))
	imm.surface_end()
	pierce_preview_node.visible = true

func _hide_pierce_preview() -> void:
	if pierce_preview_node == null or not is_instance_valid(pierce_preview_node):
		return
	pierce_preview_node.visible = false

func _setup_archer_arrow_anchor_nodes() -> void:
	archer_arrow_origin_anchor = _resolve_archer_arrow_anchor_node(archer_arrow_origin_anchor_path, "ArcherArrowOriginAnchor")
	archer_arrow_target_anchor = _resolve_archer_arrow_anchor_node(archer_arrow_target_anchor_path, "ArcherArrowTargetAnchor")
	if archer_arrow_origin_anchor != null and archer_arrow_origin_anchor.position.is_equal_approx(Vector3.ZERO):
		archer_arrow_origin_anchor.position = Vector3(0.0, archer_arrow_height_offset, 0.0)
	if archer_arrow_target_anchor != null and archer_arrow_target_anchor.position.is_equal_approx(Vector3.ZERO):
		archer_arrow_target_anchor.position = Vector3(0.0, archer_arrow_height_offset, 0.0)
	_sync_archer_arrow_anchor_markers()

func _resolve_archer_arrow_anchor_node(path: NodePath, fallback_name: String) -> Node3D:
	var node: Node3D = null
	if not path.is_empty():
		node = get_node_or_null(path) as Node3D
	if node == null:
		node = get_node_or_null(fallback_name) as Node3D
	if node == null:
		node = Node3D.new()
		node.name = fallback_name
		add_child(node)
	return node

func _resolve_archer_origin_world(fallback_world: Vector3) -> Vector3:
	if not archer_arrow_use_anchor_nodes:
		return fallback_world
	if archer_arrow_origin_anchor == null or not is_instance_valid(archer_arrow_origin_anchor):
		_setup_archer_arrow_anchor_nodes()
	if archer_arrow_origin_anchor != null and is_instance_valid(archer_arrow_origin_anchor):
		return archer_arrow_origin_anchor.global_position
	return fallback_world

func _resolve_archer_target_world(enemy: UnitController, fallback_world: Vector3) -> Vector3:
	if enemy == null or not archer_arrow_use_anchor_nodes:
		return fallback_world
	if not enemy.archer_arrow_use_anchor_nodes:
		return fallback_world
	if enemy.archer_arrow_target_anchor == null or not is_instance_valid(enemy.archer_arrow_target_anchor):
		enemy._setup_archer_arrow_anchor_nodes()
	if enemy.archer_arrow_target_anchor != null and is_instance_valid(enemy.archer_arrow_target_anchor):
		return enemy.archer_arrow_target_anchor.global_position
	return fallback_world

func _sync_archer_arrow_anchor_markers() -> void:
	if not archer_arrow_anchor_marker_visible:
		if archer_arrow_anchor_marker_root != null and is_instance_valid(archer_arrow_anchor_marker_root):
			archer_arrow_anchor_marker_root.visible = false
		return
	if archer_arrow_anchor_marker_root == null or not is_instance_valid(archer_arrow_anchor_marker_root):
		archer_arrow_anchor_marker_root = Node3D.new()
		archer_arrow_anchor_marker_root.name = "ArcherArrowAnchorMarkers"
		add_child(archer_arrow_anchor_marker_root)
	if archer_arrow_origin_marker == null or not is_instance_valid(archer_arrow_origin_marker):
		archer_arrow_origin_marker = _create_archer_arrow_anchor_marker(Color(0.24, 1.0, 0.4, 0.9))
		archer_arrow_origin_marker.name = "OriginMarker"
		archer_arrow_anchor_marker_root.add_child(archer_arrow_origin_marker)
	if archer_arrow_target_marker == null or not is_instance_valid(archer_arrow_target_marker):
		archer_arrow_target_marker = _create_archer_arrow_anchor_marker(Color(1.0, 0.35, 0.24, 0.9))
		archer_arrow_target_marker.name = "TargetMarker"
		archer_arrow_anchor_marker_root.add_child(archer_arrow_target_marker)
	archer_arrow_anchor_marker_root.visible = true
	_update_archer_arrow_anchor_markers()

func _create_archer_arrow_anchor_marker(color: Color) -> MeshInstance3D:
	var marker := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.2
	mesh.height = 0.4
	marker.mesh = mesh
	marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	marker.top_level = true
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.no_depth_test = true
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = Color(color.r, color.g, color.b, 1.0)
	mat.emission_energy_multiplier = 1.4
	marker.material_override = mat
	return marker

func _update_archer_arrow_anchor_markers() -> void:
	if not archer_arrow_anchor_marker_visible:
		if archer_arrow_anchor_marker_root != null and is_instance_valid(archer_arrow_anchor_marker_root):
			archer_arrow_anchor_marker_root.visible = false
		return
	if archer_arrow_anchor_marker_root == null or not is_instance_valid(archer_arrow_anchor_marker_root):
		_sync_archer_arrow_anchor_markers()
		return
	archer_arrow_anchor_marker_root.visible = true
	var marker_scale: float = clampf(archer_arrow_anchor_marker_radius / 0.2, 0.25, 5.0)
	if archer_arrow_origin_marker != null and is_instance_valid(archer_arrow_origin_marker):
		archer_arrow_origin_marker.scale = Vector3.ONE * marker_scale
		if archer_arrow_origin_anchor != null and is_instance_valid(archer_arrow_origin_anchor):
			archer_arrow_origin_marker.global_position = archer_arrow_origin_anchor.global_position
	if archer_arrow_target_marker != null and is_instance_valid(archer_arrow_target_marker):
		archer_arrow_target_marker.scale = Vector3.ONE * marker_scale
		if archer_arrow_target_anchor != null and is_instance_valid(archer_arrow_target_anchor):
			archer_arrow_target_marker.global_position = archer_arrow_target_anchor.global_position

func _build_archer_arrow_trace() -> void:
	if projectile_trace_vfx != null and is_instance_valid(projectile_trace_vfx):
		_sync_projectile_trace_vfx_style()
		return
	var instance: Node = PROJECTILE_TRACE_VFX_SCENE.instantiate()
	if not (instance is Node3D):
		return
	projectile_trace_vfx = instance as Node3D
	projectile_trace_vfx.name = "ProjectileTraceVfx"
	add_child(projectile_trace_vfx)
	_sync_projectile_trace_vfx_style()

func _has_projectile_trace_vfx() -> bool:
	if projectile_trace_vfx == null or not is_instance_valid(projectile_trace_vfx):
		_build_archer_arrow_trace()
	return projectile_trace_vfx != null and is_instance_valid(projectile_trace_vfx)

func _sync_projectile_trace_vfx_style() -> void:
	if projectile_trace_vfx == null or not is_instance_valid(projectile_trace_vfx):
		return
	var duration_sec: float = archer_arrow_line_duration
	var length_ratio: float = archer_arrow_trail_length_ratio
	var head_alpha: float = archer_arrow_trail_head_alpha
	var tail_alpha: float = archer_arrow_trail_tail_alpha
	var albedo: Color = Color(1.0, 0.98, 0.9, 0.98)
	var emission: Color = Color(1.0, 0.98, 0.9, 1.0)
	var emission_mul: float = 1.7
	if _is_strategist_role():
		duration_sec = maxf(0.06, strategist_trace_duration)
		length_ratio = clampf(strategist_trace_length_ratio, 0.08, 0.95)
		head_alpha = clampf(strategist_trace_head_alpha, 0.0, 1.0)
		tail_alpha = clampf(strategist_trace_tail_alpha, 0.0, 1.0)
		albedo = Color(0.72, 0.95, 1.0, 0.98)
		emission = Color(0.46, 0.94, 1.0, 1.0)
		emission_mul = 2.25
	if projectile_trace_vfx.has_method("configure_visual"):
		projectile_trace_vfx.call(
			"configure_visual",
			duration_sec,
			length_ratio,
			head_alpha,
			tail_alpha
		)
	if projectile_trace_vfx.has_method("configure_color"):
		projectile_trace_vfx.call("configure_color", albedo, emission, emission_mul)

func _play_projectile_trace(trails: Array[Dictionary], duration_sec: float) -> void:
	if not _has_projectile_trace_vfx():
		return
	_sync_projectile_trace_vfx_style()
	if projectile_trace_vfx.has_method("play_trails"):
		projectile_trace_vfx.call("play_trails", trails, maxf(0.04, duration_sec))

func _set_archer_skill_fire_lock(wave_delays: Array) -> void:
	var delays: Array = wave_delays if not wave_delays.is_empty() else [0.0]
	var max_delay: float = 0.0
	for delay_any in delays:
		max_delay = maxf(max_delay, maxf(0.0, float(delay_any)))
	var sustain: float = maxf(0.08, archer_arrow_line_duration * (1.0 + maxf(0.0, float(delays.size() - 1)) * 0.34))
	var lock_time: float = maxf(0.12, max_delay + sustain + 0.04)
	archer_skill_fire_lock_timer = maxf(archer_skill_fire_lock_timer, lock_time)
	attack_timer = maxf(attack_timer, archer_skill_fire_lock_timer)

func _emit_archer_arrow_trace(enemy: UnitController) -> void:
	if enemy == null or enemy.dead:
		return
	if not _has_projectile_trace_vfx():
		return
	var ctx: Dictionary = _get_archer_frontline_context(enemy)
	var own_front: float = float(ctx.get("own_front", 0.0))
	var enemy_front: float = float(ctx.get("enemy_front", 0.0))
	var dir2d: Vector3 = enemy.global_position - global_position
	dir2d.y = 0.0
	if dir2d.length_squared() <= EPS:
		dir2d = desired_facing if desired_facing.length_squared() > EPS else Vector3.FORWARD
	var dir: Vector3 = dir2d.normalized()
	var launch_forward: Vector3 = get_collision_forward_flat()
	if launch_forward.length_squared() <= EPS:
		launch_forward = dir
	launch_forward = launch_forward.normalized()
	var start: Vector3 = global_position + launch_forward * own_front + Vector3(0.0, archer_arrow_height_offset, 0.0)
	var end: Vector3 = enemy.global_position - dir * enemy_front + Vector3(0.0, archer_arrow_height_offset, 0.0)
	if start.distance_to(end) < 0.65:
		end = enemy.global_position + Vector3(0.0, archer_arrow_height_offset, 0.0)
	var side: Vector3 = Vector3(-dir.z, 0.0, dir.x)
	if side.length_squared() <= EPS:
		side = Vector3.RIGHT
	side = side.normalized()
	var is_strategist: bool = _is_strategist_role()
	var forward: Vector3 = dir
	var view_side: Vector3 = side
	if not is_strategist:
		var cam: Camera3D = get_viewport().get_camera_3d()
		if cam != null:
			var to_cam: Vector3 = cam.global_position - ((start + end) * 0.5)
			if to_cam.length_squared() > EPS:
				view_side = dir.cross(to_cam.normalized())
				if view_side.length_squared() > EPS:
					view_side = view_side.normalized()
				else:
					view_side = side
	var burst_base: int = strategist_trace_burst_base if is_strategist else archer_arrow_burst_base
	var burst_scale: float = strategist_trace_burst_scale_per_1000 if is_strategist else archer_arrow_burst_scale_per_1000
	var burst_max: int = strategist_trace_burst_max if is_strategist else archer_arrow_burst_max
	var burst_count: int = int(round(float(burst_base) + maxf(0.0, burst_scale) * float(maxi(0, troop_count)) / 1000.0))
	burst_count = clampi(burst_count, 1, maxi(1, burst_max))
	if is_strategist:
		burst_count = 1
	var origin_r: float = maxf(archer_arrow_origin_spread_radius, _get_non_melee_formation_radius() * 0.52)
	var target_r: float = maxf(archer_arrow_target_spread_radius, enemy.get_activity_radius() * 0.9)
	var h_jitter: float = maxf(0.0, archer_arrow_height_jitter)
	if is_strategist:
		origin_r = 0.0
		target_r = 0.0
		h_jitter = 0.0
	var blade_face_dir: Vector3 = _get_strategist_blade_face_dir(dir, enemy) if is_strategist else dir
	archer_arrow_trails.clear()
	archer_arrow_trails.resize(burst_count)
	var start_side_sum: float = 0.0
	var end_side_sum: float = 0.0
	for i in range(burst_count):
		var o: Vector2 = _random_disk_point(origin_r)
		var t: Vector2 = _random_disk_point(target_r)
		var start_i: Vector3 = start + side * o.x + forward * (o.y * 0.9)
		var end_i: Vector3 = end + side * t.x + forward * (t.y * 0.75)
		if h_jitter > 0.0:
			end_i.y += (randf() * 2.0 - 1.0) * h_jitter
		if start_i.distance_to(end_i) < 0.65:
			end_i = end_i + dir * 0.65
		var width: float = 0.0
		if is_strategist:
			width = maxf(0.32, archer_arrow_lane_half_width * maxf(2.8, strategist_trace_width_mul))
		else:
			width = maxf(0.02, archer_arrow_lane_half_width * (0.34 + randf() * 0.28))
		var travel_dist: float = start_i.distance_to(end_i)
		var arc_height: float = 0.0
		if is_strategist:
			arc_height = maxf(0.4, archer_arrow_arc_height * maxf(0.2, strategist_trace_arc_mul) * maxf(1.3, travel_dist * 0.11))
		else:
			arc_height = maxf(0.45, archer_arrow_arc_height * maxf(2.0, travel_dist * 0.16) * (0.9 + randf() * 0.35))
		start_side_sum += (start_i - start).dot(side)
		end_side_sum += (end_i - end).dot(side)
		var trail_data: Dictionary = {
			"start": start_i,
			"end": end_i,
			"side": view_side * width,
			"arc_height": arc_height,
			"tail_color": Color(0.52, 0.92, 1.0, 1.0) if is_strategist else Color(1.0, 0.98, 0.9, 1.0),
			"head_color": Color(0.26, 0.78, 1.0, 1.0) if is_strategist else Color(1.0, 0.98, 0.9, 1.0),
			"line_mode": false
		}
		if is_strategist:
			trail_data["blade_mode"] = true
			trail_data["blade_curve"] = 0.98
			trail_data["blade_segments"] = 11
			trail_data["blade_body_mul"] = 3.2
			trail_data["blade_tip_mul"] = 2.85
			trail_data["blade_face_to_target"] = true
			trail_data["blade_face_dir"] = blade_face_dir
			trail_data["blade_curve_sign"] = 1.0 if strategist_blade_curve_sign >= 0.0 else -1.0
			trail_data["blade_tail_white_ratio"] = clampf(strategist_blade_tail_white_ratio, 0.0, 0.9)
		archer_arrow_trails[i] = trail_data
	if burst_count > 1:
		var inv_count: float = 1.0 / float(burst_count)
		var start_side_bias: float = start_side_sum * inv_count
		var end_side_bias: float = end_side_sum * inv_count
		for i in range(burst_count):
			var trail: Dictionary = archer_arrow_trails[i]
			var s: Vector3 = trail.get("start", start)
			var e: Vector3 = trail.get("end", end)
			s -= side * start_side_bias
			e -= side * end_side_bias
			trail["start"] = s
			trail["end"] = e
			archer_arrow_trails[i] = trail
	_play_projectile_trace(archer_arrow_trails, maxf(0.04, strategist_trace_duration if is_strategist else archer_arrow_line_duration))

func _emit_archer_skill_trace(enemy: UnitController, burst_count: int, wave_delays: Array, origin_spread_mul: float = 1.0, target_spread_mul: float = 1.0, arc_mul: float = 1.0, width_mul: float = 1.0, target_forward_jitter_mul: float = 0.75, origin_forward_jitter_mul: float = 0.9, tail_color: Color = Color(1.0, 0.98, 0.9, 1.0), head_color: Color = Color(1.0, 0.98, 0.9, 1.0), line_mode: bool = false) -> void:
	if enemy == null or enemy.dead:
		return
	if not _has_projectile_trace_vfx():
		return
	var ctx: Dictionary = _get_archer_frontline_context(enemy)
	var own_front: float = float(ctx.get("own_front", 0.0))
	var enemy_front: float = float(ctx.get("enemy_front", 0.0))
	var dir2d: Vector3 = enemy.global_position - global_position
	dir2d.y = 0.0
	if dir2d.length_squared() <= EPS:
		dir2d = desired_facing if desired_facing.length_squared() > EPS else Vector3.FORWARD
	var dir: Vector3 = dir2d.normalized()
	var launch_forward: Vector3 = get_collision_forward_flat()
	if launch_forward.length_squared() <= EPS:
		launch_forward = dir
	launch_forward = launch_forward.normalized()
	var start: Vector3 = global_position + launch_forward * own_front + Vector3(0.0, archer_arrow_height_offset, 0.0)
	var end: Vector3 = enemy.global_position - dir * enemy_front + Vector3(0.0, archer_arrow_height_offset, 0.0)
	if start.distance_to(end) < 0.65:
		end = enemy.global_position + Vector3(0.0, archer_arrow_height_offset, 0.0)
	var side: Vector3 = Vector3(-dir.z, 0.0, dir.x)
	if side.length_squared() <= EPS:
		side = Vector3.RIGHT
	side = side.normalized()
	var forward: Vector3 = dir
	var cam: Camera3D = get_viewport().get_camera_3d()
	var view_side: Vector3 = side
	if cam != null:
		var to_cam: Vector3 = cam.global_position - ((start + end) * 0.5)
		if to_cam.length_squared() > EPS:
			view_side = dir.cross(to_cam.normalized())
			if view_side.length_squared() > EPS:
				view_side = view_side.normalized()
			else:
				view_side = side
	var safe_burst_count: int = clampi(burst_count, 1, 64)
	var origin_r: float = maxf(archer_arrow_origin_spread_radius * maxf(0.1, origin_spread_mul), _get_non_melee_formation_radius() * 0.52 * maxf(0.1, origin_spread_mul))
	var target_r: float = maxf(archer_arrow_target_spread_radius * maxf(0.1, target_spread_mul), enemy.get_activity_radius() * 0.9 * maxf(0.1, target_spread_mul))
	var h_jitter: float = maxf(0.0, archer_arrow_height_jitter)
	var delays: Array = wave_delays if not wave_delays.is_empty() else [0.0]
	var max_delay: float = 0.0
	for delay_any in delays:
		max_delay = maxf(max_delay, maxf(0.0, float(delay_any)))
	archer_arrow_trails.clear()
	var start_side_sum: float = 0.0
	var end_side_sum: float = 0.0
	var trail_count: int = 0
	for wave_delay_any in delays:
		var wave_delay: float = maxf(0.0, float(wave_delay_any))
		for idx in range(safe_burst_count):
			var o: Vector2 = _random_disk_point(origin_r)
			var t: Vector2 = _random_disk_point(target_r)
			var start_i: Vector3 = start + side * o.x + forward * (o.y * maxf(0.2, origin_forward_jitter_mul))
			var end_i: Vector3 = end + side * t.x + forward * (t.y * maxf(0.1, target_forward_jitter_mul))
			if h_jitter > 0.0:
				end_i.y += (randf() * 2.0 - 1.0) * h_jitter
			if start_i.distance_to(end_i) < 0.65:
				end_i = end_i + dir * 0.65
			var width: float = maxf(0.02, archer_arrow_lane_half_width * maxf(0.2, width_mul) * (0.34 + randf() * 0.28))
			var travel_dist: float = start_i.distance_to(end_i)
			var arc_height: float = maxf(1.4, archer_arrow_arc_height * maxf(0.2, arc_mul) * maxf(2.0, travel_dist * 0.16) * (0.9 + randf() * 0.35))
			start_side_sum += (start_i - start).dot(side)
			end_side_sum += (end_i - end).dot(side)
			trail_count += 1
			archer_arrow_trails.append({
				"start": start_i,
				"end": end_i,
				"side": view_side * width,
				"arc_height": arc_height,
				"delay": wave_delay + randf_range(0.0, 0.04),
				"tail_color": tail_color,
				"head_color": head_color,
				"line_mode": line_mode
			})
	if trail_count > 1:
		var inv_count: float = 1.0 / float(trail_count)
		var start_side_bias: float = start_side_sum * inv_count
		var end_side_bias: float = end_side_sum * inv_count
		for i in range(trail_count):
			var trail: Dictionary = archer_arrow_trails[i]
			var s: Vector3 = trail.get("start", start)
			var e: Vector3 = trail.get("end", end)
			s -= side * start_side_bias
			e -= side * end_side_bias
			trail["start"] = s
			trail["end"] = e
			archer_arrow_trails[i] = trail
	var delay_span: float = clampf(max_delay, 0.0, 0.92)
	var duration_mul: float = 1.0 + delay_span * 1.25 + maxf(0.0, float(delays.size() - 1)) * 0.18
	_play_projectile_trace(archer_arrow_trails, maxf(0.12, archer_arrow_line_duration * duration_mul))

func _random_disk_point(radius: float) -> Vector2:
	var r: float = maxf(0.0, radius)
	if r <= 0.0:
		return Vector2.ZERO
	var ang: float = randf() * TAU
	var len: float = sqrt(randf()) * r
	return Vector2(cos(ang) * len, sin(ang) * len)

func _play_skill_vfx(new_skill: SkillType, executing: bool) -> void:
	skill_vfx_skill = int(new_skill)
	skill_vfx_executing = executing
	skill_vfx_timer = 0.0
	skill_vfx_duration = 0.0
	if skill_vfx_instance != null and is_instance_valid(skill_vfx_instance) and skill_vfx_instance.has_method("stop"):
		skill_vfx_instance.call("stop")
func _update_skill_vfx(delta: float) -> void:
	return
func _mark_tactic_crit_vfx() -> void:
	return
func _apply_skill_vfx_material(_color: Color) -> void:
	pass

func _update_gpu_anim_state() -> void:
	if soldier_anim_material == null:
		return
	var is_archer: bool = _is_archer_role()
	var shader_state: float = float(state)
	if is_archer:
		if archer_use_idle_gpu_anim_in_combat and state == UnitState.MELEE:
			# Archer combat uses stand-and-fire logic; avoid hit-bob flicker.
			shader_state = 0.0
		elif archer_use_idle_gpu_anim_while_moving and state == UnitState.MOVE:
			# Archer movement uses glide-only visuals to avoid high-frequency jitter.
			shader_state = 0.0
	var sway_mul: float = cavalry_sway_mul if unit_type == UnitType.CAVALRY else infantry_sway_mul
	if is_archer:
		if state == UnitState.MELEE:
			sway_mul = minf(sway_mul, maxf(0.0, archer_gpu_sway_mul_attack))
		elif state == UnitState.MOVE:
			sway_mul = 0.0
		else:
			sway_mul = minf(sway_mul, maxf(0.0, archer_gpu_sway_mul))
	soldier_anim_material.set_shader_parameter("u_state", shader_state)
	soldier_anim_material.set_shader_parameter("u_sway_mul", sway_mul)
	var move_cycle_mul: float = 1.0
	if is_archer and state == UnitState.MOVE:
		move_cycle_mul = 0.2
	soldier_anim_material.set_shader_parameter("u_move_cycle_mul", move_cycle_mul)
	var idle_cycle_mul: float = 1.0
	if is_archer and state != UnitState.MOVE:
		idle_cycle_mul = clampf(archer_idle_cycle_mul, 0.2, 1.5)
	soldier_anim_material.set_shader_parameter("u_idle_cycle_mul", idle_cycle_mul)
	var anim_intensity: float = 1.0
	if is_archer:
		anim_intensity = 0.0
	soldier_anim_material.set_shader_parameter("u_anim_intensity", anim_intensity)
	_update_gpu_anim_attack_dir()

func _update_gpu_anim_attack_dir() -> void:
	if soldier_anim_material == null:
		return
	var dir := soldier_mesh_basis.inverse() * attack_dir_local
	dir.y = 0.0
	if dir.length_squared() <= EPS:
		dir = Vector3.FORWARD
	soldier_anim_material.set_shader_parameter("u_attack_dir_local", dir.normalized())

func _update_soldier_offsets(_delta: float) -> void:
	# Deprecated: per-soldier per-frame update is intentionally disabled.
	pass

func _refresh_visuals(_delta: float) -> void:
	# Deprecated: animation is driven by GPU shader uniforms.
	pass

func _get_soldier_facing(i: int) -> Vector3:
	if frame_motion_dir.length_squared() > EPS:
		return frame_motion_dir
	if move_velocity.length_squared() > EPS:
		return move_velocity.normalized()
	if state == UnitState.MELEE and target_unit != null and not target_unit.dead:
		var to_enemy := target_unit.global_position - (global_position + global_basis * current_offsets[i])
		to_enemy.y = 0.0
		if to_enemy.length_squared() > EPS:
			return to_enemy.normalized()
	if desired_facing.length_squared() > EPS:
		return desired_facing.normalized()
	return Vector3.FORWARD

func _cached_enemy_local_dir() -> Vector3:
	if target_unit == null or target_unit.dead:
		return Vector3.FORWARD
	var local := global_basis.inverse() * (target_unit.global_position - global_position)
	local.y = 0.0
	if local.length_squared() <= EPS:
		return Vector3.FORWARD
	return local.normalized()

func _refresh_melee_offsets() -> void:
	if target_unit == null or target_unit.dead:
		return
	var to_enemy_world := target_unit.global_position - global_position
	to_enemy_world.y = 0.0
	if to_enemy_world.length_squared() <= EPS:
		return
	var front_local := global_basis.inverse() * to_enemy_world.normalized()
	front_local.y = 0.0
	if front_local.length_squared() <= EPS:
		front_local = Vector3.FORWARD
	front_local = front_local.normalized()
	var side_local := Vector3(front_local.z, 0.0, -front_local.x)
	if side_local.length_squared() <= EPS:
		side_local = Vector3.RIGHT
	side_local = side_local.normalized()

	# Melee layout follows troop-banded line template and keeps center anchored at unit center.
	var square_dim: int = _get_square_dim_for_troops(troop_count)
	var target_rows: int = mini(4, _get_line_rows_for_square_dim(square_dim))
	var base_cols: int = maxi(1, int(ceil(float(soldier_count) / float(maxi(1, target_rows)))))
	var width_mul: float = clampf(melee_frontline_width_mul, 0.5, 3.0)
	var depth_mul: float = clampf(melee_frontline_depth_mul, 0.4, 2.5)
	var line_cols: int = clampi(base_cols, 2, max(2, soldier_count))
	var row_count: int = maxi(1, int(ceil(float(soldier_count) / float(line_cols))))
	var type_row_spacing: float = cavalry_melee_row_spacing if unit_type == UnitType.CAVALRY else infantry_melee_row_spacing
	var type_lateral_spacing: float = cavalry_melee_lateral_spacing if unit_type == UnitType.CAVALRY else infantry_melee_lateral_spacing
	var row_depth: float = maxf(type_row_spacing * depth_mul, 0.45)
	var lateral_spacing: float = maxf(type_lateral_spacing * width_mul, 0.78)
	var half_cols: float = float(line_cols - 1) * 0.5
	var half_cols_safe: float = maxf(half_cols, 0.001)
	var sway_mul: float = cavalry_sway_mul if unit_type == UnitType.CAVALRY else infantry_sway_mul
	var boundary_gap: float = maxf(0.0, melee_boundary_gap)

	for i in soldier_count:
		var seed := seeds[i]
		var row: int = i / line_cols
		var col: int = i % line_cols
		var col_offset: float = float(col) - half_cols
		var edge_factor: float = absf(col_offset) / half_cols_safe
		var edge_sign: float = 1.0 if col_offset > 0.0 else (-1.0 if col_offset < 0.0 else 0.0)

		var depth := (float(row_count - 1) * 0.5 - float(row)) * row_depth
		var lateral := col_offset * lateral_spacing
		if row % 2 == 1:
			depth -= row_depth * 0.03
		lateral += edge_sign * edge_factor * melee_side_spread
		depth += sin(seed * 5.6 + visual_time * 1.2) * 0.03
		lateral += cos(seed * 4.2 + visual_time * 0.8) * 0.04 * sway_mul

		var offset := front_local * depth + side_local * lateral
		offset = _clamp_local_offset_to_melee_boundary(offset, target_unit, boundary_gap)
		offset = _clamp_local_radius(offset)
		desired_offsets[i] = offset
	attack_dir_local = front_local
	_update_gpu_anim_attack_dir()
	_apply_offsets_immediate(desired_offsets, false)

func _clamp_local_offset_to_melee_boundary(local_offset: Vector3, enemy: UnitController, gap: float) -> Vector3:
	if enemy == null or enemy.dead:
		return local_offset
	var to_enemy: Vector3 = enemy.global_position - global_position
	to_enemy.y = 0.0
	if to_enemy.length_squared() <= EPS:
		return local_offset
	var dir: Vector3 = to_enemy.normalized()
	var mid: Vector3 = (global_position + enemy.global_position) * 0.5
	var world: Vector3 = global_position + global_basis * local_offset
	var proj: float = (world - mid).dot(dir)
	var allowed_max: float = -maxf(0.0, gap)
	if proj > allowed_max:
		world -= dir * (proj - allowed_max)
	var local_fixed: Vector3 = global_basis.inverse() * (world - global_position)
	local_fixed.y = 0.0
	return local_fixed

func _avoid_enemy_activity_overlap(local_offset: Vector3, _enemies: Array) -> Vector3:
	return local_offset

func _avoid_enemy_activity_overlap_DISABLED_OLD(local_offset: Vector3, enemies: Array) -> Vector3:
	if enemies.is_empty():
		return local_offset

	var world := global_position + global_basis * local_offset
	for enemy_any in enemies:
		if not (enemy_any is UnitController):
			continue
		var enemy: UnitController = enemy_any
		if enemy.dead:
			continue
		var delta := world - enemy.global_position
		delta.y = 0.0
		var radius := enemy.get_activity_radius()
		var dist := delta.length()
		if dist < radius:
			var push_dir := delta.normalized() if dist > EPS else (world - global_position).normalized()
			if push_dir.length_squared() <= EPS:
				push_dir = Vector3.RIGHT
			world = enemy.global_position + push_dir * (radius + 0.05)

	var local_fixed := global_basis.inverse() * (world - global_position)
	local_fixed.y = 0.0
	return _clamp_local_radius(local_fixed)

func _clamp_local_radius(local_offset: Vector3) -> Vector3:
	var flat := Vector3(local_offset.x, 0.0, local_offset.z)
	if not flat.is_finite():
		return Vector3.ZERO
	# Do not shrink melee offsets; otherwise the widened front line collapses into narrow columns again.
	if state == UnitState.MELEE:
		return flat
	var radius := get_activity_radius()
	radius = maxf(radius, _get_non_melee_formation_radius())
	if not _is_finite_float(radius) or radius <= EPS:
		return Vector3.ZERO
	var d := flat.length()
	if not _is_finite_float(d):
		return Vector3.ZERO
	if d <= radius:
		return flat
	return flat / d * radius

func _reset_post_combat_visual_motion() -> void:
	clear_temporary_detour()
	_stop_staged_transition()
	transition_restore_home_lock = false
	nav_mode = NavMode.NONE
	has_move_target = false
	move_target = global_position
	attack_move_active = false
	attack_move_goal = Vector3.ZERO
	pending_displacement = Vector3.ZERO
	move_velocity = Vector3.ZERO
	blocked_move_timer = 0.0
	blocked_repath_cd = 0.0
	path_points.clear()
	path_index = 0
	charge_split_reaction_timer = 0.0
	charge_split_reaction_total = 0.0
	impact_launch_timer = 0.0
	impact_launch_total = 0.0
	impact_launch_height_current = 0.0
	impact_launch_landing_triggered = false
	_apply_impact_launch_transform(0.0, 0.0)
	_apply_offsets_immediate(home_offsets, false)

func _die() -> void:
	dead = true
	downhill_speed_bonus_current = 0.0
	command_mode = CommandMode.NONE
	pierce_active = false
	pierce_ignore_target_id = 0
	_reset_post_combat_visual_motion()
	_hide_pierce_preview()
	timed_statuses.clear()
	clear_burn()
	if soldiers_mm != null:
		soldiers_mm.visible_instance_count = 0
	if commander_mount_root != null and is_instance_valid(commander_mount_root):
		commander_mount_root.visible = false
	commander_dialogue_text = ""
	commander_dialogue_timer = 0.0
	commander_dialogue_total = 0.0
	if battlefield != null and battlefield.has_method("unregister_unit"):
		battlefield.call("unregister_unit", self)
	queue_free()

func _mark_repulsion_dirty() -> void:
	pass

func _build_multimesh_visual() -> void:
	soldiers_mmi = MultiMeshInstance3D.new()
	soldiers_mmi.name = "Soldiers"
	soldiers_mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if soldier_cast_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(soldiers_mmi)

	var mesh: Mesh
	var source_albedo_tex: Texture2D = null
	var using_proxy_mesh: bool = false
	soldier_mesh_basis = Basis.IDENTITY
	if _should_use_proxy_soldier_mesh():
		mesh = _build_proxy_soldier_mesh()
		using_proxy_mesh = mesh != null
	if mesh == null and use_model_mesh:
		var cache_key := _get_model_cache_key()
		if _cached_model_mesh_by_type.has(cache_key):
			mesh = _cached_model_mesh_by_type.get(cache_key) as Mesh
			source_albedo_tex = _cached_model_albedo_by_type.get(cache_key) as Texture2D
			soldier_mesh_basis = _cached_model_basis_by_type.get(cache_key, Basis.IDENTITY)
		else:
			var model_paths: Array[String] = _get_model_scene_candidate_paths()
			for model_path in model_paths:
				mesh = _load_mesh_from_model_scene(model_path)
				if mesh == null:
					continue
				source_albedo_tex = _extract_mesh_albedo_texture(mesh)
				break
			_cached_model_mesh_by_type[cache_key] = mesh
			_cached_model_albedo_by_type[cache_key] = source_albedo_tex
			_cached_model_basis_by_type[cache_key] = soldier_mesh_basis
		if source_albedo_tex == null:
			source_albedo_tex = _load_default_albedo_texture_for_unit()

	if mesh == null:
		if unit_type == UnitType.CAVALRY:
			var box := BoxMesh.new()
			box.size = Vector3(0.42, 1.4, 0.9)
			mesh = box
		else:
			var capsule := CapsuleMesh.new()
			capsule.radius = 0.2
			capsule.height = 0.9
			mesh = capsule

		var material := StandardMaterial3D.new()
		material.albedo_color = _get_visual_tint_color()
		material.roughness = 0.85
		material.metallic = 0.02
		mesh.surface_set_material(0, material)
		soldier_visual_scale = 1.05 if unit_type == UnitType.CAVALRY else 0.95
		soldier_yaw_offset = 0.0
		soldier_mesh_basis = Basis.IDENTITY
	else:
		var target_height := 1.55 if unit_type == UnitType.CAVALRY else 1.35
		soldier_visual_scale = _compute_height_scale(mesh, target_height)
		if using_proxy_mesh:
			soldier_visual_scale *= maxf(0.2, proxy_soldier_scale_mul)
		else:
			soldier_visual_scale *= cavalry_model_scale_mul if unit_type == UnitType.CAVALRY else infantry_model_scale_mul
		soldier_yaw_offset = 0.0
		var yaw_rad := deg_to_rad(model_forward_yaw_degrees)
		if absf(yaw_rad) > EPS:
			soldier_mesh_basis = Basis(Vector3.UP, yaw_rad) * soldier_mesh_basis

	var anim_material := ShaderMaterial.new()
	anim_material.shader = SOLDIER_GPU_SHADER
	anim_material.set_shader_parameter("u_team_color", _get_visual_tint_color())
	anim_material.set_shader_parameter("u_state", float(state))
	anim_material.set_shader_parameter("u_sway_mul", cavalry_sway_mul if unit_type == UnitType.CAVALRY else infantry_sway_mul)
	anim_material.set_shader_parameter("u_attack_dir_local", Vector3.FORWARD)
	var override_tex: Texture2D = _load_override_albedo_texture()
	var final_albedo_tex: Texture2D = override_tex if override_tex != null else source_albedo_tex
	var use_albedo_tex: bool = use_model_albedo_texture and final_albedo_tex != null
	anim_material.set_shader_parameter("u_use_albedo_tex", use_albedo_tex)
	anim_material.set_shader_parameter("u_team_tint_strength", clampf(team_tint_strength, 0.0, 1.0))
	if use_albedo_tex:
		anim_material.set_shader_parameter("u_albedo_tex", final_albedo_tex)
	soldiers_mmi.material_override = anim_material
	soldier_anim_material = anim_material
	seeds_uploaded = false

	soldiers_mm = MultiMesh.new()
	soldiers_mm.transform_format = MultiMesh.TRANSFORM_3D
	soldiers_mm.use_custom_data = true
	soldiers_mm.mesh = mesh
	soldiers_mm.instance_count = soldier_count
	soldiers_mm.visible_instance_count = soldier_count
	soldiers_mmi.multimesh = soldiers_mm

func _ensure_commander_mount_root() -> void:
	if commander_mount_root != null and is_instance_valid(commander_mount_root):
		return
	var node: Node = get_node_or_null("CommanderMount")
	if node is Node3D:
		commander_mount_root = node as Node3D
	else:
		commander_mount_root = Node3D.new()
		commander_mount_root.name = "CommanderMount"
		add_child(commander_mount_root)
	if commander_mount_mesh_node != null and is_instance_valid(commander_mount_mesh_node):
		return
	var mesh_node: Node = commander_mount_root.get_node_or_null("CommanderMountMesh")
	if mesh_node is MeshInstance3D:
		commander_mount_mesh_node = mesh_node as MeshInstance3D
	else:
		commander_mount_mesh_node = MeshInstance3D.new()
		commander_mount_mesh_node.name = "CommanderMountMesh"
		commander_mount_root.add_child(commander_mount_mesh_node)
	if commander_mount_mesh_node != null and is_instance_valid(commander_mount_mesh_node):
		commander_mount_mesh_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _resolve_commander_mount_model_path() -> String:
	var p: String = commander_mount_model_source_path.strip_edges()
	if p.is_empty():
		return DEFAULT_CAVALRY_MODEL_SOURCE_PATH
	return p

func _load_commander_mount_mesh_data(path: String) -> Dictionary:
	var key: String = path.strip_edges()
	if key.is_empty():
		return {}
	var cached_mesh_any: Variant = _cached_commander_mount_mesh_by_path.get(key, null)
	if cached_mesh_any is Mesh:
		var cached_basis: Basis = _cached_commander_mount_basis_by_path.get(key, Basis.IDENTITY)
		return {
			"mesh": cached_mesh_any as Mesh,
			"basis": cached_basis
		}
	var loaded: Resource = load(key)
	if loaded == null:
		return {}
	var mesh: Mesh = null
	var basis: Basis = Basis.IDENTITY
	var preferred_material: Material = null
	if loaded is PackedScene:
		var root: Node = (loaded as PackedScene).instantiate()
		if root == null:
			return {}
		var found: Dictionary = _find_first_mesh_data_recursive(root, Basis.IDENTITY)
		root.free()
		if found.is_empty():
			return {}
		mesh = found.get("mesh", null) as Mesh
		basis = found.get("basis", Basis.IDENTITY)
		preferred_material = found.get("material", null) as Material
	elif loaded is Mesh:
		mesh = loaded as Mesh
		basis = Basis.IDENTITY
	else:
		return {}
	if mesh == null:
		return {}
	var single_surface: Mesh = _make_single_surface_mesh(mesh, preferred_material)
	if single_surface == null:
		return {}
	var final_basis: Basis = basis.orthonormalized()
	_cached_commander_mount_mesh_by_path[key] = single_surface
	_cached_commander_mount_basis_by_path[key] = final_basis
	return {
		"mesh": single_surface,
		"basis": final_basis
	}

func _resolve_commander_mount_local_position() -> Vector3:
	var out: Vector3 = commander_mount_local_offset
	if not commander_mount_place_in_front:
		return out
	var front_dist: float = _get_non_melee_formation_radius() * maxf(0.0, commander_mount_front_factor) + maxf(0.0, commander_mount_front_extra)
	out += Vector3(0.0, 0.0, -front_dist)
	return out

func _rebuild_commander_mount_visual() -> void:
	_ensure_commander_mount_root()
	if commander_mount_root == null or not is_instance_valid(commander_mount_root):
		return
	commander_mount_root.position = _resolve_commander_mount_local_position()
	if not commander_mount_enabled:
		commander_mount_root.visible = false
		if commander_mount_mesh_node != null and is_instance_valid(commander_mount_mesh_node):
			commander_mount_mesh_node.mesh = null
		return
	var model_path: String = _resolve_commander_mount_model_path()
	var signature: String = "%s|%.3f|%.3f|%.3f" % [
		model_path,
		commander_mount_scale_mul,
		commander_mount_target_height,
		commander_mount_forward_yaw_degrees
	]
	if signature == commander_mount_signature and commander_mount_mesh_node != null and is_instance_valid(commander_mount_mesh_node):
		_refresh_commander_mount_visibility()
		return
	commander_mount_signature = signature
	var mesh_data: Dictionary = _load_commander_mount_mesh_data(model_path)
	if mesh_data.is_empty():
		commander_mount_root.visible = false
		if commander_mount_mesh_node != null and is_instance_valid(commander_mount_mesh_node):
			commander_mount_mesh_node.mesh = null
		return
	if commander_mount_mesh_node == null or not is_instance_valid(commander_mount_mesh_node):
		return
	var mount_mesh: Mesh = mesh_data.get("mesh", null) as Mesh
	if mount_mesh == null:
		commander_mount_root.visible = false
		commander_mount_mesh_node.mesh = null
		return
	commander_mount_mesh_node.mesh = mount_mesh
	var basis: Basis = mesh_data.get("basis", Basis.IDENTITY)
	var yaw_rad: float = deg_to_rad(commander_mount_forward_yaw_degrees)
	if absf(yaw_rad) > EPS:
		basis = Basis(Vector3.UP, yaw_rad) * basis
	commander_mount_mesh_basis = basis.orthonormalized()
	commander_mount_scale_runtime = _compute_height_scale(mount_mesh, maxf(0.5, commander_mount_target_height)) * maxf(0.1, commander_mount_scale_mul)
	commander_mount_mesh_node.transform = Transform3D(commander_mount_mesh_basis.scaled(Vector3.ONE * commander_mount_scale_runtime), Vector3.ZERO)
	_refresh_commander_mount_visibility()

func _refresh_commander_mount_visibility() -> void:
	if commander_mount_root == null or not is_instance_valid(commander_mount_root):
		return
	commander_mount_root.position = _resolve_commander_mount_local_position()
	if commander_mount_mesh_node == null or not is_instance_valid(commander_mount_mesh_node):
		commander_mount_root.visible = false
		return
	var visible_now: bool = commander_mount_enabled and not dead and commander_mount_mesh_node.mesh != null
	if visible_now and commander_mount_hide_when_soldiers_hidden and not soldier_render_enabled:
		visible_now = false
	if visible_now:
		var depth: float = _get_effect_camera_depth()
		visible_now = depth <= maxf(1.0, commander_mount_visible_near_depth)
	commander_mount_root.visible = visible_now

func _should_use_proxy_soldier_mesh() -> bool:
	return use_proxy_soldier_mesh_when_low_perf and performance_mode_low

func _build_proxy_soldier_mesh() -> Mesh:
	var seg: int = clampi(proxy_soldier_radial_segments, 8, 48)
	var cache_key: String = "proxy|%d|%d" % [int(unit_type), seg]
	if _cached_proxy_mesh_by_type.has(cache_key):
		return _cached_proxy_mesh_by_type.get(cache_key) as Mesh
	# 12 profile points * 32 segments * 2 triangles = 704 triangles.
	var profile: PackedVector2Array = _proxy_profile_for_unit()
	var mesh: ArrayMesh = _build_revolved_profile_mesh(profile, seg)
	if mesh != null:
		_cached_proxy_mesh_by_type[cache_key] = mesh
	return mesh

func _proxy_profile_for_unit() -> PackedVector2Array:
	var out := PackedVector2Array()
	if unit_type == UnitType.CAVALRY:
		out.append(Vector2(0.12, 0.00))
		out.append(Vector2(0.13, 0.18))
		out.append(Vector2(0.16, 0.36))
		out.append(Vector2(0.20, 0.56))
		out.append(Vector2(0.24, 0.78))
		out.append(Vector2(0.26, 1.00))
		out.append(Vector2(0.24, 1.18))
		out.append(Vector2(0.21, 1.32))
		out.append(Vector2(0.17, 1.44))
		out.append(Vector2(0.20, 1.58))
		out.append(Vector2(0.18, 1.70))
		out.append(Vector2(0.10, 1.84))
	else:
		out.append(Vector2(0.08, 0.00))
		out.append(Vector2(0.09, 0.16))
		out.append(Vector2(0.11, 0.34))
		out.append(Vector2(0.14, 0.54))
		out.append(Vector2(0.17, 0.78))
		out.append(Vector2(0.19, 0.98))
		out.append(Vector2(0.17, 1.16))
		out.append(Vector2(0.14, 1.28))
		out.append(Vector2(0.12, 1.38))
		out.append(Vector2(0.16, 1.50))
		out.append(Vector2(0.14, 1.62))
		out.append(Vector2(0.08, 1.74))
	return out

func _build_revolved_profile_mesh(profile: PackedVector2Array, segments: int) -> ArrayMesh:
	if profile.size() < 2:
		return null
	var seg: int = maxi(3, segments)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var profile_steps: float = maxf(1.0, float(profile.size() - 1))
	for i in range(profile.size() - 1):
		var p0: Vector2 = profile[i]
		var p1: Vector2 = profile[i + 1]
		var r0: float = maxf(0.001, p0.x)
		var r1: float = maxf(0.001, p1.x)
		var y0: float = p0.y
		var y1: float = p1.y
		var dy: float = y1 - y0
		var slope: float = 0.0
		if absf(dy) > EPS:
			slope = (r0 - r1) / dy
		var v0: float = float(i) / profile_steps
		var v1: float = float(i + 1) / profile_steps
		for s in range(seg):
			var u0: float = float(s) / float(seg)
			var u1: float = float(s + 1) / float(seg)
			var a0: float = TAU * u0
			var a1: float = TAU * u1
			var c0: float = cos(a0)
			var s0: float = sin(a0)
			var c1: float = cos(a1)
			var s1: float = sin(a1)
			var v00 := Vector3(c0 * r0, y0, s0 * r0)
			var v01 := Vector3(c1 * r0, y0, s1 * r0)
			var v10 := Vector3(c0 * r1, y1, s0 * r1)
			var v11 := Vector3(c1 * r1, y1, s1 * r1)
			var n0 := Vector3(c0, slope, s0).normalized()
			var n1 := Vector3(c1, slope, s1).normalized()

			st.set_normal(n0)
			st.set_uv(Vector2(u0, v0))
			st.add_vertex(v00)
			st.set_normal(n0)
			st.set_uv(Vector2(u0, v1))
			st.add_vertex(v10)
			st.set_normal(n1)
			st.set_uv(Vector2(u1, v1))
			st.add_vertex(v11)

			st.set_normal(n0)
			st.set_uv(Vector2(u0, v0))
			st.add_vertex(v00)
			st.set_normal(n1)
			st.set_uv(Vector2(u1, v1))
			st.add_vertex(v11)
			st.set_normal(n1)
			st.set_uv(Vector2(u1, v0))
			st.add_vertex(v01)
	var mesh: ArrayMesh = st.commit() as ArrayMesh
	return mesh

func _get_model_cache_key() -> String:
	return "%d|%s" % [int(unit_type), override_model_source_path]

func _get_visual_tint_color() -> Color:
	return CAVALRY_BASE_TINT if unit_type == UnitType.CAVALRY else INFANTRY_BASE_TINT

func _get_model_scene_candidate_paths() -> Array[String]:
	var source_path := DEFAULT_CAVALRY_MODEL_SOURCE_PATH if unit_type == UnitType.CAVALRY else DEFAULT_INFANTRY_MODEL_SOURCE_PATH
	var imported_path := DEFAULT_CAVALRY_MODEL_PATH if unit_type == UnitType.CAVALRY else DEFAULT_INFANTRY_MODEL_PATH
	var out: Array[String] = []
	if not override_model_source_path.is_empty():
		out.append(override_model_source_path)
	if not source_path.is_empty():
		out.append(source_path)
	if not imported_path.is_empty() and imported_path != source_path:
		out.append(imported_path)
	return out

func _load_mesh_from_model_scene(path: String) -> Mesh:
	if path.is_empty():
		return null
	var packed: PackedScene = load(path)
	if packed == null:
		return null
	var root: Node = packed.instantiate()
	if root == null:
		return null
	var found: Dictionary = _find_first_mesh_data_recursive(root, Basis.IDENTITY)
	if found.is_empty():
		root.free()
		return null
	var found_mesh: Mesh = found["mesh"]
	var found_material: Material = found.get("material", null) as Material
	soldier_mesh_basis = found["basis"]
	root.free()
	if found_mesh == null:
		return null
	return _make_single_surface_mesh(found_mesh, found_material)

func _find_first_mesh_data_recursive(node: Node, parent_basis: Basis) -> Dictionary:
	var current_basis: Basis = parent_basis
	if node is Node3D:
		var n3d: Node3D = node
		current_basis = parent_basis * n3d.transform.basis
	if node is MeshInstance3D:
		var mi: MeshInstance3D = node
		if mi.mesh != null:
			var picked_material: Material = mi.material_override
			if picked_material == null and mi.mesh.get_surface_count() > 0:
				picked_material = mi.get_active_material(0)
			if picked_material == null and mi.mesh.get_surface_count() > 0:
				picked_material = mi.get_surface_override_material(0)
			if picked_material == null and mi.mesh.get_surface_count() > 0:
				picked_material = mi.mesh.surface_get_material(0)
			return {
				"mesh": mi.mesh,
				"basis": current_basis.orthonormalized(),
				"material": picked_material
			}
	for child in node.get_children():
		var nested: Dictionary = _find_first_mesh_data_recursive(child, current_basis)
		if not nested.is_empty():
			return nested
	return {}

func _make_single_surface_mesh(src: Mesh, preferred_material: Material = null) -> Mesh:
	if src == null or src.get_surface_count() <= 0:
		return null
	var out := ArrayMesh.new()
	var arrays: Array = src.surface_get_arrays(0)
	var blend_shapes: Array = src.surface_get_blend_shape_arrays(0)
	var format: int = src.surface_get_format(0)
	out.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, blend_shapes, {}, format)
	var mat: Material = preferred_material
	if mat == null:
		mat = src.surface_get_material(0)
	if mat != null:
		out.surface_set_material(0, mat)
	return out

func _compute_height_scale(mesh: Mesh, target_height: float) -> float:
	if mesh == null:
		return 1.0
	var h: float = mesh.get_aabb().size.y
	if h <= EPS:
		return 1.0
	return target_height / h

func _extract_mesh_albedo_texture(mesh: Mesh) -> Texture2D:
	if mesh == null or mesh.get_surface_count() <= 0:
		return null
	var mat: Material = mesh.surface_get_material(0)
	return _extract_albedo_from_material(mat)

func _extract_albedo_from_material(mat: Material) -> Texture2D:
	if mat == null:
		return null
	if mat is BaseMaterial3D:
		return (mat as BaseMaterial3D).albedo_texture
	if mat is ShaderMaterial:
		var shader_mat: ShaderMaterial = mat as ShaderMaterial
		var tex_any: Variant = shader_mat.get_shader_parameter("albedo_texture")
		if tex_any is Texture2D:
			return tex_any as Texture2D
	return null

func _load_default_albedo_texture_for_unit() -> Texture2D:
	var fallback_path := DEFAULT_CAVALRY_ALBEDO_PATH if unit_type == UnitType.CAVALRY else DEFAULT_INFANTRY_ALBEDO_PATH
	if fallback_path.is_empty():
		return null
	var res: Resource = load(fallback_path)
	if res is Texture2D:
		return res as Texture2D
	return null

func _load_override_albedo_texture() -> Texture2D:
	if override_albedo_texture_path.is_empty():
		return null
	var res: Resource = load(override_albedo_texture_path)
	if res is Texture2D:
		return res as Texture2D
	return null

func _initialize_soldier_offsets() -> void:
	home_offsets = _generate_formation_offsets(base_formation, soldier_count, formation_spacing)
	desired_offsets = []
	current_offsets = []
	skill_offsets = _generate_formation_offsets(base_formation, soldier_count, formation_spacing)
	seeds = []
	for i in soldier_count:
		desired_offsets.append(home_offsets[i])
		current_offsets.append(home_offsets[i])
		seeds.append(randf())

func _generate_formation_offsets(form: FormationType, count: int, spacing: float) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var safe_count: int = maxi(1, count)
	var square_dim: int = _get_square_dim_for_troops(troop_count)
	match form:
		FormationType.SQUARE:
			var cols: int = square_dim
			var rows: int = maxi(1, int(ceil(float(safe_count) / float(cols))))
			var step := maxf(0.01, spacing) * 2.0
			for i in safe_count:
				var row := i / cols
				var col := i % cols
				var x := (float(col) - float(cols - 1) * 0.5) * step
				var z := (float(row) - float(rows - 1) * 0.5) * step
				out.append(Vector3(x, 0.0, z))
		FormationType.LINE:
			var line_rows: int = _get_line_rows_for_square_dim(square_dim)
			var cols_line: int = maxi(1, int(ceil(float(safe_count) / float(maxi(1, line_rows)))))
			var rows_line: int = maxi(1, int(ceil(float(safe_count) / float(cols_line))))
			var step_x: float = maxf(0.01, spacing) * 2.0
			var step_z: float = maxf(0.01, spacing) * 1.7
			for i in safe_count:
				var row: int = i / cols_line
				var col: int = i % cols_line
				var x := (float(col) - float(cols_line - 1) * 0.5) * step_x
				var z := (float(row) - float(rows_line - 1) * 0.5) * step_z
				out.append(Vector3(x, 0.0, z))
		FormationType.WEDGE:
			var placed := 0
			var row_id := 0
			while placed < safe_count:
				var row_count := row_id * 2 + 1
				for j in row_count:
					if placed >= safe_count:
						break
					var x := (float(j) - float(row_id)) * spacing * 0.9
					var z := float(row_id) * spacing
					out.append(Vector3(x, 0.0, z))
					placed += 1
				row_id += 1

	if out.is_empty():
		return out

	var center := Vector3.ZERO
	for p in out:
		center += p
	center /= float(out.size())
	for i in out.size():
		out[i] -= center
	return out

func has_status(status_id: StatusId) -> bool:
	return timed_statuses.has(int(status_id))

func _is_control_status(status_id: StatusId) -> bool:
	return status_id == StatusId.CONFUSION or status_id == StatusId.MISINFORMATION or status_id == StatusId.PARALYZED or status_id == StatusId.SLOWED

func apply_status(status_id: StatusId, duration_sec: float = 0.0) -> void:
	var key: int = int(status_id)
	var duration_final: float = duration_sec
	if duration_final > 0.0 and _is_control_status(status_id):
		if _is_personality_event_layer_enabled():
			var longdan_lv: int = _personality_highest_level("longdan")
			if longdan_lv > 0 and _personality_proc_ready("longdan_cleanse") and _consume_personality_event_budget(1, "longdan_cleanse"):
				_set_personality_proc_cd("longdan_cleanse", 20.0)
				personality_event_longdan_defense_bonus_pct = maxf(personality_event_longdan_defense_bonus_pct, 0.35 if longdan_lv >= 2 else 0.25)
				personality_event_longdan_defense_bonus_left = maxf(personality_event_longdan_defense_bonus_left, 4.0)
				if longdan_lv >= 2:
					personality_event_longdan_attack_bonus_pct = maxf(personality_event_longdan_attack_bonus_pct, 0.15)
					personality_event_longdan_attack_bonus_left = maxf(personality_event_longdan_attack_bonus_left, 6.0)
				_rebuild_personality_event_runtime_bonus()
				return
		var control_resist_pct: float = _get_personality_control_resist_pct()
		duration_final = maxf(0.12, duration_final * (1.0 - control_resist_pct))
	if duration_final <= 0.0:
		timed_statuses[key] = maxf(float(timed_statuses.get(key, 0.0)), 0.01)
	else:
		timed_statuses[key] = maxf(float(timed_statuses.get(key, 0.0)), duration_final)
	if status_id == StatusId.BURNING and burn_time_left <= 0.001:
		burn_time_left = maxf(burn_time_left, duration_final)
	if status_id == StatusId.PARALYZED:
		_trigger_paralyzed_feedback(maxf(duration_final, sweep_stun_duration))

func clear_status(status_id: StatusId) -> void:
	timed_statuses.erase(int(status_id))

func set_terrain_advantage(active: bool, hold_sec: float = 0.4) -> void:
	if active:
		apply_status(StatusId.TERRAIN_ADVANTAGE, hold_sec)
	else:
		clear_status(StatusId.TERRAIN_ADVANTAGE)

func set_terrain_disadvantage(active: bool, hold_sec: float = 0.4) -> void:
	if active:
		apply_status(StatusId.TERRAIN_DISADVANTAGE, hold_sec)
	else:
		clear_status(StatusId.TERRAIN_DISADVANTAGE)

func get_current_spirit() -> float:
	return spirit_current

func get_current_will() -> float:
	return spirit_current

func get_hp_ratio() -> float:
	return clampf(hp / maxf(1.0, max_hp), 0.0, 1.0)

func get_recent_damage_ratio() -> float:
	return clampf(auto_skill_recent_damage / maxf(1.0, max_hp), 0.0, 4.0)

func has_shield_guard_active() -> bool:
	return _is_shield_role() and _has_persistent_shield_formation()

func get_skill_spirit_cost_value(skill_id: int) -> float:
	match skill_id:
		int(SkillType.CHARGE):
			return _get_skill_spirit_cost(SkillType.CHARGE)
		int(SkillType.BREAKTHROUGH):
			return _get_skill_spirit_cost(SkillType.BREAKTHROUGH)
		int(SkillType.SWEEP):
			return _get_skill_spirit_cost(SkillType.SWEEP)
		_:
			return 0.0

func get_skill_will_cost_value(skill_id: int) -> float:
	return get_skill_spirit_cost_value(skill_id)

func _get_skill_cooldown_sec(skill: SkillType) -> float:
	match skill:
		SkillType.CHARGE:
			return skill_cd_charge
		SkillType.BREAKTHROUGH:
			return skill_cd_breakthrough
		SkillType.SWEEP:
			return skill_cd_sweep
		_:
			return 0.0

func get_skill_cd_left(skill_id: int) -> float:
	return maxf(0.0, float(skill_cooldowns.get(skill_id, 0.0)))

func _tick_skill_cooldowns(delta: float) -> void:
	if skill_cooldowns.is_empty():
		return
	var erase_keys: Array[int] = []
	for key_any in skill_cooldowns.keys():
		var key: int = int(key_any)
		var left: float = maxf(0.0, float(skill_cooldowns.get(key, 0.0)) - maxf(0.0, delta))
		if left <= 0.001:
			erase_keys.append(key)
		else:
			skill_cooldowns[key] = left
	for key in erase_keys:
		skill_cooldowns.erase(key)

func _tick_timed_statuses(delta: float) -> void:
	if timed_statuses.is_empty():
		return
	var erase_keys: Array[int] = []
	for key_any in timed_statuses.keys():
		var key: int = int(key_any)
		var left: float = float(timed_statuses.get(key, 0.0))
		if left < 0.0:
			continue
		left -= maxf(0.0, delta)
		if left <= 0.001:
			erase_keys.append(key)
		else:
			timed_statuses[key] = left
	for key in erase_keys:
		timed_statuses.erase(key)

func _refresh_auto_statuses() -> void:
	if has_status(StatusId.OUT_OF_SUPPLY):
		timed_statuses.erase(int(StatusId.SUPPLY_NORMAL))
	else:
		timed_statuses[int(StatusId.SUPPLY_NORMAL)] = -1.0
	if morale_current >= maxf(0.0, high_morale_threshold):
		timed_statuses[int(StatusId.HIGH_MORALE)] = -1.0
	else:
		timed_statuses.erase(int(StatusId.HIGH_MORALE))
	if personality_attack_bonus_pct > 0.001 or personality_defense_bonus_pct > 0.001 or personality_speed_bonus_pct > 0.001 or personality_spirit_bonus_flat > 0.001 or personality_event_attack_bonus_pct_runtime > 0.001 or personality_event_defense_bonus_pct_runtime > 0.001 or personality_event_speed_bonus_pct_runtime > 0.001 or personality_event_ignore_defense_pct_runtime > 0.001:
		timed_statuses[int(StatusId.PERSONALITY_BUFF)] = -1.0
	else:
		timed_statuses.erase(int(StatusId.PERSONALITY_BUFF))
	if skill_type != SkillType.NONE:
		timed_statuses[int(StatusId.TACTIC_BUFF)] = maxf(float(timed_statuses.get(int(StatusId.TACTIC_BUFF), 0.0)), 0.18)
	elif float(timed_statuses.get(int(StatusId.TACTIC_BUFF), 0.0)) >= 0.0:
		timed_statuses.erase(int(StatusId.TACTIC_BUFF))
	if burn_time_left > 0.001 and burn_dps > 0.001:
		timed_statuses[int(StatusId.BURNING)] = maxf(float(timed_statuses.get(int(StatusId.BURNING), 0.0)), burn_time_left)

func _morale_stat_mul() -> float:
	var missing: float = clampf((morale_cap_base + tech_morale_cap_bonus) - morale_current, 0.0, 100.0)
	var steps: int = int(floor(missing / 10.0 + 0.0001))
	var mul: float = 1.0 - float(steps) * morale_stat_penalty_per_10
	return clampf(mul, morale_stat_mul_min, 1.0)

func _status_attack_mul() -> float:
	var mul: float = _morale_stat_mul()
	if has_status(StatusId.SUPPLY_NORMAL):
		mul *= status_supply_normal_attack_mul
	if has_status(StatusId.HIGH_MORALE):
		mul *= status_high_morale_attack_mul
	if has_status(StatusId.TACTIC_BUFF):
		mul *= status_tactic_buff_attack_mul
	if has_status(StatusId.FACILITY_ATTACK_AURA):
		mul *= status_facility_attack_aura_mul
	if has_status(StatusId.PERSONALITY_BUFF):
		mul *= status_personality_buff_attack_mul
	if has_status(StatusId.TERRAIN_ADVANTAGE):
		mul *= status_terrain_advantage_attack_mul
	if has_status(StatusId.OUT_OF_SUPPLY):
		mul *= status_out_of_supply_attack_mul
	if has_status(StatusId.COUNTERED):
		mul *= status_countered_attack_mul
	if has_status(StatusId.CONFUSION):
		mul *= status_confusion_attack_mul
	if has_status(StatusId.MISINFORMATION):
		mul *= status_misinformation_attack_mul
	if has_status(StatusId.BURNING):
		mul *= status_burning_attack_mul
	if has_status(StatusId.PARALYZED):
		mul *= status_paralyzed_attack_mul
	if has_status(StatusId.TERRAIN_DISADVANTAGE):
		mul *= status_terrain_disadvantage_attack_mul
	return maxf(0.0, mul)

func _status_defense_mul() -> float:
	var mul: float = _morale_stat_mul()
	if has_status(StatusId.SUPPLY_NORMAL):
		mul *= status_supply_normal_defense_mul
	if has_status(StatusId.HIGH_MORALE):
		mul *= status_high_morale_defense_mul
	if has_status(StatusId.TACTIC_BUFF):
		mul *= status_tactic_buff_defense_mul
	if has_status(StatusId.PERSONALITY_BUFF):
		mul *= status_personality_buff_defense_mul
	if has_status(StatusId.TERRAIN_ADVANTAGE):
		mul *= status_terrain_advantage_defense_mul
	if has_status(StatusId.OUT_OF_SUPPLY):
		mul *= status_out_of_supply_defense_mul
	if has_status(StatusId.COUNTERED):
		mul *= status_countered_defense_mul
	if has_status(StatusId.CONFUSION):
		mul *= status_confusion_defense_mul
	if has_status(StatusId.MISINFORMATION):
		mul *= status_misinformation_defense_mul
	if has_status(StatusId.BURNING):
		mul *= status_burning_defense_mul
	if has_status(StatusId.PARALYZED):
		mul *= status_paralyzed_defense_mul
	if has_status(StatusId.TERRAIN_DISADVANTAGE):
		mul *= status_terrain_disadvantage_defense_mul
	return maxf(0.05, mul)

func _status_speed_mul() -> float:
	var mul: float = _morale_stat_mul()
	if has_status(StatusId.SUPPLY_NORMAL):
		mul *= status_supply_normal_speed_mul
	if has_status(StatusId.HIGH_MORALE):
		mul *= status_high_morale_speed_mul
	if has_status(StatusId.TACTIC_BUFF):
		mul *= status_tactic_buff_speed_mul
	if has_status(StatusId.PERSONALITY_BUFF):
		mul *= status_personality_buff_speed_mul
	if has_status(StatusId.TERRAIN_ADVANTAGE):
		mul *= status_terrain_advantage_speed_mul
	if has_status(StatusId.OUT_OF_SUPPLY):
		mul *= status_out_of_supply_speed_mul
	if has_status(StatusId.COUNTERED):
		mul *= status_countered_speed_mul
	if has_status(StatusId.CONFUSION):
		mul *= status_confusion_speed_mul
	if has_status(StatusId.MISINFORMATION):
		mul *= status_misinformation_speed_mul
	if has_status(StatusId.BURNING):
		mul *= status_burning_speed_mul
	if has_status(StatusId.SLOWED):
		mul *= status_slowed_speed_mul
	if has_status(StatusId.PARALYZED):
		mul *= status_paralyzed_speed_mul
	if has_status(StatusId.TERRAIN_DISADVANTAGE):
		mul *= status_terrain_disadvantage_speed_mul
	return maxf(0.0, mul)

func _get_runtime_attack_mul() -> float:
	var mul: float = _status_attack_mul()
	if _is_shield_role():
		mul *= shield_skill_attack_mul
	mul *= 1.0 + personality_event_attack_bonus_pct_runtime
	return maxf(0.0, mul)

func _get_runtime_defense_mul() -> float:
	var mul: float = _status_defense_mul()
	if _is_shield_role():
		mul *= shield_skill_defense_mul
	mul *= 1.0 + personality_event_defense_bonus_pct_runtime
	return maxf(0.05, mul)

func _get_runtime_speed_mul() -> float:
	var mul: float = _status_speed_mul()
	if _is_shield_role():
		mul *= shield_skill_speed_mul
	mul *= 1.0 + personality_event_speed_bonus_pct_runtime
	return maxf(0.0, mul)

func _apply_morale_delta(delta_value: float, _from_event: bool = false) -> void:
	var morale_cap: float = maxf(1.0, morale_cap_base + tech_morale_cap_bonus)
	morale_current = clampf(morale_current + delta_value, 0.0, morale_cap)
	_refresh_auto_statuses()

func _apply_morale_loss_from_hp_change(before_hp: float, after_hp: float) -> void:
	if before_hp <= after_hp or max_hp <= 0.001:
		return
	var hp_ratio_loss: float = clampf((before_hp - after_hp) / max_hp, 0.0, 1.0)
	var morale_loss: float = hp_ratio_loss * 10.0 * morale_loss_per_10pct_troop
	if is_city_garrison:
		morale_loss *= garrison_morale_loss_mul
	_apply_morale_delta(-morale_loss, true)

func _apply_morale_shock_from_source(source: UnitController) -> void:
	if source == null or source.dead or source.team_id == team_id:
		return
	var counter_mul: float = 1.0
	if battlefield != null and battlefield.has_method("get_role_counter_damage_mul"):
		counter_mul = float(battlefield.call("get_role_counter_damage_mul", source._get_self_role_id(), _get_self_role_id()))
	if counter_mul > 1.001:
		apply_status(StatusId.COUNTERED, status_countered_duration)
		_apply_morale_delta(-morale_loss_countered_bonus, true)
	var own_forward: Vector3 = get_collision_forward_flat()
	var to_source: Vector3 = source.global_position - global_position
	to_source.y = 0.0
	if to_source.length_squared() > EPS and own_forward.dot(to_source.normalized()) <= flanked_dot_threshold:
		_apply_morale_delta(-morale_loss_flanked_bonus, true)

func _tick_status_morale_pressure(delta: float) -> void:
	if delta <= 0.0:
		return
	if has_status(StatusId.OUT_OF_SUPPLY):
		_apply_morale_delta(-morale_loss_out_of_supply_per_sec * delta, true)
	if has_status(StatusId.TERRAIN_DISADVANTAGE):
		_apply_morale_delta(-morale_loss_special_terrain_per_sec * delta, true)
	if is_burning():
		_apply_morale_delta(-morale_loss_burning_per_sec * delta, true)

func _tick_morale_zero_attrition(delta: float) -> void:
	if morale_current > 0.001 or dead:
		return
	receive_damage(max_hp * morale_zero_hp_loss_per_sec * maxf(0.0, delta), null)

func get_alive_troop_count() -> int:
	return maxi(0, int(round(float(troop_count) * clampf(hp / maxf(1.0, max_hp), 0.0, 1.0))))

func get_alive_soldier_count() -> int:
	return maxi(0, mini(soldier_count, int(round(float(soldier_count) * clampf(hp / maxf(1.0, max_hp), 0.0, 1.0)))))

func _sync_visible_soldier_count() -> void:
	if soldiers_mm == null:
		return
	var visible_count: int = 0 if dead else maxi(1, get_alive_soldier_count())
	soldiers_mm.visible_instance_count = clampi(visible_count, 0, soldier_count)

func set_soldier_render_enabled(enabled: bool) -> void:
	soldier_render_enabled = enabled
	if soldiers_mmi != null and is_instance_valid(soldiers_mmi):
		soldiers_mmi.visible = enabled
	if soldiers_mm != null:
		if enabled:
			_sync_visible_soldier_count()
		else:
			soldiers_mm.visible_instance_count = 0
	_refresh_commander_mount_visibility()

func _check_rout_conditions() -> void:
	if dead:
		return
	if main_commander_down:
		_dispatch_defeat_report(null)
		_die()
		return
	var troop_ratio: float = clampf(float(get_alive_troop_count()) / maxf(1.0, float(troop_count)), 0.0, 1.0)
	var rout_threshold: float = rout_troop_ratio_garrison if is_city_garrison else rout_troop_ratio_normal
	if morale_current <= 0.001 and troop_ratio <= maxf(0.01, rout_threshold):
		_dispatch_defeat_report(null)
		_die()

func _ensure_runtime_role_profile_applied() -> void:
	if role_profile_runtime_applied:
		return
	if _is_archer_role():
		attack_range = maxf(attack_range, ranged_fixed_center_attack_distance)
	else:
		attack_range = maxf(attack_range, melee_fixed_center_attack_distance)
	_rebuild_unit_profile()
	_refresh_auto_statuses()
	role_profile_runtime_applied = true

func _get_self_role_id() -> String:
	var role_id: String = combat_role_id.strip_edges().to_lower()
	if role_id.is_empty():
		return "cavalry" if unit_type == UnitType.CAVALRY else "infantry"
	return role_id

func _get_role_counter_damage_mul_to(enemy: UnitController) -> float:
	if enemy == null or enemy.dead:
		return 1.0
	if battlefield != null and battlefield.has_method("get_role_counter_damage_mul"):
		return float(battlefield.call("get_role_counter_damage_mul", _get_self_role_id(), enemy._get_self_role_id()))
	return 1.0

func _get_height_attack_mul_to(enemy: UnitController) -> float:
	if enemy == null or enemy.dead:
		return 1.0
	if battlefield != null and battlefield.has_method("get_height_attack_mul"):
		return float(battlefield.call("get_height_attack_mul", self, enemy))
	return 1.0

func _get_height_speed_mul_towards(world_target: Vector3) -> float:
	var move_dir: Vector3 = world_target - global_position
	move_dir.y = 0.0
	if move_dir.length_squared() <= EPS:
		return 1.0
	if battlefield != null and battlefield.has_method("get_height_speed_mul"):
		return float(battlefield.call("get_height_speed_mul", self, move_dir.normalized()))
	return 1.0

func _get_zoc_speed_mul_for_dir(move_dir: Vector3, move_target_unit: UnitController = null, ignore_zoc: bool = false) -> float:
	if personality_event_rendun_ignore_zoc_left > 0.001:
		return 1.0
	if ignore_zoc or not zoc_enabled:
		return 1.0
	if move_target_unit != null and move_target_unit.team_id != team_id and command_mode == CommandMode.FORCE_ATTACK:
		return 1.0
	if (state == UnitState.SKILL_FORM or state == UnitState.SKILL_EXEC) and zoc_ignore_for_skill_charge:
		return 1.0
	if battlefield == null or not battlefield.has_method("get_enemy_units"):
		return 1.0
	var dir: Vector3 = move_dir
	dir.y = 0.0
	if dir.length_squared() <= EPS:
		return 1.0
	dir = dir.normalized()
	var enemy_count: int = 0
	for enemy_any in battlefield.call("get_enemy_units", team_id):
		if not (enemy_any is UnitController):
			continue
		var enemy: UnitController = enemy_any
		if enemy.dead:
			continue
		var to_enemy: Vector3 = enemy.global_position - global_position
		to_enemy.y = 0.0
		if to_enemy.length_squared() <= EPS:
			continue
		if to_enemy.length() > maxf(0.5, zoc_radius):
			continue
		if dir.dot(to_enemy.normalized()) < zoc_front_dot_threshold:
			continue
		enemy_count += 1
		if enemy_count >= maxi(1, zoc_min_enemy_count):
			return clampf(zoc_speed_mul, 0.05, 1.0)
	return 1.0

func _get_archer_frontline_context(enemy: UnitController) -> Dictionary:
	var own_front: float = maxf(0.5, get_collision_half_extents().y * maxf(0.1, archer_frontline_self_radius_mul))
	var enemy_front: float = maxf(0.7, enemy.get_collision_half_extents().y * maxf(0.1, archer_frontline_enemy_radius_mul)) if enemy != null else 1.0
	return {
		"own_front": own_front,
		"enemy_front": enemy_front
	}

func _enter_state(new_state: UnitState) -> void:
	if state == new_state:
		return
	state = new_state
	state_time = 0.0
	if state != UnitState.MOVE:
		move_velocity = Vector3.ZERO
	if state == UnitState.IDLE:
		clear_temporary_detour()
	if state == UnitState.MELEE:
		melee_refresh_timer = 0.0
		melee_leave_timer = 0.0
		if target_unit != null and is_instance_valid(target_unit) and not target_unit.dead:
			_on_personality_first_engage(target_unit)
		if not (transition_restore_home_lock and transition_active):
			if _has_persistent_shield_formation():
				_apply_offsets_immediate(skill_offsets, false)
			else:
				_apply_offsets_immediate(home_offsets, false)
	if state == UnitState.SKILL_FORM or state == UnitState.SKILL_EXEC:
		attack_timer = maxf(attack_timer, 0.08)
	_update_gpu_anim_state()

func _advance_path_waypoint_if_needed(goal_hint: Vector3) -> void:
	if path_points.is_empty() or path_index >= path_points.size():
		return
	var waypoint: Vector3 = path_points[path_index]
	if _flat_distance(global_position, waypoint) <= maxf(0.2, nav_path_reach_tolerance + get_collision_half_extents().y * 0.12):
		path_index += 1
	if path_index >= path_points.size() and goal_hint != Vector3.INF:
		path_points = PackedVector3Array([global_position, goal_hint])
		path_index = 1

func _update_state(delta: float) -> void:
	_refresh_auto_statuses()
	match state:
		UnitState.IDLE:
			_process_idle_state(delta)
		UnitState.MOVE:
			_process_move_state(delta)
		UnitState.MELEE:
			_process_melee_state(delta)
		UnitState.SKILL_FORM:
			_process_skill_form(delta)
		UnitState.SKILL_EXEC:
			_process_skill_exec(delta)
	_update_gpu_anim_state()

func _process_idle_state(delta: float) -> void:
	if has_move_target or nav_mode != NavMode.NONE:
		_enter_state(UnitState.MOVE)
		return
	if command_mode == CommandMode.HOLD_POSITION:
		var hold_enemy: UnitController = _find_enemy_in_radius(maxf(_get_effective_attack_range(), hold_attack_scan_radius))
		if hold_enemy != null:
			target_unit = hold_enemy
			_enter_state(UnitState.MELEE)
			return
	if can_auto_engage():
		var auto_enemy: UnitController = _find_enemy_in_radius(maxf(vision_radius, _get_effective_attack_range() + 1.0))
		if auto_enemy != null:
			issue_attack_order(auto_enemy, auto_enemy.global_position, false, false)
			return
	_apply_unit_facing(desired_facing, delta)

func _process_move_state(delta: float) -> void:
	if command_mode == CommandMode.RETREAT and retreat_destination != Vector3.INF:
		move_target = retreat_destination
		has_move_target = true
	if nav_mode == NavMode.CHASE_TARGET and chase_target_unit != null:
		if _is_chase_target_lost(chase_target_unit):
			_switch_chase_to_fallback_move()
			return
		target_unit = chase_target_unit
		chase_last_goal_point = _get_chase_navigation_goal(chase_target_unit)
		var desired_dist: float = get_ranged_engage_center_distance(chase_target_unit) if _is_archer_role() else get_melee_engage_center_distance(chase_target_unit)
		if _flat_distance_to(chase_target_unit.global_position) <= desired_dist:
			_enter_state(UnitState.MELEE)
			return
		chase_repath_timer -= delta
		if (path_points.is_empty() or path_index >= path_points.size() or _flat_distance(chase_last_goal_point, _get_current_waypoint()) > chase_repath_threshold) and not nav_query_pending and not chase_updates_paused:
			if chase_repath_timer <= 0.0:
				_request_path_async(chase_last_goal_point, PathRequestReason.CHASE_UPDATE, false, true)
				chase_repath_timer = maxf(0.08, chase_repath_interval)
		var chase_goal: Vector3 = _get_current_waypoint() if not path_points.is_empty() and path_index < path_points.size() else chase_last_goal_point
		_advance_path_waypoint_if_needed(chase_last_goal_point)
		_move_towards(chase_goal, float(profile_cache.get("final_speed", move_speed)), delta, "chase", chase_target_unit)
		return
	if attack_move_active and _try_lock_attack_move_target(delta):
		return
	if not has_move_target:
		_enter_state(UnitState.IDLE)
		return
	if path_points.is_empty() and not nav_query_pending:
		_request_path_async(move_target, PathRequestReason.POINT_MOVE, true, true)
	var goal_hint: Vector3 = move_target
	var waypoint: Vector3 = _get_current_waypoint()
	_advance_path_waypoint_if_needed(goal_hint)
	waypoint = _get_current_waypoint()
	_move_towards(waypoint, float(profile_cache.get("final_speed", move_speed)), delta, "move", null)
	if _flat_distance_to(move_target) <= maxf(0.6, retreat_arrive_distance if command_mode == CommandMode.RETREAT else 0.8):
		if _try_activate_next_staged_move_target():
			return
		has_move_target = false
		move_target = global_position
		nav_mode = NavMode.NONE
		if attack_move_active:
			attack_move_active = false
			attack_move_goal = Vector3.ZERO
		_restore_post_move_formation()
		if skill_return_pending:
			var resume_target: UnitController = skill_return_resume_target if skill_return_resume_target != null and is_instance_valid(skill_return_resume_target) and not skill_return_resume_target.dead else null
			var restore_face: Vector3 = skill_return_face_dir if skill_return_face_dir.length_squared() > EPS else get_collision_forward_flat()
			skill_return_pending = false
			skill_return_resume_target = null
			skill_return_face_dir = Vector3.FORWARD
			desired_facing = restore_face.normalized()
			look_at(global_position + desired_facing, Vector3.UP)
			if resume_target == null and stance != StanceType.PASSIVE and stance != StanceType.HOLD:
				resume_target = _find_enemy_in_radius(maxf(vision_radius, _get_effective_attack_range() + 1.0))
			if resume_target != null:
				chase_target_unit = resume_target
				target_unit = resume_target
				melee_refresh_timer = 0.0
				attack_timer = minf(attack_timer, 0.05)
				reengage_time_left = maxf(0.0, chase_reengage_lock_sec)
				motion_dir = _flat_dir_to(global_position, resume_target.global_position)
				desired_facing = motion_dir
				look_at(global_position + desired_facing, Vector3.UP)
				var desired_dist: float = get_ranged_engage_center_distance(resume_target) if _is_archer_role() else get_melee_engage_center_distance(resume_target)
				if _flat_distance_to(resume_target.global_position) <= desired_dist + (archer_range_hysteresis if _is_archer_role() else melee_center_distance_tolerance):
					nav_mode = NavMode.NONE
					has_move_target = false
					_enter_state(UnitState.MELEE)
				else:
					nav_mode = NavMode.CHASE_TARGET
					has_move_target = false
					_enter_state(UnitState.MOVE)
			else:
				nav_mode = NavMode.NONE
				_enter_state(UnitState.IDLE)
			return
		_enter_state(UnitState.IDLE)

func _plan_move_order_targets(world_pos: Vector3) -> Dictionary:
	var desired: Vector3 = Vector3(world_pos.x, global_position.y, world_pos.z)
	var first_target: Vector3 = desired
	var next_targets: Array[Vector3] = []
	if battlefield != null and battlefield.has_method("plan_unit_move_targets"):
		var plan_any: Variant = battlefield.call("plan_unit_move_targets", self, desired)
		if plan_any is Dictionary:
			var plan: Dictionary = plan_any
			if not bool(plan.get("ok", true)):
				return {"ok": false, "reason": String(plan.get("reason", "blocked"))}
			var first_any: Variant = plan.get("first_target", desired)
			if first_any is Vector3:
				first_target = first_any
			var next_any: Variant = plan.get("next_targets", [])
			if next_any is Array:
				for item in (next_any as Array):
					if item is Vector3:
						next_targets.append(item)
	if battlefield != null and battlefield.has_method("resolve_walkable_point"):
		var resolved_first: Variant = battlefield.call("resolve_walkable_point", first_target, self)
		if resolved_first is Vector3 and resolved_first != Vector3.INF:
			first_target = resolved_first
	return {"ok": first_target != Vector3.INF, "first_target": first_target, "next_targets": next_targets}

func _try_activate_next_staged_move_target() -> bool:
	if staged_move_targets.is_empty():
		return false
	while not staged_move_targets.is_empty():
		var raw_next: Vector3 = staged_move_targets.pop_front()
		var next_target: Vector3 = raw_next
		if battlefield != null and battlefield.has_method("resolve_walkable_point"):
			var resolved_any: Variant = battlefield.call("resolve_walkable_point", raw_next, self)
			if resolved_any is Vector3 and resolved_any != Vector3.INF:
				next_target = resolved_any
		if next_target == Vector3.INF:
			continue
		if _flat_distance_to(next_target) <= maxf(0.6, retreat_arrive_distance if command_mode == CommandMode.RETREAT else 0.8):
			continue
		move_target = Vector3(next_target.x, global_position.y, next_target.z)
		has_move_target = true
		if attack_move_active:
			nav_mode = NavMode.ATTACK_MOVE
			_request_path_async(move_target, PathRequestReason.ATTACK_MOVE, true, true)
		else:
			nav_mode = NavMode.POINT_MOVE
			_request_path_async(move_target, PathRequestReason.POINT_MOVE, true, true)
		return true
	return false

func _variant_to_vec3_array(value: Variant) -> Array[Vector3]:
	var out: Array[Vector3] = []
	if value is Array:
		for item in (value as Array):
			if item is Vector3:
				out.append(item)
	return out
func _perform_attack_on_target(enemy: UnitController, is_ranged: bool) -> void:
	if enemy == null or enemy.dead:
		return
	var ignore_def_mul: float = 1.0
	if personality_event_ignore_defense_pct_runtime > 0.001 and skill_type == SkillType.NONE:
		ignore_def_mul += clampf(personality_event_ignore_defense_pct_runtime, 0.0, 0.45)
	if is_ranged:
		if archer_skill_fire_lock_timer > 0.0:
			return
		if _is_strategist_role():
			_trigger_strategist_cast_vfx()
		_emit_archer_arrow_trace(enemy)
		var base_damage: float = _get_base_attack_damage() * archer_damage_mul * ignore_def_mul
		_apply_tactic_damage_to(enemy, base_damage)
		if _is_strategist_role():
			_queue_strategist_impact_vfx(enemy)
	else:
		var base_damage: float = _get_base_attack_damage() * ignore_def_mul
		_apply_tactic_damage_to(enemy, base_damage)

func _process_melee_state(delta: float) -> void:
	if target_unit == null or target_unit.dead:
		if chase_target_unit != null and not chase_target_unit.dead:
			target_unit = chase_target_unit
			_enter_state(UnitState.MOVE)
			return
		target_unit = null
		chase_target_unit = null
		_reset_post_combat_visual_motion()
		if has_move_target:
			_enter_state(UnitState.MOVE)
		else:
			_enter_state(UnitState.IDLE)
		return
	var dist_to_target: float = _flat_distance_to(target_unit.global_position)
	var is_ranged: bool = _is_archer_role()
	var desired_dist: float = get_ranged_engage_center_distance(target_unit) if is_ranged else get_melee_engage_center_distance(target_unit)
	if dist_to_target > desired_dist + (archer_range_hysteresis if is_ranged else melee_center_distance_tolerance):
		_move_towards(target_unit.global_position, float(profile_cache.get("final_speed", move_speed)), delta, "reengage", target_unit)
		melee_refresh_timer = 0.0
		return
	var face_dir: Vector3 = _flat_dir_to(global_position, target_unit.global_position)
	_apply_unit_facing(face_dir, delta)
	if not is_ranged:
		if transition_restore_home_lock and transition_active:
			melee_refresh_timer = maxf(melee_refresh_timer, 0.06)
		else:
			if _has_persistent_shield_formation():
				_apply_offsets_immediate(skill_offsets, false)
			else:
				_apply_offsets_immediate(home_offsets, false)
	else:
		if not (transition_restore_home_lock and transition_active):
			_apply_offsets_immediate(home_offsets, false)
	attack_timer -= delta
	if attack_timer <= 0.0:
		attack_timer = maxf(0.08, 1.0 / maxf(0.05, float(profile_cache.get("final_attack_speed", 1.0))))
		_perform_attack_on_target(target_unit, is_ranged)

func _process_skill_form(delta: float) -> void:
	var active_skill_target: UnitController = skill_target if skill_target != null and is_instance_valid(skill_target) and not skill_target.dead else null
	var is_pierce_form: bool = (skill_type == SkillType.CHARGE or skill_type == SkillType.BREAKTHROUGH) and not _is_archer_role() and not _is_shield_role()
	var facing: Vector3 = _resolve_skill_forward()
	if is_pierce_form and pierce_path_forward.length_squared() > EPS:
		facing = pierce_path_forward.normalized()
	elif active_skill_target != null:
		facing = _flat_dir_to(global_position, active_skill_target.global_position)
	if is_pierce_form and charge_form_duration_ref > 0.001:
		var form_total: float = maxf(0.001, charge_form_duration_ref)
		var progress: float = clampf(1.0 - skill_timer / form_total, 0.0, 1.0)
		var backstep_dist: float = charge_windup_backstep_distance
		if skill_type == SkillType.BREAKTHROUGH:
			backstep_dist *= maxf(1.0, breakthrough_windup_backstep_mul)
		var start_ratio: float = clampf(charge_windup_backstep_start_ratio, 0.0, 0.95)
		var end_ratio: float = clampf(charge_windup_backstep_end_ratio, start_ratio + 0.02, 1.0)
		var retreat_ratio: float = clampf((progress - start_ratio) / maxf(0.001, end_ratio - start_ratio), 0.0, 1.0)
		retreat_ratio = retreat_ratio * retreat_ratio * (3.0 - 2.0 * retreat_ratio)
		var retreat_target: Vector3 = charge_form_origin.lerp(charge_form_origin - facing.normalized() * backstep_dist, retreat_ratio)
		retreat_target.y = global_position.y
		global_position = retreat_target
	_apply_unit_facing(facing, delta)
	skill_timer = maxf(0.0, skill_timer - delta)
	if skill_timer <= 0.0:
		_begin_skill_exec()

func _compute_sweep_goal(active_skill_target: UnitController) -> Vector3:
	var forward: Vector3 = _resolve_skill_forward()
	var target_pos: Vector3 = global_position + forward * maxf(4.0, sweep_forward_distance)
	if active_skill_target != null:
		target_pos = active_skill_target.global_position
	var goal: Vector3 = target_pos
	goal.y = global_position.y
	return goal

func _begin_skill_exec() -> void:
	var active_skill_target: UnitController = skill_target if skill_target != null and is_instance_valid(skill_target) and not skill_target.dead else null
	charge_hit_timer = 0.0
	sweep_impact_triggered = false
	skill_success_triggered = false
	match skill_type:
		SkillType.CHARGE:
			if _is_archer_role():
				charge_goal = global_position
				skill_timer = maxf(0.42, charge_duration * 0.72)
				skill_exec_speed_ref = 0.0
				charge_hit_timer = maxf(0.08, skill_timer * 0.45)
				pierce_active = false
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
				allow_overlap = false
			elif _is_shield_role():
				charge_goal = global_position
				skill_timer = maxf(0.65, shield_wall_exec_duration)
				skill_exec_speed_ref = 0.0
				charge_hit_timer = 0.0
				pierce_active = false
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
				allow_overlap = false
			elif _is_spear_role():
				charge_goal = global_position
				skill_timer = maxf(0.75, spear_brace_duration)
				skill_exec_speed_ref = 0.0
				charge_hit_timer = 0.0
				pierce_active = false
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
			else:
				charge_goal = global_position + _resolve_skill_forward() * maxf(4.0, charge_distance)
				if active_skill_target != null:
					var to_target: Vector3 = active_skill_target.global_position - global_position
					to_target.y = 0.0
					if to_target.length_squared() > EPS:
						var enemy_half: Vector2 = active_skill_target.get_collision_half_extents()
						var front_gap: float = maxf(0.15, enemy_half.y * 0.12)
						charge_goal = active_skill_target.global_position - to_target.normalized() * front_gap
				skill_timer = maxf(0.3, charge_duration)
				skill_exec_speed_ref = maxf(charge_speed, move_speed) * 1.6
				charge_hit_timer = 0.08
				pierce_active = true
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
		SkillType.BREAKTHROUGH:
			if _is_archer_role():
				charge_goal = global_position
				skill_timer = maxf(0.38, breakthrough_duration * 0.58)
				skill_exec_speed_ref = 0.0
				charge_hit_timer = maxf(0.06, skill_timer * 0.38)
				pierce_active = false
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
				allow_overlap = false
			elif _is_shield_role():
				charge_goal = _compute_shield_bash_goal(active_skill_target)
				skill_exec_speed_ref = maxf(charge_speed, move_speed) * maxf(1.05, shield_bash_speed_mul)
				var shield_bash_travel: float = maxf(0.1, _flat_distance_to(charge_goal))
				skill_timer = clampf(shield_bash_travel / maxf(0.1, skill_exec_speed_ref) + 0.2, 0.3, maxf(0.72, shield_bash_exec_duration))
				charge_hit_timer = 0.03
				pierce_active = false
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
				allow_overlap = false
			elif _is_spear_role():
				charge_goal = _compute_spear_hook_goal(active_skill_target)
				if active_skill_target != null:
					var to_target: Vector3 = active_skill_target.global_position - global_position
					to_target.y = 0.0
					if to_target.length_squared() > EPS:
						charge_goal = active_skill_target.global_position - to_target.normalized() * maxf(0.4, active_skill_target.get_collision_half_extents().y * 0.16)
				skill_exec_speed_ref = maxf(charge_speed, move_speed) * maxf(1.4, spear_lunge_speed_mul)
				var spear_lunge_travel: float = maxf(0.1, _flat_distance_to(charge_goal))
				skill_timer = clampf(spear_lunge_travel / maxf(0.1, skill_exec_speed_ref) + 0.16, 0.28, maxf(0.46, breakthrough_duration * 0.72))
				charge_hit_timer = 0.02
				pierce_active = false
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
			else:
				charge_goal = pierce_path_end if pierce_path_end != Vector3.ZERO else global_position + _resolve_skill_forward() * maxf(5.0, breakthrough_distance)
				skill_exec_speed_ref = maxf(breakthrough_speed, charge_speed) * maxf(1.2, breakthrough_exec_speed_mul)
				var breakthrough_travel: float = maxf(0.1, _flat_distance_to(charge_goal))
				skill_timer = clampf(breakthrough_travel / maxf(0.1, skill_exec_speed_ref) + 0.22, 0.3, maxf(0.42, breakthrough_duration))
				charge_hit_timer = 0.035
				pierce_active = true
				pierce_can_pass_through = true
				if active_skill_target != null:
					pierce_ignore_target_id = active_skill_target.get_instance_id()
		SkillType.SWEEP:
			if _is_archer_role():
				charge_goal = global_position
				skill_timer = maxf(0.52, sweep_duration * 0.82)
				skill_exec_speed_ref = 0.0
				charge_hit_timer = maxf(0.08, skill_timer * 0.42)
				pierce_active = false
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
				allow_overlap = false
			elif _is_shield_role():
				charge_goal = global_position
				skill_timer = maxf(0.82, shield_tortoise_exec_duration)
				skill_exec_speed_ref = 0.0
				charge_hit_timer = 0.0
				pierce_active = false
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
				allow_overlap = false
			elif _is_spear_role():
				charge_goal = global_position
				skill_timer = maxf(0.58, sweep_duration * 0.9)
				skill_exec_speed_ref = 0.0
				charge_hit_timer = 0.0
				pierce_active = false
				pierce_can_pass_through = false
				pierce_ignore_target_id = 0
				allow_overlap = false
			else:
				charge_goal = _compute_sweep_goal(active_skill_target)
				skill_timer = maxf(0.5, sweep_duration)
				skill_exec_speed_ref = maxf(sweep_dash_speed, move_speed) * 2.0
				charge_hit_timer = 0.1
				pierce_active = active_skill_target != null
				pierce_can_pass_through = true
				pierce_ignore_target_id = active_skill_target.get_instance_id() if active_skill_target != null else 0
				allow_overlap = active_skill_target != null
		_:
			_finish_skill()
			return
	_play_skill_vfx(skill_type, true)
	_enter_state(UnitState.SKILL_EXEC)

func _process_skill_exec(delta: float) -> void:
	var active_skill_target: UnitController = skill_target if skill_target != null and is_instance_valid(skill_target) and not skill_target.dead else null
	skill_timer = maxf(0.0, skill_timer - delta)
	match skill_type:
		SkillType.CHARGE:
			if _is_archer_role():
				if active_skill_target == null:
					_finish_skill()
					return
				_apply_unit_facing(_flat_dir_to(global_position, active_skill_target.global_position), delta)
				charge_hit_timer -= delta
				if charge_hit_timer <= 0.0 and not pierce_hit_applied:
					charge_hit_timer = 999.0
					_apply_archer_volley_hit(active_skill_target)
				if pierce_hit_applied:
					skill_timer = minf(skill_timer, 0.18)
				if skill_timer <= 0.0:
					_finish_skill()
			elif _is_shield_role():
				if active_skill_target != null:
					_apply_unit_facing(_flat_dir_to(global_position, active_skill_target.global_position), delta)
				_apply_shield_wall_hit(active_skill_target)
				if pierce_hit_applied:
					skill_timer = minf(skill_timer, 0.28)
				if skill_timer <= 0.0:
					_finish_skill()
			elif _is_spear_role():
				if active_skill_target != null:
					_apply_unit_facing(_flat_dir_to(global_position, active_skill_target.global_position), delta)
				_try_apply_spear_brace_hit(active_skill_target)
				if pierce_hit_applied:
					skill_timer = minf(skill_timer, 0.16)
				if skill_timer <= 0.0:
					_finish_skill()
			else:
				_move_towards(charge_goal, skill_exec_speed_ref, delta, "charge", active_skill_target)
				_try_apply_pierce_hit(SkillType.CHARGE)
				if pierce_hit_applied:
					skill_timer = minf(skill_timer, 0.12)
				charge_hit_timer -= delta
				if charge_hit_timer <= 0.0:
					charge_hit_timer = 0.08
					_apply_charge_hits(maxf(2.2, get_collision_half_extents().x * 1.05))
				if skill_timer <= 0.0 or _flat_distance_to(charge_goal) <= 0.25:
					_finish_skill()
		SkillType.BREAKTHROUGH:
			if _is_archer_role():
				if active_skill_target == null:
					_finish_skill()
					return
				_apply_unit_facing(_flat_dir_to(global_position, active_skill_target.global_position), delta)
				charge_hit_timer -= delta
				if charge_hit_timer <= 0.0 and not pierce_hit_applied:
					charge_hit_timer = 999.0
					_apply_archer_pierce_hit(active_skill_target)
				if pierce_hit_applied:
					skill_timer = minf(skill_timer, 0.16)
				if skill_timer <= 0.0:
					_finish_skill()
			elif _is_shield_role():
				if active_skill_target == null:
					_finish_skill()
					return
				_move_towards(charge_goal, skill_exec_speed_ref, delta, "charge", active_skill_target)
				_try_apply_shield_bash_hit(active_skill_target)
				if pierce_hit_applied:
					skill_timer = minf(skill_timer, 0.22)
				if skill_timer <= 0.0 or global_position.distance_to(charge_goal) <= 0.28:
					_finish_skill()
			elif _is_spear_role():
				_move_towards(charge_goal, skill_exec_speed_ref, delta, "charge", active_skill_target)
				_try_apply_spear_lunge_hit(active_skill_target)
				if pierce_hit_applied:
					skill_timer = minf(skill_timer, 0.14)
				if skill_timer <= 0.0 or global_position.distance_to(charge_goal) <= 0.35:
					_finish_skill()
			else:
				_move_towards(charge_goal, skill_exec_speed_ref, delta, "charge", active_skill_target)
				_try_apply_pierce_hit(SkillType.BREAKTHROUGH)
				charge_hit_timer -= delta
				if charge_hit_timer <= 0.0:
					charge_hit_timer = 0.05
					_apply_breakthrough_hits(maxf(2.2, get_collision_half_extents().x * 0.95))
				if skill_timer <= 0.0 or global_position.distance_to(charge_goal) <= 0.35:
					_finish_skill()
		SkillType.SWEEP:
			if _is_archer_role():
				if active_skill_target == null:
					_finish_skill()
					return
				_apply_unit_facing(_flat_dir_to(global_position, active_skill_target.global_position), delta)
				charge_hit_timer -= delta
				if charge_hit_timer <= 0.0 and not sweep_impact_triggered:
					charge_hit_timer = 999.0
					_apply_archer_barrage_hit(active_skill_target)
				if sweep_impact_triggered:
					skill_timer = minf(skill_timer, 0.22)
				if skill_timer <= 0.0:
					_finish_skill()
			elif _is_shield_role():
				if active_skill_target != null:
					_apply_unit_facing(_flat_dir_to(global_position, active_skill_target.global_position), delta)
				_apply_shield_tortoise_hit(active_skill_target)
				if sweep_impact_triggered:
					skill_timer = minf(skill_timer, 0.34)
				if skill_timer <= 0.0:
					_finish_skill()
			elif _is_spear_role():
				if active_skill_target == null:
					_finish_skill()
					return
				_apply_unit_facing(_flat_dir_to(global_position, active_skill_target.global_position), delta)
				_apply_spear_throw_hit(active_skill_target)
				if sweep_impact_triggered:
					skill_timer = minf(skill_timer, 0.24)
				if skill_timer <= 0.0:
					_finish_skill()
			else:
				_move_towards(charge_goal, skill_exec_speed_ref, delta, "charge", active_skill_target)
				charge_hit_timer -= delta
				if charge_hit_timer <= 0.0:
					charge_hit_timer = 0.11
					_apply_sweep_hits()
				if skill_timer <= 0.0 or global_position.distance_to(charge_goal) <= 0.6:
					_finish_skill()
		_:
			_finish_skill()

func get_combat_role_id() -> String:
	return combat_role_id.strip_edges().to_lower()

func get_commander_display_name() -> String:
	var name_text: String = main_commander_name.strip_edges()
	if name_text.is_empty():
		name_text = name.strip_edges()
	if name_text.is_empty():
		name_text = "主帅"
	return name_text

func _status_display_name(status_id: int) -> String:
	match status_id:
		int(StatusId.SUPPLY_NORMAL):
			return "补给充足"
		int(StatusId.HIGH_MORALE):
			return "高士气"
		int(StatusId.TACTIC_BUFF):
			return "战法强化"
		int(StatusId.PERSONALITY_BUFF):
			return "个性强化"
		int(StatusId.TERRAIN_ADVANTAGE):
			return "地形有利"
		int(StatusId.OUT_OF_SUPPLY):
			return "断粮"
		int(StatusId.MORALE_COLLAPSE):
			return "士气崩溃"
		int(StatusId.COUNTERED):
			return "被克制"
		int(StatusId.CONFUSION):
			return "混乱"
		int(StatusId.MISINFORMATION):
			return "误导"
		int(StatusId.BURNING):
			return "着火"
		int(StatusId.SLOWED):
			return "迟缓"
		int(StatusId.PARALYZED):
			return "麻痹"
		int(StatusId.TERRAIN_DISADVANTAGE):
			return "地形不利"
		int(StatusId.FACILITY_ATTACK_AURA):
			return "军乐攻势"
		_:
			return ""

func _collect_status_display_lines(limit: int = 4) -> Array[String]:
	var lines: Array[String] = []
	if timed_statuses.is_empty():
		return lines
	var keys: Array = timed_statuses.keys()
	keys.sort()
	for key_any in keys:
		var status_id: int = int(key_any)
		var status_name: String = _status_display_name(status_id)
		if status_name.is_empty():
			continue
		var left: float = float(timed_statuses.get(status_id, -1.0))
		if left >= 0.0:
			lines.append("%s %.1fs" % [status_name, left])
		else:
			lines.append(status_name)
		if limit > 0 and lines.size() >= limit:
			break
	return lines

func _state_display_text() -> String:
	var text: String = "未知"
	match state:
		UnitState.IDLE:
			text = "待机"
		UnitState.MOVE:
			text = "移动"
		UnitState.MELEE:
			text = "交战"
		UnitState.SKILL_FORM:
			text = "战法蓄势"
		UnitState.SKILL_EXEC:
			text = "战法释放"
	if naval_embarked:
		return "%s(乘船:%s)" % [text, _ship_type_display_text(_resolve_ship_type_for_runtime())]
	return text

func _stance_display_text() -> String:
	match stance:
		StanceType.ACTIVE:
			return "主动"
		StanceType.HOLD:
			return "固守"
		StanceType.PASSIVE:
			return "被动"
		_:
			return "未知"

func _personality_summary_text() -> String:
	var parts: Array[String] = []
	if absf(personality_attack_bonus_pct) >= 0.001:
		parts.append("攻%s%.0f%%" % ["+" if personality_attack_bonus_pct >= 0.0 else "", personality_attack_bonus_pct * 100.0])
	if absf(personality_defense_bonus_pct) >= 0.001:
		parts.append("防%s%.0f%%" % ["+" if personality_defense_bonus_pct >= 0.0 else "", personality_defense_bonus_pct * 100.0])
	if absf(personality_speed_bonus_pct) >= 0.001:
		parts.append("速%s%.0f%%" % ["+" if personality_speed_bonus_pct >= 0.0 else "", personality_speed_bonus_pct * 100.0])
	if absf(personality_spirit_bonus_flat) >= 0.01:
		parts.append("斗志%s%.0f" % ["+" if personality_spirit_bonus_flat >= 0.0 else "", personality_spirit_bonus_flat])
	if absf(personality_event_attack_bonus_pct_runtime) >= 0.001:
		parts.append("触发攻+%.0f%%" % [personality_event_attack_bonus_pct_runtime * 100.0])
	if absf(personality_event_defense_bonus_pct_runtime) >= 0.001:
		parts.append("触发防+%.0f%%" % [personality_event_defense_bonus_pct_runtime * 100.0])
	if absf(personality_event_speed_bonus_pct_runtime) >= 0.001:
		parts.append("触发速+%.0f%%" % [personality_event_speed_bonus_pct_runtime * 100.0])
	if absf(personality_event_ignore_defense_pct_runtime) >= 0.001:
		parts.append("破防+%.0f%%" % [personality_event_ignore_defense_pct_runtime * 100.0])
	var control_resist_pct: float = _get_personality_control_resist_pct()
	if absf(control_resist_pct) >= 0.001:
		parts.append("控抗+%.0f%%" % [control_resist_pct * 100.0])
	if parts.is_empty():
		return "无"
	return " / ".join(PackedStringArray(parts))

func _officer_personality_text(raw_text: String, fallback_text: String) -> String:
	var text: String = raw_text.strip_edges()
	if not text.is_empty():
		return text
	return fallback_text

func _siege_role_multiplier(role_id: String) -> float:
	match role_id:
		"siege":
			return 1.55
		"shield":
			return 1.28
		"spear":
			return 1.18
		"archer":
			return 0.92
		"crossbow":
			return 1.04
		"strategist":
			return 0.82
		"cavalry", "scout":
			return 0.86
		"naval":
			return 1.08
		_:
			return 1.0

func get_rts_panel_data() -> Dictionary:
	var unit_skills: Array = []
	var role_id: String = combat_role_id.strip_edges().to_lower()
	if role_id != "strategist" and (unit_type == UnitType.CAVALRY or role_id == "spear" or role_id == "shield" or role_id == "archer" or role_id == "crossbow"):
		unit_skills.append({"id": int(SkillType.CHARGE)})
		unit_skills.append({"id": int(SkillType.BREAKTHROUGH)})
		unit_skills.append({"id": int(SkillType.SWEEP)})
	var physical_attack_base: float = float(profile_cache.get("final_attack", attack_damage))
	var physical_defense_base: float = float(profile_cache.get("final_defense", max_hp * 0.08))
	var magic_attack_base: float = float(profile_cache.get("final_magic_attack", attack_damage * 0.45))
	var magic_defense_base: float = float(profile_cache.get("final_magic_defense", max_hp * 0.05))
	var move_speed_base: float = float(profile_cache.get("final_speed", move_speed))
	var attack_speed_base: float = float(profile_cache.get("final_attack_speed", 1.0))
	var runtime_attack_mul: float = _get_runtime_attack_mul()
	var runtime_defense_mul: float = _get_runtime_defense_mul()
	var runtime_speed_mul: float = _get_runtime_speed_mul()
	var status_attack_mul: float = _status_attack_mul()
	var status_defense_mul: float = _status_defense_mul()
	var personality_summary: String = _personality_summary_text()
	var main_aptitude_text: String = _aptitude_to_text(main_unit_aptitude)
	var vice_1_aptitude_text: String = _aptitude_to_text(vice_1_unit_aptitude)
	var vice_2_aptitude_text: String = _aptitude_to_text(vice_2_unit_aptitude)
	var main_personality_text: String = _officer_personality_text(main_battle_personality, personality_summary)
	var vice_1_personality_text: String = _officer_personality_text(vice_1_battle_personality, personality_summary)
	var vice_2_personality_text: String = _officer_personality_text(vice_2_battle_personality, personality_summary)
	var officers: Array = []
	officers.append({
		"name": main_commander_name,
		"aptitude": main_aptitude_text,
		"personality": main_personality_text
	})
	officers.append({
		"name": vice_commander_1_name,
		"aptitude": vice_1_aptitude_text,
		"personality": vice_1_personality_text
	})
	officers.append({
		"name": vice_commander_2_name,
		"aptitude": vice_2_aptitude_text,
		"personality": vice_2_personality_text
	})
	var unit_type_label: String = unit_type_label_override.strip_edges()
	if unit_type_label.is_empty():
		unit_type_label = role_id
	return {
		"main_name": main_commander_name,
		"vice_1_name": vice_commander_1_name,
		"vice_2_name": vice_commander_2_name,
		"intelligence_mix": float(profile_cache.get("intelligence_mix", main_intelligence)),
		"leadership_mix": float(profile_cache.get("leadership_mix", main_leadership)),
		"might_mix": float(profile_cache.get("might_mix", main_might)),
		"politics_mix": float(profile_cache.get("politics_mix", main_politics)),
		"charm_mix": float(profile_cache.get("charm_mix", main_charm)),
		"aptitude": String(profile_cache.get("aptitude", _aptitude_to_text(main_unit_aptitude))),
		"main_aptitude": main_aptitude_text,
		"vice_1_aptitude": vice_1_aptitude_text,
		"vice_2_aptitude": vice_2_aptitude_text,
		"main_personality": main_personality_text,
		"vice_1_personality": vice_1_personality_text,
		"vice_2_personality": vice_2_personality_text,
		"personality_summary": personality_summary,
		"officers": officers,
		"alive_troops": get_alive_troop_count(),
		"morale": morale_current,
		"spirit": spirit_current,
		"state_text": _state_display_text(),
		"stance_text": _stance_display_text(),
		"active_statuses": _collect_status_display_lines(6),
		"tech_traits_active": tech_traits_runtime.duplicate(true),
		"tech_effect_cumulative": tech_effect_cumulative_runtime.duplicate(true),
		"famous_skill_name": famous_skill_name,
		"famous_skill_desc": famous_skill_desc,
		"personality_event_debug_enabled": personality_event_debug_stats_enabled,
		"personality_event_trigger_total": personality_event_debug_trigger_total,
		"personality_event_blocked_total": personality_event_debug_blocked_total,
		"personality_event_forced_total": personality_event_debug_forced_total,
		"physical_attack": physical_attack_base * runtime_attack_mul,
		"physical_defense": physical_defense_base * runtime_defense_mul,
		"magic_attack": magic_attack_base * maxf(0.0, status_attack_mul),
		"magic_defense": magic_defense_base * maxf(0.05, status_defense_mul),
		"siege_power": physical_attack_base * runtime_attack_mul * _siege_role_multiplier(role_id),
		"move_speed": move_speed_base * runtime_speed_mul,
		"attack_speed": attack_speed_base * maxf(0.0, status_attack_mul),
		"unit_type_label": unit_type_label,
		"unit_skills": unit_skills,
		"combat_role_id": role_id,
		"naval_embarked": naval_embarked,
		"naval_ship_type": _resolve_ship_type_for_runtime(),
		"naval_ship_label": _ship_type_display_text(_resolve_ship_type_for_runtime()),
		"tactic_slots": tactic_slots,
		"unlocked_tactics": unlocked_tactics.duplicate()
	}

func _normalize_ship_type_id(raw_type: String) -> String:
	var ship_type: String = raw_type.strip_edges().to_lower()
	match ship_type:
		"", "default":
			return ""
		"zouge", "zoug", "small", "light", "walkboat", "走舸":
			return "zouge"
		"lou", "louchuan", "lou_chuan", "tower", "tower_ship", "advanced", "楼船", "斗舰", "艨艟":
			return "lou_chuan"
		_:
			return ship_type

func _ship_type_display_text(ship_type: String) -> String:
	var normalized: String = _normalize_ship_type_id(ship_type)
	match normalized:
		"lou_chuan":
			return "楼船"
		"zouge":
			return "走舸"
		_:
			return "走舸"

func _resolve_ship_type_for_runtime() -> String:
	var active: String = _normalize_ship_type_id(naval_ship_type)
	if not active.is_empty():
		return active
	var preferred: String = _normalize_ship_type_id(naval_preferred_ship_type)
	if not preferred.is_empty():
		return preferred
	return "zouge"

func set_preferred_ship_type(ship_type: String) -> void:
	naval_preferred_ship_type = _normalize_ship_type_id(ship_type)
	if not naval_embarked and not naval_preferred_ship_type.is_empty():
		naval_ship_type = naval_preferred_ship_type

func get_preferred_ship_type() -> String:
	return _resolve_ship_type_for_runtime()

func is_embarked() -> bool:
	return naval_embarked

func get_embarked_ship_type() -> String:
	return _resolve_ship_type_for_runtime()

func set_embarked_state(active: bool, ship_type: String = "") -> void:
	var normalized: String = _normalize_ship_type_id(ship_type)
	if active:
		naval_embarked = true
		if normalized.is_empty():
			normalized = _resolve_ship_type_for_runtime()
		naval_ship_type = normalized
		return
	naval_embarked = false
	if not normalized.is_empty():
		naval_preferred_ship_type = normalized
		naval_ship_type = normalized

func _requires_naval_direct_path(goal_world: Vector3) -> bool:
	if battlefield == null or not battlefield.has_method("is_unit_naval_direct_path_required"):
		return false
	return bool(battlefield.call("is_unit_naval_direct_path_required", self, goal_world))
