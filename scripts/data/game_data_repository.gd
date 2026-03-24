extends RefCounted
class_name GameDataRepository

const JsonDataSource := preload("res://scripts/data/json_data_source.gd")

var _world_state: Dictionary = {}
var _rules: Dictionary = {}

func bootstrap(world_state: Dictionary, rules_by_key: Dictionary) -> void:
	_world_state = world_state.duplicate(true)
	_rules = rules_by_key.duplicate(true)

func get_world_snapshot() -> Dictionary:
	return _world_state.duplicate(true)

func get_rules_snapshot(key: String) -> Dictionary:
	if not _rules.has(key):
		return {}
	return (_rules[key] as Dictionary).duplicate(true)

func get_meta_snapshot() -> Dictionary:
	return (_world_state.get("meta", {}) as Dictionary).duplicate(true)

func patch_meta(patch: Dictionary, _source: String) -> void:
	var mutable_meta: Dictionary = _world_state.get("meta", {})
	_recursive_merge(mutable_meta, patch)
	_world_state["meta"] = mutable_meta

func list_city_ids() -> Array[String]:
	var ids: Array[String] = []
	for city_any in _world_state.get("cities", []):
		var city: Dictionary = city_any
		ids.append(String(city.get("id", "")))
	return ids

func get_city_snapshot(city_id: String) -> Dictionary:
	var idx: int = _find_city_index(city_id)
	if idx < 0:
		return {}
	return (_world_state["cities"][idx] as Dictionary).duplicate(true)

func patch_city(city_id: String, patch: Dictionary, _source: String) -> bool:
	var idx: int = _find_city_index(city_id)
	if idx < 0:
		return false
	var mutable_city: Dictionary = (_world_state["cities"][idx] as Dictionary)
	_recursive_merge(mutable_city, patch)
	_world_state["cities"][idx] = mutable_city
	return true

func get_relation_value(faction_a: String, faction_b: String) -> float:
	var relation: Dictionary = _find_relation(faction_a, faction_b)
	if relation.is_empty():
		return 0.0
	return float(relation.get("value", 0.0))

func patch_relation_value(faction_a: String, faction_b: String, new_value: float, _source: String) -> void:
	var diplomacy: Dictionary = _world_state.get("diplomacy", {})
	if not diplomacy.has("relations"):
		diplomacy["relations"] = []
	var relations: Array = diplomacy["relations"]
	for i in relations.size():
		var rel: Dictionary = relations[i]
		if _is_relation_pair(rel, faction_a, faction_b):
			rel["value"] = new_value
			relations[i] = rel
			diplomacy["relations"] = relations
			_world_state["diplomacy"] = diplomacy
			return
	relations.append({
		"a": faction_a,
		"b": faction_b,
		"value": new_value
	})
	diplomacy["relations"] = relations
	_world_state["diplomacy"] = diplomacy

func list_factions() -> Array[String]:
	var out: Array[String] = []
	for faction_any in _world_state.get("factions", []):
		var faction: Dictionary = faction_any
		out.append(String(faction.get("id", "")))
	return out

func advance_calendar(delta_days: float) -> void:
	var meta: Dictionary = _world_state.get("meta", {})
	var day_value: float = float(meta.get("calendar_day", 1.0))
	meta["calendar_day"] = day_value + delta_days
	_world_state["meta"] = meta

func get_player_faction_id() -> String:
	var meta: Dictionary = _world_state.get("meta", {})
	return String(meta.get("player_faction_id", ""))

func get_calendar_day() -> float:
	var meta: Dictionary = _world_state.get("meta", {})
	return float(meta.get("calendar_day", 1.0))

func save_world_state(data_source: JsonDataSource, path: String) -> bool:
	return data_source.save_dictionary(path, _world_state)

func _find_city_index(city_id: String) -> int:
	var cities: Array = _world_state.get("cities", [])
	for i in cities.size():
		var city: Dictionary = cities[i]
		if String(city.get("id", "")) == city_id:
			return i
	return -1

func _recursive_merge(target: Dictionary, patch: Dictionary) -> void:
	for key in patch.keys():
		var patch_value: Variant = patch[key]
		if patch_value is Dictionary and target.get(key, null) is Dictionary:
			var nested_target: Dictionary = target[key]
			_recursive_merge(nested_target, patch_value)
			target[key] = nested_target
		else:
			target[key] = patch_value

func _find_relation(faction_a: String, faction_b: String) -> Dictionary:
	var diplomacy: Dictionary = _world_state.get("diplomacy", {})
	for rel_any in diplomacy.get("relations", []):
		var rel: Dictionary = rel_any
		if _is_relation_pair(rel, faction_a, faction_b):
			return rel
	return {}

func _is_relation_pair(relation: Dictionary, faction_a: String, faction_b: String) -> bool:
	var a: String = String(relation.get("a", ""))
	var b: String = String(relation.get("b", ""))
	return (a == faction_a and b == faction_b) or (a == faction_b and b == faction_a)