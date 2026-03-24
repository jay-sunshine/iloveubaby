extends SceneTree

const ROOT_SCENE_SCRIPT := preload("res://scripts/presentation/china_terrain_scene.gd")
const CAMERA_SCRIPT := preload("res://scripts/presentation/map_camera_controller.gd")
const POLITICAL_OVERLAY_SCRIPT := preload("res://scripts/presentation/china_political_mask_overlay.gd")
const GRASS_ALBEDO := "res://素材/nature/textures/grass-02-alb.png"
const GRASS_NORMAL := "res://素材/nature/textures/grass-02-nrm.png"
const ROCK_ALBEDO := "res://素材/nature/textures/rock-alb.png"
const ROCK_NORMAL := "res://素材/nature/textures/rock-norm.png"

const HEIGHTMAP_PATH := "res://data/terrain/china_30km/china_height_30km.r16"
const TERRAIN_DATA_DIR := "res://data/terrain/china_30km/terrain_data"
const OUTPUT_SCENE_PATH := "res://scenes/china_terrain_30km.tscn"
const WORLD_SIZE_M := 30000.0
const SEA_DEPTH_M := -1200.0
const LAND_MAX_HEIGHT_M := 1900.0
const DEM_SIZE := 4096
const IMPORT_CENTER := Vector2i(-15000, -15000)
const WATER_LEVEL_M := -20.0
const WATER_PLANE_SIZE_M := 42000.0
const SLOPE_ROCK_DEGREES := 40.0
const GRASS_TEXTURE_ID := 0
const ROCK_TEXTURE_ID := 1


func _initialize() -> void:
	process_frame.connect(Callable(self, "_run"), CONNECT_ONE_SHOT)


func _run() -> void:
	_clear_output_dir(TERRAIN_DATA_DIR)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(TERRAIN_DATA_DIR))

	var camera: Camera3D = Camera3D.new()
	camera.current = true
	get_root().add_child(camera)

	var importer_script: Script = load("res://addons/terrain_3d/tools/importer.gd")
	var importer: Node = importer_script.new()
	get_root().add_child(importer)
	await process_frame
	var terrain_material: Resource = _build_terrain_material()
	var terrain_assets: Resource = _build_terrain_assets()
	var vertex_spacing := WORLD_SIZE_M / float(DEM_SIZE - 1)

	importer.set("mesh_size", 48)
	importer.set("vertex_spacing", vertex_spacing)
	importer.set("save_16_bit", true)
	importer.set("material", terrain_material)
	importer.set("assets", terrain_assets)
	importer.set("height_file_name", HEIGHTMAP_PATH)
	importer.set("import_position", IMPORT_CENTER)
	importer.set("import_scale", 1.0)
	importer.set("height_offset", 0.0)
	importer.set("r16_size", Vector2i(DEM_SIZE, DEM_SIZE))
	importer.set("r16_range", Vector2(SEA_DEPTH_M, LAND_MAX_HEIGHT_M))
	importer.set("destination_directory", TERRAIN_DATA_DIR)
	importer.call("reset_terrain", true)
	importer.call("start_import", true)
	_apply_surface_controls(importer, vertex_spacing)
	importer.call("save_data", true)

	var root: Node3D = Node3D.new()
	root.name = "ChinaTerrain30km"
	root.set_script(ROOT_SCENE_SCRIPT)

	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.name = "WorldEnv"
	world_env.environment = Environment.new()
	world_env.environment.background_mode = Environment.BG_COLOR
	world_env.environment.background_color = Color(0.56, 0.58, 0.62, 1.0)
	world_env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world_env.environment.ambient_light_color = Color(0.84, 0.86, 0.9, 1.0)
	world_env.environment.ambient_light_energy = 1.4
	world_env.environment.ambient_light_sky_contribution = 0.0
	root.add_child(world_env)
	world_env.owner = root

	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.name = "SunLight"
	sun.rotation_degrees = Vector3(-48.0, 38.0, 0.0)
	sun.shadow_enabled = false
	sun.light_energy = 1.35
	sun.light_indirect_energy = 0.25
	root.add_child(sun)
	sun.owner = root

	var scene_camera: Camera3D = Camera3D.new()
	scene_camera.name = "EditorCamera"
	scene_camera.current = true
	scene_camera.far = WORLD_SIZE_M * 2.0
	scene_camera.look_at_from_position(Vector3(WORLD_SIZE_M * 0.5, 15000.0, WORLD_SIZE_M * 1.15), Vector3(WORLD_SIZE_M * 0.5, 0.0, WORLD_SIZE_M * 0.5), Vector3.UP)
	scene_camera.set_script(CAMERA_SCRIPT)
	root.add_child(scene_camera)
	scene_camera.owner = root

	var terrain: Node3D = ClassDB.instantiate("Terrain3D")
	terrain.name = "Terrain3D"
	terrain.set("data_directory", TERRAIN_DATA_DIR)
	terrain.set("material", terrain_material)
	terrain.set("assets", terrain_assets)
	terrain.set("mesh_size", 48)
	terrain.set("vertex_spacing", vertex_spacing)
	terrain.set("save_16_bit", true)
	root.add_child(terrain)
	terrain.owner = root

	var water := MeshInstance3D.new()
	water.name = "SeaWater"
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(WATER_PLANE_SIZE_M, WATER_PLANE_SIZE_M)
	water.mesh = water_mesh
	water.position = Vector3(0.0, WATER_LEVEL_M, 0.0)
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	water.material_override = _build_water_material()
	root.add_child(water)
	water.owner = root

	var political_overlay := Node3D.new()
	political_overlay.name = "PoliticalOverview"
	political_overlay.set_script(POLITICAL_OVERLAY_SCRIPT)
	political_overlay.visible = false
	root.add_child(political_overlay)
	political_overlay.owner = root

	var packed: PackedScene = PackedScene.new()
	var pack_err: int = packed.pack(root)
	if pack_err == OK:
		ResourceSaver.save(packed, OUTPUT_SCENE_PATH)
	quit(pack_err)


