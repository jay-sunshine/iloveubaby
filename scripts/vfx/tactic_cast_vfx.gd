extends Node3D

@export var ring_path: NodePath = NodePath("Ring")
@export var trail_path: NodePath = NodePath("Trail")
@export var dust_path: NodePath = NodePath("Dust")

var ring_node: MeshInstance3D = null
var trail_node: MeshInstance3D = null
var dust_node: MeshInstance3D = null
var ring_material: StandardMaterial3D = null
var trail_material: StandardMaterial3D = null
var dust_material: StandardMaterial3D = null

var active_timer: float = 0.0
var active_total: float = 0.0
var active_skill_id: int = 0
var active_executing: bool = false
var active_color: Color = Color(1.0, 0.8, 0.2, 0.9)
var crit_flash: float = 0.0

func _ready() -> void:
	ring_node = get_node_or_null(ring_path) as MeshInstance3D
	trail_node = get_node_or_null(trail_path) as MeshInstance3D
	dust_node = get_node_or_null(dust_path) as MeshInstance3D
	ring_material = _dup_material(ring_node)
	trail_material = _dup_material(trail_node)
	dust_material = _dup_material(dust_node)
	visible = false
	set_process(true)

func play(skill_id: int, executing: bool, total_duration: float, tint: Color) -> void:
	active_skill_id = skill_id
	active_executing = executing
	active_total = maxf(0.1, total_duration)
	active_timer = active_total
	active_color = tint
	crit_flash = 0.0
	visible = true
	scale = Vector3.ONE
	_apply_color(active_color)
	_update_visual(0.0)

func stop() -> void:
	active_timer = 0.0
	active_total = 0.0
	visible = false

func boost_crit_flash() -> void:
	crit_flash = 1.0
	active_timer = maxf(active_timer, 0.12)
	active_color = active_color.lerp(Color(1.0, 0.95, 0.68, 1.0), 0.45)
	_apply_color(active_color)

func _process(delta: float) -> void:
	if active_timer <= 0.0:
		if visible:
			visible = false
		return
	active_timer = maxf(0.0, active_timer - maxf(0.0, delta))
	crit_flash = maxf(0.0, crit_flash - delta * 4.0)
	var progress: float = clampf(1.0 - active_timer / maxf(0.001, active_total), 0.0, 1.0)
	_update_visual(progress)
	if active_timer <= 0.0:
		visible = false

func _update_visual(progress: float) -> void:
	var pulse: float = 1.0 + sin(progress * PI * 3.0) * 0.08 + crit_flash * 0.1
	var ring_scale := Vector3.ONE
	var trail_scale := Vector3.ONE
	var dust_scale := Vector3.ONE
	if active_executing:
		match active_skill_id:
			1:
				ring_scale = Vector3(1.05 + progress * 1.45, 1.0, 1.9 + progress * 8.4)
				trail_scale = Vector3(0.95 + progress * 0.55, 1.0, 2.1 + progress * 8.2)
				dust_scale = Vector3(1.2 + progress * 1.4, 1.0, 1.6 + progress * 3.8)
			2:
				ring_scale = Vector3(0.52 + progress * 0.46, 1.0, 2.4 + progress * 10.8)
				trail_scale = Vector3(0.7 + progress * 0.42, 1.0, 3.0 + progress * 9.4)
				dust_scale = Vector3(1.0 + progress * 1.2, 1.0, 2.1 + progress * 4.4)
			3:
				ring_scale = Vector3(4.6 + progress * 10.2, 1.0, 1.55 + progress * 3.6)
				trail_scale = Vector3(2.1 + progress * 4.6, 1.0, 2.0 + progress * 1.8)
				dust_scale = Vector3(1.8 + progress * 2.0, 1.0, 2.2 + progress * 1.6)
			_:
				ring_scale = Vector3(1.2 + progress * 2.0, 1.0, 1.8 + progress * 3.6)
				trail_scale = Vector3(1.2 + progress * 1.8, 1.0, 2.2 + progress * 4.8)
				dust_scale = Vector3(1.3 + progress * 1.5, 1.0, 2.0 + progress * 2.2)
	else:
		match active_skill_id:
			1:
				ring_scale = Vector3(1.08 + progress * 0.28, 1.0, 1.55 + progress * 1.35) * pulse
				trail_scale = Vector3(0.9 + progress * 0.18, 1.0, 1.65 + progress * 1.7) * pulse
				dust_scale = Vector3(1.0 + progress * 0.28, 1.0, 1.2 + progress * 0.8) * pulse
			2:
				ring_scale = Vector3(0.62 + progress * 0.15, 1.0, 1.95 + progress * 1.65) * pulse
				trail_scale = Vector3(0.72 + progress * 0.18, 1.0, 2.05 + progress * 1.8) * pulse
				dust_scale = Vector3(1.0 + progress * 0.22, 1.0, 1.6 + progress * 0.9) * pulse
			3:
				ring_scale = Vector3(3.4 + progress * 2.25, 1.0, 1.38 + progress * 0.9) * pulse
				trail_scale = Vector3(2.4 + progress * 0.9, 1.0, 1.8 + progress * 0.8) * pulse
				dust_scale = Vector3(1.4 + progress * 0.45, 1.0, 1.6 + progress * 0.5) * pulse
			_:
				ring_scale = Vector3.ONE * pulse
				trail_scale = Vector3(1.2, 1.0, 1.6) * pulse
				dust_scale = Vector3.ONE * pulse
	if ring_node != null:
		ring_node.scale = ring_scale
	if trail_node != null:
		trail_node.scale = trail_scale
	if dust_node != null:
		dust_node.scale = dust_scale
	var alpha: float = active_color.a * (1.0 - progress * 0.82)
	var color: Color = Color(active_color.r, active_color.g, active_color.b, alpha + crit_flash * 0.08)
	_apply_color(color)

func _apply_color(color: Color) -> void:
	if ring_material != null:
		ring_material.albedo_color = color
		ring_material.emission = Color(color.r, color.g, color.b, 1.0)
	if trail_material != null:
		trail_material.albedo_color = Color(color.r, color.g, color.b, color.a * 0.85)
		trail_material.emission = Color(color.r, color.g, color.b, 1.0)
	if dust_material != null:
		var dust_color: Color = color.lerp(Color(0.78, 0.72, 0.58, color.a), 0.42)
		dust_material.albedo_color = Color(dust_color.r, dust_color.g, dust_color.b, color.a * 0.5)
		dust_material.emission = Color(color.r, color.g, color.b, 1.0)

func _dup_material(node: MeshInstance3D) -> StandardMaterial3D:
	if node == null:
		return null
	var base_material: Material = node.material_override
	if base_material == null:
		return null
	var dup: Material = base_material.duplicate()
	node.material_override = dup
	return dup as StandardMaterial3D