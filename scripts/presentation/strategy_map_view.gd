extends Node3D
class_name StrategyMapView

const MapCameraController := preload("res://scripts/presentation/map_camera_controller.gd")
const PoliticalMapOverlay := preload("res://scripts/presentation/political_map_overlay.gd")

const BUILDING_COLLISION_LAYER := 2
const GROUND_COLLISION_LAYER := 1
const TERRAIN_CELL_SIZE := 120.0
const SMALL_MAP_DEFAULT_X := 960.0
const SMALL_MAP_DEFAULT_Z := 720.0
const TERRAIN_BLEND_SHADER_PATH := "res://scripts/presentation/map_ground_blend.gdshader"
const FOG_OF_WAR_OVERLAY_SHADER_PATH := "res://scripts/presentation/fog_of_war_overlay.gdshader"
const FOG_OF_WAR_MAX_CENTERS := 96
const TERRAIN_VISUAL_DEBUG_CELLS := false

const TERRAIN_GRASS := "grass"
const TERRAIN_ROAD := "road"
const TERRAIN_FOREST := "forest"
const TERRAIN_SWAMP := "swamp"
const TERRAIN_SAND := "sand"
const TERRAIN_WATER := "water"
const TERRAIN_MOUNTAIN := "mountain"
const TERRAIN_MAX_CLIMB_SLOPE_DEFAULT_DEG := 40.0


const TERRAIN_COST := {
	TERRAIN_GRASS: 1.0,
	TERRAIN_ROAD: 0.62,
	TERRAIN_FOREST: 1.45,
	TERRAIN_SWAMP: 2.1,
	TERRAIN_SAND: 1.28
}

const TERRAIN_COLOR := {
	TERRAIN_GRASS: Color(0.33, 0.57, 0.31, 0.95),
	TERRAIN_ROAD: Color(0.63, 0.56, 0.38, 0.98),
	TERRAIN_FOREST: Color(0.16, 0.39, 0.19, 0.98),
	TERRAIN_SWAMP: Color(0.28, 0.36, 0.24, 0.98),
	TERRAIN_SAND: Color(0.69, 0.62, 0.42, 0.98),
	TERRAIN_WATER: Color(0.18, 0.43, 0.67, 0.82),
	TERRAIN_MOUNTAIN: Color(0.45, 0.43, 0.41, 0.98)
}

var _mountain_center: Vector2 = Vector2(-250.0, -120.0)
var _mountain_radius: Vector2 = Vector2(180.0, 130.0)
var _mountain_height: float = 96.0
var _archer_plateau_center: Vector2 = Vector2(22.0, 68.0)
var _archer_plateau_half_extents: Vector2 = Vector2(18.0, 14.0)
var _archer_plateau_height: float = 8.0
var _water_center: Vector2 = Vector2(120.0, 90.0)
var _water_radius: Vector2 = Vector2(170.0, 105.0)
var _swamp_center: Vector2 = Vector2(150.0, 80.0)
var _swamp_radius: Vector2 = Vector2(230.0, 145.0)
var _sand_center: Vector2 = Vector2(290.0, -190.0)
var _sand_radius: Vector2 = Vector2(170.0, 120.0)
var _forest_center: Vector2 = Vector2(-40.0, 220.0)
var _forest_radius: Vector2 = Vector2(250.0, 150.0)

var _presentation_rules: Dictionary = {}
var _font: FontFile
var _camera: Camera3D
var _latest_snapshot: Dictionary = {}

var _building_nodes: Dictionary = {}
var _building_labels: Dictionary = {}
var _buildings_by_id: Dictionary = {}
var _building_colliders: Dictionary = {}
var _building_proxy_enabled: Dictionary = {}
var _proxy_refresh_timer: Timer
var _building_marker_root: Node3D
var _building_collider_root: Node3D
var _building_label_root: Node3D
var _terrain_visual_root: Node3D
var _terrain_nav_root: Node3D
var _terrain_ground_mesh: MeshInstance3D
var _fog_of_war_overlay_mesh: MeshInstance3D
var _fog_of_war_overlay_material: ShaderMaterial
var _political_overlay: PoliticalMapOverlay
var _ground_map_size := Vector2(SMALL_MAP_DEFAULT_X, SMALL_MAP_DEFAULT_Z)
var _ground_raycast_length: float = 5000.0
var _terrain_max_climb_slope_deg: float = TERRAIN_MAX_CLIMB_SLOPE_DEFAULT_DEG
var _site_visibility_overrides: Dictionary = {}
var _supply_debug_enabled: bool = false
var _supply_debug_root: Node3D
var _supply_debug_labels: Dictionary = {}

func setup(snapshot: Dictionary, presentation_rules: Dictionary, font: FontFile) -> void:
	_latest_snapshot = snapshot.duplicate(true)
	_presentation_rules = presentation_rules
	_font = font
	_site_visibility_overrides = _extract_site_visibility_overrides(_latest_snapshot)
	_apply_map_runtime_rules()
	_build_environment()
	_build_ground(snapshot)
	_rebuild_buildings(snapshot)
	_build_camera(snapshot)
	_refresh_fog_of_war_overlay(_latest_snapshot)
	_refresh_supply_debug_overlay(_latest_snapshot)

func refresh(snapshot: Dictionary, selected_building_id: String) -> void:
	_latest_snapshot = snapshot.duplicate(true)
	_site_visibility_overrides = _extract_site_visibility_overrides(_latest_snapshot)
	var strategic_manager: Node = get_node_or_null("StrategicSites")
	var city_manager: Node = get_node_or_null("CitySites")
	var units: Array = _get_building_units(snapshot)
	if units.size() != _building_nodes.size():
		_rebuild_buildings(snapshot)
	units = _get_building_units(snapshot)

	var player_faction: String = String(snapshot.get("meta", {}).get("player_faction_id", ""))
	for unit_any in units:
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = unit_any
		var building_id: String = String(unit.get("id", ""))
		if building_id.is_empty():
			continue
		if not _building_nodes.has(building_id):
			_rebuild_buildings(snapshot)
			break

		var marker: MeshInstance3D = _building_nodes[building_id]
		var pos: Dictionary = unit.get("position", {})
		var marker_h: float = _marker_height_for_type(String(unit.get("type", "city")))
		marker.position = Vector3(float(pos.get("x", 0.0)), marker_h * 0.5, float(pos.get("z", 0.0)))
		marker.material_override = _marker_material(String(unit.get("faction_id", "")), player_faction, building_id == selected_building_id)

		if _building_labels.has(building_id):
			var label: Label3D = _building_labels[building_id]
			label.position = marker.position + Vector3(0.0, marker_h + 4.0, 0.0)
			label.text = String(unit.get("name", building_id))
	_apply_runtime_site_statuses(snapshot, city_manager, strategic_manager)
	if strategic_manager != null and strategic_manager.has_method("set_selected_site"):
		strategic_manager.call("set_selected_site", selected_building_id)
	if strategic_manager != null and strategic_manager.has_method("set_site_visibility_overrides"):
		strategic_manager.call("set_site_visibility_overrides", _site_visibility_overrides)
	if city_manager != null and city_manager.has_method("set_selected_site"):
		city_manager.call("set_selected_site", selected_building_id)
	if city_manager != null and city_manager.has_method("set_site_visibility_overrides"):
		city_manager.call("set_site_visibility_overrides", _site_visibility_overrides)
	_sync_building_proxies(false)
	_refresh_fog_of_war_overlay(snapshot)
	_refresh_supply_debug_overlay(snapshot)

func set_supply_debug_enabled(enabled: bool) -> void:
	_supply_debug_enabled = enabled
	_refresh_supply_debug_overlay(_latest_snapshot)

