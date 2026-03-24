extends Control
class_name ExpeditionRadarChart

const GRID_COLOR := Color(0.78, 0.69, 0.47, 0.35)
const AXIS_COLOR := Color(0.84, 0.75, 0.54, 0.52)
const LAND_FILL_COLOR := Color(0.32, 0.68, 0.95, 0.26)
const LAND_LINE_COLOR := Color(0.38, 0.75, 1.0, 0.95)
const WATER_FILL_COLOR := Color(0.98, 0.63, 0.28, 0.23)
const WATER_LINE_COLOR := Color(1.0, 0.72, 0.33, 0.96)
const CENTER_DOT_COLOR := Color(0.95, 0.9, 0.75, 0.9)
const LABEL_COLOR := Color(0.96, 0.9, 0.78, 0.96)
const LABEL_OUTLINE_COLOR := Color(0.06, 0.08, 0.1, 0.92)

var _axis_labels: Array[String] = []
var _land_values: Array[float] = []
var _water_values: Array[float] = []

func set_profiles(labels: Array, land_values: Dictionary, water_values: Dictionary) -> void:
	_axis_labels.clear()
	_land_values.clear()
	_water_values.clear()
	for key_any in labels:
		var key: String = str(key_any).strip_edges()
		if key.is_empty():
			continue
		_axis_labels.append(key)
		_land_values.append(clampf(float(land_values.get(key, 0.0)), 0.0, 100.0))
		_water_values.append(clampf(float(water_values.get(key, 0.0)), 0.0, 100.0))
	queue_redraw()

func clear_profiles() -> void:
	_axis_labels.clear()
	_land_values.clear()
	_water_values.clear()
	queue_redraw()

func _draw() -> void:
	var axis_count: int = _axis_labels.size()
	if axis_count < 3:
		return
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.29
	if radius <= 8.0:
		return

	for ring in range(1, 5):
		var level_ratio: float = float(ring) / 4.0
		var ring_points: PackedVector2Array = _build_polygon_points(center, radius * level_ratio, axis_count, [])
		draw_polyline(_closed_points(ring_points), GRID_COLOR, 1.2, true)

	var axis_points: PackedVector2Array = _build_polygon_points(center, radius, axis_count, [])
	for point in axis_points:
		draw_line(center, point, AXIS_COLOR, 1.1, true)

	var land_points: PackedVector2Array = _build_polygon_points(center, radius, axis_count, _land_values)
	var water_points: PackedVector2Array = _build_polygon_points(center, radius, axis_count, _water_values)
	if land_points.size() == axis_count:
		draw_polygon(land_points, PackedColorArray([LAND_FILL_COLOR]))
		draw_polyline(_closed_points(land_points), LAND_LINE_COLOR, 2.0, true)
	if water_points.size() == axis_count:
		draw_polygon(water_points, PackedColorArray([WATER_FILL_COLOR]))
		draw_polyline(_closed_points(water_points), WATER_LINE_COLOR, 2.0, true)

	draw_circle(center, 2.8, CENTER_DOT_COLOR)
	_draw_axis_labels(center, radius, axis_count)

func _draw_axis_labels(center: Vector2, radius: float, axis_count: int) -> void:
	var font: Font = get_theme_default_font()
	if font == null:
		return
	var font_size: int = max(11, get_theme_default_font_size() - 2)
	for i in range(axis_count):
		var angle: float = -PI * 0.5 + TAU * (float(i) / float(axis_count))
		var dir := Vector2(cos(angle), sin(angle))
		var text: String = "%s %.0f/%.0f" % [
			_axis_labels[i],
			_land_values[i] if i < _land_values.size() else 0.0,
			_water_values[i] if i < _water_values.size() else 0.0
		]
		var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var pos: Vector2 = center + dir * (radius + 18.0)
		if dir.x > 0.25:
			pos.x += 4.0
		elif dir.x < -0.25:
			pos.x -= text_size.x + 4.0
		else:
			pos.x -= text_size.x * 0.5
		if dir.y > 0.25:
			pos.y += text_size.y
		elif dir.y < -0.25:
			pos.y -= 4.0
		else:
			pos.y += text_size.y * 0.5
		_draw_label_text(font, font_size, pos, text)

func _draw_label_text(font: Font, font_size: int, pos: Vector2, text: String) -> void:
	var outline_offsets := [
		Vector2(-1.0, 0.0),
		Vector2(1.0, 0.0),
		Vector2(0.0, -1.0),
		Vector2(0.0, 1.0)
	]
	for offset in outline_offsets:
		draw_string(font, pos + offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, LABEL_OUTLINE_COLOR)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, LABEL_COLOR)

func _build_polygon_points(center: Vector2, radius: float, axis_count: int, values: Array[float]) -> PackedVector2Array:
	var points := PackedVector2Array()
	if axis_count < 3:
		return points
	for i in range(axis_count):
		var angle: float = -PI * 0.5 + TAU * (float(i) / float(axis_count))
		var dir := Vector2(cos(angle), sin(angle))
		var ratio: float = 1.0
		if values.size() == axis_count:
			ratio = clampf(values[i] / 100.0, 0.0, 1.0)
		points.append(center + dir * radius * ratio)
	return points

func _closed_points(points: PackedVector2Array) -> PackedVector2Array:
	var out: PackedVector2Array = points
	if out.size() > 0:
		out.append(out[0])
	return out