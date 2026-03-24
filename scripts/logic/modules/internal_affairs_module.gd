extends "res://scripts/logic/logic_module_base.gd"
class_name InternalAffairsModule

func get_module_name() -> String:
	return "internal_affairs"

func tick(delta_days: float, api, inbox: Array[Dictionary], _bus) -> void:
	var rules: Dictionary = api.get_rules("internal_affairs")
	var base_income: Dictionary = rules.get("resource_income_base", {})
	var focus_bonus: Dictionary = rules.get("focus_bonus", {})
	var drift: Dictionary = rules.get("support_security_drift", {})
	var consumption: Dictionary = rules.get("consumption", {})
	var clamp_rules: Dictionary = rules.get("clamp", {})
	var coeff: Dictionary = rules.get("coefficients", {})
	var pop_growth: float = float(rules.get("population_growth_per_day", 0.0))
	var ai_focus: Dictionary = _collect_ai_focus(inbox)

	var taishou_global_base: float = float(coeff.get("taishou_global_base", 0.7))
	var taishou_global_scale: float = float(coeff.get("taishou_global_scale", 0.6))
	var role_floor: float = float(coeff.get("role_resource_floor", 0.45))
	var role_scale: float = float(coeff.get("role_resource_scale", 0.95))
	var tax_rate_base: float = float(coeff.get("tax_rate_base", 0.08))
	var tax_rate_shicao_scale: float = float(coeff.get("tax_rate_shicao_scale", 0.12))
	var stable_horse_per_day_per_level: float = float(coeff.get("stable_horse_per_day_per_level", 10.0))
	var tech_gain_base: float = float(coeff.get("gongcao_tech_gain_per_day", 1.0))
	var troop_gain_base: float = float(coeff.get("bingcao_troop_gain_per_day", 120.0))
	var morale_gain_base: float = float(coeff.get("bingcao_morale_gain_per_day", 0.18))
	var defense_repair_base: float = float(coeff.get("duwei_defense_repair_per_day", 32.0))
	var support_from_taishou: float = float(coeff.get("taishou_support_factor", 0.02))
	var security_from_duwei: float = float(coeff.get("duwei_security_factor", 0.02))

	for city_id in api.list_city_ids():
		var city: Dictionary = api.get_city(city_id)
		var resources: Dictionary = city.get("resources", {})
		var stats: Dictionary = city.get("stats", {})
		var officers: Dictionary = city.get("officers", {})
		var defense: Dictionary = city.get("defense", {})
		var development: Dictionary = city.get("development", {})
		var focus: String = String(ai_focus.get(city_id, ""))

		var taishou: float = float(officers.get("taishou", 50.0))
		var shicao: float = float(officers.get("shicao", 50.0))
		var hucao: float = float(officers.get("hucao", 50.0))
		var junxu: float = float(officers.get("junxu", hucao))
		var gongcao: float = float(officers.get("gongcao", 50.0))
		var bingcao: float = float(officers.get("bingcao", 50.0))
		var duwei: float = float(officers.get("duwei", 50.0))

		var taishou_norm: float = _role_norm(taishou)
		var shicao_norm: float = _role_norm(shicao)
		var hucao_norm: float = _role_norm(hucao)
		var junxu_norm: float = _role_norm(junxu)
		var gongcao_norm: float = _role_norm(gongcao)
		var bingcao_norm: float = _role_norm(bingcao)
		var duwei_norm: float = _role_norm(duwei)

		var support_now: float = float(stats.get("public_support", 0.0))
		var security_now: float = float(stats.get("security", 0.0))
		var support_factor: float = support_now / 100.0
		var security_factor: float = security_now / 100.0
		var taishou_global_mul: float = taishou_global_base + taishou_norm * taishou_global_scale
		var common_income_mul: float = taishou_global_mul * (0.65 + support_factor * 0.35) * (0.65 + security_factor * 0.35)

		var money_income: float = float(base_income.get("money", 0.0)) * (role_floor + shicao_norm * role_scale) * (1.0 + tax_rate_base + shicao_norm * tax_rate_shicao_scale) * common_income_mul * delta_days
		var food_income: float = float(base_income.get("food", 0.0)) * (role_floor + hucao_norm * role_scale) * common_income_mul * delta_days
		var wood_income: float = float(base_income.get("wood", 0.0)) * (role_floor + junxu_norm * role_scale) * common_income_mul * delta_days
		var iron_income: float = float(base_income.get("iron", 0.0)) * (role_floor + gongcao_norm * role_scale) * common_income_mul * delta_days
		var stables_lv: float = maxf(0.0, float(development.get("stables", 0.0)))
		var horse_income_base: float = float(base_income.get("horse", 0.0))
		var horse_income: float = (horse_income_base + stables_lv * stable_horse_per_day_per_level) * (role_floor + bingcao_norm * role_scale) * common_income_mul * delta_days

		if focus == "money":
			money_income *= 1.0 + float(focus_bonus.get("money", 0.0))
		if focus == "food":
			food_income *= 1.0 + float(focus_bonus.get("food", 0.0))
		if focus == "wood":
			wood_income *= 1.0 + float(focus_bonus.get("wood", 0.0))
		if focus == "iron":
			iron_income *= 1.0 + float(focus_bonus.get("iron", 0.0))
		if focus == "horse":
			horse_income *= 1.0 + float(focus_bonus.get("horse", 0.0))

		var reserve_now: float = float(stats.get("reserve_troops", 0.0))
		var organized_now: float = float(stats.get("organized_troops", 0.0))
		var troops_now: float = float(stats.get("troops", reserve_now + organized_now))
		if reserve_now <= 0.0 and organized_now <= 0.0 and troops_now > 0.0:
			reserve_now = troops_now
		var money_after_income: float = float(resources.get("money", 0.0)) + money_income
		var food_after_income: float = float(resources.get("food", 0.0)) + food_income
		var wood_after_income: float = float(resources.get("wood", 0.0)) + wood_income
		var iron_after_income: float = float(resources.get("iron", 0.0)) + iron_income
		var horse_after_income: float = float(resources.get("horse", 0.0)) + horse_income
		money_after_income -= troops_now * float(consumption.get("money_per_troop_per_day", 0.0)) * delta_days
		food_after_income -= troops_now * float(consumption.get("food_per_troop_per_day", 0.0)) * delta_days

		var patch_resources := {
			"money": maxf(float(clamp_rules.get("resource_min", 0.0)), money_after_income),
			"food": maxf(float(clamp_rules.get("resource_min", 0.0)), food_after_income),
			"wood": maxf(float(clamp_rules.get("resource_min", 0.0)), wood_after_income),
			"iron": maxf(float(clamp_rules.get("resource_min", 0.0)), iron_after_income),
			"horse": maxf(float(clamp_rules.get("resource_min", 0.0)), horse_after_income)
		}

		var troop_gain: float = troop_gain_base * (0.45 + bingcao_norm * 0.9) * (0.6 + support_factor * 0.4) * delta_days
		var morale_gain: float = morale_gain_base * (0.5 + bingcao_norm * 0.7 + taishou_norm * 0.4) * delta_days
		if focus == "military":
			troop_gain *= 1.0 + float(focus_bonus.get("military", 0.0))
			morale_gain *= 1.0 + float(focus_bonus.get("military", 0.0))

		# Simplified role responsibilities:
		# Taishou -> support/public hearts, Duwei -> security/defense.
		var support_delta: float = taishou * support_from_taishou * delta_days * 0.1
		var security_delta: float = duwei * security_from_duwei * delta_days * 0.1
		support_delta += security_now * float(drift.get("security_to_support", 0.0)) * delta_days
		security_delta += support_now * float(drift.get("support_to_security", 0.0)) * delta_days
		if focus == "support":
			support_delta += float(focus_bonus.get("support", 0.0))
		if focus == "security":
			security_delta += float(focus_bonus.get("security", 0.0))

		var support_next: float = clampf(
			support_now + support_delta,
			float(clamp_rules.get("public_support_min", 0.0)),
			float(clamp_rules.get("public_support_max", 100.0))
		)
		var security_next: float = clampf(
			security_now + security_delta,
			float(clamp_rules.get("security_min", 0.0)),
			float(clamp_rules.get("security_max", 100.0))
		)

		var population_now: float = float(stats.get("population", 0.0))
		var population_next: float = maxf(
			float(clamp_rules.get("population_min", 0.0)),
			population_now + population_now * pop_growth * (0.5 + support_next / 200.0) * delta_days
		)

		var tech_now: float = float(stats.get("tech_points", 0.0))
		var tech_gain: float = tech_gain_base * (0.6 + gongcao_norm * 0.9) * taishou_global_mul * delta_days
		var morale_now: float = float(stats.get("morale", 70.0))
		var troops_min: float = float(clamp_rules.get("troops_min", 0.0))
		var reserve_next: float = maxf(troops_min, reserve_now + troop_gain)
		var organized_next: float = maxf(0.0, organized_now)
		var troops_next: float = maxf(troops_min, reserve_next + organized_next)
		var morale_next: float = clampf(morale_now + morale_gain, 0.0, 100.0)

		var defense_current_now: float = float(defense.get("current", 0.0))
		var defense_max: float = float(defense.get("max", defense_current_now))
		var defense_repair: float = defense_repair_base * (0.5 + duwei_norm * 0.9) * delta_days
		var defense_current_next: float = clampf(defense_current_now + defense_repair, 0.0, defense_max)

		api.patch_city(city_id, {
			"resources": patch_resources,
			"stats": {
				"public_support": support_next,
				"security": security_next,
				"population": population_next,
				"reserve_troops": reserve_next,
				"organized_troops": organized_next,
				"troops": troops_next,
				"morale": morale_next,
				"tech_points": maxf(0.0, tech_now + tech_gain)
			},
			"defense": {
				"current": defense_current_next,
				"max": defense_max
			}
		}, get_module_name())

func _role_norm(score: float) -> float:
	return clampf(score / 100.0, 0.0, 1.5)

func _collect_ai_focus(inbox: Array[Dictionary]) -> Dictionary:
	var out: Dictionary = {}
	for event_entry in inbox:
		if String(event_entry.get("type", "")) != "ai_policy":
			continue
		var payload: Dictionary = event_entry.get("payload", {})
		out[String(payload.get("city_id", ""))] = String(payload.get("focus", ""))
	return out