func pick_building_from_screen(screen_pos: Vector2) -> String:
	if _camera == null:
		return ""
	var from: Vector3 = _camera.project_ray_origin(screen_pos)
	var to: Vector3 = from + _camera.project_ray_normal(screen_pos) * _ground_raycast_length
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = BUILDING_COLLISION_LAYER
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return ""
	var collider: Object = hit.get("collider") as Object
	if collider == null:
		return ""
	if collider.has_meta("building_id"):
		var building_id: String = String(collider.get_meta("building_id"))
		if _is_site_forced_visible(building_id):
			return building_id
	return ""

func query_terrain_from_screen(screen_pos: Vector2) -> Dictionary:
	if _camera == null:
		return {}
	var from: Vector3 = _camera.project_ray_origin(screen_pos)
	var to: Vector3 = from + _camera.project_ray_normal(screen_pos) * _ground_raycast_length
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = GROUND_COLLISION_LAYER
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {}
	var world_pos: Vector3 = hit.get("position", Vector3.ZERO)
	return {
		"position": world_pos,
		"terrain_type": terrain_type_at_world(world_pos)
	}

func terrain_type_at_world(world_pos: Vector3) -> String:
	return _sample_terrain_type(world_pos, _ground_map_size.x, _ground_map_size.y)

func get_building_snapshot(building_id: String) -> Dictionary:
	if _buildings_by_id.has(building_id):
		return (_buildings_by_id[building_id] as Dictionary).duplicate(true)
	for unit_any in _latest_snapshot.get("building_units", []):
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = unit_any
		if String(unit.get("id", "")) == building_id:
			return unit.duplicate(true)
	for city_any in _latest_snapshot.get("cities", []):
		if not (city_any is Dictionary):
			continue
		var city: Dictionary = city_any
		if String(city.get("id", "")) != building_id:
			continue
		var city_classification_any: Variant = city.get("classification", {})
		var city_classification: Dictionary = (city_classification_any as Dictionary).duplicate(true) if city_classification_any is Dictionary else {}
		var city_stats_any: Variant = city.get("stats", {})
		var city_stats: Dictionary = (city_stats_any as Dictionary).duplicate(true) if city_stats_any is Dictionary else {}
		return {
			"id": String(city.get("id", "")),
			"city_id": String(city.get("id", "")),
			"name": String(city.get("name", "")),
			"faction_id": String(city.get("faction_id", "")),
			"type": "city",
			"scale": String(city_classification.get("scale", "medium")),
			"classification": city_classification,
			"position": (city.get("position", {}) as Dictionary).duplicate(true),
			"stats": city_stats,
			"defense": city_stats.get("defense", city.get("defense", -1.0)),
			"troops": city_stats.get("troops", city.get("troops", -1.0))
		}
	var city_site: Dictionary = _get_site_snapshot_from_manager("CitySites", building_id)
	if not city_site.is_empty():
		return city_site
	var strategic_site: Dictionary = _get_site_snapshot_from_manager("StrategicSites", building_id)
	if not strategic_site.is_empty():
		return strategic_site
	return {}

func get_all_site_snapshots() -> Array:
	var out: Array = []
	var seen: Dictionary = {}
	for unit_any in _get_building_units(_latest_snapshot):
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = (unit_any as Dictionary).duplicate(true)
		var building_id: String = String(unit.get("id", ""))
		if building_id.is_empty() or seen.has(building_id):
			continue
		seen[building_id] = true
		out.append(unit)
	_append_unique_sites_from_manager(out, seen, "CitySites")
	_append_unique_sites_from_manager(out, seen, "StrategicSites")
	return out

func _get_site_snapshot_from_manager(node_name: String, site_id: String) -> Dictionary:
	var manager: Node = get_node_or_null(node_name)
	if manager == null or not manager.has_method("get_site_snapshot"):
		return {}
	var snapshot_any: Variant = manager.call("get_site_snapshot", site_id)
	if not (snapshot_any is Dictionary):
		return {}
	var snapshot: Dictionary = (snapshot_any as Dictionary).duplicate(true)
	if snapshot.is_empty():
		return {}
	var normalized_id: String = String(snapshot.get("id", site_id))
	if normalized_id.is_empty():
		normalized_id = site_id
	snapshot["id"] = normalized_id
	if String(snapshot.get("city_id", "")).is_empty():
		snapshot["city_id"] = normalized_id
	if String(snapshot.get("name", "")).is_empty():
		snapshot["name"] = normalized_id
	if String(snapshot.get("type", "")).is_empty():
		snapshot["type"] = "fort"
	return snapshot

func _append_unique_sites_from_manager(out: Array, seen: Dictionary, node_name: String) -> void:
	var manager: Node = get_node_or_null(node_name)
	if manager == null or not manager.has_method("get_all_site_snapshots"):
		return
	var all_any: Variant = manager.call("get_all_site_snapshots")
	if not (all_any is Array):
		return
	for site_any in (all_any as Array):
		if not (site_any is Dictionary):
			continue
		var site: Dictionary = (site_any as Dictionary).duplicate(true)
		var site_id: String = String(site.get("id", ""))
		if site_id.is_empty() or seen.has(site_id):
			continue
		seen[site_id] = true
		out.append(site)

func _apply_runtime_site_statuses(snapshot: Dictionary, city_manager: Node, strategic_manager: Node) -> void:
	var seen_ids: Dictionary = {}
	for city_any in snapshot.get("cities", []):
		if not (city_any is Dictionary):
			continue
		var city_unit: Dictionary = _build_city_runtime_unit(city_any as Dictionary)
		var city_id: String = String(city_unit.get("id", "")).strip_edges()
		if city_id.is_empty() or seen_ids.has(city_id):
			continue
		seen_ids[city_id] = true
		_apply_runtime_site_status_to_manager(city_unit, city_manager, strategic_manager)
	for unit_any in snapshot.get("building_units", []):
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = (unit_any as Dictionary).duplicate(true)
		var site_id: String = String(unit.get("id", "")).strip_edges()
		if site_id.is_empty() or seen_ids.has(site_id):
			continue
		seen_ids[site_id] = true
		_apply_runtime_site_status_to_manager(unit, city_manager, strategic_manager)

func _build_city_runtime_unit(city: Dictionary) -> Dictionary:
	var city_stats_any: Variant = city.get("stats", {})
	var city_stats: Dictionary = (city_stats_any as Dictionary).duplicate(true) if city_stats_any is Dictionary else {}
	return {
		"id": String(city.get("id", "")),
		"type": "city",
		"stats": city_stats,
		"defense": city_stats.get("defense", city.get("defense", -1.0)),
		"troops": city_stats.get("troops", city.get("troops", -1.0))
	}

func _apply_runtime_site_status_to_manager(unit: Dictionary, city_manager: Node, strategic_manager: Node) -> void:
	var site_id: String = String(unit.get("id", "")).strip_edges()
	if site_id.is_empty():
		return
	var unit_type: String = String(unit.get("type", "city")).to_lower()
	if unit_type != "city" and unit_type != "pass" and unit_type != "fort" and unit_type != "ferry" and unit_type != "resource":
		return
	var manager: Node = city_manager if unit_type == "city" else strategic_manager
	if manager == null or not manager.has_method("apply_runtime_site_status"):
		return
	var status: Dictionary = _extract_runtime_site_status(unit)
	manager.call(
		"apply_runtime_site_status",
		site_id,
		float(status.get("defense_current", -1.0)),
		float(status.get("defense_max", -1.0)),
		float(status.get("troops", -1.0))
	)

