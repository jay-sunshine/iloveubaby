extends SceneTree
func _init():
	call_deferred("_run")
func _decode_control(value: float) -> int:
	var bytes := PackedByteArray()
	bytes.resize(4)
	bytes.encode_float(0, value)
	return bytes.decode_u32(0)
func _run():
	var targets = [
		"res://data/terrain/china_30km/terrain_data/terrain3d_00_00.res",
		"res://data/terrain/china_30km/terrain_data/terrain3d_05_05.res",
		"res://data/terrain/china_30km/terrain_data/terrain3d_10_10.res"
	]
	for path in targets:
		var region = load(path)
		if region == null:
			print(path, " missing")
			continue
		var h: Image = region.get_height_map()
		var c: Image = region.get_control_map()
		var pts = [Vector2i(16,16), Vector2i(128,128), Vector2i(240,240)]
		print("REGION ", path)
		for p in pts:
			var hv = h.get_pixelv(p).r
			var cv = _decode_control(c.get_pixelv(p).r)
			var base = int((cv >> 27) & 0x1F)
			var over = int((cv >> 22) & 0x1F)
			print(" p=", p, " h=", hv, " base=", base, " over=", over, " auto=", (cv & 0x1))
	quit()
