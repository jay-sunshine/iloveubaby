@tool
extends Node3D

const TREE_SCENE_PATH := "res://scenes/prefabs/vegetation/black_pine_tree_b_lod0.tscn"
const LUOYANG_WORLD_X := 3894.0
const LUOYANG_WORLD_Z := 3988.0
const SAMPLE_OFFSETS := [
	Vector3(68.0, 0.0, 42.0),
	Vector3(112.0, 0.0, -36.0),
	Vector3(-58.0, 0.0, 74.0)
]
const SAMPLE_ROTATIONS := [18.0, -34.0, 57.0]
const SAMPLE_SCALES := [0.96, 1.08, 0.9]

func _ready() -> void:
	if get_child_count() > 0:
		return
	_spawn_samples()

func _spawn_samples() -> void:
	var tree_scene := load(TREE_SCENE_PATH) as PackedScene
	if tree_scene == null:
		push_warning("JapaneseTreeSampleSpawner missing tree scene: %s" % TREE_SCENE_PATH)
		return
	var terrain := get_parent().get_node_or_null("Terrain3D")
	for idx in range(SAMPLE_OFFSETS.size()):
		var inst := tree_scene.instantiate()
		if not (inst is Node3D):
			continue
		var tree := inst as Node3D
		var world_pos: Vector3 = Vector3(LUOYANG_WORLD_X, 0.0, LUOYANG_WORLD_Z) + SAMPLE_OFFSETS[idx]
		world_pos.y = _sample_ground_height(terrain, world_pos)
		tree.position = world_pos
		tree.rotation_degrees.y = SAMPLE_ROTATIONS[idx]
		tree.scale = Vector3.ONE * SAMPLE_SCALES[idx]
		tree.name = "JapaneseBlackPine_%d" % (idx + 1)
		_apply_perf_tuning(tree)
		add_child(tree)
		_own_node_for_editor(tree)

func _sample_ground_height(terrain: Node, world_pos: Vector3) -> float:
	if terrain == null:
		return 0.0
	var terrain_data: Variant = terrain.get("data")
	if terrain_data != null and terrain_data.has_method("get_height"):
		return float(terrain_data.call("get_height", world_pos))
	return 0.0

func _apply_perf_tuning(node: Node) -> void:
	if node is GeometryInstance3D:
		var gi := node as GeometryInstance3D
		gi.visibility_range_begin = 0.0
		gi.visibility_range_end = 6500.0
		gi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	if node is MeshInstance3D:
		(node as MeshInstance3D).extra_cull_margin = 24.0
	for child in node.get_children():
		_apply_perf_tuning(child)

func _own_node_for_editor(node: Node) -> void:
	if node == null or not Engine.is_editor_hint():
		return
	var tree := get_tree()
	if tree == null:
		return
	var edited_root := tree.edited_scene_root
	if edited_root != null:
		node.owner = edited_root