func _extract_runtime_site_status(unit: Dictionary) -> Dictionary:
	var stats_any: Variant = unit.get("stats", {})
	var stats: Dictionary = (stats_any as Dictionary) if stats_any is Dictionary else {}
	var defense_values: Dictionary = _extract_defense_values(unit, stats)
	var troops: float = _read_runtime_number(
		unit.get(
			"troops",
			stats.get("troops", stats.get("garrison_troops", unit.get("garrison_troops", -1.0)))
		)
	)
	if troops < 0.0:
		troops = _read_runtime_number(stats.get("soldier_count", unit.get("soldier_count", -1.0)))
	if troops < 0.0:
		var reserve_troops: float = _read_runtime_number(stats.get("reserve_troops", unit.get("reserve_troops", -1.0)))
		var organized_troops: float = _read_runtime_number(stats.get("organized_troops", unit.get("organized_troops", -1.0)))
		if reserve_troops >= 0.0 or organized_troops >= 0.0:
			troops = maxf(reserve_troops, 0.0) + maxf(organized_troops, 0.0)
	return {
		"defense_current": float(defense_values.get("current", -1.0)),
		"defense_max": float(defense_values.get("max", -1.0)),
		"troops": troops
	}

func _extract_defense_values(unit: Dictionary, stats: Dictionary) -> Dictionary:
	var defense_source: Variant = unit.get("defense", stats.get("defense", -1.0))
	var defense_current: float = -1.0
	var defense_max: float = -1.0
	if defense_source is Dictionary:
		var defense_dict: Dictionary = defense_source as Dictionary
		defense_current = _read_runtime_number(
			defense_dict.get("current", defense_dict.get("value", defense_dict.get("now", -1.0)))
		)
		defense_max = _read_runtime_number(
			defense_dict.get("max", defense_dict.get("cap", defense_dict.get("limit", -1.0)))
		)
	else:
		defense_current = _read_runtime_number(defense_source)
	if defense_current < 0.0:
		defense_current = _read_runtime_number(stats.get("security", unit.get("security", -1.0)))
	if defense_max < 0.0:
		defense_max = _read_runtime_number(unit.get("defense_max", stats.get("defense_max", -1.0)))
	if defense_max < 0.0 and defense_current >= 0.0:
		defense_max = defense_current
	if defense_current < 0.0 and defense_max >= 0.0:
		defense_current = defense_max
	return {"current": defense_current, "max": defense_max}

func _read_runtime_number(value: Variant) -> float:
	if value is int or value is float:
		var numeric: float = float(value)
		return numeric if is_finite(numeric) else -1.0
	if value is Dictionary:
		var data: Dictionary = value as Dictionary
		if data.has("current"):
			return _read_runtime_number(data.get("current", -1.0))
		if data.has("value"):
			return _read_runtime_number(data.get("value", -1.0))
	return -1.0

func set_political_overlay_mode(mode: String, region_color_overrides: Dictionary = {}) -> void:
	if _political_overlay == null:
		return
	_political_overlay.set_display_mode(mode, region_color_overrides, _font)
	_update_overview_visibility()


func get_political_region_at_world(world_pos: Vector3) -> String:
	if _political_overlay == null:
		return ""
	return _political_overlay.region_id_at_world(world_pos)

func _build_environment() -> void:
	var env_node: Node = get_node_or_null("WorldEnv")
	var env: WorldEnvironment
	if env_node is WorldEnvironment:
		env = env_node as WorldEnvironment
	else:
		env = WorldEnvironment.new()
		env.name = "WorldEnv"
		add_child(env)

	var environment: Environment = env.environment
	if environment == null:
		environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.66, 0.78, 0.94)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.85, 0.85, 0.85)
	environment.ambient_light_energy = 0.7
	env.environment = environment

	var light_node: Node = get_node_or_null("SunLight")
	var light: DirectionalLight3D
	if light_node is DirectionalLight3D:
		light = light_node as DirectionalLight3D
	else:
		light = DirectionalLight3D.new()
		light.name = "SunLight"
		add_child(light)
	light.rotation_degrees = Vector3(-53.0, -30.0, 0.0)
	light.light_energy = 2.0

func _build_ground(snapshot: Dictionary) -> void:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var size: Dictionary = snapshot.get("map", {}).get("size", {})
	var src_x: float = float(size.get("x", 1200.0))
	var src_z: float = float(size.get("z", 1200.0))
	var map_x: float = minf(src_x, float(map_cfg.get("terrain_demo_size_x", SMALL_MAP_DEFAULT_X)))
	var map_z: float = minf(src_z, float(map_cfg.get("terrain_demo_size_z", SMALL_MAP_DEFAULT_Z)))
	_ground_map_size = Vector2(maxf(map_x, 320.0), maxf(map_z, 320.0))
	_ground_raycast_length = maxf(8000.0, _ground_map_size.length() * 2.2)

	_build_terrain3d_base()

	var terrain_visual_node: Node = get_node_or_null("TerrainVisuals")
	if terrain_visual_node is Node3D:
		_terrain_visual_root = terrain_visual_node as Node3D
	else:
		_terrain_visual_root = Node3D.new()
		_terrain_visual_root.name = "TerrainVisuals"
		add_child(_terrain_visual_root)
	_clear_children(_terrain_visual_root)
	_build_seamless_ground(_ground_map_size.x, _ground_map_size.y)
	_build_mountain_hills()

	var terrain_nav_node: Node = get_node_or_null("TerrainNavigation")
	if terrain_nav_node is Node3D:
		_terrain_nav_root = terrain_nav_node as Node3D
	else:
		_terrain_nav_root = Node3D.new()
		_terrain_nav_root.name = "TerrainNavigation"
		add_child(_terrain_nav_root)
	_clear_children(_terrain_nav_root)

	_build_terrain_cells(_ground_map_size.x, _ground_map_size.y)
	_build_click_ground_collider(_ground_map_size.x, _ground_map_size.y)
	_build_political_overlay()

func _build_terrain3d_base() -> void:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var enable_terrain3d: bool = bool(map_cfg.get("enable_terrain3d", false))
	if not enable_terrain3d:
		var existing_node: Node = get_node_or_null("Terrain3D")
		if existing_node != null:
			existing_node.queue_free()
		return

	var existing: Node = get_node_or_null("Terrain3D")
	if existing != null:
		if existing.is_class("Terrain3D"):
			_configure_terrain3d_node(existing)
		return

	if not ClassDB.class_exists("Terrain3D"):
		return
	var terrain: Node = ClassDB.instantiate("Terrain3D")
	if terrain == null:
		return
	terrain.name = "Terrain3D"
	_configure_terrain3d_node(terrain)
	add_child(terrain)

func _configure_terrain3d_node(terrain: Node) -> void:
	terrain.set("data_directory", "res://data/terrain/china_30km/terrain_data")
	terrain.set("mesh_size", 32)
	terrain.set("collision_enabled", false)
	terrain.set("cast_shadows", 0)
	if terrain is Node3D:
		(terrain as Node3D).visible = false

