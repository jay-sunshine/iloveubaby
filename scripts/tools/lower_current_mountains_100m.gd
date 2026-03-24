extends SceneTree

const TERRAIN_DATA_DIR := "res://data/terrain/china_30km/terrain_data"
const MOUNTAIN_START_H := 100.0
const LOWER_METERS := 100.0
const PRESERVE_COAST_BELOW := 24.0

func _initialize() -> void:
	process_frame.connect(Callable(self, "_run"), CONNECT_ONE_SHOT)

func _run() -> void:
	var dir := DirAccess.open(TERRAIN_DATA_DIR)
	if dir == null:
		push_error("Cannot open terrain dir: %s" % TERRAIN_DATA_DIR)
		quit(ERR_CANT_OPEN)
		return

	var names: Array[String] = []
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name.is_empty():
			break
		if dir.current_is_dir():
			continue
		if name.ends_with(".res"):
			names.append(name)
	dir.list_dir_end()
	names.sort()

	for name in names:
		_process_region(TERRAIN_DATA_DIR.path_join(name))

	quit()

func _process_region(region_path: String) -> void:
	var region: Resource = load(region_path)
	if region == null:
		return
	var height_map: Image = region.call("get_height_map")
	if height_map == null:
		return
	var width: int = height_map.get_width()
	var height: int = height_map.get_height()
	for y in range(height):
		for x in range(width):
			var h: float = height_map.get_pixel(x, y).r
			if h < 0.0:
				continue
			if h <= PRESERVE_COAST_BELOW:
				continue
			if h >= MOUNTAIN_START_H:
				h = maxf(MOUNTAIN_START_H, h - LOWER_METERS)
				height_map.set_pixel(x, y, Color(h, 0.0, 0.0, 1.0))
	region.call("set_height_map", height_map)
	var err: int = ResourceSaver.save(region, region_path)
	if err != OK:
		push_warning("Save failed: %s err=%d" % [region_path, err])
