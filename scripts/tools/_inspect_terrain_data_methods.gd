extends SceneTree
func _init():
	var scene: PackedScene = load("res://scenes/china_terrain_30km.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var terrain = inst.get_node("Terrain3D")
	print("TERRAIN CLASS:", terrain.get_class())
	var data = terrain.get("data")
	print("DATA CLASS:", data.get_class())
	for m in data.get_method_list():
		var n = String(m.name)
		if n.contains("control") or n.contains("pixel") or n.contains("region") or n.contains("image"):
			print(n)
	quit()
