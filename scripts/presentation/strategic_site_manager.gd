@tool
extends Node3D
class_name StrategicSiteManager

const JsonDataSource := preload("res://scripts/data/json_data_source.gd")
const DEFAULT_DATA_PATH := "res://data/config/strategic_sites.json"
const DEFAULT_OVERRIDE_PATH := "res://data/config/strategic_sites_manual_overrides.json"
const DEFAULT_CHUNK_SIZE := 3000.0
const DEFAULT_MAX_SPAWN_PER_TICK := 8
const DEFAULT_NEIGHBOR_RADIUS := 1
const HALF_MAP_SIZE := 15000.0
const DEFAULT_PLACEHOLDER_MODEL_SCENE := "res://scenes/prefabs/site_placeholder_model.tscn"
const MIN_REFRESH_INTERVAL_SEC := 0.2
const MAX_SPAWN_PER_TICK := 10
const BUILDING_COLLISION_LAYER := 2
const EDITOR_LOD_LEVEL_HEIGHTS := [160.0, 420.0, 1400.0, 4200.0, 12000.0, 26000.0]

@export_category("Editor Actions")
@export var save_current_positions_now: bool = false:
	set(value):
		if value:
			save_current_positions_now = false
			call_deferred("_save_current_positions_to_override")
@export var rebuild_now: bool = false:
	set(value):
		if value:
			rebuild_now = false
			call_deferred("reload_and_refresh")
@export var clear_now: bool = false:
	set(value):
		if value:
			clear_now = false
			call_deferred("clear_instances")

@export_category("Data And Placement")
@export_file("*.json") var data_path: String = DEFAULT_DATA_PATH
@export_file("*.json") var manual_override_path: String = DEFAULT_OVERRIDE_PATH
@export var auto_load_runtime: bool = true
@export var preview_load_in_editor: bool = false
@export var terrain_path: NodePath
@export var anchor_path: NodePath
@export var input_coordinates_use_north_positive_z: bool = true
@export var preserve_editor_instance_positions: bool = true
@export var preserve_runtime_instance_positions: bool = true
@export var editor_current_positions_authoritative: bool = true
@export var force_load_all: bool = false
@export var height_offset: float = 0.0
@export var max_spawn_per_tick: int = DEFAULT_MAX_SPAWN_PER_TICK
@export var refresh_interval_seconds: float = 0.6
@export var skip_refresh_when_fully_loaded: bool = true

@export_category("Visual And LOD")
@export var normalize_non_city_visuals: bool = false
@export var non_city_model_scale: float = 176.0
@export var non_city_scale_threshold: float = 5.0
@export var non_city_label_height: float = 48.0
@export var non_city_label_font_size: int = 18
@export var non_city_label_pixel_size: float = 0.0028
@export var non_city_lod3_label_scale: float = 0.70
@export var non_city_lod4_label_scale: float = 0.88
@export var hide_non_city_labels_from_lod: int = 5
@export var hide_non_city_models_from_lod: int = 5
@export var distance_cull_non_city_models: bool = true
@export var non_city_model_visible_distance: float = 7800.0
@export var city_lod_enabled: bool = true
@export var city_lod3_label_scale: float = 0.90
@export var city_lod4_label_scale: float = 0.80
@export var hide_city_labels_from_lod: int = 6
@export var hide_city_models_from_lod: int = 6
@export var distance_cull_city_models: bool = false
@export var city_model_visible_distance: float = 12000.0
@export var use_placeholder_models: bool = false
@export_file("*.tscn") var placeholder_model_scene_path: String = DEFAULT_PLACEHOLDER_MODEL_SCENE

var _json_source := JsonDataSource.new()
var _chunk_size: float = DEFAULT_CHUNK_SIZE
var _neighbor_radius: int = DEFAULT_NEIGHBOR_RADIUS
var _site_defs_by_id: Dictionary = {}
var _site_ids_by_chunk: Dictionary = {}
var _active_instances: Dictionary = {}
var _pending_spawn_ids: Array[String] = []
var _current_center_chunk := Vector2i(999999, 999999)
var _instance_root: Node3D
var _refresh_timer: Timer
var _selected_site_id: String = ""
var _current_lod_level: int = 3
var _current_total_lods: int = 6
var _current_lod_height: float = 1400.0
var _runtime_use_placeholder_models: bool = false
var _placeholder_model_scene: PackedScene = null
var _scene_cache: Dictionary = {}
var _warned_missing_placeholder: bool = false
var _site_visibility_overrides: Dictionary = {}
var _editor_lod_applied_once: bool = false
var _runtime_site_status: Dictionary = {}

func _ready() -> void:
	_ensure_instance_root()
	_ensure_refresh_timer()
	reload_data()
	_adopt_preexisting_instances()
	if Engine.is_editor_hint():
		_refresh_editor_lod_preview()
		return
	if auto_load_runtime:
		_refresh_active_sites(true)

