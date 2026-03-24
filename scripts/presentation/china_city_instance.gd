@tool
extends Node3D
class_name ChinaCityInstance

const LOD_CITY_ICON_PATH := "res://\u7d20\u6750/icon/chengchi.png"
const FORCE_GEOMETRY_LOD5_ICON := false

var _model_root: Node3D
var _label: Label3D
var _marker: MeshInstance3D
var _icon_root: Node3D
var _city_name: String = ""
var _state_name: String = ""
var _is_major_city: bool = false
var _base_label_height: float = 56.0
var _base_label_font_size: int = 20
var _base_label_pixel_size: float = 0.0032
var _base_marker_scale: float = 3.0
var _show_label_enabled: bool = true
var _show_marker_enabled: bool = true
var _city_icon_texture: Texture2D = null

func _ready() -> void:
	_ensure_nodes()
	_sync_from_existing_nodes()
	apply_lod(3, 6, global_position.y)

func setup(city_name: String, state_name: String, world_pos: Vector3, model_scene: PackedScene, city_scale: float, show_label: bool, label_height: float, label_font_size: int, label_pixel_size: float, show_marker: bool, marker_scale: float) -> void:
	_ensure_nodes()
	name = "City_%s" % city_name
	position = world_pos
	_city_name = city_name
	_state_name = state_name
	set_meta("city_name", city_name)
	set_meta("state", state_name)
	_show_label_enabled = show_label
	_show_marker_enabled = show_marker
	_base_label_height = label_height
	_base_label_font_size = label_font_size
	_base_label_pixel_size = label_pixel_size
	_base_marker_scale = marker_scale
	set_model(model_scene, city_scale)
	_label.text = city_name
	_apply_base_style()

func override_identity(city_name: String, state_name: String, rename_node: bool = true) -> void:
	_ensure_nodes()
	_city_name = city_name.strip_edges()
	_state_name = state_name.strip_edges()
	if rename_node and not _city_name.is_empty():
		name = "City_%s" % _city_name
	set_meta("city_name", _city_name)
	set_meta("state", _state_name)
	if _label != null:
		_label.text = _city_name

func set_model(model_scene: PackedScene, city_scale: float) -> void:
	_ensure_nodes()
	_clear_children(_model_root)
	_instantiate_model(model_scene, city_scale)

func ensure_model(model_scene: PackedScene, city_scale: float, city_name: String = "") -> void:
	_ensure_nodes()
	if _model_root == null:
		return
	if not city_name.is_empty():
		_city_name = city_name
		set_meta("city_name", city_name)
	if _model_root.get_child_count() > 0:
		return
	_instantiate_model(model_scene, city_scale)

func configure_presentation(show_label: bool, label_height: float, label_font_size: int, label_pixel_size: float, show_marker: bool, marker_scale: float, major_city_names: PackedStringArray = PackedStringArray()) -> void:
	_ensure_nodes()
	_show_label_enabled = show_label
	_show_marker_enabled = show_marker
	_base_label_height = label_height
	_base_label_font_size = label_font_size
	_base_label_pixel_size = label_pixel_size
	_base_marker_scale = marker_scale
	_sync_from_existing_nodes()
	_is_major_city = major_city_names.has(_city_name)
	_apply_base_style()

