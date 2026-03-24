@tool
extends Node3D

@export var terrain_path: NodePath = NodePath("../Terrain3D")

var _snap_queued: bool = false

func _enter_tree() -> void:
	set_notify_transform(true)
	_queue_snap()

func _ready() -> void:
	set_notify_transform(true)
	_queue_snap()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		_queue_snap()

func _queue_snap() -> void:
	if _snap_queued:
		return
	_snap_queued = true
	call_deferred("_apply_snap")

func _apply_snap() -> void:
	_snap_queued = false
	_snap_all_children_to_terrain()

func _snap_all_children_to_terrain() -> void:
	var terrain := get_node_or_null(terrain_path)
	if terrain == null:
		return
	var terrain_data: Variant = terrain.get("data")
	if terrain_data == null or not terrain_data.has_method("get_height"):
		return
	for child in get_children():
		if not (child is Node3D):
			continue
		var tree := child as Node3D
		var world_pos := tree.global_position
		world_pos.y = float(terrain_data.call("get_height", Vector3(world_pos.x, 0.0, world_pos.z)))
		tree.global_position = world_pos