func reload_and_refresh() -> void:
	reload_data()
	_adopt_preexisting_instances()
	_refresh_active_sites(true)

func _persist_editor_positions_if_present() -> void:
	if not Engine.is_editor_hint():
		return
	if not editor_current_positions_authoritative:
		return
	if _instance_root == null:
		return
	if _instance_root.get_child_count() <= 0:
		return
	_save_current_positions_to_override()

func reload_data() -> void:
	_persist_editor_positions_if_present()
	_site_defs_by_id.clear()
	_site_ids_by_chunk.clear()
	_pending_spawn_ids.clear()
	_current_center_chunk = Vector2i(999999, 999999)
	_scene_cache.clear()
	_warned_missing_placeholder = false
	_runtime_site_status.clear()
	var root: Dictionary = _json_source.load_dictionary(data_path)
	if root.is_empty():
		return
	_chunk_size = maxf(float(root.get("chunk_size", DEFAULT_CHUNK_SIZE)), 1.0)
	_neighbor_radius = maxi(int(root.get("active_neighbor_radius", DEFAULT_NEIGHBOR_RADIUS)), 0)
	_runtime_use_placeholder_models = use_placeholder_models
	if root.has("use_placeholder_models"):
		_runtime_use_placeholder_models = bool(root.get("use_placeholder_models"))
	var placeholder_path := String(root.get("placeholder_model_scene", placeholder_model_scene_path))
	_placeholder_model_scene = _load_packed_scene(placeholder_path) if _runtime_use_placeholder_models and not placeholder_path.is_empty() else null
	var overrides := _load_override_map()
	var sites_any: Variant = root.get("sites", [])
	if not (sites_any is Array):
		return
	for site_any in sites_any:
		if not (site_any is Dictionary):
			continue
		var site: Dictionary = (site_any as Dictionary).duplicate(true)
		var site_id: String = String(site.get("id", "")).strip_edges()
		if site_id.is_empty():
			continue
		if overrides.has(site_id):
			_merge_dictionary(site, overrides[site_id])
		if not _validate_site(site):
			continue
		_site_defs_by_id[site_id] = site
		var pos: Dictionary = site.get("position", {})
		var source_x: float = float(pos.get("x", 0.0))
		var source_z: float = float(pos.get("z", 0.0))
		var chunk: Vector2i = _world_to_chunk(source_x, _source_z_to_world_z_for_site(source_z, site))
		var chunk_ids: Array = _site_ids_by_chunk.get(chunk, [])
		chunk_ids.append(site_id)
		_site_ids_by_chunk[chunk] = chunk_ids

func clear_instances() -> void:
	_pending_spawn_ids.clear()
	_selected_site_id = ""
	for site_id in _active_instances.keys():
		var node: Node = _active_instances[site_id]
		if is_instance_valid(node):
			node.queue_free()
	_active_instances.clear()
	if _instance_root != null:
		for child in _instance_root.get_children():
			if child is Node:
				(child as Node).queue_free()

func _adopt_preexisting_instances() -> void:
	if _instance_root == null:
		return
	var reapply_positions: bool = true
	if Engine.is_editor_hint():
		reapply_positions = not preserve_editor_instance_positions
	else:
		reapply_positions = not preserve_runtime_instance_positions
	var adopted: Dictionary = {}
	for child in _instance_root.get_children():
		if not (child is Node):
			continue
		var node: Node = child as Node
		var site_id: String = _extract_site_id_from_node(node)
		if site_id.is_empty():
			continue
		if not _site_defs_by_id.has(site_id):
			node.queue_free()
			continue
		if adopted.has(site_id):
			node.queue_free()
			continue
		var site: Dictionary = _site_defs_by_id.get(site_id, {})
		_apply_site_meta(node, site_id, site)
		if reapply_positions:
			_apply_site_world_position(node, site)
		adopted[site_id] = node
	_active_instances = adopted

func _extract_site_id_from_node(node: Node) -> String:
	if node == null:
		return ""
	var site_id: String = String(node.get_meta("building_id", "")).strip_edges()
	if not site_id.is_empty():
		return site_id
	var node_name: String = String(node.name)
	if node_name.begins_with("Site_"):
		return node_name.trim_prefix("Site_")
	return ""

