extends SceneTree

const TERRAIN_DATA_DIR := "res://data/terrain/china_30km/terrain_data"
const PASSES := 2
const PRESERVE_COAST_BELOW := 24.0
const MOUNTAIN_MIN_H := 520.0
const RIDGE_MIN_RELIEF := 42.0
const RIDGE_HIGH_RELIEF := 95.0
const SPIKE3_MIN := 18.0
const SPIKE5_MIN := 38.0
const MAX_LOWER_PER_PASS := 22.0
const CHANGE_EPSILON := 0.01

var _changed_points: int = 0
var _total_lowered: float = 0.0
var _max_lowered: float = 0.0

func _init() -> void:
	print("mountain_soft_smooth:start")
	call_deferred("_run")

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

	var avg_lowered: float = _total_lowered / float(_changed_points) if _changed_points > 0 else 0.0
	print(
		"mountain_soft_smooth changed_points=%d total_lowered=%.2f avg_lowered=%.3f max_lowered=%.3f" %
		[_changed_points, _total_lowered, avg_lowered, _max_lowered]
	)
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
				if source_h < 0.0 or source_h <= PRESERVE_COAST_BELOW or source_h < MOUNTAIN_MIN_H:
					next[idx] = source_h
					continue

				var mean3: float = _sample_mean(current, width, height, x, y, 1)
				var mean5: float = _sample_mean(current, width, height, x, y, 2)
				var relief3: float = _sample_relief(current, width, height, x, y, 1)
				var relief5: float = _sample_relief(current, width, height, x, y, 2)
				var spike3: float = source_h - mean3
				var spike5: float = source_h - mean5
				var target: float = source_h

				if relief5 >= RIDGE_MIN_RELIEF or spike3 >= SPIKE3_MIN:
					if spike3 >= SPIKE3_MIN:
						target = minf(target, lerpf(source_h, mean3, 0.22))
					if spike5 >= SPIKE5_MIN:
						target = minf(target, lerpf(source_h, mean5, 0.30))
					if relief5 >= RIDGE_HIGH_RELIEF:
						target = lerpf(target, mean5, 0.15)
					if relief3 >= RIDGE_HIGH_RELIEF * 0.72:
						target = lerpf(target, mean3, 0.10)

				var lowered: float = clampf(source_h - target, 0.0, MAX_LOWER_PER_PASS)
				next[idx] = maxf(0.0, source_h - lowered)

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
				if after_h < before_h:
					var delta: float = before_h - after_h
					_total_lowered += delta
					_max_lowered = maxf(_max_lowered, delta)
			height_map.set_pixel(x, y, Color(after_h, 0.0, 0.0, 1.0))

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
