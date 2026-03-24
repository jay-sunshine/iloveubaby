extends RefCounted
class_name GameLogicFacade

const LogicEventBus := preload("res://scripts/logic/logic_event_bus.gd")
const AIModule := preload("res://scripts/logic/modules/ai_module.gd")
const DiplomacyModule := preload("res://scripts/logic/modules/diplomacy_module.gd")
const InternalAffairsModule := preload("res://scripts/logic/modules/internal_affairs_module.gd")
const GeneralModule := preload("res://scripts/logic/modules/general_module.gd")
const BattleModule := preload("res://scripts/logic/modules/battle_module.gd")

var _api
var _event_bus := LogicEventBus.new()
var _modules: Dictionary = {}
var _module_order: Array[String] = []

func _init(api, engine_rules: Dictionary) -> void:
	_api = api
	_modules = {
		"diplomacy": DiplomacyModule.new(),
		"ai": AIModule.new(),
		"internal_affairs": InternalAffairsModule.new(),
		"general": GeneralModule.new(),
		"battle": BattleModule.new()
	}
	for module_name_any in engine_rules.get("module_order", []):
		var module_name: String = String(module_name_any)
		if _modules.has(module_name):
			_module_order.append(module_name)
	if _module_order.is_empty():
		_module_order = ["diplomacy", "ai", "internal_affairs", "general", "battle"]

func tick(delta_days: float) -> Dictionary:
	if delta_days <= 0.0:
		return _api.get_world_snapshot()

	_event_bus.clear()
	for module_name in _module_order:
		var module = _modules[module_name]
		var inbox: Array[Dictionary] = _event_bus.get_events()
		module.tick(delta_days, _api, inbox, _event_bus)

	_api.advance_calendar(delta_days)
	return _api.get_world_snapshot()

func get_world_snapshot() -> Dictionary:
	return _api.get_world_snapshot()

func get_meta_snapshot() -> Dictionary:
	return _api.get_meta_snapshot()

func patch_meta(raw_patch: Dictionary, source_module: String = "logic") -> void:
	_api.patch_meta(raw_patch, source_module)

func set_phase(phase_name: String) -> void:
	_api.patch_meta({"phase": phase_name}, "phase_system")

func get_phase() -> String:
	var meta: Dictionary = _api.get_meta_snapshot()
	return String(meta.get("phase", "internal"))

func refill_command_points() -> void:
	var meta: Dictionary = _api.get_meta_snapshot()
	var max_points: float = float(meta.get("max_command_points", 0.0))
	_api.patch_meta({"command_points": max_points}, "command_system")

func consume_command_points(cost: float) -> bool:
	if cost <= 0.0:
		return true
	var meta: Dictionary = _api.get_meta_snapshot()
	var current: float = float(meta.get("command_points", 0.0))
	if current < cost:
		return false
	_api.patch_meta({"command_points": current - cost}, "command_system")
	return true

func apply_city_patch_from_editor(city_id: String, raw_patch: Dictionary) -> bool:
	var allowed_groups: Array[String] = ["resources", "stats", "officers"]
	var clean_patch: Dictionary = {}
	for group_name in allowed_groups:
		if not raw_patch.has(group_name):
			continue
		var raw_group: Variant = raw_patch[group_name]
		if not (raw_group is Dictionary):
			continue
		var clean_group: Dictionary = {}
		for key in (raw_group as Dictionary).keys():
			var value: Variant = (raw_group as Dictionary)[key]
			if value is float or value is int:
				clean_group[String(key)] = float(value)
		if not clean_group.is_empty():
			clean_patch[group_name] = clean_group

	if clean_patch.is_empty():
		return false
	return _api.patch_city(city_id, clean_patch, "editor_panel")

func apply_city_patch(city_id: String, raw_patch: Dictionary, source_module: String = "logic") -> bool:
	if raw_patch.is_empty():
		return false
	return _api.patch_city(city_id, raw_patch, source_module)

func save_world_state(path: String) -> bool:
	return _api.save_world_state(path)
