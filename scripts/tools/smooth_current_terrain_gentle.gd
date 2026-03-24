extends SceneTree

const TERRAIN_DATA_DIR := "res://data/terrain/china_30km/terrain_data"
const PASSES := 3
const PRESERVE_COAST_BELOW := 24.0
const LOWLAND_MAX_H := 180.0
const HILL_MAX_H := 650.0
const MOUNTAIN_MAX_H := 1600.0
const CHANGE_EPSILON := 0.01

var _changed_points: int = 0
var _max_before: float = -INF
var _max_after: float = -INF
var _min_before: float = INF
var _min_after: float = INF

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

	print("gentle_smooth changed_points=%d min_before=%.2f max_before=%.2f min_after=%.2f max_after=%.2f" % [_changed_points, _min_before, _max_before, _min_after, _max_after])
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
			var h: float = height_map.get_pixel(x, y).r
			current[y * width + x] = h
			_min_before = minf(_min_before, h)
			_max_before = maxf(_max_before, h)

	var next := PackedFloat32Array()
	next.resize(width * height)

	for _pass in range(PASSES):
		for y in range(height):
			for x in range(width):
				var idx := y * width + x
				var source_h: float = current[idx]
				if source_h < 0.0 or source_h <= PRESERVE_COAST_BELOW:
					next[idx] = source_h
					continue

				var mean3: float = _sample_mean(current, width, height, x, y, 1)
				var mean5: float = _sample_mean(current, width, height, x, y, 2)
				var relief3: float = _sample_relief(current, width, height, x, y, 1)
				var relief5: float = _sample_relief(current, width, height, x, y, 2)
				var spike: float = source_h - mean3
				var new_h: float = source_h

				if source_h <= LOWLAND_MAX_H:
					if relief5 >= 16.0:
						new_h = lerpf(source_h, lerpf(mean3, mean5, 0.55), 0.46)
				elif source_h <= HILL_MAX_H:
					if relief5 >= 26.0:
						new_h = lerpf(source_h, lerpf(mean3, mean5, 0.42), 0.34)
				elif source_h <= MOUNTAIN_MAX_H:
					if relief5 >= 44.0:
						new_h = lerpf(source_h, lerpf(mean3, mean5, 0.28), 0.22)
				else:
					if relief5 >= 60.0:
						new_h = lerpf(source_h, mean3, 0.14)

				if spike >= 22.0:
					new_h = minf(new_h, lerpf(source_h, mean3, 0.52))
				if spike >= 55.0:
					new_h = minf(new_h, lerpf(source_h, mean5, 0.66))
				if relief3 >= 90.0:
					new_h = lerpf(new_h, mean3, 0.16)
				if relief5 >= 160.0:
					new_h = lerpf(new_h, mean5, 0.12)

				new_h = maxf(0.0, new_h)
				next[idx] = new_h

		var swap := current
		current = next
		next = swap

	for y in range(height):
		for x in range(width):
			var idx := y * width + x
			var before_h: float = height_map.get_pixel(x, y).r
			var after_h: float = current[idx]
			if absf(after_h - before_h) > CHANGE_EPSILON:
				_changed_points += 1
			height_map.set_pixel(x, y, Color(after_h, 0.0, 0.0, 1.0))
			_min_after = minf(_min_after, after_h)
			_max_after = maxf(_max_after, after_h)

	region.call("set_height_map", height_map)
	var err: int = ResourceSaver.save(region, region_path)
	if err != OK:
		push_warning("Save failed: %s err=%d" % [region_path, err])

func _sample_mean(data: PackedFloat32Array, width: int, height: int, cx: int, cy: int, radius: int) -> float:
	var sum_h := 0.0
	var count := 0.0
	for oy in range(-radius, radius + 1):
		var sy := clampi(cy + oy, 0, height - 1)
		for ox in range(-radius, radius + 1):
			var sx := clampi(cx + ox, 0, width - 1)
			sum_h += data[sy * width + sx]
			count += 1.0
	return sum_h / maxf(count, 1.0)

func _sample_relief(data: PackedFloat32Array, width: int, height: int, cx: int, cy: int, radius: int) -> float:
	var min_h := INF
	var max_h := -INF
	for oy in range(-radius, radius + 1):
		var sy := clampi(cy + oy, 0, height - 1)
		for ox in range(-radius, radius + 1):
			var sx := clampi(cx + ox, 0, width - 1)
			var h: float = data[sy * width + sx]
			min_h = minf(min_h, h)
			max_h = maxf(max_h, h)
	return max_h - min_h
