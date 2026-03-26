@tool
extends Node3D

@export var bark_roughness: float = 0.97
@export var bark_metallic: float = 0.0
@export var bark_tint: Color = Color(1, 1, 1, 1)
@export var leaf_tint: Color = Color(1, 1, 1, 1)
@export var leaf_alpha_scissor: float = 0.34
@export var leaf_backlight: Color = Color(0.72, 0.74, 0.68, 1.0)
@export var leaf_roughness: float = 0.95
@export var leaf_specular: float = 0.45
@export var leaf_disable_receive_shadows: bool = false
@export var leaf_disable_cast_shadows: bool = false
@export var leaf_transmittance_depth: float = 0.28

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
			tuned.albedo_color = leaf_tint
			tuned.roughness = leaf_roughness
			tuned.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
			tuned.specular = leaf_specular
			tuned.disable_receive_shadows = leaf_disable_receive_shadows
			tuned.transmittance_enabled = true
			tuned.transmittance_color = leaf_backlight
			tuned.transmittance_depth = leaf_transmittance_depth
			if leaf_disable_cast_shadows:
				mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			else:
				mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		else:
			tuned.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			tuned.cull_mode = BaseMaterial3D.CULL_BACK
			tuned.roughness = bark_roughness
			tuned.metallic = bark_metallic
			tuned.albedo_color = bark_tint
		mesh_instance.set_surface_override_material(surface_idx, tuned)