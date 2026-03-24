extends Node3D
class_name ChinaPoliticalMaskOverlay

const REGION_DATA_PATH := "res://data/config/han_13_zhou_regions.json"
const MASK_META_PATH := "res://data/terrain/china_30km/political/zhou_mask_meta.json"
const SHADER_PATH := "res://scripts/presentation/political_mask_overlay.gdshader"

@export var map_size: Vector2 = Vector2(30000.0, 30000.0)
@export var plane_y: float = 0.3

var _mesh_instance: MeshInstance3D
var _material: ShaderMaterial
var _region_defs: Array[Dictionary] = []
var _region_polygons_world: Array[Dictionary] = []
var _region_index_by_id: Dictionary = {}


func _ready() -> void:
	_load_region_defs()
	_build_plane()
	_apply_default_material()


func set_region_color_overrides(region_color_overrides: Dictionary = {}) -> void:
	_apply_region_color_overrides(region_color_overrides, true, Color(0.0, 0.0, 0.0, 0.0))


func set_region_color_overrides_with_fallback(region_color_overrides: Dictionary, fallback_color: Color) -> void:
	_apply_region_color_overrides(region_color_overrides, false, fallback_color)


func _apply_region_color_overrides(region_color_overrides: Dictionary, use_region_base_color: bool, fallback_color: Color) -> void:
	if _material == null:
		return
	for i in range(1, 14):
		_material.set_shader_parameter("region_color_%02d" % i, fallback_color)
	for region in _region_defs:
		var region_id: String = String(region.get("id", ""))
		var region_index: int = int(_region_index_by_id.get(region_id, 0))
		if region_index <= 0:
			continue
		var base_color: Color = fallback_color
		if use_region_base_color:
			base_color = _color_from_any(region.get("color", [0.8, 0.8, 0.8, 0.92]), Color(0.8, 0.8, 0.8, 0.92))
		if region_color_overrides.has(region_id):
			base_color = _color_from_any(region_color_overrides.get(region_id), base_color)
		_material.set_shader_parameter("region_color_%02d" % region_index, base_color)


func set_overlay_opacity(opacity: float) -> void:
	if _material == null:
		return
	_material.set_shader_parameter("overlay_opacity", clampf(opacity, 0.0, 1.0))


func region_id_at_world(world_pos: Vector3) -> String:
	var point := Vector2(world_pos.x, world_pos.z)
	for i in range(_region_polygons_world.size() - 1, -1, -1):
		var region: Dictionary = _region_polygons_world[i]
		var polygon: PackedVector2Array = region.get("polygon", PackedVector2Array())
		if Geometry2D.is_point_in_polygon(point, polygon):
			return String(region.get("id", ""))
	return ""

func get_region_ids() -> Array:
	var ids: Array = []
	for region in _region_defs:
		var region_id: String = String(region.get("id", "")).strip_edges()
		if not region_id.is_empty():
			ids.append(region_id)
	return ids


func _load_region_defs() -> void:
	_region_defs.clear()
	_region_polygons_world.clear()
	_region_index_by_id.clear()
	var file: FileAccess = FileAccess.open(REGION_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("Missing region file: %s" % REGION_DATA_PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_warning("Invalid region json: %s" % REGION_DATA_PATH)
		return
	var index: int = 1
	for entry_any in (parsed as Dictionary).get("regions", []):
		if not (entry_any is Dictionary):
			continue
		var entry: Dictionary = (entry_any as Dictionary).duplicate(true)
		_region_defs.append(entry)
		_region_index_by_id[String(entry.get("id", ""))] = index
		var polygon := PackedVector2Array()
		for point_any in entry.get("polygon_uvs", []):
			polygon.append(_uv_to_world(_vector2_from_any(point_any)))
		_region_polygons_world.append({
			"id": String(entry.get("id", "")),
			"polygon": polygon
		})
		index += 1


func _build_plane() -> void:
	if _mesh_instance == null:
		_mesh_instance = MeshInstance3D.new()
		_mesh_instance.name = "PoliticalMaskPlane"
		add_child(_mesh_instance)
	var plane := PlaneMesh.new()
	plane.size = map_size
	_mesh_instance.mesh = plane
	_mesh_instance.position = Vector3(0.0, plane_y, 0.0)
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _apply_default_material() -> void:
	var meta_file: FileAccess = FileAccess.open(MASK_META_PATH, FileAccess.READ)
	if meta_file == null:
		push_warning("Missing mask meta file: %s" % MASK_META_PATH)
		return
	var meta_parsed: Variant = JSON.parse_string(meta_file.get_as_text())
	if not (meta_parsed is Dictionary):
		push_warning("Invalid mask meta json: %s" % MASK_META_PATH)
		return
	var meta: Dictionary = meta_parsed as Dictionary
	var shader: Shader = load(SHADER_PATH)
	if shader == null:
		push_warning("Missing overlay shader: %s" % SHADER_PATH)
		return
	_material = ShaderMaterial.new()
	_material.shader = shader
	_material.set_shader_parameter("id_mask", load(String(meta.get("id_mask", ""))))
	_material.set_shader_parameter("border_mask", load(String(meta.get("border_mask", ""))))
	_material.set_shader_parameter("label_mask", load(String(meta.get("label_overlay", ""))))
	_material.set_shader_parameter("border_color", Color(0.27, 0.12, 0.06, 1.0))
	_material.set_shader_parameter("label_color", Color(0.12, 0.07, 0.03, 1.0))
	_material.set_shader_parameter("overlay_opacity", 1.0)
	_mesh_instance.material_override = _material
	set_region_color_overrides({})


func _uv_to_world(uv: Vector2) -> Vector2:
	return Vector2(uv.x * map_size.x - map_size.x * 0.5, uv.y * map_size.y - map_size.y * 0.5)


func _vector2_from_any(value: Variant) -> Vector2:
	if value is Vector2:
		return value
	if value is Array and (value as Array).size() >= 2:
		var arr: Array = value
		return Vector2(float(arr[0]), float(arr[1]))
	return Vector2.ZERO


func _color_from_any(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	if value is Array and (value as Array).size() >= 3:
		var arr: Array = value
		var alpha: float = 1.0 if arr.size() < 4 else float(arr[3])
		return Color(float(arr[0]), float(arr[1]), float(arr[2]), alpha)
	return fallback