func apply_lod(level: int, total_levels: int, _height: float = 0.0) -> void:
	_ensure_nodes()
	_sync_from_existing_nodes()
	var total: int = maxi(1, total_levels)
	var clamped_level: int = clampi(level, 1, total)
	var show_model: bool = true
	var show_label_now: bool = _show_label_enabled
	var show_marker_now: bool = _show_marker_enabled
	var show_icon_now: bool = false
	var show_point_now: bool = false
	var label_height: float = _base_label_height
	var label_font_size: int = _base_label_font_size
	var label_pixel_size: float = _base_label_pixel_size
	var outline_size: int = 3
	var marker_scale: float = _base_marker_scale
	var icon_height: float = maxf(13.0, _base_label_height * 0.24)
	var icon_scale: float = 1.0

	match clamped_level:
		1:
			show_label_now = _show_label_enabled
			show_marker_now = _show_marker_enabled
			label_height = _base_label_height * 0.72
			label_font_size = maxi(_base_label_font_size, int(round(_base_label_font_size * 1.0)))
			label_pixel_size = _base_label_pixel_size * 0.9
			marker_scale = _base_marker_scale * 0.72
		2:
			show_label_now = _show_label_enabled
			label_height = _base_label_height * 0.82
			label_font_size = maxi(_base_label_font_size + 2, int(round(_base_label_font_size * 1.2)))
			label_pixel_size = _base_label_pixel_size * 1.15
			marker_scale = _base_marker_scale * 0.82
		3:
			show_label_now = _show_label_enabled
			label_height = _base_label_height * 0.62
			label_font_size = maxi(6, int(round(_base_label_font_size * 0.82)))
			label_pixel_size = _base_label_pixel_size * 0.62
			marker_scale = _base_marker_scale * 0.92
		4:
			show_model = false
			show_label_now = _show_label_enabled
			show_marker_now = false
			show_icon_now = false
			label_height = _base_label_height * 0.76
			label_font_size = maxi(6, int(round(_base_label_font_size * 0.9)))
			label_pixel_size = _base_label_pixel_size * 0.82
		5:
			show_model = false
			show_label_now = false
			show_marker_now = false
			show_icon_now = true
			icon_height = maxf(24.0, _base_label_height * 0.48)
			icon_scale = _compute_lod_icon_scale(_height)
		_:
			show_model = false
			show_label_now = false
			show_marker_now = true
			show_icon_now = false
			show_point_now = true
			marker_scale = maxf(_base_marker_scale * 0.45, _compute_lod_point_scale(_height))

	_model_root.visible = show_model
	_label.visible = show_label_now
	_label.position = Vector3(0.0, label_height, 0.0)
	_label.font_size = label_font_size
	_label.pixel_size = label_pixel_size
	_label.fixed_size = true
	_label.outline_size = outline_size
	_label.modulate = Color(1.0, 0.95, 0.84, 1.0) if not _is_major_city else Color(1.0, 0.9, 0.72, 1.0)
	_marker.visible = show_marker_now
	_marker.position = Vector3(0.0, maxf(14.0 if show_point_now else 10.0, label_height * (0.42 if show_point_now else 0.18)), 0.0)
	_marker.scale = Vector3.ONE * marker_scale
	_icon_root.visible = show_icon_now
	_icon_root.position = Vector3(0.0, icon_height, 0.0)
	_icon_root.scale = Vector3.ONE * icon_scale
	if show_marker_now and show_point_now:
		_apply_marker_point_style()
	else:
		_apply_marker_default_style()

func _ensure_nodes() -> void:
	_clear_legacy_icon_labels()
	_prune_duplicate_runtime_nodes()
	if _model_root == null:
		_model_root = _find_model_root()
		if _model_root == null:
			_model_root = Node3D.new()
			_model_root.name = "ModelRoot"
			add_child(_model_root)
	if _label == null:
		_label = _find_label_node()
		if _label == null:
			_label = Label3D.new()
			_label.name = "CityLabel"
			_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			_label.no_depth_test = true
			_label.fixed_size = true
			_label.modulate = Color(1.0, 0.96, 0.85, 1.0)
			_label.outline_size = 3
			_label.outline_modulate = Color(0.08, 0.06, 0.04, 0.92)
			_label.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			add_child(_label)
	if _marker == null:
		_marker = _find_marker_node()
		if _marker == null:
			_marker = MeshInstance3D.new()
			_marker.name = "EditorMarker"
			add_child(_marker)
	if _icon_root == null:
		_icon_root = _find_icon_root()
		if _icon_root == null:
			_icon_root = Node3D.new()
			_icon_root.name = "CityIcon"
			add_child(_icon_root)
		_build_icon_root()

