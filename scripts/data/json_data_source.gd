extends RefCounted
class_name JsonDataSource

func load_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("JSON file not found: %s" % path)
		return {}

	var raw_text := FileAccess.get_file_as_string(path)
	var parser := JSON.new()
	var parse_code := parser.parse(raw_text)
	if parse_code != OK:
		push_error("JSON parse failed: %s (line %d)" % [path, parser.get_error_line()])
		return {}

	if not (parser.data is Dictionary):
		push_error("JSON root is not Dictionary: %s" % path)
		return {}

	return (parser.data as Dictionary).duplicate(true)

func save_dictionary(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("JSON write open failed: %s" % path)
		return false
	file.store_string(JSON.stringify(value, "\t", false))
	return true
