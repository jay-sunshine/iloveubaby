@tool
extends Node3D
class_name ChinaCityOverlay

const EXACT_CITY_DATA_PATH := "res://data/config/three_kingdoms_14_cities_exact_positions.json"
const MANUAL_OVERRIDE_PATH := "res://data/config/three_kingdoms_14_cities_manual_overrides.json"
const FALLBACK_CITY_DATA_PATH := "res://data/config/san14_main_cities_actual_coordinates.json"
const CITY_INSTANCE_SCENE := preload("res://scenes/prefabs/china_city_instance.tscn")
const EDITOR_LOD_LEVEL_HEIGHTS := [160.0, 420.0, 1400.0, 4200.0, 12000.0, 26000.0]
const EDITOR_LOD_REFRESH_INTERVAL := 0.2
const LUOYANG_NAME := "\u6d1b\u9633"
const ASSET_ROOT := "res://\u7d20\u6750"
const BUILDING_MODEL_DIR := ASSET_ROOT + "/\u5efa\u6a21/\u5efa\u7b51\u5355\u4f4d"
const LUOYANG_MODEL_PATH := BUILDING_MODEL_DIR + "/luoyang_ct30_low_2k.glb"
const DEFAULT_CITY_MODEL_PATH := "res://scenes/prefabs/models/chengchi_ct30_low_2k_retex_ground_fixed.tscn"
const DEFAULT_MAJOR_CITY_NAME_LIST := [
	"\u6d1b\u9633",
	"\u957f\u5b89",
	"\u6210\u90fd",
	"\u5efa\u4e1a",
	"\u8bb8\u660c",
	"\u90ba",
	"\u8944\u9633"
]

@export var auto_rebuild_overlay: bool = false
@export var rebuild_overlay_now: bool = false:
	set(value):
		if value:
			rebuild_overlay_now = false
			call_deferred("_rebuild_overlay")
@export var save_current_positions_now: bool = false:
	set(value):
		if value:
			save_current_positions_now = false
			call_deferred("_save_current_positions_to_override")
@export var refresh_city_heights_now: bool = false:
	set(value):
		if value:
			refresh_city_heights_now = false
			call_deferred("_refresh_current_city_heights")
@export var prefer_manual_overrides: bool = true
@export var lock_to_manual_overrides: bool = true
@export var editor_current_positions_authoritative: bool = true
@export var editor_force_lod_level: int = 3
@export var show_editor_markers: bool = false
@export var editor_marker_scale: float = 3.0
@export var default_city_scale: float = 220.0
@export var luoyang_scale: float = 280.0
@export var city_height_offset: float = 6.0
@export var world_offset_x: float = 0.0
@export var world_offset_z: float = 8000.0
@export var show_labels: bool = true
@export var label_height_offset: float = 56.0
@export var label_font_size: int = 20
@export var label_pixel_size: float = 0.0032
@export var input_coordinates_use_north_positive_z: bool = true
@export var major_city_names: PackedStringArray = PackedStringArray([
	"\u6d1b\u9633",
	"\u957f\u5b89",
	"\u6210\u90fd",
	"\u5efa\u4e1a",
	"\u8bb8\u660c",
	"\u90ba",
	"\u8944\u9633"
])

var _terrain: Node
var _instance_root: Node3D
var _current_lod_level: int = 3
var _current_total_lods: int = 6
var _current_lod_height: float = 1400.0
var _editor_lod_refresh_accum: float = 0.0
func _ready() -> void:
	_terrain = get_parent().get_node_or_null("Terrain3D")
	if major_city_names.is_empty():
		major_city_names = PackedStringArray(DEFAULT_MAJOR_CITY_NAME_LIST)
	_ensure_roots()
	_persist_editor_positions_if_present()
	_refresh_existing_instances()
	if _instance_root != null and _instance_root.get_child_count() == 0:
		call_deferred("_rebuild_overlay")
	_apply_lod_to_all()
	_sync_editor_lod_from_camera(true)
	if auto_rebuild_overlay:
		call_deferred("_rebuild_overlay")

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

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	_editor_lod_refresh_accum += delta
	if _editor_lod_refresh_accum < EDITOR_LOD_REFRESH_INTERVAL:
		return
	_editor_lod_refresh_accum = 0.0
	_sync_editor_lod_from_camera(false)

