extends Node
class_name PreloadManager

signal preload_progress(progress: float)
signal preload_finished

var _cache: Dictionary = {}
var _pending_paths: Array[String] = []
var _request_total: int = 0
var _request_completed: int = 0

func begin(paths: Array[String]) -> void:
	_pending_paths.clear()
	_request_total = 0
	_request_completed = 0

	for path in paths:
		if path.is_empty() or _cache.has(path):
			continue
		var err: int = ResourceLoader.load_threaded_request(path)
		if err == OK or err == ERR_BUSY:
			_pending_paths.append(path)
			_request_total += 1
			continue
		var fallback: Resource = load(path)
		if fallback != null:
			_cache[path] = fallback

	if _request_total <= 0:
		emit_signal("preload_progress", 1.0)
		emit_signal("preload_finished")
		set_process(false)
		return

	emit_signal("preload_progress", 0.0)
	set_process(true)

func get_or_load(path: String) -> Resource:
	if _cache.has(path):
		return _cache[path]
	var loaded: Resource = load(path)
	if loaded != null:
		_cache[path] = loaded
	return loaded

func is_ready(path: String) -> bool:
	return _cache.has(path)

func _process(_delta: float) -> void:
	if _pending_paths.is_empty():
		return

	for i in range(_pending_paths.size() - 1, -1, -1):
		var path: String = _pending_paths[i]
		var progress: Array = []
		var status: int = ResourceLoader.load_threaded_get_status(path, progress)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			continue
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var resource: Resource = ResourceLoader.load_threaded_get(path)
			if resource != null:
				_cache[path] = resource
		_pending_paths.remove_at(i)
		_request_completed += 1

	var ratio: float = 1.0
	if _request_total > 0:
		ratio = float(_request_completed) / float(_request_total)
	emit_signal("preload_progress", clampf(ratio, 0.0, 1.0))

	if _pending_paths.is_empty():
		set_process(false)
		emit_signal("preload_finished")