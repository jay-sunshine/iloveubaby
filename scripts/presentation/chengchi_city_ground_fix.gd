@tool
extends Node3D

const GROUND_FIX_MATERIAL_PATH := "res://scenes/materials/chengchi_city_ground_fix.tres"

var _ground_fix_material: Material = null

func _ready() -> void:
	_apply_ground_fix()

func _apply_ground_fix() -> void:
	if _ground_fix_material == null:
		_ground_fix_material = load(GROUND_FIX_MATERIAL_PATH) as Material
	if _ground_fix_material == null:
		push_warning("Cannot load city ground fix material: %s" % GROUND_FIX_MATERIAL_PATH)
		return
	_apply_material_to_meshes(self)

func _apply_material_to_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			(child as MeshInstance3D).material_override = _ground_fix_material
		_apply_material_to_meshes(child)
