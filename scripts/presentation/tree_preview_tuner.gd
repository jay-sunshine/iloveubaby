@tool
extends Node3D

@export var bark_roughness: float = 0.95
@export var bark_metallic: float = 0.0
@export var leaf_alpha_scissor: float = 0.45
@export var leaf_backlight: Color = Color(0.68, 0.82, 0.58, 1.0)
@export var leaf_roughness: float = 0.9
@export var leaf_disable_receive_shadows: bool = true
@export var leaf_disable_cast_shadows: bool = true

func _ready() -> void:
	_tune_tree(self)

func _tune_tree(root: Node) -> void:
	for child in root.get_children():
		if child is MeshInstance3D:
			_tune_mesh(child as MeshInstance3D)
		_tune_tree(child)

func _tune_mesh(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance.mesh == null:
		return
	var surface_count := mesh_instance.mesh.get_surface_count()
	for surface_idx in range(surface_count):
		var original := mesh_instance.mesh.surface_get_material(surface_idx)
		if original == null:
			continue
		var tuned := original.duplicate() as StandardMaterial3D
		if tuned == null:
			continue
		var name_text := String(tuned.resource_name).to_lower()
		var is_leaf := name_text.contains("sprout") or name_text.contains("leaf")
		if is_leaf:
			tuned.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			tuned.alpha_scissor_threshold = leaf_alpha_scissor
			tuned.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE
			tuned.cull_mode = BaseMaterial3D.CULL_DISABLED
			tuned.backlight_enabled = true
			tuned.backlight = leaf_backlight
			tuned.roughness = leaf_roughness
			tuned.disable_receive_shadows = leaf_disable_receive_shadows
			tuned.transmittance_enabled = true
			tuned.transmittance_color = leaf_backlight
			tuned.transmittance_depth = 0.35
			if leaf_disable_cast_shadows:
				mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		else:
			tuned.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			tuned.cull_mode = BaseMaterial3D.CULL_BACK
			tuned.roughness = bark_roughness
			tuned.metallic = bark_metallic
		mesh_instance.set_surface_override_material(surface_idx, tuned)
