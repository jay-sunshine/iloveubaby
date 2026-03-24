extends "res://scripts/logic/logic_module_base.gd"
class_name GeneralModule

func get_module_name() -> String:
	return "general"

func tick(delta_days: float, api, inbox: Array[Dictionary], _bus) -> void:
	var rules: Dictionary = api.get_rules("general")
	var roles: Array = rules.get("officer_roles", [])
	if roles.is_empty():
		return

	var train_rate: float = float(rules.get("daily_training_rate", 0.0))
	var decay_rate: float = float(rules.get("daily_decay_rate", 0.0))
	var military_bonus: float = float(rules.get("military_focus_bonus", 0.0))
	var value_min: float = float(rules.get("min_officer_value", 1.0))
	var value_max: float = float(rules.get("max_officer_value", 100.0))
	var military_focus_map: Dictionary = _collect_military_focus(inbox)

	for city_id in api.list_city_ids():
		var city: Dictionary = api.get_city(city_id)
		var stats: Dictionary = city.get("stats", {})
		var officers: Dictionary = city.get("officers", {})
		var support_factor: float = float(stats.get("public_support", 0.0)) / 100.0
		var security_factor: float = float(stats.get("security", 0.0)) / 100.0
		var focus_bonus: float = military_bonus if bool(military_focus_map.get(city_id, false)) else 0.0

		var patch_officers: Dictionary = {}
		for role_any in roles:
			var role: String = String(role_any)
			var current: float = float(officers.get(role, 50.0))
			var gain: float = (train_rate * support_factor + focus_bonus) * delta_days
			var loss: float = decay_rate * (1.0 - security_factor) * delta_days
			patch_officers[role] = clampf(current + gain - loss, value_min, value_max)

		api.patch_city(city_id, {
			"officers": patch_officers
		}, get_module_name())

func _collect_military_focus(inbox: Array[Dictionary]) -> Dictionary:
	var out: Dictionary = {}
	for event_entry in inbox:
		if String(event_entry.get("type", "")) != "ai_policy":
			continue
		var payload: Dictionary = event_entry.get("payload", {})
		if String(payload.get("focus", "")) != "military":
			continue
		out[String(payload.get("city_id", ""))] = true
	return out