func _build_seamless_ground(map_x: float, map_z: float) -> void:
	if _terrain_visual_root == null:
		return
	var ground_mesh_node: Node = _terrain_visual_root.get_node_or_null("SeamlessGround")
	if ground_mesh_node is MeshInstance3D:
		_terrain_ground_mesh = ground_mesh_node as MeshInstance3D
	else:
		_terrain_ground_mesh = MeshInstance3D.new()
		_terrain_ground_mesh.name = "SeamlessGround"
		_terrain_visual_root.add_child(_terrain_ground_mesh)
	var plane := PlaneMesh.new()
	plane.size = Vector2(map_x, map_z)
	_terrain_ground_mesh.mesh = plane
	_terrain_ground_mesh.position = Vector3(0.0, 0.03, 0.0)

	var shader: Shader = load(TERRAIN_BLEND_SHADER_PATH)
	if shader != null:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("u_map_size_x", map_x)
		mat.set_shader_parameter("u_map_size_z", map_z)
		mat.set_shader_parameter("u_color_grass", TERRAIN_COLOR.get(TERRAIN_GRASS, Color(0.33, 0.57, 0.31, 0.95)))
		mat.set_shader_parameter("u_color_road", TERRAIN_COLOR.get(TERRAIN_ROAD, Color(0.63, 0.56, 0.38, 0.98)))
		mat.set_shader_parameter("u_color_forest", TERRAIN_COLOR.get(TERRAIN_FOREST, Color(0.16, 0.39, 0.19, 0.98)))
		mat.set_shader_parameter("u_color_swamp", TERRAIN_COLOR.get(TERRAIN_SWAMP, Color(0.28, 0.36, 0.24, 0.98)))
		mat.set_shader_parameter("u_color_sand", TERRAIN_COLOR.get(TERRAIN_SAND, Color(0.69, 0.62, 0.42, 0.98)))
		mat.set_shader_parameter("u_color_water", TERRAIN_COLOR.get(TERRAIN_WATER, Color(0.18, 0.43, 0.67, 0.82)))
		mat.set_shader_parameter("u_color_mountain", TERRAIN_COLOR.get(TERRAIN_MOUNTAIN, Color(0.45, 0.43, 0.41, 0.98)))
		_terrain_ground_mesh.material_override = mat
	else:
		var fallback := StandardMaterial3D.new()
		fallback.albedo_color = TERRAIN_COLOR.get(TERRAIN_GRASS, Color(0.33, 0.57, 0.31, 0.95))
		fallback.roughness = 0.92
		fallback.metallic = 0.02
		_terrain_ground_mesh.material_override = fallback
	_ensure_fog_of_war_overlay(map_x, map_z)

func _build_click_ground_collider(map_x: float, map_z: float) -> void:
	var body_node: Node = get_node_or_null("GroundBody")
	var body: StaticBody3D
	if body_node is StaticBody3D:
		body = body_node as StaticBody3D
	else:
		body = StaticBody3D.new()
		body.name = "GroundBody"
		add_child(body)
	body.collision_layer = GROUND_COLLISION_LAYER
	body.collision_mask = 0

	var shape_node: Node = body.get_node_or_null("GroundShape")
	var shape: CollisionShape3D
	if shape_node is CollisionShape3D:
		shape = shape_node as CollisionShape3D
	else:
		shape = CollisionShape3D.new()
		shape.name = "GroundShape"
		body.add_child(shape)

	var box: BoxShape3D
	if shape.shape is BoxShape3D:
		box = shape.shape as BoxShape3D
	else:
		box = BoxShape3D.new()
		shape.shape = box
	box.size = Vector3(map_x, 2.0, map_z)
	shape.position = Vector3(0.0, -1.0, 0.0)

func _clear_children(parent: Node) -> void:
	if parent == null:
		return
	for child in parent.get_children():
		if child is Node:
			(child as Node).queue_free()

func _ensure_building_roots() -> void:
	var marker_node: Node = get_node_or_null("BuildingMarkers")
	if marker_node is Node3D:
		_building_marker_root = marker_node as Node3D
	else:
		_building_marker_root = Node3D.new()
		_building_marker_root.name = "BuildingMarkers"
		add_child(_building_marker_root)

	var collider_node: Node = get_node_or_null("BuildingColliders")
	if collider_node is Node3D:
		_building_collider_root = collider_node as Node3D
	else:
		_building_collider_root = Node3D.new()
		_building_collider_root.name = "BuildingColliders"
		add_child(_building_collider_root)

	var label_node: Node = get_node_or_null("BuildingLabels")
	if label_node is Node3D:
		_building_label_root = label_node as Node3D
	else:
		_building_label_root = Node3D.new()
		_building_label_root.name = "BuildingLabels"
		add_child(_building_label_root)

func _rebuild_buildings(snapshot: Dictionary) -> void:
	_ensure_building_roots()
	_clear_children(_building_marker_root)
	_clear_children(_building_collider_root)
	_clear_children(_building_label_root)

	_building_nodes.clear()
	_building_labels.clear()
	_building_colliders.clear()
	_building_proxy_enabled.clear()
	_buildings_by_id.clear()

	var units: Array = _get_building_units(snapshot)
	var player_faction: String = String(snapshot.get("meta", {}).get("player_faction_id", ""))
	var label_size: int = int(_presentation_rules.get("map", {}).get("label_size", 24))
	var show_building_labels: bool = bool(_presentation_rules.get("map", {}).get("show_building_labels", false))

	for unit_any in units:
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = unit_any
		var building_id: String = String(unit.get("id", ""))
		if building_id.is_empty():
			continue
		var unit_type: String = String(unit.get("type", "city"))
		var marker_h: float = _marker_height_for_type(unit_type)
		var pos: Dictionary = unit.get("position", {})

		var marker := MeshInstance3D.new()
		marker.name = "BuildingMarker_%s" % building_id
		marker.mesh = _marker_mesh_for_type(unit_type)
		marker.position = Vector3(float(pos.get("x", 0.0)), marker_h * 0.5, float(pos.get("z", 0.0)))
		marker.material_override = _marker_material(String(unit.get("faction_id", "")), player_faction, false)
		_building_marker_root.add_child(marker)

		var collider := StaticBody3D.new()
		collider.name = "BuildingCollider_%s" % building_id
		collider.collision_layer = BUILDING_COLLISION_LAYER
		collider.collision_mask = 0
		collider.position = marker.position
		collider.set_meta("building_id", building_id)
		_building_collider_root.add_child(collider)
		var collision_shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = _marker_radius_for_type(unit_type)
		collision_shape.shape = sphere
		collider.add_child(collision_shape)

		var label: Label3D = null
		if show_building_labels:
			label = Label3D.new()
			label.name = "BuildingLabel_%s" % building_id
			label.font = _font
			label.font_size = label_size
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.no_depth_test = true
			label.position = marker.position + Vector3(0.0, marker_h + 4.0, 0.0)
			label.text = String(unit.get("name", building_id))
			_building_label_root.add_child(label)

		_building_nodes[building_id] = marker
		_building_colliders[building_id] = collider
		if label != null:
			_building_labels[building_id] = label
		_buildings_by_id[building_id] = unit.duplicate(true)
		_building_proxy_enabled[building_id] = true

	_sync_building_proxies(true)
	_ensure_proxy_refresh_timer()

func _ensure_proxy_refresh_timer() -> void:
	if Engine.is_editor_hint():
		return
	var existing: Node = get_node_or_null("ProxyRefreshTimer")
	if existing is Timer:
		_proxy_refresh_timer = existing as Timer
	else:
		_proxy_refresh_timer = Timer.new()
		_proxy_refresh_timer.name = "ProxyRefreshTimer"
		_proxy_refresh_timer.one_shot = false
		_proxy_refresh_timer.autostart = true
		add_child(_proxy_refresh_timer)
	_proxy_refresh_timer.wait_time = 0.6
	if not _proxy_refresh_timer.timeout.is_connected(_on_proxy_refresh_timer_timeout):
		_proxy_refresh_timer.timeout.connect(_on_proxy_refresh_timer_timeout)
	_proxy_refresh_timer.start()

func _on_proxy_refresh_timer_timeout() -> void:
	_sync_building_proxies(false)

