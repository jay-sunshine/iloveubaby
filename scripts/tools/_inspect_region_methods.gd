extends SceneTree
func _init():
	var scene: PackedScene = load("res://scenes/china_terrain_30km.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var data = inst.get_node("Terrain3D").get("data")
	var regions = data.get_regions_active()
	print("REGION COUNT:", regions.size())
	if regions.size() > 0:
		var region = regions[0]
		print("REGION CLASS:", region.get_class())
		for m in region.get_method_list():
			var n = String(m.name)
			if n.contains("map") or n.contains("image") or n.contains("control") or n.contains("save") or n.contains("load"):
				print(n)
	quit()