func _rebuild_overlay() -> void:
	_persist_editor_positions_if_present()
	_terrain = get_parent().get_node_or_null("Terrain3D")
	_ensure_roots()
	_clear_children(_instance_root)

	var cities: Array[Dictionary] = _load_city_data()
	if cities.is_empty():
		push_warning("ChinaCityOverlay has no city data.")
		return

	for city in cities:
		_spawn_city_instance(city)

func _spawn_city_instance(city: Dictionary) -> void:
	var city_name: String = String(city.get("city_name", city.get("name", "")))
	if city_name.is_empty():
		return
	var state_name: String = String(city.get("state", ""))
	var coordinate: Dictionary = city.get("coordinate", city.get("position", {}))
	var world_x: float = float(coordinate.get("x", 0.0)) + world_offset_x
	var world_z: float = _source_z_to_world_z(float(coordinate.get("z", 0.0))) + world_offset_z
	if not is_finite(world_x) or not is_finite(world_z):
		return
	var ground_y: float = _sample_ground_height(Vector3(world_x, 0.0, world_z))
	if not is_finite(ground_y):
		ground_y = 0.0
	var model_path: String = LUOYANG_MODEL_PATH if city_name == LUOYANG_NAME else DEFAULT_CITY_MODEL_PATH
	var model_scene: PackedScene = load(model_path) as PackedScene
	var inst: Node = CITY_INSTANCE_SCENE.instantiate()
	if not (inst is ChinaCityInstance):
		return
	var city_scale: float = luoyang_scale if city_name == LUOYANG_NAME else default_city_scale
	var city_instance := inst as ChinaCityInstance
	city_instance.setup(
		city_name,
		state_name,
		Vector3(world_x, ground_y + city_height_offset, world_z),
		model_scene,
		city_scale,
		show_labels,
		label_height_offset,
		label_font_size,
		label_pixel_size,
		show_editor_markers,
		editor_marker_scale
	)
	city_instance.configure_presentation(show_labels, label_height_offset, label_font_size, label_pixel_size, show_editor_markers, editor_marker_scale, major_city_names)
	city_instance.apply_lod(_current_lod_level, _current_total_lods, _current_lod_height)
	_instance_root.add_child(city_instance)
	_own_node_for_editor(city_instance)

func apply_camera_lod(level: int, total_levels: int, height: float) -> void:
	_current_lod_level = level
	_current_total_lods = total_levels
	_current_lod_height = height
	_apply_lod_to_all()

func _sync_editor_lod_from_camera(force_apply: bool = false) -> void:
	if not Engine.is_editor_hint():
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var camera := viewport.get_camera_3d()
	if camera == null:
		return
	var editor_height: float = maxf(1.0, camera.global_position.y)
	var editor_level: int = _nearest_lod_level(editor_height, EDITOR_LOD_LEVEL_HEIGHTS)
	var editor_total: int = EDITOR_LOD_LEVEL_HEIGHTS.size()
	if editor_force_lod_level > 0:
		editor_level = clampi(editor_force_lod_level, 1, editor_total)
		editor_height = float(EDITOR_LOD_LEVEL_HEIGHTS[editor_level - 1])
	if not force_apply and editor_level == _current_lod_level and editor_total == _current_total_lods and absf(editor_height - _current_lod_height) <= 0.1:
		return
	_current_lod_level = editor_level
	_current_total_lods = editor_total
	_current_lod_height = editor_height
	_apply_lod_to_all()

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

func _source_z_to_world_z(source_z: float) -> float:
	return -source_z if input_coordinates_use_north_positive_z else source_z

func _world_z_to_source_z(world_local_z: float) -> float:
	return -world_local_z if input_coordinates_use_north_positive_z else world_local_z

func _sample_ground_height(world_pos: Vector3) -> float:
	if _terrain == null:
		return 0.0
	var terrain_data: Variant = _terrain.get("data")
	if terrain_data != null and terrain_data.has_method("get_height"):
		return float(terrain_data.call("get_height", world_pos))
	return 0.0

