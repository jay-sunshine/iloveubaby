extends Node3D
class_name ShieldClosePreview

@export var walk_speed_scale: float = 0.85
@export var default_speed_scale: float = 1.0

var _status_label: Label = null
var _anim_player: AnimationPlayer = null


func _ready() -> void:
	_status_label = get_node_or_null("CanvasLayer/Status")
	var model := get_node_or_null("ShieldModel")
	if model == null:
		_set_status("ShieldModel missing")
		return

	_ensure_meshes_visible(model)
	_anim_player = _find_animation_player(model)
	if _anim_player == null:
		_set_status("AnimationPlayer not found")
		return

	var names: PackedStringArray = PackedStringArray()
	for n in _anim_player.get_animation_list():
		names.append(String(n))
	_set_status("Animations: %s" % ", ".join(names))
	_play_by_keywords(["walk", "run", "jog"])


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	match key_event.keycode:
		KEY_1:
			_play_by_keywords(["idle", "stand", "block"])
		KEY_2:
			_play_by_keywords(["walk", "run", "jog"])
		KEY_3:
			_play_by_keywords(["slash", "attack", "hit"])


func _play_by_keywords(keywords: Array[String]) -> void:
	if _anim_player == null:
		return
	var clip := _find_clip(_anim_player, keywords)
	if clip.is_empty():
		_set_status("Clip not found: %s" % ", ".join(keywords))
		return

	var lower := clip.to_lower()
	if lower.find("walk") >= 0 or lower.find("run") >= 0 or lower.find("jog") >= 0:
		_anim_player.speed_scale = walk_speed_scale
	else:
		_anim_player.speed_scale = default_speed_scale

	_anim_player.play(clip, 0.08)
	_set_status("Playing: %s speed=%.2f" % [clip, _anim_player.speed_scale])


func _find_clip(anim_player: AnimationPlayer, keywords: Array[String]) -> String:
	var fallback := ""
	for name_any in anim_player.get_animation_list():
		var name := String(name_any)
		if fallback.is_empty():
			fallback = name
		var lower := name.to_lower()
		for kw in keywords:
			if lower.find(kw) >= 0:
				return name
	return fallback


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _ensure_meshes_visible(node: Node) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).visible = true
	for child in node.get_children():
		_ensure_meshes_visible(child)


func _set_status(msg: String) -> void:
	if _status_label != null:
		_status_label.text = msg
	print("[ShieldClosePreview] ", msg)