func _sync_building_proxies(force: bool) -> void:
	if _building_nodes.is_empty():
		return
	var city_manager: Node = get_node_or_null("CitySites")
	var strategic_manager: Node = get_node_or_null("StrategicSites")
	var has_city: bool = city_manager != null and city_manager.has_method("has_active_site")
	var has_strategic: bool = strategic_manager != null and strategic_manager.has_method("has_active_site")
	if not has_city and not has_strategic:
		return
	for building_id in _building_nodes.keys():
		var active: bool = false
		if has_city and bool(city_manager.call("has_active_site", building_id)):
			active = true
		elif has_strategic and bool(strategic_manager.call("has_active_site", building_id)):
			active = true
		var forced_visible: bool = _is_site_forced_visible(String(building_id))
		var proxy_enabled: bool = not active and forced_visible
		var prev_state_any: Variant = _building_proxy_enabled.get(building_id, null)
		if not force and prev_state_any is bool and prev_state_any == proxy_enabled:
			continue
		_building_proxy_enabled[building_id] = proxy_enabled
		var marker: Node3D = _building_nodes.get(building_id)
		if marker != null and is_instance_valid(marker):
			marker.visible = proxy_enabled
		var collider: StaticBody3D = _building_colliders.get(building_id)
		if collider != null and is_instance_valid(collider):
			collider.collision_layer = BUILDING_COLLISION_LAYER if proxy_enabled else 0
			collider.input_ray_pickable = proxy_enabled
		var label: Label3D = _building_labels.get(building_id)
		if label != null and is_instance_valid(label):
			label.visible = proxy_enabled

func _extract_site_visibility_overrides(snapshot: Dictionary) -> Dictionary:
	var supply_fog_any: Variant = snapshot.get("supply_fog", {})
	if supply_fog_any is Dictionary:
		var vis_any: Variant = (supply_fog_any as Dictionary).get("site_visible", {})
		if vis_any is Dictionary:
			return (vis_any as Dictionary).duplicate(true)
	return {}

func _is_site_forced_visible(building_id: String) -> bool:
	if building_id.is_empty():
		return true
	if not _site_visibility_overrides.has(building_id):
		return true
	return bool(_site_visibility_overrides.get(building_id, true))

func _ensure_fog_of_war_overlay(map_x: float, map_z: float) -> void:
	if _terrain_visual_root == null:
		return
	var existing: Node = _terrain_visual_root.get_node_or_null("FogOfWarOverlay")
	if existing is MeshInstance3D:
		_fog_of_war_overlay_mesh = existing as MeshInstance3D
	else:
		_fog_of_war_overlay_mesh = MeshInstance3D.new()
		_fog_of_war_overlay_mesh.name = "FogOfWarOverlay"
		_terrain_visual_root.add_child(_fog_of_war_overlay_mesh)
	var plane := PlaneMesh.new()
	plane.size = Vector2(map_x, map_z)
	_fog_of_war_overlay_mesh.mesh = plane
	_fog_of_war_overlay_mesh.position = Vector3(0.0, 0.11, 0.0)
	_fog_of_war_overlay_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var shader: Shader = load(FOG_OF_WAR_OVERLAY_SHADER_PATH)
	if shader != null:
		if _fog_of_war_overlay_material == null:
			_fog_of_war_overlay_material = ShaderMaterial.new()
		_fog_of_war_overlay_material.shader = shader
		_fog_of_war_overlay_material.set_shader_parameter("u_map_size_x", map_x)
		_fog_of_war_overlay_material.set_shader_parameter("u_map_size_z", map_z)
		_fog_of_war_overlay_material.set_shader_parameter("u_dark_alpha", 0.52)
		_fog_of_war_overlay_mesh.material_override = _fog_of_war_overlay_material
	else:
		var fallback := StandardMaterial3D.new()
		fallback.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fallback.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fallback.albedo_color = Color(0.02, 0.02, 0.02, 0.38)
		_fog_of_war_overlay_mesh.material_override = fallback
		_fog_of_war_overlay_material = null
	_fog_of_war_overlay_mesh.visible = false

func _refresh_fog_of_war_overlay(snapshot: Dictionary) -> void:
	if _fog_of_war_overlay_mesh == null or not is_instance_valid(_fog_of_war_overlay_mesh):
		return
	var supply_fog_any: Variant = snapshot.get("supply_fog", {})
	var supply_fog: Dictionary = supply_fog_any as Dictionary if supply_fog_any is Dictionary else {}
	var enabled: bool = bool(supply_fog.get("enabled", false))
	_fog_of_war_overlay_mesh.visible = enabled
	if not enabled or _fog_of_war_overlay_material == null:
		return
	var reveal_any: Variant = supply_fog.get("reveal_centers", [])
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
	_fog_of_war_overlay_material.set_shader_parameter("u_center_count", center_count)
	_fog_of_war_overlay_material.set_shader_parameter("u_centers", packed)
	var vision_ctx_any: Variant = supply_fog.get("vision_context", {})
	var vision_ctx: Dictionary = vision_ctx_any as Dictionary if vision_ctx_any is Dictionary else {}
	var day_phase: String = String(vision_ctx.get("day_phase", "day")).to_lower()
	var is_night: bool = day_phase == "night"
	_fog_of_war_overlay_material.set_shader_parameter("u_dark_alpha", 0.5 if not is_night else 0.64)
	_fog_of_war_overlay_material.set_shader_parameter("u_ring_strength", 0.17 if not is_night else 0.23)
	_fog_of_war_overlay_material.set_shader_parameter("u_ring_width", 18.0 if not is_night else 24.0)

func _ensure_supply_debug_root() -> void:
	var node: Node = get_node_or_null("SupplyDebugLabels")
	if node is Node3D:
		_supply_debug_root = node as Node3D
		return
	_supply_debug_root = Node3D.new()
	_supply_debug_root.name = "SupplyDebugLabels"
	add_child(_supply_debug_root)

func _refresh_supply_debug_overlay(snapshot: Dictionary) -> void:
	_ensure_supply_debug_root()
	if _supply_debug_root == null:
		return
	_supply_debug_root.visible = _supply_debug_enabled
	if not _supply_debug_enabled:
		return
	var supply_fog: Dictionary = snapshot.get("supply_fog", {})
	var site_visible: Dictionary = supply_fog.get("site_visible", {}) if supply_fog.get("site_visible", {}) is Dictionary else {}
	var in_supply_ids: Dictionary = {}
	var in_supply_any: Variant = supply_fog.get("in_supply_site_ids", [])
	if in_supply_any is Array:
		for id_any in (in_supply_any as Array):
			in_supply_ids[str(id_any)] = true
	var player_faction: String = String(snapshot.get("meta", {}).get("player_faction_id", ""))
	var alive: Dictionary = {}
	for unit_any in _get_building_units(snapshot):
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = unit_any
		var site_id: String = String(unit.get("id", ""))
		if site_id.is_empty():
			continue
		alive[site_id] = true
		var label: Label3D = _supply_debug_labels.get(site_id) as Label3D
		if label == null or not is_instance_valid(label):
			label = Label3D.new()
			label.name = "SupplyDebug_%s" % site_id
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.no_depth_test = true
			label.fixed_size = true
			label.pixel_size = 0.02
			label.outline_size = 3
			label.outline_modulate = Color(0.0, 0.0, 0.0, 0.85)
			label.font = _font
			_supply_debug_root.add_child(label)
			_supply_debug_labels[site_id] = label
		var pos_any: Variant = unit.get("position", {})
		var pos: Dictionary = (pos_any as Dictionary).duplicate(true) if pos_any is Dictionary else {}
		var type_key: String = String(unit.get("type", "site"))
		var y: float = _marker_height_for_type(type_key) + 18.0
		label.position = Vector3(float(pos.get("x", 0.0)), y, float(pos.get("z", 0.0)))
		var faction_id: String = String(unit.get("faction_id", ""))
		var faction_flag: String = "P" if faction_id == player_faction else "E"
		var in_supply: bool = in_supply_ids.has(site_id)
		var visible_now: bool = bool(site_visible.get(site_id, true))
		var fog_text: String = "show" if visible_now else "hide"
		var line_text: String = "on" if in_supply else "off"
		label.text = "%s [%s]\nline:%s fog:%s" % [site_id, faction_flag, line_text, fog_text]
		label.modulate = Color(0.75, 1.0, 0.75, 1.0) if visible_now else Color(1.0, 0.52, 0.52, 1.0)
	for site_id_any in _supply_debug_labels.keys():
		var site_id: String = String(site_id_any)
		if alive.has(site_id):
			continue
		var stale: Label3D = _supply_debug_labels.get(site_id) as Label3D
		if stale != null and is_instance_valid(stale):
			stale.queue_free()
		_supply_debug_labels.erase(site_id)

