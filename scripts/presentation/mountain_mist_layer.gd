extends Node3D

const CLOUD_TEXTURE := preload("res://素材/brackeys_vfx_bundle/particles/alpha/smoke_07_a.png")
const MIST_ANCHORS := [
	{"xz": Vector2(800.0, 2600.0), "height_offset": 180.0, "width": 1100.0, "depth": 520.0, "alpha": 0.16},
	{"xz": Vector2(1800.0, 4200.0), "height_offset": 220.0, "width": 1300.0, "depth": 620.0, "alpha": 0.17},
	{"xz": Vector2(2600.0, 5600.0), "height_offset": 240.0, "width": 1400.0, "depth": 680.0, "alpha": 0.15},
	{"xz": Vector2(3600.0, 4700.0), "height_offset": 210.0, "width": 1250.0, "depth": 600.0, "alpha": 0.17},
	{"xz": Vector2(4800.0, 3300.0), "height_offset": 200.0, "width": 1200.0, "depth": 560.0, "alpha": 0.16},
	{"xz": Vector2(6200.0, 5200.0), "height_offset": 230.0, "width": 1500.0, "depth": 720.0, "alpha": 0.15},
	{"xz": Vector2(7200.0, 6800.0), "height_offset": 250.0, "width": 1450.0, "depth": 700.0, "alpha": 0.14}
]

@export var terrain_path: NodePath = ^"../Terrain3D"
@export var min_terrain_height: float = 900.0
@export var bob_amplitude: float = 12.0
@export var bob_speed: float = 0.08

var _terrain: Node3D = null
var _cards: Array[Node3D] = []
var _time_accum: float = 0.0

func _ready() -> void:
	_terrain = get_node_or_null(terrain_path) as Node3D
	if _terrain == null:
		push_warning("MountainMistLayer missing terrain reference.")
		return
	_build_cards()
	_refresh_layout(true)

func _process(delta: float) -> void:
	if _cards.is_empty():
		return
	_time_accum += delta
	for entry_any in _cards:
		if not (entry_any is Node3D):
			continue
		var card_root := entry_any as Node3D
		var base_y: float = float(card_root.get_meta("base_y", card_root.position.y))
		var phase: float = float(card_root.get_meta("phase", 0.0))
		var drift: float = sin(_time_accum * bob_speed + phase) * bob_amplitude
		card_root.position.y = base_y + drift

func _build_cards() -> void:
	for child in get_children():
		child.queue_free()
	_cards.clear()
	for i in range(MIST_ANCHORS.size()):
		var spec: Dictionary = MIST_ANCHORS[i]
		var root := Node3D.new()
		root.name = "Mist_%02d" % i
		root.set_meta("anchor_xz", spec["xz"])
		root.set_meta("height_offset", spec["height_offset"])
		root.set_meta("phase", float(i) * 0.9)
		add_child(root)
		_cards.append(root)
		_add_card_mesh(root, float(spec["width"]), float(spec["depth"]), float(spec["alpha"]), 0.0, 0.0)
		_add_card_mesh(root, float(spec["width"]) * 0.78, float(spec["depth"]) * 0.92, float(spec["alpha"]) * 0.82, 120.0, 80.0)

func _add_card_mesh(root: Node3D, width: float, depth: float, alpha: float, yaw_deg: float, x_offset: float) -> void:
	var quad := QuadMesh.new()
	quad.size = Vector2(width, depth)
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.billboard_keep_scale = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = false
	material.albedo_texture = CLOUD_TEXTURE
	material.albedo_color = Color(0.92, 0.95, 0.98, alpha)
	material.distance_fade_mode = BaseMaterial3D.DISTANCE_FADE_PIXEL_ALPHA
	material.distance_fade_min_distance = 600.0
	material.distance_fade_max_distance = 1800.0
	quad.material = material
	var mesh := MeshInstance3D.new()
	mesh.mesh = quad
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.position = Vector3(x_offset, 0.0, 0.0)
	mesh.rotation_degrees = Vector3(0.0, yaw_deg, 0.0)
	root.add_child(mesh)

func _refresh_layout(force_hide_below_threshold: bool = false) -> void:
	if _terrain == null or not is_instance_valid(_terrain):
		return
	var data: Object = _terrain.call("get_data") if _terrain.has_method("get_data") else _terrain.get("data")
	if data == null:
		return
	for root_any in _cards:
		if not (root_any is Node3D):
			continue
		var root := root_any as Node3D
		var anchor_xz: Vector2 = root.get_meta("anchor_xz", Vector2.ZERO)
		var sample := Vector3(anchor_xz.x, 0.0, anchor_xz.y)
		var terrain_h: float = float(data.call("get_height", sample)) if data.has_method("get_height") else 0.0
		if force_hide_below_threshold and terrain_h < min_terrain_height:
			root.visible = false
			continue
		root.visible = true
		var target_y: float = terrain_h + float(root.get_meta("height_offset", 180.0))
		root.position = Vector3(anchor_xz.x, target_y, anchor_xz.y)
		root.set_meta("base_y", target_y)