func _apply_site_meta(node: Node, site_id: String, site: Dictionary) -> void:
	if node == null:
		return
	var site_type: String = String(site.get("type", node.get_meta("building_type", "fort")))
	var site_name: String = String(site.get("name", site_id))
	var state_name: String = String(site.get("state", ""))
	if String(node.name) != "Site_%s" % site_id:
		node.name = "Site_%s" % site_id
	node.set_meta("building_id", site_id)
	node.set_meta("building_type", site_type)
	node.set_meta("site_name", site_name)
	node.set_meta("state_name", state_name)
	if _node_has_property(node, "site_name"):
		node.set("site_name", site_name)
	if _node_has_property(node, "site_type"):
		node.set("site_type", site_type)
	if _node_has_property(node, "state_name"):
		node.set("state_name", state_name)
	if _node_has_property(node, "faction_id"):
		node.set("faction_id", String(site.get("faction_id", "")))
	var fallback_show: bool = true
	if _node_has_property(node, "show_label"):
		fallback_show = bool(node.get("show_label"))
	if not node.has_meta("base_show_label"):
		node.set_meta("base_show_label", bool(site.get("show_label", fallback_show)))
	if _node_has_property(node, "label_height") and not node.has_meta("base_label_height"):
		node.set_meta("base_label_height", float(node.get("label_height")))
	if _node_has_property(node, "label_font_size") and not node.has_meta("base_label_font_size"):
		node.set_meta("base_label_font_size", int(node.get("label_font_size")))
	if _node_has_property(node, "label_pixel_size") and not node.has_meta("base_label_pixel_size"):
		node.set_meta("base_label_pixel_size", float(node.get("label_pixel_size")))
	var static_body: Node = node.get_node_or_null("StaticBody3D")
	if static_body != null:
		static_body.set_meta("building_id", site_id)
		static_body.set_meta("building_type", site_type)
	_apply_runtime_status_to_instance(node, site_id)

func set_selected_site(site_id: String) -> void:
	_selected_site_id = site_id
	for active_id in _active_instances.keys():
		var node: Node = _active_instances[active_id]
		if node != null and node.has_method("set_selected"):
			node.call("set_selected", String(active_id) == _selected_site_id)

func apply_camera_lod(level: int, total_levels: int, height: float) -> void:
	_current_lod_level = level
	_current_total_lods = total_levels
	_current_lod_height = height
	_apply_lod_to_active_instances()

func get_site_snapshot(site_id: String) -> Dictionary:
	if not _site_defs_by_id.has(site_id):
		return {}
	return (_site_defs_by_id[site_id] as Dictionary).duplicate(true)

func get_all_site_snapshots() -> Array:
	var out: Array = []
	for site_id_any in _site_defs_by_id.keys():
		var site_id: String = String(site_id_any)
		if site_id.is_empty():
			continue
		var site_any: Variant = _site_defs_by_id.get(site_id, {})
		if site_any is Dictionary:
			out.append((site_any as Dictionary).duplicate(true))
	return out

func set_site_visibility_overrides(overrides: Dictionary) -> void:
	_site_visibility_overrides = overrides.duplicate(true)
	_apply_lod_to_active_instances()

func apply_runtime_site_status(site_id: String, defense_current: float, defense_max: float, troops: float) -> void:
	var normalized_site_id: String = site_id.strip_edges()
	if normalized_site_id.is_empty():
		return
	_runtime_site_status[normalized_site_id] = {
		"defense_current": _sanitize_runtime_value(defense_current),
		"defense_max": _sanitize_runtime_value(defense_max),
		"troops": _sanitize_runtime_value(troops)
	}
	if not _active_instances.has(normalized_site_id):
		return
	var node: Node = _active_instances[normalized_site_id]
	if not is_instance_valid(node):
		return
	_apply_runtime_status_to_instance(node, normalized_site_id)

func has_active_site(site_id: String) -> bool:
	if not _active_instances.has(site_id):
		return false
	var node: Node = _active_instances[site_id]
	return node != null and is_instance_valid(node)

func _ensure_instance_root() -> void:
	var existing: Node = get_node_or_null("SiteInstances")
	if existing is Node3D:
		_instance_root = existing as Node3D
	else:
		_instance_root = Node3D.new()
		_instance_root.name = "SiteInstances"
		add_child(_instance_root)
		_own_node_for_editor(_instance_root)

func _ensure_refresh_timer() -> void:
	var existing: Node = get_node_or_null("RefreshTimer")
	if existing is Timer:
		_refresh_timer = existing as Timer
	else:
		_refresh_timer = Timer.new()
		_refresh_timer.name = "RefreshTimer"
		_refresh_timer.wait_time = maxf(refresh_interval_seconds, MIN_REFRESH_INTERVAL_SEC)
		_refresh_timer.one_shot = false
		_refresh_timer.autostart = true
		add_child(_refresh_timer)
		_own_node_for_editor(_refresh_timer)
	_refresh_timer.wait_time = maxf(refresh_interval_seconds, MIN_REFRESH_INTERVAL_SEC)
	if not _refresh_timer.timeout.is_connected(_on_refresh_timer_timeout):
		_refresh_timer.timeout.connect(_on_refresh_timer_timeout)
	_refresh_timer.start()

func _on_refresh_timer_timeout() -> void:
	if Engine.is_editor_hint():
		_refresh_editor_lod_preview()
		return
	if not auto_load_runtime:
		return
	_sync_lod_from_anchor()
	if skip_refresh_when_fully_loaded and force_load_all and _pending_spawn_ids.is_empty() and _active_instances.size() >= _site_defs_by_id.size() and _site_defs_by_id.size() > 0:
		_apply_lod_to_active_instances()
		return
	_refresh_active_sites(false)