func _build_camera(snapshot: Dictionary) -> void:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var camera_cfg: Dictionary = map_cfg.get("camera", {})
	var map_size := {
		"x": _ground_map_size.x,
		"z": _ground_map_size.y
	}

	var camera_node: Node = get_node_or_null("MapCamera")
	if camera_node is Camera3D:
		_camera = camera_node as Camera3D
	else:
		_camera = Camera3D.new()
		_camera.name = "MapCamera"
		add_child(_camera)

	if _camera.get_script() != MapCameraController:
		_camera.set_script(MapCameraController)
	_camera.current = true
	_camera.fov = 58.0
	if _camera.has_signal("zoom_lod_changed"):
		var zoom_cb := Callable(self, "_on_camera_zoom_lod_changed")
		if not _camera.is_connected("zoom_lod_changed", zoom_cb):
			_camera.connect("zoom_lod_changed", zoom_cb)
	_camera.call("configure", camera_cfg, map_size)
	_on_camera_zoom_lod_changed(int(_camera.call("get_current_lod_level")), int(_camera.call("get_total_lod_levels")), float(_camera.call("get_current_target_height")))


func _build_political_overlay() -> void:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var enabled: bool = bool(map_cfg.get("political_overview_enabled", true))
	if not enabled:
		var existing: Node = get_node_or_null("PoliticalOverlay")
		if existing != null:
			existing.queue_free()
		_political_overlay = null
		return

	var overlay_node: Node = get_node_or_null("PoliticalOverlay")
	if overlay_node is PoliticalMapOverlay:
		_political_overlay = overlay_node as PoliticalMapOverlay
	else:
		_political_overlay = PoliticalMapOverlay.new()
		_political_overlay.name = "PoliticalOverlay"
		add_child(_political_overlay)
	_political_overlay.setup(_ground_map_size, map_cfg, _font)
	_political_overlay.visible = false


func _on_camera_zoom_lod_changed(level: int, total_levels: int, _height: float) -> void:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var overview_lod_level: int = int(map_cfg.get("political_overview_lod_level", total_levels))
	var enable_overview: bool = level >= overview_lod_level and total_levels > 0
	if _camera != null and _camera.has_method("set_overview_mode"):
		_camera.call("set_overview_mode", enable_overview, enable_overview)
	_set_overview_layer_state(enable_overview)


func _update_overview_visibility() -> void:
	if _camera == null or not _camera.has_method("get_current_lod_level"):
		return
	_on_camera_zoom_lod_changed(int(_camera.call("get_current_lod_level")), int(_camera.call("get_total_lod_levels")), float(_camera.call("get_current_target_height")))


func _set_overview_layer_state(enabled: bool) -> void:
	if _political_overlay != null:
		var active_mode: String = _political_overlay.get_display_mode()
		_political_overlay.visible = enabled and active_mode != "hidden"
	if _terrain_visual_root != null:
		_terrain_visual_root.visible = not enabled
	if _terrain_nav_root != null:
		_terrain_nav_root.visible = not enabled
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var terrain3d_should_show: bool = not enabled and bool(map_cfg.get("enable_terrain3d", false))
	var terrain3d_node: Node = get_node_or_null("Terrain3D")
	if terrain3d_node is Node3D:
		(terrain3d_node as Node3D).visible = terrain3d_should_show

func _build_terrain_cells(map_x: float, map_z: float) -> void:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var nav_max_cells: int = maxi(256, int(map_cfg.get("terrain_nav_max_cells", 2800)))
	var nav_min_cell_size: float = maxf(40.0, float(map_cfg.get("terrain_nav_min_cell_size", TERRAIN_CELL_SIZE)))
	var map_area: float = maxf(1.0, map_x * map_z)
	var cell_size: float = maxf(nav_min_cell_size, sqrt(map_area / float(nav_max_cells)))
	var x_count: int = maxi(2, int(ceil(map_x / cell_size)))
	var z_count: int = maxi(2, int(ceil(map_z / cell_size)))
	while x_count * z_count > nav_max_cells:
		cell_size *= 1.08
		x_count = maxi(2, int(ceil(map_x / cell_size)))
		z_count = maxi(2, int(ceil(map_z / cell_size)))

	var origin_x := -float(x_count) * cell_size * 0.5 + cell_size * 0.5
	var origin_z := -float(z_count) * cell_size * 0.5 + cell_size * 0.5

	for z in z_count:
		for x in x_count:
			var center := Vector3(origin_x + float(x) * cell_size, 0.0, origin_z + float(z) * cell_size)
			var terrain_type := _sample_terrain_type(center, map_x, map_z)
			center.y = _ground_height_at_world(center)
			if TERRAIN_VISUAL_DEBUG_CELLS:
				_add_terrain_visual_rect(center, cell_size - 2.0, cell_size - 2.0, terrain_type)
			if _is_nav_cell_walkable(center, cell_size * 0.5, map_x, map_z):
				_add_terrain_nav_region(center, cell_size, cell_size, float(TERRAIN_COST.get(terrain_type, 1.0)))

func _sample_terrain_type(pos: Vector3, map_x: float, map_z: float) -> String:
	var road_h := absf(pos.z + 24.0) <= 18.0 and absf(pos.x) <= map_x * 0.46
	var road_v := absf(pos.x - 72.0) <= 16.0 and absf(pos.z) <= map_z * 0.45
	if road_h or road_v:
		return TERRAIN_ROAD

	if _in_ellipse(pos, _mountain_center, _mountain_radius):
		return TERRAIN_MOUNTAIN
	if _in_ellipse(pos, _water_center, _water_radius):
		return TERRAIN_WATER
	if _in_ellipse(pos, _swamp_center, _swamp_radius):
		return TERRAIN_SWAMP
	if _in_ellipse(pos, _sand_center, _sand_radius):
		return TERRAIN_SAND
	if _in_ellipse(pos, _forest_center, _forest_radius):
		return TERRAIN_FOREST
	return TERRAIN_GRASS

func _in_ellipse(pos: Vector3, center: Vector2, radius: Vector2) -> bool:
	var rx := maxf(radius.x, 0.001)
	var rz := maxf(radius.y, 0.001)
	var nx := (pos.x - center.x) / rx
	var nz := (pos.z - center.y) / rz
	return nx * nx + nz * nz <= 1.0

func _is_walkable_terrain(terrain_type: String, world_pos: Vector3 = Vector3.ZERO) -> bool:
	if terrain_type == TERRAIN_WATER:
		return false
	if terrain_type == TERRAIN_MOUNTAIN:
		return _terrain_slope_deg_at_world(world_pos) <= _terrain_max_climb_slope_deg
	return true

