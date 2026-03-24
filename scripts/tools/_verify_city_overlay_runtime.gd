extends SceneTree

func _init() -> void:
	var scene: PackedScene = load("res://scenes/china_terrain_30km.tscn")
	print("scene_loaded=", scene != null)
	if scene == null:
		quit(1)
		return
	var root: Node = scene.instantiate()
	var overlay = root.get_node_or_null("CityOverlay")
	print("overlay_found=", overlay != null)
	if overlay == null:
		quit(2)
		return
	overlay.call("_rebuild_overlay")
	var inst_root = overlay.get_node_or_null("CityInstances")
	print("child_count=", inst_root.get_child_count() if inst_root != null else -1)
	if inst_root != null and inst_root.get_child_count() > 0:
		var luoyang = inst_root.get_node_or_null("City_洛阳")
		if luoyang != null:
			print("luoyang_pos=", luoyang.position)
			var label = luoyang.get_node_or_null("CityLabel")
			if label != null:
				print("label_visible=", label.visible)
				print("label_font=", label.font_size)
				print("label_pixel=", label.pixel_size)
	quit()