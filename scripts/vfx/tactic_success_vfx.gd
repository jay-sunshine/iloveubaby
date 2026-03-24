extends Node3D

@export var ring_path: NodePath = NodePath("Ring")
@export var core_path: NodePath = NodePath("Core")
@export var beam_a_path: NodePath = NodePath("BeamA")
@export var beam_b_path: NodePath = NodePath("BeamB")
@export var flash_path: NodePath = NodePath("Flash")
@export var dust_nodes: Array[NodePath] = [NodePath("DustA"), NodePath("DustB"), NodePath("DustC")]

var ring_node: MeshInstance3D = null
var core_node: MeshInstance3D = null
var beam_a_node: MeshInstance3D = null
var beam_b_node: MeshInstance3D = null
var flash_node: MeshInstance3D = null
var dust_meshes: Array[MeshInstance3D] = []
var ring_material: StandardMaterial3D = null
var core_material: StandardMaterial3D = null
var beam_a_material: StandardMaterial3D = null
var beam_b_material: StandardMaterial3D = null
var flash_material: StandardMaterial3D = null
var dust_materials: Array[StandardMaterial3D] = []

var active_timer: float = 0.0
var active_total: float = 0.0
var active_skill_id: int = 0
var base_color: Color = Color(1.0, 0.9, 0.42, 1.0)

func _ready() -> void:
	top_level = true
	ring_node = get_node_or_null(ring_path) as MeshInstance3D
	core_node = get_node_or_null(core_path) as MeshInstance3D
	beam_a_node = get_node_or_null(beam_a_path) as MeshInstance3D
	beam_b_node = get_node_or_null(beam_b_path) as MeshInstance3D
	flash_node = get_node_or_null(flash_path) as MeshInstance3D
	ring_material = _dup_material(ring_node)
	core_material = _dup_material(core_node)
	beam_a_material = _dup_material(beam_a_node)
	beam_b_material = _dup_material(beam_b_node)
	flash_material = _dup_material(flash_node)
	for node_path in dust_nodes:
		var dust_node: MeshInstance3D = get_node_or_null(node_path) as MeshInstance3D
		if dust_node == null:
			continue
		dust_meshes.append(dust_node)
		dust_materials.append(_dup_material(dust_node))
	visible = false
	set_process(true)

func play(skill_id: int, world_center: Vector3, forward_dir: Vector3, scale_mul: float, tint: Color, total_duration: float) -> void:
	active_skill_id = skill_id
	active_total = maxf(0.1, total_duration)
	active_timer = active_total
	base_color = tint
	visible = true
	global_position = world_center
	var flat_forward: Vector3 = Vector3(forward_dir.x, 0.0, forward_dir.z)
	if flat_forward.length_squared() > 0.0001:
		global_basis = Basis.looking_at(flat_forward.normalized(), Vector3.UP, true)
	scale = Vector3.ONE * maxf(0.4, scale_mul)
	_update_visual(0.0)

func _process(delta: float) -> void:
	if active_timer <= 0.0:
		if visible:
			visible = false
		return
	active_timer = maxf(0.0, active_timer - maxf(0.0, delta))
	var progress: float = clampf(1.0 - active_timer / maxf(0.001, active_total), 0.0, 1.0)
	_update_visual(progress)
	if active_timer <= 0.0:
		visible = false

func _update_visual(progress: float) -> void:
	var ring_alpha: float = (1.0 - progress) * 0.95
	var core_alpha: float = clampf((1.0 - progress * 0.7) * 0.85, 0.0, 1.0)
	var flash_window: float = clampf(1.0 - progress * 4.2, 0.0, 1.0)
	var gold_window: float = clampf((progress - 0.08) / 0.5, 0.0, 1.0)
	var beam_alpha: float = clampf((1.0 - progress) * 0.75, 0.0, 1.0)
	var dust_alpha: float = clampf((1.0 - progress * 0.9) * 0.55, 0.0, 1.0)
	if ring_node != null:
		ring_node.scale = Vector3(0.7 + progress * 1.5, 1.0, 0.7 + progress * 1.5)
		ring_node.rotation.y = progress * PI * 0.7
	if core_node != null:
		core_node.scale = Vector3(0.75 + progress * 0.55, 1.0, 0.75 + progress * 0.55)
	if beam_a_node != null:
		beam_a_node.scale = Vector3(1.0, 0.65 + progress * 1.5, 1.0)
		beam_a_node.rotation.y = progress * PI * 0.35
	if beam_b_node != null:
		beam_b_node.scale = Vector3(1.0, 0.55 + progress * 1.25, 1.0)
		beam_b_node.rotation.y = -progress * PI * 0.28
	if flash_node != null:
		flash_node.scale = Vector3(0.8 + progress * 1.2, 0.8 + progress * 1.2, 1.0)
	for i in range(dust_meshes.size()):
		var dust_node: MeshInstance3D = dust_meshes[i]
		if dust_node == null:
			continue
		var dir_sign: float = -1.0 if i == 0 else (1.0 if i == 1 else 0.0)
		dust_node.position = Vector3(dir_sign * (0.35 + progress * 1.2), 0.03, 0.32 + progress * 1.45)
		dust_node.scale = Vector3(1.0 + progress * 1.6, 1.0, 0.8 + progress * 1.3)
	_apply_color(ring_alpha, core_alpha, beam_alpha, flash_window, gold_window, dust_alpha)

func _apply_color(ring_alpha: float, core_alpha: float, beam_alpha: float, flash_window: float, gold_window: float, dust_alpha: float) -> void:
	var ring_color: Color = base_color.lerp(Color(1.0, 0.96, 0.76, 1.0), 0.18)
	var core_color: Color = base_color.lerp(Color(1.0, 0.98, 0.84, 1.0), 0.35)
	if ring_material != null:
		ring_material.albedo_color = Color(ring_color.r, ring_color.g, ring_color.b, ring_alpha)
		ring_material.emission = ring_color
	if core_material != null:
		core_material.albedo_color = Color(core_color.r, core_color.g, core_color.b, core_alpha)
		core_material.emission = core_color
	if beam_a_material != null:
		beam_a_material.albedo_color = Color(ring_color.r, ring_color.g, ring_color.b, beam_alpha)
		beam_a_material.emission = ring_color
	if beam_b_material != null:
		beam_b_material.albedo_color = Color(core_color.r, core_color.g, core_color.b, beam_alpha * 0.82)
		beam_b_material.emission = core_color
	if flash_material != null:
		var flash_color: Color = Color(1.0, 1.0, 1.0, flash_window).lerp(Color(1.0, 0.88, 0.34, 0.45), gold_window)
		flash_material.albedo_color = flash_color
		flash_material.emission = Color(1.0, 0.96, 0.9, 1.0).lerp(Color(1.0, 0.84, 0.26, 1.0), gold_window)
	for i in range(dust_materials.size()):
		var dust_material: StandardMaterial3D = dust_materials[i]
		if dust_material == null:
			continue
		var dust_color: Color = Color(0.72, 0.64, 0.52, dust_alpha)
		dust_material.albedo_color = dust_color
		dust_material.emission = Color(base_color.r, base_color.g, base_color.b, 1.0)

func _dup_material(node: MeshInstance3D) -> StandardMaterial3D:
	if node == null:
		return null
	var base_material: Material = node.material_override
	if base_material == null:
		return null
	var dup: Material = base_material.duplicate()
	node.material_override = dup
	return dup as StandardMaterial3D