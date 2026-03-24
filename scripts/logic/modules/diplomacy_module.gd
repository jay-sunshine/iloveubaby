extends "res://scripts/logic/logic_module_base.gd"
class_name DiplomacyModule

func get_module_name() -> String:
	return "diplomacy"

func tick(delta_days: float, api, inbox: Array[Dictionary], bus) -> void:
	var rules: Dictionary = api.get_rules("diplomacy")
	var relation_min: float = float(rules.get("relation_min", -100.0))
	var relation_max: float = float(rules.get("relation_max", 100.0))
	var recover_per_day: float = float(rules.get("daily_relation_recover", 0.0))
	var battle_penalty: float = float(rules.get("battle_event_penalty", 0.0))
	var support_gap_factor: float = float(rules.get("support_gap_factor", 0.0))

	var factions: Array[String] = api.list_factions()
	for i in factions.size():
		for j in range(i + 1, factions.size()):
			var a: String = factions[i]
			var b: String = factions[j]
			var relation: float = api.get_relation_value(a, b)
			relation += recover_per_day * delta_days

			var support_gap: float = _faction_support_average(api, a) - _faction_support_average(api, b)
			relation += support_gap * support_gap_factor * delta_days

			for event_entry in inbox:
				if String(event_entry.get("type", "")) != "battle_skirmish":
					continue
				var payload: Dictionary = event_entry.get("payload", {})
				if _same_faction_pair(payload, a, b):
					relation -= battle_penalty

			relation = clampf(relation, relation_min, relation_max)
			api.patch_relation_value(a, b, relation, get_module_name())
			bus.publish(get_module_name(), "relation_updated", {
				"a": a,
				"b": b,
				"value": relation
			})

func _faction_support_average(api, faction_id: String) -> float:
	var total: float = 0.0
	var count: float = 0.0
	for city_id in api.list_city_ids():
		var city: Dictionary = api.get_city(city_id)
		if String(city.get("faction_id", "")) != faction_id:
			continue
		var stats: Dictionary = city.get("stats", {})
		total += float(stats.get("public_support", 0.0))
		count += 1.0
	if count <= 0.0:
		return 0.0
	return total / count

func _same_faction_pair(payload: Dictionary, faction_a: String, faction_b: String) -> bool:
	var pa: String = String(payload.get("faction_a", ""))
	var pb: String = String(payload.get("faction_b", ""))
	return (pa == faction_a and pb == faction_b) or (pa == faction_b and pb == faction_a)