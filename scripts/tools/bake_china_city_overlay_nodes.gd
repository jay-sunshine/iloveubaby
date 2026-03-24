extends SceneTree

const SCENE_PATH := "res://scenes/china_terrain_30km.tscn"

func _init() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	if scene == null:
		push_error("scene load failed")
		quit(1)
		return
	var inst: Node = scene.instantiate()
	get_root().add_child(inst)
	var overlay: Node = inst.get_node_or_null("CityOverlay")
	if overlay == null:
		push_error("CityOverlay missing")
		quit(2)
		return
	if overlay.has_method("_rebuild_overlay"):
		overlay.call("_rebuild_overlay")
	await process_frame
	var edited_root: Node = inst
	_set_owner_recursive(overlay.get_node_or_null("CityModels"), edited_root)
	_set_owner_recursive(overlay.get_node_or_null("CityLabels"), edited_root)
	var packed := PackedScene.new()
	var err: int = packed.pack(inst)
	if err != OK:
		push_error("pack failed: %d" % err)
		quit(3)
		return
	err = ResourceSaver.save(packed, SCENE_PATH)
	print("baked city overlay, err=", err)
	quit(err)

func _set_owner_recursive(node: Node, owner_root: Node) -> void:
	if node == null:
		return
	node.owner = owner_root
	for child in node.get_children():
		if child is Node:
			_set_owner_recursive(child as Node, owner_root)