func _is_nav_cell_walkable(cell_center: Vector3, half_extent: float, map_x: float, map_z: float) -> bool:
	var probe: float = clampf(half_extent * 0.45, 12.0, maxf(12.0, half_extent))
	var samples: Array[Vector3] = [
		cell_center,
		cell_center + Vector3(probe, 0.0, 0.0),
		cell_center + Vector3(-probe, 0.0, 0.0),
		cell_center + Vector3(0.0, 0.0, probe),
		cell_center + Vector3(0.0, 0.0, -probe),
		cell_center + Vector3(probe, 0.0, probe),
		cell_center + Vector3(probe, 0.0, -probe),
		cell_center + Vector3(-probe, 0.0, probe),
		cell_center + Vector3(-probe, 0.0, -probe)
	]
	for i in range(samples.size()):
		var sample := samples[i]
		sample.x = clampf(sample.x, -map_x * 0.5, map_x * 0.5)
		sample.z = clampf(sample.z, -map_z * 0.5, map_z * 0.5)
		sample.y = _ground_height_at_world(sample)
		var terrain_type := _sample_terrain_type(sample, map_x, map_z)
		if not _is_walkable_terrain(terrain_type, sample):
			return false
	return true

func _apply_map_runtime_rules() -> void:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	_terrain_max_climb_slope_deg = clampf(
		float(map_cfg.get("terrain_max_climb_slope_deg", TERRAIN_MAX_CLIMB_SLOPE_DEFAULT_DEG)),
		1.0,
		89.0
	)
	_apply_terrain_rules(map_cfg)

func _read_vec2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Array:
		var arr: Array = value
		if arr.size() >= 2:
			return Vector2(float(arr[0]), float(arr[1]))
	return fallback

func _apply_terrain_rules(map_cfg: Dictionary) -> void:
	var terrain_cfg: Dictionary = map_cfg.get("terrain_rules", {})
	var mountain_cfg: Dictionary = terrain_cfg.get("mountain", {})
	var plateau_cfg: Dictionary = terrain_cfg.get("archer_plateau", {})
	var water_cfg: Dictionary = terrain_cfg.get("water", {})
	var swamp_cfg: Dictionary = terrain_cfg.get("swamp", {})
	var sand_cfg: Dictionary = terrain_cfg.get("sand", {})
	var forest_cfg: Dictionary = terrain_cfg.get("forest", {})

	_mountain_center = _read_vec2(mountain_cfg.get("center", null), _mountain_center)
	_mountain_radius = _read_vec2(mountain_cfg.get("radius", null), _mountain_radius)
	_mountain_height = float(mountain_cfg.get("height", _mountain_height))

	_archer_plateau_center = _read_vec2(plateau_cfg.get("center", null), _archer_plateau_center)
	_archer_plateau_half_extents = _read_vec2(plateau_cfg.get("half_extents", null), _archer_plateau_half_extents)
	_archer_plateau_height = float(plateau_cfg.get("height", _archer_plateau_height))

	_water_center = _read_vec2(water_cfg.get("center", null), _water_center)
	_water_radius = _read_vec2(water_cfg.get("radius", null), _water_radius)
	_swamp_center = _read_vec2(swamp_cfg.get("center", null), _swamp_center)
	_swamp_radius = _read_vec2(swamp_cfg.get("radius", null), _swamp_radius)
	_sand_center = _read_vec2(sand_cfg.get("center", null), _sand_center)
	_sand_radius = _read_vec2(sand_cfg.get("radius", null), _sand_radius)
	_forest_center = _read_vec2(forest_cfg.get("center", null), _forest_center)
	_forest_radius = _read_vec2(forest_cfg.get("radius", null), _forest_radius)

func _add_terrain_visual_rect(center: Vector3, size_x: float, size_z: float, terrain_type: String) -> void:
	if _terrain_visual_root == null:
		return
	var visual := MeshInstance3D.new()
	visual.name = "Terrain_%s" % terrain_type

	if terrain_type == TERRAIN_MOUNTAIN:
		var box := BoxMesh.new()
		box.size = Vector3(size_x * 0.86, 36.0, size_z * 0.86)
		visual.mesh = box
		visual.position = center + Vector3(0.0, 18.0, 0.0)
	else:
		var plane := PlaneMesh.new()
		plane.size = Vector2(size_x, size_z)
		visual.mesh = plane
		var y := 0.05
		if terrain_type == TERRAIN_WATER:
			y = 0.12
		visual.position = center + Vector3(0.0, y, 0.0)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = TERRAIN_COLOR.get(terrain_type, Color(0.35, 0.55, 0.35, 0.95))
	mat.roughness = 0.92
	mat.metallic = 0.02
	if terrain_type == TERRAIN_WATER:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.roughness = 0.1
		mat.metallic = 0.05
	visual.material_override = mat
	_terrain_visual_root.add_child(visual)

func _add_terrain_nav_region(center: Vector3, size_x: float, size_z: float, travel_cost: float) -> void:
	if _terrain_nav_root == null:
		return
	var region := NavigationRegion3D.new()
	region.name = "NavCell"
	region.position = center + Vector3(0.0, 0.02, 0.0)
	region.enter_cost = 0.0
	region.travel_cost = maxf(travel_cost, 0.01)
	region.navigation_layers = 1
	region.navigation_mesh = _make_rect_nav_mesh(center, size_x * 0.5, size_z * 0.5)
	_terrain_nav_root.add_child(region)

func _make_rect_nav_mesh(center: Vector3, half_x: float, half_z: float) -> NavigationMesh:
	var center_h := _ground_height_at_world(center)
	var nav_mesh := NavigationMesh.new()
	var vertices := PackedVector3Array([
		_nav_vertex_local(center, center_h, -half_x, -half_z),
		_nav_vertex_local(center, center_h, half_x, -half_z),
		_nav_vertex_local(center, center_h, half_x, half_z),
		_nav_vertex_local(center, center_h, -half_x, half_z)
	])
	nav_mesh.set_vertices(vertices)
	nav_mesh.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	return nav_mesh

func _nav_vertex_local(center: Vector3, center_h: float, ox: float, oz: float) -> Vector3:
	var world := Vector3(center.x + ox, 0.0, center.z + oz)
	var h := _ground_height_at_world(world)
	return Vector3(ox, h - center_h, oz)

func _ground_height_at_world(world_pos: Vector3) -> float:
	var p := Vector2(world_pos.x, world_pos.z)
	return maxf(_mountain_height_at_2d(p), _test_archer_plateau_height_at_2d(p))

func _mountain_height_at_2d(p: Vector2) -> float:
	var n := Vector2(
		(p.x - _mountain_center.x) / maxf(_mountain_radius.x, 0.001),
		(p.y - _mountain_center.y) / maxf(_mountain_radius.y, 0.001)
	)
	var r := sqrt(n.x * n.x + n.y * n.y)
	if r >= 1.0:
		return 0.0
	var profile := 1.0 - r
	return _mountain_height * profile

func _test_archer_plateau_height_at_2d(p: Vector2) -> float:
	var dx := absf(p.x - _archer_plateau_center.x)
	var dz := absf(p.y - _archer_plateau_center.y)
	if dx <= _archer_plateau_half_extents.x and dz <= _archer_plateau_half_extents.y:
		return _archer_plateau_height
	return 0.0

func _terrain_slope_deg_at_world(world_pos: Vector3) -> float:
	var eps: float = 8.0
	var hx1 := _ground_height_at_world(world_pos + Vector3(eps, 0.0, 0.0))
	var hx2 := _ground_height_at_world(world_pos - Vector3(eps, 0.0, 0.0))
	var hz1 := _ground_height_at_world(world_pos + Vector3(0.0, 0.0, eps))
	var hz2 := _ground_height_at_world(world_pos - Vector3(0.0, 0.0, eps))
	var dx := (hx1 - hx2) / (2.0 * eps)
	var dz := (hz1 - hz2) / (2.0 * eps)
	var grad := sqrt(dx * dx + dz * dz)
	return rad_to_deg(atan(grad))

func can_unit_walk_at_world(world_pos: Vector3) -> bool:
	var terrain_type := terrain_type_at_world(world_pos)
	return _is_walkable_terrain(terrain_type, world_pos)

