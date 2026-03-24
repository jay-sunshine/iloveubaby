extends Node3D
class_name PoliticalMapOverlay

const DEFAULT_REGION_DATA_PATH := "res://data/config/han_13_zhou_regions.json"
const DEFAULT_MODE := "province"

var _map_size: Vector2 = Vector2(30000.0, 30000.0)
var _viewport_size: int = 2048
var _plane_y: float = 0.25
var _fill_alpha: float = 0.9
var _border_color: Color = Color(0.25, 0.12, 0.05, 0.95)
var _border_width: float = 5.0
var _label_color: Color = Color(0.14, 0.08, 0.04, 1.0)
var _label_outline_color: Color = Color(1.0, 0.98, 0.9, 0.95)
var _label_size: int = 44
var _display_mode: String = DEFAULT_MODE
var _region_defs: Array[Dictionary] = []
var _region_polygons_world: Array[Dictionary] = []
var _region_color_overrides: Dictionary = {}

var _plane_mesh_instance: MeshInstance3D
var _viewport: SubViewport
var _canvas_root: Node2D


func setup(map_size: Vector2, overlay_cfg: Dictionary, font: Font = null) -> void:
	_map_size = map_size
	_viewport_size = maxi(512, int(overlay_cfg.get("political_overview_texture_size", 2048)))
	_plane_y = float(overlay_cfg.get("political_overview_plane_y", 0.25))
	_fill_alpha = clampf(float(overlay_cfg.get("political_overview_alpha", 0.9)), 0.0, 1.0)
	_border_width = maxf(1.0, float(overlay_cfg.get("political_overview_border_width", 5.0)))
	_label_size = maxi(16, int(overlay_cfg.get("political_overview_label_size", 44)))
	_display_mode = String(overlay_cfg.get("political_overview_mode", DEFAULT_MODE))
	_border_color = _color_from_any(overlay_cfg.get("political_overview_border_color", [0.25, 0.12, 0.05, 0.95]), Color(0.25, 0.12, 0.05, 0.95))
	_label_color = _color_from_any(overlay_cfg.get("political_overview_label_color", [0.14, 0.08, 0.04, 1.0]), Color(0.14, 0.08, 0.04, 1.0))
	_label_outline_color = _color_from_any(overlay_cfg.get("political_overview_label_outline_color", [1.0, 0.98, 0.9, 0.95]), Color(1.0, 0.98, 0.9, 0.95))
	var region_path: String = String(overlay_cfg.get("political_overview_region_path", DEFAULT_REGION_DATA_PATH))
	_load_region_defs(region_path)
	_ensure_plane()
	_rebuild_viewport(font)


func set_display_mode(mode: String, region_color_overrides: Dictionary = {}, font: Font = null) -> void:
	_display_mode = String(mode)
	_region_color_overrides = region_color_overrides.duplicate(true)
	_rebuild_viewport(font)


func get_display_mode() -> String:
	return _display_mode


func region_id_at_world(world_pos: Vector3) -> String:
	var point := Vector2(world_pos.x, world_pos.z)
	for i in range(_region_polygons_world.size() - 1, -1, -1):
		var region: Dictionary = _region_polygons_world[i]
		var polygon: PackedVector2Array = region.get("polygon", PackedVector2Array())
		if Geometry2D.is_point_in_polygon(point, polygon):
			return String(region.get("id", ""))
	return ""


