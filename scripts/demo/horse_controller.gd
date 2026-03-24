extends Node3D
class_name HorseController

@export var walk_speed: float = 2.2
@export var run_speed: float = 5.4
@export var turn_speed_deg: float = 420.0

var _animation_player: AnimationPlayer = null
var _idle_anim: String = ""
var _walk_anim: String = ""
var _run_anim: String = ""
var _eat_anim: String = ""

func _ready() -> void:
	_animation_player = _find_animation_player(self)
	_cache_animation_names()
	_play_if_available(_idle_anim)

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_E):
		_play_if_available(_eat_anim)
		return

	var move_input := Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		move_input.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		move_input.y += 1.0
	if Input.is_key_pressed(KEY_A):
		move_input.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		move_input.x += 1.0

	if move_input.length_squared() <= 0.0:
		_play_if_available(_idle_anim)
		return

	move_input = move_input.normalized()
	var move_dir := Vector3(move_input.x, 0.0, move_input.y).normalized()
	var sprinting := Input.is_key_pressed(KEY_SHIFT)
	var speed := run_speed if sprinting else walk_speed
	global_position += move_dir * speed * delta

	var target_yaw := atan2(move_dir.x, -move_dir.z)
	var turn_step := deg_to_rad(turn_speed_deg) * delta
	rotation.y = lerp_angle(rotation.y, target_yaw, clampf(turn_step, 0.0, 1.0))

	if sprinting:
		_play_if_available(_run_anim)
	else:
		_play_if_available(_walk_anim)

func _cache_animation_names() -> void:
	if _animation_player == null:
		return
	for name_any in _animation_player.get_animation_list():
		var name := String(name_any)
		var lower := name.to_lower()
		if _idle_anim.is_empty() and lower.find("idle") >= 0:
			_idle_anim = name
		elif _walk_anim.is_empty() and lower.find("walk") >= 0:
			_walk_anim = name
		elif _run_anim.is_empty() and lower.find("run") >= 0:
			_run_anim = name
		elif _eat_anim.is_empty() and lower.find("eat") >= 0:
			_eat_anim = name

	if _idle_anim.is_empty() and _animation_player.get_animation_list().size() > 0:
		_idle_anim = String(_animation_player.get_animation_list()[0])
	if _walk_anim.is_empty():
		_walk_anim = _idle_anim
	if _run_anim.is_empty():
		_run_anim = _walk_anim
	if _eat_anim.is_empty():
		_eat_anim = _idle_anim

func _play_if_available(anim_name: String) -> void:
	if _animation_player == null or anim_name.is_empty():
		return
	if _animation_player.current_animation == anim_name and _animation_player.is_playing():
		return
	_animation_player.play(anim_name, 0.2)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
