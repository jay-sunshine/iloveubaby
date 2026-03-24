@tool
extends Node3D

const GREEN_TREE_SCENE_PATH := "res://scenes/prefabs/vegetation/black_pine_tree_b_batch_light.tscn"
const BLOSSOM_TREE_SCENE_PATH := "res://scenes/prefabs/vegetation/sakura_tree_a_batch_light.tscn"
const BASE_VISUAL_SCALE := 5.0
const SAMPLE_CONFIGS := [
	{
		"scene_path": GREEN_TREE_SCENE_PATH,
		"name": "GreenTree_01",
		"position": Vector3(-28.0, 0.0, 18.0),
		"rotation_y": 12.0,
		"visual_scale": 4.2
	},
	{
		"scene_path": GREEN_TREE_SCENE_PATH,
		"name": "GreenTree_02",
		"position": Vector3(24.0, 0.0, -10.0),
		"rotation_y": -33.0,
		"visual_scale": 4.8
	},
	{
		"scene_path": GREEN_TREE_SCENE_PATH,
		"name": "GreenTree_03",
		"position": Vector3(-4.0, 0.0, -26.0),
		"rotation_y": 48.0,
		"visual_scale": 5.3
	},
	{
		"scene_path": GREEN_TREE_SCENE_PATH,
		"name": "GreenTree_04",
		"position": Vector3(32.0, 0.0, 26.0),
		"rotation_y": 87.0,
		"visual_scale": 6.0
	},
	{
		"scene_path": BLOSSOM_TREE_SCENE_PATH,
		"name": "BlossomTree_01",
		"position": Vector3(-36.0, 0.0, -6.0),
		"rotation_y": -18.0,
		"visual_scale": 4.6
	},
	{
		"scene_path": BLOSSOM_TREE_SCENE_PATH,
		"name": "BlossomTree_02",
		"position": Vector3(10.0, 0.0, 34.0),
		"rotation_y": 26.0,
		"visual_scale": 5.5
	}
]

func _ready() -> void:
	if get_child_count() > 0:
		return
	_spawn_samples()

func _spawn_samples() -> void:
	for config_any in SAMPLE_CONFIGS:
		if not (config_any is Dictionary):
			continue
		var config := config_any as Dictionary
		var scene_path := String(config.get("scene_path", "")).strip_edges()
		var packed := load(scene_path) as PackedScene
		if packed == null:
			push_warning("JapaneseTreeBatchSampleSpawner missing tree scene: %s" % scene_path)
			continue
		var inst := packed.instantiate()
		if not (inst is Node3D):
			continue
		var tree := inst as Node3D
		tree.name = String(config.get("name", "TreeSample")).strip_edges()
		tree.position = config.get("position", Vector3.ZERO)
		tree.rotation_degrees.y = float(config.get("rotation_y", 0.0))
		var visual_scale := maxf(0.1, float(config.get("visual_scale", BASE_VISUAL_SCALE)))
		var relative_scale := visual_scale / BASE_VISUAL_SCALE
		tree.scale = Vector3.ONE * relative_scale
		add_child(tree)
		_own_node_for_editor(tree)

func _own_node_for_editor(node: Node) -> void:
	if node == null or not Engine.is_editor_hint():
		return
	var tree := get_tree()
	if tree == null:
		return
	var edited_root := tree.edited_scene_root
	if edited_root != null:
		node.owner = edited_root