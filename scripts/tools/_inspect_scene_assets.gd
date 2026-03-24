extends SceneTree
func _init():
	var scene: PackedScene = load("res://scenes/china_terrain_30km.tscn")
	var inst = scene.instantiate()
	get_root().add_child(inst)
	var terrain = inst.get_node("Terrain3D")
	var assets = terrain.get("assets")
	print("ASSETS:", assets)
	if assets:
		for i in range(assets.call("get_texture_count")):
			var tex = assets.call("get_texture", i)
			print("IDX", i, " NAME=", tex.get("name"), " ALB=", tex.get("albedo_texture"), " NRM=", tex.get("normal_texture"))
	var material = terrain.get("material")
	print("AUTO:", material.get("auto_shader"))
	print("PARAMS:", material.get("_shader_parameters"))
	quit()
