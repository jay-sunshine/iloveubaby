extends SceneTree
func _initialize():
	process_frame.connect(_run, CONNECT_ONE_SHOT)
func _run():
	var terrain = ClassDB.instantiate("Terrain3D")
	get_root().add_child(terrain)
	terrain.set_data_directory("res://data/terrain/china_30km/terrain_data")
	await process_frame
	await process_frame
	var data = terrain.get_data()
	print("REGIONS:", data.get_region_count())
	if data.get_region_count() > 0:
		var r = data.get_regions_active()[0]
		print("FIRST REGION:", r.get_location())
	quit()
