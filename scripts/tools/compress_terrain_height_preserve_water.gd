extends SceneTree

const TERRAIN_DATA_DIR := "res://data/terrain/china_30km/terrain_data"

# Keep water channels/coasts unchanged.
const PRESERVE_WATER_EDGE_BELOW := 28.0

# Keep lowland readability for RTS and compress only higher relief.
const KEEP_LOWLAND_BELOW := 180.0
const MIDLAND_TOP := 520.0
const MIDLAND_SCALE := 0.78
const HIGHLAND_SCALE := 0.60

var _region_count := 0
var _changed_points := 0
var _lowered_total := 0.0
var _lowered_max := 0.0


func _init() -> void:
	print("compress_terrain_height_preserve_water:start")
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

	print(
		"compress_terrain_height_preserve_water done: regions=%d changed=%d lowered_total=%.2f avg_lowered=%.3f max_lowered=%.3f"
		% [
			_region_count,
			_changed_points,
			_lowered_total,
			(_lowered_total / float(_changed_points)) if _changed_points > 0 else 0.0,
			_lowered_max
		]
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

	_region_count += 1
	var width: int = height_map.get_width()
	var height: int = height_map.get_height()
	var changed_local := 0

	var midland_top_target: float = KEEP_LOWLAND_BELOW + (MIDLAND_TOP - KEEP_LOWLAND_BELOW) * MIDLAND_SCALE

	for y in range(height):
		for x in range(width):
			var source_h: float = height_map.get_pixel(x, y).r
			var new_h: float = source_h

			# Keep water channels and coastal belt untouched.
			if source_h <= PRESERVE_WATER_EDGE_BELOW:
				continue
			# Keep plains untouched for battlefield readability.
			if source_h <= KEEP_LOWLAND_BELOW:
				continue

			if source_h <= MIDLAND_TOP:
				new_h = KEEP_LOWLAND_BELOW + (source_h - KEEP_LOWLAND_BELOW) * MIDLAND_SCALE
			else:
				new_h = midland_top_target + (source_h - MIDLAND_TOP) * HIGHLAND_SCALE

			if new_h >= source_h:
				continue

			var lowered: float = source_h - new_h
			_changed_points += 1
			changed_local += 1
			_lowered_total += lowered
			if lowered > _lowered_max:
				_lowered_max = lowered
			height_map.set_pixel(x, y, Color(new_h, 0.0, 0.0, 1.0))

	if changed_local <= 0:
		return

	region.call("set_height_map", height_map)
	var err: int = ResourceSaver.save(region, region_path)
	if err != OK:
		push_warning("Save failed: %s err=%d" % [region_path, err])
