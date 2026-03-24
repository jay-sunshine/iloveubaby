extends "res://scripts/logic/logic_module_base.gd"
class_name AIModule

func get_module_name() -> String:
	return "ai"

func tick(_delta_days: float, api, _inbox: Array[Dictionary], bus) -> void:
	var rules: Dictionary = api.get_rules("ai")
	var policy_cycle: Array = rules.get("policy_cycle", [])
	if policy_cycle.is_empty():
		return

	var switch_days: float = maxf(float(rules.get("policy_switch_days", 7.0)), 0.001)
	var cycle_index: int = int(floor(api.get_calendar_day() / switch_days))
	var player_faction: String = api.get_player_faction_id()

	for city_id in api.list_city_ids():
		var city: Dictionary = api.get_city(city_id)
		if String(city.get("faction_id", "")) == player_faction:
			continue
		var index_with_seed: int = (cycle_index + _city_seed(city_id)) % policy_cycle.size()
		var focus: String = String(policy_cycle[index_with_seed])
		bus.publish(get_module_name(), "ai_policy", {
			"city_id": city_id,
			"focus": focus
		})

func _city_seed(city_id: String) -> int:
	var seed := 0
	for idx in city_id.length():
		seed += city_id.unicode_at(idx)
	return seed