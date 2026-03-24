extends RefCounted
class_name LogicApi

const GameDataRepository := preload("res://scripts/data/game_data_repository.gd")
const JsonDataSource := preload("res://scripts/data/json_data_source.gd")

var _repo: GameDataRepository
var _data_source: JsonDataSource

func _init(repo: GameDataRepository, data_source: JsonDataSource) -> void:
	_repo = repo
	_data_source = data_source

func get_world_snapshot() -> Dictionary:
	return _repo.get_world_snapshot()

func get_rules(rule_key: String) -> Dictionary:
	return _repo.get_rules_snapshot(rule_key)

func get_meta_snapshot() -> Dictionary:
	return _repo.get_meta_snapshot()

func patch_meta(patch: Dictionary, source_module: String) -> void:
	_repo.patch_meta(patch, source_module)

func list_city_ids() -> Array[String]:
	return _repo.list_city_ids()

func get_city(city_id: String) -> Dictionary:
	return _repo.get_city_snapshot(city_id)

func patch_city(city_id: String, patch: Dictionary, source_module: String) -> bool:
	return _repo.patch_city(city_id, patch, source_module)

func list_factions() -> Array[String]:
	return _repo.list_factions()

func get_relation_value(faction_a: String, faction_b: String) -> float:
	return _repo.get_relation_value(faction_a, faction_b)

func patch_relation_value(faction_a: String, faction_b: String, value: float, source_module: String) -> void:
	_repo.patch_relation_value(faction_a, faction_b, value, source_module)

func get_player_faction_id() -> String:
	return _repo.get_player_faction_id()

func advance_calendar(delta_days: float) -> void:
	_repo.advance_calendar(delta_days)

func get_calendar_day() -> float:
	return _repo.get_calendar_day()

func save_world_state(path: String) -> bool:
	return _repo.save_world_state(_data_source, path)

func get_distance_between_cities(city_a: String, city_b: String) -> float:
	var a: Dictionary = get_city(city_a)
	var b: Dictionary = get_city(city_b)
	if a.is_empty() or b.is_empty():
		return INF
	var pos_a: Dictionary = a.get("position", {})
	var pos_b: Dictionary = b.get("position", {})
	var dx: float = float(pos_a.get("x", 0.0)) - float(pos_b.get("x", 0.0))
	var dz: float = float(pos_a.get("z", 0.0)) - float(pos_b.get("z", 0.0))
	return sqrt(dx * dx + dz * dz)