@tool
extends Area3D
class_name FortressSiteInstance

const LOD_ICON_TEXTURE_PATHS := {
	"city": "res://\u7d20\u6750/icon/chengchi.png",
	"pass": "res://\u7d20\u6750/icon/guanaai.png",
	"fort": "res://\u7d20\u6750/icon/wubao.png",
	"ferry": "res://\u7d20\u6750/icon/jindu.png",
	"resource": "res://\u7d20\u6750/icon/resource.png"
}
const FORCE_GEOMETRY_LOD5_ICONS := false
const DEFENSE_BAR_SEGMENTS := 8

@export var site_name: String = "Fortress":
	set(value):
		site_name = value
		_update_label()

@export_enum("pass", "fort", "ferry", "resource") var site_type: String = "pass"
@export var state_name: String = ""
@export var faction_id: String = ""
@export var site_scale: float = 1.0:
	set(value):
		site_scale = maxf(value, 0.001)
		_update_model_scale()

@export var model_scale_multiplier: float = 1.0:
	set(value):
		model_scale_multiplier = maxf(value, 0.001)
		_update_model_scale()

@export var show_label: bool = true:
	set(value):
		show_label = value
		_update_label()

@export var label_height: float = 18.0:
	set(value):
		label_height = value
		_update_label_transform()

@export var label_font_size: int = 20:
	set(value):
		label_font_size = maxi(value, 8)
		_update_label()

@export var label_pixel_size: float = 0.012:
	set(value):
		label_pixel_size = maxf(value, 0.001)
		_update_label()

@export var collision_extents: Vector3 = Vector3(14.0, 8.0, 14.0):
	set(value):
		collision_extents = Vector3(maxf(value.x, 0.1), maxf(value.y, 0.1), maxf(value.z, 0.1))
		_update_collision_shapes()

@export var model_scene: PackedScene:
	set(value):
		model_scene = value
		_rebuild_model()
@export var model_cast_shadows: bool = false:
	set(value):
		model_cast_shadows = value
		_apply_model_render_flags()

var _selection_shape: CollisionShape3D = null
var _body_shape: CollisionShape3D = null
var _model_root: Node3D = null
var _label: Label3D = null
var _selection_marker: MeshInstance3D = null
var _model_instance: Node3D = null
var _lod_marker_root: Node3D = null
var _lod_icon: MeshInstance3D = null
var _lod_point: MeshInstance3D = null
var _lod_icon_kind: String = ""
var _lod_icon_texture_cache: Dictionary = {}
var _runtime_lod_show_detail: bool = false
var _runtime_defense_current: float = -1.0
var _runtime_defense_max: float = -1.0
var _runtime_troops: float = -1.0

func _bind_runtime_nodes() -> void:
	_selection_shape = get_node_or_null("SelectionShape") as CollisionShape3D
	_body_shape = get_node_or_null("StaticBody3D/BodyShape") as CollisionShape3D
	_model_root = get_node_or_null("ModelRoot") as Node3D
	if _model_root == null:
		for child in get_children():
			if child is Node3D and String((child as Node).name).begins_with("ModelRoot"):
				_model_root = child as Node3D
				break
	_label = get_node_or_null("Label3D") as Label3D
	if _label == null:
		for child in get_children():
			if child is Label3D:
				_label = child as Label3D
				break
	_prune_duplicate_labels()
	_selection_marker = get_node_or_null("SelectionMarker") as MeshInstance3D
	_lod_marker_root = get_node_or_null("LodMarkers") as Node3D
	_lod_icon = get_node_or_null("LodMarkers/LodIcon") as MeshInstance3D
	_lod_point = get_node_or_null("LodMarkers/LodPoint") as MeshInstance3D

func _prune_duplicate_labels() -> void:
	if _label == null:
		return
	for child in get_children():
		if child is Label3D and child != _label:
			(child as Label3D).queue_free()

func _ready() -> void:
	_bind_runtime_nodes()
	monitoring = false
	monitorable = true
	input_ray_pickable = true
	collision_layer = 2
	collision_mask = 0
	var body := get_node_or_null("StaticBody3D") as StaticBody3D
	if body != null:
		body.collision_layer = 2
		body.collision_mask = 1 | 4
	_update_collision_shapes()
	_rebuild_model()
	_update_model_scale()
	_apply_model_render_flags()
	_update_label_transform()
	_update_label()
	_ensure_lod_markers()
	_update_lod_marker_transform()
	if _selection_marker != null:
		_selection_marker.visible = false

func set_selected(value: bool) -> void:
	if _selection_marker != null:
		_selection_marker.visible = value

func set_runtime_site_status(defense_current: float, defense_max: float, troops: float) -> void:
	var next_defense_current: float = _sanitize_runtime_value(defense_current)
	var next_defense_max: float = _sanitize_runtime_value(defense_max)
	var next_troops: float = _sanitize_runtime_value(troops)
	if is_equal_approx(_runtime_defense_current, next_defense_current) and is_equal_approx(_runtime_defense_max, next_defense_max) and is_equal_approx(_runtime_troops, next_troops):
		return
	_runtime_defense_current = next_defense_current
	_runtime_defense_max = next_defense_max
	_runtime_troops = next_troops
	_update_label()

