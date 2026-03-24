extends SceneTree

const TERRAIN_DATA_DIR := "res://data/terrain/china_30km/terrain_data"
const PREVIEW_PATH := "res://data/terrain/china_30km/china_height_30km_preview.png"


func _initialize() -> void:
	process_frame.connect(Callable(self, "_run"), CONNECT_ONE_SHOT)


func _run() -> void:
	var camera: Camera3D = Camera3D.new()
	camera.current = true
	get_root().add_child(camera)
	var terrain: Node = ClassDB.instantiate("Terrain3D")
	get_root().add_child(terrain)
	terrain.set("data_directory", TERRAIN_DATA_DIR)
	await process_frame
	var data: Object = terrain.get("data") as Object
	if data == null:
		quit(ERR_CANT_OPEN)
		return
	var err: int = data.call("export_image", PREVIEW_PATH, 0)
	quit(err)
