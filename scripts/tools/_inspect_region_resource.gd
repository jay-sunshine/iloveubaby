extends SceneTree
func _init():
	var region = load("res://data/terrain/china_30km/terrain_data/terrain3d_00_00.res")
	print("REGION:", region)
	print("CLASS:", region.get_class())
	for p in region.get_property_list():
		var n = String(p.name)
		if n.contains("map") or n.contains("image") or n.contains("control") or n.contains("height") or n.contains("location"):
			print("PROP:", n, " type=", p.type)
	for m in region.get_method_list():
		var n = String(m.name)
		if n.contains("map") or n.contains("image") or n.contains("control") or n.contains("save") or n.contains("location"):
			print("METHOD:", n)
	quit()