func set_lod_label_mode(show_detail: bool) -> void:
	if _runtime_lod_show_detail == show_detail:
		return
	_runtime_lod_show_detail = show_detail
	_update_label()

func _rebuild_model() -> void:
	if _model_root == null:
		return
	for child in _model_root.get_children():
		child.queue_free()
	_model_instance = null
	if model_scene == null:
		return
	var inst := model_scene.instantiate()
	if inst is Node3D:
		_model_instance = inst as Node3D
		_model_root.add_child(_model_instance)
		_update_model_scale()
		_apply_model_render_flags()

func _update_model_scale() -> void:
	if _model_instance != null:
		_model_instance.scale = Vector3.ONE * site_scale * model_scale_multiplier

func set_model_visible(visible_now: bool) -> void:
	if _model_root != null:
		_model_root.visible = visible_now

func _apply_model_render_flags() -> void:
	if _model_root == null:
		return
	var shadow_mode: int = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if model_cast_shadows:
		shadow_mode = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	_apply_render_flags_recursive(_model_root, shadow_mode)

func _apply_render_flags_recursive(node: Node, shadow_mode: int) -> void:
	if node is GeometryInstance3D:
		(node as GeometryInstance3D).cast_shadow = shadow_mode
	for child in node.get_children():
		if child is Node:
			_apply_render_flags_recursive(child, shadow_mode)

func _update_label() -> void:
	if _label == null:
		return
	var display_text: String = _compose_label_text()
	_label.text = display_text
	_label.visible = show_label and not display_text.is_empty()
	_label.font_size = label_font_size
	_label.pixel_size = label_pixel_size
	_label.fixed_size = true
	_label.no_depth_test = true
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.outline_size = 3
	_label.outline_modulate = Color(0.08, 0.06, 0.04, 0.92)
	_label.modulate = Color(1.0, 0.96, 0.84, 1.0)

func _compose_label_text() -> String:
	if not _runtime_lod_show_detail:
		return site_name
	if site_name.is_empty():
		return ""
	var defense_bar: String = _build_defense_bar(_runtime_defense_current, _runtime_defense_max)
	var troops_text: String = _format_runtime_value(_runtime_troops)
	return "%s\n%s %s" % [site_name, defense_bar, troops_text]

func _build_defense_bar(defense_current: float, defense_max: float) -> String:
	var effective_max: float = defense_max
	if effective_max < 0.0:
		effective_max = defense_current
	if effective_max <= 0.0:
		return ".".repeat(DEFENSE_BAR_SEGMENTS)
	var ratio: float = clampf(maxf(defense_current, 0.0) / effective_max, 0.0, 1.0)
	var filled: int = clampi(int(round(ratio * float(DEFENSE_BAR_SEGMENTS))), 0, DEFENSE_BAR_SEGMENTS)
	return "=".repeat(filled) + ".".repeat(DEFENSE_BAR_SEGMENTS - filled)

func _format_runtime_value(value: float) -> String:
	if value < 0.0:
		return "--"
	return str(int(round(value)))

func _sanitize_runtime_value(value: float) -> float:
	return maxf(value, -1.0)

func _update_label_transform() -> void:
	if _label == null:
		return
	_label.position = Vector3(0.0, label_height, 0.0)
	_update_lod_marker_transform()

func _update_collision_shapes() -> void:
	var box := BoxShape3D.new()
	box.size = collision_extents * 2.0
	if _selection_shape != null:
		_selection_shape.shape = box
	var body_box := BoxShape3D.new()
	body_box.size = collision_extents * 2.0
	if _body_shape != null:
		_body_shape.shape = body_box
	if _selection_marker != null:
		var mesh := _selection_marker.mesh as CylinderMesh
		if mesh != null:
			mesh.top_radius = maxf(collision_extents.x, collision_extents.z) * 0.95
			mesh.bottom_radius = mesh.top_radius
			mesh.height = 0.35

func set_lod_marker_state(show_icon: bool, show_point: bool, icon_kind: String, lod_height: float = 0.0) -> void:
	_ensure_lod_markers()
	_apply_lod_icon_style(icon_kind)
	if _lod_icon != null:
		_lod_icon.visible = show_icon
	if _lod_point != null:
		_lod_point.visible = show_point
	_apply_lod_marker_scale(lod_height)
	_update_lod_marker_transform()

func _apply_lod_marker_scale(lod_height: float) -> void:
	if _lod_icon != null:
		var icon_scale: float = _compute_lod_icon_scale(lod_height)
		if _lod_icon.visible:
			icon_scale *= 1.0
		_lod_icon.scale = Vector3.ONE * icon_scale
	if _lod_point != null:
		_lod_point.scale = Vector3.ONE * _compute_lod_point_scale(lod_height)

