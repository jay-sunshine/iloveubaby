extends SceneTree
func _init():
	var terrain = ClassDB.instantiate("Terrain3D")
	print(terrain.get_class())
	for m in terrain.get_method_list():
		var n = String(m.name)
		if n.contains("data") or n.contains("directory") or n.contains("material") or n.contains("assets"):
			print(n)
	quit()