func _prune_duplicate_runtime_nodes() -> void:
	var keep_model_root: Node3D = null
	var keep_label: Label3D = null
	var keep_marker: MeshInstance3D = null
	var keep_icon_root: Node3D = null
	for child in get_children():
		var child_name: String = String((child as Node).name)
		if child is Label3D and child_name.begins_with("CityLabel"):
			if keep_label == null:
				keep_label = child as Label3D
			else:
				(child as Node).queue_free()
		elif child is MeshInstance3D and child_name.begins_with("EditorMarker"):
			if keep_marker == null:
				keep_marker = child as MeshInstance3D
			else:
				(child as Node).queue_free()
		elif child is Node3D and child_name.begins_with("ModelRoot"):
			if keep_model_root == null:
				keep_model_root = child as Node3D
			else:
				(child as Node).queue_free()
		elif child is Node3D and child_name.begins_with("CityIcon"):
			if keep_icon_root == null:
				keep_icon_root = child as Node3D
			else:
				(child as Node).queue_free()
	if keep_model_root != null:
		keep_model_root.name = "ModelRoot"
	if keep_label != null:
		keep_label.name = "CityLabel"
	if keep_marker != null:
		keep_marker.name = "EditorMarker"
	if keep_icon_root != null:
		keep_icon_root.name = "CityIcon"
	_model_root = keep_model_root
	_label = keep_label
	_marker = keep_marker
	_icon_root = keep_icon_root

func _sync_from_existing_nodes() -> void:
	if _city_name.is_empty():
		_city_name = String(get_meta("city_name", _label.text if _label != null else name.trim_prefix("City_")))
	if _state_name.is_empty():
		_state_name = String(get_meta("state", ""))
	if _label != null and _label.text.is_empty():
		_label.text = _city_name

func _apply_base_style() -> void:
	_clear_legacy_icon_labels()
	if _label == null or _marker == null or _icon_root == null:
		return
	_label.text = _city_name
	_label.position = Vector3(0.0, _base_label_height, 0.0)
	_label.font_size = _base_label_font_size
	_label.pixel_size = _base_label_pixel_size
	_label.fixed_size = true
	_label.no_depth_test = true
	_label.outline_size = 3
	if _marker.mesh == null or _marker.mesh is SphereMesh:
		var keep_mesh := BoxMesh.new()
		keep_mesh.size = Vector3(2.2, 0.7, 2.2)
		_marker.mesh = keep_mesh
	if _marker.material_override == null:
		var marker_mat := StandardMaterial3D.new()
		marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		marker_mat.albedo_color = Color(1.0, 0.75, 0.2, 0.92)
		marker_mat.no_depth_test = true
		_marker.material_override = marker_mat
	_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_marker.position = Vector3(0.0, maxf(10.0, _base_label_height * 0.18), 0.0)
	_marker.scale = Vector3.ONE * _base_marker_scale
	_icon_root.position = Vector3(0.0, maxf(13.0, _base_label_height * 0.24), 0.0)
	_icon_root.scale = Vector3.ONE * 0.8
	_icon_root.visible = false
	_build_icon_root()

func _apply_marker_default_style() -> void:
	if _marker == null:
		return
	var style := String(_marker.get_meta("marker_style", ""))
	if style == "default" and _marker.mesh != null and _marker.material_override != null:
		return
	var keep_mesh := BoxMesh.new()
	keep_mesh.size = Vector3(2.2, 0.7, 2.2)
	_marker.mesh = keep_mesh
	var marker_mat := StandardMaterial3D.new()
	marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marker_mat.albedo_color = Color(1.0, 0.75, 0.2, 0.92)
	marker_mat.no_depth_test = true
	_marker.material_override = marker_mat
	_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_marker.set_meta("marker_style", "default")

func _apply_marker_point_style() -> void:
	if _marker == null:
		return
	var style := String(_marker.get_meta("marker_style", ""))
	if style == "point" and _marker.mesh != null and _marker.material_override != null:
		return
	var dot := CylinderMesh.new()
	dot.top_radius = 1.1
	dot.bottom_radius = 1.1
	dot.height = 0.24
	_marker.mesh = dot
	var dot_mat := StandardMaterial3D.new()
	dot_mat.albedo_color = Color(0.9, 0.9, 0.9, 1.0)
	dot_mat.roughness = 0.5
	dot_mat.metallic = 0.02
	_marker.material_override = dot_mat
	_marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_marker.set_meta("marker_style", "point")