func _compute_lod_icon_scale(lod_height: float) -> float:
	if lod_height <= 0.0:
		return 28.0
	return clampf(lod_height * 0.0032, 18.0, 72.0)

func _compute_lod_point_scale(lod_height: float) -> float:
	if lod_height <= 0.0:
		return 1.0
	return clampf(lod_height * 0.0038, 30.0, 110.0)

func _ensure_lod_markers() -> void:
	if _lod_marker_root == null:
		_lod_marker_root = Node3D.new()
		_lod_marker_root.name = "LodMarkers"
		add_child(_lod_marker_root)
	if _lod_icon == null:
		_lod_icon = MeshInstance3D.new()
		_lod_icon.name = "LodIcon"
		_lod_icon.extra_cull_margin = 4096.0
		_lod_icon.cast_shadow = 0
		_lod_icon.visible = false
		_lod_marker_root.add_child(_lod_icon)
	if _lod_point == null:
		_lod_point = MeshInstance3D.new()
		_lod_point.name = "LodPoint"
		_lod_point.cast_shadow = 0
		_lod_point.visible = false
		_lod_marker_root.add_child(_lod_point)
		_apply_lod_point_style()

func _apply_lod_icon_style(icon_kind: String) -> void:
	if _lod_icon == null:
		return
	_lod_icon_kind = icon_kind
	var icon_texture: Texture2D = _load_lod_icon_texture(icon_kind)
	if icon_texture != null and not FORCE_GEOMETRY_LOD5_ICONS:
		var plane := PlaneMesh.new()
		plane.size = Vector2(9.6, 9.6)
		_lod_icon.mesh = plane
		var card_mat := StandardMaterial3D.new()
		card_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		card_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		card_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		card_mat.albedo_color = Color(1.0, 0.88, 0.36, 1.0)
		card_mat.albedo_texture = icon_texture
		card_mat.emission_enabled = true
		card_mat.emission = Color(1.0, 1.0, 1.0, 1.0)
		card_mat.emission_energy_multiplier = 1.6
		card_mat.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
		card_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		card_mat.no_depth_test = true
		_lod_icon.material_override = card_mat
		return
	var mesh: Mesh = null
	var color := Color(0.9, 0.78, 0.3, 1.0)
	match icon_kind:
		"city":
			var box := BoxMesh.new()
			box.size = Vector3(4.0, 0.72, 4.0)
			mesh = box
			color = Color(1.0, 0.85, 0.25, 1.0)
		"pass":
			var gate := BoxMesh.new()
			gate.size = Vector3(5.2, 0.74, 2.1)
			mesh = gate
			color = Color(0.98, 0.55, 0.22, 1.0)
		"fort":
			var fort := BoxMesh.new()
			fort.size = Vector3(3.6, 0.72, 3.6)
			mesh = fort
			color = Color(0.92, 0.33, 0.27, 1.0)
		"ferry":
			var cyl := CylinderMesh.new()
			cyl.top_radius = 1.8
			cyl.bottom_radius = 1.8
			cyl.height = 0.68
			mesh = cyl
			color = Color(0.20, 0.78, 0.98, 1.0)
		"resource":
			var sphere := SphereMesh.new()
			sphere.radius = 1.7
			sphere.height = 3.4
			mesh = sphere
			color = Color(0.36, 0.95, 0.42, 1.0)
		_:
			var fallback := BoxMesh.new()
			fallback.size = Vector3(3.4, 0.7, 3.4)
			mesh = fallback
			color = Color(0.95, 0.95, 0.95, 1.0)
	_lod_icon.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.35
	mat.no_depth_test = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	_lod_icon.material_override = mat

func _load_lod_icon_texture(icon_kind: String) -> Texture2D:
	if _lod_icon_texture_cache.has(icon_kind):
		return _lod_icon_texture_cache[icon_kind] as Texture2D
	var path: String = String(LOD_ICON_TEXTURE_PATHS.get(icon_kind, "")).strip_edges()
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		return null
	var tex := load(path) as Texture2D
	if tex != null:
		_lod_icon_texture_cache[icon_kind] = tex
	return tex

func _apply_lod_point_style() -> void:
	if _lod_point == null:
		return
	var dot := CylinderMesh.new()
	dot.top_radius = 1.1
	dot.bottom_radius = 1.1
	dot.height = 0.24
	_lod_point.mesh = dot
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.9, 0.9, 1.0)
	mat.roughness = 0.5
	mat.metallic = 0.02
	_lod_point.material_override = mat

func _update_lod_marker_transform() -> void:
	var base_h: float = maxf(label_height, 8.0)
	if _lod_icon != null:
		_lod_icon.position = Vector3(0.0, maxf(14.0, base_h * 1.25), 0.0)
	if _lod_point != null:
		_lod_point.position = Vector3(0.0, maxf(8.0, base_h * 0.75), 0.0)
