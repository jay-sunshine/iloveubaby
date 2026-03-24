extends SceneTree

const TERRAIN_DATA_DIR := "res://data/terrain/china_30km/terrain_data"
const LOWLAND_MAX_H := 300.0
const MIDLAND_MAX_H := 600.0
const MOUNTAIN_COMPRESS_START := 600.0
const MOUNTAIN_COMPRESS_SCALE := 0.8
const PASSES := 4
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
		push_warning("Skip region: %s" % region_path)
		return
	var height_map: Image = region.call("get_height_map")
	if height_map == null:
		return

	var width: int = height_map.get_width()
	var height: int = height_map.get_height()
	var current := PackedFloat32Array()
	current.resize(width * height)
	for y in range(height):
		for x in range(width):
			current[y * width + x] = height_map.get_pixel(x, y).r

	var next := PackedFloat32Array()
	next.resize(width * height)

	for _pass in range(PASSES):
		for y in range(height):
			for x in range(width):
				var idx := y * width + x
				var source_h: float = current[idx]
				if source_h < 0.0:
					next[idx] = source_h
					continue
				if source_h <= PRESERVE_COAST_BELOW:
					next[idx] = source_h
					continue
				var min_h := source_h
				var max_h := source_h
				var sum_h := 0.0
				var count := 0.0
				for oy in range(-1, 2):
					var sy := clampi(y + oy, 0, height - 1)
					for ox in range(-1, 2):
						var sx := clampi(x + ox, 0, width - 1)
						var sample_h: float = current[sy * width + sx]
						sum_h += sample_h
						count += 1.0
						if sample_h < min_h:
							min_h = sample_h
						if sample_h > max_h:
							max_h = sample_h
				var mean_h: float = sum_h / count
				var relief: float = max_h - min_h
				var new_h: float = source_h

				if source_h <= LOWLAND_MAX_H:
					if relief <= 150.0:
						var plain_target: float = mean_h * 0.38
						new_h = lerpf(source_h, plain_target, 0.72)
					elif relief <= 220.0:
						new_h = lerpf(source_h, mean_h * 0.6, 0.46)
				elif source_h <= MIDLAND_MAX_H:
					if relief <= 200.0:
						new_h = lerpf(source_h, mean_h * 0.74, 0.34)
					elif relief <= 300.0:
						new_h = lerpf(source_h, mean_h * 0.84, 0.24)

				if new_h > MOUNTAIN_COMPRESS_START:
					new_h = MOUNTAIN_COMPRESS_START + (new_h - MOUNTAIN_COMPRESS_START) * MOUNTAIN_COMPRESS_SCALE

				if new_h < 0.0:
					new_h = 0.0
				next[idx] = new_h

		var swap := current
		current = next
		next = swap

	for y in range(height):
		for x in range(width):
			height_map.set_pixel(x, y, Color(current[y * width + x], 0.0, 0.0, 1.0))

	region.call("set_height_map", height_map)
	var err: int = ResourceSaver.save(region, region_path)
	if err != OK:
		push_warning("Save failed: %s err=%d" % [region_path, err])