func _load_region_defs(region_path: String) -> void:
	_region_defs.clear()
	_region_polygons_world.clear()
	var file: FileAccess = FileAccess.open(region_path, FileAccess.READ)
	if file == null:
		push_warning("Political overlay region file missing: %s" % region_path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_warning("Political overlay region file parse failed: %s" % region_path)
		return
	for entry_any in (parsed as Dictionary).get("regions", []):
		if not (entry_any is Dictionary):
			continue
		var entry: Dictionary = (entry_any as Dictionary).duplicate(true)
		_region_defs.append(entry)
		var world_polygon := PackedVector2Array()
		for point_any in entry.get("polygon_uvs", []):
			var uv: Vector2 = _vector2_from_any(point_any)
			world_polygon.append(_uv_to_world(uv))
		_region_polygons_world.append({
			"id": String(entry.get("id", "")),
			"polygon": world_polygon
		})


func _ensure_plane() -> void:
	if _plane_mesh_instance == null:
		_plane_mesh_instance = MeshInstance3D.new()
		_plane_mesh_instance.name = "OverviewPlane"
		add_child(_plane_mesh_instance)
	var plane := PlaneMesh.new()
	plane.size = _map_size
	_plane_mesh_instance.mesh = plane
	_plane_mesh_instance.position = Vector3(0.0, _plane_y, 0.0)
	_plane_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	if _viewport == null:
		_viewport = SubViewport.new()
		_viewport.name = "OverviewViewport"
		_viewport.disable_3d = true
		_viewport.transparent_bg = true
		_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		add_child(_viewport)
	if _canvas_root == null:
		_canvas_root = Node2D.new()
		_canvas_root.name = "CanvasRoot"
		_viewport.add_child(_canvas_root)


func _rebuild_viewport(font: Font = null) -> void:
	if _viewport == null or _canvas_root == null:
		return
	_viewport.size = Vector2i(_viewport_size, _viewport_size)
	for child in _canvas_root.get_children():
		child.queue_free()
	for region in _region_defs:
		_add_region_polygon(region)
		_add_region_border(region)
		_add_region_label(region, font)
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_apply_plane_material()


func _add_region_polygon(region: Dictionary) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = _scaled_polygon(region)
	polygon.color = _resolve_region_color(region)
	_canvas_root.add_child(polygon)


func _add_region_border(region: Dictionary) -> void:
	var polygon: PackedVector2Array = _scaled_polygon(region)
	if polygon.size() < 3:
		return
	var border := Line2D.new()
	border.width = _border_width
	border.default_color = _border_color
	border.joint_mode = Line2D.LINE_JOINT_ROUND
	border.begin_cap_mode = Line2D.LINE_CAP_ROUND
	border.end_cap_mode = Line2D.LINE_CAP_ROUND
	border.antialiased = true
	for point in polygon:
		border.add_point(point)
	border.add_point(polygon[0])
	_canvas_root.add_child(border)


func _add_region_label(region: Dictionary, font: Font = null) -> void:
	if not region.has("label_uv"):
		return
	var label := Label.new()
	label.text = String(region.get("name", region.get("id", "")))
	label.size = Vector2(320.0, 80.0)
	label.position = _scale_uv(_vector2_from_any(region.get("label_uv", [0.5, 0.5]))) - label.size * 0.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.modulate = _label_color
	label.add_theme_font_size_override("font_size", _label_size)
	if font != null:
		label.add_theme_font_override("font", font)
	var settings := LabelSettings.new()
	if font != null:
		settings.font = font
	settings.font_size = _label_size
	settings.font_color = _label_color
	settings.outline_size = maxi(2, int(round(_label_size * 0.08)))
	settings.outline_color = _label_outline_color
	label.label_settings = settings
	_canvas_root.add_child(label)


func _apply_plane_material() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_texture = _viewport.get_texture()
	material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	material.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	_plane_mesh_instance.material_override = material


func _scaled_polygon(region: Dictionary) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for point_any in region.get("polygon_uvs", []):
		polygon.append(_scale_uv(_vector2_from_any(point_any)))
	return polygon


func _scale_uv(uv: Vector2) -> Vector2:
	return Vector2(uv.x * float(_viewport_size), uv.y * float(_viewport_size))


func _uv_to_world(uv: Vector2) -> Vector2:
	return Vector2(uv.x * _map_size.x - _map_size.x * 0.5, uv.y * _map_size.y - _map_size.y * 0.5)


func _resolve_region_color(region: Dictionary) -> Color:
	var region_id: String = String(region.get("id", ""))
	if _region_color_overrides.has(region_id):
		var override_value: Variant = _region_color_overrides.get(region_id)
		var override_color: Color = _color_from_any(override_value, Color.WHITE)
		override_color.a = _fill_alpha
		return override_color
	var base: Color = _color_from_any(region.get("color", [0.8, 0.8, 0.8, _fill_alpha]), Color(0.8, 0.8, 0.8, _fill_alpha))
	base.a = _fill_alpha
	if _display_mode == "faction":
		return base.lightened(0.05)
	return base


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
		var alpha: float = 1.0
		if arr.size() >= 4:
			alpha = float(arr[3])
		return Color(float(arr[0]), float(arr[1]), float(arr[2]), alpha)
	return fallback
