extends Node3D
class_name ShieldAnimPreview

@export var walk_speed_scale: float = 0.85
@export var default_speed_scale: float = 1.0

var _anim_player: AnimationPlayer = null
var _status_label: Label = null
var _model_root: Node3D = null


func _ready() -> void:
	_status_label = get_node_or_null("CanvasLayer/Status")
	_model_root = get_node_or_null("ShieldModel") as Node3D
	if _model_root == null:
		_set_status("ShieldModel missing in scene")
		return

	_ensure_meshes_visible(_model_root)
	_fit_camera_to_instance(_model_root)

	_anim_player = _find_animation_player(_model_root)
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
		KEY_R:
			_fit_camera_to_instance(_model_root)


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
	_set_status("Playing: %s  speed=%.2f" % [clip, _anim_player.speed_scale])


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


func _set_status(msg: String) -> void:
	if _status_label != null:
		_status_label.text = msg
	print("[ShieldAnimPreview] ", msg)


func _ensure_meshes_visible(node: Node) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).visible = true
	for child in node.get_children():
		_ensure_meshes_visible(child)


func _collect_meshes(node: Node, out: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		out.append(node as MeshInstance3D)
	for child in node.get_children():
		_collect_meshes(child, out)


func _mesh_world_aabb(mi: MeshInstance3D) -> AABB:
	var local_aabb := mi.get_aabb()
	var xf := mi.global_transform
	var mn := Vector3(1e20, 1e20, 1e20)
	var mx := Vector3(-1e20, -1e20, -1e20)
	for x in [0, 1]:
		for y in [0, 1]:
			for z in [0, 1]:
				var p := local_aabb.position + Vector3(local_aabb.size.x * x, local_aabb.size.y * y, local_aabb.size.z * z)
				var wp := xf * p
				mn = mn.min(wp)
				mx = mx.max(wp)
	return AABB(mn, mx - mn)


func _fit_camera_to_instance(instance: Node) -> void:
	var cam := get_node_or_null("Camera3D") as Camera3D
	if cam == null:
		return

	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(instance, meshes)
	if meshes.is_empty():
		return

	var mn := Vector3(1e20, 1e20, 1e20)
	var mx := Vector3(-1e20, -1e20, -1e20)
	for m in meshes:
		var a := _mesh_world_aabb(m)
		mn = mn.min(a.position)
		mx = mx.max(a.position + a.size)

	var center: Vector3 = (mn + mx) * 0.5
	var size: Vector3 = mx - mn
	var radius: float = max(size.x, max(size.y, size.z)) * 0.9
	if radius < 1.0:
		radius = 1.0

	cam.global_position = center + Vector3(0.0, radius * 1.0, radius * 2.0)
	cam.look_at(center, Vector3.UP)