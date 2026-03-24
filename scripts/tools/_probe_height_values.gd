extends SceneTree
func _init():
	call_deferred("_run")
func _run():
	var region = load("res://data/terrain/china_30km/terrain_data/terrain3d_00_00.res")
	var img: Image = region.get_height_map()
	var min_v := 1e20
	var max_v := -1e20
	for y in [0, img.get_height()/2, img.get_height()-1]:
		for x in [0, img.get_width()/2, img.get_width()-1]:
			print("px", x, y, "=", img.get_pixel(x,y))
	for y in range(0, img.get_height(), 16):
		for x in range(0, img.get_width(), 16):
			var v = img.get_pixel(x,y).r
			min_v = min(min_v, v)
			max_v = max(max_v, v)
	print("min=", min_v, " max=", max_v, " format=", img.get_format())
	quit()
