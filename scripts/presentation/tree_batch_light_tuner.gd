@tool
extends Node3D

@export var bark_roughness: float = 1.0
@export var bark_metallic: float = 0.0
@export var leaf_alpha_scissor: float = 0.55
@export var leaf_roughness: float = 1.0
@export var use_double_sided_leaves: bool = false
@export var disable_receive_shadows: bool = true
@export var disable_cast_shadows: bool = true
@export var visibility_range_begin: float = 0.0
@export var visibility_range_end: float = 4200.0
@export var extra_cull_margin: float = 8.0

func _enter_tree() -> void:
	call_deferred("_tune_tree", self)

func _ready() -> void:
	call_deferred("_tune_tree", self)

func _tune_tree(root: Node) -> void:
	for child in root.get_children():
		if child is GeometryInstance3D:
			_tune_geometry(child as GeometryInstance3D)
		if child is MeshInstance3D:
			_tune_mesh(child as MeshInstance3D)
		_tune_tree(child)

func _tune_geometry(geometry_instance: GeometryInstance3D) -> void:
	geometry_instance.visibility_range_begin = visibility_range_begin
	geometry_instance.visibility_range_end = visibility_range_end
	geometry_instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	if disable_cast_shadows:
		geometry_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _tune_mesh(mesh_instance: MeshInstance3D) -> void:
	mesh_instance.extra_cull_margin = extra_cull_margin
	if mesh_instance.mesh == null:
		return
	var surface_count := mesh_instance.mesh.get_surface_count()
	for surface_idx in range(surface_count):
		var existing_override := mesh_instance.get_surface_override_material(surface_idx)
		var tuned := existing_override as StandardMaterial3D
		if tuned == null or not bool(tuned.get_meta("tree_batch_light_tuned", false)):
			var original := existing_override
			if original == null:
				original = mesh_instance.mesh.surface_get_material(surface_idx)
			if original == null:
				continue
			tuned = original.duplicate() as StandardMaterial3D
			if tuned == null:
				continue
			tuned.set_meta("tree_batch_light_tuned", true)
			mesh_instance.set_surface_override_material(surface_idx, tuned)
		var name_text := String(tuned.resource_name).to_lower()
		var is_leaf := name_text.contains("sprout") or name_text.contains("leaf")
		if is_leaf:
			tuned.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			tuned.alpha_scissor_threshold = leaf_alpha_scissor
			tuned.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_OFF
			tuned.cull_mode = BaseMaterial3D.CULL_DISABLED if use_double_sided_leaves else BaseMaterial3D.CULL_BACK
			tuned.backlight_enabled = false
			tuned.transmittance_enabled = false
			tuned.roughness = leaf_roughness
			tuned.disable_receive_shadows = disable_receive_shadows
		else:
			tuned.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			tuned.cull_mode = BaseMaterial3D.CULL_BACK
			tuned.roughness = bark_roughness
			tuned.metallic = bark_metallic
			tuned.disable_receive_shadows = false
