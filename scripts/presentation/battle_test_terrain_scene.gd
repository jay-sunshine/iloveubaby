extends Node3D

const BattleCameraController := preload("res://scripts/battle_camera_controller.gd")
const GROUND_COLLISION_LAYER := 1
const DEFAULT_GROUND_HALF_EXTENT := 80.0
const TERRAIN_RAY_LENGTH := 10000.0
const TERRAIN_WALKABLE_SLOPE_DEG := 40.0

@export var ground_half_extent: float = DEFAULT_GROUND_HALF_EXTENT
@export var camera_focus_point: Vector3 = Vector3.ZERO

var _camera: Camera3D = null
var _terrain: Node3D = null

func _ready() -> void:
	_camera = get_node_or_null("BattleCamera") as Camera3D
	_terrain = get_node_or_null("Terrain3D") as Node3D
	if _camera != null:
		if _camera.get_script() != BattleCameraController:
			_camera.set_script(BattleCameraController)
		var use_embedded_camera: bool = true
		var parent_node: Node = get_parent()
		if parent_node != null and parent_node.get("embedded_on_strategy_map") != null:
			use_embedded_camera = not bool(parent_node.get("embedded_on_strategy_map"))
		_camera.current = use_embedded_camera
		if _camera.has_method("set_focus_point"):
			_camera.call("set_focus_point", camera_focus_point)

func _terrain_data():
	if _terrain == null or not is_instance_valid(_terrain):
		return null
	if _terrain.has_method("get_data"):
		return _terrain.call("get_data")
	return _terrain.get("data")

func _terrain_has_regions() -> bool:
	var data = _terrain_data()
	if data == null:
		return false
	if data.has_method("get_region_count"):
		return int(data.call("get_region_count")) > 0
	return false

func terrain_height_at_world(world_pos: Vector3) -> float:
	var data = _terrain_data()
	if data != null and _terrain_has_regions() and data.has_method("get_height"):
		return float(data.call("get_height", world_pos))
	return 0.0

func terrain_slope_deg_at_world(world_pos: Vector3) -> float:
	var data = _terrain_data()
	if data != null and _terrain_has_regions() and data.has_method("get_normal"):
		var normal: Vector3 = data.call("get_normal", world_pos)
		if normal.length_squared() > 0.000001:
			return rad_to_deg(normal.normalized().angle_to(Vector3.UP))
	return 0.0

func can_unit_walk_at_world(world_pos: Vector3) -> bool:
	var in_ground_bounds: bool = absf(world_pos.x) <= ground_half_extent and absf(world_pos.z) <= ground_half_extent
	if not in_ground_bounds:
		return false
	if not _terrain_has_regions():
		return true
	var data = _terrain_data()
	var inside_region: bool = true
	if data != null and data.has_method("has_regionp"):
		inside_region = bool(data.call("has_regionp", world_pos))
	if not inside_region:
		# Demo fallback: allow movement on the full test ground even outside painted Terrain3D regions.
		return true
	if data != null and data.has_method("get_control_hole") and bool(data.call("get_control_hole", world_pos)):
		return false
	return terrain_slope_deg_at_world(world_pos) <= TERRAIN_WALKABLE_SLOPE_DEG

func terrain_type_at_world(world_pos: Vector3) -> String:
	var slope: float = terrain_slope_deg_at_world(world_pos)
	if slope > TERRAIN_WALKABLE_SLOPE_DEG:
		return "mountain"
	if slope > 20.0:
		return "hill"
	return "plain"

func query_terrain_from_screen(screen_pos: Vector2) -> Dictionary:
	if _camera == null:
		return {}
	var from: Vector3 = _camera.project_ray_origin(screen_pos)
	var dir: Vector3 = _camera.project_ray_normal(screen_pos)
	var to: Vector3 = from + dir * TERRAIN_RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = GROUND_COLLISION_LAYER
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var world_pos: Vector3 = hit.get("position", Vector3.ZERO)
		world_pos.y = terrain_height_at_world(world_pos)
		return {
			"position": world_pos,
			"terrain_type": terrain_type_at_world(world_pos)
		}
	var plane_hit = Plane(Vector3.UP, 0.0).intersects_ray(from, dir)
	if plane_hit == null:
		return {}
	var plane_pos: Vector3 = plane_hit
	plane_pos.y = terrain_height_at_world(plane_pos)
	return {
		"position": plane_pos,
		"terrain_type": terrain_type_at_world(plane_pos)
	}
