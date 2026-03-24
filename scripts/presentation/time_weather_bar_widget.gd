extends Control
class_name TimeWeatherBarWidget

@export var background_path: NodePath = NodePath("Background")
@export var top_label_path: NodePath = NodePath("TopLabel")
@export var bottom_label_path: NodePath = NodePath("BottomLabel")

var _background: TextureRect
var _top_label: Label
var _bottom_label: Label
var _text_padding_x: float = 24.0
var _top_y_ratio: float = 0.2
var _top_h_ratio: float = 0.24
var _bottom_y_ratio: float = 0.62
var _bottom_h_ratio: float = 0.24

func _ready() -> void:
	_cache_nodes()
	_text_padding_x = 24.0
	if not resized.is_connected(_on_resized):
		resized.connect(_on_resized)
	_on_resized()

func apply_rules(rules: Dictionary) -> void:
	_cache_nodes()
	var use_scene_size: bool = bool(rules.get("use_scene_size", true))
	if not use_scene_size and rules.has("panel_size"):
		var arr: Array = rules.get("panel_size", [])
		size = Vector2(
			float(arr[0]) if arr.size() > 0 else size.x,
			float(arr[1]) if arr.size() > 1 else size.y
		)
	if _background != null:
		var bg_path: String = String(rules.get("background_image", ""))
		if not bg_path.is_empty():
			_background.texture = load(bg_path)
		_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_background.stretch_mode = _texture_rect_stretch_mode_from_rule(String(rules.get("stretch_mode", "keep_aspect_centered")))
		_background.texture_filter = _texture_filter_from_rule(String(rules.get("texture_filter", "nearest")))
		_background.position = Vector2.ZERO
		_background.size = size

	var text_color: Color = _color_from_any(rules.get("text_color", [0.93, 0.88, 0.76, 1.0]), Color(0.93, 0.88, 0.76, 1.0))
	var top_font_size: int = int(rules.get("top_font_size", 24))
	var bottom_font_size: int = int(rules.get("bottom_font_size", 22))
	var pad_x: float = float(rules.get("text_padding_x", 24.0))
	_text_padding_x = pad_x
	_top_y_ratio = clampf(float(rules.get("top_y_ratio", 0.2)), 0.0, 0.8)
	_top_h_ratio = clampf(float(rules.get("top_h_ratio", 0.24)), 0.08, 0.8)
	_bottom_y_ratio = clampf(float(rules.get("bottom_y_ratio", 0.62)), 0.0, 0.9)
	_bottom_h_ratio = clampf(float(rules.get("bottom_h_ratio", 0.24)), 0.08, 0.8)

	if _top_label != null:
		_top_label.add_theme_font_size_override("font_size", top_font_size)
		_top_label.add_theme_color_override("font_color", text_color)
		_top_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_top_label.clip_text = true
	if _bottom_label != null:
		_bottom_label.add_theme_font_size_override("font_size", bottom_font_size)
		_bottom_label.add_theme_color_override("font_color", text_color)
		_bottom_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_bottom_label.clip_text = true
	_on_resized()

func set_display(top_text: String, bottom_text: String) -> void:
	if _top_label != null:
		_top_label.text = top_text
	if _bottom_label != null:
		_bottom_label.text = bottom_text

func layout_centered(viewport_size: Vector2, offset_y: float) -> void:
	position = Vector2((viewport_size.x - size.x) * 0.5, offset_y)

func _cache_nodes() -> void:
	_background = get_node_or_null(background_path) as TextureRect
	_top_label = get_node_or_null(top_label_path) as Label
	_bottom_label = get_node_or_null(bottom_label_path) as Label

func _apply_default_layout(pad_x: float) -> void:
	if _top_label != null:
		_top_label.position = Vector2(pad_x, size.y * _top_y_ratio)
		_top_label.size = Vector2(maxf(40.0, size.x - pad_x * 2.0), size.y * _top_h_ratio)
		_top_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_top_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if _bottom_label != null:
		_bottom_label.position = Vector2(pad_x, size.y * _bottom_y_ratio)
		_bottom_label.size = Vector2(maxf(40.0, size.x - pad_x * 2.0), size.y * _bottom_h_ratio)
		_bottom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_bottom_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _on_resized() -> void:
	if _background != null:
		_background.position = Vector2.ZERO
		_background.size = size
	_apply_default_layout(_text_padding_x)

func _color_from_any(value: Variant, fallback: Color) -> Color:
	if value is Array:
		var arr: Array = value
		if arr.size() >= 3:
			var alpha: float = 1.0
			if arr.size() >= 4:
				alpha = float(arr[3])
			return Color(float(arr[0]), float(arr[1]), float(arr[2]), alpha)
	return fallback

func _texture_filter_from_rule(value: String) -> CanvasItem.TextureFilter:
	match value.to_lower():
		"nearest":
			return CanvasItem.TEXTURE_FILTER_NEAREST
		"nearest_mipmap":
			return CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		"linear_mipmap":
			return CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		"linear":
			return CanvasItem.TEXTURE_FILTER_LINEAR
		_:
			return CanvasItem.TEXTURE_FILTER_LINEAR

func _texture_rect_stretch_mode_from_rule(value: String) -> TextureRect.StretchMode:
	match value.to_lower():
		"scale":
			return TextureRect.STRETCH_SCALE
		"keep":
			return TextureRect.STRETCH_KEEP
		"keep_centered":
			return TextureRect.STRETCH_KEEP_CENTERED
		"keep_aspect":
			return TextureRect.STRETCH_KEEP_ASPECT
		"keep_aspect_centered":
			return TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		"keep_aspect_covered":
			return TextureRect.STRETCH_KEEP_ASPECT_COVERED
		_:
			return TextureRect.STRETCH_KEEP_ASPECT_CENTERED