func _refresh_active_sites(force_full_refresh: bool) -> void:
	if _site_defs_by_id.is_empty():
		clear_instances()
		return
	_adopt_preexisting_instances()
	var anchor_pos: Vector3 = _get_anchor_world_position()
	var center_chunk: Vector2i = _world_to_chunk(anchor_pos.x, anchor_pos.z)
	var desired_ids: Dictionary = {}
	var load_all: bool = force_load_all and not Engine.is_editor_hint()
	if load_all:
		for site_id_any in _site_defs_by_id.keys():
			var all_id: String = String(site_id_any)
			desired_ids[all_id] = true
			if not _active_instances.has(all_id) and _pending_spawn_ids.find(all_id) == -1:
				_pending_spawn_ids.append(all_id)
	else:
		for dz in range(-_neighbor_radius, _neighbor_radius + 1):
			for dx in range(-_neighbor_radius, _neighbor_radius + 1):
				var key := Vector2i(center_chunk.x + dx, center_chunk.y + dz)
				var chunk_ids: Array = _site_ids_by_chunk.get(key, [])
				for site_id_any in chunk_ids:
					var site_id: String = String(site_id_any)
					desired_ids[site_id] = true
					if not _active_instances.has(site_id) and _pending_spawn_ids.find(site_id) == -1:
						_pending_spawn_ids.append(site_id)
	for active_id_any in _active_instances.keys():
		var active_id: String = String(active_id_any)
		if desired_ids.has(active_id):
			continue
		var node: Node = _active_instances[active_id]
		if is_instance_valid(node):
			node.queue_free()
		_active_instances.erase(active_id)
	_pending_spawn_ids = _pending_spawn_ids.filter(func(site_id: String) -> bool:
		return desired_ids.has(site_id)
	)
	if force_full_refresh or center_chunk != _current_center_chunk:
		_spawn_pending_batch()
	else:
		_spawn_pending_batch()
	_current_center_chunk = center_chunk
	set_selected_site(_selected_site_id)
	_apply_lod_to_active_instances()

func _spawn_pending_batch() -> void:
	if _instance_root == null:
		return
	var allowed_per_tick: int = mini(maxi(max_spawn_per_tick, 0), MAX_SPAWN_PER_TICK)
	if allowed_per_tick <= 0:
		return
	var spawn_count: int = mini(allowed_per_tick, _pending_spawn_ids.size())
	for _i in range(spawn_count):
		var site_id: String = _pending_spawn_ids.pop_front()
		if _active_instances.has(site_id):
			continue
		var site: Dictionary = _site_defs_by_id.get(site_id, {})
		if site.is_empty():
			continue
		var instance: Node = _instantiate_site(site)
		if instance == null:
			continue
		_active_instances[site_id] = instance

func _instantiate_site(site: Dictionary) -> Node:
	var scene_path: String = String(site.get("prefab_scene", ""))
	if scene_path.is_empty():
		return null
	var packed: PackedScene = _load_packed_scene(scene_path)
	if packed == null:
		push_warning("StrategicSiteManager cannot load prefab: %s" % scene_path)
		return null
	var node: Node = packed.instantiate()
	if node == null:
		return null
	var site_id: String = String(site.get("id", ""))
	var site_type: String = String(site.get("type", "fort"))
	var model_path: String = String(site.get("model_path", ""))
	var model_scene: PackedScene = null
	if not model_path.is_empty():
		model_scene = _load_packed_scene(model_path)
	var placeholder_scene: PackedScene = _resolve_placeholder_scene(site)
	if placeholder_scene != null:
		model_scene = placeholder_scene
	elif _runtime_use_placeholder_models and model_scene == null and _placeholder_model_scene == null and not _warned_missing_placeholder:
		_warned_missing_placeholder = true
		push_warning("StrategicSiteManager placeholder enabled but placeholder model not found.")
	if _node_has_property(node, "site_name"):
		node.set("site_name", String(site.get("name", site_id)))
	if _node_has_property(node, "site_type"):
		node.set("site_type", site_type)
	if _node_has_property(node, "state_name") and site.has("state"):
		node.set("state_name", String(site.get("state", "")))
	if _node_has_property(node, "faction_id"):
		node.set("faction_id", String(site.get("faction_id", "")))
	if _node_has_property(node, "site_scale"):
		var raw_scale: float = float(site.get("site_scale", 1.0))
		node.set("site_scale", _resolve_site_scale(site_type, raw_scale))
	if _node_has_property(node, "label_height"):
		var raw_height: float = float(site.get("label_height", 18.0))
		node.set("label_height", _resolve_label_height(site_type, raw_height))
	if _node_has_property(node, "label_font_size"):
		var raw_font_size: int = int(site.get("label_font_size", 28))
		node.set("label_font_size", _resolve_label_font_size(site_type, raw_font_size))
	if _node_has_property(node, "label_pixel_size"):
		var raw_pixel_size: float = float(site.get("label_pixel_size", 0.02))
		node.set("label_pixel_size", _resolve_label_pixel_size(site_type, raw_pixel_size))
	if _node_has_property(node, "show_label"):
		node.set("show_label", bool(site.get("show_label", true)))
	if _node_has_property(node, "collision_extents"):
		var ext: Dictionary = site.get("collision_extents", {})
		node.set("collision_extents", Vector3(float(ext.get("x", 14.0)), float(ext.get("y", 8.0)), float(ext.get("z", 14.0))))
	if _node_has_property(node, "model_scene") and model_scene != null:
		node.set("model_scene", model_scene)
	if node is Node3D:
		_apply_site_world_position(node, site)
	if node is CollisionObject3D:
		(node as CollisionObject3D).input_ray_pickable = true
	node.name = "Site_%s" % site_id
	_apply_site_meta(node, site_id, site)
	_instance_root.add_child(node)
	_apply_lod_to_instance(node, site_type, _get_anchor_world_position())
	return node

