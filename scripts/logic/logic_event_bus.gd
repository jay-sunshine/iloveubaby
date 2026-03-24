extends RefCounted
class_name LogicEventBus

var _events: Array[Dictionary] = []

func clear() -> void:
	_events.clear()

func publish(source_module: String, event_type: String, payload: Dictionary = {}) -> void:
	_events.append({
		"source": source_module,
		"type": event_type,
		"payload": payload.duplicate(true)
	})

func get_events() -> Array[Dictionary]:
	var copy: Array[Dictionary] = []
	for event_entry in _events:
		copy.append((event_entry as Dictionary).duplicate(true))
	return copy

func filter_by_type(events: Array[Dictionary], event_type: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for event_entry in events:
		if String(event_entry.get("type", "")) == event_type:
			out.append(event_entry)
	return out
