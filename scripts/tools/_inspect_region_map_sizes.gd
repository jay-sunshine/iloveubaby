extends SceneTree
func _init():
	var region = load("res://data/terrain/china_30km/terrain_data/terrain3d_00_00.res")
	var control: Image = region.get_control_map()
	var height: Image = region.get_height_map()
	print("HEIGHT ", height.get_width(), "x", height.get_height(), " format=", height.get_format())
	print("CONTROL ", control.get_width(), "x", control.get_height(), " format=", control.get_format())
	print("CONTROL PIXEL 0,0:", control.get_pixel(0,0))
	quit()
