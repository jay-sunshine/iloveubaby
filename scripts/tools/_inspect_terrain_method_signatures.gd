extends SceneTree
func _init():
	var scene: PackedScene = load("res://scenes/china_terrain_30km.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var data = inst.get_node("Terrain3D").get("data")
	for target in ["set_control_auto","set_control_base_id","set_control_overlay_id","set_control_blend","set_control","get_control_auto"]:
		for m in data.get_method_list():
			if String(m.name) == target:
				print("METHOD:", target, " -> ", m)
	quit()