func _load_city_data() -> Array[Dictionary]:
	var manual: Array[Dictionary] = _load_manual_override_data()
	if lock_to_manual_overrides and not manual.is_empty():
		return manual
	if prefer_manual_overrides and not manual.is_empty():
		return manual
	var exact: Array[Dictionary] = _load_exact_city_data()
	if not exact.is_empty():
		return exact
	return _load_fallback_city_data()

func _load_manual_override_data() -> Array[Dictionary]:
	var file := FileAccess.open(MANUAL_OVERRIDE_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return []
	var root: Dictionary = parsed as Dictionary
	var out: Array[Dictionary] = []
	for item_any in root.get("three_kingdoms_14_cities", []):
		if item_any is Dictionary:
			out.append((item_any as Dictionary).duplicate(true))
	return out

func _load_exact_city_data() -> Array[Dictionary]:
	var file := FileAccess.open(EXACT_CITY_DATA_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return []
	var root: Dictionary = parsed as Dictionary
	var out: Array[Dictionary] = []
	var flat_raw: Array = root.get("three_kingdoms_14_cities", [])
	for item_any in flat_raw:
		if item_any is Dictionary:
			out.append((item_any as Dictionary).duplicate(true))
	if not out.is_empty():
		return out
	var grouped_any: Variant = root.get("three_kingdoms_14_46_cities", {})
	if grouped_any is Dictionary:
		var grouped: Dictionary = grouped_any as Dictionary
		for state_name in grouped.keys():
			var cities_any: Variant = grouped.get(state_name, [])
			if not (cities_any is Array):
				continue
			for item_any in (cities_any as Array):
				if not (item_any is Dictionary):
					continue
				var entry: Dictionary = (item_any as Dictionary).duplicate(true)
				entry["state"] = String(state_name)
				out.append(entry)
	return out

func _load_fallback_city_data() -> Array[Dictionary]:
	var file := FileAccess.open(FALLBACK_CITY_DATA_PATH, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return []
	var root: Dictionary = parsed as Dictionary
	var raw: Array = root.get("san14_main_cities_actual_coordinates", root.get("cities", []))
	var out: Array[Dictionary] = []
	for item_any in raw:
		if item_any is Dictionary:
			out.append((item_any as Dictionary).duplicate(true))
	return out

func _ensure_roots() -> void:
	var instance_node: Node = get_node_or_null("CityInstances")
	if instance_node is Node3D:
		_instance_root = instance_node as Node3D
	else:
		_instance_root = Node3D.new()
		_instance_root.name = "CityInstances"
		add_child(_instance_root)
	_own_node_for_editor(_instance_root)

func _refresh_existing_instances() -> void:
	if _instance_root == null:
		return
	var cities: Array[Dictionary] = _load_city_data()
	_repair_existing_city_identities(cities)
	for child in _instance_root.get_children():
		if child is ChinaCityInstance:
			var city := child as ChinaCityInstance
			var city_name: String = String(city.get_meta("city_name", city.name.trim_prefix("City_")))
			var model_path: String = LUOYANG_MODEL_PATH if city_name == LUOYANG_NAME else DEFAULT_CITY_MODEL_PATH
			var model_scene: PackedScene = load(model_path) as PackedScene
			var city_scale: float = luoyang_scale if city_name == LUOYANG_NAME else default_city_scale
			city.ensure_model(model_scene, city_scale, city_name)
			city.configure_presentation(show_labels, label_height_offset, label_font_size, label_pixel_size, show_editor_markers, editor_marker_scale, major_city_names)

func _repair_existing_city_identities(cities: Array[Dictionary]) -> void:
	if _instance_root == null or cities.is_empty():
		return
	var candidates: Array[Dictionary] = []
	for city in cities:
		var city_name: String = String(city.get("city_name", city.get("name", ""))).strip_edges()
		if city_name.is_empty():
			continue
		var state_name: String = String(city.get("state", ""))
		var coordinate: Dictionary = city.get("coordinate", city.get("position", {}))
		var world_x: float = float(coordinate.get("x", 0.0)) + world_offset_x
		var world_z: float = _source_z_to_world_z(float(coordinate.get("z", 0.0))) + world_offset_z
		candidates.append({
			"city_name": city_name,
			"state": state_name,
			"world_pos": Vector2(world_x, world_z),
			"used": false
		})
	if candidates.is_empty():
		return
	for child in _instance_root.get_children():
		if not (child is ChinaCityInstance):
			continue
		var city_node := child as ChinaCityInstance
		var current_name: String = String(city_node.get_meta("city_name", city_node.name.trim_prefix("City_"))).strip_edges()
		var idx: int = _find_best_city_candidate(candidates, city_node.position, current_name)
		if idx < 0:
			continue
		var matched: Dictionary = candidates[idx]
		matched["used"] = true
		candidates[idx] = matched
		city_node.override_identity(String(matched.get("city_name", "")), String(matched.get("state", "")), true)

func _find_best_city_candidate(candidates: Array[Dictionary], world_pos: Vector3, current_name: String) -> int:
	var best_idx: int = -1
	var best_score: float = INF
	var node_pos_2d := Vector2(world_pos.x, world_pos.z)
	for i in range(candidates.size()):
		var cand: Dictionary = candidates[i]
		if bool(cand.get("used", false)):
			continue
		var cand_pos: Vector2 = cand.get("world_pos", Vector2.ZERO)
		var score: float = node_pos_2d.distance_squared_to(cand_pos)
		if not current_name.is_empty() and String(cand.get("city_name", "")) == current_name:
			score *= 0.01
		if score < best_score:
			best_score = score
			best_idx = i
	return best_idx

func _apply_lod_to_all() -> void:
	if _instance_root == null:
		return
	for child in _instance_root.get_children():
		if child is ChinaCityInstance:
			(child as ChinaCityInstance).apply_lod(_current_lod_level, _current_total_lods, _current_lod_height)

func _refresh_current_city_heights() -> void:
	_terrain = get_parent().get_node_or_null("Terrain3D")
	if _instance_root == null:
		return
	for child in _instance_root.get_children():
		if not (child is Node3D):
			continue
		var city_node := child as Node3D
		var pos := city_node.position
		pos.y = _sample_ground_height(Vector3(pos.x, 0.0, pos.z)) + city_height_offset
		city_node.position = pos

func _save_current_positions_to_override() -> void:
	if _instance_root == null:
		return
	var cities: Array[Dictionary] = []
	for child in _instance_root.get_children():
		if not (child is Node3D):
			continue
		var city_node := child as Node3D
		var city_name: String = String(city_node.get_meta("city_name", city_node.name.trim_prefix("City_")))
		if city_name.is_empty():
			continue
		var state_name: String = String(city_node.get_meta("state", ""))
		var local_x: float = city_node.position.x - world_offset_x
		var local_z: float = city_node.position.z - world_offset_z
		cities.append({
			"state": state_name,
			"city_name": city_name,
			"coordinate": {
				"x": int(round(local_x)),
				"z": int(round(_world_z_to_source_z(local_z)))
			}
		})
	cities.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a.get("city_name", "")) < String(b.get("city_name", ""))
	)
	var root := {
		"source": "manual_editor_adjustment",
		"world_offset_x": world_offset_x,
		"world_offset_z": world_offset_z,
		"input_coordinates_use_north_positive_z": input_coordinates_use_north_positive_z,
		"three_kingdoms_14_cities": cities
	}
	var file := FileAccess.open(MANUAL_OVERRIDE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Cannot write manual override file: %s" % MANUAL_OVERRIDE_PATH)
		return
	file.store_string(JSON.stringify(root, "\t"))
	print("Saved manual city overrides: ", MANUAL_OVERRIDE_PATH)

func _own_node_for_editor(node: Node) -> void:
	if node == null or not Engine.is_editor_hint():
		return
	var tree := get_tree()
	if tree == null:
		return
	var edited_root := tree.edited_scene_root
	if edited_root != null:
		node.owner = edited_root

func _clear_children(parent: Node) -> void:
	if parent == null:
		return
	for child in parent.get_children():
		if child is Node:
			(child as Node).queue_free()




