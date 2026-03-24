extends SceneTree
func _init():
	print("START")
	call_deferred("_run")
func _run():
	var camera := Camera3D.new()
	camera.current = true
	get_root().add_child(camera)
	var terrain = ClassDB.instantiate("Terrain3D")
	terrain.set_data_directory("res://data/terrain/china_30km/terrain_data")
	get_root().add_child(terrain)
	await process_frame
	await process_frame
	var data = terrain.get_data()
	var pos := Vector3(0, 0, 0)
	print("before control:", data.get_control(pos), " auto=", data.get_control_auto(pos), " base=", data.get_control_base_id(pos), " over=", data.get_control_overlay_id(pos), " blend=", data.get_control_blend(pos))
	data.set_control_base_id(pos, 0)
	data.set_control_overlay_id(pos, 1)
	data.set_control_blend(pos, 0.5)
	data.set_control_auto(pos, true)
	print("after control:", data.get_control(pos), " auto=", data.get_control_auto(pos), " base=", data.get_control_base_id(pos), " over=", data.get_control_overlay_id(pos), " blend=", data.get_control_blend(pos))
	var region = data.get_region(pos)
	print("region:", region.get_location())
	var img: Image = region.get_control_map()
	print("pixel00:", img.get_pixel(0,0))
	quit()