func terrain_slope_deg_at_world(world_pos: Vector3) -> float:
	return _terrain_slope_deg_at_world(world_pos)

func terrain_height_at_world(world_pos: Vector3) -> float:
	return _ground_height_at_world(world_pos)

func get_team_retreat_points(is_player_team: bool) -> Array[Vector3]:
	var out: Array[Vector3] = []
	var snapshot: Dictionary = _latest_snapshot
	if snapshot.is_empty():
		return out
	var units: Array = _get_building_units(snapshot)
	var player_faction: String = String(snapshot.get("meta", {}).get("player_faction_id", ""))
	for unit_any in units:
		if not (unit_any is Dictionary):
			continue
		var unit: Dictionary = unit_any
		var faction_id: String = String(unit.get("faction_id", ""))
		if faction_id.is_empty():
			continue
		var is_player_faction: bool = faction_id == player_faction
		if is_player_team and not is_player_faction:
			continue
		if (not is_player_team) and is_player_faction:
			continue
		var pos: Dictionary = unit.get("position", {})
		var world_pos := Vector3(float(pos.get("x", 0.0)), 0.0, float(pos.get("z", 0.0)))
		out.append(world_pos)
	return out

func _build_mountain_hills() -> void:
	if _terrain_visual_root == null:
		return
	var hill := MeshInstance3D.new()
	hill.name = "MountainHill_Main"
	var cone := CylinderMesh.new()
	cone.top_radius = 0.01
	cone.bottom_radius = 1.0
	cone.height = 1.0
	cone.radial_segments = 28
	cone.rings = 6
	hill.mesh = cone
	hill.position = Vector3(_mountain_center.x, _mountain_height * 0.5 + 0.08, _mountain_center.y)
	hill.scale = Vector3(_mountain_radius.x, _mountain_height, _mountain_radius.y)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = TERRAIN_COLOR.get(TERRAIN_MOUNTAIN, Color(0.45, 0.43, 0.41, 0.98))
	mat.roughness = 0.95
	mat.metallic = 0.01
	hill.material_override = mat
	_terrain_visual_root.add_child(hill)

	var plateau := MeshInstance3D.new()
	plateau.name = "ArcherTestPlateau"
	var plateau_mesh := BoxMesh.new()
	plateau_mesh.size = Vector3(_archer_plateau_half_extents.x * 2.0, _archer_plateau_height, _archer_plateau_half_extents.y * 2.0)
	plateau.mesh = plateau_mesh
	plateau.position = Vector3(_archer_plateau_center.x, _archer_plateau_height * 0.5 + 0.04, _archer_plateau_center.y)
	var plateau_mat := StandardMaterial3D.new()
	plateau_mat.albedo_color = Color(0.58, 0.50, 0.36, 0.98)
	plateau_mat.roughness = 0.97
	plateau_mat.metallic = 0.0
	plateau.material_override = plateau_mat
	_terrain_visual_root.add_child(plateau)

	var plateau_body := StaticBody3D.new()
	plateau_body.name = "ArcherTestPlateauBody"
	plateau_body.collision_layer = GROUND_COLLISION_LAYER
	plateau_body.collision_mask = 0
	plateau_body.position = plateau.position
	var plateau_shape := CollisionShape3D.new()
	var plateau_box := BoxShape3D.new()
	plateau_box.size = plateau_mesh.size
	plateau_shape.shape = plateau_box
	plateau_body.add_child(plateau_shape)
	add_child(plateau_body)


func _get_building_units(snapshot: Dictionary) -> Array:
	if snapshot.has("building_units"):
		var direct: Array = snapshot.get("building_units", [])
		if not direct.is_empty():
			var out_copy: Array = []
			for unit_any in direct:
				if unit_any is Dictionary:
					var unit: Dictionary = (unit_any as Dictionary).duplicate(true)
					if not _should_render_building_marker(String(unit.get("type", "city"))):
						continue
					out_copy.append(unit)
			return out_copy

	var out: Array = []
	for city_any in snapshot.get("cities", []):
		if not (city_any is Dictionary):
			continue
		var city: Dictionary = city_any
		var city_classification_any: Variant = city.get("classification", {})
		var city_classification: Dictionary = (city_classification_any as Dictionary).duplicate(true) if city_classification_any is Dictionary else {}
		var city_stats_any: Variant = city.get("stats", {})
		var city_stats: Dictionary = (city_stats_any as Dictionary).duplicate(true) if city_stats_any is Dictionary else {}
		out.append({
			"id": String(city.get("id", "")),
			"city_id": String(city.get("id", "")),
			"name": String(city.get("name", "")),
			"faction_id": String(city.get("faction_id", "")),
			"type": "city",
			"scale": String(city_classification.get("scale", "medium")),
			"classification": city_classification,
			"position": city.get("position", {}).duplicate(true),
			"stats": city_stats,
			"defense": city_stats.get("defense", city.get("defense", -1.0)),
			"troops": city_stats.get("troops", city.get("troops", -1.0))
		})
	return out

func _should_render_building_marker(unit_type: String) -> bool:
	match unit_type:
		"city":
			return get_node_or_null("CitySites") == null
		"pass", "fort", "ferry":
			return get_node_or_null("StrategicSites") == null
		_:
			return true

func _marker_mesh_for_type(unit_type: String) -> Mesh:
	match unit_type:
		"pass":
			var box := BoxMesh.new()
			box.size = Vector3(18.0, _marker_height_for_type(unit_type), 14.0)
			return box
		"fort":
			var box2 := BoxMesh.new()
			box2.size = Vector3(14.0, _marker_height_for_type(unit_type), 14.0)
			return box2
		"ferry":
			var cyl_small := CylinderMesh.new()
			cyl_small.top_radius = _marker_radius_for_type(unit_type)
			cyl_small.bottom_radius = _marker_radius_for_type(unit_type)
			cyl_small.height = _marker_height_for_type(unit_type)
			return cyl_small
		_:
			var cyl := CylinderMesh.new()
			cyl.top_radius = _marker_radius_for_type(unit_type)
			cyl.bottom_radius = _marker_radius_for_type(unit_type)
			cyl.height = _marker_height_for_type(unit_type)
			return cyl

func _marker_radius_for_type(unit_type: String) -> float:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var base_r: float = float(map_cfg.get("city_marker_radius", 11.0))
	match unit_type:
		"pass":
			return base_r * 0.9
		"fort":
			return base_r * 0.75
		"ferry":
			return base_r * 0.6
		"resource":
			return base_r * 0.55
		_:
			return base_r

func _marker_height_for_type(unit_type: String) -> float:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var base_h: float = float(map_cfg.get("city_marker_height", 12.0))
	match unit_type:
		"pass":
			return base_h * 1.15
		"fort":
			return base_h * 0.9
		"ferry":
			return base_h * 0.75
		"resource":
			return base_h * 0.7
		_:
			return base_h

func _marker_material(faction_id: String, player_faction: String, is_selected: bool) -> StandardMaterial3D:
	var map_cfg: Dictionary = _presentation_rules.get("map", {})
	var material := StandardMaterial3D.new()
	if is_selected:
		material.albedo_color = _array_to_color(map_cfg.get("city_selected_color", [0.95, 0.8, 0.2]))
	elif faction_id == player_faction:
		material.albedo_color = _array_to_color(map_cfg.get("city_friend_color", [0.9, 0.3, 0.2]))
	else:
		material.albedo_color = _array_to_color(map_cfg.get("city_enemy_color", [0.2, 0.4, 0.9]))
	material.roughness = 0.5
	material.metallic = 0.15
	return material

func _array_to_color(arr: Array) -> Color:
	if arr.size() < 3:
		return Color.WHITE
	return Color(float(arr[0]), float(arr[1]), float(arr[2]), 1.0)