func _compute_lod_icon_scale(lod_height: float) -> float:
	if lod_height <= 0.0:
		return 28.0
	return clampf(lod_height * 0.0032, 18.0, 72.0)

func _compute_lod_point_scale(lod_height: float) -> float:
	if lod_height <= 0.0:
		return 1.0
	return clampf(lod_height * 0.0038, 30.0, 110.0)

func _build_icon_root() -> void:
	if _icon_root == null:
		return
	var style := String(_icon_root.get_meta("icon_style", ""))
	var style_key := "city_icon_v5_geo" if FORCE_GEOMETRY_LOD5_ICON else "city_icon_v5_tex"
	if style == style_key and _icon_root.get_child_count() > 0:
		return
	_clear_children(_icon_root)
	var icon := MeshInstance3D.new()
	icon.name = "IconCity"
	icon.extra_cull_margin = 4096.0
	var mesh: Mesh = null
	if FORCE_GEOMETRY_LOD5_ICON:
		var box := BoxMesh.new()
		box.size = Vector3(4.2, 0.72, 4.2)
		mesh = box
	else:
		var plane := PlaneMesh.new()
		plane.size = Vector2(9.6, 9.6)
		mesh = plane
	icon.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if not FORCE_GEOMETRY_LOD5_ICON:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.88, 0.34, 1.0)
	mat.emission_energy_multiplier = 1.4
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.no_depth_test = true
	if _city_icon_texture == null and ResourceLoader.exists(LOD_CITY_ICON_PATH):
		_city_icon_texture = load(LOD_CITY_ICON_PATH) as Texture2D
	if _city_icon_texture != null and not FORCE_GEOMETRY_LOD5_ICON:
		mat.albedo_color = Color(1.0, 0.88, 0.36, 1.0)
		mat.albedo_texture = _city_icon_texture
	else:
		mat.albedo_color = Color(1.0, 0.86, 0.30, 1.0)
	icon.material_override = mat
	icon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_icon_root.add_child(icon)
	_icon_root.set_meta("icon_style", style_key)

func _clear_legacy_icon_labels() -> void:
	for child in get_children():
		if child is Label3D and String((child as Node).name).begins_with("CityIcon"):
			(child as Label3D).visible = false
			(child as Node).queue_free()
func _find_model_root() -> Node3D:
	for child in get_children():
		if child is Node3D and String((child as Node).name).begins_with("ModelRoot"):
			return child as Node3D
	return null

func _find_label_node() -> Label3D:
	for child in get_children():
		if child is Label3D and String((child as Node).name).begins_with("CityLabel"):
			return child as Label3D
	return null

func _find_marker_node() -> MeshInstance3D:
	for child in get_children():
		if child is MeshInstance3D and String((child as Node).name).begins_with("EditorMarker"):
			return child as MeshInstance3D
	return null

func _find_icon_root() -> Node3D:
	for child in get_children():
		if child is Node3D and String((child as Node).name).begins_with("CityIcon"):
			return child as Node3D
	return null

func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		if child is Node:
			(child as Node).queue_free()

func _instantiate_model(model_scene: PackedScene, city_scale: float) -> void:
	if _model_root == null or model_scene == null:
		return
	var inst: Node = model_scene.instantiate()
	if inst is Node3D:
		var model := inst as Node3D
		model.scale = Vector3.ONE * city_scale
		model.rotation_degrees.y = _stable_rotation_deg(_city_name)
		_model_root.add_child(model)
	else:
		_model_root.add_child(inst)

func _stable_rotation_deg(name_text: String) -> float:
	var accum: int = 0
	for i in name_text.length():
		accum += name_text.unicode_at(i)
	return float((accum * 37) % 360)