func _clear_output_dir(res_dir: String) -> void:
	var abs_dir: String = ProjectSettings.globalize_path(res_dir)
	if not DirAccess.dir_exists_absolute(abs_dir):
		return
	var dir: DirAccess = DirAccess.open(abs_dir)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var name: String = dir.get_next()
		if name.is_empty():
			break
		if name == "." or name == "..":
			continue
		var child_path: String = abs_dir.path_join(name)
		if dir.current_is_dir():
			DirAccess.remove_absolute(child_path)
		else:
			DirAccess.remove_absolute(child_path)
	dir.list_dir_end()


func _apply_surface_controls(importer: Node, vertex_spacing: float) -> void:
	var terrain_data: Object = importer.get("data")
	if terrain_data == null:
		return
	var slope_threshold := tan(deg_to_rad(SLOPE_ROCK_DEGREES))
	var regions: Array = terrain_data.call("get_regions_active")
	for region in regions:
		var region_location: Vector2i = region.call("get_location")
		var height_map: Image = region.call("get_height_map")
		var control_map: Image = region.call("get_control_map")
		if height_map == null or control_map == null:
			continue
		var map_width: int = height_map.get_width()
		var map_height: int = height_map.get_height()
		for y in range(map_height):
			var y_prev: int = max(y - 1, 0)
			var y_next: int = min(y + 1, map_height - 1)
			var z_span: float = max(float(y_next - y_prev) * vertex_spacing, 0.001)
			for x in range(map_width):
				var x_prev: int = max(x - 1, 0)
				var x_next: int = min(x + 1, map_width - 1)
				var x_span: float = max(float(x_next - x_prev) * vertex_spacing, 0.001)
				var center_height: float = height_map.get_pixel(x, y).r
				var texture_id: int = GRASS_TEXTURE_ID
				if center_height < 0.0:
					texture_id = ROCK_TEXTURE_ID
				else:
					var dx: float = (height_map.get_pixel(x_next, y).r - height_map.get_pixel(x_prev, y).r) / x_span
					var dz: float = (height_map.get_pixel(x, y_next).r - height_map.get_pixel(x, y_prev).r) / z_span
					var slope: float = sqrt(dx * dx + dz * dz)
					if slope >= slope_threshold:
						texture_id = ROCK_TEXTURE_ID
				control_map.set_pixel(x, y, Color(_encode_control(texture_id, texture_id, 0.0, false), 0.0, 0.0, 1.0))
		region.call("set_control_map", control_map)
		terrain_data.call("set_region_modified", region_location, true)
	terrain_data.call("update_maps", 1, true, false)


func _encode_control(base_id: int, overlay_id: int, blend: float, auto_enabled: bool) -> float:
	var blend_byte := int(clamp(round(blend * 255.0), 0.0, 255.0))
	var control := ((base_id & 0x1F) << 27) | ((overlay_id & 0x1F) << 22) | ((blend_byte & 0xFF) << 14)
	if auto_enabled:
		control |= 0x1
	var bytes := PackedByteArray()
	bytes.resize(4)
	bytes.encode_u32(0, control)
	return bytes.decode_float(0)


func _build_terrain_material() -> Resource:
	if not ClassDB.class_exists("Terrain3DMaterial"):
		return null
	var material: Object = ClassDB.instantiate("Terrain3DMaterial")
	material.call("set_auto_shader", false)
	material.call("set_show_checkered", false)
	material.set("_shader_parameters", {
		&"blend_sharpness": 0.92,
		&"macro_variation_slope": 0.33
	})
	return material as Resource


func _build_terrain_assets() -> Resource:
	if not ClassDB.class_exists("Terrain3DAssets") or not ClassDB.class_exists("Terrain3DTextureAsset"):
		return null
	var assets: Object = ClassDB.instantiate("Terrain3DAssets")
	assets.call("clear_textures")
	assets.call("set_texture", 0, _make_texture_asset("Grass", GRASS_ALBEDO, GRASS_NORMAL, 0.075, 0.32, 0.97))
	assets.call("set_texture", 1, _make_texture_asset("Rock", ROCK_ALBEDO, ROCK_NORMAL, 0.11, 0.55, 1.0))
	assets.call("update_texture_list")
	return assets as Resource


func _make_texture_asset(asset_name: String, albedo_path: String, normal_path: String, uv_scale: float, normal_depth: float, roughness: float) -> Object:
	var texture_asset: Object = ClassDB.instantiate("Terrain3DTextureAsset")
	texture_asset.call("set_name", asset_name)
	texture_asset.call("set_albedo_texture", load(albedo_path))
	texture_asset.call("set_normal_texture", load(normal_path))
	texture_asset.call("set_uv_scale", uv_scale)
	texture_asset.call("set_normal_depth", normal_depth)
	texture_asset.call("set_roughness", roughness)
	texture_asset.call("set_ao_strength", 1.0)
	return texture_asset

func _build_water_material() -> Material:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.16, 0.34, 0.46, 0.54)
	material.metallic = 0.02
	material.roughness = 0.08
	material.rim_enabled = true
	material.rim = 0.18
	material.rim_tint = 0.65
	material.clearcoat_enabled = true
	material.clearcoat = 0.45
	material.clearcoat_roughness = 0.12
	material.refraction_enabled = false
	material.disable_receive_shadows = true
	material.no_depth_test = false
	return material
