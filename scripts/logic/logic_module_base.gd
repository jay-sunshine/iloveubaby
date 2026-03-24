extends RefCounted
class_name LogicModuleBase

func get_module_name() -> String:
	return ""

func tick(_delta_days: float, _api, _inbox: Array[Dictionary], _bus) -> void:
	pass
