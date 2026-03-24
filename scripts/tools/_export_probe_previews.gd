extends SceneTree

const TARGETS := {
	"terrain_data_probe": "res://data/terrain/china_30km/terrain_data_probe_preview.png",
	"terrain_data_probe2": "res://data/terrain/china_30km/terrain_data_probe2_preview.png",
	"terrain_data_probe4096": "res://data/terrain/china_30km/terrain_data_probe4096_preview.png",
	"terrain_data_test_center": "res://data/terrain/china_30km/terrain_data_test_center_preview.png"
}

func _initialize() -> void:
	process_frame.connect(Callable(self, "_run"), CONNECT_ONE_SHOT)

func _run() -> void:
	var camera := Camera3D.new()
	camera.current = true
	get_root().add_child(camera)
	for dir_name in TARGETS.keys():
		var terrain: Node = ClassDB.instantiate("Terrain3D")
		get_root().add_child(terrain)
		terrain.set("data_directory", "res://data/terrain/china_30km/" + dir_name)
		await process_frame
		var data: Object = terrain.get("data") as Object
		if data != null:
			var err: int = data.call("export_image", String(TARGETS[dir_name]), 0)
			print(dir_name, " -> ", err)
		terrain.queue_free()
		await process_frame
	quit()