func _apply_site_world_position(node: Node, site: Dictionary) -> void:
	if not (node is Node3D):
		return
	var pos: Dictionary = site.get("position", {})
	var world_x: float = float(pos.get("x", 0.0))
	var world_z: float = _source_z_to_world_z_for_site(float(pos.get("z", 0.0)), site)
	var ground_y: float = _sample_ground_height(world_x, world_z)
	if not is_finite(ground_y):
		ground_y = 0.0
	(node as Node3D).position = Vector3(world_x, ground_y + height_offset, world_z)

func _resolve_site_scale(site_type: String, raw_scale: float) -> float:
	var safe_scale: float = maxf(raw_scale, 0.001)
	if not normalize_non_city_visuals or site_type == "city":
		return safe_scale
	if safe_scale <= non_city_scale_threshold:
		return maxf(non_city_model_scale, 0.001) * safe_scale
	return safe_scale

func _resolve_label_height(site_type: String, raw_height: float) -> float:
	var safe_height: float = maxf(raw_height, 0.1)
	if not normalize_non_city_visuals or site_type == "city":
		return safe_height
	return maxf(non_city_label_height, 0.1)

func _resolve_label_font_size(site_type: String, raw_font_size: int) -> int:
	var safe_size: int = maxi(raw_font_size, 8)
	if not normalize_non_city_visuals or site_type == "city":
		return safe_size
	return maxi(non_city_label_font_size, 8)

func _resolve_label_pixel_size(site_type: String, raw_pixel_size: float) -> float:
	var safe_pixel_size: float = maxf(raw_pixel_size, 0.001)
	if not normalize_non_city_visuals or site_type == "city":
		return safe_pixel_size
	return maxf(non_city_label_pixel_size, 0.001)

func _apply_lod_to_active_instances() -> void:
	var anchor_pos: Vector3 = _get_anchor_world_position()
	for site_id in _active_instances.keys():
		var node: Node = _active_instances[site_id]
		if is_instance_valid(node):
			_apply_lod_to_instance(node, "", anchor_pos)

func _resolve_placeholder_scene(site: Dictionary) -> PackedScene:
	var site_placeholder_path: String = String(site.get("placeholder_model_scene", "")).strip_edges()
	var use_site_placeholder: bool = bool(site.get("use_placeholder_model", false))
	if not site_placeholder_path.is_empty():
		use_site_placeholder = true
	if not (use_site_placeholder or _runtime_use_placeholder_models):
		return null
	if not site_placeholder_path.is_empty():
		var loaded := _load_packed_scene(site_placeholder_path)
		if loaded != null:
			return loaded
	if _placeholder_model_scene != null:
		return _placeholder_model_scene
	return null

