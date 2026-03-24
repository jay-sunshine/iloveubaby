extends "res://scripts/logic/logic_module_base.gd"
class_name BattleModule

func get_module_name() -> String:
	return "battle"

func tick(delta_days: float, api, _inbox: Array[Dictionary], bus) -> void:
	var rules: Dictionary = api.get_rules("battle")
	var hostile_threshold: float = float(rules.get("hostile_relation_threshold", -35.0))
	var skirmish_distance: float = float(rules.get("skirmish_distance", 1000.0))
	var base_ratio: float = float(rules.get("base_daily_casualty_ratio", 0.0))
	var relation_mul: float = float(rules.get("relation_pressure_multiplier", 0.0))
	var security_loss: float = float(rules.get("security_loss_per_skirmish", 0.0)) * delta_days
	var troops_min: float = float(rules.get("troops_min", 0.0))
	var security_min: float = float(rules.get("security_min", 0.0))
	var security_max: float = float(rules.get("security_max", 100.0))

	var city_ids: Array[String] = api.list_city_ids()
	for i in city_ids.size():
		for j in range(i + 1, city_ids.size()):
			var city_a: Dictionary = api.get_city(city_ids[i])
			var city_b: Dictionary = api.get_city(city_ids[j])
			var faction_a: String = String(city_a.get("faction_id", ""))
			var faction_b: String = String(city_b.get("faction_id", ""))
			if faction_a == faction_b:
				continue

			var relation: float = api.get_relation_value(faction_a, faction_b)
			if relation > hostile_threshold:
				continue

			if api.get_distance_between_cities(city_ids[i], city_ids[j]) > skirmish_distance:
				continue

			var pressure: float = absf(relation) / 100.0 * relation_mul
			var ratio: float = (base_ratio + base_ratio * pressure) * delta_days
			_apply_city_loss(api, city_a, ratio, security_loss, troops_min, security_min, security_max)
			_apply_city_loss(api, city_b, ratio, security_loss, troops_min, security_min, security_max)
			bus.publish(get_module_name(), "battle_skirmish", {
				"city_a": city_ids[i],
				"city_b": city_ids[j],
				"faction_a": faction_a,
				"faction_b": faction_b,
				"casualty_ratio": ratio
			})

func _apply_city_loss(api, city: Dictionary, ratio: float, security_loss: float, troops_min: float, security_min: float, security_max: float) -> void:
	var city_id: String = String(city.get("id", ""))
	var stats: Dictionary = city.get("stats", {})
	var troops: float = float(stats.get("troops", 0.0))
	var security: float = float(stats.get("security", 0.0))
	var new_troops: float = maxf(troops_min, troops - troops * ratio)
	var new_security: float = clampf(security - security_loss, security_min, security_max)
	api.patch_city(city_id, {
		"stats": {
			"troops": new_troops,
			"security": new_security
		}
	}, get_module_name())