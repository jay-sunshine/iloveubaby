extends SceneTree
func _init():
	call_deferred("_run")
func _decode_control(value: float) -> int:
	var bytes := PackedByteArray()
	bytes.resize(4)
	bytes.encode_float(0, value)
	return bytes.decode_u32(0)
func _run():
	var dir = DirAccess.open("res://data/terrain/china_30km/terrain_data")
	var files: Array[String] = []
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name.is_empty():
			break
		if name.ends_with(".res"):
			files.append("res://data/terrain/china_30km/terrain_data/" + name)
	dir.list_dir_end()
	var grass := 0
	var rock := 0
	var sea := 0
	for path in files:
		var region = load(path)
		var h: Image = region.get_height_map()
		var c: Image = region.get_control_map()
		for y in range(0, h.get_height(), 16):
			for x in range(0, h.get_width(), 16):
				var hv = h.get_pixel(x, y).r
				var cv = _decode_control(c.get_pixel(x, y).r)
				var base = int((cv >> 27) & 0x1F)
				if hv < 0.0:
					sea += 1
				elif base == 0:
					grass += 1
				else:
					rock += 1
	print("grass=", grass, " rock=", rock, " sea=", sea)
	quit()