func _apply_lod_to_instance(node: Node, site_type_hint: String = "", anchor_world_pos: Vector3 = Vector3.INF) -> void:
	if node == null:
		return
	var site_id: String = String(node.get_meta("building_id", "")).strip_edges()
	var forced_visible: bool = _is_site_forced_visible(site_id)
	_apply_site_visibility_state(node, forced_visible)
	if not forced_visible:
		return
	var site_type: String = site_type_hint
	if site_type.is_empty():
		site_type = String(node.get_meta("building_type", "fort"))
	var is_city: bool = site_type == "city"
	if is_city and not city_lod_enabled:
		return

	var base_show: bool = bool(node.get_meta("base_show_label", true))
	var base_height: float = float(node.get_meta("base_label_height", 18.0))
	var base_font: int = int(node.get_meta("base_label_font_size", 20))
	var base_pixel: float = float(node.get_meta("base_label_pixel_size", 0.012))

	var lod_level: int = maxi(_current_lod_level, 1)
	var label_scale: float = 1.0
	if lod_level == 3:
		label_scale = maxf(city_lod3_label_scale if is_city else non_city_lod3_label_scale, 0.6)
	elif lod_level == 4:
		label_scale = maxf(city_lod4_label_scale if is_city else non_city_lod4_label_scale, 0.6)

	var show_model: bool = true
	var show_label: bool = base_show
	var show_icon: bool = false
	var show_point: bool = false

	if lod_level >= 6:
		show_model = false
		show_label = false
		show_icon = false
		show_point = true
	elif lod_level == 5:
		show_model = false
		show_label = false
		show_icon = true
		show_point = false
	elif lod_level == 4:
		show_model = false
		show_label = base_show
		show_icon = false
		show_point = false
	else:
		var hide_labels: bool = lod_level >= maxi(hide_city_labels_from_lod if is_city else hide_non_city_labels_from_lod, 2)
		var hide_models_by_lod: bool = lod_level >= maxi(hide_city_models_from_lod if is_city else hide_non_city_models_from_lod, 2)
		show_label = base_show and not hide_labels
		show_model = not hide_models_by_lod
		if show_model and anchor_world_pos != Vector3.INF and node is Node3D:
			var use_distance_cull: bool = distance_cull_city_models if is_city else distance_cull_non_city_models
			if use_distance_cull:
				var max_distance: float = maxf(city_model_visible_distance if is_city else non_city_model_visible_distance, 120.0)
				var dist_sq: float = ((node as Node3D).global_position - anchor_world_pos).length_squared()
				show_model = dist_sq <= max_distance * max_distance
	_apply_model_visibility(node, show_model)
	if _node_has_property(node, "show_label"):
		node.set("show_label", show_label)
	if _node_has_property(node, "label_font_size"):
		node.set("label_font_size", maxi(8, int(round(float(base_font) * label_scale))))
	if _node_has_property(node, "label_pixel_size"):
		node.set("label_pixel_size", maxf(0.001, base_pixel * label_scale))
	if _node_has_property(node, "label_height"):
		var height_scale: float = 1.0 if label_scale <= 1.0 else (1.0 + (label_scale - 1.0) * 0.8)
		node.set("label_height", maxf(0.1, base_height * height_scale))
	if node.has_method("set_lod_label_mode"):
		node.call("set_lod_label_mode", lod_level <= 3)
	if node.has_method("set_lod_marker_state"):
		node.call("set_lod_marker_state", show_icon, show_point, site_type, _current_lod_height)

func _apply_runtime_status_to_instance(node: Node, site_id: String) -> void:
	if node == null or not node.has_method("set_runtime_site_status"):
		return
	var status_any: Variant = _runtime_site_status.get(site_id, {})
	if not (status_any is Dictionary):
		node.call("set_runtime_site_status", -1.0, -1.0, -1.0)
		return
	var status: Dictionary = status_any as Dictionary
	node.call(
		"set_runtime_site_status",
		_sanitize_runtime_value(float(status.get("defense_current", -1.0))),
		_sanitize_runtime_value(float(status.get("defense_max", -1.0))),
		_sanitize_runtime_value(float(status.get("troops", -1.0)))
	)

func _sanitize_runtime_value(value: float) -> float:
	return maxf(value, -1.0)

func _is_site_forced_visible(site_id: String) -> bool:
	if site_id.is_empty():
		return true
	if not _site_visibility_overrides.has(site_id):
		return true
	return bool(_site_visibility_overrides.get(site_id, true))

func _apply_site_visibility_state(node: Node, visible_now: bool) -> void:
	if node == null:
		return
	if node is Node3D:
		(node as Node3D).visible = visible_now
	if node is CollisionObject3D:
		var collision_node: CollisionObject3D = node as CollisionObject3D
		collision_node.input_ray_pickable = visible_now
		collision_node.collision_layer = BUILDING_COLLISION_LAYER if visible_now else 0
	var body: StaticBody3D = node.get_node_or_null("StaticBody3D") as StaticBody3D
	if body != null:
		body.input_ray_pickable = visible_now
		body.collision_layer = BUILDING_COLLISION_LAYER if visible_now else 0

func _apply_model_visibility(node: Node, visible_now: bool) -> void:
	if node == null:
		return
	if node.has_method("set_model_visible"):
		node.call("set_model_visible", visible_now)
		return
	var model_root: Node = node.get_node_or_null("ModelRoot")
	if model_root is Node3D:
		(model_root as Node3D).visible = visible_now

func _sample_ground_height(world_x: float, world_z: float) -> float:
	if terrain_path.is_empty():
		return 0.0
	var terrain: Node = get_node_or_null(terrain_path)
	if terrain == null:
		return 0.0
	var terrain_data: Variant = terrain.get("data")
	if terrain_data == null:
		return 0.0
	if terrain_data.has_method("get_height"):
		var h1: float = float(terrain_data.call("get_height", Vector3(world_x, 0.0, world_z)))
		return h1 if is_finite(h1) else 0.0
	if terrain_data.has_method("get_height_at_position"):
		var h2: float = float(terrain_data.call("get_height_at_position", Vector3(world_x, 0.0, world_z)))
		return h2 if is_finite(h2) else 0.0
	return 0.0

