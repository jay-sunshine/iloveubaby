extends SceneTree
func _init():
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
	for m in terrain.get_data().get_method_list():
		if String(m.name) == "set_region_modified":
			print(m)
	quit()
