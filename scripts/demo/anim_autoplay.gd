extends Node3D
class_name AnimAutoplay

@export var speed_scale: float = 0.85
@export var prefer_keywords: PackedStringArray = PackedStringArray(["walk", "run", "jog", "idle"])

var _animation_player: AnimationPlayer = null


func _ready() -> void:
	_animation_player = _find_animation_player(self)
	if _animation_player == null:
		print("[AnimAutoplay] AnimationPlayer not found on ", name)
		return

	var clip := _pick_clip()
	if clip.is_empty():
		print("[AnimAutoplay] No clip on ", name)
		return

	_animation_player.speed_scale = speed_scale
	_animation_player.play(clip, 0.08)
	print("[AnimAutoplay] ", name, " -> ", clip, " speed=", speed_scale)


func _pick_clip() -> String:
	if _animation_player == null:
		return ""
	var list := _animation_player.get_animation_list()
	if list.is_empty():
		return ""

	for kw_any in prefer_keywords:
		var kw := String(kw_any).to_lower()
		for n_any in list:
			var n := String(n_any)
			if n.to_lower().find(kw) >= 0:
				return n

	return String(list[0])


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for c in node.get_children():
		var found := _find_animation_player(c)
		if found != null:
			return found
	return null