func _site_uses_unflipped_north_south(site: Dictionary) -> bool:
	var site_type: String = String(site.get("type", "")).strip_edges().to_lower()
	if site_type == "ferry":
		return true
	var prefab_scene: String = String(site.get("prefab_scene", "")).strip_edges().to_lower()
	if prefab_scene.contains("fortress_outpost_instance"):
		return true
	var model_path: String = String(site.get("model_path", "")).strip_edges().to_lower()
	return model_path.contains("wubao")

func _source_z_to_world_z(source_z: float) -> float:
	return -source_z if input_coordinates_use_north_positive_z else source_z

func _source_z_to_world_z_for_site(source_z: float, site: Dictionary) -> float:
	if not input_coordinates_use_north_positive_z:
		return source_z
	return source_z if _site_uses_unflipped_north_south(site) else -source_z

func _world_z_to_source_z(world_z: float) -> float:
	return -world_z if input_coordinates_use_north_positive_z else world_z

func _world_z_to_source_z_for_site(world_z: float, site: Dictionary) -> float:
	if not input_coordinates_use_north_positive_z:
		return world_z
	return world_z if _site_uses_unflipped_north_south(site) else -world_z

func _get_anchor_world_position() -> Vector3:
	if Engine.is_editor_hint():
		var editor_viewport := get_viewport()
		if editor_viewport != null:
			var editor_camera := editor_viewport.get_camera_3d()
			if editor_camera != null:
				return editor_camera.global_position
	if not anchor_path.is_empty():
		var anchor: Node = get_node_or_null(anchor_path)
		if anchor is Node3D:
			return (anchor as Node3D).global_position
	var viewport := get_viewport()
	if viewport != null:
		var camera := viewport.get_camera_3d()
		if camera != null:
			return camera.global_position
	return global_position

func _sync_lod_from_anchor() -> void:
	if anchor_path.is_empty():
		return
	if Engine.is_editor_hint():
		# In editor, camera scripts that are not @tool run as placeholders.
		# Avoid calling custom methods on placeholder script instances.
		return
	var anchor: Node = get_node_or_null(anchor_path)
	if anchor == null:
		return
	if not anchor.has_method("get_current_lod_level"):
		return
	if not anchor.has_method("get_total_lod_levels"):
		return
	if not anchor.has_method("get_current_target_height"):
		return
	var level: int = int(anchor.call("get_current_lod_level"))
	var total: int = int(anchor.call("get_total_lod_levels"))
	var height: float = float(anchor.call("get_current_target_height"))
	_current_lod_level = maxi(1, level)
	_current_total_lods = maxi(1, total)
	_current_lod_height = height

func _refresh_editor_lod_preview() -> void:
	if not Engine.is_editor_hint():
		return
	var changed: bool = _sync_editor_lod_from_camera()
	if changed or not _editor_lod_applied_once:
		_apply_lod_to_active_instances()
		_editor_lod_applied_once = true

func _sync_editor_lod_from_camera() -> bool:
	var viewport := get_viewport()
	if viewport == null:
		return false
	var camera := viewport.get_camera_3d()
	if camera == null:
		return false
	var editor_height: float = maxf(1.0, camera.global_position.y)
	var editor_total: int = EDITOR_LOD_LEVEL_HEIGHTS.size()
	var editor_level: int = _nearest_lod_level(editor_height, EDITOR_LOD_LEVEL_HEIGHTS)
	if editor_level == _current_lod_level and editor_total == _current_total_lods and absf(editor_height - _current_lod_height) <= 0.1:
		return false
	_current_lod_height = editor_height
	_current_total_lods = editor_total
	_current_lod_level = editor_level
	return true

func _nearest_lod_level(height_value: float, levels: Array) -> int:
	if levels.is_empty():
		return 1
	var best_i: int = 0
	var best_delta: float = absf(float(levels[0]) - height_value)
	for i in range(1, levels.size()):
		var d: float = absf(float(levels[i]) - height_value)
		if d < best_delta:
			best_delta = d
			best_i = i
	return best_i + 1

func _world_to_chunk(world_x: float, world_z: float) -> Vector2i:
	var chunk_x: int = int(floor((clampf(world_x, -HALF_MAP_SIZE, HALF_MAP_SIZE) + HALF_MAP_SIZE) / _chunk_size))
	var chunk_z: int = int(floor((clampf(world_z, -HALF_MAP_SIZE, HALF_MAP_SIZE) + HALF_MAP_SIZE) / _chunk_size))
	return Vector2i(chunk_x, chunk_z)

func _load_packed_scene(path: String) -> PackedScene:
	if path.is_empty():
		return null
	if _scene_cache.has(path):
		return _scene_cache[path] as PackedScene
	var loaded: PackedScene = load(path) as PackedScene
	if loaded != null:
		_scene_cache[path] = loaded
	return loaded

func _load_override_map() -> Dictionary:
	if manual_override_path.is_empty() or not FileAccess.file_exists(manual_override_path):
		return {}
	var root: Dictionary = _json_source.load_dictionary(manual_override_path)
	if root.is_empty():
		return {}
	var out: Dictionary = {}
	var raw_sites: Variant = root.get("sites", root.get("overrides", []))
	if raw_sites is Array:
		for site_any in (raw_sites as Array):
			if not (site_any is Dictionary):
				continue
			var site: Dictionary = site_any as Dictionary
			var site_id: String = String(site.get("id", "")).strip_edges()
			if site_id.is_empty():
				continue
			out[site_id] = site.duplicate(true)
	return out

func _save_current_positions_to_override() -> void:
	if _instance_root == null:
		_ensure_instance_root()
	if _instance_root == null:
		push_warning("StrategicSiteManager has no SiteInstances root; cannot save overrides.")
		return
	var merged_override_map: Dictionary = {}
	var existing_override_map: Dictionary = _load_override_map()
	for existing_id_any in existing_override_map.keys():
		var existing_id: String = String(existing_id_any).strip_edges()
		if existing_id.is_empty():
			continue
		var existing_any: Variant = existing_override_map.get(existing_id, {})
		if not (existing_any is Dictionary):
			continue
		merged_override_map[existing_id] = (existing_any as Dictionary).duplicate(true)
	for child in _instance_root.get_children():
		if not (child is Node3D):
			continue
		var node: Node3D = child as Node3D
		var site_id: String = _extract_site_id_from_node(node)
		if site_id.is_empty():
			continue
		var merged_entry_any: Variant = merged_override_map.get(site_id, {})
		var merged_entry: Dictionary = (merged_entry_any as Dictionary).duplicate(true) if merged_entry_any is Dictionary else {}
		merged_entry["id"] = site_id
		var site_def_any: Variant = _site_defs_by_id.get(site_id, {})
		var site_def: Dictionary = site_def_any as Dictionary if site_def_any is Dictionary else {}
		merged_entry["position"] = {
			"x": int(round(node.position.x)),
			"z": int(round(_world_z_to_source_z_for_site(node.position.z, site_def)))
		}
		merged_override_map[site_id] = merged_entry
	var sites: Array[Dictionary] = []
	for site_id_any in merged_override_map.keys():
		var site_id: String = String(site_id_any).strip_edges()
		if site_id.is_empty():
			continue
		var site_any: Variant = merged_override_map.get(site_id, {})
		if not (site_any is Dictionary):
			continue
		var site_entry: Dictionary = (site_any as Dictionary).duplicate(true)
		site_entry["id"] = site_id
		sites.append(site_entry)
	sites.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a.get("id", "")) < String(b.get("id", ""))
	)
	var root: Dictionary = {
		"source": "manual_editor_adjustment",
		"input_coordinates_use_north_positive_z": input_coordinates_use_north_positive_z,
		"sites": sites
	}
	var file := FileAccess.open(manual_override_path, FileAccess.WRITE)
	if file == null:
		push_warning("Cannot write strategic manual override file: %s" % manual_override_path)
		return
	file.store_string(JSON.stringify(root, "\t"))
	print("Saved strategic site overrides: %s (%d sites)" % [manual_override_path, sites.size()])

func _validate_site(site: Dictionary) -> bool:
	if String(site.get("id", "")).strip_edges().is_empty():
		return false
	if String(site.get("name", "")).strip_edges().is_empty():
		return false
	if not (site.get("position", null) is Dictionary):
		return false
	if String(site.get("prefab_scene", "")).strip_edges().is_empty():
		return false
	return true

func _merge_dictionary(target: Dictionary, patch: Dictionary) -> void:
	for key in patch.keys():
		var patch_value: Variant = patch[key]
		if patch_value is Dictionary and target.get(key, null) is Dictionary:
			var nested: Dictionary = target[key]
			_merge_dictionary(nested, patch_value)
			target[key] = nested
		else:
			target[key] = patch_value

func _own_node_for_editor(node: Node) -> void:
	if node == null or not Engine.is_editor_hint():
		return
	var tree := get_tree()
	if tree == null:
		return
	var edited_root := tree.edited_scene_root
	if edited_root != null:
		node.owner = edited_root
func _node_has_property(node: Object, property_name: String) -> bool:
	if node == null:
		return false
	for prop_any in node.get_property_list():
		if not (prop_any is Dictionary):
			continue
		var prop: Dictionary = prop_any as Dictionary
		if String(prop.get("name", "")) == property_name:
			return true
	return false
